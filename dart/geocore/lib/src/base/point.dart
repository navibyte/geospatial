// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'geometry.dart';

/// A read-only point with coordinate value getters.
abstract class Point extends Geometry {
  const Point();

  @override
  int get dimension => 0;

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
}