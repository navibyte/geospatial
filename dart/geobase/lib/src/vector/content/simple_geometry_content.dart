// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/coordinates/base.dart';
import '/src/coordinates/geographic.dart';
import '/src/coordinates/projected.dart';

/// A function to write simple geometry data to [output].
typedef WriteSimpleGeometries = void Function(SimpleGeometryContent output);

/// An interface to write simple geometry data to format encoders and object
/// builders.
///
/// This interface supports following "simple" geometry types introduced in the
/// [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
/// standard by [The Open Geospatial Consortium](https://www.ogc.org/): `point`,
/// `lineString`, `polygon`, `multiPoint`, `multiLineString`, `multiPolygon`,
/// `geometryCollection`.
///
/// Coordinate positions and position arrays are represented as coordinate value
/// arrays of `Iterable<double>`. Bounding boxes are represented as [Box].
abstract class SimpleGeometryContent {
  /// Writes a point geometry with [position].
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// Supported coordinate value combinations for `Iterable<double>` are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m). Use an optional [type] to
  /// explicitely set the coordinate type. If not provided and an iterable has
  /// 3 items, then xyz coordinates are assumed.
  ///
  /// An example to write a point geometry with 2D coordinates:
  /// ```dart
  ///    // using a coordinate value list (x, y)
  ///    content.point([10, 20]);
  /// ```
  ///
  /// An example to write a point geometry with 3D coordinates:
  /// ```dart
  ///    // using a coordinate value list (x, y, z)
  ///    content.point([10, 20, 30]);
  /// ```
  ///
  /// An example to write a point geometry with 2D coordinates with measurement:
  /// ```dart
  ///    // using a coordinate value list (x, y, m), need to specify type
  ///    content.position([10, 20, 40], type: Coords.xym);
  /// ```
  ///
  /// An example to write a point geometry with 3D coordinates with measurement:
  /// ```dart
  ///    // using a coordinate value list (x, y, z, m)
  ///    content.point([10, 20, 30, 40]);
  /// ```
  void point(
    Iterable<double> position, {
    Coords? type,
    String? name,
  });

  /// Writes a line string geometry with a position array from [chain].
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
  ///
  /// The [chain] array contains coordinate values of chain positions as a flat
  /// structure. For example for `Coords.xyz` the first three coordinate values
  /// are x, y and z of the first position, the next three coordinate values are
  /// x, y and z of the second position, and so on.
  /// 
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bbox] of [Box] can used set a minimum bounding box for a
  /// geometry written. A writer implementation may use it or ignore it. Known
  /// [Box] sub classes are [ProjBox] (projected or cartesian coordinates) and
  /// [GeoBox] (geographic coordinates). Other sub classes are supported too.
  ///
  /// An example to write a line string with 3 points and a bounding box:
  /// ```dart
  ///   content.lineString(
  ///       // points as a flat structure with three (x, y) points
  ///       [
  ///            -1.1, -1.1,
  ///            2.1, -2.5,
  ///            3.5, -3.49,
  ///       ],
  ///       type: Coords.xy,
  ///       bbox: Box(minX: -1.1, minY: -3.49, maxX: 3.5, maxY: -1.1),
  ///   );
  /// ```
  void lineString(
    Iterable<double> chain, {
    required Coords type,
    String? name,
    Box? bbox,
  });

  /// Writes a polygon geometry with a position array from [rings].
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
  ///
  /// The [rings] iterable is an array of arrays containing coordinate values of
  /// linear rings (outer and inner) of a polygon as a flat structure. For
  /// example for `Coords.xyz` the first three coordinate values are x, y and z
  /// of the first position, the next three coordinate values are x, y and z of
  /// the second position, and so on.
  /// 
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bbox] of [Box] can used set a minimum bounding box for a
  /// geometry written. A writer implementation may use it or ignore it. Known
  /// [Box] sub classes are [ProjBox] (projected or cartesian coordinates) and
  /// [GeoBox] (geographic coordinates). Other sub classes are supported too.
  ///
  /// An example to write a polygon geometry with one linear ring containing
  /// 4 points:
  /// ```dart
  ///  content.polygon(
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
  void polygon(
    Iterable<Iterable<double>> rings, {
    required Coords type,
    String? name,
    Box? bbox,
  });

  /// Writes a multi point geometry with a position array from [positions].
  ///
  /// Use the required [type] to explicitely set the coordinate type. 
  /// 
  /// The [positions] iterable is an array containing `Iterable<double>` items
  /// each representing a position. Supported coordinate value combinations for
  /// positions are: (x, y), (x, y, z), (x, y, m) and (x, y, z, m). 
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bbox] of [Box] can used set a minimum bounding box for a
  /// geometry written. A writer implementation may use it or ignore it. Known
  /// [Box] sub classes are [ProjBox] (projected or cartesian coordinates) and
  /// [GeoBox] (geographic coordinates). Other sub classes are supported too.
  ///
  /// An example to write a multi point geometry with 3 points:
  /// ```dart
  ///   content.multiPoint(
  ///       [
  ///            [-1.1, -1.1],
  ///            [2.1, -2.5],
  ///            [3.5, -3.49],
  ///       ],
  ///       type: Coords.xy,
  ///   );
  /// ```
  void multiPoint(
    Iterable<Iterable<double>> positions, {
    required Coords type,
    String? name,
    Box? bbox,
  });

  /// Writes a multi line string with a position array from [chains].
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
  ///
  /// The [chains] iterable is an array of arrays containing coordinate values
  /// of chains in a multi line string as a flat structure. For example for
  /// `Coords.xyz` the first three coordinate values are x, y and z of the first
  /// position, the next three coordinate values are x, y and z of the second
  /// position, and so on.
  /// 
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bbox] of [Box] can used set a minimum bounding box for a
  /// geometry written. A writer implementation may use it or ignore it. Known
  /// [Box] sub classes are [ProjBox] (projected or cartesian coordinates) and
  /// [GeoBox] (geographic coordinates). Other sub classes are supported too.
  ///
  /// An example to write a multi line string with two line strings:
  /// ```dart
  ///  content.multiLineString(
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
  void multiLineString(
    Iterable<Iterable<double>> chains, {
    required Coords type,
    String? name,
    Box? bbox,
  });

  /// Writes a multi polygon geometry with a position array from [ringsArray].
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
  ///
  /// The [ringsArray] iterable is an array of arrays of arrays containing
  /// coordinate values of linear rings (outer and inner) of a polygon as a
  /// flat structure. For example for `Coords.xyz` the first three coordinate
  /// values are x, y and z of the first position, the next three coordinate
  /// values are x, y and z of the second position, and so on.
  /// 
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bbox] of [Box] can used set a minimum bounding box for a
  /// geometry written. A writer implementation may use it or ignore it. Known
  /// [Box] sub classes are [ProjBox] (projected or cartesian coordinates) and
  /// [GeoBox] (geographic coordinates). Other sub classes are supported too.
  ///
  /// An example to write a multi polygon geometry with two polygons:
  /// ```dart
  ///  content.multiPolygon(
  ///      // an array of polygons
  ///      [
  ///        // an array of linear rings of the first polygon
  ///        [
  ///          // a linear ring as a flat structure with four (x, y) points
  ///          [
  ///            10.1, 10.1,
  ///            5.0, 9.0,
  ///            12.0, 4.0,
  ///            10.1, 10.1,
  ///          ],
  ///        ],
  ///        // an array of linear rings of the second polygon
  ///        [
  ///          // a linear ring as a flat structure with four (x, y) points
  ///          [
  ///            110.1, 110.1,
  ///            15.0, 19.0,
  ///            112.0, 14.0,
  ///            110.1, 110.1,
  ///          ],
  ///        ],
  ///      ],
  ///  );
  /// ```
  void multiPolygon(
    Iterable<Iterable<Iterable<double>>> ringsArray, {
    required Coords type,
    String? name,
    Box? bbox,
  });

  /// Writes a geometry collection of [geometries].
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates.
  ///
  /// An optional expected [count], when given, specifies the number of geometry
  /// objects in a collection. Note that when given a count MUST be exact.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bbox] of [Box] can used set a minimum bounding box for a
  /// geometry written. A writer implementation may use it or ignore it. Known
  /// [Box] sub classes are [ProjBox] (projected or cartesian coordinates) and
  /// [GeoBox] (geographic coordinates). Other sub classes are supported too.
  ///
  /// An example to write a geometry collection with two child geometries:
  /// ```dart
  ///   content.geometryCollection(
  ///       type: Coords.xy
  ///       count: 2,
  ///       (geom) => geom
  ///         ..point([10.123, 20.25])
  ///         ..polygon(
  ///           [
  ///              [
  ///                 10.1, 10.1,
  ///                 5.0, 9.0,
  ///                 12.0, 4.0,
  ///                 10.1, 10.1,
  ///              ],
  ///           ],
  ///           type: Coords.xy,
  ///         ),
  ///     );
  /// ```
  void geometryCollection(
    WriteSimpleGeometries geometries, {
    Coords? type,
    int? count,
    String? name,
    Box? bbox,
  });

  /// Writes an empty geometry of [type].
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Note: normally it might be a good idea to avoid "empty geometries" as
  /// those are encoded and decoded with different ways in different formats.
  ///
  /// An example to write an "empty" point:
  /// ```dart
  ///   content.emptyGeometry(Geom.point);
  /// ```
  void emptyGeometry(Geom type, {String? name});
}
