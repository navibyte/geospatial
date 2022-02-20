// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/base/codes.dart';
import '/src/utils/tolerance.dart';

import 'position.dart';

/// A projected position with [x], [y], and optional [z] and [m] coordinates.
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
@immutable
class Projected extends Position {
  final num _x;
  final num _y;
  final num? _z;
  final num? _m;

  /// A projected position with [x], [y], and optional [z] and [m] coordinates.
  const Projected({required num x, required num y, num? z, num? m})
      : _x = x,
        _y = y,
        _z = z,
        _m = m;

  /// A position from parameters compatible with `CreatePosition` function type.
  const Projected.create({required num x, required num y, num? z, num? m})
      : _x = x,
        _y = y,
        _z = z,
        _m = m;

  @override
  num get x => _x;

  @override
  num get y => _y;

  @override
  num get z => _z ?? 0;

  @override
  num? get optZ => _z;

  @override
  num get m => _m ?? 0;

  @override
  num? get optM => _m;

  /// A coordinate value by the coordinate axis index [i].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  @override
  num operator [](int i) => Projected.getValue(this, i);

  /// Coordinate values of this position as an iterable of 2, 3 or 4 items.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  @override
  Iterable<num> get values => Projected.getValues(this);

  @override
  R copyTo<R extends Position>(CreatePosition<R> factory) =>
      factory.call(x: _x, y: _y, z: _z, m: _m);

  /// Copies the position with optional [x], [y], [z] and [m] overriding values.
  ///
  /// For example:
  /// `Projected(x: 1, y: 1).copyWith(y: 2) == Projected(x: 1, y: 2)`
  /// `Projected(x: 1, y: 1).copyWith(z: 2) == Projected(x: 1, y: 1, z: 2)`
  @override
  Projected copyWith({num? x, num? y, num? z, num? m}) => Projected(
        x: x ?? _x,
        y: y ?? _y,
        z: z ?? _z,
        m: m ?? _m,
      );

  @override
  Projected transform(TransformPosition transform) => transform(this);

  @override
  int get spatialDimension => typeCoords.spatialDimension;

  @override
  int get coordinateDimension => typeCoords.coordinateDimension;

  @override
  bool get isGeographic => false;

  @override
  bool get is3D => _z != null;

  @override
  bool get isMeasured => _m != null;

  @override
  Coords get typeCoords => CoordsExtension.select(
        isGeographic: isGeographic,
        is3D: is3D,
        isMeasured: isMeasured,
      );

  @override
  String toString() {
    switch (typeCoords) {
      case Coords.xy:
        return '$_x,$_y';
      case Coords.xyz:
        return '$_x,$_y,$_z';
      case Coords.xym:
        return '$_x,$_y,$_m';
      case Coords.xyzm:
        return '$_x,$_y,$_z,$_m';
      case Coords.lonLat:
      case Coords.lonLatElev:
      case Coords.lonLatM:
      case Coords.lonLatElevM:
        return '<not geographic>';
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Projected && Projected.testEquals(this, other);

  @override
  int get hashCode => Projected.hash(this);

  @override
  bool equals2D(Position other, {num? toleranceHoriz}) =>
      other is Projected &&
      Projected.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  @override
  bool equals3D(
    Position other, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) =>
      other is Projected &&
      Projected.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  // ---------------------------------------------------------------------------
  // Static methods with default logic, used by Position itself too.

  /// A coordinate value of [position] by the coordinate axis index [i].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  static num getValue(Projected position, int i) {
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
  static Iterable<num> getValues(Projected position) sync* {
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
  static bool testEquals(Projected p1, Projected p2) =>
      p1.x == p2.x && p1.y == p2.y && p1.optZ == p2.optZ && p1.optM == p2.optM;

  /// The hash code for [position].
  static int hash(Projected position) =>
      Object.hash(position.x, position.y, position.optZ, position.optM);

  /// True if positions [p1] and [p2] equals by testing 2D coordinates only.
  static bool testEquals2D(Projected p1, Projected p2, {num? toleranceHoriz}) {
    assertTolerance(toleranceHoriz);
    return toleranceHoriz != null
        ? (p1.x - p2.x).abs() <= toleranceHoriz &&
            (p1.y - p2.y).abs() <= toleranceHoriz
        : p1.x == p2.x && p1.y == p2.y;
  }

  /// True if positions [p1] and [p2] equals by testing 3D coordinates only.
  static bool testEquals3D(
    Projected p1,
    Projected p2, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) {
    assertTolerance(toleranceVert);
    if (!Projected.testEquals2D(p1, p2, toleranceHoriz: toleranceHoriz)) {
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
