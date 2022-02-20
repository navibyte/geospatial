// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'positionable.dart';

/// Creates a new position of [T] from [x] and [y], and optional [z] and [m].
///
/// For projected or cartesian positions (`Projected`), coordinates axis are
/// applied as is.
///
/// For geographic positions (`Geographic`), coordinates are applied as:
/// `x` => `lon`, `y` => `lat`, `z` => `elev`, `m` => `m`
typedef CreatePosition<T extends Position> = T Function({
  required num x,
  required num y,
  num? z,
  num? m,
});

/// A function to transform the [source] position of [T] to a position of [T].
///
/// Target positions of [T] are created using [source] itself as a factory.
///
/// Throws FormatException if cannot transform.
typedef TransformPosition = T Function<T extends Position>(T source);

/// A base interface for geospatial positions.
//
/// This interface defines coordinate value only for the m axis. Sub classes
/// define coordinate values for other axes (x, y and z for projected or
/// cartesian positions, and longitude, latitude and elevation for geographic
/// positions).
///
/// The known sub classes are `Projected` (with x, y, z and m coordinates) and
/// `Geographic` (with lon, lat, elev and m coordinates).
abstract class Position extends Positionable {
  /// Default `const` constructor to allow extending this abstract class.
  const Position();

  /// The x coordinate value.
  ///
  /// For geographic coordinates x represents *longitude*.
  num get x;

  /// The y coordinate value.
  ///
  /// For geographic coordinates y represents *latitude*.
  num get y;

  /// The z coordinate value. Returns zero if not available.
  ///
  /// You can also use [is3D] to check whether z coordinate is available, or
  /// [optZ] returns z coordinate as nullable value.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  num get z;

  /// The z coordinate value optionally. Returns null if not available.
  ///
  /// You can also use [is3D] to check whether z coordinate is available.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  num? get optZ;

  /// The m ("measure") coordinate value. Returns zero if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available,
  /// [optM] returns m coordinate as nullable value.
  ///
  /// [m] represents a measurement or a value on a linear referencing system
  /// (like time).
  num get m;

  /// The m ("measure") coordinate optionally. Returns null if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available.
  ///
  /// [m] represents a measurement or a value on a linear referencing system
  /// (like time).
  num? get optM;

  /// A coordinate value by the coordinate axis index [i].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  num operator [](int i);

  /// Coordinate values of this position as an iterable of 2, 3 or 4 items.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  Iterable<num> get values;

  /// Copies this position to a new position created by the [factory].
  R copyTo<R extends Position>(CreatePosition<R> factory);

  /// Copies the position with optional [x], [y], [z] and [m] overriding values.
  ///
  /// When copying `Geographic` then coordinates has correspondence:
  /// `x` => `lon`, `y` => `lat`, `z` => `elev`, `m` => `m`
  Position copyWith({num? x, num? y, num? z, num? m});

  /// Returns a position with all points transformed using [transform].
  Position transform(TransformPosition transform);

  /// True if this position equals with [other] by testing 2D coordinates only.
  ///
  /// If [toleranceHoriz] is given, then differences on 2D coordinate values
  /// (ie. x and y, or lon and lat) between this and [other] must be within
  /// tolerance. Otherwise value must be exactly same.
  ///
  /// Tolerance values must be null or positive (>= 0).
  bool equals2D(Position other, {num? toleranceHoriz});

  /// True if this position equals with [other] by testing 3D coordinates only.
  ///
  /// Returns false if this or [other] is not a 3D position.
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
    Position other, {
    num? toleranceHoriz,
    num? toleranceVert,
  });
}
