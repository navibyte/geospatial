// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A read-only point with coordinate value getters.
abstract class Point extends Geometry implements _Coordinates {
  const Point();

  /// Create an empty point.
  factory Point.empty({bool is3D, bool hasM}) = _PointEmpty;

  @override
  int get dimension => 0;

  @override
  Bounds get bounds => Bounds.of(min: this, max: this);

  /// A coordinate value by the index [i].
  ///
  /// Coordinate ordering must be: (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  ///
  /// If a sub class has geographic coordinates, then ordering must be:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  ///
  /// Or for Easting and Northing projected coordinates ordering is:
  /// (E, N), (E, N, m), (E, N, z) or (E, N, z, m).
  double operator [](int i);

  /// Returns coordinate values of this point as a fixed length double list.
  ///
  /// The default implementation creates a fixed length `List<double>` with
  /// length equaling to [coordinateDimension]. Then [] operator is used to populate
  /// coordinate values.
  ///
  /// Sub classes may override the default implementation to provide more
  /// efficient approach. It's also allowed to return internal data storage
  /// for coordinate values.
  List<double> get values {
    // create fixed length list and set coordinate values on it
    return List<double>.generate(coordinateDimension, (i) => this[i],
        growable: false);
  }

  /// X coordinate as double.
  double get x;

  /// Y coordinate as double.
  double get y;

  /// Z coordinate as double. Returns 0.0 if not available.
  double get z => 0.0;

  /// M coordinate (time, measure etc.) as double. Returns 0.0 if not available.
  ///
  /// [m] represents a value on a linear referencing system (like time).
  /// Could be associated with a 2D point (x, y, m) or a 3D point (x, y, z, m).
  double get m => 0.0;

  /// True if this point equals with [other] point in 2D.
  bool equals2D(Point other) =>
      isNotEmpty && other.isNotEmpty && x == other.x && y == other.y;

  /// True if this point equals with [other] point in 3D.
  bool equals3D(Point other) => equals2D(other) && z == other.z;

  /// Creates a new [Point] instance compatible with this point instance.
  ///
  /// Values for a new point are given by [x], [y], [z] and [z] as applicable
  /// for an implementing class.
  Point newPoint(
      {double x = 0.0, double y = 0.0, double z = 0.0, double m = 0.0});
}

/// A private implementation for an empty point with coordinate 0.0 values.
/// The implementation may change in future.
@immutable
class _PointEmpty extends Point {
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
  int get coordinateDimension => is3D ? 3 : 2;

  @override
  int get spatialDimension => coordinateDimension + (hasM ? 1 : 0);

  @override
  double operator [](int i) => 0.0;

  @override
  double get x => 0.0;

  @override
  double get y => 0.0;

  @override
  Point newPoint(
          {double x = 0.0, double y = 0.0, double z = 0.0, double m = 0.0}) =>
      this;
}
