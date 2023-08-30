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
import '/src/vector/array/coordinates.dart';
import '/src/vector/array/coordinates_extensions.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/default_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';

import 'geometry.dart';
import 'geometry_builder.dart';
import 'linestring.dart';

/// A multi line string with an array of line strings (each with a chain of
/// positions).
class MultiLineString extends SimpleGeometry {
  final List<PositionArray> _lineStrings;

  /// A multi line string with an array of [lineStrings] (each with a chain of
  /// positions).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each line string or a chain of positions is represented by a
  /// [PositionArray] instance.
  const MultiLineString(List<PositionArray> lineStrings, {super.bounds})
      : _lineStrings = lineStrings;

  /// A multi line string from an iterable of [lineStrings] (each a chain as an
  /// iterable of positions).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each line string or a chain of positions is represented by an
  /// `Iterable<Position>` instance. The coordinate type of all positions in
  /// all chains should be the same.
  factory MultiLineString.from(
    Iterable<Iterable<Position>> lineStrings, {
    Box? bounds,
  }) =>
      MultiLineString(
        lineStrings.map((chain) => chain.array()).toList(growable: false),
        bounds: bounds,
      );

  /// Builds a multi line string from an array of [lineStrings] (each with a
  /// chain of positions).
  ///
  /// Use [type] to specify the type of coordinates, by default `Coords.xy` is
  /// expected.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each line string or a chain of positions is represented by a
  /// `Iterable<double>` instance. They contain coordinate values as a flat
  /// structure. For example for `Coords.xyz` the first three coordinate values
  /// are x, y and z of the first position, the next three coordinate values are
  /// x, y and z of the second position, and so on.
  ///
  /// An example to build a multi line string with two line strings:
  /// ```dart
  ///  MultiLineString.build(
  ///      // an array of chains (one chain for each line string)
  ///      [
  ///        // a chain as a flat structure with four (x, y) points
  ///        [
  ///          10.1, 10.1,
  ///          5.0, 9.0,
  ///          12.0, 4.0,
  ///          10.1, 10.1,
  ///        ],
  ///        // a chain as a flat structure with three (x, y) points
  ///        [
  ///          -1.1, -1.1,
  ///          2.1, -2.5,
  ///          3.5, -3.49,
  ///        ],
  ///      ],
  ///      type: Coords.xy,
  ///  );
  /// ```
  factory MultiLineString.build(
    Iterable<Iterable<double>> lineStrings, {
    Coords type = Coords.xy,
    Box? bounds,
  }) =>
      MultiLineString(
        buildListOfPositionArrays(lineStrings, type: type),
        bounds: bounds,
      );

  /// Parses a multi line string geometry from [text] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory MultiLineString.parse(
    String text, {
    TextReaderFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.parse<MultiLineString>(
        text,
        format: format,
        crs: crs,
        options: options,
      );

  /// Parses a multi line string geometry from [coordinates] conforming to
  /// [DefaultFormat].
  ///
  /// Use [crs] and [crsLogic] to give hints (like axis order, and whether x
  /// and y must be swapped when read in) about coordinate reference system in
  /// text input.
  factory MultiLineString.parseCoords(
    String coordinates, {
    CoordRefSys? crs,
    GeoRepresentation? crsLogic,
  }) {
    final array = json.decode('[$coordinates]') as List<dynamic>;
    if (array.isEmpty) {
      return MultiLineString.build(const []);
    }
    final coordType = resolveCoordType(array, positionLevel: 2);
    return MultiLineString.build(
      createFlatPositionArrayArrayDouble(
        array,
        coordType,
        swapXY: crs?.swapXY(logic: crsLogic) ?? false,
      ),
      type: coordType,
    );
  }

  /// Decodes a multi line string geometry from [bytes] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory MultiLineString.decode(
    Uint8List bytes, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decode<MultiLineString>(
        bytes,
        format: format,
        options: options,
      );

  @override
  Geom get geomType => Geom.multiLineString;

  @override
  Coords get coordType =>
      _lineStrings.isNotEmpty ? _lineStrings.first.type : Coords.xy;

  @override
  bool get isEmptyByGeometry => _lineStrings.isEmpty;

  /// The chains of all line strings.
  List<PositionArray> get chains => _lineStrings;

  /// All line strings as a lazy iterable of [LineString] geometries.
  Iterable<LineString> get lineStrings =>
      chains.map<LineString>(LineString.new);

  @override
  Box? calculateBounds() => BoundsBuilder.calculateBounds(
        arrays: _lineStrings,
        type: coordType,
      );

  @override
  @Deprecated('Use populated or unpopulated instead.')
  MultiLineString bounded({bool recalculate = false}) {
    if (isEmptyByGeometry) return this;

    if (recalculate || bounds == null) {
      // return a new MultiLineString (chains kept intact) with populated bounds
      return MultiLineString(
        chains,
        bounds: BoundsBuilder.calculateBounds(
          arrays: chains,
          type: coordType,
        ),
      );
    } else {
      // bounds was already populated and not asked to recalculate
      return this;
    }
  }

  @override
  MultiLineString populated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was unpopulated and geometry not empty
      if (bounds == null && !isEmptyByGeometry) {
        return MultiLineString(
          chains,
          bounds: BoundsBuilder.calculateBounds(
            arrays: chains,
            type: coordType,
          ),
        );
      }
    }
    return this;
  }

  @override
  MultiLineString unpopulated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was populated
      if (bounds != null) {
        return MultiLineString(chains);
      }
    }
    return this;
  }

  @override
  MultiLineString project(Projection projection) {
    final projected = _lineStrings
        .map((chain) => chain.project(projection))
        .toList(growable: false);

    return MultiLineString(
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
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      isEmptyByGeometry
          ? writer.emptyGeometry(Geom.multiLineString, name: name)
          : writer.multiLineString(
              _lineStrings,
              type: coordType,
              name: name,
              bounds: bounds,
            );

  // NOTE: coordinates as raw data

  @override
  bool equalsCoords(Geometry other) {
    if (other is! MultiLineString) return false;
    if (identical(this, other)) return true;
    if (bounds != null && other.bounds != null && !(bounds! == other.bounds!)) {
      // both geometries has bound boxes and boxes do not equal
      return false;
    }

    final c1 = chains;
    final c2 = other.chains;
    if (c1.length != c2.length) return false;
    for (var i = 0; i < c1.length; i++) {
      if (!c1[i].equalsCoords(c2[i])) return false;
    }
    return true;
  }

  @override
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    if (other is! MultiLineString) return false;
    if (isEmptyByGeometry || other.isEmptyByGeometry) return false;
    if (bounds != null &&
        other.bounds != null &&
        !bounds!.equals2D(
          other.bounds!,
          toleranceHoriz: toleranceHoriz,
        )) {
      // both geometries has bound boxes and boxes do not equal in 2D
      return false;
    }
    // ensure both multi line strings has same amount of chains
    final c1 = chains;
    final c2 = other.chains;
    if (c1.length != c2.length) return false;
    // loop all chains and test 2D coordinates using PositionData of chains
    for (var i = 0; i < c1.length; i++) {
      if (!c1[i].data.equals2D(
            c2[i].data,
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
    if (other is! MultiLineString) return false;
    if (isEmptyByGeometry || other.isEmptyByGeometry) return false;
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
    // ensure both multi line strings has same amount of chains
    final c1 = chains;
    final c2 = other.chains;
    if (c1.length != c2.length) return false;
    // loop all chains and test 3D coordinates using PositionData of chains
    for (var i = 0; i < c1.length; i++) {
      if (!c1[i].data.equals3D(
            c2[i].data,
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
      other is MultiLineString &&
      bounds == other.bounds &&
      chains == other.chains;

  @override
  int get hashCode => Object.hash(bounds, chains);
}
