// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'coords.dart';

/// An enum for geometry types.
///
/// Geometry types introduced above are based on the
/// [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
/// standard by [The Open Geospatial Consortium](https://www.ogc.org/).
///
/// The types are also compatible with
/// [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry).
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
  int wkbId(Coords coordinateType) => coordinateType.wkbId + wkbId2D;

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
  /// References:
  /// * [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
  static Geom fromWkbId(int id) {
    switch (id % 1000) {
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
        throw const FormatException('Invalid WKB id');
    }
  }
}
