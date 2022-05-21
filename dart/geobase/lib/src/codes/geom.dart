// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

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
  point('POINT', 'Point'),

  /// The type for the `LINESTRING` geometry.
  lineString('LINESTRING', 'LineString'),

  /// The type for the `POLYGON` geometry.
  polygon('POLYGON', 'Polygon'),

  /// The type for the `GEOMETRYCOLLECTION` geometry.
  geometryCollection('GEOMETRYCOLLECTION', 'GeometryCollection'),

  /// The type for the `MULTIPOINT` geometry.
  multiPoint('MULTIPOINT', 'MultiPoint'),

  /// The type for the `MULTILINESTRING` geometry.
  multiLineString('MULTILINESTRING', 'MultiLineString'),

  /// The type for the `MULTIPOLYGON` geometry.
  multiPolygon('MULTIPOLYGON', 'MultiPolygon');

  /// Create an enum for a geometry type.
  const Geom(this.nameWkt, this.nameGeoJson);

  /// The WKT name for an enum, ie. `POINT` for the point type.
  final String nameWkt;

  /// The GeoJSON type for an enum, ie. `Point` for the point type.
  final String nameGeoJson;

  /// True for the collection of other geometries (geometryCollection).
  bool get isCollection => this == Geom.geometryCollection;

  /// True for multi geometries (multiPoint, multiLineString, multiPolygon).
  bool get isMulti =>
      this == Geom.multiPoint ||
      this == Geom.multiLineString ||
      this == Geom.multiPolygon;
}

/*
/// An extension for the [Geom] enum.
extension GeomExtension on Geom {
  /// True for the collection of other geometries (geometryCollection).
  bool get isCollection => this == Geom.geometryCollection;

  /// True for multi geometries (multiPoint, multiLineString, multiPolygon).
  bool get isMulti =>
      this == Geom.multiPoint ||
      this == Geom.multiLineString ||
      this == Geom.multiPolygon;

  /// Returns the WKT name for an enum, ie. `POINT` for the point type.
  String get nameWkt {
    switch (this) {
      case Geom.point:
        return 'POINT';
      case Geom.lineString:
        return 'LINESTRING';
      case Geom.polygon:
        return 'POLYGON';
      case Geom.geometryCollection:
        return 'GEOMETRYCOLLECTION';
      case Geom.multiPoint:
        return 'MULTIPOINT';
      case Geom.multiLineString:
        return 'MULTILINESTRING';
      case Geom.multiPolygon:
        return 'MULTIPOLYGON';
    }
  }

  /// Returns the GeoJSON type for an enum, ie. `Point` for the point type.
  String get nameGeoJson {
    switch (this) {
      case Geom.point:
        return 'Point';
      case Geom.lineString:
        return 'LineString';
      case Geom.polygon:
        return 'Polygon';
      case Geom.geometryCollection:
        return 'GeometryCollection';
      case Geom.multiPoint:
        return 'MultiPoint';
      case Geom.multiLineString:
        return 'MultiLineString';
      case Geom.multiPolygon:
        return 'MultiPolygon';
    }
  }
}
*/
