// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'position.dart';
import 'positionable.dart';

/// A base interface for axis-aligned bounding boxes with min & max coordinates.
///
/// This interface defines min and max coordinate values only for the m axis.
/// Sub classes define min and max coordinate values for other axes (x, y and z
/// in projected coordinate systems, and longitude, latitude and elevation in
/// geographic coordinate systems).
///
/// The known sub classes are `ProjBox` (with minX, minY, minZ, minM, maxX,
/// maxY, maxZ and maxM coordinates) and `GeoBox` (with west, south, minElev,
/// minM, east, north, maxElev and maxM coordinates)
abstract class Box extends Positionable {
  /// Default `const` constructor to allow extending this abstract class.
  const Box();

  /// The minimum m coordinate optionally. Returns null if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available.
  num? get minM;

  /// The maximum m coordinate optionally. Returns null if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available.
  num? get maxM;

  /// The minimum position (or west-south) of this bounding box.
  Position get min;

  /// The maximum position (or east-north) of this bounding box.
  Position get max;

  /// Returns all distinct (in 2D) corners for this axis aligned bounding box.
  ///
  /// May return 1 (when `min == max`), 2 (when either or both 2D coordinates
  /// equals between min and max) or 4 positions (otherwise).
  Iterable<Position> get corners2D;

  /// True if this box equals with [other] by testing 2D coordinates only.
  ///
  /// If [toleranceHoriz] is given, then differences on 2D coordinate values
  /// (ie. x and y, or lon and lat) between this and [other] must be within
  /// tolerance. Otherwise value must be exactly same.
  ///
  /// Tolerance values must be null or positive (>= 0).
  bool equals2D(Box other, {num? toleranceHoriz});

  /// True if this box equals with [other] by testing 3D coordinates only.
  ///
  /// Returns false if this or [other] is not a 3D box.
  ///
  /// If [toleranceHoriz] is given, then differences on 2D coordinate values
  /// (ie. x and y, or lon and lat) between this and [other] must be within
  /// tolerance. Otherwise value must be exactly same.
  ///
  /// The tolerance for vertical coordinate values (ie. z or elev) is given by
  /// an optional [toleranceVert] value.
  ///
  /// Tolerance values must be null or positive (>= 0).
  bool equals3D(
    Box other, {
    num? toleranceHoriz,
    num? toleranceVert,
  });
}
