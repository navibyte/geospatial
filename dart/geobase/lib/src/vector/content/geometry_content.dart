// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/base.dart';

import 'simple_geometry_content.dart';

/// A function to write geometry data to [output].
typedef WriteGeometries = void Function(GeometryContent output);

/// An interface to write geometry data to format encoders and object builders.
///
/// This mixin supports specific simple geometry types defined by
/// [SimpleGeometryContent] and geometry collections. It's possible that in
/// future versions other geometry types are added.
///
/// Coordinate positions and position arrays are represented as coordinate value
/// arrays of `Iterable<double>`. Bounding boxes are represented as [Box].
mixin GeometryContent implements SimpleGeometryContent {
  /// Writes a geometry collection from the content provided by [geometries].
  ///
  /// An optional expected [count], when given, specifies the number of geometry
  /// objects in a collection. Note that when given the count MUST be exact.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bounds] of [Box] can used set a minimum bounding box for a
  /// geometry written. A writer implementation may use it or ignore it. Known
  /// [Box] sub classes are `ProjBox` (projected or cartesian coordinates) and
  /// `GeoBox` (geographic coordinates). Other sub classes are supported too.
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
    WriteGeometries geometries, {
    int? count,
    String? name,
    Box? bounds,
  });
}
