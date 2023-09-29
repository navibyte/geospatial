// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import '/src/codes/coords.dart';
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
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';
import '/src/vector_data/model/bounded/bounded.dart';

import 'geometry.dart';
import 'geometry_builder.dart';

/// A line string geometry with a chain of positions.
class LineString extends SimpleGeometry {
  final PositionSeries _chain;

  /// A line string geometry with a [chain] of positions and optional [bounds].
  ///
  /// The [chain] array must contain at least two positions (or be empty).
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a line string from 2D positions
  /// LineString(
  ///   [
  ///     10.0, 20.0, // (x, y) for position 0
  ///     12.5, 22.5, // (x, y) for position 1
  ///     15.0, 25.0, // (x, y) for position 2
  ///   ].positions(Coords.xy),
  /// );
  ///
  /// // a line string from 3D positions
  /// LineString(
  ///   [
  ///     10.0, 20.0, 30.0, // (x, y, z) for position 0
  ///     12.5, 22.5, 32.5, // (x, y, z) for position 1
  ///     15.0, 25.0, 35.0, // (x, y, z) for position 2
  ///   ].positions(Coords.xyz),
  /// );
  ///
  /// // a line string from measured 2D positions
  /// LineString(
  ///   [
  ///     10.0, 20.0, 40.0, // (x, y, m) for position 0
  ///     12.5, 22.5, 42.5, // (x, y, m) for position 1
  ///     15.0, 25.0, 45.0, // (x, y, m) for position 2
  ///   ].positions(Coords.xym),
  /// );
  ///
  /// // a line string from measured 3D positions
  /// LineString(
  ///   [
  ///     10.0, 20.0, 30.0, 40.0, // (x, y, z, m) for position 0
  ///     12.5, 22.5, 32.5, 42.5, // (x, y, z, m) for position 1
  ///     15.0, 25.0, 35.0, 45.0, // (x, y, z, m) for position 2
  ///   ].positions(Coords.xyzm),
  /// );
  /// ```
  const LineString(PositionSeries chain, {super.bounds})
      : _chain = chain,
        assert(
          chain.length == 0 || chain.length >= 2,
          'Chain must contain at least two positions (or be empty)',
        );

  /// A line string geometry from a [chain] of positions and optional [bounds].
  ///
  /// The [chain] iterable must contain at least two positions (or be empty).
  ///
  /// The coordinate type of all positions in a chain should be the same.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a line string from 2D positions
  /// LineString.from([
  ///   [10.0, 20.0].xy,
  ///   [12.5, 22.5].xy,
  ///   [15.0, 25.0].xy,
  /// ]);
  ///
  /// // a line string from 3D positions
  /// LineString.from([
  ///   [10.0, 20.0, 30.0].xyz,
  ///   [12.5, 22.5, 32.5].xyz,
  ///   [15.0, 25.0, 35.0].xyz,
  /// ]);
  ///
  /// // a line string from measured 2D positions
  /// LineString.from([
  ///   [10.0, 20.0, 40.0].xym,
  ///   [12.5, 22.5, 42.5].xym,
  ///   [15.0, 25.0, 45.0].xym,
  /// ]);
  ///
  /// // a line string from measured 3D positions
  /// LineString.from(
  ///   [
  ///     [10.0, 20.0, 30.0, 40.0].xyzm,
  ///     [12.5, 22.5, 32.5, 42.5].xyzm,
  ///     [15.0, 25.0, 35.0, 45.0].xyzm,
  ///   ],
  /// );
  /// ```
  factory LineString.from(Iterable<Position> chain, {Box? bounds}) =>
      LineString(
        PositionSeries.from(chain),
        bounds: bounds,
      );

  /// Builds a line string geometry from a [chain] of positions.
  ///
  /// Use [type] to specify the type of coordinates, by default `Coords.xy` is
  /// expected.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// The [chain] array must contain at least two positions (or be empty). It
  /// contains coordinate values of chain positions as a flat structure. For
  /// example for `Coords.xyz` the first three coordinate values are x, y and z
  /// of the first position, the next three coordinate values are x, y and z of
  /// the second position, and so on.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a line string from 2D positions
  /// LineString.build(
  ///   [
  ///     10.0, 20.0, // (x, y) for position 0
  ///     12.5, 22.5, // (x, y) for position 1
  ///     15.0, 25.0, // (x, y) for position 2
  ///   ],
  ///   type: Coords.xy,
  /// );
  ///
  /// // a line string from 3D positions
  /// LineString.build(
  ///   [
  ///     10.0, 20.0, 30.0, // (x, y, z) for position 0
  ///     12.5, 22.5, 32.5, // (x, y, z) for position 1
  ///     15.0, 25.0, 35.0, // (x, y, z) for position 2
  ///   ],
  ///   type: Coords.xyz,
  /// );
  ///
  /// // a line string from measured 2D positions
  /// LineString.build(
  ///   [
  ///     10.0, 20.0, 40.0, // (x, y, m) for position 0
  ///     12.5, 22.5, 42.5, // (x, y, m) for position 1
  ///     15.0, 25.0, 45.0, // (x, y, m) for position 2
  ///   ],
  ///   type: Coords.xym,
  /// );
  ///
  /// // a line string from measured 3D positions
  /// LineString.build(
  ///   [
  ///     10.0, 20.0, 30.0, 40.0, // (x, y, z, m) for position 0
  ///     12.5, 22.5, 32.5, 42.5, // (x, y, z, m) for position 1
  ///     15.0, 25.0, 35.0, 45.0, // (x, y, z, m) for position 2
  ///   ],
  ///   type: Coords.xyzm,
  /// );
  /// ```
  factory LineString.build(
    Iterable<double> chain, {
    Coords type = Coords.xy,
    Box? bounds,
  }) =>
      LineString(
        PositionSeries.view(
          chain is List<double> ? chain : toFloatNNList(chain),
          type: type,
        ),
        bounds: bounds,
      );

  /// Parses a line string geometry from [text] conforming to [format].
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
  /// // a line string from 2D positions
  /// LineString.parse(
  ///   format: GeoJSON.geometry,
  ///   '{"type": "LineString", "coordinates": [[10.0,20.0], '
  ///   '[12.5,22.5], [15.0,25.0]]}',
  /// );
  /// LineString.parse(
  ///   format: WKT.geometry,
  ///   'LINESTRING (10.0 20.0,12.5 22.5,15.0 25.0)',
  /// );
  ///
  /// // a line string from 3D positions
  /// LineString.parse(
  ///   format: GeoJSON.geometry,
  ///   '{"type": "LineString", "coordinates": [[10.0,20.0,30.0], '
  ///   '[12.5,22.5,32.5], [15.0,25.0,35.0]]}',
  /// );
  /// LineString.parse(
  ///   format: WKT.geometry,
  ///   'LINESTRING Z (10.0 20.0 30.0,12.5 22.5 32.5,15.0 25.0 35.0)',
  /// );
  ///
  /// // a line string from measured 2D positions
  /// LineString.parse(
  ///   format: WKT.geometry,
  ///   'LINESTRING M (10.0 20.0 40.0,12.5 22.5 42.5,15.0 25.0 45.0)',
  /// );
  ///
  /// // a line string from measured 3D positions
  /// LineString.parse(
  ///   format: GeoJSON.geometry,
  ///   '{"type": "LineString", "coordinates": [[10.0,20.0,30.0,40.0], '
  ///   '[12.5,22.5,32.5,42.5], [15.0,25.0,35.0,45.0]]}',
  /// );
  /// LineString.parse(
  ///   format: WKT.geometry,
  ///   'LINESTRING ZM '
  ///   '(10.0 20.0 30.0 40.0,12.5 22.5 32.5 42.5,15.0 25.0 35.0 45.0)',
  /// );
  /// ```
  factory LineString.parse(
    String text, {
    TextReaderFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.parse<LineString>(
        text,
        format: format,
        crs: crs,
        options: options,
      );

  /// Parses a line string geometry from [coordinates] with coordinate values
  /// separated by [delimiter].
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
  /// // a line string from 2D positions
  /// LineString.parseCoords(
  ///   // values for three (x, y) positions
  ///   '10.0,20.0,12.5,22.5,15.0,25.0',
  ///   type: Coords.xy,
  /// );
  ///
  /// // a line string from 3D positions
  /// LineString.parseCoords(
  ///   // values for three (x, y, z) positions
  ///   '10.0,20.0,30.0,12.5,22.5,32.5,15.0,25.0,35.0',
  ///   type: Coords.xyz,
  /// );
  ///
  /// // a line string from measured 2D positions
  /// LineString.parseCoords(
  ///   // values for three (x, y, m) positions
  ///   '10.0,20.0,40.0,12.5,22.5,42.5,15.0,25.0,45.0',
  ///   type: Coords.xym,
  /// );
  ///
  /// // a line string from measured 3D positions
  /// LineString.parseCoords(
  ///   // values for three (x, y, z, m) positions
  ///   '10.0,20.0,30.0,40.0,12.5,22.5,32.5,42.5,15.0,25.0,35.0,45.0',
  ///   type: Coords.xyzm,
  /// );
  ///
  /// // a line string from 2D positions using an alternative delimiter
  /// LineString.parseCoords(
  ///   // values for three (x, y) positions
  ///   '10.0;20.0;12.5;22.5;15.0;25.0',
  ///   type: Coords.xy,
  ///   delimiter: ';',
  /// );
  ///
  /// // a line string from 2D positions with x before y
  /// LineString.parseCoords(
  ///   // values for three (x, y) positions
  ///   '20.0,10.0,22.5,12.5,25.0,15.0',
  ///   type: Coords.xy,
  ///   swapXY: true,
  /// );
  ///
  /// // a line string from 2D positions with the internal storage using single
  /// // precision floating point numbers (`Float32List` in this case)
  /// LineString.parseCoords(
  ///   // values for three (x, y) positions
  ///   '10.0,20.0,12.5,22.5,15.0,25.0',
  ///   type: Coords.xy,
  ///   singlePrecision: true,
  /// );
  /// ```
  factory LineString.parseCoords(
    String coordinates, {
    Pattern delimiter = ',',
    Coords type = Coords.xy,
    bool swapXY = false,
    bool singlePrecision = false,
  }) {
    final str = coordinates.trim();
    if (str.isEmpty) {
      return LineString(PositionSeries.empty());
    }
    // NOTE: validate line string (at least two points)
    return LineString(
      parsePositionSeriesFromTextDim1(
        str,
        delimiter: delimiter,
        type: type,
        swapXY: swapXY,
        singlePrecision: singlePrecision,
      ),
    );
  }

  /// Decodes a line string geometry from [bytes] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory LineString.decode(
    Uint8List bytes, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decode<LineString>(
        bytes,
        format: format,
        options: options,
      );

  @override
  Geom get geomType => Geom.lineString;

  @override
  Coords get coordType => _chain.type;

  @override
  bool get isEmptyByGeometry => _chain.isEmpty;

  /// The chain of positions in this line string geometry.
  PositionSeries get chain => _chain;

  /// Returns a line string containing a chain with all positions in reversed
  /// order compared to the chain of this.
  LineString reversed() => LineString(chain.reversed(), bounds: bounds);

  @override
  Box? calculateBounds() => BoundsBuilder.calculateBounds(
        series: chain,
        type: coordType,
      );

  @override
  @Deprecated('Use populated or unpopulated instead.')
  LineString bounded({bool recalculate = false}) {
    if (isEmptyByGeometry) return this;

    if (recalculate || bounds == null) {
      // return a new linestring (chain kept intact) with populated bounds
      return LineString(
        chain,
        bounds: BoundsBuilder.calculateBounds(
          series: chain,
          type: coordType,
        ),
      );
    } else {
      // bounds was already populated and not asked to recalculate
      return this;
    }
  }

  @override
  LineString populated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was unpopulated and geometry not empty
      if (bounds == null && !isEmptyByGeometry) {
        return LineString(
          chain,
          bounds: BoundsBuilder.calculateBounds(
            series: chain,
            type: coordType,
          ),
        );
      }
    }
    return this;
  }

  @override
  LineString unpopulated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was populated
      if (bounds != null) {
        return LineString(chain);
      }
    }
    return this;
  }

  @override
  LineString project(Projection projection) {
    final projected = chain.project(projection);

    return LineString(
      projected,

      // bounds calculated from projected chain if there was bounds before
      bounds: bounds != null
          ? BoundsBuilder.calculateBounds(
              series: projected,
              type: coordType,
            )
          : null,
    );
  }

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      isEmptyByGeometry
          ? writer.emptyGeometry(Geom.lineString, name: name)
          : writer.lineString(chain, name: name, bounds: bounds);

  // NOTE: coordinates as raw data

  @override
  bool equalsCoords(Bounded other) => testEqualsCoords<LineString>(
        this,
        other,
        (lineString1, lineString2) => lineString1.chain.equalsCoords(
          lineString2.chain,
        ),
      );

  @override
  bool equals2D(
    Bounded other, {
    double toleranceHoriz = defaultEpsilon,
  }) =>
      testEquals2D<LineString>(
        this,
        other,
        (lineString1, lineString2) => lineString1.chain.equals2D(
          lineString2.chain,
          toleranceHoriz: toleranceHoriz,
        ),
        toleranceHoriz: toleranceHoriz,
      );

  @override
  bool equals3D(
    Bounded other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) =>
      testEquals3D<LineString>(
        this,
        other,
        (lineString1, lineString2) => lineString1.chain.equals3D(
          lineString2.chain,
          toleranceHoriz: toleranceHoriz,
          toleranceVert: toleranceVert,
        ),
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  @override
  bool operator ==(Object other) =>
      other is LineString && bounds == other.bounds && chain == other.chain;

  @override
  int get hashCode => Object.hash(bounds, chain);
}
