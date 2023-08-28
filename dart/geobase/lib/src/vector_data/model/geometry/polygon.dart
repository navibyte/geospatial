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
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/reference/coord_ref_sys.dart';
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

/// A polygon geometry with one exterior and 0 to N interior rings.
///
/// An empty polygon has no rings.
class Polygon extends SimpleGeometry {
  final List<PositionArray> _rings;

  /// A polygon geometry with one exterior and 0 to N interior [rings].
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each ring in the polygon is represented by a `PositionArray` instance.
  ///
  /// An empty polygon has no rings.
  ///
  /// For "normal" polygons the [rings] list must be non-empty. The first
  /// element is the exterior ring, and any other rings are interior rings (or
  /// holes). All rings must be closed linear rings. As specified by GeoJSON,
  /// they should "follow the right-hand rule with respect to the area it
  /// bounds, i.e., exterior rings are counterclockwise, and holes are
  /// clockwise".
  const Polygon(List<PositionArray> rings, {super.bounds}) : _rings = rings;

  /// A polygon geometry with one exterior and 0 to N interior [rings].
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each ring in the polygon is represented by an `Iterable<Position>`
  /// instance.
  ///
  /// An empty polygon has no rings.
  ///
  /// For "normal" polygons the [rings] list must be non-empty. The first
  /// element is the exterior ring, and any other rings are interior rings (or
  /// holes). All rings must be closed linear rings. As specified by GeoJSON,
  /// they should "follow the right-hand rule with respect to the area it
  /// bounds, i.e., exterior rings are counterclockwise, and holes are
  /// clockwise".
  factory Polygon.from(
    Iterable<Iterable<Position>> rings, {
    Box? bounds,
  }) =>
      Polygon(
        rings.map((ring) => ring.array()).toList(growable: false),
        bounds: bounds,
      );

  /// Builds a polygon geometry from one exterior and 0 to N interior [rings].
  ///
  /// Use [type] to specify the type of coordinates, by default `Coords.xy` is
  /// expected.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each ring in the polygon is represented by an `Iterable<double>` array.
  /// Such arrays contain coordinate values as a flat structure. For example for
  /// `Coords.xyz` the first three coordinate values are x, y and z of the first
  /// position, the next three coordinate values are x, y and z of the second
  /// position, and so on.
  ///
  /// An empty polygon has no rings.
  ///
  /// For "normal" polygons the [rings] list must be non-empty. The first
  /// element is the exterior ring, and any other rings are interior rings (or
  /// holes). All rings must be closed linear rings. As specified by GeoJSON,
  /// they should "follow the right-hand rule with respect to the area it
  /// bounds, i.e., exterior rings are counterclockwise, and holes are
  /// clockwise".
  ///
  /// An example to build a polygon geometry with one linear ring containing
  /// 4 points:
  /// ```dart
  ///  Polygon.build(
  ///      // an array of linear rings
  ///      [
  ///        // a linear ring as a flat structure with four (x, y) points
  ///        [
  ///          10.1, 10.1,
  ///          5.0, 9.0,
  ///          12.0, 4.0,
  ///          10.1, 10.1,
  ///        ],
  ///      ],
  ///      type: Coords.xy,
  ///  );
  /// ```
  factory Polygon.build(
    Iterable<Iterable<double>> rings, {
    Coords type = Coords.xy,
    Box? bounds,
  }) =>
      Polygon(
        buildListOfPositionArrays(rings, type: type),
        bounds: bounds,
      );

  /// Parses a polygon geometry from [text] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory Polygon.parse(
    String text, {
    TextReaderFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.parse<Polygon>(
        text,
        format: format,
        crs: crs,
        options: options,
      );

  /// Parses a polygon geometry from [coordinates] conforming to
  /// [DefaultFormat].
  ///
  /// Use [crs] and [crsLogic] to give hints (like axis order, and whether x
  /// and y must be swapped when read in) about coordinate reference system in
  /// text input.
  factory Polygon.parseCoords(
    String coordinates, {
    CoordRefSys? crs,
    GeoRepresentation? crsLogic,
  }) {
    final array = json.decode('[$coordinates]') as List<dynamic>;
    if (array.isEmpty) {
      return Polygon.build(const []);
    }
    final coordType = resolveCoordType(array, positionLevel: 2);
    return Polygon.build(
      createFlatPositionArrayArrayDouble(
        array,
        coordType,
        swapXY: crs?.swapXY(logic: crsLogic) ?? false,
      ),
      type: coordType,
    );
  }

  /// Decodes a polygon geometry from [bytes] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory Polygon.decode(
    Uint8List bytes, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decode<Polygon>(
        bytes,
        format: format,
        options: options,
      );

  @override
  Geom get geomType => Geom.polygon;

  @override
  Coords get coordType => exterior?.type ?? Coords.xy;

  @override
  bool get isEmpty => _rings.isEmpty;

  /// The rings (exterior + interior) of this polygon.
  ///
  /// For non-empty polygons the first element is the exterior ring,
  /// and any other rings are interior rings (or holes). All rings must be
  /// closed linear rings.
  List<PositionArray> get rings => _rings;

  /// An exterior ring of this polygon.
  ///
  /// For empty polygon this returns null.
  PositionArray? get exterior => _rings.isEmpty ? null : _rings[0];

  /// The interior rings (or holes) of this polygon, allowed to be empty.
  Iterable<PositionArray> get interior => rings.skip(1);

  @override
  Box? calculateBounds() => BoundsBuilder.calculateBounds(
        arrays: _rings,
        type: coordType,
      );

  @override
  Polygon bounded({bool recalculate = false}) {
    if (isEmpty) return this;

    if (recalculate || bounds == null) {
      // return a new Polygon (rings kept intact) with populated bounds
      return Polygon(
        rings,
        bounds: BoundsBuilder.calculateBounds(
          arrays: rings,
          type: coordType,
        ),
      );
    } else {
      // bounds was already populated and not asked to recalculate
      return this;
    }
  }

  @override
  Polygon populated({
    bool traverse = false,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was unpopulated and geometry not empty
      if (bounds == null && !isEmpty) {
        return Polygon(
          rings,
          bounds: BoundsBuilder.calculateBounds(
            arrays: rings,
            type: coordType,
          ),
        );
      }
    }
    return this;
  }

  @override
  Polygon unpopulated({
    bool traverse = false,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was populated
      if (bounds != null) {
        return Polygon(rings);
      }
    }
    return this;
  }

  @override
  Polygon project(Projection projection) {
    final projected =
        _rings.map((ring) => ring.project(projection)).toList(growable: false);

    return Polygon(
      projected,

      // bounds calculated from projected geometry if there was bounds before
      bounds: bounds != null
          ? BoundsBuilder.calculateBounds(
              arrays: projected,
              type: coordType,
            )
          : null,
    );
  }

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) => isEmpty
      ? writer.emptyGeometry(Geom.polygon, name: name)
      : writer.polygon(
          _rings,
          type: coordType,
          name: name,
          bounds: bounds,
        );

  // NOTE: coordinates as raw data

  @override
  bool equalsCoords(Geometry other) {
    if (other is! Polygon) return false;
    if (identical(this, other)) return true;
    if (bounds != null && other.bounds != null && !(bounds! == other.bounds!)) {
      // both geometries has bound boxes and boxes do not equal
      return false;
    }

    final r1 = rings;
    final r2 = other.rings;
    if (r1.length != r2.length) return false;
    for (var i = 0; i < r1.length; i++) {
      if (!r1[i].equalsCoords(r2[i])) return false;
    }
    return true;
  }

  @override
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    if (other is! Polygon) return false;
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
    // ensure both polygons has same amount of linear rings
    final r1 = rings;
    final r2 = other.rings;
    if (r1.length != r2.length) return false;
    // loop all linear rings and test 2D coordinates using PositionData of rings
    for (var i = 0; i < r1.length; i++) {
      if (!r1[i].data.equals2D(
            r2[i].data,
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
    if (other is! Polygon) return false;
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
    // ensure both polygons has same amount of linear rings
    final r1 = rings;
    final r2 = other.rings;
    if (r1.length != r2.length) return false;
    // loop all linear rings and test 3D coordinates using PositionData of rings
    for (var i = 0; i < r1.length; i++) {
      if (!r1[i].data.equals3D(
            r2[i].data,
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
      other is Polygon && bounds == other.bounds && rings == other.rings;

  @override
  int get hashCode => Object.hash(bounds, rings);
}
