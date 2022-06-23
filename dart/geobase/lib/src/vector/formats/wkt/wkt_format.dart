// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/utils/format_geojson_wkt.dart';
import '/src/vector/content.dart';
import '/src/vector/encode/base.dart';
import '/src/vector/encode/geometry.dart';

/// The WKT format for geometries (implements [GeometryFormat]).
@Deprecated('Instantiate WKT class directly.')
GeometryFormat wktFormat() => WKT();

/// The WKT format for geometries (implements [GeometryFormat]).
///
/// Rules applied by the format conforms with WKT (Well-known text
/// representation of geometry) formatting of coordinate lists and geometries.
///
/// Examples:
/// * point (empty): `POINT EMPTY`
/// * point (x, y): `POINT(10.1 20.2)`
/// * point (x, y, z): `POINT Z(10.1 20.2 30.3)`
/// * point (x, y, m): `POINT M(10.1 20.2 30.3)`
/// * point (x, y, z, m): `POINT ZM(10.1 20.2 30.3 40.4)`
/// * geopoint (lon, lat): `POINT(10.1 20.2)`
/// * box (min-x, min-y, max-x, max-y) with values `10.1 10.1,20.2 20.2`:
///   * `POLYGON((10.1 10.1,20.2 10.1,20.2 20.2,10.1 20.2,10.1 10.1))`
/// * multi point (with 2D points):
///   * `MULTIPOINT(10.1 10.1,20.2 20.2,30.3 30.3)`
/// * line string (with 2D points):
///   * `LINESTRING(10.1 10.1,20.2 20.2,30.3 30.3)`
/// * multi line string (with 2D points):
///   * `MULTILINESTRING((35 10,45 45,15 40,10 20,35 10))`
/// * polygon (with 2D points):
///   * `POLYGON((35 10,45 45,15 40,10 20,35 10))`
/// * multi polygon (with 2D points):
///   * `MULTIPOLYGON(((35 10,45 45,15 40,10 20,35 10)))`
/// * coordinates for other geometries with similar principles
///
/// Note that WKT does not specify bounding box formatting. Here bounding boxes
/// are formatted as polygons. See also `wktLikeFormat` that formats them as a
/// point series of two points (min, max).
class WKT implements GeometryFormat {
  /// The WKT format for geometries.
  WKT();

  @override
  ContentWriter<CoordinateContent> coordinatesToText({
    StringSink? buffer,
    int? decimals,
  }) =>
      WktTextWriter(buffer: buffer, decimals: decimals);

  @override
  ContentWriter<GeometryContent> geometriesToText({
    StringSink? buffer,
    int? decimals,
  }) =>
      WktTextWriter(buffer: buffer, decimals: decimals);
}
