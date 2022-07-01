// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/coordinates/base.dart';
import '/src/utils/byte_writer.dart';
import '/src/utils/format_validation.dart';
import '/src/vector/content.dart';

/// Writer [geometries] to a sequence of bytes as specified by WKB format.
Uint8List writeWkb(WriteGeometries geometries) {
  final writer = _WkbGeometryWriter(ByteWriter.buffered());
  geometries.call(writer);
  return writer.toBytes();
}

class _WkbGeometryWriter with GeometryContent {
  final ByteWriter writer;
  final Coords? forcedTypeCoords;

  _WkbGeometryWriter(this.writer, {this.forcedTypeCoords});

  /// Returns geometry data written as a sequence of bytes in a Uint8List.
  Uint8List toBytes() => writer.toBytes();

  @override
  void point(
    Object coordinates, {
    String? name,
    Coords? coordType,
  }) {
    // detect type for coordinates
    final typeCoords =
        forcedTypeCoords ?? _typeCoordsWithPosition(coordinates, coordType);

    // write a point geometry
    _writeGeometryHeader(Geom.point, typeCoords);
    _writePoint(coordinates, typeCoords);
  }

  @override
  void lineString(
    Iterable<Object> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    // detect type for coordinates
    final typeCoords =
        forcedTypeCoords ?? _typeCoordsWithPositions1D(coordinates, coordType);

    // write a line string geometry
    _writeGeometryHeader(Geom.lineString, typeCoords);
    _writePointArray(coordinates, typeCoords);
  }

  @override
  void polygon(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    // detect type for coordinates
    final typeCoords =
        forcedTypeCoords ?? _typeCoordsWithPositions2D(coordinates, coordType);

    // write a polygon geometry
    _writeGeometryHeader(Geom.polygon, typeCoords);

    // write numRings
    writer.writeUint32(coordinates.length);

    // write all linear rings (of polygon)
    for (final linearRing in coordinates) {
      _writePointArray(linearRing, typeCoords);
    }
  }

  @override
  void multiPoint(
    Iterable<Object> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    // detect type for coordinates
    final typeCoords =
        forcedTypeCoords ?? _typeCoordsWithPositions1D(coordinates, coordType);

    // write a multi point geometry
    _writeGeometryHeader(Geom.multiPoint, typeCoords);

    // write numPoints
    writer.writeUint32(coordinates.length);

    // write all points
    for (final point in coordinates) {
      _writeGeometryHeader(Geom.point, typeCoords);
      _writePoint(point, typeCoords);
    }
  }

  @override
  void multiLineString(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    // detect type for coordinates
    final typeCoords =
        forcedTypeCoords ?? _typeCoordsWithPositions2D(coordinates, coordType);

    // write a multi line geometry
    _writeGeometryHeader(Geom.multiLineString, typeCoords);

    // write numLineStrings
    writer.writeUint32(coordinates.length);

    // write all line strings
    for (final lineString in coordinates) {
      _writeGeometryHeader(Geom.lineString, typeCoords);
      _writePointArray(lineString, typeCoords);
    }
  }

  @override
  void multiPolygon(
    Iterable<Iterable<Iterable<Object>>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    // detect type for coordinates
    final typeCoords =
        forcedTypeCoords ?? _typeCoordsWithPositions3D(coordinates, coordType);

    // write a multi polygon geometry
    _writeGeometryHeader(Geom.multiPolygon, typeCoords);

    // write numPolygons
    writer.writeUint32(coordinates.length);

    // write all polygons
    for (final polygon in coordinates) {
      _writeGeometryHeader(Geom.polygon, typeCoords);

      // write numRings
      writer.writeUint32(polygon.length);

      // write all linear rings for a polygon
      for (final linearRing in polygon) {
        _writePointArray(linearRing, typeCoords);
      }
    }
  }

  @override
  void geometryCollection({
    required WriteGeometries geometries,
    int? count,
    String? name,
    Object? bbox,
  }) {
    // first calculate number of geometries and analyze coordinate types
    final collector = _GeometryCollector();
    geometries.call(collector);
    final typeCoords = forcedTypeCoords ??
        Coords.select(
          is3D: collector.hasZ,
          isMeasured: collector.hasM,
        );

    // write header for geometry collection
    _writeGeometryHeader(Geom.geometryCollection, typeCoords);
    writer.writeUint32(collector.numGeometries);

    // recursively write geometries contained in a collection (same byte writer)
    final subWriter = _WkbGeometryWriter(writer, forcedTypeCoords: typeCoords);
    geometries.call(subWriter);
  }

  @override
  void emptyGeometry(Geom type, {String? name}) {
    // detect type for coordinates
    final typeCoords = forcedTypeCoords ?? Coords.xy;

    switch (type) {
      case Geom.point:
        // this is a spcial case, see => https://trac.osgeo.org/geos/ticket/1005
        _writeGeometryHeader(type, typeCoords);
        writer
          ..writeFloat64(double.nan)
          ..writeFloat64(double.nan);
        if (typeCoords.is3D) {
          writer.writeFloat64(double.nan);
        }
        if (typeCoords.isMeasured) {
          writer.writeFloat64(double.nan);
        }
        break;
      case Geom.lineString:
      case Geom.polygon:
      case Geom.multiPoint:
      case Geom.multiLineString:
      case Geom.multiPolygon:
      case Geom.geometryCollection:
        // write geometry with 0 elements (points, rings, geometries, etc.)
        _writeGeometryHeader(type, typeCoords);
        writer.writeUint32(0);
        break;
    }
  }

  void _writeGeometryHeader(Geom typeGeom, Coords typeCoords) {
    // write byte order
    switch (writer.endian) {
      // wkbXDR (= 0 // Big Endian) value of the WKBByteOrder enum
      case Endian.big:
        writer.writeInt8(0);
        break;

      // wkbNDR (= 1 // Little Endian) value of the WKBByteOrder enum
      case Endian.little:
        writer.writeInt8(1);
        break;
    }

    // enum type (WKBGeometryType) as integer is calculated from geometry and
    // coordinate types as specified by this library
    final type = typeGeom.idWkb(typeCoords);

    // write geometry type (as specified by the WKBGeometryType enum)
    writer.writeUint32(type);
  }

  void _writePointArray(Iterable<Object> points, Coords typeCoords) {
    // write numPoints
    writer.writeUint32(points.length);

    // write points
    for (final point in points) {
      _writePoint(point, typeCoords);
    }
  }

  void _writePoint(Object point, Coords typeCoords) {
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

    switch (typeCoords) {
      // 2D point
      case Coords.xy:
        writer
          ..writeFloat64(x.toDouble())
          ..writeFloat64(y.toDouble());
        break;

      // Z point
      case Coords.xyz:
        writer
          ..writeFloat64(x.toDouble())
          ..writeFloat64(y.toDouble())
          ..writeFloat64(z.toDouble());
        break;

      // M point
      case Coords.xym:
        writer
          ..writeFloat64(x.toDouble())
          ..writeFloat64(y.toDouble())
          ..writeFloat64(m.toDouble());
        break;

      // ZM point
      case Coords.xyzm:
        writer
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
    Coords? coordType,
  }) {
    final typeCoords = _typeCoordsWithPosition(coordinates, coordType);
    hasZ |= typeCoords.is3D;
    hasM |= typeCoords.isMeasured;
    numGeometries++;
  }

  @override
  void lineString(
    Iterable<Object> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    final typeCoords = _typeCoordsWithPositions1D(coordinates, coordType);
    hasZ |= typeCoords.is3D;
    hasM |= typeCoords.isMeasured;
    numGeometries++;
  }

  @override
  void polygon(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    final typeCoords = _typeCoordsWithPositions2D(coordinates, coordType);
    hasZ |= typeCoords.is3D;
    hasM |= typeCoords.isMeasured;
    numGeometries++;
  }

  @override
  void multiPoint(
    Iterable<Object> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    final typeCoords = _typeCoordsWithPositions1D(coordinates, coordType);
    hasZ |= typeCoords.is3D;
    hasM |= typeCoords.isMeasured;
    numGeometries++;
  }

  @override
  void multiLineString(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    final typeCoords = _typeCoordsWithPositions2D(coordinates, coordType);
    hasZ |= typeCoords.is3D;
    hasM |= typeCoords.isMeasured;
    numGeometries++;
  }

  @override
  void multiPolygon(
    Iterable<Iterable<Iterable<Object>>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    final typeCoords = _typeCoordsWithPositions3D(coordinates, coordType);
    hasZ |= typeCoords.is3D;
    hasM |= typeCoords.isMeasured;
    numGeometries++;
  }

  @override
  void geometryCollection({
    required WriteGeometries geometries,
    int? count,
    String? name,
    Object? bbox,
  }) {
    numGeometries++;
  }

  @override
  void emptyGeometry(Geom type, {String? name}) {
    numGeometries++;
  }
}

// -----------------------------------------------------------------------------

Coords _typeCoordsWithPosition(
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

Coords _typeCoordsWithPositions1D(
  Iterable<Object> coordinates,
  Coords? coordType,
) {
  // detect type for coordinates
  if (coordType != null) {
    return coordType;
  } else if (coordinates.isNotEmpty) {
    return _typeCoordsWithPosition(coordinates.first, coordType);
  } else {
    return Coords.xy;
  }
}

Coords _typeCoordsWithPositions2D(
  Iterable<Iterable<Object>> coordinates,
  Coords? coordType,
) {
  // detect type for coordinates
  if (coordType != null) {
    return coordType;
  } else if (coordinates.isNotEmpty && coordinates.first.isNotEmpty) {
    return _typeCoordsWithPosition(coordinates.first.first, coordType);
  } else {
    return Coords.xy;
  }
}

Coords _typeCoordsWithPositions3D(
  Iterable<Iterable<Iterable<Object>>> coordinates,
  Coords? coordType,
) {
  // detect type for coordinates
  if (coordType != null) {
    return coordType;
  } else if (coordinates.isNotEmpty &&
      coordinates.first.isNotEmpty &&
      coordinates.first.first.isNotEmpty) {
    return _typeCoordsWithPosition(coordinates.first.first.first, coordType);
  } else {
    return Coords.xy;
  }
}
