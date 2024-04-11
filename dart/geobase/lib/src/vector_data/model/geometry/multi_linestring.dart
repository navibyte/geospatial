// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

import 'dart:typed_data';

import '/src/common/codes/coords.dart';
import '/src/common/codes/geom.dart';
import '/src/common/constants/epsilon.dart';
import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_extensions.dart';
import '/src/coordinates/base/position_scheme.dart';
import '/src/coordinates/base/position_series.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/bounded_utils.dart';
import '/src/utils/coord_positions.dart';
import '/src/utils/coord_type.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';

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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi line string with two line strings both with three 2D positions
  /// MultiLineString([
  ///   [10.0, 20.0, 12.5, 22.5, 15.0, 25.0].positions(Coords.xy),
  ///   [12.5, 23.0, 11.5, 24.0, 12.5, 24.0].positions(Coords.xy),
  /// ]);
  ///
  /// // a multi line string with two line strings both with three 3D positions
  /// MultiLineString([
  ///   [10.0, 20.0, 30.0, 12.5, 22.5, 32.5, 15.0, 25.0, 35.0]
  ///       .positions(Coords.xyz),
  ///   [12.5, 23.0, 32.5, 11.5, 24.0, 31.5, 12.5, 24.0, 32.5]
  ///       .positions(Coords.xyz),
  /// ]);
  /// ```
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi line string with two line strings both with three 2D positions
  /// MultiLineString.from([
  ///   [
  ///     [10.0, 20.0].xy,
  ///     [12.5, 22.5].xy,
  ///     [15.0, 25.0].xy,
  ///   ],
  ///   [
  ///     [12.5, 23.0].xy,
  ///     [11.5, 24.0].xy,
  ///     [12.5, 24.0].xy,
  ///   ],
  /// ]);
  ///
  /// // a multi line string with two line strings both with three 3D positions
  /// MultiLineString.from([
  ///   [
  ///     [10.0, 20.0, 30.0].xyz,
  ///     [12.5, 22.5, 32.5].xyz,
  ///     [15.0, 25.0, 35.0].xyz,
  ///   ],
  ///   [
  ///     [12.5, 23.0, 32.5].xyz,
  ///     [11.5, 24.0, 31.5].xyz,
  ///     [12.5, 24.0, 32.5].xyz,
  ///   ],
  /// ]);
  /// ```
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
  /// Examples:
  ///
  /// ```dart
  /// // a multi line string with two line strings both with three 2D positions
  /// MultiLineString.build(
  ///   [
  ///     [10.0, 20.0, 12.5, 22.5, 15.0, 25.0],
  ///     [12.5, 23.0, 11.5, 24.0, 12.5, 24.0],
  ///   ],
  ///   type: Coords.xy,
  /// );
  ///
  /// // a multi line string with two line strings both with three 3D positions
  /// MultiLineString.build(
  ///   [
  ///     [10.0, 20.0, 30.0, 12.5, 22.5, 32.5, 15.0, 25.0, 35.0],
  ///     [12.5, 23.0, 32.5, 11.5, 24.0, 31.5, 12.5, 24.0, 32.5],
  ///   ],
  ///   type: Coords.xyz,
  /// );
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
                chain is List<double> ? chain : toFloatNNList(chain),
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi line string with two line strings both with three 2D positions
  /// MultiLineString.parse(
  ///   format: GeoJSON.geometry,
  ///   '''
  ///   {
  ///     "type": "MultiLineString",
  ///     "coordinates": [
  ///       [[10.0,20.0], [12.5,22.5], [15.0,25.0]],
  ///       [[12.5,23.0], [11.5,24.0], [12.5,24.0]]
  ///     ]
  ///   }
  ///   ''',
  /// );
  /// MultiLineString.parse(
  ///   format: WKT.geometry,
  ///   '''
  ///   MULTILINESTRING (
  ///     (10.0 20.0,12.5 22.5,15.0 25.0),
  ///     (12.5 23.0,11.5 24.0,12.5 24.0)
  ///   )
  ///   ''',
  /// );
  ///
  /// // a multi line string with two line strings both with three 3D positions
  /// MultiLineString.parse(
  ///   format: GeoJSON.geometry,
  ///   '''
  ///   {
  ///     "type": "MultiLineString",
  ///     "coordinates": [
  ///       [[10.0,20.0,30.0], [12.5,22.5,32.5], [15.0,25.0,35.0]],
  ///       [[12.5,23.0,32.5], [11.5,24.0,31.5], [12.5,24.0,32.5]]
  ///     ]
  ///   }
  ///   ''',
  /// );
  /// MultiLineString.parse(
  ///   format: WKT.geometry,
  ///   '''
  ///   MULTILINESTRING Z (
  ///     (10.0 20.0 30.0,12.5 22.5 32.5,15.0 25.0 35.0),
  ///     (12.5 23.0 32.5,11.5 24.0 31.5,12.5 24.0 32.5)
  ///   )
  ///   ''',
  /// );
  /// ```
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

  /// Parses a multi line string geometry from [lineStrings] with each line
  /// string formatted as a text containing coordinate values separated by
  /// [delimiter].
  ///
  /// Use the required optional [type] to explicitely set the coordinate type.
  ///
  /// If [swapXY] is true, then swaps x and y for all positions in the result.
  ///
  /// If [singlePrecision] is true, then coordinate values of positions are
  /// stored in `Float32List` instead of the `Float64List` (default).
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi line string with two line strings both with three 2D positions
  /// MultiLineString.parseCoords(
  ///   [
  ///     '10.0,20.0,12.5,22.5,15.0,25.0',
  ///     '12.5,23.0,11.5,24.0,12.5,24.0',
  ///   ],
  ///   type: Coords.xy,
  /// );
  ///
  /// // a multi line string with two line strings both with three 3D positions
  /// MultiLineString.parseCoords(
  ///   [
  ///     '10.0,20.0,30.0,12.5,22.5,32.5,15.0,25.0,35.0',
  ///     '12.5,23.0,32.5,11.5,24.0,31.5,12.5,24.0,32.5',
  ///   ],
  ///   type: Coords.xyz,
  /// );
  ///
  /// // a multi line string with two line strings both with three 2D positions
  /// // using an alternative delimiter
  /// MultiLineString.parseCoords(
  ///   [
  ///     '10.0;20.0;12.5;22.5;15.0;25.0',
  ///     '12.5;23.0;11.5;24.0;12.5;24.0',
  ///   ],
  ///   type: Coords.xy,
  ///   delimiter: ';',
  /// );
  ///
  /// // a multi line string with two line strings both with three 2D positions
  /// // with x before y
  /// MultiLineString.parseCoords(
  ///   [
  ///     '20.0,10.0,22.5,12.5,25.0,15.0',
  ///     '23.0,12.5,24.0,11.5,24.0,12.5',
  ///   ],
  ///   type: Coords.xy,
  ///   swapXY: true,
  /// );
  ///
  /// // a multi line string with two line strings both with three 2D positions
  /// // with the internal storage using single precision floating point numbers
  /// // (`Float32List` in this case)
  /// MultiLineString.parseCoords(
  ///   [
  ///     '10.0,20.0,12.5,22.5,15.0,25.0',
  ///     '12.5,23.0,11.5,24.0,12.5,24.0',
  ///   ],
  ///   type: Coords.xy,
  ///   singlePrecision: true,
  /// );
  /// ```
  factory MultiLineString.parseCoords(
    Iterable<String> lineStrings, {
    Pattern delimiter = ',',
    Coords type = Coords.xy,
    bool swapXY = false,
    bool singlePrecision = false,
  }) {
    if (lineStrings.isEmpty) {
      return MultiLineString.build(const []);
    } else {
      return MultiLineString(
        lineStrings
            .map(
              (lineString) => parsePositionSeriesFromTextDim1(
                lineString,
                delimiter: delimiter,
                type: type,
                swapXY: swapXY,
                singlePrecision: singlePrecision,
              ),
            )
            .toList(growable: false),
      );
    }
  }

  /// Decodes a multi line string geometry from [bytes] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  ///
  /// See also [MultiLineString.decodeHex] to decode from bytes represented as
  /// a hex string.
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

  /// Decodes a multi line string geometry from [bytesHex] (as a hex string)
  /// conforming to [format].
  ///
  /// See [MultiLineString.decode] for more information.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi line string from a WKB encoded hex string - same geometry as
  /// // WKT: "MULTILINESTRING((35 10,45 45,15 40,10 20,35 10))"
  /// MultiLineString.decodeHex('01050000000100000001020000000500000000000000008041400000000000002440000000000080464000000000008046400000000000002e4000000000000044400000000000002440000000000000344000000000008041400000000000002440');
  /// ```
  factory MultiLineString.decodeHex(
    String bytesHex, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decodeHex<MultiLineString>(
        bytesHex,
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
  Box? calculateBounds({PositionScheme scheme = Position.scheme}) =>
      chains.map((c) => c.calculateBounds(scheme: scheme)).merge();

  @override
  MultiLineString populated({
    int traverse = 0,
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was unpopulated or of other scheme
      final b = bounds;
      final empty = chains.isEmpty;
      if ((b == null && !empty) ||
          (b != null && !b.conforming.conformsWith(scheme))) {
        return MultiLineString(
          chains,
          bounds: empty
              ? null
              : chains.map((c) => c.getBounds(scheme: scheme)).merge(),
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

    return MultiLineString(projected);
  }

  @override
  double length2D() {
    var length = 0.0;
    for (final chain in chains) {
      length += chain.length2D();
    }
    return length;
  }

  @override
  double length3D() {
    var length = 0.0;
    for (final chain in chains) {
      length += chain.length3D();
    }
    return length;
  }

  @override
  double area2D() => 0.0;

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      isEmptyByGeometry
          ? writer.emptyGeometry(Geom.multiLineString, name: name)
          : writer.multiLineString(chains, name: name, bounds: bounds);

  // NOTE: coordinates as raw data

  @override
  bool equalsCoords(Geometry other) => testEqualsCoords<MultiLineString>(
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
    Geometry other, {
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
    Geometry other, {
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
