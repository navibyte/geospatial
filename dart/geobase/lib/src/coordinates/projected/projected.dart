// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_scheme.dart';
import '/src/coordinates/geographic/geographic.dart';
import '/src/coordinates/projection/projection.dart';

import 'projbox.dart';

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
  final double _x;
  final double _y;
  final double? _z;
  final double? _m;

  /// A position scheme that creates [Projected] and [ProjBox] instances for
  /// positions and bounding boxes.
  ///
  /// These instances can be used to store projected positions and boxes.
  static const scheme =
      PositionScheme(position: Projected.create, box: ProjBox.create);

  /// A projected position with [x], [y], and optional [z] and [m] coordinates.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D position (x: 10.0, y: 20.0)
  /// Projected(x: 10.0, y: 20.0);
  ///
  /// // a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// Projected(x: 10.0, y: 20.0, z: 30.0);
  ///
  /// // a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
  /// Projected(x: 10.0, y: 20.0, m: 40.0);
  ///
  /// // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// Projected(x: 10.0, y: 20.0, z: 30.0, m: 40.0);
  /// ```
  ///
  /// This default constructor is equivalent to [Projected.create].
  const Projected({required double x, required double y, double? z, double? m})
      : _x = x,
        _y = y,
        _z = z,
        _m = m;

  /// A position from parameters compatible with `CreatePosition` function type.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D position (x: 10.0, y: 20.0)
  /// Projected.create(x: 10.0, y: 20.0);
  ///
  /// // a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// Projected.create(x: 10.0, y: 20.0, z: 30.0);
  ///
  /// // a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
  /// Projected.create(x: 10.0, y: 20.0, m: 40.0);
  ///
  /// // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// Projected.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0);
  /// ```
  ///
  /// This constructor is equivalent to the default contructor [Projected.new].
  const Projected.create({
    required double x,
    required double y,
    double? z,
    double? m,
  })  : _x = x,
        _y = y,
        _z = z,
        _m = m;

  /// Creates a projected position by copying coordinates from [source].
  ///
  /// If [source] is an instance of [Projected] then it's returned.
  static Projected from(Position source) =>
      source is Projected ? source : source.copyTo(Projected.create);

  /// Builds a projected position from [coords] starting from [offset].
  ///
  /// Supported coordinate value combinations for [coords] are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [coords] has 3 items, then xyz coordinates are assumed.
  ///
  /// Throws FormatException if coordinates are invalid.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D position (x: 10.0, y: 20.0)
  /// Projected.build([10.0, 20.0]);
  ///
  /// // a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// Projected.build([10.0, 20.0, 30.0]);
  ///
  /// // a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
  /// // (need to specify the coordinate type XYM)
  /// Projected.build([10.0, 20.0, 40.0], type: Coords.xym);
  ///
  /// // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// Projected.build([10.0, 20.0, 30.0, 40.0]);
  /// ```
  factory Projected.build(
    Iterable<num> coords, {
    int offset = 0,
    Coords? type,
  }) =>
      Position.buildPosition(
        coords,
        to: Projected.create,
        offset: offset,
        type: type,
      );

  /// Parses a projected position from [text].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// Supported coordinate value combinations for [text] are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [text] has 3 items, then xyz coordinates are assumed.
  ///
  /// If [swapXY] is true, then swaps x and y for the result.
  ///
  /// Throws FormatException if coordinates are invalid.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D position (x: 10.0, y: 20.0)
  /// Projected.parse('10.0,20.0');
  ///
  /// // a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// Projected.parse('10.0,20.0,30.0');
  ///
  /// // a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
  /// // (need to specify the coordinate type XYM)
  /// Projected.parse('10.0,20.0,40.0', type: Coords.xym);
  ///
  /// // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// Projected.parse('10.0,20.0,30.0,40.0');
  ///
  /// // a 2D position (x: 10.0, y: 20.0) using an alternative delimiter
  /// Projected.parse('10.0;20.0', delimiter: ';');
  ///
  /// // a 2D position (x: 10.0, y: 20.0) from an array with y before x
  /// Projected.parse('20.0,10.0', swapXY: true);
  /// ```
  factory Projected.parse(
    String text, {
    Pattern delimiter = ',',
    bool swapXY = false,
    Coords? type,
  }) =>
      Position.parsePosition(
        text,
        to: Projected.create,
        delimiter: delimiter,
        type: type,
        swapXY: swapXY,
      );

  @override
  PositionScheme get conforming => Projected.scheme;

  @override
  double get x => _x;

  @override
  double get y => _y;

  @override
  double get z => _z ?? 0;

  @override
  double? get optZ => _z;

  @override
  double get m => _m ?? 0;

  @override
  double? get optM => _m;

  /// Copies the position with optional [x], [y], [z] and [m] overriding values.
  ///
  /// For example when `const pos = Projected(x: 1.0, y: 1.0)` then
  /// * `pos.copyWith(y: 2.0) == Projected(x: 1.0, y: 2.0)`
  /// * `pos.copyWith(z: 2.0) == Projected(x: 1.0, y: 1.0, z: 2.0)`
  ///
  /// Some sub classes may ignore a non-null z parameter value if a position is
  /// not a 3D position, and a non-null m parameter if a position is not a
  /// measured position. However [Projected] itself supports changing the
  /// coordinate type.
  @override
  Projected copyWith({double? x, double? y, double? z, double? m}) => Projected(
        x: x ?? _x,
        y: y ?? _y,
        z: z ?? _z,
        m: m ?? _m,
      );

  @override
  Projected copyByType(Coords type) => coordType == type
      ? this
      : Projected.create(
          x: x,
          y: y,
          z: type.is3D ? z : null,
          m: type.isMeasured ? m : null,
        );

  @override
  Projected packed() => this;

  /// Unprojects this projected position to a geographic position using
  /// the inverse [projection].
  @override
  Geographic project(Projection projection) =>
      projection.project(this, to: Geographic.create);

  @override
  Projected transform(TransformPosition transform) => transform.call(this);

  @override
  bool get is3D => _z != null;

  @override
  bool get isMeasured => _m != null;

  @override
  String toString() {
    switch (coordType) {
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
