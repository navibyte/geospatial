// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '/src/common/codes/coords.dart';
import '/src/common/codes/geo_representation.dart';
import '/src/common/codes/geom.dart';
import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/base/box.dart';
import '/src/utils/coord_positions.dart';
import '/src/utils/coord_type.dart';
import '/src/utils/format_geojson_wkt.dart';
import '/src/utils/format_impl.dart';
import '/src/vector/content/coordinates_content.dart';
import '/src/vector/content/feature_content.dart';
import '/src/vector/content/geometry_content.dart';
import '/src/vector/encoding/content_decoder.dart';
import '/src/vector/encoding/content_encoder.dart';
import '/src/vector/encoding/text_format.dart';

part 'geojson_decoder.dart';
part 'geojsonl_format.dart';

/// Optional configuration parameters for formatting (and parsing) GeoJSON.
class GeoJsonConf with EquatableMixin {
  /// Use this to set logic whether coordinate axis order should be
  /// authority-based (the default) or always lon-lat order.
  final GeoRepresentation? crsLogic;

  /// When true, coordinate values read when parsing are allowed to be stored
  /// on single-precision floating point numbers (Float32).
  ///
  /// By default this is true to indicate that double-precision floating point
  /// numbers (Float64) are used.
  final bool singlePrecision;

  /// When [ignoreMeasured] is set to true, then M coordinates are ignored from
  /// formatting.
  final bool ignoreMeasured;

  /// When [ignoreForeignMembers] is set to true, then such JSON elements that
  /// are not described by the GeoJSON specification, are ignored. See the
  /// section 6.1 of the specifcation (RFC 7946).
  final bool ignoreForeignMembers;

  /// When [printNonDefaultCrs], then "crs" attribute is printed to the
  /// "FeatureCollection".
  ///
  /// The "crs" property is printed only when a coordinate reference system is
  /// "non-default", that is, other than WGS 84 with the longitude-latitude axis
  /// order.
  final bool printNonDefaultCrs;

  /// When true and the number of decimals not set for output, then numbers
  /// outputted are compacted.
  ///
  /// Examples:
  /// * int (15) => "15"
  /// * double (15.0) => "15"
  /// * double (15.1) => "15.1"
  /// * double (15.123) => "15.123"
  final bool compactNums;

  /// Optional configuration parameters for formatting GeoJSON.
  const GeoJsonConf({
    this.crsLogic,
    this.singlePrecision = false,
    this.ignoreMeasured = false,
    this.ignoreForeignMembers = false,
    this.printNonDefaultCrs = false,
    this.compactNums = true,
  });

  @override
  List<Object?> get props => [
        crsLogic,
        singlePrecision,
        ignoreMeasured,
        ignoreForeignMembers,
        printNonDefaultCrs,
        compactNums,
      ];
}

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
///
/// When getting an encoder from text writer format objects this `GeoJSON`
/// class provides you can use `crs` parameter to give hints (like axis order,
/// and whether x and y must be swapped when writing) about coordinate reference
/// system in text output. When `crs` is available then `crs.swapXY` is used to
/// determine whether swapping (x/longitude <-> y/latitude) should occur.
///
/// See also the [GeoJSONL] format for decoding and encoding GeoJSON features
/// in a text sequence with features delimited by line feeds.
class GeoJSON {
  /// The GeoJSON text format (encoding only) for coordinate objects.
  static const TextWriterFormat<CoordinateContent> coordinate =
      TextWriterFormatImplConf(GeoJsonTextWriter.new);

  /// The GeoJSON text format (encoding and decoding) for geometry objects.
  static const TextFormat<GeometryContent> geometry =
      _GeoJsonGeometryTextFormat();

  /// The GeoJSON text format (encoding and decoding) for feature objects.
  static const TextFormat<FeatureContent> feature = _GeoJsonFeatureTextFormat();

  /// The GeoJSON text format (encoding only) for coordinate objects with
  /// optional [conf].
  static TextWriterFormat<CoordinateContent> coordinateFormat({
    GeoJsonConf? conf,
  }) =>
      TextWriterFormatImplConf(
        GeoJsonTextWriter.new,
        conf: conf,
      );

  /// The GeoJSON text format (encoding and decoding) for geometry objects with
  /// optional [conf].
  static TextFormat<GeometryContent> geometryFormat({
    GeoJsonConf? conf,
  }) =>
      _GeoJsonGeometryTextFormat(conf: conf);

  /// The GeoJSON text format (encoding and decoding) for feature objects with
  /// optional [conf].
  static TextFormat<FeatureContent> featureFormat({GeoJsonConf? conf}) =>
      _GeoJsonFeatureTextFormat(conf: conf);
}

class _GeoJsonGeometryTextFormat with TextFormat<GeometryContent> {
  const _GeoJsonGeometryTextFormat({this.conf});

  final GeoJsonConf? conf;

  @override
  ContentDecoder decoder(
    GeometryContent builder, {
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      _GeoJsonGeometryTextDecoder(
        builder,
        crs: crs,
        options: options,
        conf: conf,
      );

  @override
  ContentEncoder<GeometryContent> encoder({
    StringSink? buffer,
    int? decimals,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeoJsonTextWriter(
        buffer: buffer,
        decimals: decimals,
        crs: crs,
        conf: conf,
      );
}

class _GeoJsonFeatureTextFormat with TextFormat<FeatureContent> {
  const _GeoJsonFeatureTextFormat({this.conf});

  final GeoJsonConf? conf;

  @override
  ContentDecoder decoder(
    FeatureContent builder, {
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      _GeoJsonFeatureTextDecoder(
        builder,
        crs: crs,
        options: options,
        conf: conf,
      );

  @override
  ContentEncoder<FeatureContent> encoder({
    StringSink? buffer,
    int? decimals,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeoJsonTextWriter(
        buffer: buffer,
        decimals: decimals,
        crs: crs,
        conf: conf,
      );
}
