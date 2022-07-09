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
/// Coordinate positions are represented either as [Position] or
/// `Iterable<num>`. Bounding boxes are represented either as [Box] or
/// `Iterable<num>`.
abstract class SimpleGeometryContent {
  /// Writes a point geometry with a position from [coordinates].
  ///
  /// The [coordinates] represents a single position of [Position] or
  /// `Iterable<num>`.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Other sub classes
  /// are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Examples to write a point geometry with 2D coordinates:
  /// ```dart
  ///    // using coordinate value list (x, y)
  ///    content.point([10, 20]);
  /// 
  ///    // using the type for positions with projected coordinates
  ///    // (same coordinates with the previous example)
  ///    content.point(const Projected(x: 10, y: 20));
  /// ```
  /// 
  /// Examples to write a point geometry with 3D coordinates:
  /// ```dart
  ///    // using coordinate value list (x, y, z)
  ///    content.point([10, 20, 30]);
  /// 
  ///    // using the type for positions with geographic coordinates
  ///    content.point(const Geographic(lon: 10, lat: 20, elev: 30));
  /// ```
  /// 
  /// An example to write a point geometry with 2D coordinates with measurement:
  /// ```dart
  ///    // using the type for positions with projected coordinates
  ///    content.point(const Projected(x: 10, y: 20, m: 40));
  /// ```
  /// 
  /// Examples to write a point geometry with 3D coordinates with measurement:
  /// ```dart
  ///    // using coordinate value list (x, y, z, m)
  ///    content.point([10, 20, 30, 40]);
  /// 
  ///    // using the type for positions with projected coordinates
  ///    content.point(const Projected(x: 10, y: 20, z: 30, m: 40));
  /// ```
  void point(
    Object coordinates, {
    String? name,
    Coords? type,
  });

  /// Writes a line string geometry with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array containing `Object` items
  /// representing positions of points in a line string. Supported sub classes
  /// for items are [Position] and `Iterable<num>`.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates.
  ///
  /// An optional [bbox] of [Box] or `Iterable<num>` can used set a minimum
  /// bounding box for a geometry written. A writer implementation may use it or
  /// ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates). Other sub classes are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// An example to write a line string with 3 points and a bounding box:
  /// ```dart
  ///   content.lineString(
  ///       [
  ///            [-1.1, -1.1],
  ///            [2.1, -2.5],
  ///            [3.5, -3.49],
  ///       ],
  ///       bbox: [-1.1, -3.49, 3.5, -1.1],
  ///   );
  /// ```
  void lineString(
    Iterable<Object> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  });

  /// Writes a polygon geometry with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array of arrays containing `Object` items
  /// representing positions of points in linear rings (outer and inner) of a
  /// polygon. Supported sub classes for items are [Position] and
  /// `Iterable<num>`.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates.
  ///
  /// An optional [bbox] of [Box] or `Iterable<num>` can used set a minimum
  /// bounding box for a geometry written. A writer implementation may use it or
  /// ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates). Other sub classes are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// An example to write a polygon geometry with one linear ring containing
  /// 4 points:
  /// ```dart
  ///  content.polygon(
  ///      [
  ///        [
  ///          [10.1, 10.1],
  ///          [5, 9],
  ///          [12, 4],
  ///          [10.1, 10.1],
  ///        ],
  ///      ],
  ///  );
  /// ```
  void polygon(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  });

  /// Writes a multi point geometry with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array containing `Object` items
  /// representing positions of points in a multi point collection. Supported
  /// sub classes for items are [Position] and `Iterable<num>`.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates.
  ///
  /// An optional [bbox] of [Box] or `Iterable<num>` can used set a minimum
  /// bounding box for a geometry written. A writer implementation may use it or
  /// ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates). Other sub classes are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// An example to write a multi point geometry with 3 points:
  /// ```dart
  ///   content.multiPoint(
  ///       [
  ///            [-1.1, -1.1],
  ///            [2.1, -2.5],
  ///            [3.5, -3.49],
  ///       ],
  ///   );
  /// ```
  void multiPoint(
    Iterable<Object> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  });

  /// Writes a multi line string with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array of arrays containing `Object` items
  /// representing positions of points in line strings of a multi line string
  /// collection. Supported sub classes for items are [Position] and
  /// `Iterable<num>`.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates.
  ///
  /// An optional [bbox] of [Box] or `Iterable<num>` can used set a minimum
  /// bounding box for a geometry written. A writer implementation may use it or
  /// ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates). Other sub classes are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// An example to write a multi line string with two line strings:
  /// ```dart
  ///  content.multiLineString(
  ///      [
  ///        [
  ///          [10.1, 10.1],
  ///          [5, 9],
  ///          [12, 4],
  ///          [10.1, 10.1],
  ///        ],
  ///        [
  ///          [-1.1, -1.1],
  ///          [2.1, -2.5],
  ///          [3.5, -3.49],
  ///        ],
  ///      ],
  ///  );
  /// ```
  void multiLineString(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  });

  /// Writes a multi polygon geometry with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array of arrays of arrays containing
  /// `Object` items representing positions of points in linear rings (outer and
  /// inner) of polygons in a multi polygon collection. Supported sub classes
  /// for items are [Position] and `Iterable<num>`.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates.
  ///
  /// An optional [bbox] of [Box] or `Iterable<num>` can used set a minimum
  /// bounding box for a geometry written. A writer implementation may use it or
  /// ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates). Other sub classes are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// An example to write a multi polygon geometry with two polygons:
  /// ```dart
  ///  content.multiPolygon(
  ///      [
  ///        [
  ///          [
  ///            [10.1, 10.1],
  ///            [5, 9],
  ///            [12, 4],
  ///            [10.1, 10.1],
  ///          ],
  ///        ],
  ///        [
  ///          [
  ///            [110.1, 110.1],
  ///            [15, 19],
  ///            [112, 14],
  ///            [110.1, 110.1],
  ///          ],
  ///        ],
  ///      ],
  ///  );
  /// ```
  void multiPolygon(
    Iterable<Iterable<Iterable<Object>>> coordinates, {
    String? name,
    Coords? type,
    Object? bbox,
  });

  /// Writes a geometry collection of [geometries].
  ///
  /// An optional expected [count], when given, specifies the number of geometry
  /// objects in a collection. Note that when given a count MUST be exact.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates.
  ///
  /// An optional [bbox] of [Box] or `Iterable<num>` can used set a minimum
  /// bounding box for a geometry written. A writer implementation may use it or
  /// ignore it.
  ///
  /// Known [Box] sub classes are [ProjBox] (projected or cartesian coordinates)
  /// and [GeoBox] (geographic coordinates). Other sub classes are supported
  /// too.
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// An example to write a geometry collection with two child geometries:
  /// ```dart
  ///   content.geometryCollection(
  ///       count: 2,
  ///       (geom) => geom
  ///         ..point([10.123, 20.25, -30.95], type: Coords.xyz)
  ///         ..polygon(
  ///           [
  ///             [
  ///               const Geographic(lon: 10.1, lat: 10.1),
  ///               const Geographic(lon: 5, lat: 9),
  ///               const Geographic(lon: 12, lat: 4),
  ///               const Geographic(lon: 10.1, lat: 10.1)
  ///             ],
  ///           ],
  ///         ),
  ///     );
  /// ```
  void geometryCollection(
    WriteSimpleGeometries geometries, {
    int? count,
    String? name,
    Coords? type,
    Object? bbox,
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
