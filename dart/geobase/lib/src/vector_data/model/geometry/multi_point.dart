// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/coordinates/projection.dart';
import '/src/utils/coord_arrays.dart';
import '/src/utils/coord_arrays_from_json.dart';
import '/src/vector/content.dart';
import '/src/vector/encoding.dart';
import '/src/vector/formats.dart';
import '/src/vector_data/array.dart';

import 'geometry.dart';
import 'geometry_builder.dart';
import 'point.dart';

/// A multi point geometry with an array of points (each with a position).
class MultiPoint extends SimpleGeometry {
  final List<PositionCoords> _points;
  final Coords? _type;

  /// A multi point geometry with an array of [points] (each with a position).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each point is represented by [PositionCoords] instances.
  const MultiPoint(List<PositionCoords> points, {BoxCoords? bounds})
      : this._(points, bounds: bounds);

  const MultiPoint._(this._points, {super.bounds, Coords? type}) : _type = type;

  /// Builds a multi point geometry from an array of [points] (each with a
  /// position).
  ///
  /// Use the required [type] to explicitely set the coordinate type.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
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
    Iterable<double>? bounds,
  }) =>
      MultiPoint._(
        buildListOfPositionsCoords(points, type: type),
        type: type,
        bounds: buildBoxCoordsOpt(bounds, type: type),
      );

  /// Parses a multi point geometry from [text] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [GeoJSON] is used
  /// as a default.
  factory MultiPoint.parse(
    String text, {
    TextReaderFormat<SimpleGeometryContent> format = GeoJSON.geometry,
  }) =>
      GeometryBuilder.parse<MultiPoint>(text, format: format);

  /// Parses a multi point geometry from [coordinates] conforming to
  /// [DefaultFormat].
  factory MultiPoint.parseCoords(String coordinates) {
    final array = requirePositionArrayDouble(json.decode('[$coordinates]'));
    final coordType = resolveCoordType(array, positionLevel: 1);
    return MultiPoint.build(
      array,
      type: coordType,
    );
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
  MultiPoint project(Projection projection) => MultiPoint._(
        _points
            .map((pos) => projection.project(pos, to: PositionCoords.create))
            .toList(growable: false),
        type: _type,
      );

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
