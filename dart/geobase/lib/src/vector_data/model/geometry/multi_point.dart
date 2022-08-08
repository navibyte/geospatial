// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/vector_data/array.dart';

import 'geometry.dart';
import 'point.dart';

/// A multi point geometry with a series of points (each with a position).
class MultiPoint extends Geometry {
  final List<PositionCoords> _points;

  /// A multi point geometry with a series of [points] (each with a position).
  ///
  /// Each point is represented by [PositionCoords] instances.
  const MultiPoint(List<PositionCoords> points) : _points = points;

  /// A multi point geometry from a series of [points] (each with a position).
  ///
  /// Use the required [type] to explicitely set the coordinate type.
  ///
  /// Each point is represented by `Iterable<double>` instances. Supported
  /// coordinate value combinations for positions are: (x, y), (x, y, z),
  /// (x, y, m) and (x, y, z, m).
  ///
  /// An example to build a multi point geometry with 3 points:
  /// ```dart
  ///   MultiPoint.build(
  ///       [
  ///            [-1.1, -1.1],
  ///            [2.1, -2.5],
  ///            [3.5, -3.49],
  ///       ],
  ///       type: Coords.xy,
  ///   );
  /// ```
  factory MultiPoint.build(
    Iterable<Iterable<double>> points, {
    required Coords type,
  }) {
    if (points is List<PositionCoords>) {
      return MultiPoint(points);
    } else if (points is Iterable<PositionCoords>) {
      return MultiPoint(points.toList(growable: false));
    } else {
      return MultiPoint(
        points
            .map<PositionCoords>(
              (pos) => PositionCoords.view(
                pos is List<double> ? pos : pos.toList(growable: false),
                type: type,
              ),
            )
            .toList(growable: false),
      );
    }
  }

  @override
  Geom get type => Geom.multiPoint;

  /// The positions of all points.
  List<PositionCoords> get positions => _points;

  /// All points as a lazy iterable of [Point] geometries.
  Iterable<Point> get points => positions.map<Point>(Point.new);

  // todo: coordinates as raw data, toString

  @override
  bool operator ==(Object other) =>
      other is MultiPoint && positions == other.positions;

  @override
  int get hashCode => positions.hashCode;
}
