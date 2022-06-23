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
  void geometryWithPosition({
    required Geom type,
    required Position coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    // detect type for coordinates
    final typeCoords =
        forcedTypeCoords ?? _typeCoordsWithPosition(coordinates, coordType);

    // expected geometry types: point
    if (type == Geom.point) {
      _writeGeometryHeader(type, typeCoords);
      _writePoint(coordinates, typeCoords);
    }
  }

  @override
  void geometryWithPositions1D({
    required Geom type,
    required Iterable<Position> coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    // detect type for coordinates
    final typeCoords =
        forcedTypeCoords ?? _typeCoordsWithPositions1D(coordinates, coordType);

    // expected geometry types: lineString, multiPoint
    if (type == Geom.lineString) {
      _writeGeometryHeader(type, typeCoords);
      _writePointArray(coordinates, typeCoords);
    } else if (type == Geom.multiPoint) {
      _writeGeometryHeader(type, typeCoords);

      // write numPoints
      writer.writeUint32(coordinates.length);

      // write all points
      for (final point in coordinates) {
        _writeGeometryHeader(Geom.point, typeCoords);
        _writePoint(point, typeCoords);
      }
    }
  }

  @override
  void geometryWithPositions2D({
    required Geom type,
    required Iterable<Iterable<Position>> coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    // detect type for coordinates
    final typeCoords =
        forcedTypeCoords ?? _typeCoordsWithPositions2D(coordinates, coordType);

    // expected geometry types: polygon, multiLineString
    if (type == Geom.polygon) {
      _writeGeometryHeader(type, typeCoords);

      // write numRings
      writer.writeUint32(coordinates.length);

      // write all linear rings (of polygon)
      for (final linearRing in coordinates) {
        _writePointArray(linearRing, typeCoords);
      }
    } else if (type == Geom.multiLineString) {
      _writeGeometryHeader(type, typeCoords);

      // write numLineStrings
      writer.writeUint32(coordinates.length);

      // write all line strings
      for (final lineString in coordinates) {
        _writeGeometryHeader(Geom.lineString, typeCoords);
        _writePointArray(lineString, typeCoords);
      }
    }
  }

  @override
  void geometryWithPositions3D({
    required Geom type,
    required Iterable<Iterable<Iterable<Position>>> coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    // detect type for coordinates
    final typeCoords =
        forcedTypeCoords ?? _typeCoordsWithPositions3D(coordinates, coordType);

    // expected geometry types: multiPolygon
    if (type == Geom.multiPolygon) {
      _writeGeometryHeader(type, typeCoords);

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
  }

  @override
  void geometryCollection({
    required WriteGeometries geometries,
    int? count,
    String? name,
    Box? bbox,
  }) {
    // first calculate number of geometries and analyze coordinate types
    final collector = _GeometryCollector();
    geometries.call(collector);
    final typeCoords = forcedTypeCoords ??
        Coords.select(
          isGeographic: collector.numGeometries > 0 && !collector.hasProjected,
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

  void _writePointArray(Iterable<Position> points, Coords typeCoords) {
    // write numPoints
    writer.writeUint32(points.length);

    // write points
    for (final point in points) {
      _writePoint(point, typeCoords);
    }
  }

  void _writePoint(Position point, Coords typeCoords) {
    switch (typeCoords) {
      // 2D point
      case Coords.xy:
      case Coords.lonLat:
        writer
          ..writeFloat64(point.x.toDouble())
          ..writeFloat64(point.y.toDouble());
        break;

      // Z point
      case Coords.xyz:
      case Coords.lonLatElev:
        writer
          ..writeFloat64(point.x.toDouble())
          ..writeFloat64(point.y.toDouble())
          ..writeFloat64(point.z.toDouble());
        break;

      // M point
      case Coords.xym:
      case Coords.lonLatM:
        writer
          ..writeFloat64(point.x.toDouble())
          ..writeFloat64(point.y.toDouble())
          ..writeFloat64(point.m.toDouble());
        break;

      // ZM point
      case Coords.xyzm:
      case Coords.lonLatElevM:
        writer
          ..writeFloat64(point.x.toDouble())
          ..writeFloat64(point.y.toDouble())
          ..writeFloat64(point.z.toDouble())
          ..writeFloat64(point.m.toDouble());
        break;
    }
  }
}

// -----------------------------------------------------------------------------

class _GeometryCollector with GeometryContent {
  bool hasZ = false;
  bool hasM = false;
  bool hasProjected = false;
  int numGeometries = 0;

  @override
  void geometryWithPosition({
    required Geom type,
    required Position coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    final typeCoords = _typeCoordsWithPosition(coordinates, coordType);
    hasZ |= typeCoords.is3D;
    hasM |= typeCoords.isMeasured;
    hasProjected |= !typeCoords.isGeographic;
    numGeometries++;
  }

  @override
  void geometryWithPositions1D({
    required Geom type,
    required Iterable<Position> coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    final typeCoords = _typeCoordsWithPositions1D(coordinates, coordType);
    hasZ |= typeCoords.is3D;
    hasM |= typeCoords.isMeasured;
    hasProjected |= !typeCoords.isGeographic;
    numGeometries++;
  }

  @override
  void geometryWithPositions2D({
    required Geom type,
    required Iterable<Iterable<Position>> coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    final typeCoords = _typeCoordsWithPositions2D(coordinates, coordType);
    hasZ |= typeCoords.is3D;
    hasM |= typeCoords.isMeasured;
    hasProjected |= !typeCoords.isGeographic;
    numGeometries++;
  }

  @override
  void geometryWithPositions3D({
    required Geom type,
    required Iterable<Iterable<Iterable<Position>>> coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    final typeCoords = _typeCoordsWithPositions3D(coordinates, coordType);
    hasZ |= typeCoords.is3D;
    hasM |= typeCoords.isMeasured;
    hasProjected |= !typeCoords.isGeographic;
    numGeometries++;
  }

  @override
  void geometryCollection({
    required WriteGeometries geometries,
    int? count,
    String? name,
    Box? bbox,
  }) {
    hasProjected |= true;
    numGeometries++;
  }

  @override
  void emptyGeometry(Geom type, {String? name}) {
    hasProjected |= true;
    numGeometries++;
  }
}

// -----------------------------------------------------------------------------

Coords _typeCoordsWithPosition(
  Position coordinates,
  Coords? coordType,
) {
  // detect type for coordinates
  return coordType ?? coordinates.typeCoords;
}

Coords _typeCoordsWithPositions1D(
  Iterable<Position> coordinates,
  Coords? coordType,
) {
  // detect type for coordinates
  if (coordType != null) {
    return coordType;
  } else if (coordinates.isNotEmpty) {
    return coordinates.first.typeCoords;
  } else {
    return Coords.xy;
  }
}

Coords _typeCoordsWithPositions2D(
  Iterable<Iterable<Position>> coordinates,
  Coords? coordType,
) {
  // detect type for coordinates
  if (coordType != null) {
    return coordType;
  } else if (coordinates.isNotEmpty && coordinates.first.isNotEmpty) {
    return coordinates.first.first.typeCoords;
  } else {
    return Coords.xy;
  }
}

Coords _typeCoordsWithPositions3D(
  Iterable<Iterable<Iterable<Position>>> coordinates,
  Coords? coordType,
) {
  // detect type for coordinates
  if (coordType != null) {
    return coordType;
  } else if (coordinates.isNotEmpty &&
      coordinates.first.isNotEmpty &&
      coordinates.first.first.isNotEmpty) {
    return coordinates.first.first.first.typeCoords;
  } else {
    return Coords.xy;
  }
}
