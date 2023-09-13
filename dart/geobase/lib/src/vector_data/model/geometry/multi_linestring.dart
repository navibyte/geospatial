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
import '/src/coordinates/base/position_series.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/reference/coord_ref_sys.dart';
import '/src/utils/bounded_utils.dart';
import '/src/utils/bounds_builder.dart';
import '/src/utils/coord_positions.dart';
import '/src/utils/coord_type.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/default_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';
import '/src/vector_data/model/bounded/bounded.dart';

import 'geometry.dart';
import 'geometry_builder.dart';
import 'linestring.dart';

/// A multi line string with an array of line strings (each with a chain of
/// positions).
class MultiLineString extends SimpleGeometry {
  final List<PositionSeries> _lineStrings;

  /// A multi line string with an array of [lineStrings] (each with a chain of
  /// positions).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each line string or a chain of positions is represented by a
  /// [PositionSeries] instance.
  const MultiLineString(List<PositionSeries> lineStrings, {super.bounds})
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
        lineStrings.map(PositionSeries.from).toList(growable: false),
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
        lineStrings
            .map(
              (chain) => PositionSeries.view(
                chain is List<double> ? chain : chain.toList(growable: false),
                type: type,
              ),
            )
            .toList(growable: false),
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
    final str = coordinates.trim();
    if (str.isEmpty) {
      return MultiLineString.build(const []);
    }
    final array = json.decode('[$str]') as List<dynamic>;
    return MultiLineString(
      createPositionSeriesArray(
        array,
        swapXY: crs?.swapXY(logic: crsLogic) ?? false,
      ),
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
  Coords get coordType => positionSeriesArrayType(chains);

  @override
  bool get isEmptyByGeometry => _lineStrings.isEmpty;

  /// The chains of all line strings.
  List<PositionSeries> get chains => _lineStrings;

  /// All line strings as a lazy iterable of [LineString] geometries.
  Iterable<LineString> get lineStrings =>
      chains.map<LineString>(LineString.new);

  @override
  Box? calculateBounds() => BoundsBuilder.calculateBounds(
        seriesArray: _lineStrings,
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
          seriesArray: chains,
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
            seriesArray: chains,
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
              seriesArray: projected,
              type: coordType,
            )
          : null,
    );
  }

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      isEmptyByGeometry
          ? writer.emptyGeometry(Geom.multiLineString, name: name)
          : writer.multiLineString(chains, name: name, bounds: bounds);

  // NOTE: coordinates as raw data

  @override
  bool equalsCoords(Bounded other) => testEqualsCoords<MultiLineString>(
        this,
        other,
        (mls1, mls2) => _testMultiLineStrings(
          mls1,
          mls2,
          (posArray1, posArray2) => posArray1.equalsCoords(posArray2),
        ),
      );

  @override
  bool equals2D(
    Bounded other, {
    double toleranceHoriz = defaultEpsilon,
  }) =>
      testEquals2D<MultiLineString>(
        this,
        other,
        (mls1, mls2) => _testMultiLineStrings(
          mls1,
          mls2,
          (posArray1, posArray2) => posArray1.equals2D(
            posArray2,
            toleranceHoriz: toleranceHoriz,
          ),
        ),
        toleranceHoriz: toleranceHoriz,
      );

  @override
  bool equals3D(
    Bounded other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) =>
      testEquals3D<MultiLineString>(
        this,
        other,
        (mls1, mls2) => _testMultiLineStrings(
          mls1,
          mls2,
          (posArray1, posArray2) => posArray1.equals3D(
            posArray2,
            toleranceHoriz: toleranceHoriz,
            toleranceVert: toleranceVert,
          ),
        ),
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  @override
  bool operator ==(Object other) =>
      other is MultiLineString &&
      bounds == other.bounds &&
      chains == other.chains;

  @override
  int get hashCode => Object.hash(bounds, chains);
}

bool _testMultiLineStrings(
  MultiLineString mls1,
  MultiLineString mls2,
  bool Function(PositionSeries, PositionSeries) testPositionArrays,
) {
  // ensure both multi line strings has same amount of chains
  final c1 = mls1.chains;
  final c2 = mls2.chains;
  if (c1.length != c2.length) return false;
  // loop all chains and test coordinates using PositionData of chains
  for (var i = 0; i < c1.length; i++) {
    if (!testPositionArrays.call(c1[i], c2[i])) {
      return false;
    }
  }
  return true;
}
