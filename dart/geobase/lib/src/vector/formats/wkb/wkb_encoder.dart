// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'wkb_format.dart';

class _WkbGeometryEncoder
    with GeometryContent
    implements ContentEncoder<GeometryContent> {
  final ByteWriter _buffer;

  _WkbGeometryEncoder({
    required Endian endian,
  }) : _buffer = ByteWriter.buffered(
          endian: endian,

          // Note this is needed because of emptyGeometry special case of
          // POINT(NaN NaN) and how it is encoded in WKB (same way with OSGEO)
          nanEncodedAsNegative: true,
        );

  @override
  GeometryContent get writer => this;

  @override
  Uint8List toBytes() => _buffer.toBytes();

  @override
  String toText() => base64.encode(toBytes());

  @override
  String toString() => toText();

  @override
  void point(
    Position position, {
    String? name,
  }) {
    // type for coordinates
    final coordType = position.type;

    // write a point geometry
    _writeGeometryHeader(Geom.point, coordType);
    _writePosition(position, coordType);
  }

  @override
  void lineString(
    PositionSeries chain, {
    String? name,
    Box? bounds,
  }) {
    // type for coordinates
    final coordType = chain.type;

    // write a line string geometry
    _writeGeometryHeader(Geom.lineString, coordType);
    _writePositionSeries(chain, coordType);
  }

  @override
  void polygon(
    Iterable<PositionSeries> rings, {
    String? name,
    Box? bounds,
  }) {
    // type for coordinates
    final coordType = positionSeriesArrayType(rings);

    // write a polygon geometry
    _writeGeometryHeader(Geom.polygon, coordType);

    // write numRings
    _buffer.writeUint32(rings.length);

    // write all linear rings (of polygon)
    for (final linearRing in rings) {
      _writePositionSeries(linearRing, coordType);
    }
  }

  @override
  void multiPoint(
    Iterable<Position> points, {
    String? name,
    Box? bounds,
  }) {
    // type for coordinates
    final coordType = positionArrayType(points);

    // write a multi point geometry
    _writeGeometryHeader(Geom.multiPoint, coordType);

    // write numPoints
    _buffer.writeUint32(points.length);

    // write all points
    for (final point in points) {
      _writeGeometryHeader(Geom.point, coordType);
      _writePosition(point, coordType);
    }
  }

  @override
  void multiLineString(
    Iterable<PositionSeries> lineStrings, {
    String? name,
    Box? bounds,
  }) {
    // type for coordinates
    final coordType = positionSeriesArrayType(lineStrings);

    // write a multi line geometry
    _writeGeometryHeader(Geom.multiLineString, coordType);

    // write numLineStrings
    _buffer.writeUint32(lineStrings.length);

    // write chains of all line strings
    for (final chain in lineStrings) {
      _writeGeometryHeader(Geom.lineString, coordType);
      _writePositionSeries(chain, coordType);
    }
  }

  @override
  void multiPolygon(
    Iterable<Iterable<PositionSeries>> polygons, {
    String? name,
    Box? bounds,
  }) {
    // type for coordinates
    final coordType = positionSeriesArrayArrayType(polygons);

    // write a multi polygon geometry
    _writeGeometryHeader(Geom.multiPolygon, coordType);

    // write numPolygons
    _buffer.writeUint32(polygons.length);

    // write all rings of polygons
    for (final rings in polygons) {
      _writeGeometryHeader(Geom.polygon, coordType);

      // write numRings
      _buffer.writeUint32(rings.length);

      // write all linear rings for a polygon
      for (final linearRing in rings) {
        _writePositionSeries(linearRing, coordType);
      }
    }
  }

  @override
  void geometryCollection(
    WriteGeometries geometries, {
    Coords? type,
    int? count,
    String? name,
    Box? bounds,
  }) {
    final int numGeom;
    final Coords coordType;

    if (type != null && count != null) {
      numGeom = count;
      coordType = type;
    } else {
      // calculate number of geometries and analyze coordinate types
      final collector = _GeometryCollector();
      geometries.call(collector);
      numGeom = count ?? collector.numGeometries;
      coordType = Coords.select(
        is3D: collector.hasZ,
        isMeasured: collector.hasM,
      );
    }

    // write header for geometry collection
    _writeGeometryHeader(Geom.geometryCollection, coordType);
    _buffer.writeUint32(numGeom);

    // recursively write geometries contained in a collection (same writer)
    geometries.call(this);
  }

  @override
  void emptyGeometry(Geom type, {String? name}) {
    // type for coordinates
    const coordType = Coords.xy;

    switch (type) {
      case Geom.point:
        // this is a special case => https://trac.osgeo.org/geos/ticket/1005
        //                           https://trac.osgeo.org/postgis/ticket/3181
        //                           https://github.com/OSGeo/gdal/issues/2472
        // write only x and y as double.nan
        // that is POINT(NaN NaN) is considered POINT EMPTY, or something..
        // Note: negative NaN (whatever it is) is needed to get same output in
        //       bytes as those OSGEO related (reliable?) sources
        //       (thats why buffer is create with nanEncodedAsNegative: true)
        _writeGeometryHeader(type, Coords.xy);
        _buffer
          ..writeFloat64(double.nan)
          ..writeFloat64(double.nan);
        break;
      case Geom.lineString:
      case Geom.polygon:
      case Geom.multiPoint:
      case Geom.multiLineString:
      case Geom.multiPolygon:
      case Geom.geometryCollection:
        // write geometry with 0 elements (points, rings, geometries, etc.)
        _writeGeometryHeader(type, coordType);
        _buffer.writeUint32(0);
        break;
    }
  }

  void _writeGeometryHeader(Geom geomType, Coords coordType) {
    // write byte order
    switch (_buffer.endian) {
      // wkbXDR (= 0 // Big Endian) value of the WKBByteOrder enum
      case Endian.big:
        _buffer.writeInt8(0);
        break;

      // wkbNDR (= 1 // Little Endian) value of the WKBByteOrder enum
      case Endian.little:
        _buffer.writeInt8(1);
        break;
    }

    // enum type (WKBGeometryType) as integer is calculated from geometry and
    // coordinate types as specified by this library
    final type = geomType.wkbId(coordType);

    // write geometry type (as specified by the WKBGeometryType enum)
    _buffer.writeUint32(type);
  }

  void _writePosition(Position point, Coords type) {
    // at least write x and y
    _buffer
      ..writeFloat64(point.x)
      ..writeFloat64(point.y);

    // optionally write z and m too
    if (type.is3D) {
      _buffer.writeFloat64(point.z);
    }
    if (type.isMeasured) {
      _buffer.writeFloat64(point.m);
    }
  }

  void _writePositionSeries(PositionSeries positions, Coords type) {
    // calculate the number of points and coordinate values
    final numPoints = positions.length;
    final numValues = numPoints * type.coordinateDimension;

    // get coordinate values as a double iterable
    final coordinates = positions.valuesByType(type);

    // write numPoints
    _buffer.writeUint32(numPoints);

    // NOTE: write the whole buffer at once

    // write all coordinate values for each point as a flat structure
    var i = 0;
    for (final value in coordinates) {
      if (++i > numValues) throw invalidCoordinates;

      _buffer.writeFloat64(value);
    }
  }
}

// -----------------------------------------------------------------------------

class _GeometryCollector with GeometryContent {
  bool hasZ = false;
  bool hasM = false;
  int numGeometries = 0;

  @override
  void point(
    Position position, {
    String? name,
  }) {
    if (!hasZ || !hasM) {
      final type = position.type;
      hasZ |= type.is3D;
      hasM |= type.isMeasured;
    }
    numGeometries++;
  }

  @override
  void lineString(
    PositionSeries chain, {
    String? name,
    Box? bounds,
  }) {
    if (!hasZ || !hasM) {
      final type = chain.type;
      hasZ |= type.is3D;
      hasM |= type.isMeasured;
    }
    numGeometries++;
  }

  @override
  void polygon(
    Iterable<PositionSeries> rings, {
    String? name,
    Box? bounds,
  }) {
    if (!hasZ || !hasM) {
      final type = positionSeriesArrayType(rings);
      hasZ |= type.is3D;
      hasM |= type.isMeasured;
    }
    numGeometries++;
  }

  @override
  void multiPoint(
    Iterable<Position> points, {
    String? name,
    Box? bounds,
  }) {
    if (!hasZ || !hasM) {
      final type = positionArrayType(points);
      hasZ |= type.is3D;
      hasM |= type.isMeasured;
    }
    numGeometries++;
  }

  @override
  void multiLineString(
    Iterable<PositionSeries> lineStrings, {
    String? name,
    Box? bounds,
  }) {
    if (!hasZ || !hasM) {
      final type = positionSeriesArrayType(lineStrings);
      hasZ |= type.is3D;
      hasM |= type.isMeasured;
    }
    numGeometries++;
  }

  @override
  void multiPolygon(
    Iterable<Iterable<PositionSeries>> polygons, {
    String? name,
    Box? bounds,
  }) {
    if (!hasZ || !hasM) {
      final type = positionSeriesArrayArrayType(polygons);
      hasZ |= type.is3D;
      hasM |= type.isMeasured;
    }
    numGeometries++;
  }

  @override
  void geometryCollection(
    WriteGeometries geometries, {
    Coords? type,
    int? count,
    String? name,
    Box? bounds,
  }) {
    if (type != null && (!hasZ || !hasM)) {
      hasZ |= type.is3D;
      hasM |= type.isMeasured;
    }
    numGeometries++;
  }

  @override
  void emptyGeometry(Geom type, {String? name}) {
    numGeometries++;
  }
}
