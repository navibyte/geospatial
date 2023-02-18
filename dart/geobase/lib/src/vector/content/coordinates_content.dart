// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/base.dart';

/// An interface to write coordinate data to format encoders and object
/// builders.
///
/// Coordinate positions are represented either as [Position] and bounding boxes
/// are represented either as [Box].
mixin CoordinateContent {
  /// Writes a bounding box represented by [bounds] of [Box].
  ///
  /// Known [Box] sub classes are `ProjBox` (projected or cartesian coordinates)
  /// and `GeoBox` (geographic coordinates). Other sub classes are supported
  /// too.
  ///
  /// An example with 2D coordinates:
  /// ```dart
  ///    // a bounding box with projected coordinates
  ///    content.box(
  ///       const ProjBox(minX: 10, minY: 10, maxX: 20, maxY: 20));
  ///
  ///    // a bounding box with with geographic coordinates
  ///    // (between -20.0 .. 20.0 in longitude, 50.0 .. 60.0 in latitude)
  ///    content.box(
  ///       const GeoBox(west: -20, south: 50, east: 20, north: 60));
  /// ```
  void bounds(Box bounds);

  /// Writes a single position represented by [coordinates] of [Position].
  ///
  /// Known [Position] sub classes are `Projected` (projected or cartesian
  /// coordinates) and `Geographic` (geographic coordinates). Other sub classes
  /// are supported too.
  ///
  /// An example with 2D coordinates:
  /// ```dart
  ///    // a position with projected coordinates
  ///    content.position(const Projected(x: 10, y: 20));
  /// ```
  ///
  /// An example with 3D coordinates:
  /// ```dart
  ///    // a position with geographic coordinates
  ///    content.position(const Geographic(lon: 10, lat: 20, elev: 30));
  /// ```
  ///
  /// An example with 2D coordinates with measurement:
  /// ```dart
  ///    // a position with projected coordinates
  ///    content.position(const Projected(x: 10, y: 20, m: 40));
  /// ```
  ///
  /// An example with 3D coordinates with measurement:
  /// ```dart
  ///    // a position with projected coordinates
  ///    content.position(const Projected(x: 10, y: 20, z: 30, m: 40));
  /// ```
  void position(Position coordinates);

  /// Writes an array of [Position] items represented by [coordinates].
  ///
  /// Known [Position] sub classes are `Projected` (projected or cartesian
  /// coordinates) and `Geographic` (geographic coordinates). Other sub classes
  /// are supported too.
  ///
  /// An example:
  /// ```dart
  ///      content.positions([
  ///           const Projected(x: 10.123, y: 20.25),
  ///           const Projected(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
  ///           const Projected(x: 10.123, y: 20.25),
  ///         ]);
  /// ```
  void positions(Iterable<Position> coordinates);
}
