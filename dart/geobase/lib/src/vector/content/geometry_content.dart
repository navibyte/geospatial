// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'simple_geometry_content.dart';

/// A function to write geometry data to [output].
typedef WriteGeometries = void Function(GeometryContent output);

/// An interface to write geometry data to format encoders and object builders.
///
/// This mixin supports specific simple geometry types defined by
/// [SimpleGeometryContent] and geometry collections. It's possible that in
/// future versions other geometry types are added.
///
/// Coordinate positions, position arrays and bounding boxes are represented as
/// coordinate value arrays of `Iterable<double>`.
mixin GeometryContent implements SimpleGeometryContent {
  /// Writes a geometry collection from the content provided by [geometries].
  ///
  /// An optional expected [count], when given, specifies the number of geometry
  /// objects in a collection. Note that when given the count MUST be exact.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry
  /// written. A writer implementation may use it or ignore it. Supported
  /// coordinate value combinations by coordinate type:
  ///
  /// Type | Expected values
  /// ---- | ---------------
  /// xy   | minX, minY, maxX, maxY
  /// xyz  | minX, minY, minZ, maxX, maxY, maxZ
  /// xym  | minX, minY, minM, maxX, maxY, maxM
  /// xyzm | minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
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
    Iterable<double>? bounds,
  });
}
