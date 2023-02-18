// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A coordinate converter between geospatial positions and scaled coordinates.
///
/// Geospatial positions may represent geographic or projected coordinates
/// defined by a spatial coordinate reference system.
///
/// Scaled coordinates are projected coordinates scaled to a defined range
/// most often defined by a tiling scheme.
abstract class ScaledConverter {
  /// Converts geospatial [x] to scaled x coordinate with range (0, [width]).
  ///
  /// The source geospatial [x] coordinate could be a projected x (metric) or a
  /// geographic longitude coordinate defined by a spatial coordinate reference
  /// system.
  ///
  /// The target scaled [x] coordinate could be a "world" pixel coordinate with
  /// a double value (ie. range 0. .. 256.0) or a projected x coordinate with
  /// a integer column value (of a tile or a pixel) defined by a tiling scheme.
  double toScaledX(num x, {num width = 256});

  /// Converts geopatial [y] to scaled y coordinate with range (0, [height]).
  ///
  /// The source geospatial [y] coordinate could be a projected y (metric) or a
  /// geographic latitude coordinate defined by a spatial coordinate reference
  /// system.
  ///
  /// The target scaled [y] coordinate could be a "world" pixel coordinate with
  /// a double value (ie. range 0. .. 256.0) or a projected y coordinate with
  /// a integer row value (of a tile or a pixel) defined by a tiling scheme.
  double toScaledY(num y, {num height = 256});

  /// Converts scaled [x] coordinate with range (0, [width]) to geospatial x.
  ///
  /// The source scaled [x] coordinate could be a "world" pixel coordinate with
  /// a double value (ie. range 0. .. 256.0) or a projected x coordinate with
  /// a integer column value (of a tile or a pixel) defined by a tiling scheme.
  ///
  /// The target geospatial [x] coordinate could be a projected x (metric) or a
  /// geographic longitude coordinate defined by a spatial coordinate reference
  /// system.
  double fromScaledX(num x, {num width = 256});

  /// Converts scaled [y] coordinate with range (0, [height]) to geospatial y.
  ///
  /// The source scaled [y] coordinate could be a "world" pixel coordinate with
  /// a double value (ie. range 0. .. 256.0) or a projected y coordinate with
  /// a integer row value (of a tile or a pixel) defined by a tiling scheme.
  ///
  /// The target geospatial [y] coordinate could be a projected y (metric) or a
  /// geographic latitude coordinate defined by a spatial coordinate reference
  /// system.
  double fromScaledY(num y, {num height = 256});
}
