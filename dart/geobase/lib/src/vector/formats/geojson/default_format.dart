// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/utils/format_geojson_wkt.dart';
import '/src/utils/format_impl.dart';
import '/src/vector/content.dart';
import '/src/vector/encoding.dart';

/// The "default" text format for [coordinate] and [geometry] objects.
///
/// Rules applied by the format are aligned with GeoJSON.
///
/// Examples:
/// * point (x, y): `10.1,20.2`
/// * point (x, y, z): `10.1,20.2,30.3`
/// * point (x, y, m) with z formatted as 0: `10.1,20.2,0,40.4`
/// * point (x, y, z, m): `10.1,20.2,30.3,40.4`
/// * box (min-x, min-y, max-x, max-y): `10.1,10.1,20.2,20.2`
/// * box (min-x, min-y, min-z, max-x, max-y, maz-z):
///   * `10.1,10.1,10.1,20.2,20.2,20.2`
/// * line string, multi point (with 2D points):
///   * `[10.1,10.1],[20.2,20.2],[30.3,30.3]`
/// * polygon, multi line string (with 2D points):
///   * `[[35,10],[45,45],[15,40],[10,20],[35,10]]`
/// * multi polygon (with 2D points):
///   * `[[[35,10],[45,45],[15,40],[10,20],[35,10]]]`
/// * coordinates for other geometries with similar principles
class DefaultFormat {
  /// The (default) text writer format for coordinate objects.
  static const TextWriterFormat<CoordinateContent> coordinate =
      TextWriterFormatImpl(DefaultTextWriter.new);

  /// The (default) text writer format for geometry objects.
  static const TextWriterFormat<GeometryContent> geometry =
      TextWriterFormatImpl(DefaultTextWriter.new);
}
