// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'geometry.dart';
import 'point_immutable.dart';

/// A read-only point with coordinate value getters.
abstract class Point extends Geometry {
  const Point();

  /// Create an empty point.
  factory Point.empty({bool hasZ, bool hasM}) = PointEmpty;

  /// A point from [coords]: xy or xyz (if [expectM] then could be xyz or xyzm).
  ///
  /// Throws FormatException if cannot create point.
  factory Point.from(Iterable<double> coords, {bool expectM = false}) {
    if (expectM) {
      if (coords.length >= 4) {
        return Point3m.from(coords);
      } else if (coords.length == 3) {
        return Point2m.from(coords);
      }
    } else {
      if (coords.length >= 3) {
        return Point3.from(coords);
      } else if (coords.length == 2) {
        return Point2.from(coords);
      }
    }
    throw FormatException('Not a valid point.');
  }

  @override
  int get dimension => 0;

  /// The number of coordinate values (2, 3 or 4) for this point.
  ///
  /// If value is 2, the point has 2D coordinates without m coordinate.
  ///
  /// If value is 3, the point has 2D coordinates with m coordinate or it
  /// has 3D coordinates without m coordinate.
  ///
  /// If value is 4, the point has 3D coordinates with m coordinate.
  ///
  /// Must be >= [spatialDimension].
  int get coordinateDimension;

  /// The number of spatial coordinate values (2 for 2D or 3 for 3D).
  int get spatialDimension;

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
}

/// An empty point (non-existent) that has all coordinate values 0.0 if queried.
@immutable
class PointEmpty extends Point {
  PointEmpty({this.hasZ = false, this.hasM = false});

  final bool hasZ;

  final bool hasM;

  @override
  bool get isEmpty => true;

  @override
  int get coordinateDimension => hasZ ? 3 : 2;

  @override
  int get spatialDimension => coordinateDimension + (hasM ? 1 : 0);

  @override
  double operator [](int i) => 0.0;

  @override
  double get x => 0.0;

  @override
  double get y => 0.0;
}
