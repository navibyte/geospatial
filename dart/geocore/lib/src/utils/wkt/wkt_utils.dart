// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/base/spatial.dart';

final _splitByWhitespace = RegExp(r'\s+');

/// Create an exception telling [coords] text is invalid.
FormatException _invalidCoords(String coords) =>
    FormatException('Invalid coords: $coords');

/// Parses a num iterable from [coords] with values separated by white space.
@internal
Iterable<num> parseWktCoords(String coords) {
  final parts = _omitParenthesis(coords.trim()).split(_splitByWhitespace);
  // NOTE: need to know expected coord dim
  if (parts.length < 2) {
    throw _invalidCoords(coords);
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
@internal
Iterable<int> parseWktCoordsInt(String coords) {
  final parts = _omitParenthesis(coords.trim()).split(_splitByWhitespace);
  if (parts.length < 2) {
    throw _invalidCoords(coords);
  }
  return parts
      .map<int>((value) => int.tryParse(value) ?? double.parse(value).round());
}

/// Parses a point of [T] with num coords from [point] using the [pointFactory].
///
/// Throws FormatException if parsing fails.
@internal
T parseWktPoint<T extends Point>(String point, PointFactory<T> pointFactory) =>
    pointFactory.newFrom(parseWktCoords(point));

/// Parses a point of [T] with int coords from [point] using the [pointFactory].
///
/// Throws FormatException if parsing fails.
@internal
T parseWktPointInt<T extends Point>(
  String point,
  PointFactory<T> pointFactory,
) =>
    pointFactory.newFrom(parseWktCoordsInt(point));

/// Parses a series of points of [T] from [pointSeries].
///
/// Points are separated by `,` chars. Each point is parsed using the
/// [pointFactory].
///
/// Throws FormatException if parsing fails.
@internal
PointSeries<T> parseWktPointSeries<T extends Point>(
  String pointSeries,
  PointFactory<T> pointFactory,
) =>
    PointSeries<T>.from(
      pointSeries
          .split(',')
          .map<T>((point) => pointFactory.newFrom(parseWktCoords(point))),
    );

String _omitParenthesis(String str) => str.startsWith('(') && str.endsWith(')')
    ? str.substring(1, str.length - 1)
    : str;
