// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../../base.dart';
import '../../geo.dart';
import '../../utils/wkt.dart';

import '../factory.dart';

/// The default WKT factory instace assuming geographic CRS80 coordinates.
///
/// Result type candidates for point objects: [GeoPoint2], [GeoPoint2m],
/// [GeoPoint3], [GeoPoint3m].
///
/// Supported WKT geometry types: 'POINT', 'LINESTRING', 'POLYGON',
/// 'MULTIPOINT', 'MULTILINESTRING', 'MULTIPOLYGON', 'GEOMETRYCOLLECTION'.
///
/// See [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry).
const wktGeographic = WktFactory<GeoPoint>(
  pointFactory: geoPointFactoryAllowingM,
);

/// The default WKT factory instace assuming projected coordinates.
///
/// Result type candidates for point objects: [Point2], [Point2m], [Point3],
/// [Point3m].
///
/// Supported WKT geometry types: 'POINT', 'LINESTRING', 'POLYGON',
/// 'MULTIPOINT', 'MULTILINESTRING', 'MULTIPOLYGON', 'GEOMETRYCOLLECTION'.
///
/// See [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry).
const wktProjected = WktFactory<Point>(
  pointFactory: projectedPointFactoryAllowingM,
);

/// A geospatial object factory capable of parsing WKT geometries from text.
///
/// Supported WKT geometry types: 'POINT', 'LINESTRING', 'POLYGON',
/// 'MULTIPOINT', 'MULTILINESTRING', 'MULTIPOLYGON', 'GEOMETRYCOLLECTION'.
///
/// See [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry).
class WktFactory<PointType extends Point> {
  /// Create a factory with [pointFactory].
  const WktFactory({required this.pointFactory});

  /// A function to return a factory creating points from coordinate values.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom point instances.
  final PointFactory<PointType> Function({required bool expectM}) pointFactory;

  /// Parses a single geometry from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  Geometry parse<T extends PointType>(Object data) {
    if (data is! String) {
      throw const FormatException('Unknown data.');
    }
    return parseNextWktGeometry<T>(
      data,
      resolve: ({required bool expectM}) => T == PointType
          ? pointFactory(expectM: expectM) as PointFactory<T>
          : CastingPointFactory<T>(pointFactory(expectM: expectM)),
    );
  }

  /// Parses all geometries from a [data] object.
  ///
  /// An optional [range] specificies start offset and optional limit count
  /// specifying a geometry object range to be returned on a collection.
  ///
  /// Throws FormatException if parsing fails.
  BoundedSeries<Geometry> parseAll<T extends PointType>(Object data,
      {Range? range}) {
    if (data is! String) {
      throw const FormatException('Unknown data.');
    }
    return parseWktGeometrySeries<T>(
      data,
      resolve: ({required bool expectM}) => T == PointType
          ? pointFactory(expectM: expectM) as PointFactory<T>
          : CastingPointFactory<T>(pointFactory(expectM: expectM)),
      range: range,
    );
  }
}
