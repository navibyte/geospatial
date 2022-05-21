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
