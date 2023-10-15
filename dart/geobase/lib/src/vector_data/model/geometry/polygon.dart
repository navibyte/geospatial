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
import '/src/coordinates/base/position_scheme.dart';
import '/src/coordinates/base/position_series.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/reference/coord_ref_sys.dart';
import '/src/utils/bounded_utils.dart';
import '/src/utils/coord_positions.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';

import 'geometry.dart';
import 'geometry_builder.dart';

/// A polygon geometry with one exterior and 0 to N interior rings.
///
/// An empty polygon has no rings.
class Polygon extends SimpleGeometry {
  final List<PositionSeries> _rings;

  /// A polygon geometry with one exterior and 0 to N interior [rings].
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each ring in the polygon is represented by a `PositionSeries` instance.
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
  /// Examples:
  ///
  /// ```dart
  /// // a polygon (with an exterior ring only) from 2D positions
  /// Polygon(
  ///   [
  ///     // an exterior ring with values of five (x, y) positions
  ///     [
  ///       10.0, 20.0,
  ///       12.5, 22.5,
  ///       15.0, 25.0,
  ///       11.5, 27.5,
  ///       10.0, 20.0,
  ///     ].positions(Coords.xy),
  ///   ],
  /// );
  ///
  /// // a polygon (with an exterior and one interior ring) from 2D positions
  /// Polygon(
  ///   [
  ///     // an exterior ring with values of five (x, y) positions
  ///     [
  ///       10.0, 20.0,
  ///       12.5, 22.5,
  ///       15.0, 25.0,
  ///       11.5, 27.5,
  ///       10.0, 20.0,
  ///     ].positions(Coords.xy),
  ///     // an interior ring with values of four (x, y) positions
  ///     [
  ///       12.5, 23.0,
  ///       11.5, 24.0,
  ///       12.5, 24.0,
  ///       12.5, 23.0,
  ///     ].positions(Coords.xy),
  ///   ],
  /// );
  ///
  /// // a polygon (with an exterior ring only) from 3D positions
  /// Polygon(
  ///   [
  ///     // an exterior ring with values of five (x, y, z) positions
  ///     [
  ///       10.0, 20.0, 30.0,
  ///       12.5, 22.5, 32.5,
  ///       15.0, 25.0, 35.0,
  ///       11.5, 27.5, 37.5,
  ///       10.0, 20.0, 30.0,
  ///     ].positions(Coords.xyz),
  ///   ],
  /// );
  ///
  /// // a polygon (with an exterior ring only) from measured 2D positions
  /// Polygon(
  ///   [
  ///     // an exterior ring with values of five (x, y, m) positions
  ///     [
  ///       10.0, 20.0, 40.0,
  ///       12.5, 22.5, 42.5,
  ///       15.0, 25.0, 45.0,
  ///       11.5, 27.5, 47.5,
  ///       10.0, 20.0, 40.0,
  ///     ].positions(Coords.xym),
  ///   ],
  /// );
  ///
  /// // a polygon (with an exterior ring only) from measured 3D positions
  /// Polygon(
  ///   [
  ///     // an exterior ring with values of five (x, y, z, m) positions
  ///     [
  ///       10.0, 20.0, 30.0, 40.0,
  ///       12.5, 22.5, 32.5, 42.5,
  ///       15.0, 25.0, 35.0, 45.0,
  ///       11.5, 27.5, 37.5, 47.5,
  ///       10.0, 20.0, 30.0, 40.0,
  ///     ].positions(Coords.xyzm),
  ///   ],
  /// );
  /// ```
  const Polygon(List<PositionSeries> rings, {super.bounds}) : _rings = rings;

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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a polygon (with an exterior ring only) from 2D positions
  /// Polygon.from(
  ///   [
  ///     // an exterior ring with five (x, y) positions
  ///     [
  ///       [10.0, 20.0].xy,
  ///       [12.5, 22.5].xy,
  ///       [15.0, 25.0].xy,
  ///       [11.5, 27.5].xy,
  ///       [10.0, 20.0].xy,
  ///     ],
  ///   ],
  /// );
  ///
  /// // a polygon (with an exterior and one interior ring) from 2D positions
  /// Polygon.from(
  ///   [
  ///     // an exterior ring with five (x, y) positions
  ///     [
  ///       [10.0, 20.0].xy,
  ///       [12.5, 22.5].xy,
  ///       [15.0, 25.0].xy,
  ///       [11.5, 27.5].xy,
  ///       [10.0, 20.0].xy,
  ///     ],
  ///     // an interior ring with four (x, y) positions
  ///     [
  ///       [12.5, 23.0].xy,
  ///       [11.5, 24.0].xy,
  ///       [12.5, 24.0].xy,
  ///       [12.5, 23.0].xy,
  ///     ],
  ///   ],
  /// );
  ///
  /// // a polygon (with an exterior ring only) from 3D positions
  /// Polygon.from(
  ///   [
  ///     // an exterior ring with five (x, y, z) positions
  ///     [
  ///       [10.0, 20.0, 30.0].xyz,
  ///       [12.5, 22.5, 32.5].xyz,
  ///       [15.0, 25.0, 35.0].xyz,
  ///       [11.5, 27.5, 37.5].xyz,
  ///       [10.0, 20.0, 30.0].xyz,
  ///     ],
  ///   ],
  /// );
  ///
  /// // a polygon (with an exterior ring only) from measured 2D positions
  /// Polygon.from(
  ///   [
  ///     // an exterior ring with five (x, y, m) positions
  ///     [
  ///       [10.0, 20.0, 40.0].xym,
  ///       [12.5, 22.5, 42.5].xym,
  ///       [15.0, 25.0, 45.0].xym,
  ///       [11.5, 27.5, 47.5].xym,
  ///       [10.0, 20.0, 40.0].xym,
  ///     ],
  ///   ],
  /// );
  ///
  /// // a polygon (with an exterior ring only) from measured 3D positions
  /// Polygon.from(
  ///   [
  ///     // an exterior ring with five (x, y, z, m) positions
  ///     [
  ///       [10.0, 20.0, 30.0, 40.0].xyzm,
  ///       [12.5, 22.5, 32.5, 42.5].xyzm,
  ///       [15.0, 25.0, 35.0, 45.0].xyzm,
  ///       [11.5, 27.5, 37.5, 47.5].xyzm,
  ///       [10.0, 20.0, 30.0, 40.0].xyzm,
  ///     ],
  ///   ],
  /// );
  /// ```
  factory Polygon.from(
    Iterable<Iterable<Position>> rings, {
    Box? bounds,
  }) =>
      Polygon(
        rings.map(PositionSeries.from).toList(growable: false),
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
  /// Examples:
  ///
  /// ```dart
  /// // a polygon (with an exterior ring only) from 2D positions
  /// Polygon.build(
  ///   [
  ///     // an exterior ring with values of five (x, y) positions
  ///     [
  ///       10.0, 20.0,
  ///       12.5, 22.5,
  ///       15.0, 25.0,
  ///       11.5, 27.5,
  ///       10.0, 20.0,
  ///     ],
  ///   ],
  ///   type: Coords.xy,
  /// );
  ///
  /// // a polygon (with an exterior and one interior ring) from 2D positions
  /// Polygon.build(
  ///   [
  ///     // an exterior ring with values of five (x, y) positions
  ///     [
  ///       10.0, 20.0,
  ///       12.5, 22.5,
  ///       15.0, 25.0,
  ///       11.5, 27.5,
  ///       10.0, 20.0,
  ///     ],
  ///     // an interior ring with values of four (x, y) positions
  ///     [
  ///       12.5, 23.0,
  ///       11.5, 24.0,
  ///       12.5, 24.0,
  ///       12.5, 23.0,
  ///     ],
  ///   ],
  ///   type: Coords.xy,
  /// );
  ///
  /// // a polygon (with an exterior ring only) from 3D positions
  /// Polygon.build(
  ///   [
  ///     // an exterior ring with values of five (x, y, z) positions
  ///     [
  ///       10.0, 20.0, 30.0,
  ///       12.5, 22.5, 32.5,
  ///       15.0, 25.0, 35.0,
  ///       11.5, 27.5, 37.5,
  ///       10.0, 20.0, 30.0,
  ///     ],
  ///   ],
  ///   type: Coords.xyz,
  /// );
  ///
  /// // a polygon (with an exterior ring only) from measured 2D positions
  /// Polygon.build(
  ///   [
  ///     // an exterior ring with values of five (x, y, m) positions
  ///     [
  ///       10.0, 20.0, 40.0,
  ///       12.5, 22.5, 42.5,
  ///       15.0, 25.0, 45.0,
  ///       11.5, 27.5, 47.5,
  ///       10.0, 20.0, 40.0,
  ///     ],
  ///   ],
  ///   type: Coords.xym,
  /// );
  ///
  /// // a polygon (with an exterior ring only) from measured 3D positions
  /// Polygon.build(
  ///   [
  ///     // an exterior ring with values of five (x, y, z, m) positions
  ///     [
  ///       10.0, 20.0, 30.0, 40.0,
  ///       12.5, 22.5, 32.5, 42.5,
  ///       15.0, 25.0, 35.0, 45.0,
  ///       11.5, 27.5, 37.5, 47.5,
  ///       10.0, 20.0, 30.0, 40.0,
  ///     ],
  ///   ],
  ///   type: Coords.xyzm,
  /// );
  /// ```
  factory Polygon.build(
    Iterable<Iterable<double>> rings, {
    Coords type = Coords.xy,
    Box? bounds,
  }) =>
      Polygon(
        rings
            .map(
              (ring) => PositionSeries.view(
                ring is List<double> ? ring : toFloatNNList(ring),
                type: type,
              ),
            )
            .toList(growable: false),
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a polygon (with an exterior ring only) from 2D positions
  /// Polygon.parse(
  ///   format: GeoJSON.geometry,
  ///   '''
  ///   {
  ///     "type": "Polygon",
  ///     "coordinates": [
  ///       [
  ///         [10.0,20.0],
  ///         [12.5,22.5],
  ///         [15.0,25.0],
  ///         [11.5,27.5],
  ///         [10.0,20.0]
  ///       ]
  ///     ]
  ///   }
  ///   ''',
  /// );
  /// Polygon.parse(
  ///   format: WKT.geometry,
  ///   'POLYGON ((10.0 20.0,12.5 22.5,15.0 25.0,11.5 27.5,10.0 20.0))',
  /// );
  ///
  /// // a polygon (with an exterior ring only) from 3D positions
  /// Polygon.parse(
  ///   format: GeoJSON.geometry,
  ///   '''
  ///   {
  ///     "type": "Polygon",
  ///     "coordinates": [
  ///       [
  ///         [10.0,20.0,30.0],
  ///         [12.5,22.5,32.5],
  ///         [15.0,25.0,35.0],
  ///         [11.5,27.5,37.5],
  ///         [10.0,20.0,30.0]
  ///       ]
  ///     ]
  ///   }
  ///   ''',
  /// );
  /// Polygon.parse(
  ///   format: WKT.geometry,
  ///   '''
  ///   POLYGON Z (
  ///     (
  ///       10.0 20.0 30.0,
  ///       12.5 22.5 32.5,
  ///       15.0 25.0 35.0,
  ///       11.5 27.5 37.5,
  ///       10.0 20.0 30.0
  ///     )
  ///   )
  ///   ''',
  /// );
  ///
  /// // a polygon (with an exterior ring only) from measured 2D positions
  /// Polygon.parse(
  ///   format: WKT.geometry,
  ///   '''
  ///   POLYGON M (
  ///     (
  ///       10.0 20.0 40.0,
  ///       12.5 22.5 42.5,
  ///       15.0 25.0 45.0,
  ///       11.5 27.5 47.5,
  ///       10.0 20.0 40.0
  ///     )
  ///   )
  ///   ''',
  /// );
  ///
  /// // a polygon (with an exterior ring only) from measured 3D positions
  /// Polygon.parse(
  ///   format: GeoJSON.geometry,
  ///   '''
  ///   {
  ///     "type": "Polygon",
  ///     "coordinates": [
  ///       [
  ///         [10.0,20.0,30.0,40.0],
  ///         [12.5,22.5,32.5,42.5],
  ///         [15.0,25.0,35.0,45.0],
  ///         [11.5,27.5,37.5,47.5],
  ///         [10.0,20.0,30.0,40.0]
  ///       ]
  ///     ]
  ///   }
  ///   ''',
  /// );
  /// Polygon.parse(
  ///   format: WKT.geometry,
  ///   '''
  ///   POLYGON ZM (
  ///     (
  ///       10.0 20.0 30.0 40.0,
  ///       12.5 22.5 32.5 42.5,
  ///       15.0 25.0 35.0 45.0,
  ///       11.5 27.5 37.5 47.5,
  ///       10.0 20.0 30.0 40.0
  ///     )
  ///   )
  ///   ''',
  /// );
  /// ```
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

  /// Parses a polygon geometry from [rings] with linear rings formatted as
  /// texts containing coordinate values separated by [delimiter].
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
  /// // a polygon (with an exterior ring only) from 2D positions
  /// Polygon.parseCoords(
  ///   [
  ///     // an exterior ring with values of five (x, y) positions
  ///     '10.0,20.0,'
  ///     '12.5,22.5,'
  ///     '15.0,25.0,'
  ///     '11.5,27.5,'
  ///     '10.0,20.0'
  ///   ],
  ///   type: Coords.xy,
  /// );
  ///
  /// // a polygon (with an exterior and one interior ring) from 2D positions
  /// Polygon.parseCoords(
  ///   [
  ///     // an exterior ring with values of five (x, y) positions
  ///     '10.0,20.0,'
  ///     '12.5,22.5,'
  ///     '15.0,25.0,'
  ///     '11.5,27.5,'
  ///     '10.0,20.0',
  ///
  ///     // an interior ring with values of four (x, y) positions
  ///     '12.5,23.0,'
  ///     '11.5,24.0,'
  ///     '12.5,24.0,'
  ///     '12.5,23.0'
  ///   ],
  ///   type: Coords.xy,
  /// );
  ///
  /// // a polygon (with an exterior ring only) from 3D positions
  /// Polygon.parseCoords(
  ///   [
  ///     // an exterior ring with values of five (x, y, z) positions
  ///     '10.0,20.0,30.0,'
  ///     '12.5,22.5,32.5,'
  ///     '15.0,25.0,35.0,'
  ///     '11.5,27.5,37.5,'
  ///     '10.0,20.0,30.0'
  ///   ],
  ///   type: Coords.xyz,
  /// );
  ///
  /// // a polygon (with an exterior ring only) from measured 2D positions
  /// Polygon.parseCoords(
  ///   [
  ///     // an exterior ring with values of five (x, y, m) positions
  ///     '10.0,20.0,40.0,'
  ///     '12.5,22.5,42.5,'
  ///     '15.0,25.0,45.0,'
  ///     '11.5,27.5,47.5,'
  ///     '10.0,20.0,40.0'
  ///   ],
  ///   type: Coords.xym,
  /// );
  ///
  /// // a polygon (with an exterior ring only) from measured 3D positions
  /// Polygon.parseCoords(
  ///   [
  ///     // an exterior ring with values of five (x, y, z, m) positions
  ///     '10.0,20.0,30.0,40.0,'
  ///     '12.5,22.5,32.5,42.5,'
  ///     '15.0,25.0,35.0,45.0,'
  ///     '11.5,27.5,37.5,47.5,'
  ///     '10.0,20.0,30.0,40.0'
  ///   ],
  ///   type: Coords.xyzm,
  /// );
  ///
  /// // a polygon (with an exterior ring only) from 2D positions using an
  /// // alternative delimiter
  /// Polygon.parseCoords(
  ///   [
  ///     // an exterior ring with values of five (x, y) positions
  ///     '10.0;20.0;'
  ///     '12.5;22.5;'
  ///     '15.0;25.0;'
  ///     '11.5;27.5;'
  ///     '10.0;20.0'
  ///   ],
  ///   type: Coords.xy,
  ///   delimiter: ';',
  /// );
  ///
  /// // a polygon (with an exterior ring only) from 2D positions with x before
  /// // y
  /// Polygon.parseCoords(
  ///   [
  ///     // an exterior ring with values of five (x, y) positions
  ///     '20.0,10.0,'
  ///     '22.5,12.5,'
  ///     '25.0,15.0,'
  ///     '27.5,11.5,'
  ///     '20.0,10.0'
  ///   ],
  ///   type: Coords.xy,
  ///   swapXY: true,
  /// );
  ///
  /// // a polygon (with an exterior ring only) from 2D positions with the
  /// // internal storage using single precision floating point numbers
  /// // (`Float32List` in this case)
  /// Polygon.parseCoords(
  ///   [
  ///     // an exterior ring with values of five (x, y) positions
  ///     '10.0,20.0,'
  ///     '12.5,22.5,'
  ///     '15.0,25.0,'
  ///     '11.5,27.5,'
  ///     '10.0,20.0'
  ///   ],
  ///   type: Coords.xy,
  ///   singlePrecision: true,
  /// );
  /// ```
  factory Polygon.parseCoords(
    Iterable<String> rings, {
    Pattern delimiter = ',',
    Coords type = Coords.xy,
    bool swapXY = false,
    bool singlePrecision = false,
  }) {
    if (rings.isEmpty) {
      return Polygon.build(const []);
    } else {
      return Polygon(
        rings
            .map(
              (ring) => parsePositionSeriesFromTextDim1(
                ring,
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
  Coords get coordType => exterior?.coordType ?? Coords.xy;

  @override
  bool get isEmptyByGeometry => _rings.isEmpty;

  /// The rings (exterior + interior) of this polygon.
  ///
  /// For non-empty polygons the first element is the exterior ring,
  /// and any other rings are interior rings (or holes). All rings must be
  /// closed linear rings.
  List<PositionSeries> get rings => _rings;

  /// An exterior ring of this polygon.
  ///
  /// For empty polygon this returns null.
  PositionSeries? get exterior => _rings.isEmpty ? null : _rings[0];

  /// The interior rings (or holes) of this polygon, allowed to be empty.
  Iterable<PositionSeries> get interior => rings.skip(1);

  @override
  Box? calculateBounds({PositionScheme scheme = Position.scheme}) =>
      exterior?.calculateBounds(scheme: scheme);

  @override
  Polygon populated({
    int traverse = 0,
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was unpopulated or of other scheme
      final b = bounds;
      final empty = rings.isEmpty;
      if ((b == null && !empty) || (b != null && !b.conformsScheme(scheme))) {
        return Polygon(
          rings,
          bounds: empty ? null : exterior?.getBounds(scheme: scheme),
        );
      }
    }
    return this;
  }

  @override
  Polygon unpopulated({
    int traverse = 0,
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
        rings.map((ring) => ring.project(projection)).toList(growable: false);

    return Polygon(projected);
  }

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      isEmptyByGeometry
          ? writer.emptyGeometry(Geom.polygon, name: name)
          : writer.polygon(rings, name: name, bounds: bounds);

  // NOTE: coordinates as raw data

  @override
  bool equalsCoords(Geometry other) => testEquals2D<Polygon>(
        this,
        other,
        (polygon1, polygon2) => _testPolygons(
          polygon1,
          polygon2,
          (posArray1, posArray2) => posArray1.equalsCoords(posArray2),
        ),
      );

  @override
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
  }) =>
      testEquals2D<Polygon>(
        this,
        other,
        (polygon1, polygon2) => _testPolygons(
          polygon1,
          polygon2,
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
      testEquals3D<Polygon>(
        this,
        other,
        (polygon1, polygon2) => _testPolygons(
          polygon1,
          polygon2,
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
      other is Polygon && bounds == other.bounds && rings == other.rings;

  @override
  int get hashCode => Object.hash(bounds, rings);
}

bool _testPolygons(
  Polygon polygon1,
  Polygon polygon2,
  bool Function(PositionSeries, PositionSeries) testPositionArrays,
) {
  // ensure both polygons has same amount of linear rings
  final r1 = polygon1.rings;
  final r2 = polygon2.rings;
  if (r1.length != r2.length) return false;
  // loop all linear rings and test coordinates using PositionData of rings
  for (var i = 0; i < r1.length; i++) {
    if (!testPositionArrays.call(r1[i], r2[i])) {
      return false;
    }
  }
  return true;
}
