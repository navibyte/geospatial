// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enum for coordinate types (by spatial dimension and whether is measured).
enum Coords {
  /// 2D coordinates as projected (x, y) or geographic (lon, lat).
  xy(
    coordinateDimension: 2,
    spatialDimension: 2,
    is3D: false,
    isMeasured: false,
    wkbId: 0,
    wktSpecifier: null,
    indexForZ: null,
    indexForM: null,
  ),

  /// 3D coordinates as projected (x, y, z) or geographic (lon, lat, elev).
  xyz(
    coordinateDimension: 3,
    spatialDimension: 3,
    is3D: true,
    isMeasured: false,
    wkbId: 1000,
    wktSpecifier: 'Z',
    indexForZ: 2,
    indexForM: null,
  ),

  /// 2D measured coordinates as projected (x, y, m) or geographic (lon, lat,
  /// m).
  xym(
    coordinateDimension: 3,
    spatialDimension: 2,
    is3D: false,
    isMeasured: true,
    wkbId: 2000,
    wktSpecifier: 'M',
    indexForZ: null,
    indexForM: 2,
  ),

  /// 3D measured coordinates as projected (x, y, z, m) or geographic (lon, lat,
  /// elev, m).
  xyzm(
    coordinateDimension: 4,
    spatialDimension: 3,
    is3D: true,
    isMeasured: true,
    wkbId: 3000,
    wktSpecifier: 'ZM',
    indexForZ: 2,
    indexForM: 3,
  );

  /// Create an enum for a coordinate type.
  const Coords({
    required this.coordinateDimension,
    required this.spatialDimension,
    required this.is3D,
    required this.isMeasured,
    required this.wkbId,
    required this.wktSpecifier,
    required this.indexForZ,
    required this.indexForM,
  });

  /// The number of coordinate values (2, 3 or 4).
  final int coordinateDimension;

  /// The number of spatial coordinate values (2 for 2D or 3 for 3D).
  final int spatialDimension;

  /// True if coordinates represents a 3D position (with z or elev coordinate).
  final bool is3D;

  /// True if coordinates represents a measured position with m coordinate.
  final bool isMeasured;

  /// The WKB type for coordinates, ie. `1000` for coordinates with Z.
  ///
  /// Expected values are:
  /// * `0` for 2D coordinates: (x,y) or (lon,lat)
  /// * `1000` for 3D coordinates: (x,y,z) or (lon,lat,elev)
  /// * `2000` for measured coordinates: (x,y,m) or (lon,lat,m)
  /// * `3000` for 3D / measured coordinates: (x,y,z,m) or (lon,lat,elev,m)
  ///
  /// References:
  /// * [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
  final int wkbId;

  /// An optional WKT specifier for coordinates, ie. `Z`, `M` or `ZM`.
  final String? wktSpecifier;

  /// The index for an optional Z coordinate in a sequence of coordinates.
  ///
  /// The value is 2 for 3D coordinates, and null for 2D coordinates.
  final int? indexForZ;

  /// The index for an optional M coordinate in a sequence of coordinates.
  ///
  /// The value is 2 (for 2D coordinates) and 3 (for 3D coordinates) if this
  /// coordinate type is measured. Otherwise the value is null.
  final int? indexForM;

  /// Selects a [Coords] enum based on [is3D] and [isMeasured].
  static Coords select({
    required bool is3D,
    required bool isMeasured,
  }) {
    if (is3D) {
      return isMeasured ? Coords.xyzm : Coords.xyz;
    } else {
      return isMeasured ? Coords.xym : Coords.xy;
    }
  }

  /// Resolves the coordinate type from [coordinateDimension].
  ///
  /// If [coordinateDimension] is 3, then [xyzForDim3] is used to select
  /// between `xyz` and `xym`.
  ///
  /// Coordinate types resolved:
  ///
  /// Dimension | Coordinate type
  /// --------- | ---------------
  /// 2         | `Coords.xy`
  /// 3         | `Coords.xyz` (if [xyzForDim3] is true)
  /// 3         | `Coords.xym` (if [xyzForDim3] is false)
  /// 4         | `Coords.xyzm`
  /// any other | Throws FormatException
  static Coords fromDimension(
    int coordinateDimension, {
    bool xyzForDim3 = true,
  }) {
    if (coordinateDimension == 4) {
      return Coords.xyzm;
    } else if (coordinateDimension == 3) {
      return xyzForDim3 ? Coords.xyz : Coords.xym;
    } else if (coordinateDimension == 2) {
      return Coords.xy;
    }
    throw const FormatException('invalid coordinate dimension');
  }

  /// Selects a [Coords] enum based on the WKB type [id].
  ///
  /// Expected values are:
  /// * `0` to `7` for 2D coordinates: (x,y) or (lon,lat)
  /// * `1000` to `1007` for 3D coordinates: (x,y,z) or (lon,lat,elev)
  /// * `2000` to `2007` for measured coordinates: (x,y,m) or (lon,lat,m)
  /// * `3000` to `3007` for 3D / measured coordinates: (x,y,z,m) or
  ///   (lon,lat,elev,m)
  ///
  /// Supports parsing a coordinate type also from Extended WKB (EWKB) type with
  /// dimensionality flags:
  /// * If the flag `0x80000000` is on, then z or elev coordinates are expected.
  /// * If the flag `0x40000000` is on, then m coordinates are expected.
  ///
  /// References:
  /// * [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
  /// * [GEOS : Well-Known Binary (WKB)](https://libgeos.org/specifications/wkb/)
  /// * [PostGIS : ST_AsEWKB](https://postgis.net/docs/ST_AsEWKB.html)
  static Coords fromWkbId(int id) {
    // Take only 3 least-significant bytes of 4 byte unsigned integer.
    // (as Extended WKB specifies flags on most-significant byte)
    final id24 = id & 0xffffff;

    // Get the geometry type.
    switch ((id24 ~/ 1000) * 1000) {
      case 0:
        // check special cases for Extented WKB first
        if ((id & 0x80000000) != 0) {
          // EWKB dimensionality flag for Z is on
          if ((id & 0x40000000) != 0) {
            // EWKB dimensionality flag for M is on
            return Coords.xyzm;
          } else {
            return Coords.xyz;
          }
        } else if ((id & 0x40000000) != 0) {
          // EWKB dimensionality flag for M is on
          return Coords.xym;
        }

        // standard WKB, only xy coordinates
        return Coords.xy;
      case 1000:
        return Coords.xyz;
      case 2000:
        return Coords.xym;
      case 3000:
        return Coords.xyzm;
      default:
        throw const FormatException('Invalid WKB id');
    }
  }
}
