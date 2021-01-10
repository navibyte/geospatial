// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// Cartesian vector (or point) data structures:
// * Point2 with x and y as num values
// * Point2m with x, y and m as num, values
// * Point3 with x, y and z as num values
// * Point3m with x, y, z and m as num values
// * Point2i with x and y as int values
// * Point3i with x, y and z as int values

part of 'base.dart';

/// An immutable point with X and Y as num values.
@immutable
class Point2 extends Point<num> with EquatableMixin {
  /// A point at given [x] and [y].
  const Point2({required num x, required num y})
      : _x = x,
        _y = y;

  /// A point with coordinates given in order [x], [y].
  const Point2.xy(num x, num y)
      : _x = x,
        _y = y;

  /// A point at the origin (0.0, 0.0).
  const Point2.origin()
      : _x = 0.0,
        _y = 0.0;

  /// A point from [coords] given in order: x, y.
  factory Point2.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return Point2.xy(
      coords.elementAt(start),
      coords.elementAt(start + 1),
    );
  }

  final num _x, _y;

  @override
  List<Object?> get props => [_x, _y];

  @override
  bool get isEmpty => false;

  @override
  int get coordinateDimension => 2;

  @override
  int get spatialDimension => 2;

  @override
  bool get is3D => false;

  @override
  bool get hasM => false;

  @override
  num operator [](int i) {
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
  num get x => _x;

  @override
  num get y => _y;

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      Point2(x: x, y: y);

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(2, coords, offset: offset, length: length);
    return Point2.from(coords, offset: offset);
  }
}

/// An immutable point with X, Y and M as num values.
class Point2m extends Point2 {
  /// A point at given [x] and [y] ([m] is zero by default).
  const Point2m({required num x, required num y, num m = 0.0})
      : _m = m,
        super(x: x, y: y);

  /// A point with coordinates given in order [x], [y], [m].
  const Point2m.xym(num x, num y, num m)
      : _m = m,
        super(x: x, y: y);

  /// A point at the origin (0.0, 0.0, 0.0).
  const Point2m.origin()
      : _m = 0.0,
        super.origin();

  /// A point from [coords] given in order: x, y, m.
  factory Point2m.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return Point2m.xym(
      coords.elementAt(start),
      coords.elementAt(start + 1),
      coords.elementAt(start + 2),
    );
  }

  final num _m;

  @override
  List<Object?> get props => [_x, _y, _m];

  @override
  int get coordinateDimension => 3;

  @override
  bool get hasM => true;

  @override
  num operator [](int i) {
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
  num get m => _m;

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      Point2m(x: x, y: y, m: m ?? 0.0);

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
    return Point2m.from(coords, offset: offset);
  }
}

/// An immutable point with X, Y and Z as num values.
class Point3 extends Point2 {
  /// A point at given [x] and [y] ([z] is zero by default).
  const Point3({required num x, required num y, num z = 0.0})
      : _z = z,
        super(x: x, y: y);

  /// A point with coordinates given in order [x], [y], [z].
  const Point3.xyz(num x, num y, num z)
      : _z = z,
        super(x: x, y: y);

  /// A point at the origin (0.0, 0.0, 0.0).
  const Point3.origin()
      : _z = 0.0,
        super.origin();

  /// A point from [coords] given in order: x, y, m.
  factory Point3.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return Point3.xyz(
      coords.elementAt(start),
      coords.elementAt(start + 1),
      coords.elementAt(start + 2),
    );
  }

  final num _z;

  @override
  List<Object?> get props => [_x, _y, _z];

  @override
  int get coordinateDimension => 3;

  @override
  int get spatialDimension => 3;

  @override
  bool get is3D => true;

  @override
  num operator [](int i) {
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
  num get z => _z;

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      Point3(x: x, y: y, z: z ?? 0.0);

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
    return Point3.from(coords, offset: offset);
  }
}

/// An immutable point with X, Y, Z and M as num values.
class Point3m extends Point3 {
  /// A point at given [x] and [y] ([z] and [m] are zero by default).
  const Point3m({required num x, required num y, num z = 0.0, num m = 0.0})
      : _m = m,
        super(x: x, y: y, z: z);

  /// A point with coordinates given in order [x], [y], [z], [m].
  const Point3m.xyzm(num x, num y, num z, num m)
      : _m = m,
        super(x: x, y: y, z: z);

  /// A point at the origin (0.0, 0.0, 0.0, 0.0).
  const Point3m.origin()
      : _m = 0.0,
        super.origin();

  /// A point from [coords] given in order: x, y, z, m.
  factory Point3m.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return Point3m.xyzm(
      coords.elementAt(start),
      coords.elementAt(start + 1),
      coords.elementAt(start + 2),
      coords.elementAt(start + 3),
    );
  }

  final num _m;

  @override
  List<Object?> get props => [_x, _y, _z, _m];

  @override
  int get coordinateDimension => 4;

  @override
  bool get hasM => true;

  @override
  num operator [](int i) {
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
  num get m => _m;

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      Point3m(x: x, y: y, z: z ?? 0.0, m: m ?? 0.0);

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(4, coords, offset: offset, length: length);
    return Point3m.from(coords, offset: offset);
  }
}

/// An immutable point with X and Y as integer values.
@immutable
class Point2i extends Point<int> with EquatableMixin {
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
  factory Point2i.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return Point2i.xy(
      coords.elementAt(start).round(),
      coords.elementAt(start + 1).round(),
    );
  }

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
  bool get is3D => false;

  @override
  bool get hasM => false;

  @override
  int operator [](int i) {
    switch (i) {
      case 0:
        return _x;
      case 1:
        return _y;
      default:
        return 0;
    }
  }

  @override
  int get x => _x;

  @override
  int get y => _y;

  @override
  int get z => 0;

  @override
  int get m => 0;

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      Point2i(x: x.round(), y: y.round());

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(2, coords, offset: offset, length: length);
    return Point2i.from(coords, offset: offset);
  }
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
  factory Point3i.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return Point3i.xyz(
      coords.elementAt(start).round(),
      coords.elementAt(start + 1).round(),
      coords.elementAt(start + 2).round(),
    );
  }

  final int _z;

  @override
  List<Object?> get props => [_x, _y, _z];

  @override
  int get coordinateDimension => 3;

  @override
  int get spatialDimension => 3;

  @override
  bool get is3D => true;

  @override
  int operator [](int i) {
    switch (i) {
      case 0:
        return _x;
      case 1:
        return _y;
      case 2:
        return _z;
      default:
        return 0;
    }
  }

  @override
  int get z => _z;

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      Point3i(x: x.round(), y: y.round(), z: z?.round() ?? 0);

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
    return Point3i.from(coords, offset: offset);
  }
}
