// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'coords.dart';

// EWKB type flags
const _ewkbDimensionalityFlagZ = 0x80000000;
const _ewkbDimensionalityFlagM = 0x40000000;
const _ewkbSridFlag = 0x20000000;

/// An enum for geometry types.
///
/// Geometry types introduced above are based on the
/// [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
/// standard by [The Open Geospatial Consortium](https://www.ogc.org/).
///
/// The types are also compatible with
/// [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
/// and [three flavors of WKB](https://libgeos.org/specifications/wkb/).
enum Geom {
  /// The type for the `POINT` geometry.
  point(
    wktName: 'POINT',
    geoJsonName: 'Point',
    wkbId2D: 1,
  ),

  /// The type for the `LINESTRING` geometry.
  lineString(
    wktName: 'LINESTRING',
    geoJsonName: 'LineString',
    wkbId2D: 2,
  ),

  /// The type for the `POLYGON` geometry.
  polygon(
    wktName: 'POLYGON',
    geoJsonName: 'Polygon',
    wkbId2D: 3,
  ),

  /// The type for the `MULTIPOINT` geometry.
  multiPoint(
    wktName: 'MULTIPOINT',
    geoJsonName: 'MultiPoint',
    wkbId2D: 4,
  ),

  /// The type for the `MULTILINESTRING` geometry.
  multiLineString(
    wktName: 'MULTILINESTRING',
    geoJsonName: 'MultiLineString',
    wkbId2D: 5,
  ),

  /// The type for the `MULTIPOLYGON` geometry.
  multiPolygon(
    wktName: 'MULTIPOLYGON',
    geoJsonName: 'MultiPolygon',
    wkbId2D: 6,
  ),

  /// The type for the `GEOMETRYCOLLECTION` geometry.
  geometryCollection(
    wktName: 'GEOMETRYCOLLECTION',
    geoJsonName: 'GeometryCollection',
    wkbId2D: 7,
  );

  /// Create an enum for a geometry type.
  const Geom({
    required this.wktName,
    required this.geoJsonName,
    required this.wkbId2D,
  });

  /// The WKT name for the geometry type, ie. `POINT` for the point type.
  final String wktName;

  /// The GeoJSON type for the geometry type, ie. `Point` for the point type.
  final String geoJsonName;

  /// The WKB type for the (2-dimensional) geometry, ie. `1` for the point type.
  ///
  /// Expected values are:
  /// * `1` for the `point` type
  /// * `2` for the `lineString` type
  /// * `3` for the `polygon` type
  /// * `4` for the `multiPoint` type
  /// * `5` for the `multiLineString` type
  /// * `6` for the `multiPolygon` type
  /// * `7` for the `geometryCollection` type
  ///
  /// References:
  /// * [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
  final int wkbId2D;

  /// True for the collection of other geometries (geometryCollection).
  bool get isCollection => this == Geom.geometryCollection;

  /// True for multi geometries (multiPoint, multiLineString, multiPolygon).
  bool get isMulti =>
      this == Geom.multiPoint ||
      this == Geom.multiLineString ||
      this == Geom.multiPolygon;

  /// The WKB type for this geometry type and the given [coordinateType].
  ///
  /// Expected values are:
  ///
  /// Geometry             | 2D   | Z    | M    | ZM
  /// -------------------- | ---- | ---- | ---- | ----
  /// `point`              | 0001 | 1001 | 2001 | 3001
  /// `lineString`         | 0002 | 1002 | 2002 | 3002
  /// `polygon`            | 0003 | 1003 | 2003 | 3003
  /// `multiPoint`         | 0004 | 1004 | 2004 | 3004
  /// `multiLineString`    | 0005 | 1005 | 2005 | 3005
  /// `multiPolygon`       | 0006 | 1006 | 2006 | 3006
  /// `geometryCollection` | 0007 | 1007 | 2007 | 3007
  ///
  /// References:
  /// * [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
  ///
  /// See also [extendedWkbId] to get a geometry type as used by Extended WKB.
  int wkbId(Coords coordinateType) => coordinateType.wkbId + wkbId2D;

  /// The Extended WKB (EWKB) type for this geometry type, the given
  /// [coordinateType] and [hasSRID].
  ///
  /// The base value of the geometry type is:
  /// * `1` for the `point` type
  /// * `2` for the `lineString` type
  /// * `3` for the `polygon` type
  /// * `4` for the `multiPoint` type
  /// * `5` for the `multiLineString` type
  /// * `6` for the `multiPolygon` type
  /// * `7` for the `geometryCollection` type
  ///
  /// Following Extended WKB (EWKB) flags are added to the returned id using
  /// the bit-wise OR operator:
  /// * If `coordinateType.is3D` is true, then flag `0x80000000` is set.
  /// * If `coordinateType.isMeasured` is true, then flag `0x40000000` is set.
  /// * If [hasSRID] is true, then flag `0x20000000` is set.
  ///
  /// See also [wkbId] to get a geometry type as specified by the standard.
  int extendedWkbId(Coords coordinateType, {bool hasSRID = false}) {
    var id = wkbId2D;
    if (coordinateType.is3D) {
      id |= _ewkbDimensionalityFlagZ;
    }
    if (coordinateType.isMeasured) {
      id |= _ewkbDimensionalityFlagM;
    }
    if (hasSRID) {
      id |= _ewkbSridFlag;
    }
    return id;
  }

  /// Selects a [Geom] enum based on the WKB type [id].
  ///
  /// Expected values (for the 2-dimensional geometry) are:
  /// * `1` for the `point` type
  /// * `2` for the `lineString` type
  /// * `3` for the `polygon` type
  /// * `4` for the `multiPoint` type
  /// * `5` for the `multiLineString` type
  /// * `6` for the `multiPolygon` type
  /// * `7` for the `geometryCollection` type
  ///
  /// Supports parsing a geometry type also from Extended WKB (EWKB) type.
  ///
  /// References:
  /// * [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
  /// * [GEOS : Well-Known Binary (WKB)](https://libgeos.org/specifications/wkb/)
  /// * [PostGIS : ST_AsEWKB](https://postgis.net/docs/ST_AsEWKB.html)
  static Geom fromWkbId(int id) {
    // Take only 3 least-significant bytes of 4 byte unsigned integer.
    // (as Extended WKB specifies flags on most-significant byte)
    final id24 = id & 0xffffff;

    // Get the geometry type.
    switch (id24 % 1000) {
      case 1:
        return Geom.point;
      case 2:
        return Geom.lineString;
      case 3:
        return Geom.polygon;
      case 4:
        return Geom.multiPoint;
      case 5:
        return Geom.multiLineString;
      case 6:
        return Geom.multiPolygon;
      case 7:
        return Geom.geometryCollection;
      default:
        throw FormatException('Invalid WKB id $id');
    }
  }
}
