// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import 'package:meta/meta.dart';

import '/src/common/codes/geom.dart';
import '/src/common/constants/epsilon.dart';
import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/base/bounded.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_scheme.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/byte_utils.dart';
import '/src/vector/content/geometry_content.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';

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
  ///
  /// The specification from [Bounded]:
  /// "Returns true if this bounded object is considered empty (that is it do
  /// not contain any geometry directly or on child objects, or geometry
  /// contained is empty)".
  @override
  bool get isEmptyByGeometry;

  /// Returns a geometry of the same subtype as this with certain data members
  /// populated.
  ///
  /// If nothing is populated then `this` is returned.
  ///
  /// If [onBounds] is true (as by default):
  /// * The `bounds` in a returned geometry object is ensured to be populated
  ///   (expect when cannot be calculated, for example in the case of an empty
  ///   geometry).
  /// * If [traverse] > 0, then also bounding boxes of child geometry objects of
  ///   this geometry are populated for child levels indicated by [traverse]
  ///   (0: no childs, 1: only direct childs, 2: direct childs and childs of
  ///   them, ..).
  ///
  /// Use [scheme] to set the position scheme:
  /// * `Position.scheme` for generic position data (geographic, projected or
  ///    any other), this is also the default
  /// * `Projected.scheme` for projected position data
  /// * `Geographic.scheme` for geographic position data
  ///
  /// See also [unpopulated].
  @override
  Geometry populated({
    int traverse = 0,
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  });

  /// Returns a geometry of the same subtype as this with certain data members
  /// unpopulated (or cleared).
  ///
  /// If nothing is unpopulated then `this` is returned.
  ///
  /// If [onBounds] is true (as by default):
  /// * The `bounds` in a returned geometry object is ensured to be unpopulated
  ///   (expect when `bounds` is always available).
  /// * If [traverse] > 0, then also bounding boxes of child geometry objects of
  ///   this geometry are unpopulated for child levels indicated by [traverse]
  ///   (0: no childs, 1: only direct childs, 2: direct childs and childs of
  ///   them, ..).
  ///
  /// See also [populated].
  @override
  Geometry unpopulated({
    int traverse = 0,
    bool onBounds = true,
  });

  @override
  Geometry project(Projection projection);

  /// Returns the length of this geometry calculated in a cartesian 2D plane.
  ///
  /// For points the result is `0.0`, for line strings the length of a line, for
  /// polygons the perimeter of an area. Multi geometries and geometry
  /// collections returns the sum of lengths of contained geometries.
  ///
  /// To calculate lengths along the surface of the earth, see `spherical`
  /// extensions for `Iterable<Geographic>` and `PositionSeries` implemented by
  /// the `package:geobase/geodesy.dart` library.
  ///
  /// See also [length3D].
  double length2D();

  /// Returns the length of this geometry calculated in a cartesian 3D space.
  ///
  /// For points the result is `0.0`, for line strings the length of a line, for
  /// polygons the perimeter of an area. Multi geometries and geometry
  /// collections returns the sum of lengths of contained geometries.
  ///
  /// To calculate (2D) lengths along the surface of the earth, see `spherical`
  /// extensions for `Iterable<Geographic>` and `PositionSeries` implemented by
  /// the `package:geobase/geodesy.dart` library.
  ///
  /// See also [length2D].
  double length3D();

  /// Returns the area of this geometry calculated in a cartesian 2D plane.
  ///
  /// The area is zero or a positive double value. For points and line string
  /// the result is `0.0`, and for polygon geometries the area of an polygon
  /// (more specifically the area represented by an exterior ring minus areas of
  /// any interior rings or holes). Multi geometries and geometry collections
  /// returns the sum of areas of contained geometries.
  ///
  /// To calculate (2D) area on the surface of the earth, see `spherical`
  /// extensions for `Iterable<Geographic>` and `PositionSeries` implemented by
  /// the `package:geobase/geodesy.dart` library.
  double area2D();

  @override
  bool equalsCoords(Geometry other);

  @override
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
  });

  @override
  bool equals3D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  });

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
  ///
  /// See also [toBytesHex] to get the binary representation as a hex string.
  Uint8List toBytes({
    BinaryFormat<GeometryContent> format = WKB.geometry,
    Endian? endian,
    Map<String, dynamic>? options,
  }) {
    final encoder = format.encoder(endian: endian, options: options);
    writeTo(encoder.writer);
    return encoder.toBytes();
  }

  /// The binary representation as a hex string of this geometry object, with
  /// [format] applied.
  ///
  /// See [toBytes] for more information.
  String toBytesHex({
    BinaryFormat<GeometryContent> format = WKB.geometry,
    Endian? endian,
    Map<String, dynamic>? options,
  }) =>
      toBytes(format: format, endian: endian, options: options).toHex();

  /// The string representation of this geometry object as specified by
  /// [GeoJSON].
  ///
  /// See also [toText].
  @override
  String toString() => toText();
}

/// A base interface for "simple" geometry classes.
///
/// This package provides following "simple" geometry classes based on the
/// [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
/// standard by [The Open Geospatial Consortium](https://www.ogc.org/): `Point`,
/// `LineString`, `Polygon`, `MultiPoint`, `MultiLineString` and `MultiPolygon`.
/// It the context of this package the type `GeometryCollection` is not consider
/// "simple". It's possible that in future versions other geometry types are
/// added.
abstract class SimpleGeometry extends Geometry {
  /// A "simple" geometry with an optional [bounds].
  const SimpleGeometry({super.bounds});

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
