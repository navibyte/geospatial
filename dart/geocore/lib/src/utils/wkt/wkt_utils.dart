// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../../base.dart';

final _splitByWhitespace = RegExp(r'\s+');

/// Create an exception telling [wkt] text is invalid.
FormatException invalidWkt(String wkt) => FormatException('Invalid wkt: $wkt');

/// Create an exception telling [coords] text is invalid.
FormatException invalidCoords(String coords) =>
    FormatException('Invalid coords: $coords');

/// Parses a num iterable from [coords] with values separated by white space.
Iterable<num> parseWktCoords(String coords) {
  final parts = _omitParenthesis(coords.trim()).split(_splitByWhitespace);
  // todo : need to know expected coord dim
  if (parts.length < 2) {
    throw invalidCoords(coords);
  }
  return parts.map<num>(double.parse);
}
/*
  todo : consider behaviour?

  Iterable<num> parseWktCoords(String coords) => _omitParenthesis(coords.trim())
    .split(_splitByWhitespace)
    .map<num>((value) => int.tryParse(value) ?? double.parse(value));
*/

/// Parses an int iterable from [coords] with values separated by white space.
///
/// Throws FormatException if parsing fails.
Iterable<int> parseWktCoordsInt(String coords) {
  final parts = _omitParenthesis(coords.trim()).split(_splitByWhitespace);
  if (parts.length < 2) {
    throw invalidCoords(coords);
  }
  return parts
      .map<int>((value) => int.tryParse(value) ?? double.parse(value).round());
}

/// Parses a point of [T] with num coords from [point] using the [pointFactory].
///
/// Throws FormatException if parsing fails.
T parseWktPoint<T extends Point>(String point, PointFactory<T> pointFactory) =>
    pointFactory.newFrom(parseWktCoords(point));

/// Parses a point of [T] with int coords from [point] using the [pointFactory].
///
/// Throws FormatException if parsing fails.
T parseWktPointInt<T extends Point>(
        String point, PointFactory<T> pointFactory) =>
    pointFactory.newFrom(parseWktCoordsInt(point));

/// Parses a series of points of [T] from [pointSeries].
///
/// Points are separated by `,` chars. Each point is parsed using the
/// [pointFactory].
///
/// Throws FormatException if parsing fails.
PointSeries<T> parseWktPointSeries<T extends Point>(
        String pointSeries, PointFactory<T> pointFactory) =>
    PointSeries<T>.from(pointSeries
        .split(',')
        .map<T>((point) => pointFactory.newFrom(parseWktCoords(point))));

/// Parses a line string with points of [T] from [lineString].
///
/// Points are separated by `,` chars. Each point is parsed using the
/// [pointFactory].
///
/// A line string [type] can be given also.
///
/// Throws FormatException if parsing fails.
LineString<T> parseWktLineString<T extends Point>(
        String lineString, PointFactory<T> pointFactory,
        {LineStringType type = LineStringType.any}) =>
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
    String lineStringSeries, PointFactory<T> pointFactory,
    {LineStringType type = LineStringType.any}) {
  final lineStrings = <LineString<T>>[];
  var ls = 0;
  while (ls < lineStringSeries.length) {
    if (lineStringSeries[ls] == '(') {
      final le = lineStringSeries.indexOf(')', ls);
      if (le == -1) {
        throw invalidWkt(lineStringSeries);
      } else {
        lineStrings.add(parseWktLineString<T>(
            lineStringSeries.substring(ls + 1, le), pointFactory,
            type: type));
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
        String polygon, PointFactory<T> pointFactory) =>
    Polygon<T>(parseWktLineStringSeries<T>(polygon, pointFactory,
        type: LineStringType.ring));

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
    String polygonSeries, PointFactory<T> pointFactory) {
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
            throw invalidWkt(polygonSeries);
          } else {
            lineStrings.add(parseWktLineString<T>(
                polygonSeries.substring(ls + 1, le), pointFactory,
                type: LineStringType.ring));
            ls = le;
          }
        }
        ls++;
      }
      final pe = polygonSeries.indexOf(')', ls);
      if (pe == -1) {
        throw invalidWkt(polygonSeries);
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
        String multiPoint, PointFactory<T> pointFactory) =>
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
        String multiLineString, PointFactory<T> pointFactory,
        {LineStringType type = LineStringType.any}) =>
    MultiLineString<T>(
        parseWktLineStringSeries<T>(multiLineString, pointFactory, type: type));

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
        String multiPolygon, PointFactory<T> pointFactory) =>
    MultiPolygon<T>(parseWktPolygonSeries<T>(multiPolygon, pointFactory));

String _omitParenthesis(String str) => str.startsWith('(') && str.endsWith(')')
    ? str.substring(1, str.length - 1)
    : str;
