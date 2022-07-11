// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/coordinates/base.dart';
import '/src/coordinates/geographic.dart';
import '/src/coordinates/projected.dart';

/// An interface to write coordinate data to format encoders and object
/// builders.
///
/// Coordinate positions are represented either as [Position] or
/// `Iterable<num>`. Bounding boxes are represented either as [Box] or
/// `Iterable<num>`.
mixin CoordinateContent {
  /// Writes a bounding box represented by [bbox] of [Box] or `Iterable<num>`.
  ///
  /// Known [Box] sub classes are [ProjBox] (projected or cartesian coordinates)
  /// and [GeoBox] (geographic coordinates). Other sub classes are supported
  /// too.
  ///
  /// Supported coordinate value combinations by coordinate type for 
  /// `Iterable<num>` are:
  ///
  /// Type | Expected values
  /// ---- | ---------------
  /// xy   | minX, minY, maxX, maxY
  /// xyz  | minX, minY, minZ, maxX, maxY, maxZ
  /// xym  | minX, minY, minM, maxX, maxY, maxM
  /// xyzm | minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and an iterable has 6 items, then xyz coordinates are assumed.
  ///
  /// An example with 2D coordinates:
  /// ```dart
  ///    // using coordinate value list (minX, minY, maxX, maxY)
  ///    content.box([10, 10, 20, 20]);
  ///
  ///    // using the type for bounding box with projected coordinates
  ///    // (same coordinates with the previous example)
  ///    content.box(
  ///       const ProjBox(minX: 10, minY: 10, maxX: 20, maxY: 20));
  ///
  ///    // using the type for bounding box with geographic coordinates
  ///    // (between -20.0 .. 20.0 in longitude, 50.0 .. 60.0 in latitude)
  ///    content.box(
  ///       const GeoBox(west: -20, south: 50, east: 20, north: 60));
  /// ```
  void box(Object bbox, {Coords? type});

  /// Writes a single position represented by [coordinates] of [Position] or
  /// `Iterable<num>`.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Other sub classes
  /// are supported too.
  ///
  /// Supported coordinate value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m). Use an optional [type] to 
  /// explicitely set the coordinate type. If not provided and an iterable has
  /// 3 items, then xyz coordinates are assumed.
  ///
  /// An example with 2D coordinates:
  /// ```dart
  ///    // using coordinate value list (x, y)
  ///    content.position([10, 20]);
  ///
  ///    // using the type for positions with projected coordinates
  ///    // (same coordinates with the previous example)
  ///    content.position(const Projected(x: 10, y: 20));
  /// ```
  ///
  /// An example with 3D coordinates:
  /// ```dart
  ///    // using coordinate value list (x, y, z)
  ///    content.position([10, 20, 30]);
  ///
  ///    // using the type for positions with geographic coordinates
  ///    content.position(const Geographic(lon: 10, lat: 20, elev: 30));
  /// ```
  ///
  /// An example with 2D coordinates with measurement:
  /// ```dart
  ///    // using coordinate value list (x, y, m), need to specify type
  ///    content.position([10, 20, 40], type: Coords.xym);
  /// 
  ///    // using the type for positions with projected coordinates
  ///    content.position(const Projected(x: 10, y: 20, m: 40));
  /// ```
  ///
  /// An example with 3D coordinates with measurement:
  /// ```dart
  ///    // using coordinate value list (x, y, z, m)
  ///    content.position([10, 20, 30, 40]);
  ///
  ///    // using the type for positions with projected coordinates
  ///    content.position(const Projected(x: 10, y: 20, z: 30, m: 40));
  /// ```
  void position(Object coordinates, {Coords? type});

  /// Writes a series of positions represented by [coordinates].
  ///
  /// The [coordinates] iterable is an array containing `Object` items.
  /// Supported sub classes for items are [Position] and `Iterable<num>`.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Other sub classes
  /// are supported too.
  ///
  /// Supported coordinate value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m). Use an optional [type] to 
  /// explicitely set the coordinate type. If not provided and an iterable has
  /// 3 items, then xyz coordinates are assumed.
  ///
  /// An example
  /// ```dart
  ///      // using list of coordinate value lists
  ///      content.positions([
  ///           [10.123, 20.25],
  ///           [10.123, 20.25, -30.95, -1.999],
  ///           [10.123, 20.25],
  ///         ]);
  ///
  ///      // using list of position objects
  ///      content.positions([
  ///           const Projected(x: 10.123, y: 20.25),
  ///           const Projected(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
  ///           const Projected(x: 10.123, y: 20.25),
  ///         ]);
  /// ```
  void positions(Iterable<Object> coordinates, {Coords? type});
}
