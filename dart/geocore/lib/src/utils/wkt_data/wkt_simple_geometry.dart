// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/codes.dart';
import '/src/base/spatial.dart';
import '/src/data/simple_geometry.dart';
import '/src/parse/factory.dart';
import '/src/utils/wkt.dart';

/// Create an exception telling [wkt] text is invalid.
FormatException _invalidWkt(String wkt) => FormatException('Invalid wkt: $wkt');

/// Parses a line string with points of [T] from [lineString].
///
/// Points are separated by `,` chars. Each point is parsed using the
/// [pointFactory].
///
/// A line string [type] can be given also.
///
/// Throws FormatException if parsing fails.
LineString<T> parseWktLineString<T extends Point>(
  String lineString,
  PointFactory<T> pointFactory, {
  LineStringType type = LineStringType.any,
}) =>
    LineString<T>(parseWktPointSeries<T>(lineString, pointFactory), type: type);

/// Parses a series of line strings with points of [T] from [lineStringSeries].
///
/// Each line string is surrounded by `(` and `)` chars.
///
/// Points in each line string are separated by `,` chars. Each point is parsed
/// using the [pointFactory].
///
/// A line string [type] can be given also.
///
/// Throws FormatException if parsing fails.
BoundedSeries<LineString<T>> parseWktLineStringSeries<T extends Point>(
  String lineStringSeries,
  PointFactory<T> pointFactory, {
  LineStringType type = LineStringType.any,
}) {
  final lineStrings = <LineString<T>>[];
  var ls = 0;
  while (ls < lineStringSeries.length) {
    if (lineStringSeries[ls] == '(') {
      final le = lineStringSeries.indexOf(')', ls);
      if (le == -1) {
        throw _invalidWkt(lineStringSeries);
      } else {
        lineStrings.add(
          parseWktLineString<T>(
            lineStringSeries.substring(ls + 1, le),
            pointFactory,
            type: type,
          ),
        );
        ls = le;
      }
    }
    ls++;
  }
  return BoundedSeries<LineString<T>>.view(lineStrings);
}

/// Parses a polygon with points of [T] from [polygon].
///
/// Each linear ring (outer or inner) in a polygon is surrounded by `(` and `)`
/// chars.
///
/// Points in each linear ring are separated by `,` chars. Each point is parsed
/// using the [pointFactory].
///
/// Throws FormatException if parsing fails.
Polygon<T> parseWktPolygon<T extends Point>(
  String polygon,
  PointFactory<T> pointFactory,
) =>
    Polygon<T>(
      parseWktLineStringSeries<T>(
        polygon,
        pointFactory,
        type: LineStringType.ring,
      ),
    );

/// Parses a series of polygons with points of [T] from [polygonSeries].
///
/// Each polygon in a polygon series is surrounded by `(` and `)` chars.
///
/// Each linear ring (outer or inner) in a polygon is surrounded by `(` and `)`
/// chars.
///
/// Points in each linear ring are separated by `,` chars. Each point is parsed
/// using the [pointFactory].
///
/// Throws FormatException if parsing fails.
BoundedSeries<Polygon<T>> parseWktPolygonSeries<T extends Point>(
  String polygonSeries,
  PointFactory<T> pointFactory,
) {
  final polygons = <Polygon<T>>[];
  var ps = 0;
  while (ps < polygonSeries.length) {
    if (polygonSeries[ps] == '(') {
      final lineStrings = <LineString<T>>[];
      var ls = ps + 1;
      while (ls < polygonSeries.length) {
        if (polygonSeries[ls] == ')') {
          break;
        } else if (polygonSeries[ls] == '(') {
          final le = polygonSeries.indexOf(')', ls);
          if (le == -1) {
            throw _invalidWkt(polygonSeries);
          } else {
            lineStrings.add(
              parseWktLineString<T>(
                polygonSeries.substring(ls + 1, le),
                pointFactory,
                type: LineStringType.ring,
              ),
            );
            ls = le;
          }
        }
        ls++;
      }
      final pe = polygonSeries.indexOf(')', ls);
      if (pe == -1) {
        throw _invalidWkt(polygonSeries);
      } else {
        polygons
            .add(Polygon<T>(BoundedSeries<LineString<T>>.from(lineStrings)));
        ps = pe;
      }
    }
    ps++;
  }
  return BoundedSeries<Polygon<T>>.from(polygons);
}

/// Parses a multi point of [T] from [multiPoint].
///
/// Points are separated by `,` chars. Each point is parsed using the
/// [pointFactory].
///
/// Throws FormatException if parsing fails.
MultiPoint<T> parseWktMultiPoint<T extends Point>(
  String multiPoint,
  PointFactory<T> pointFactory,
) =>
    MultiPoint<T>(parseWktPointSeries<T>(multiPoint, pointFactory));

/// Parses a multi line string with points of [T] from [multiLineString].
///
/// Each line string is surrounded by `(` and `)` chars.
///
/// Points in each line string are separated by `,` chars. Each point is parsed
/// using the [pointFactory].
///
/// A line string [type] can be given also.
///
/// Throws FormatException if parsing fails.
MultiLineString<T> parseWktMultiLineString<T extends Point>(
  String multiLineString,
  PointFactory<T> pointFactory, {
  LineStringType type = LineStringType.any,
}) =>
    MultiLineString<T>(
      parseWktLineStringSeries<T>(
        multiLineString,
        pointFactory,
        type: type,
      ),
    );

/// Parses a multi of polygon with points of [T] from [multiPolygon].
///
/// Each polygon in a polygon series is surrounded by `(` and `)` chars.
///
/// Each linear ring (outer or inner) in a polygon is surrounded by `(` and `)`
/// chars.
///
/// Points in each linear ring are separated by `,` chars. Each point is parsed
/// using the [pointFactory].
///
/// Throws FormatException if parsing fails.
MultiPolygon<T> parseWktMultiPolygon<T extends Point>(
  String multiPolygon,
  PointFactory<T> pointFactory,
) =>
    MultiPolygon<T>(parseWktPolygonSeries<T>(multiPolygon, pointFactory));

/// Parses a single geometry with points of [T] from [text].
///
/// Throws FormatException if parsing fails.
Geometry parseWktGeometry<T extends Point>(
  String text, {
  required PointFactory<T> Function({required bool expectM}) resolve,
}) {
  for (var type = 0; type < _types.length; type++) {
    if (text.startsWith(_types[type])) {
      var i = _types[type].length;
      var expectM = false;
      var expectZ = false;
      while (i < text.length) {
        final c = text[i];
        switch (c) {
          case 'M':
            expectM = true;
            break;
          case 'Z':
            expectZ = true;
            break;
          case 'E':
            if (text.startsWith('EMPTY', i)) {
              switch (type) {
                case 0: // POINT
                  return Point.empty(
                    type: CoordsExtension.select(hasZ: expectZ, hasM: expectM),
                  );
                default:
                  // todo : more specific empty geometries?
                  return Geometry.empty();
              }
            } else {
              throw _invalidWkt(text);
            }
          case '(':
            if (text[text.length - 1] == ')') {
              final data = text.substring(i + 1, text.length - 1);
              final pf = resolve(expectM: expectM);
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
                case 6: // GEOMETRYCOLLECTION
                  return parseWktGeometryCollection<T>(data, resolve: resolve);
              }
            } else {
              throw _invalidWkt(text);
            }
            break;
          default:
            if (!_isBlank(c)) throw _invalidWkt(text);
        }
        i++;
      }
      break;
    }
  }
  throw _invalidWkt(text);
}

/// Parses a single next available geometry with points of [T] from [text].
///
/// Throws FormatException if parsing fails.
Geometry parseNextWktGeometry<T extends Point>(
  String text, {
  required PointFactory<T> Function({required bool expectM}) resolve,
}) {
  final start = _findWktTokenStart(text);
  if (start >= 0) {
    final end = _findWktTokenEnd(text, start);
    if (end > start) {
      return parseWktGeometry<T>(text.substring(start, end), resolve: resolve);
    }
  }
  throw _invalidWkt(text);
}

/// Parses a series of geometries with points of [T] from [text].
///
/// An optional [range] specificies start offset and optional limit count
/// specifying a geometry object range to be returned on a collection.
///
/// Throws FormatException if parsing fails.
BoundedSeries<Geometry> parseWktGeometrySeries<T extends Point>(
  String text, {
  required PointFactory<T> Function({required bool expectM}) resolve,
  Range? range,
}) {
  final geometries = <Geometry>[];
  final rangeLimit = range?.limit;
  if (rangeLimit == null || rangeLimit > 0) {
    final rangeStart = range?.start;
    var startChar = 0;
    var tokenIndex = 0;
    var countAdded = 0;
    while ((startChar = _findWktTokenStart(text, offset: startChar)) != -1) {
      final endChar = _findWktTokenEnd(text, startChar);
      if (endChar > startChar) {
        if (rangeStart == null || tokenIndex >= rangeStart) {
          geometries.add(
            parseWktGeometry<T>(
              text.substring(startChar, endChar),
              resolve: resolve,
            ),
          );
          countAdded++;
          if (rangeLimit != null && countAdded >= rangeLimit) {
            break;
          }
        }
        startChar = endChar;
        tokenIndex++;
      } else {
        throw _invalidWkt(text);
      }
    }
  }
  return BoundedSeries<Geometry>.from(geometries);
}

/// Parses a geometry collection with points of [T] from [text].
///
/// Throws FormatException if parsing fails.
GeometryCollection<Geometry> parseWktGeometryCollection<T extends Point>(
  String text, {
  required PointFactory<T> Function({required bool expectM}) resolve,
}) =>
    GeometryCollection<Geometry>(
      parseWktGeometrySeries(text, resolve: resolve),
    );

int _findWktTokenStart(String text, {int offset = 0}) {
  final len = text.length;
  var i = offset;
  while (i < len) {
    final c = text[i];
    if (_isBlank(c) || c == ',') {
      i++;
    } else {
      return i;
    }
  }
  return -1;
}

int _findWktTokenEnd(String text, int start) {
  final len = text.length;
  var i = start;
  var depth = 0;
  while (i < len) {
    final c = text[i];
    if (c == '(') {
      depth++;
    } else if (c == ')') {
      depth--;
      if (depth == 0) {
        // got last ")" in token like "POLYGON ((3 1, 4 4, 2 4, 1 2, 3 1))"
        // include that last ")"
        return i + 1;
      }
    } else if (c == ',') {
      if (depth == 0) {
        // got separating "," between token, do not include
        return i;
      }
    } else if (c == 'E') {
      if (text.startsWith('EMPTY', i)) {
        // propably end part of something like "POINT EMPTY"
        return i + 5;
      }
    }
    i++;
  }
  return i; // end of string, i == len + 1, return as end
}

const _types = <String>[
  'POINT',
  'LINESTRING',
  'POLYGON',
  'MULTIPOINT',
  'MULTILINESTRING',
  'MULTIPOLYGON',
  'GEOMETRYCOLLECTION',
];

bool _isBlank(String str) => str.trim().isEmpty;
