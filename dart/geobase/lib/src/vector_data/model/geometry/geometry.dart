// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/crs/coord_ref_sys.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/vector/content/geometry_content.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';
import '/src/vector_data/model/bounded/bounded.dart';

/// A base interface for geometry classes.
///
/// Geometry classes (including all subtypes) are immutable.
@immutable
abstract class Geometry extends Bounded {
  /// A geometry with an optional [bounds].
  const Geometry({super.bounds});

  /// The geometry type.
  Geom get geomType;

  /// Returns true if this geometry is considered empty.
  ///
  /// Emptiness in the context of this classes extending Geometry is defined:
  /// * `Point` has x and y coordinates with value `double.nan`.
  /// * `LineString` has an empty chain of points.
  /// * `Polygon` has an empty list of linear rings.
  /// * `MultiPoint` has no points.
  /// * `MultiLineString` has no line strings.
  /// * `MultiPolygon` has no polygons.
  /// * `GeometryCollection` has no geometries.
  bool get isEmpty;

  /// Returns a new geometry projected using [projection].
  ///
  /// The returned geometry sub type must be the same as the type of this.
  ///
  /// If [bounds] object is available on this, it's recalculated after
  /// projecting geometries. If [bounds] is null, then it's null after
  /// projecting too.
  @override
  Geometry project(Projection projection);

  /// Writes this geometry object to [writer].
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  void writeTo(GeometryContent writer, {String? name});

  /// The string representation of this geometry object, with [format] applied.
  ///
  /// When [format] is not given, then the geometry format of [GeoJSON] is
  /// used as a default.
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when writing) about coordinate reference system in text output.
  ///
  /// Other format or encoder implementation specific options can be set by
  /// [options].
  String toText({
    TextWriterFormat<GeometryContent> format = GeoJSON.geometry,
    int? decimals,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) {
    final encoder =
        format.encoder(decimals: decimals, crs: crs, options: options);
    writeTo(encoder.writer);
    return encoder.toText();
  }

  /// The binary representation of this geometry object, with [format] applied.
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// An optional [endian] specifies endianness for byte sequences written. Some
  /// encoders might ignore this, and some has a default value for it.
  ///
  /// Other format or encoder implementation specific options can be set by
  /// [options].
  Uint8List toBytes({
    BinaryFormat<GeometryContent> format = WKB.geometry,
    Endian? endian,
    Map<String, dynamic>? options,
  }) {
    final encoder = format.encoder(endian: endian, options: options);
    writeTo(encoder.writer);
    return encoder.toBytes();
  }

  /// True if this geometry equals with [other] by testing 2D coordinates of all
  /// positions (that must be in same order in both geometries).
  ///
  /// Returns false if this and [other] are not of the same geometry type.
  ///
  /// Returns false if this or [other] is an "empty geometry" ([isEmpty] true).
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
  });

  /// True if this geometry equals with [other] by testing 3D coordinates of all
  /// positions (that must be in same order in both geometries).
  ///
  /// Returns false if this and [other] are not of the same geometry type.
  ///
  /// Returns false if this or [other] is an "empty geometry" ([isEmpty] true).
  ///
  /// Returns false if this or [other] do not contain 3D coordinates.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Differences on vertical coordinate values (ie. z or elev) between
  /// this and [other] must be within [toleranceVert].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals3D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  });

  /// The string representation of this geometry object as specified by
  /// [GeoJSON].
  ///
  /// See also [toText].
  @override
  String toString() => toText();
}

/// A base interface for "simple" geometry classes.
abstract class SimpleGeometry extends Geometry {
  /// A "simple" geometry with an optional [bounds].
  const SimpleGeometry({super.bounds});

  /// The coordinate type for this geometry.
  Coords get coordType;

  /// The coordinate type for this geometry.
  ///
  /// For simple geometries this method call equals to calling [coordType].
  @override
  Coords resolveCoordType() => coordType;

  @override
  void writeTo(SimpleGeometryContent writer, {String? name});

  @override
  String toText({
    TextWriterFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    int? decimals,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) {
    final encoder =
        format.encoder(decimals: decimals, crs: crs, options: options);
    writeTo(encoder.writer);
    return encoder.toText();
  }

  @override
  Uint8List toBytes({
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    Endian? endian,
    Map<String, dynamic>? options,
  }) {
    final encoder = format.encoder(endian: endian, options: options);
    writeTo(encoder.writer);
    return encoder.toBytes();
  }
}
