// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// The axis order of coordinate values in position and point representations.
/// 
/// Internally this library uses [xy] order for geographic and projected
/// coordinates.
/// 
/// However external geospatial data representations both for human (ie. a
/// common decimal degrees repsenting latitude before longitude) and machine
/// interfaces (ie. formats like WKT, GeoJSON or data protocols like WFS and OGC
/// API standards) may specify either [xy] or [yx] order for coordinates.
enum AxisOrder {
  /// The axis order in position and point representations is expected to be 
  /// `(longitude, latitude)` for geographic coordinates, `(easting, northing)`
  /// for projected map coordinates, and `(x, y)` for other cartesian
  /// coordinates.
  /// 
  /// This is also the internal representation of coordinates in this library.
  xy,

  /// The axis order in position and point representations is expected to be 
  /// `(latitude, longitude)` for geographic coordinates, `(northing, easting)`
  /// for projected map coordinates, and `(y, x)` for other cartesian
  /// coordinates.
  yx,
}
