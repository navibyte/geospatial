// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// The default rules to format string representations of coordinates.
///
/// These rules are aligned with GeoJSON formatting of coordinate lists.
///
/// Examples:
/// * point (x, y): `10.1,20.2`
/// * point (x, y, m) or (x, y, z): `10.1,20.2,30.3`
/// * point (x, y, z, m): `10.1,20.2,30.3,40.4`
/// * geopoint (lon, lat): `10.1,20.2`
/// * bounds (min-x, min-y, max-x, max-y): `10.1,10.1,20.2,20.2`
/// * bounds (min-x, min-y, min-z, max-x, max-y, maz-z):
///   * `10.1,10.1,10.1,20.2,20.2,20.2`
/// * point series, line string, multi point (with 2D points):
///   * `[10.1,10.1],[20.2,20.2],[30.3,30.3]`
/// * polygon, multi line string (with 2D points):
///   * `[[35,10],[45,45],[15,40],[10,20],[35,10]]`
/// * multi polygon (with 2D points):
///   * `[[[35,10],[45,45],[15,40],[10,20],[35,10]]]`
/// * coordinates for other geometries with similar principles
const defaultFormat = CoordinatesFormat(
  // decimals: null, (no default value for fraction digits)
  valueDelimiter: ',',
  pointPrefix: '[',
  pointPostfix: ']',
  pointDelimiter: ',',
  boundsPointDelimiter: ',',
  itemPrefix: '[',
  itemPostfix: ']',
  itemDelimiter: ',',
);

/// The WKT like rules to format string representations of coordinates.
///
/// These rules are aligned with WKT (Well-known text representation of
/// geometry) formatting of coordinate lists.
///
/// Examples:
/// * point (x, y): `10.1 20.2`
/// * point (x, y, m) or (x, y, z): `10.1 20.2 30.3`
/// * point (x, y, z, m): `10.1 20.2 30.3 40.4`
/// * geopoint (lon, lat): `10.1 20.2`
/// * bounds (min-x, min-y, max-x, max-y): `10.1 10.1,20.2 20.2`
/// * bounds (min-x, min-y, min-z, max-x, max-y, maz-z):
///   * `10.1 10.1 10.1,20.2 20.2 20.2`
/// * point series, line string, multi point (with 2D points):
///   * `10.1 10.1,20.2 20.2,30.3 30.3`
/// * polygon, multi line string (with 2D points):
///   * `(35 10,45 45,15 40,10 20,35 10)`
/// * multi polygon (with 2D points):
///   * `((35 10,45 45,15 40,10 20,35 10))`
/// * coordinates for other geometries with similar principles
///
/// Note that WKT does not specify bounding box formatting. In some applications
/// bounding boxes are formatted as polygons. An example presented above however
/// format bounding box as a point series of two points (min, max).
const wktFormat = CoordinatesFormat(
  // decimals: null, (no default value for fraction digits)
  valueDelimiter: ' ',
  pointPrefix: '',
  pointPostfix: '',
  pointDelimiter: ',',
  boundsPointDelimiter: ',',
  itemPrefix: '(',
  itemPostfix: ')',
  itemDelimiter: ',',
);

/// Rules to format string representations of coordinates.
class CoordinatesFormat {
  /// The number of decimals (not applied on number values without decimals).
  final int? decimals;

  /// The delimiter between coordinate values of a point.
  final String valueDelimiter;

  /// The prefix printed before each point of a point series.
  final String pointPrefix;

  /// The postfix printed after each point of a point series.
  final String pointPostfix;

  /// The delimiter between points of a point series.
  final String pointDelimiter;

  /// The delimiter between points (min and max) of bounds.
  final String boundsPointDelimiter;

  /// The prefix printed before each item (other than points or coordinates).
  final String itemPrefix;

  /// The postfix printed after each item (other than points or coordinates).
  final String itemPostfix;

  /// The delimiter between geometry items (other than points or coordinates).
  final String itemDelimiter;

  /// Creates rules to format string representations of coordinates.
  const CoordinatesFormat({
    this.decimals,
    required this.valueDelimiter,
    required this.pointPrefix,
    required this.pointPostfix,
    required this.pointDelimiter,
    required this.boundsPointDelimiter,
    required this.itemPrefix,
    required this.itemPostfix,
    required this.itemDelimiter,
  });
}
