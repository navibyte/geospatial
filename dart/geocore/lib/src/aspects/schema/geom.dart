// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enum for `geometry` types.
///
/// Geometry types introduced above are based on the
/// [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
/// standard by [The Open Geospatial Consortium](https://www.ogc.org/).
///
/// The types are also compatible with
/// [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry).
enum Geom {
  /// The type for the `POINT` geometry.
  point,

  /// The type for the `LINESTRING` geometry.
  lineString,

  /// The type for the `POLYGON` geometry.
  polygon,

  /// The type for the `GEOMETRYCOLLECTION` geometry.
  geometryCollection,

  /// The type for the `MULTIPOINT` geometry.
  multiPoint,

  /// The type for the `MULTILINESTRING` geometry.
  multiLineString,

  /// The type for the `MULTIPOLYGON` geometry.
  multiPolygon,
}

/// An extension for the [Geom] enum.
extension GeomExtension on Geom {
  /// Returns true is this geometry type is a collection type (or "multi").
  bool get isCollection =>
      this == Geom.geometryCollection ||
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
}
