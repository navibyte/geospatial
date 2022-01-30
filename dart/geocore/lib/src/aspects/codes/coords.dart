// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enum for coordinate types.
enum Coords {
  /// Coordinates are `2D`, with points missing Z and M coordinates.
  /// 
  /// That is points are expected to be (x, y) or (lon, lat).
  is2D,

  /// Coordinates are `3D`, with points containing Z (or elev) coordinate.
  /// 
  /// That is points are expected to be (x, y, z) or (lon, lat, elev).
  is3D,

  /// Coordinates are both `2D` and `measured`, with points containing M.
  /// 
  /// That is points are expected to be (x, y, m) or (lon, lat, m).
  is2DAndMeasured,

  /// Coordinates are both `3D` and `measured`, with points containing Z and M.
  /// 
  /// That is points are expected to be (x, y, z, m) or (lon, lat, elev, m).
  is3DAndMeasured,
}

/// An extension for the [Coords] enum.
extension CoordsExtension on Coords {
  /// Selects an enum value of [Coords] based on [hasZ] and [hasM].
  static Coords select({required bool hasZ, required bool hasM}) {
    if (hasZ) {
      return hasM ? Coords.is3DAndMeasured : Coords.is3D;
    } else {
      return hasM ? Coords.is2DAndMeasured : Coords.is2D;
    }
  }

  /// Returns true if coordinates has Z.
  bool get hasZ => this == Coords.is3D || this == Coords.is3DAndMeasured;

  /// Returns true if coordinates has M.
  bool get hasM =>
      this == Coords.is2DAndMeasured || this == Coords.is3DAndMeasured;

  /// Returns the WKT specifier for coordinates, ie. `Z`, `M` or `ZM`.
  String get specifierWkt {
    switch (this) {
      case Coords.is2D:
        return '';
      case Coords.is3D:
        return 'Z';
      case Coords.is2DAndMeasured:
        return 'M';
      case Coords.is3DAndMeasured:
        return 'ZM';
    }
  }
}
