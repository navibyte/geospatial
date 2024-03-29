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

/// The WKT (like) text format for [coordinate] and [geometry] objects.
///
/// Rules applied by the format are aligned with WKT (Well-known text
/// representation of geometry) formatting of coordinate lists.
///
/// Examples:
/// * point (x, y): `10.1 20.2`
/// * point (x, y, z): `10.1 20.2 30.3`
/// * point (x, y, z, m): `10.1 20.2 30.3 40.4`
/// * box (min-x, min-y, max-x, max-y): `10.1 10.1,20.2 20.2`
/// * box (min-x, min-y, min-z, max-x, max-y, maz-z):
///   * `10.1 10.1 10.1,20.2 20.2 20.2`
/// * line string, multi point (with 2D points):
///   * `10.1 10.1,20.2 20.2,30.3 30.3`
/// * polygon, multi line string (with 2D points):
///   * `(35 10,45 45,15 40,10 20,35 10)`
/// * multi polygon (with 2D points):
///   * `((35 10,45 45,15 40,10 20,35 10))`
/// * coordinates for other geometries with similar principles
///
/// Note that WKT does not specify bounding box formatting. In some applications
/// bounding boxes are formatted as polygons. An example presented above however
/// format bounding box as a point series of two points (min, max). See also
/// `wktFormat` that formats them as polygons.
///
/// When getting an encoder from text writer format objects this `WktLikeFormat`
/// class provides you COULD use `crs` parameter to give hints (like axis order,
/// and whether x and y must be swapped when writing) about coordinate reference
/// system in text output. However for the WKT (like) text format such crs
/// information is ignored, x/longitude is always printed before y/latitude
/// regardless of crs axis order.
class WktLikeFormat {
  /// The WKT (like) text writer format for coordinate objects.
  static const TextWriterFormat<CoordinateContent> coordinate =
      TextWriterFormatImpl(WktLikeTextWriter.new);

  /// The WKT (like) text writer format for geometry objects.
  static const TextWriterFormat<GeometryContent> geometry =
      TextWriterFormatImpl(WktLikeTextWriter.new);
}
