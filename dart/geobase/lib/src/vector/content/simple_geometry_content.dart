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
  /// Use an optional [type] to explicitely specify the type of coordinates. If
  /// not provided and an iterable has 3 items, then xyz coordinates are
  /// assumed.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// Supported coordinate value combinations for `Iterable<double>` are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
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

  /// Writes a line string geometry with a [chain] of positions.
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

  /// Writes a polygon geometry with one exterior and 0 to N interior [rings].
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
  ///
  /// Each ring in the polygon is represented by `Iterable<double>` arrays. Such
  /// arrays contain coordinate values as a flat structure. For example for
  /// `Coords.xyz` the first three coordinate values are x, y and z of the first
  /// position, the next three coordinate values are x, y and z of the second
  /// position, and so on.
  ///
  /// The [rings] iterable must be non-empty. The first element is the exterior
  /// ring, and any other rings are interior rings (or holes). All rings must be
  /// closed linear rings. As specified by GeoJSON, they should "follow the
  /// right-hand rule with respect to the area it bounds, i.e., exterior rings
  /// are counterclockwise, and holes are clockwise".
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

  /// Writes a multi point geometry with a series of [points] (each with a
  /// position).
  ///
  /// Use the required [type] to explicitely set the coordinate type.
  ///
  /// Each point is represented by `Iterable<double>` instances. Supported
  /// coordinate value combinations for positions are: (x, y), (x, y, z),
  /// (x, y, m) and (x, y, z, m).
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
    Iterable<Iterable<double>> points, {
    required Coords type,
    String? name,
    Box? bbox,
  });

  /// Writes a multi line string with a series of [lineStrings] (each with a
  /// chain of positions).
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
  ///
  /// Each line string or a chain of positions is represented by
  /// `Iterable<double>` instances. They contain coordinate values as a flat
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
    Iterable<Iterable<double>> lineStrings, {
    required Coords type,
    String? name,
    Box? bbox,
  });

  /// Writes a multi polygon with a series of [polygons] (each with a series of
  /// rings).
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
  ///
  /// Each polygon is represented by `Iterable<Iterable<double>>` instances
  /// containing one exterior and 0 to N interior rings. The first element is
  /// the exterior ring, and any other rings are interior rings (or holes). All
  /// rings must be closed linear rings. As specified by GeoJSON, they should
  /// "follow the right-hand rule with respect to the area it bounds, i.e.,
  /// exterior rings are counterclockwise, and holes are clockwise".
  ///
  /// Each ring in the polygon is represented by `Iterable<double>` arrays. Such
  /// arrays contain coordinate values as a flat structure. For example for
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
    Iterable<Iterable<Iterable<double>>> polygons, {
    required Coords type,
    String? name,
    Box? bbox,
  });

  /// Writes a geometry collection from the content stream provided by
  /// [geometries].
  ///
  /// Use an optional [type] to give a hint of type of coordinates in
  /// geometries. However, sub geometries provided by [geometries] may set
  /// another types too.
  ///
  /// An optional expected [count], when given, specifies the number of geometry
  /// objects in a collection. Note that when given the count MUST be exact.
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
