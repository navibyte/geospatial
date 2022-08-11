// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/vector/content.dart';
import '/src/vector/encoding.dart';
import '/src/vector/formats.dart';
import '/src/vector_data/array.dart';

import 'geometry.dart';

/// A point geometry with a position.
class Point implements SimpleGeometry {
  final PositionCoords _position;

  /// A point geometry with [position].
  const Point(PositionCoords position) : _position = position;

  /// A point geometry from a [position].
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates. If
  /// not provided and an iterable has 3 items, then xyz coordinates are
  /// assumed.
  ///
  /// Supported coordinate value combinations for `Iterable<double>` are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
  ///
  /// An example to build a point geometry with 2D coordinates:
  /// ```dart
  ///    // using a coordinate value list (x, y)
  ///    Point.build([10, 20]);
  /// ```
  ///
  /// An example to build a point geometry with 3D coordinates:
  /// ```dart
  ///    // using a coordinate value list (x, y, z)
  ///    Point.build([10, 20, 30]);
  /// ```
  ///
  /// An example to build a point geometry with 2D coordinates with measurement:
  /// ```dart
  ///    // using a coordinate value list (x, y, m), need to specify type
  ///    Point.build([10, 20, 40], type: Coords.xym);
  /// ```
  ///
  /// An example to build a point geometry with 3D coordinates with measurement:
  /// ```dart
  ///    // using a coordinate value list (x, y, z, m)
  ///    Point.build([10, 20, 30, 40]);
  /// ```
  factory Point.build(
    Iterable<double> position, {
    Coords? type,
  }) {
    if (position is PositionCoords) {
      return Point(position);
    } else {
      return Point(
        PositionCoords.view(
          position is List<double>
              ? position
              : position.toList(growable: false),
          type: type ?? Coords.fromDimension(position.length),
        ),
      );
    }
  }

  @override
  Geom get geomType => Geom.point;

  @override
  Coords get coordType => _position.type;

  /// The position in this point geometry.
  PositionCoords get position => _position;

  /// The bounding box for this point, mix and max with the same point position.
  @override
  BoxCoords get bounds => BoxCoords.create(
        minX: position.x,
        minY: position.y,
        minZ: position.optZ,
        minM: position.optM,
        maxX: position.x,
        maxY: position.y,
        maxZ: position.optZ,
        maxM: position.optM,
      );

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      writer.point(_position, type: coordType, name: name);

  // todo: coordinates as raw data

  @override
  String toStringAs({
    TextWriterFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    int? decimals,
  }) {
    final encoder = format.encoder(decimals: decimals);
    writeTo(encoder.writer);
    return encoder.toText();
  }

  @override
  String toString() => toStringAs();

  @override
  bool operator ==(Object other) =>
      other is Point && position == other.position;

  @override
  int get hashCode => position.hashCode;
}
