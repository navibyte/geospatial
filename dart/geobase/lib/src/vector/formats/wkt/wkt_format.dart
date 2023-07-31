// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/utils/format_geojson_wkt.dart';
import '/src/utils/format_impl.dart';
import '/src/vector/content/coordinates_content.dart';
import '/src/vector/content/geometry_content.dart';
import '/src/vector/encoding/text_format.dart';

/// The WKT text format for [coordinate] and [geometry] objects.
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
/// 
/// When getting an encoder from text writer format objects this `WKT`
/// class provides you COULD use `crs` parameter to give hints (like axis order,
/// and whether x and y must be swapped when writing) about coordinate reference
/// system in text output. However for the WKT text format such crs
/// information is ignored, x/longitude is always printed before y/latitude
/// regardless of crs axis order.
class WKT {
  /// The WKT text writer format for coordinate objects.
  static const TextWriterFormat<CoordinateContent> coordinate =
      TextWriterFormatImpl(WktTextWriter.new);

  /// The WKT text writer format for geometry objects.
  static const TextWriterFormat<GeometryContent> geometry =
      TextWriterFormatImpl(WktTextWriter.new);
}
