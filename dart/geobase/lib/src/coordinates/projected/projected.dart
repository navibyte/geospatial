// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base.dart';

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
///
/// For 2D coordinates the coordinate axis indexes are:
///
/// Index | Projected
/// ----- | ---------
/// 0     | x
/// 1     | y
/// 2     | m
///
/// For 3D coordinates the coordinate axis indexes are:
///
/// Index | Projected
/// ----- | ---------
/// 0     | x
/// 1     | y
/// 2     | z
/// 3     | m
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

  /// Creates a projected position from [coords] starting from [offset].
  ///
  /// Supported coordinate value combinations for [coords] are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [coords] has 3 items, then xyz coordinates are assumed.
  ///
  /// Throws FormatException if coordinates are invalid.
  factory Projected.fromCoords(
    Iterable<num> coords, {
    int offset = 0,
    Coords? type,
  }) =>
      Position.createFromCoords(
        coords,
        to: Projected.create,
        offset: offset,
        type: type,
      );

  /// Creates a projected position from [text].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// Supported coordinate value combinations for [text] are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [text] has 3 items, then xyz coordinates are assumed.
  ///
  /// Throws FormatException if coordinates are invalid.
  factory Projected.fromText(
    String text, {
    Pattern? delimiter = ',',
    Coords? type,
  }) =>
      Position.createFromText(
        text,
        to: Projected.create,
        delimiter: delimiter,
        type: type,
      );

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

  /// A coordinate value by the coordinate axis [index].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  @override
  num operator [](int index) => Position.getValue(this, index);

  /// Coordinate values of this position as an iterable of 2, 3 or 4 items.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  @override
  Iterable<num> get values => Position.getValues(this);

  /// Copies the position with optional [x], [y], [z] and [m] overriding values.
  ///
  /// For example:
  /// `Projected(x: 1, y: 1).copyWith(y: 2) == Projected(x: 1, y: 2)`
  /// `Projected(x: 1, y: 1).copyWith(z: 2) == Projected(x: 1, y: 1, z: 2)`
  ///
  /// Some sub classes may ignore a non-null z parameter value if a position is
  /// not a 3D position, and a non-null m parameter if a position is not a
  /// measured position. However [Projected] itself supports changing the
  /// coordinate type.
  @override
  Projected copyWith({num? x, num? y, num? z, num? m}) => Projected(
        x: x ?? _x,
        y: y ?? _y,
        z: z ?? _z,
        m: m ?? _m,
      );

  @override
  Projected transform(TransformPosition transform) => transform.call(this);

/*
  @override
  bool get isGeographic => false;
*/

  @override
  bool get is3D => _z != null;

  @override
  bool get isMeasured => _m != null;

  @override
  String toString() {
    switch (type) {
      case Coords.xy:
        return '$_x,$_y';
      case Coords.xyz:
        return '$_x,$_y,$_z';
      case Coords.xym:
        return '$_x,$_y,$_m';
      case Coords.xyzm:
        return '$_x,$_y,$_z,$_m';
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Position && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);
}
