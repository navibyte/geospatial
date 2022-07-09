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
  final Coords? forcedTypeCoords;
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
        conf = conf ?? const WkbConf(),
        forcedTypeCoords = null;

  _WkbGeometryEncoder.buffer(
    ByteWriter buffer, {
    this.forcedTypeCoords,
    required this.conf,
  }) : _buffer = buffer;

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
    Object coordinates, {
    String? name,
    Coords? type,
  }) {
    // detect type for coordinates
    final coordType =
        forcedTypeCoords ?? _coordTypeFromPosition(coordinates, type);

    // write a point geometry
    _writeGeometryHeader(Geom.point, coordType);
    _writePoint(coordinates, coordType);
  }

  @override
  void lineString(
    Iterable<Object> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  }) {
    // detect type for coordinates
    final coordType =
        forcedTypeCoords ?? _coordTypeFromPositions1D(coordinates, type);

    // write a line string geometry
    _writeGeometryHeader(Geom.lineString, coordType);
    _writePointArray(coordinates, coordType);
  }

  @override
  void polygon(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  }) {
    // detect type for coordinates
    final coordType =
        forcedTypeCoords ?? _coordTypeFromPositions2D(coordinates, type);

    // write a polygon geometry
    _writeGeometryHeader(Geom.polygon, coordType);

    // write numRings
    _buffer.writeUint32(coordinates.length);

    // write all linear rings (of polygon)
    for (final linearRing in coordinates) {
      _writePointArray(linearRing, coordType);
    }
  }

  @override
  void multiPoint(
    Iterable<Object> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  }) {
    // detect type for coordinates
    final coordType =
        forcedTypeCoords ?? _coordTypeFromPositions1D(coordinates, type);

    // write a multi point geometry
    _writeGeometryHeader(Geom.multiPoint, coordType);

    // write numPoints
    _buffer.writeUint32(coordinates.length);

    // write all points
    for (final point in coordinates) {
      _writeGeometryHeader(Geom.point, coordType);
      _writePoint(point, coordType);
    }
  }

  @override
  void multiLineString(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  }) {
    // detect type for coordinates
    final coordType =
        forcedTypeCoords ?? _coordTypeFromPositions2D(coordinates, type);

    // write a multi line geometry
    _writeGeometryHeader(Geom.multiLineString, coordType);

    // write numLineStrings
    _buffer.writeUint32(coordinates.length);

    // write all line strings
    for (final lineString in coordinates) {
      _writeGeometryHeader(Geom.lineString, coordType);
      _writePointArray(lineString, coordType);
    }
  }

  @override
  void multiPolygon(
    Iterable<Iterable<Iterable<Object>>> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  }) {
    // detect type for coordinates
    final coordType =
        forcedTypeCoords ?? _coordTypeFromPositions3D(coordinates, type);

    // write a multi polygon geometry
    _writeGeometryHeader(Geom.multiPolygon, coordType);

    // write numPolygons
    _buffer.writeUint32(coordinates.length);

    // write all polygons
    for (final polygon in coordinates) {
      _writeGeometryHeader(Geom.polygon, coordType);

      // write numRings
      _buffer.writeUint32(polygon.length);

      // write all linear rings for a polygon
      for (final linearRing in polygon) {
        _writePointArray(linearRing, coordType);
      }
    }
  }

  @override
  void geometryCollection(
    WriteGeometries geometries, {
    int? count,
    String? name,
    Coords? type,
    Object? bbox,
  }) {
    final int numGeom;
    final Coords coordType;

    final suggestedType = forcedTypeCoords ?? type;
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

    // if configured, child geometries are expecgted to have smae coord type
    final Coords? force;
    if (conf.forceCoordTypeOfItemsOnGeometryCollection) {
      force = coordType;
    } else {
      force = null; // null => not forced
    }

    // recursively write geometries contained in a collection (same byte writer)
    final subWriter = _WkbGeometryEncoder.buffer(
      _buffer,
      forcedTypeCoords: force,
      conf: conf,
    );
    geometries.call(subWriter);
  }

  @override
  void emptyGeometry(Geom type, {String? name}) {
    // detect type for coordinates
    final coordType = forcedTypeCoords ?? Coords.xy;

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

  void _writePointArray(Iterable<Object> points, Coords coordType) {
    // write numPoints
    _buffer.writeUint32(points.length);

    // write points
    for (final point in points) {
      _writePoint(point, coordType);
    }
  }

  void _writePoint(Object point, Coords coordType) {
    num x = 0;
    num y = 0;
    num z = 0;
    num m = 0;
    if (point is Position) {
      x = point.x;
      y = point.y;
      z = point.z;
      m = point.m;
    } else if (point is Iterable<num>) {
      var ok = false;
      final iter = point.iterator;
      if (iter.moveNext()) {
        x = iter.current;
        if (iter.moveNext()) {
          y = iter.current;
          z = iter.moveNext() ? iter.current : 0;
          m = iter.moveNext() ? iter.current : 0;
          ok = true;
        }
      }
      if (!ok) {
        throw invalidCoordinates;
      }
    } else {
      throw invalidCoordinates;
    }

    switch (coordType) {
      // 2D point
      case Coords.xy:
        _buffer
          ..writeFloat64(x.toDouble())
          ..writeFloat64(y.toDouble());
        break;

      // Z point
      case Coords.xyz:
        _buffer
          ..writeFloat64(x.toDouble())
          ..writeFloat64(y.toDouble())
          ..writeFloat64(z.toDouble());
        break;

      // M point
      case Coords.xym:
        _buffer
          ..writeFloat64(x.toDouble())
          ..writeFloat64(y.toDouble())
          ..writeFloat64(m.toDouble());
        break;

      // ZM point
      case Coords.xyzm:
        _buffer
          ..writeFloat64(x.toDouble())
          ..writeFloat64(y.toDouble())
          ..writeFloat64(z.toDouble())
          ..writeFloat64(m.toDouble());
        break;
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
    Object coordinates, {
    String? name,
    Coords? type,
  }) {
    final coordType = _coordTypeFromPosition(coordinates, type);
    hasZ |= coordType.is3D;
    hasM |= coordType.isMeasured;
    numGeometries++;
  }

  @override
  void lineString(
    Iterable<Object> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  }) {
    final coordType = _coordTypeFromPositions1D(coordinates, type);
    hasZ |= coordType.is3D;
    hasM |= coordType.isMeasured;
    numGeometries++;
  }

  @override
  void polygon(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  }) {
    final coordType = _coordTypeFromPositions2D(coordinates, type);
    hasZ |= coordType.is3D;
    hasM |= coordType.isMeasured;
    numGeometries++;
  }

  @override
  void multiPoint(
    Iterable<Object> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  }) {
    final coordType = _coordTypeFromPositions1D(coordinates, type);
    hasZ |= coordType.is3D;
    hasM |= coordType.isMeasured;
    numGeometries++;
  }

  @override
  void multiLineString(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  }) {
    final coordType = _coordTypeFromPositions2D(coordinates, type);
    hasZ |= coordType.is3D;
    hasM |= coordType.isMeasured;
    numGeometries++;
  }

  @override
  void multiPolygon(
    Iterable<Iterable<Iterable<Object>>> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  }) {
    final coordType = _coordTypeFromPositions3D(coordinates, type);
    hasZ |= coordType.is3D;
    hasM |= coordType.isMeasured;
    numGeometries++;
  }

  @override
  void geometryCollection(
    WriteGeometries geometries, {
    int? count,
    String? name,
    Coords? type,
    Object? bbox,
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

// -----------------------------------------------------------------------------

Coords _coordTypeFromPosition(
  Object coordinates,
  Coords? coordType,
) {
  // detect type for coordinates
  if (coordType != null) {
    return coordType;
  } else {
    if (coordinates is Position) {
      return coordinates.typeCoords;
    } else if (coordinates is Iterable<num>) {
      if (coordinates.length >= 4) {
        return Coords.xyzm;
      } else if (coordinates.length >= 3) {
        return Coords.xyz;
      } else if (coordinates.length >= 2) {
        return Coords.xy;
      }
    }
    // no valid type (Position or Iterable<num>) for coordinates => throw
    throw invalidCoordinates;
  }
}

Coords _coordTypeFromPositions1D(
  Iterable<Object> coordinates,
  Coords? coordType,
) {
  // detect type for coordinates
  if (coordType != null) {
    return coordType;
  } else if (coordinates.isNotEmpty) {
    return _coordTypeFromPosition(coordinates.first, coordType);
  } else {
    return Coords.xy;
  }
}

Coords _coordTypeFromPositions2D(
  Iterable<Iterable<Object>> coordinates,
  Coords? coordType,
) {
  // detect type for coordinates
  if (coordType != null) {
    return coordType;
  } else if (coordinates.isNotEmpty && coordinates.first.isNotEmpty) {
    return _coordTypeFromPosition(coordinates.first.first, coordType);
  } else {
    return Coords.xy;
  }
}

Coords _coordTypeFromPositions3D(
  Iterable<Iterable<Iterable<Object>>> coordinates,
  Coords? coordType,
) {
  // detect type for coordinates
  if (coordType != null) {
    return coordType;
  } else if (coordinates.isNotEmpty &&
      coordinates.first.isNotEmpty &&
      coordinates.first.first.isNotEmpty) {
    return _coordTypeFromPosition(coordinates.first.first.first, coordType);
  } else {
    return Coords.xy;
  }
}
