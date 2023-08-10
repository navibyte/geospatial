// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import '/src/codes/coords.dart';
import '/src/codes/geo_representation.dart';
import '/src/codes/geom.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/crs/coord_ref_sys.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/bounds_builder.dart';
import '/src/utils/coord_arrays.dart';
import '/src/utils/coord_arrays_from_json.dart';
import '/src/utils/tolerance.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/default_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';
import '/src/vector_data/array/coordinates.dart';
import '/src/vector_data/array/coordinates_extensions.dart';

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
  /// Each point is represented by a [PositionCoords] instance.
  const MultiPoint(List<PositionCoords> points, {BoxCoords? bounds})
      : this._(points, bounds: bounds);

  const MultiPoint._(this._points, {super.bounds, Coords? type}) : _type = type;

  /// A multi point geometry from an iterable of `Position` objects in [points].
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each point is represented by a [Position] instance.
  factory MultiPoint.from(Iterable<Position> points, {Box? bounds}) =>
      MultiPoint._(
        points.map((p) => p.coords()).toList(growable: false),
        bounds: bounds?.coords(),
      );

  /// Builds a multi point geometry from an array of [points] (each with a
  /// position).
  ///
  /// Use [type] to specify the type of coordinates, by default `Coords.xy` is
  /// expected.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each point is represented by an `Iterable<double>` instance. Supported
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
    Coords type = Coords.xy,
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
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory MultiPoint.parse(
    String text, {
    TextReaderFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.parse<MultiPoint>(
        text,
        format: format,
        crs: crs,
        options: options,
      );

  /// Parses a multi point geometry from [coordinates] conforming to
  /// [DefaultFormat].
  ///
  /// Use [crs] and [crsLogic] to give hints (like axis order, and whether x
  /// and y must be swapped when read in) about coordinate reference system in
  /// text input.
  factory MultiPoint.parseCoords(
    String coordinates, {
    CoordRefSys? crs,
    GeoRepresentation? crsLogic,
  }) {
    final array = requirePositionArrayDouble(
      json.decode('[$coordinates]'),
      swapXY: crs?.swapXY(logic: crsLogic) ?? false,
    );
    if (array.isEmpty) {
      return MultiPoint.build(const []);
    }
    final coordType = resolveCoordType(array, positionLevel: 1);
    return MultiPoint.build(
      array,
      type: coordType,
    );
  }

  /// Decodes a multi point geometry from [bytes] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory MultiPoint.decode(
    Uint8List bytes, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decode<MultiPoint>(
        bytes,
        format: format,
        options: options,
      );

  @override
  Geom get geomType => Geom.multiPoint;

  @override
  Coords get coordType =>
      _type ?? (_points.isNotEmpty ? _points.first.type : Coords.xy);

  @override
  bool get isEmpty => _points.isEmpty;

  /// The positions of all points.
  List<PositionCoords> get positions => _points;

  /// All points as a lazy iterable of [Point] geometries.
  Iterable<Point> get points => positions.map<Point>(Point.new);

  @override
  BoxCoords? calculateBounds() => BoundsBuilder.calculateBounds(
        positions: _points,
        type: coordType,
      );

  @override
  MultiPoint bounded({bool recalculate = false}) {
    if (isEmpty) return this;

    if (recalculate || bounds == null) {
      // return a new MultiPoint (positions kept intact) with populated bounds
      return MultiPoint._(
        _points,
        type: _type,
        bounds: BoundsBuilder.calculateBounds(
          positions: _points,
          type: coordType,
        ),
      );
    } else {
      // bounds was already populated and not asked to recalculate
      return this;
    }
  }

  @override
  MultiPoint project(Projection projection) {
    final projected = _points
        .map((pos) => projection.project(pos, to: PositionCoords.create))
        .toList(growable: false);

    return MultiPoint._(
      projected,
      type: _type,

      // bounds calculated from projected geometry if there was bounds before
      bounds: bounds != null
          ? BoundsBuilder.calculateBounds(
              positions: projected,
              type: coordType,
            )
          : null,
    );
  }

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) => isEmpty
      ? writer.emptyGeometry(Geom.multiPoint, name: name)
      : writer.multiPoint(_points, type: coordType, name: name, bounds: bounds);

  // NOTE: coordinates as raw data

  @override
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    if (other is! MultiPoint) return false;
    if (isEmpty || other.isEmpty) return false;
    if (bounds != null &&
        other.bounds != null &&
        !bounds!.equals2D(
          other.bounds!,
          toleranceHoriz: toleranceHoriz,
        )) {
      // both geometries has bound boxes and boxes do not equal in 2D
      return false;
    }
    // ensure both multi points has same amount of positions
    final p1 = positions;
    final p2 = other.positions;
    if (p1.length != p2.length) return false;
    // loop all positions and test 2D coordinates
    for (var i = 0; i < p1.length; i++) {
      if (!p1[i].equals2D(
        p2[i],
        toleranceHoriz: toleranceHoriz,
      )) {
        return false;
      }
    }
    return true;
  }

  @override
  bool equals3D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    assertTolerance(toleranceVert);
    if (other is! MultiPoint) return false;
    if (isEmpty || other.isEmpty) return false;
    if (!coordType.is3D || !other.coordType.is3D) return false;
    if (bounds != null &&
        other.bounds != null &&
        !bounds!.equals3D(
          other.bounds!,
          toleranceHoriz: toleranceHoriz,
          toleranceVert: toleranceVert,
        )) {
      // both geometries has bound boxes and boxes do not equal in 3D
      return false;
    }
    // ensure both multi points has same amount of positions
    final p1 = positions;
    final p2 = other.positions;
    if (p1.length != p2.length) return false;
    // loop all positions and test 3D coordinates
    for (var i = 0; i < p1.length; i++) {
      if (!p1[i].equals3D(
        p2[i],
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      )) {
        return false;
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is MultiPoint &&
      bounds == other.bounds &&
      positions == other.positions;

  @override
  int get hashCode => Object.hash(bounds, positions);
}
