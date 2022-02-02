// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enum for coordinate types.
enum Coords {
  /// Coordinates are `2D`, with points missing z and m coordinates.
  /// 
  /// That is points are expected to be (x, y) or (lon, lat).
  xy,

  /// Coordinates are `3D`, with points containing z (or elevation) coordinate.
  /// 
  /// That is points are expected to be (x, y, z) or (lon, lat, elev).
  xyz,

  /// Coordinates are both `2D` and `measured`, with points containing m.
  /// 
  /// That is points are expected to be (x, y, m) or (lon, lat, m).
  xym,

  /// Coordinates are both `3D` and `measured`, with points containing z and m.
  /// 
  /// That is points are expected to be (x, y, z, m) or (lon, lat, elev, m).
  xyzm,
}

/// An extension for the [Coords] enum.
extension CoordsExtension on Coords {
  /// Selects an enum value of [Coords] based on [hasZ] and [hasM].
  static Coords select({required bool hasZ, required bool hasM}) {
    if (hasZ) {
      return hasM ? Coords.xyzm : Coords.xyz;
    } else {
      return hasM ? Coords.xym : Coords.xy;
    }
  }

  /// Returns true if coordinates has z coordinate.
  bool get is3D => this == Coords.xyz || this == Coords.xyzm;

  /// Returns true if coordinates has m coordinate.
  bool get isMeasured =>
      this == Coords.xym || this == Coords.xyzm;

  /// Returns the WKT specifier for coordinates, ie. `Z`, `M` or `ZM`.
  String get specifierWkt {
    switch (this) {
      case Coords.xy:
        return '';
      case Coords.xyz:
        return 'Z';
      case Coords.xym:
        return 'M';
      case Coords.xyzm:
        return 'ZM';
    }
  }
}
