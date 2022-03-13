// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/utils/num.dart';
import '/src/utils/tolerance.dart';

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
  bool equals2D(Position other, {num? toleranceHoriz}) =>
      Position.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

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
  }) =>
      Position.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  // ---------------------------------------------------------------------------
  // Static methods with default logic, used by Position, Projected and
  // Geographic.

  /// Creates a position of [R] from [coords] given in order: x, y, [z, m].
  ///
  /// The [coords] must contain at least two coordinate values (x and y)
  /// starting from [offset]. If [coords] contains three values, then 3rd item
  /// is z. If [coords] contains four values, then 4th item is m.
  ///
  /// A position instance is created using the factory function [to].
  static R createFrom<R extends Position>(
    Iterable<num> coords, {
    required CreatePosition<R> to,
    int offset = 0,
  }) {
    final len = coords.length - offset;
    if (len < 2) {
      throw const FormatException('Coords must contain at least two items');
    }
    return to.call(
      x: coords.elementAt(offset),
      y: coords.elementAt(offset + 1),
      z: len >= 3 ? coords.elementAt(offset + 2) : null,
      m: len >= 4 ? coords.elementAt(offset + 3) : null,
    );
  }

  /// Creates a position of [R] from [text] given in order: x, y, [z, m].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// The [text] must contain at least two coordinate values (x and y). If
  /// [text] contains three values, then 3rd item is z. If [text] contains four
  /// values, then 4th item is m.
  ///
  /// A position instance is created using the factory function [to].
  static R createFromText<R extends Position>(
    String text, {
    required CreatePosition<R> to,
    Pattern? delimiter = ',',
  }) {
    final coords = parseNullableNumValuesFromText(text, delimiter: delimiter);
    final len = coords.length;
    if (len < 2) {
      throw const FormatException('Coords must contain at least two items');
    }
    final x = coords.elementAt(0);
    final y = coords.elementAt(1);
    if (x == null || y == null) {
      throw const FormatException('X and y are required.');
    }
    return to.call(
      x: x,
      y: y,
      z: len >= 3 ? coords.elementAt(2) : null,
      m: len >= 4 ? coords.elementAt(3) : null,
    );
  }

  /// A coordinate value of [position] by the coordinate axis index [i].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  static num getValue(Position position, int i) {
    if (position.is3D) {
      switch (i) {
        case 0:
          return position.x;
        case 1:
          return position.y;
        case 2:
          return position.z;
        case 3:
          return position.m; // returns m or 0
        default:
          return 0;
      }
    } else {
      switch (i) {
        case 0:
          return position.x;
        case 1:
          return position.y;
        case 2:
          return position.m; // returns m or 0
        default:
          return 0;
      }
    }
  }

  /// Coordinate values of [position] as an iterable of 2, 3 or 4 items.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  static Iterable<num> getValues(Position position) sync* {
    yield position.x;
    yield position.y;
    if (position.is3D) {
      yield position.z;
    }
    if (position.isMeasured) {
      yield position.m;
    }
  }

  /// True if positions [p1] and [p2] equals by testing all coordinate values.
  static bool testEquals(Position p1, Position p2) =>
      p1.x == p2.x && p1.y == p2.y && p1.optZ == p2.optZ && p1.optM == p2.optM;

  /// The hash code for [position].
  static int hash(Position position) =>
      Object.hash(position.x, position.y, position.optZ, position.optM);

  /// True if positions [p1] and [p2] equals by testing 2D coordinates only.
  static bool testEquals2D(Position p1, Position p2, {num? toleranceHoriz}) {
    assertTolerance(toleranceHoriz);
    return toleranceHoriz != null
        ? (p1.x - p2.x).abs() <= toleranceHoriz &&
            (p1.y - p2.y).abs() <= toleranceHoriz
        : p1.x == p2.x && p1.y == p2.y;
  }

  /// True if positions [p1] and [p2] equals by testing 3D coordinates only.
  static bool testEquals3D(
    Position p1,
    Position p2, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) {
    assertTolerance(toleranceVert);
    if (!Position.testEquals2D(p1, p2, toleranceHoriz: toleranceHoriz)) {
      return false;
    }
    if (!p1.is3D || !p1.is3D) {
      return false;
    }
    return toleranceVert != null
        ? (p1.z - p2.z).abs() <= toleranceVert
        : p1.z == p2.z;
  }
}
