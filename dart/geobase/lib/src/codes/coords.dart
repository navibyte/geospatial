// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enum for coordinate types.
enum Coords {
  /// Projected or cartesian coordinates (x, y).
  ///
  /// Coordinates are 2D and not measured.
  xy(
    coordinateDimension: 2,
    spatialDimension: 2,
    is3D: false,
    isMeasured: false,
    isGeographic: false,
    specifierWkt: null,
  ),

  /// Projected or cartesian coordinates (x, y, z).
  ///
  /// Coordinates are 3D and not measured.
  xyz(
    coordinateDimension: 3,
    spatialDimension: 3,
    is3D: true,
    isMeasured: false,
    isGeographic: false,
    specifierWkt: 'Z',
  ),

  /// Projected or cartesian coordinates (x, y, m).
  ///
  /// Coordinates are 2D and measured.
  xym(
    coordinateDimension: 3,
    spatialDimension: 2,
    is3D: false,
    isMeasured: true,
    isGeographic: false,
    specifierWkt: 'M',
  ),

  /// Projected or cartesian coordinates (x, y, z, m).
  ///
  /// Coordinates are 3D and measured.
  xyzm(
    coordinateDimension: 4,
    spatialDimension: 3,
    is3D: true,
    isMeasured: true,
    isGeographic: false,
    specifierWkt: 'ZM',
  ),

  /// Geographic coordinates (longitude, latitude).
  ///
  /// Coordinates are 2D and not measured.
  lonLat(
    coordinateDimension: 2,
    spatialDimension: 2,
    is3D: false,
    isMeasured: false,
    isGeographic: true,
    specifierWkt: null,
  ),

  /// Geographic coordinates (longitude, latitude, elevation).
  ///
  /// Coordinates are 3D and not measured.
  lonLatElev(
    coordinateDimension: 3,
    spatialDimension: 3,
    is3D: true,
    isMeasured: false,
    isGeographic: true,
    specifierWkt: 'Z',
  ),

  /// Geographic coordinates (longitude, latitude, m).
  ///
  /// Coordinates are 2D and measured.
  lonLatM(
    coordinateDimension: 3,
    spatialDimension: 2,
    is3D: false,
    isMeasured: true,
    isGeographic: true,
    specifierWkt: 'M',
  ),

  /// Geographic coordinates (longitude, latitude, elevation, m).
  ///
  /// Coordinates are 3D and measured.
  lonLatElevM(
    coordinateDimension: 4,
    spatialDimension: 3,
    is3D: true,
    isMeasured: true,
    isGeographic: true,
    specifierWkt: 'ZM',
  );

  /// Create an enum for a coordinate type.
  const Coords({
    required this.coordinateDimension,
    required this.spatialDimension,
    required this.is3D,
    required this.isMeasured,
    required this.isGeographic,
    required this.specifierWkt,
  });

  /// The number of coordinate values (2, 3 or 4).
  final int coordinateDimension;

  /// The number of spatial coordinate values (2 for 2D or 3 for 3D).
  final int spatialDimension;

  /// True if coordinates represents a 3D position (with z or elev coordinate).
  final bool is3D;

  /// True if coordinates represents a measured position with m coordinate.
  final bool isMeasured;

  /// True for geographic coordinates (with longitude and latitude).
  ///
  /// If false, then coordinates are projected or cartesian (with x and y).
  final bool isGeographic;

  /// An optional WKT specifier for coordinates, ie. `Z`, `M` or `ZM`.
  final String? specifierWkt;

  /// Selects a [Coords] enum based on [isGeographic], [is3D] and [isMeasured].
  static Coords select({
    required bool isGeographic,
    required bool is3D,
    required bool isMeasured,
  }) {
    if (isGeographic) {
      if (is3D) {
        return isMeasured ? Coords.lonLatElevM : Coords.lonLatElev;
      } else {
        return isMeasured ? Coords.lonLatM : Coords.lonLat;
      }
    } else {
      if (is3D) {
        return isMeasured ? Coords.xyzm : Coords.xyz;
      } else {
        return isMeasured ? Coords.xym : Coords.xy;
      }
    }
  }
}

/*
/// An extension for the [Coords] enum.
extension CoordsExtension on Coords {
  /// Selects a [Coords] enum based on [isGeographic], [is3D] and [isMeasured].
  static Coords select({
    required bool isGeographic,
    required bool is3D,
    required bool isMeasured,
  }) {
    if (isGeographic) {
      if (is3D) {
        return isMeasured ? Coords.lonLatElevM : Coords.lonLatElev;
      } else {
        return isMeasured ? Coords.lonLatM : Coords.lonLat;
      }
    } else {
      if (is3D) {
        return isMeasured ? Coords.xyzm : Coords.xyz;
      } else {
        return isMeasured ? Coords.xym : Coords.xy;
      }
    }
  }

  /// The number of coordinate values (2, 3 or 4).
  int get coordinateDimension {
    switch (this) {
      case Coords.xy:
      case Coords.lonLat:
        return 2;
      case Coords.xyz:
      case Coords.lonLatElev:
        return 3;
      case Coords.xym:
      case Coords.lonLatM:
        return 3;
      case Coords.xyzm:
      case Coords.lonLatElevM:
        return 4;
    }
  }

  /// The number of spatial coordinate values (2 for 2D or 3 for 3D).
  int get spatialDimension {
    switch (this) {
      case Coords.xy:
      case Coords.lonLat:
        return 2;
      case Coords.xyz:
      case Coords.lonLatElev:
        return 3;
      case Coords.xym:
      case Coords.lonLatM:
        return 2;
      case Coords.xyzm:
      case Coords.lonLatElevM:
        return 3;
    }
  }

  /// True if coordinates represents a 3D position (with z or elev coordinate).
  bool get is3D =>
      this == Coords.xyz ||
      this == Coords.xyzm ||
      this == Coords.lonLatElev ||
      this == Coords.lonLatElevM;

  /// True if coordinates represents a measured position with m coordinate.
  bool get isMeasured =>
      this == Coords.xym ||
      this == Coords.xyzm ||
      this == Coords.lonLatM ||
      this == Coords.lonLatElevM;

  /// True for geographic coordinates (with longitude and latitude).
  ///
  /// If false is returned, then coordinates are projected or cartesian (with
  /// x and y coordinates).
  bool get isGeographic =>
      this == Coords.lonLat ||
      this == Coords.lonLatElev ||
      this == Coords.lonLatM ||
      this == Coords.lonLatElevM;

  /// Returns an optional WKT specifier for coordinates, ie. `Z`, `M` or `ZM`.
  String? get specifierWkt {
    switch (this) {
      case Coords.xy:
      case Coords.lonLat:
        return null;
      case Coords.xyz:
      case Coords.lonLatElev:
        return 'Z';
      case Coords.xym:
      case Coords.lonLatM:
        return 'M';
      case Coords.xyzm:
      case Coords.lonLatElevM:
        return 'ZM';
    }
  }
}
*/
