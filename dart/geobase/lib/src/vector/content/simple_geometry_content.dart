// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/codes/geom.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_series.dart';

/// A function to write simple geometry data to [output].
typedef WriteSimpleGeometries = void Function(SimpleGeometryContent output);

/// An interface to write simple geometry data to format encoders and object
/// builders.
///
/// This interface supports following "simple" geometry types introduced in the
/// [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
/// standard by [The Open Geospatial Consortium](https://www.ogc.org/): `point`,
/// `lineString`, `polygon`, `multiPoint`, `multiLineString` and `multiPolygon`.
/// It the context of this package the type `geometryCollection` is not consider
/// "simple", see `GeometryContent` for it's implementation. It's possible that
/// in future versions other geometry types are added.
abstract class SimpleGeometryContent {
  /// Writes a point geometry with [position].
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An example to write a point geometry with 2D coordinates:
  /// ```dart
  ///    // a position from a coordinate value list (x, y)
  ///    content.point([10.0, 20.0].xy);
  /// ```
  ///
  /// An example to write a point geometry with 3D coordinates:
  /// ```dart
  ///    // a position from a coordinate value list (x, y, z)
  ///    content.point([10.0, 20.0, 30.0].xyz);
  /// ```
  ///
  /// An example to write a point geometry with 2D coordinates with measurement:
  /// ```dart
  ///    // using a coordinate value list (x, y, m), need to specify type
  ///    content.point(Position.view([10.0, 20.0, 40.0], type: Coords.xym));
  /// ```
  ///
  /// An example to write a point geometry with 3D coordinates with measurement:
  /// ```dart
  ///    // using a coordinate value list (x, y, z, m)
  ///    content.point(Position.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0)]);
  /// ```
  void point(
    Position position, {
    String? name,
  });

  /// Writes a line string geometry with a [chain] of positions.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry
  /// written. A writer implementation may use it or ignore it.
  ///
  /// An example to write a line string with 3 points and a bounding box:
  /// ```dart
  ///   content.lineString(
  ///       // points as a flat structure with three (x, y) points
  ///       [
  ///            -1.1, -1.1,
  ///            2.1, -2.5,
  ///            3.5, -3.49,
  ///       ].positions(Coords.xy),
  ///       bounds: [-1.1, -3.49, 3.5, -1.1].box,
  ///   );
  /// ```
  void lineString(
    PositionSeries chain, {
    String? name,
    Box? bounds,
  });

  /// Writes a polygon geometry with one exterior and 0 to N interior [rings].
  ///
  /// The [rings] iterable must be non-empty. The first element is the exterior
  /// ring, and any other rings are interior rings (or holes). All rings must be
  /// closed linear rings. As specified by GeoJSON, they should "follow the
  /// right-hand rule with respect to the area it bounds, i.e., exterior rings
  /// are counterclockwise, and holes are clockwise".
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry
  /// written. A writer implementation may use it or ignore it.
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
  ///        ].positions(Coords.xy),
  ///      ],
  ///  );
  /// ```
  void polygon(
    Iterable<PositionSeries> rings, {
    String? name,
    Box? bounds,
  });

  /// Writes a multi point geometry with an array of [points] (each with a
  /// position).
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry
  /// written. A writer implementation may use it or ignore it.
  ///
  /// An example to write a multi point geometry with 3 points:
  /// ```dart
  ///   content.multiPoint(
  ///       [
  ///            [-1.1, -1.1].xy,
  ///            Projected(x: 2.1, y: -2.5),
  ///            Geographic(lon: 3.5, lat: -3.49),
  ///       ],
  ///   );
  /// ```
  void multiPoint(
    Iterable<Position> points, {
    String? name,
    Box? bounds,
  });

  /// Writes a multi line string with an array of [lineStrings] (each with a
  /// chain of positions).
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry
  /// written. A writer implementation may use it or ignore it.
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
  ///        ].positions(Coords.xy),
  ///        // a chain as a flat structure with three (x, y) points
  ///        [
  ///          -1.1, -1.1,
  ///          2.1, -2.5,
  ///          3.5, -3.49,
  ///        ].positions(Coords.xy),
  ///      ],
  ///  );
  /// ```
  void multiLineString(
    Iterable<PositionSeries> lineStrings, {
    String? name,
    Box? bounds,
  });

  /// Writes a multi polygon with an array of [polygons] (each with an array of
  /// rings).
  ///
  /// Each polygon is represented by `Iterable<PositionSeries>` instances
  /// containing one exterior and 0 to N interior rings. The first element is
  /// the exterior ring, and any other rings are interior rings (or holes). All
  /// rings must be closed linear rings. As specified by GeoJSON, they should
  /// "follow the right-hand rule with respect to the area it bounds, i.e.,
  /// exterior rings are counterclockwise, and holes are clockwise".
  ///
  /// Each ring in the polygon is represented by `PositionSeries` objects.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry
  /// written. A writer implementation may use it or ignore it.
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
  ///          ].positions(Coords.xy),
  ///        ],
  ///        // an array of linear rings of the second polygon
  ///        [
  ///          // a linear ring as a flat structure with four (x, y) points
  ///          [
  ///            110.1, 110.1,
  ///            15.0, 19.0,
  ///            112.0, 14.0,
  ///            110.1, 110.1,
  ///          ].positions(Coords.xy),
  ///        ],
  ///      ],
  ///  );
  /// ```
  void multiPolygon(
    Iterable<Iterable<PositionSeries>> polygons, {
    String? name,
    Box? bounds,
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
