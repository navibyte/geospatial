// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/base/spatial.dart';
import '/src/coordinates/cartesian.dart';
import '/src/coordinates/geographic.dart';
import '/src/parse/factory.dart';
import '/src/utils/wkt_data.dart';

/// Creates a WKT factory instace using the [point] factory.
///
/// An optional [pointWithM] factory can be given to instantiate any point
/// objects with M coordinates.
///
/// Supported WKT geometry types: 'POINT', 'LINESTRING', 'POLYGON',
/// 'MULTIPOINT', 'MULTILINESTRING', 'MULTIPOLYGON', 'GEOMETRYCOLLECTION'.
///
/// See [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry).
WktFactory<T> wkt<T extends Point>(
  PointFactory<T> point, [
  PointFactory<T>? pointWithM,
]) =>
    WktFactory<T>(
      pointFactory: ({required bool expectM}) =>
          expectM ? pointWithM ?? point : point,
    );

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
  pointFactory: geographicPointsWithM,
);

/// The default WKT factory instace assuming cartesian or projected coordinates.
///
/// Result type candidates for point objects: [Point2], [Point2m], [Point3],
/// [Point3m].
///
/// Supported WKT geometry types: 'POINT', 'LINESTRING', 'POLYGON',
/// 'MULTIPOINT', 'MULTILINESTRING', 'MULTIPOLYGON', 'GEOMETRYCOLLECTION'.
///
/// See [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry).
const wktCartesian = WktFactory<Point>(
  pointFactory: cartesianPointsWithM,
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
  BoundedSeries<Geometry> parseAll<T extends PointType>(
    Object data, {
    Range? range,
  }) {
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
