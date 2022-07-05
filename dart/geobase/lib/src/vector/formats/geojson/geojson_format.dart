// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_positional_boolean_parameters

import '/src/utils/format_geojson_wkt.dart';
import '/src/vector/content.dart';
import '/src/vector/encoding.dart';

/// The GeoJSON text format for [coordinate], [geometry] and [feature] objects.
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
/// This implementation allows printing M coordinates, when available on
/// source data. Such M coordinate values are always formatted as "fourth
/// element.". However, it's possible that other implementations cannot read
/// them:
/// * point (x, y, m), with z missing but formatted as 0, and m = 40.4:
///   * `{"type":"Point","coordinates":[10.1,20.2,0,40.4]}`
/// * point (x, y, z, m), with z = 30.3 and m = 40.4:
///   * `{"type":"Point","coordinates":[10.1,20.2,30.3,40.4]}`
class GeoJSON {
  /// The GeoJSON text format for coordinate objects.
  static const TextFormat<CoordinateContent> coordinate =
      _GeoJsonTextFormatImpl(GeoJsonTextWriter.new);

  /// The GeoJSON text format for geometry objects.
  static const TextFormat<GeometryContent> geometry =
      _GeoJsonTextFormatImpl(GeoJsonTextWriter.new);

  /// The GeoJSON text format for feature objects.
  static const TextFormat<FeatureContent> feature =
      _GeoJsonTextFormatImpl(GeoJsonTextWriter.new);

  /// The GeoJSON text format for coordinate objects.
  ///
  /// When [ignoreMeasured] is set to true, then M coordinates are ignored from
  /// formatting.
  ///
  /// When [ignoreForeignMembers] is set to true, then such JSON elements that
  /// are not described by the GeoJSON specification, are ignored. See the
  /// section 6.1 of the specifcation (RFC 7946).
  static TextFormat<CoordinateContent> coordinateFormat({
    bool ignoreMeasured = false,
    bool ignoreForeignMembers = false,
  }) =>
      _GeoJsonTextFormatImpl(
        GeoJsonTextWriter.new,
        ignoreMeasured,
        ignoreForeignMembers,
      );

  /// The GeoJSON text format for geometry objects.
  ///
  /// When [ignoreMeasured] is set to true, then M coordinates are ignored from
  /// formatting.
  ///
  /// When [ignoreForeignMembers] is set to true, then such JSON elements that
  /// are not described by the GeoJSON specification, are ignored. See the
  /// section 6.1 of the specifcation (RFC 7946).
  static TextFormat<GeometryContent> geometryFormat({
    bool ignoreMeasured = false,
    bool ignoreForeignMembers = false,
  }) =>
      _GeoJsonTextFormatImpl(
        GeoJsonTextWriter.new,
        ignoreMeasured,
        ignoreForeignMembers,
      );

  /// The GeoJSON text format for feature objects.
  ///
  /// When [ignoreMeasured] is set to true, then M coordinates are ignored from
  /// formatting.
  ///
  /// When [ignoreForeignMembers] is set to true, then such JSON elements that
  /// are not described by the GeoJSON specification, are ignored. See the
  /// section 6.1 of the specifcation (RFC 7946).
  static TextFormat<FeatureContent> featureFormat({
    bool ignoreMeasured = false,
    bool ignoreForeignMembers = false,
  }) =>
      _GeoJsonTextFormatImpl(
        GeoJsonTextWriter.new,
        ignoreMeasured,
        ignoreForeignMembers,
      );
}

typedef _CreateGeoJsonContentEncoder<T extends Object> = ContentEncoder<T>
    Function({
  StringSink? buffer,
  int? decimals,
  bool ignoreMeasured,
  bool ignoreForeignMembers,
});

class _GeoJsonTextFormatImpl<T extends Object> with TextFormat<T> {
  const _GeoJsonTextFormatImpl(
    this.factory, [
    this.ignoreMeasured = false,
    this.ignoreForeignMembers = false,
  ]);

  final _CreateGeoJsonContentEncoder<T> factory;

  final bool ignoreMeasured;
  final bool ignoreForeignMembers;

  @override
  ContentEncoder<T> encoder({
    StringSink? buffer,
    int? decimals,
  }) =>
      factory.call(
        buffer: buffer,
        decimals: decimals,
        ignoreMeasured: ignoreMeasured,
        ignoreForeignMembers: ignoreForeignMembers,
      );
}
