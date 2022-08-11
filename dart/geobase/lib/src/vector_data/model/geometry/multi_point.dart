// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/vector/content.dart';
import '/src/vector_data/array.dart';

import 'geometry.dart';
import 'point.dart';

/// A multi point geometry with an array of points (each with a position).
class MultiPoint extends SimpleGeometry {
  final List<PositionCoords> _points;
  final Coords? _type;

  /// A multi point geometry with an array of [points] (each with a position).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a multi
  /// point.
  ///
  /// Each point is represented by [PositionCoords] instances.
  const MultiPoint(List<PositionCoords> points, {BoxCoords? bounds})
      : this._(points, bounds: bounds);

  const MultiPoint._(this._points, {super.bounds, Coords? type}) : _type = type;

  /// A multi point geometry from an array of [points] (each with a position).
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
      return MultiPoint._(points, type: type);
    } else if (points is Iterable<PositionCoords>) {
      return MultiPoint._(points.toList(growable: false), type: type);
    } else {
      return MultiPoint._(
        points
            .map<PositionCoords>(
              (pos) => PositionCoords.view(
                pos is List<double> ? pos : pos.toList(growable: false),
                type: type,
              ),
            )
            .toList(growable: false),
        type: type,
      );
    }
  }

  @override
  Geom get geomType => Geom.multiPoint;

  @override
  Coords get coordType =>
      _type ?? (_points.isNotEmpty ? _points.first.type : Coords.xy);

  /// The positions of all points.
  List<PositionCoords> get positions => _points;

  /// All points as a lazy iterable of [Point] geometries.
  Iterable<Point> get points => positions.map<Point>(Point.new);

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      writer.multiPoint(_points, type: coordType, name: name, bounds: bounds);

  // todo: coordinates as raw data

  @override
  bool operator ==(Object other) =>
      other is MultiPoint &&
      bounds == other.bounds &&
      positions == other.positions;

  @override
  int get hashCode => Object.hash(bounds, positions);
}
