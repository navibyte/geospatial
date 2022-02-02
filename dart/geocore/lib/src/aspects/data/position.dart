// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'positionable.dart';

/// A read-only position with [x], [y], [z] and [m] coordinate values.
///
/// All concrete implementations must contain at least [x] and [y] coordinate 
/// values, but [z] and [m] coordinates are optional (getters should return `0`
/// value when such a coordinate axis is not available).
///
/// When a position contains geographic coordinates, then by default [x]
/// represents *longitude*, [y] represents *latitude*, and [z] represents
/// *elevation* (or *height* or *altitude*).
///
/// A projected map position might be defined as *easting* (E) and *northing*
/// (N) coordinates. It's suggested that then E == [x] and N == [y], but a
/// coordinate reference system might specify something else too.
///
/// [m] represents a measurement or a value on a linear referencing system (like
/// time). It could be associated with a 2D position (x, y, m) or a 3D position
/// (x, y, z, m).
abstract class Position extends Positionable {
  /// The x coordinate.
  ///
  /// For geographic coordinates x represents *longitude*.
  num get x;

  /// The y coordinate.
  ///
  /// For geographic coordinates y represents *latitude*.
  num get y;

  /// The z coordinate. Returns zero (`0`) if not available.
  /// 
  /// Use [is3D] to check whether z coordinate is available.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  num get z;

  /// The m ("measure") coordinate. Returns zero (`0`)  if not available.
  /// 
  /// Use [isMeasured] to check whether m coordinate is available.
  ///
  /// [m] represents a measurement or a value on a linear referencing system
  /// (like time). It could be associated with a 2D position (x, y, m) or a 3D
  /// position (x, y, z, m).
  num get m;
}
