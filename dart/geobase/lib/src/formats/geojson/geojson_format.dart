// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/encode/features.dart';
import '/src/encode/geometry.dart';
import '/src/utils/formats.dart';

/// The default format for geometries (implements [GeometryFormat]).
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
const defaultFormat = DefaultFormat();

/// Returns a format for formatting geometries and features to GeoJSON.
///
/// This format implements [FeatureFormat] (that implements [GeometryFormat]).
///
/// Rules applied by the format conforms with the GeoJSON formatting of
/// coordinate lists and geometries.
///
/// Examples:
/// * point (x, y):
///   * `{"type":"Point","coordinates":[10.1,20.2]}`
/// * point (x, y, z):
///   * `{"type":"Point","coordinates":[10.1,20.2,30.3]}`
/// * box (min-x, min-y, max-x, max-y), as a property inside other object:
///   * `"bbox": [10.1,10.1,20.2,20.2]`
/// * box (min-x, min-y, min-z, max-x, max-y, maz-z), as a property:
///   * `"bbox": [10.1,10.1,10.1,20.2,20.2,20.2]`
///
/// Multi point (with 2D points):
/// `{"type":"MultiPoint","coordinates":[[10.1,10.1],[20.2,20.2],[30.3,30.3]]}`
///
/// Line string (with 2D points):
/// `{"type":"LineString","coordinates":[[10.1,10.1],[20.2,20.2],[30.3,30.3]]}`
///
/// Multi line string (with 2D points):
/// ```
///   {"type":"MultiLineString",
///    "coordinates":[[[10.1,10.1],[20.2,20.2],[30.3,30.3]]]}
/// ```
///
/// Polygon (with 2D points):
/// ```
///   {"type":"Polygon",
///    "coordinates":[[[35,10],[45,45],[15,40],[10,20],[35,10]]]}
/// ```
///
/// MultiPolygon (with 2D points):
/// ```
///   {"type":"Polygon",
///    "coordinates":[[[[35,10],[45,45],[15,40],[10,20],[35,10]]]]}
/// ```
///
/// Feature:
/// ```
///   {"type": "Feature",
///    "id":1,
///    "properties": {"prop1": 100},
///    "geometry": {"type":"Point","coordinates":[10.1,20.2]}}
/// ```
///
/// The GeoJSON specification about M coordinates:
///    "Implementations SHOULD NOT extend positions beyond three elements
///    because the semantics of extra elements are unspecified and
///    ambiguous.  Historically, some implementations have used a fourth
///    element to carry a linear referencing measure (sometimes denoted as
///    "M") or a numerical timestamp, but in most situations a parser will
///    not be able to properly interpret these values.  The interpretation
///    and meaning of additional elements is beyond the scope of this
///    specification, and additional elements MAY be ignored by parsers."
///
/// This implementation allows printing M coordinates, when available on source
/// data. Such M coordinate values are always formatted as "fourth element.".
/// However, it's possible that other implementations cannot read them:
/// * point (x, y, m), with z missing but formatted as 0, and m = 40.4:
///   * `{"type":"Point","coordinates":[10.1,20.2,0,40.4]}`
/// * point (x, y, z, m), with z = 30.3 and m = 40.4:
///   * `{"type":"Point","coordinates":[10.1,20.2,30.3,40.4]}`
///
/// However when [ignoreMeasured] is set to true, then M coordinates are ignored
/// from formatting.
///
/// When [ignoreForeignMembers] is set to true, then such JSON elements that are
/// not described by the GeoJSON specification, are ignored. See the section 6.1
/// of the specifcation (RFC 7946).
FeatureFormat geoJsonFormat({
  bool ignoreMeasured = false,
  bool ignoreForeignMembers = false,
}) =>
    GeoJsonFormat(
      ignoreMeasured: ignoreMeasured,
      ignoreForeignMembers: ignoreForeignMembers,
    );
