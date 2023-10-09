// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/constants/epsilon.dart';

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

  /// True if this and [other] contain exactly same coordinate values (or both
  /// are empty) in the same order and with the same coordinate type.
  bool equalsCoords(covariant Positionable other);

  /// True if this and [other] equals by testing 2D coordinate values of all
  /// position data (that must be in same order in both objects) contained
  /// directly or by child objects.
  ///
  /// Returns false if this and [other] are not of the same subtype.
  ///
  /// Returns false if this or [other] contain "empty geometry".
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals2D(
    covariant Positionable other, {
    double toleranceHoriz = defaultEpsilon,
  });

  /// True if this and [other] equals by testing 3D coordinate values of all
  /// position data (that must be in same order in both objects) contained
  /// directly or by child objects.
  ///
  /// Returns false if this and [other] are not of the same subtype.
  ///
  /// Returns false if this or [other] contain "empty geometry".
  ///
  /// Returns false if this or [other] do not contain 3D coordinates.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Differences on vertical coordinate values (ie. z or elev) between
  /// this and [other] must be within [toleranceVert].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals3D(
    covariant Positionable other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  });
}
