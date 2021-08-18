// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A read-only point with coordinate value getters.
///
/// Coordinate values of type [C] are either `num` (allowing `double` or `int`),
/// `double` or `int`.
abstract class Point<C extends num> extends Geometry
    implements _Coordinates, PointFactory {
  /// Default `const` constructor to allow extending this abstract class.
  const Point();

  /// Create an empty point.
  factory Point.empty({bool is3D, bool hasM}) = _PointEmpty<C>;

  @override
  int get dimension => 0;

  @override
  Bounds get bounds => Bounds.of(min: this, max: this);

  /// A coordinate value by the index [i] as type [C] extending num.
  ///
  /// Coordinate ordering must be: (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  ///
  /// If a sub class has geographic coordinates, then ordering must be:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  ///
  /// Or for Easting and Northing projected coordinates ordering is:
  /// (E, N), (E, N, m), (E, N, z) or (E, N, z, m).
  C operator [](int i);

  /// Returns coordinate values of this point as a fixed length list.
  ///
  /// The default implementation creates a fixed length `List<C>` with
  /// length equaling to [coordinateDimension]. Then [] operator is used to
  /// populate coordinate values.
  ///
  /// Sub classes may override the default implementation to provide more
  /// efficient approach. It's also allowed to return internal data storage
  /// for coordinate values.
  List<C> get values =>
      // create fixed length list and set coordinate values on it
      List<C>.generate(coordinateDimension, (i) => this[i], growable: false);

  /// X coordinate as type [C] extending `num`.
  C get x;

  /// Y coordinate as type [C] extending `num`.
  C get y;

  /// Z coordinate as type [C] extending `num`. Returns zero if not available.
  C get z => _zero();

  /// M coordinate as type [C] extending `num`. Returns zero if not available.
  ///
  /// [m] represents a value on a linear referencing system (like time).
  /// Could be associated with a 2D point (x, y, m) or a 3D point (x, y, z, m).
  C get m => _zero();

  /// True if this point equals with [other] point in 2D.
  bool equals2D(Point other) =>
      isNotEmpty && other.isNotEmpty && x == other.x && y == other.y;

  /// True if this point equals with [other] point in 3D.
  bool equals3D(Point other) => equals2D(other) && z == other.z;

  /// Returns zero value of the type [C] that can be `num`, `double` or `int`.
  C _zero() {
    if (C == int) {
      return 0 as C;
    } else {
      return 0.0 as C;
    }
  }

  @override
  void writeValues(StringSink buf, {String delimiter = ','}) {
    for (var i = 0; i < coordinateDimension; i++) {
      if (i > 0) {
        buf.write(delimiter);
      }
      buf.write(this[i]);
    }
  }

  @override
  String valuesAsString({String delimiter = ','}) {
    final buf = StringBuffer();
    writeValues(buf, delimiter: delimiter);
    return buf.toString();
  }
}

/// A private implementation for an empty point with coordinate zero values.
/// The implementation may change in future.
@immutable
class _PointEmpty<C extends num> extends Point<C> with EquatableMixin {
  const _PointEmpty({this.is3D = false, this.hasM = false});

  @override
  final bool is3D;

  @override
  final bool hasM;

  @override
  Bounds get bounds => Bounds.empty();

  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;

  @override
  int get coordinateDimension => spatialDimension + (hasM ? 1 : 0);

  @override
  int get spatialDimension => is3D ? 3 : 2;

  @override
  C operator [](int i) => _zero();

  @override
  C get x => _zero();

  @override
  C get y => _zero();

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => this;

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) => this;

  @override
  List<Object?> get props => [is3D, hasM];
}
