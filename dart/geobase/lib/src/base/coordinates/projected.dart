// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/base/codes.dart';

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

  /// Creates a position from [coords] given in order: x, y, [z, m].
  ///
  /// The [coords] must contain at least two coordinate values (x and y)
  /// starting from [offset]. If [coords] contains three values, then 3rd item
  /// is z. If [coords] contains four values, then 4th item is m.
  factory Projected.from(Iterable<num> coords, {int offset = 0}) =>
      Position.createFrom(
        coords,
        to: Projected.create,
        offset: offset,
      );

  /// Creates a position from [text] given in order: x, y, [z, m].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// The [text] must contain at least two coordinate values (x and y). If
  /// [text] contains three values, then 3rd item is z. If [text] contains four
  /// values, then 4th item is m.
  factory Projected.fromText(
    String text, {
    Pattern? delimiter = ',',
  }) =>
      Position.createFromText(
        text,
        to: Projected.create,
        delimiter: delimiter,
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

  /// A coordinate value by the coordinate axis index [i].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  @override
  num operator [](int i) => Position.getValue(this, i);

  /// Coordinate values of this position as an iterable of 2, 3 or 4 items.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  @override
  Iterable<num> get values => Position.getValues(this);

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
        return '$_x,$_y,,$_m';
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
      other is Projected && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);
}
