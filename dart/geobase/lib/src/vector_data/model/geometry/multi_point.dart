// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import '/src/common/codes/coords.dart';
import '/src/common/codes/geom.dart';
import '/src/common/constants/epsilon.dart';
import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_extensions.dart';
import '/src/coordinates/base/position_scheme.dart';
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
import 'point.dart';

/// A multi point geometry with an array of points (each with a position).
class MultiPoint extends SimpleGeometry {
  final List<Position> _points;

  /// A multi point geometry with an array of [points] (each with a position).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each point is represented by a [Position] instance.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi point with three 2D positions
  /// MultiPoint([
  ///   [10.0, 20.0].xy,
  ///   [12.5, 22.5].xy,
  ///   [15.0, 25.0].xy,
  /// ]);
  ///
  /// // a multi point with three 3D positions
  /// MultiPoint([
  ///   [10.0, 20.0, 30.0].xyz,
  ///   [12.5, 22.5, 32.5].xyz,
  ///   [15.0, 25.0, 35.0].xyz,
  /// ]);
  /// ```
  const MultiPoint(List<Position> points, {super.bounds}) : _points = points;

  /// A multi point geometry from an iterable of `Position` objects in [points].
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// The coordinate type of all points should be the same.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi point with three 2D positions
  /// MultiPoint.from([
  ///   [10.0, 20.0].xy,
  ///   [12.5, 22.5].xy,
  ///   [15.0, 25.0].xy,
  /// ]);
  ///
  /// // a multi point with three 3D positions
  /// MultiPoint.from([
  ///   [10.0, 20.0, 30.0].xyz,
  ///   [12.5, 22.5, 32.5].xyz,
  ///   [15.0, 25.0, 35.0].xyz,
  /// ]);
  /// ```
  factory MultiPoint.from(Iterable<Position> points, {Box? bounds}) =>
      MultiPoint(
        points is List<Position> ? points : points.toList(growable: false),
        bounds: bounds,
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
  /// Examples:
  ///
  /// ```dart
  /// // a multi point with three 2D positions
  /// MultiPoint.build(
  ///   [
  ///     [10.0, 20.0],
  ///     [12.5, 22.5],
  ///     [15.0, 25.0],
  ///   ],
  ///   type: Coords.xy,
  /// );
  ///
  /// // a multi point with three 3D positions
  /// MultiPoint.build(
  ///   [
  ///     [10.0, 20.0, 30.0],
  ///     [12.5, 22.5, 32.5],
  ///     [15.0, 25.0, 35.0],
  ///   ],
  ///   type: Coords.xyz,
  /// );
  /// ```
  factory MultiPoint.build(
    Iterable<Iterable<double>> points, {
    Coords type = Coords.xy,
    Box? bounds,
  }) =>
      MultiPoint(
        points
            .map(
              (pos) => Position.view(
                pos is List<double> ? pos : toFloatNNList(pos),
                type: type,
              ),
            )
            .toList(growable: false),
        bounds: bounds,
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi point from three 2D positions
  /// MultiPoint.parse(
  ///   format: GeoJSON.geometry,
  ///   '''
  ///   {
  ///     "type": "MultiPoint",
  ///     "coordinates": [[10.0,20.0],[12.5,22.5],[15.0,25.0]]
  ///   }
  ///   ''',
  /// );
  /// MultiPoint.parse(
  ///   format: WKT.geometry,
  ///   'MULTIPOINT ((10.0 20.0),(12.5 22.5),(15.0 25.0))',
  /// );
  ///
  /// // a multi point from three 3D positions
  /// MultiPoint.parse(
  ///   format: GeoJSON.geometry,
  ///   '''
  ///   {
  ///     "type": "MultiPoint",
  ///     "coordinates": [[10.0,20.0,30.0],[12.5,22.5,32.5],[15.0,25.0,35.0]]
  ///   }
  ///   ''',
  /// );
  /// MultiPoint.parse(
  ///   format: WKT.geometry,
  ///   'MULTIPOINT Z ((10.0 20.0 30.0),(12.5 22.5 32.5),(15.0 25.0 35.0))',
  /// );
  /// ```
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

  /// Parses a multi point geometry from [points] with positions formatted as
  /// texts containing coordinate values separated by [delimiter].
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and an item of [points] has 3 items, then xyz coordinates are
  /// assumed.
  ///
  /// If [swapXY] is true, then swaps x and y for all positions in the result.
  ///
  /// If [singlePrecision] is true, then coordinate values of positions are
  /// stored in `Float32List` instead of the `Float64List` (default).
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi point from three 2D positions
  /// MultiPoint.parseCoords([
  ///   '10.0,20.0',
  ///   '12.5,22.5',
  ///   '15.0,25.0',
  /// ]);
  ///
  /// // a multi point from three 3D positions
  /// MultiPoint.parseCoords([
  ///   '10.0,20.0,30.0',
  ///   '12.5,22.5,32.5',
  ///   '15.0,25.0,35.0',
  /// ]);
  ///
  /// // a multi point from three 2D positions using an alternative delimiter
  /// MultiPoint.parseCoords(
  ///   [
  ///     '10.0;20.0',
  ///     '12.5;22.5',
  ///     '15.0;25.0',
  ///   ],
  ///   delimiter: ';',
  /// );
  ///
  /// // a multi point from three 2D positions with x before y
  /// MultiPoint.parseCoords(
  ///   [
  ///     '20.0,10.0',
  ///     '22.5,12.5',
  ///     '25.0,15.0',
  ///   ],
  ///   swapXY: true,
  /// );
  ///
  /// // a multi point from three 2D positions with the internal storage using
  /// // single precision floating point numbers (`Float32List` in this case)
  /// MultiPoint.parseCoords(
  ///   [
  ///     '10.0,20.0',
  ///     '12.5,22.5',
  ///     '15.0,25.0',
  ///   ],
  ///   singlePrecision: true,
  /// );
  /// ```
  factory MultiPoint.parseCoords(
    Iterable<String> points, {
    Pattern delimiter = ',',
    Coords? type,
    bool swapXY = false,
    bool singlePrecision = false,
  }) {
    if (points.isEmpty) {
      return MultiPoint.build(const []);
    } else {
      return MultiPoint(
        points
            .map(
              (point) => parsePositionFromText(
                point,
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
  Coords get coordType => positionArrayType(positions);

  @override
  bool get isEmptyByGeometry => _points.isEmpty;

  /// The positions of all points.
  ///
  /// List items can be any [Position] objects, like `Position` itself,
  /// `Projected` or `Geographic`.
  List<Position> get positions => _points;

  /// All points as a lazy iterable of [Point] geometries.
  Iterable<Point> get points => positions.map<Point>(Point.new);

  @override
  Box? calculateBounds({PositionScheme scheme = Position.scheme}) => positions
      .map(
        (p) => scheme.box.call(
          minX: p.x,
          minY: p.y,
          minZ: p.optZ,
          minM: p.optM,
          maxX: p.x,
          maxY: p.y,
          maxZ: p.optZ,
          maxM: p.optM,
        ),
      )
      .merge();

  @override
  MultiPoint populated({
    int traverse = 0,
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was unpopulated or of other scheme
      final b = bounds;
      final empty = positions.isEmpty;
      if ((b == null && !empty) ||
          (b != null && !b.conforming.conformsWith(scheme))) {
        return MultiPoint(
          positions,
          bounds: empty ? null : calculateBounds(scheme: scheme),
        );
      }
    }
    return this;
  }

  @override
  MultiPoint unpopulated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was populated
      if (bounds != null) {
        return MultiPoint(positions);
      }
    }
    return this;
  }

  @override
  MultiPoint project(Projection projection) {
    final projected =
        positions.map((pos) => pos.project(projection)).toList(growable: false);

    return MultiPoint(projected);
  }

  @override
  double length2D() => 0.0;

  @override
  double length3D() => 0.0;

  @override
  double area2D() => 0.0;

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      isEmptyByGeometry
          ? writer.emptyGeometry(Geom.multiPoint, name: name)
          : writer.multiPoint(positions, name: name, bounds: bounds);

  // NOTE: coordinates as raw data

  @override
  bool equalsCoords(Geometry other) => testEqualsCoords<MultiPoint>(
        this,
        other,
        (mp1, mp2) => _testMultiPoints(mp1, mp2, (pos1, pos2) => pos1 == pos2),
      );

  @override
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
  }) =>
      testEquals2D<MultiPoint>(
        this,
        other,
        (mp1, mp2) => _testMultiPoints(
          mp1,
          mp2,
          (pos1, pos2) => pos1.equals2D(
            pos2,
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
      testEquals3D<MultiPoint>(
        this,
        other,
        (mp1, mp2) => _testMultiPoints(
          mp1,
          mp2,
          (pos1, pos2) => pos1.equals3D(
            pos2,
            toleranceHoriz: toleranceHoriz,
            toleranceVert: toleranceVert,
          ),
        ),
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  @override
  bool operator ==(Object other) =>
      other is MultiPoint &&
      bounds == other.bounds &&
      positions == other.positions;

  @override
  int get hashCode => Object.hash(bounds, positions);
}

bool _testMultiPoints(
  MultiPoint mp1,
  MultiPoint mp2,
  bool Function(Position, Position) testPositions,
) {
  // ensure both multi points has same amount of positions
  final p1 = mp1.positions;
  final p2 = mp2.positions;
  if (p1.length != p2.length) return false;
  // loop all positions and test coordinates
  for (var i = 0; i < p1.length; i++) {
    if (!testPositions.call(p1[i], p2[i])) {
      return false;
    }
  }
  return true;
}
