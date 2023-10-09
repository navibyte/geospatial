// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';

/// A positionable object contains data structures for (geospatial) position
/// data, directly or within child objects.
///
/// This interface is extended at least by `ValuePositionable` (with coordinate
/// values directly available) and `Bounded` (objects with position data and
/// methods to resolve bounding boxes).
abstract class Positionable {
  /// Default `const` constructor to allow extending this abstract class.
  const Positionable();

  /// A value of [Coords] representing the coordinate type of position data
  /// contained directly or within child objects.
  ///
  /// For objects containing position data directly, the coordinate type is the
  /// type indicated by such data. For example for geometries containing 2D
  /// coordinates it's `Coords.xy` or for geometries containg 3D data, it's
  /// `Coords.xyz`.
  ///
  /// For objects that are containers for other positionable objects, the
  /// returned type is such that it's valid for all items contained. For example
  /// if a collection has items with types `Coords.xy`, `Coords.xyz` and
  /// `Coords.xym`, then `Coords.xy` is returned. When all items are
  /// `Coords.xyz`, then `Coords.xyz` is returned.
  Coords get coordType;
}
