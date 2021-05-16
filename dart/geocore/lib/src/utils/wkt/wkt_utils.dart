// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../../base.dart';

final _splitByWhitespace = RegExp(r'\s+');

FormatException invalidWkt(String wkt) => FormatException('Invalid wkt: $wkt');

FormatException invalidCoords(String coords) =>
    FormatException('Invalid coords: $coords');

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

Iterable<int> parseWktCoordsInt(String coords) {
  final parts = _omitParenthesis(coords.trim()).split(_splitByWhitespace);
  if (parts.length < 2) {
    throw invalidCoords(coords);
  }
  return parts
      .map<int>((value) => int.tryParse(value) ?? double.parse(value).round());
}

T parseWktPoint<T extends Point>(String point, PointFactory<T> pointFactory) =>
    pointFactory.newFrom(parseWktCoords(point));

T parseWktPointInt<T extends Point>(
        String point, PointFactory<T> pointFactory) =>
    pointFactory.newFrom(parseWktCoordsInt(point));

PointSeries<T> parseWktPointSeries<T extends Point>(
        String pointSeries, PointFactory<T> pointFactory) =>
    PointSeries<T>.from(pointSeries
        .split(',')
        .map<T>((point) => pointFactory.newFrom(parseWktCoords(point))));

LineString<T> parseWktLineString<T extends Point>(
        String lineString, PointFactory<T> pointFactory,
        {LineStringType type = LineStringType.any}) =>
    LineString<T>(parseWktPointSeries<T>(lineString, pointFactory), type: type);

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

Polygon<T> parseWktPolygon<T extends Point>(
        String polygon, PointFactory<T> pointFactory) =>
    Polygon<T>(parseWktLineStringSeries<T>(polygon, pointFactory,
        type: LineStringType.ring));

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

MultiPoint<T> parseWktMultiPoint<T extends Point>(
        String multiPoint, PointFactory<T> pointFactory) =>
    MultiPoint<T>(parseWktPointSeries<T>(multiPoint, pointFactory));

MultiLineString<T> parseWktMultiLineString<T extends Point>(
        String multiLineString, PointFactory<T> pointFactory) =>
    MultiLineString<T>(
        parseWktLineStringSeries<T>(multiLineString, pointFactory));

MultiPolygon<T> parseWktMultiPolygon<T extends Point>(
        String multiPolygon, PointFactory<T> pointFactory) =>
    MultiPolygon<T>(parseWktPolygonSeries<T>(multiPolygon, pointFactory));

String _omitParenthesis(String str) => str.startsWith('(') && str.endsWith(')')
    ? str.substring(1, str.length - 1)
    : str;
