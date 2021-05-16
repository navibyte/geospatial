// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math';

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
/// 'MULTIPOINT', 'MULTILINESTRING', 'MULTIPOLYGON'.
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
/// 'MULTIPOINT', 'MULTILINESTRING', 'MULTIPOLYGON'.
///
/// See [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry).
const wktProjected = WktFactory<Point>(
  pointFactory: projectedPointFactoryAllowingM,
);

/// A geospatial object factory capable of parsing WKT geometries from text.
///
/// Supported WKT geometry types: 'POINT', 'LINESTRING', 'POLYGON',
/// 'MULTIPOINT', 'MULTILINESTRING', 'MULTIPOLYGON'.
///
/// See [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry).
class WktFactory<PointType extends Point> {
  const WktFactory({required this.pointFactory});

  /// A function to return a factory creating points from coordinate values.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom point instances.
  final PointFactory<PointType> Function({required bool expectM}) pointFactory;

  PointFactory<T> _resolve<T extends PointType>({required bool expectM}) =>
      T == PointType
          ? pointFactory(expectM: expectM) as PointFactory<T>
          : CastingPointFactory<T>(pointFactory(expectM: expectM));

  /// Parses a geometry from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  Geometry parse<T extends PointType>(Object data) {
    if (data is! String) {
      throw FormatException('Unknown data.');
    }
    final trimmed = data.trim();
    for (var type = 0; type < _types.length; type++) {
      if (trimmed.startsWith(_types[type])) {
        var i = _types[type].length;
        var expectM = false;
        var expectZ = false;
        while (i < trimmed.length) {
          final c = trimmed[i];
          switch (c) {
            case 'M':
              expectM = true;
              break;
            case 'Z':
              expectZ = true;
              break;
            case 'E':
              if (trimmed.startsWith('EMPTY', i)) {
                switch (type) {
                  case 0: // POINT
                    return Point.empty(is3D: expectZ, hasM: expectM);
                  default:
                    // todo : more specific empty geometries?
                    return Geometry.empty();
                }
              } else {
                throw invalidWkt(trimmed);
              }
            case '(':
              if (trimmed[trimmed.length - 1] == ')') {
                final data = trimmed.substring(i + 1, trimmed.length - 1);
                final pf = _resolve<T>(expectM: expectM);
                switch (type) {
                  case 0: // POINT
                    return parseWktPoint<T>(data, pf);
                  case 1: // LINESTRING
                    return parseWktLineString<T>(data, pf);
                  case 2: // POLYGON
                    return parseWktPolygon<T>(data, pf);
                  case 3: // MULTIPOINT
                    return parseWktMultiPoint<T>(data, pf);
                  case 4: // MULTILINESTRING
                    return parseWktMultiLineString<T>(data, pf);
                  case 5: // MULTIPOLYGON
                    return parseWktMultiPolygon<T>(data, pf);
                }
              } else {
                throw invalidWkt(trimmed);
              }
              break;
            default:
              if (!_isBlank(c)) throw invalidWkt(trimmed);
          }
          i++;
        }
        break;
      }
    }
    throw invalidWkt(trimmed);
  }
}

const _types = <String>[
  'POINT',
  'LINESTRING',
  'POLYGON',
  'MULTIPOINT',
  'MULTILINESTRING',
  'MULTIPOLYGON'
  // todo : 'GEOMETRYCOLLECTION'
];

bool _isBlank(String str) => str.trim().isEmpty;
