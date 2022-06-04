// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'positionable.dart';

/// A base interface for 2D geospatial positions with (x, y) or (lon, lat).
abstract class Position2 extends Positionable {
  /// Default `const` constructor to allow extending this abstract class.
  const Position2();

  /// The x coordinate value.
  ///
  /// For geographic coordinates x represents *longitude*.
  num get x;

  /// The y coordinate value.
  ///
  /// For geographic coordinates y represents *latitude*.
  num get y;

  /// A coordinate value by the coordinate axis index [i].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y).
  ///
  /// For geographic coordinates, the coordinate ordering is: (lon, lat).
  num operator [](int i);

  /// Coordinate values of this position as an iterable of 2, 3 or 4 items.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y).
  ///
  /// For geographic coordinates, the coordinate ordering is: (lon, lat).
  Iterable<num> get values;

  /// True if this position equals with [other] by testing 2D coordinates only.
  ///
  /// If [toleranceHoriz] is given, then differences on 2D coordinate values
  /// (ie. x and y, or lon and lat) between this and [other] must be within
  /// tolerance. Otherwise value must be exactly same.
  ///
  /// Tolerance values must be null or positive (>= 0).
  bool equals2D(covariant Position2 other, {num? toleranceHoriz});
}
