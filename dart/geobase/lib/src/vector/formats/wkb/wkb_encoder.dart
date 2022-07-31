// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'wkb_format.dart';

class _WkbGeometryEncoder
    with GeometryContent
    implements ContentEncoder<GeometryContent> {
  final ByteWriter _buffer;
  final WkbConf conf;

  _WkbGeometryEncoder({
    Endian endian = Endian.big,
    int bufferSize = 128,
    WkbConf? conf,
  })  : _buffer = ByteWriter.buffered(
          endian: endian,
          bufferSize: bufferSize,

          // Note this is needed because of emptyGeometry special case of
          // POINT(NaN NaN) and how it is encoded in WKB (same way with OSGEO)
          nanEncodedAsNegative: true,
        ),
        conf = conf ?? const WkbConf();

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
    Iterable<double> position, {
    Coords? type,
    String? name,
  }) {
    // type for coordinates
    final coordType = type ?? Coords.fromDimension(position.length);

    // write a point geometry
    _writeGeometryHeader(Geom.point, coordType);
    _writePosition(position, coordType);
  }

  @override
  void lineString(
    Iterable<double> chain, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    // write a line string geometry
    _writeGeometryHeader(Geom.lineString, type);
    _writeFlatPositionArray(chain, type);
  }

  @override
  void polygon(
    Iterable<Iterable<double>> rings, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    // write a polygon geometry
    _writeGeometryHeader(Geom.polygon, type);

    // write numRings
    _buffer.writeUint32(rings.length);

    // write all linear rings (of polygon)
    for (final linearRing in rings) {
      _writeFlatPositionArray(linearRing, type);
    }
  }

  @override
  void multiPoint(
    Iterable<Iterable<double>> positions, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    // write a multi point geometry
    _writeGeometryHeader(Geom.multiPoint, type);

    // write numPoints
    _buffer.writeUint32(positions.length);

    // write all points
    for (final point in positions) {
      _writeGeometryHeader(Geom.point, type);
      _writePosition(point, type);
    }
  }

  @override
  void multiLineString(
    Iterable<Iterable<double>> chains, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    // write a multi line geometry
    _writeGeometryHeader(Geom.multiLineString, type);

    // write numLineStrings
    _buffer.writeUint32(chains.length);

    // write chains of all line strings
    for (final chain in chains) {
      _writeGeometryHeader(Geom.lineString, type);
      _writeFlatPositionArray(chain, type);
    }
  }

  @override
  void multiPolygon(
    Iterable<Iterable<Iterable<double>>> ringsArray, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    // write a multi polygon geometry
    _writeGeometryHeader(Geom.multiPolygon, type);

    // write numPolygons
    _buffer.writeUint32(ringsArray.length);

    // write all rings of polygons
    for (final rings in ringsArray) {
      _writeGeometryHeader(Geom.polygon, type);

      // write numRings
      _buffer.writeUint32(rings.length);

      // write all linear rings for a polygon
      for (final linearRing in rings) {
        _writeFlatPositionArray(linearRing, type);
      }
    }
  }

  @override
  void geometryCollection(
    WriteGeometries geometries, {
    Coords? type,
    int? count,
    String? name,
    Box? bbox,
  }) {
    final int numGeom;
    final Coords coordType;

    final suggestedType = type;
    if (count == null || suggestedType == null) {
      // calculate number of geometries and analyze coordinate types
      final collector = _GeometryCollector();
      geometries.call(collector);
      numGeom = count ?? collector.numGeometries;
      coordType = suggestedType ??
          Coords.select(
            is3D: collector.hasZ,
            isMeasured: collector.hasM,
          );
    } else {
      numGeom = count;
      coordType = suggestedType;
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

  void _writePosition(Iterable<double> point, Coords type) {
    // at least write x and y
    final iter = point.iterator;
    _buffer
      ..writeFloat64(iter.moveNext() ? iter.current : throw invalidCoordinates)
      ..writeFloat64(iter.moveNext() ? iter.current : throw invalidCoordinates);

    // optionally write z and m too
    if (type.is3D) {
      _buffer.writeFloat64(iter.moveNext() ? iter.current : 0.0);
    }
    if (type.isMeasured) {
      _buffer.writeFloat64(iter.moveNext() ? iter.current : 0.0);
    }
  }

  void _writeFlatPositionArray(Iterable<double> coordinates, Coords type) {
    // calculate the number of points
    final numValues = coordinates.length;
    final numPoints = numValues ~/ type.coordinateDimension;

    // check the size of coordinates array
    if (numValues != numPoints * type.coordinateDimension) {
      throw invalidCoordinates;
    }

    // write numPoints
    _buffer.writeUint32(numPoints);

    // todo: write the whole buffer at once

    // write all coordinate values for each point as a flat structure
    for (final value in coordinates) {
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
    Iterable<double> position, {
    Coords? type,
    String? name,
  }) {
    final coordType = type ?? Coords.fromDimension(position.length);
    hasZ |= coordType.is3D;
    hasM |= coordType.isMeasured;
    numGeometries++;
  }

  @override
  void lineString(
    Iterable<double> coordinates, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    hasZ |= type.is3D;
    hasM |= type.isMeasured;
    numGeometries++;
  }

  @override
  void polygon(
    Iterable<Iterable<double>> coordinates, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    hasZ |= type.is3D;
    hasM |= type.isMeasured;
    numGeometries++;
  }

  @override
  void multiPoint(
    Iterable<Iterable<double>> positions, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    hasZ |= type.is3D;
    hasM |= type.isMeasured;
    numGeometries++;
  }

  @override
  void multiLineString(
    Iterable<Iterable<double>> coordinates, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    hasZ |= type.is3D;
    hasM |= type.isMeasured;
    numGeometries++;
  }

  @override
  void multiPolygon(
    Iterable<Iterable<Iterable<double>>> positions, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    hasZ |= type.is3D;
    hasM |= type.isMeasured;
    numGeometries++;
  }

  @override
  void geometryCollection(
    WriteGeometries geometries, {
    Coords? type,
    int? count,
    String? name,
    Box? bbox,
  }) {
    if (type != null) {
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
