// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.
//
// Cartesian vector (or point) data structures:
// * Point2 with x and y as double values
// * Point2m with x, y and m as double values
// * Point3 with x, y and z as double values
// * Point3m with x, y, z and m as double values
// * Point2i with x and y as int values
// * Point3i with x, y and z as int values

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'point.dart';

/// An immutable point with X and Y as double values.
@immutable
class Point2 extends Point with EquatableMixin {
  /// A point at given [x] and [y].
  const Point2({required double x, required double y})
      : _x = x,
        _y = y;

  /// A point with coordinates given in order [x], [y].
  const Point2.xy(double x, double y)
      : _x = x,
        _y = y;

  /// A point at the origin (0.0, 0.0).
  const Point2.origin()
      : _x = 0.0,
        _y = 0.0;

  /// A point from [coords] given in order: x, y.
  factory Point2.from(Iterable<double> coords) =>
      Point2.xy(coords.elementAt(0), coords.elementAt(1));

  final double _x, _y;

  @override
  List<Object?> get props => [_x, _y];

  @override
  bool get isEmpty => false;

  @override
  int get coordinateDimension => 2;

  @override
  int get spatialDimension => 2;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return _x;
      case 1:
        return _y;
      default:
        return 0.0;
    }
  }

  @override
  double get x => _x;

  @override
  double get y => _y;
}

/// An immutable point with X, Y and M as double values.
class Point2m extends Point2 {
  /// A point at given [x] and [y] ([m] is zero by default).
  const Point2m({required double x, required double y, double m = 0.0})
      : _m = m,
        super(x: x, y: y);

  /// A point with coordinates given in order [x], [y], [m].
  const Point2m.xym(double x, double y, double m)
      : _m = m,
        super(x: x, y: y);

  /// A point at the origin (0.0, 0.0, 0.0).
  const Point2m.origin()
      : _m = 0.0,
        super.origin();

  /// A point from [coords] given in order: x, y, m.
  factory Point2m.from(Iterable<double> coords) => Point2m.xym(
      coords.elementAt(0), coords.elementAt(1), coords.elementAt(2));

  final double _m;

  @override
  List<Object?> get props => [_x, _y, _m];

  @override
  int get coordinateDimension => 3;

  @override
  int get spatialDimension => 2;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return _x;
      case 1:
        return _y;
      case 2:
        return _m;
      default:
        return 0.0;
    }
  }

  @override
  double get m => _m;
}

/// An immutable point with X, Y and Z as double values.
class Point3 extends Point2 {
  /// A point at given [x] and [y] ([z] is zero by default).
  const Point3({required double x, required double y, double z = 0.0})
      : _z = z,
        super(x: x, y: y);

  /// A point with coordinates given in order [x], [y], [z].
  const Point3.xyz(double x, double y, double z)
      : _z = z,
        super(x: x, y: y);

  /// A point at the origin (0.0, 0.0, 0.0).
  const Point3.origin()
      : _z = 0.0,
        super.origin();

  /// A point from [coords] given in order: x, y, m.
  factory Point3.from(Iterable<double> coords) =>
      Point3.xyz(coords.elementAt(0), coords.elementAt(1), coords.elementAt(2));

  final double _z;

  @override
  List<Object?> get props => [_x, _y, _z];

  @override
  int get coordinateDimension => 3;

  @override
  int get spatialDimension => 3;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return _x;
      case 1:
        return _y;
      case 2:
        return _z;
      default:
        return 0.0;
    }
  }

  @override
  double get z => _z;
}

/// An immutable point with X, Y, Z and M as double values.
class Point3m extends Point3 {
  /// A point at given [x] and [y] ([z] and [m] are zero by default).
  const Point3m(
      {required double x, required double y, double z = 0.0, double m = 0.0})
      : _m = m,
        super(x: x, y: y, z: z);

  /// A point with coordinates given in order [x], [y], [z], [m].
  const Point3m.xyzm(double x, double y, double z, double m)
      : _m = m,
        super(x: x, y: y, z: z);

  /// A point at the origin (0.0, 0.0, 0.0, 0.0).
  const Point3m.origin()
      : _m = 0.0,
        super.origin();

  /// A point from [coords] given in order: x, y, z, m.
  factory Point3m.from(Iterable<double> coords) => Point3m.xyzm(
      coords.elementAt(0),
      coords.elementAt(1),
      coords.elementAt(2),
      coords.elementAt(3));

  final double _m;

  @override
  List<Object?> get props => [_x, _y, _z, _m];

  @override
  int get coordinateDimension => 4;

  @override
  int get spatialDimension => 3;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return _x;
      case 1:
        return _y;
      case 2:
        return _z;
      case 3:
        return _m;
      default:
        return 0.0;
    }
  }

  @override
  double get m => _m;
}

/// An immutable point with X and Y as integer values.
@immutable
class Point2i extends Point with EquatableMixin {
  /// A point at given [x] and [y].
  const Point2i({required int x, required int y})
      : _x = x,
        _y = y;

  /// A point with coordinates given in order [x], [y].
  const Point2i.xy(int x, int y)
      : _x = x,
        _y = y;

  /// A point at the origin (0, 0).
  const Point2i.origin()
      : _x = 0,
        _y = 0;

  /// A point from [coords] given in order: x, y.
  factory Point2i.from(Iterable<int> coords) =>
      Point2i.xy(coords.elementAt(0), coords.elementAt(1));

  final int _x, _y;

  @override
  List<Object?> get props => [_x, _y];

  @override
  bool get isEmpty => false;

  @override
  int get coordinateDimension => 2;

  @override
  int get spatialDimension => 2;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return _x.toDouble();
      case 1:
        return _y.toDouble();
      default:
        return 0.0;
    }
  }

  @override
  double get x => _x.toDouble();

  @override
  double get y => _y.toDouble();
}

/// An immutable point with X, Y and Z as integer values.
class Point3i extends Point2i {
  /// A point at given [x] and [y] ([z] is zero by default).
  const Point3i({required int x, required int y, int z = 0})
      : _z = z,
        super(x: x, y: y);

  /// A point with coordinates given in order: x, y, z.
  const Point3i.xyz(int x, int y, int z)
      : _z = z,
        super(x: x, y: y);

  /// A point at the origin (0, 0, 0).
  const Point3i.origin()
      : _z = 0,
        super.origin();

  /// A point from [coords] given in order [x], [y], [z].
  factory Point3i.from(Iterable<int> coords) => Point3i.xyz(
      coords.elementAt(0), coords.elementAt(1), coords.elementAt(2));

  final int _z;

  @override
  List<Object?> get props => [_x, _y, _z];

  @override
  int get coordinateDimension => 3;

  @override
  int get spatialDimension => 3;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return _x.toDouble();
      case 1:
        return _y.toDouble();
      case 2:
        return _z.toDouble();
      default:
        return 0.0;
    }
  }

  @override
  double get z => _z.toDouble();
}
