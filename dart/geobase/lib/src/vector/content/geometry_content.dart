// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/coordinates/base/box.dart';

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
/// arrays of `Iterable<double>`.
mixin GeometryContent implements SimpleGeometryContent {
  /// Writes a geometry collection from the content provided by [geometries].
  /// 
  /// An optional [type] specifies the coordinate type of geometry objects in a
  /// collection. When not provided, the type can be resolved from objects.
  ///
  /// An optional expected [count], when given, specifies the number of geometry
  /// objects in a collection. Note that when given the count MUST be exact.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry
  /// written. A writer implementation may use it or ignore it.
  ///
  /// An example to write a geometry collection with two child geometries:
  /// ```dart
  ///   content.geometryCollection(
  ///       type: Coords.xy
  ///       count: 2,
  ///       (geom) => geom
  ///         ..point([10.123, 20.25].xy)
  ///         ..polygon(
  ///           [
  ///              [
  ///                 10.1, 10.1,
  ///                 5.0, 9.0,
  ///                 12.0, 4.0,
  ///                 10.1, 10.1,
  ///              ].positions(Coords.xy),
  ///           ],
  ///         ),
  ///     );
  /// ```
  void geometryCollection(
    WriteGeometries geometries, {
    Coords? type,
    int? count,
    String? name,
    Box? bounds,
  });
}
