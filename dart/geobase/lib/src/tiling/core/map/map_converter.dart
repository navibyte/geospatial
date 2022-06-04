// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A map converter between geospatial positions and map coordinates.
/// 
/// Geospatial positions may represent geographic or projected coordinates.
abstract class MapConverter {
  /// Converts geospatial [x] to map x coordinate with range (0, [width]).
  ///
  /// The source geospatial [x] coordinate could be a projected x or a
  /// geographic longitude coordinate.
  /// 
  /// The target map [x] coordinate could be a "world" pixel coordinate with
  /// a double value (ie. range 0. .. 256.0) or a projected x coordinate with 
  /// a metric value. 
  double toMappedX(num x, {num width = 256});

  /// Converts geopatial [y] to map y coordinate with range (0, [height]).
  ///
  /// The source geospatial [y] coordinate could be a projected y or a 
  /// geographic latitude coordinate.
  /// 
  /// The target map [y] coordinate could be a "world" pixel coordinate with
  /// a double value (ie. range 0. .. 256.0) or a projected y coordinate with 
  /// a metric value. 
  double toMappedY(num y, {num height = 256});

  /// Converts map [x] coordinate with range (0, [width]) to geospatial x.
  /// 
  /// The source map [x] coordinate could be a "world" pixel coordinate with
  /// a double value (ie. range 0. .. 256.0) or a projected x coordinate with 
  /// a metric value. 
  ///
  /// The target geospatial [x] coordinate could be a projected x or a
  /// geographic longitude coordinate.
  double fromMappedX(num x, {num width = 256});

  /// Converts map [y] coordinate with range (0, [height]) to geospatial y.
  /// 
  /// The source map [y] coordinate could be a "world" pixel coordinate with
  /// a double value (ie. range 0. .. 256.0) or a projected y coordinate with 
  /// a metric value. 
  ///
  /// The target geospatial [y] coordinate could be a projected y or a
  /// geographic latitude coordinate.
  double fromMappedY(num y, {num height = 256});
}
