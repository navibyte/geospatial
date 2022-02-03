// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/codes.dart';

import 'positionable.dart';

/// A position with [x], [y], and optional [z] and [m] coordinate values.
///
/// All implementations must contain at least [x] and [y] coordinate values, but
/// [z] and [m] coordinates are optional (getters should return zero value when
/// such a coordinate axis is not available).
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
class Position extends Positionable {
  /// A position with [x], [y], and optional [z] and [m] coordinates.
  const Position({required num x, required num y, num? z, num? m})
      : _x = x,
        _y = y,
        _z = z,
        _m = m;

  final num _x;
  final num _y;
  final num? _z;
  final num? _m;

  /// The x coordinate value.
  ///
  /// For geographic coordinates x represents *longitude*.
  num get x => _x;

  /// The y coordinate value.
  ///
  /// For geographic coordinates y represents *latitude*.
  num get y => _y;

  /// The z coordinate value. Returns zero if not available.
  ///
  /// Use [is3D] to check whether z coordinate is available.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  num get z => _z ?? 0;

  /// The z coordinate value optionally. Returns null if not available.
  ///
  /// Use [is3D] to check whether z coordinate is available.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  num? get optZ => _z;

  /// The m ("measure") coordinate value. Returns zero if not available.
  ///
  /// Use [isMeasured] to check whether m coordinate is available.
  ///
  /// [m] represents a measurement or a value on a linear referencing system
  /// (like time). It could be associated with a 2D position (x, y, m) or a 3D
  /// position (x, y, z, m).
  num get m => _m ?? 0;

  /// The m ("measure") coordinate optionally. Returns null if not available.
  ///
  /// Use [isMeasured] to check whether m coordinate is available.
  ///
  /// [m] represents a measurement or a value on a linear referencing system
  /// (like time). It could be associated with a 2D position (x, y, m) or a 3D
  /// position (x, y, z, m).
  num? get optM => _m;

  @override
  int get spatialDimension => typeCoords.spatialDimension;

  @override
  int get coordinateDimension => typeCoords.coordinateDimension;

  @override
  bool get is3D => optZ != null;

  @override
  bool get isMeasured => optM != null;

  @override
  Coords get typeCoords =>
      CoordsExtension.select(is3D: is3D, isMeasured: isMeasured);

  @override
  String toString() {
    switch (typeCoords) {
      case Coords.xy:
        return '$x,$y';
      case Coords.xyz:
        return '$x,$y,$z';
      case Coords.xym:
        return '$x,$y,$m';
      case Coords.xyzm:
        return '$x,$y,$z,$m';
    }
  }
}
