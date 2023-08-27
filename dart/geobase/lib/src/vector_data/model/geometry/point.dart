// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import '/src/codes/coords.dart';
import '/src/codes/geo_representation.dart';
import '/src/codes/geom.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/reference/coord_ref_sys.dart';
import '/src/utils/coord_arrays.dart';
import '/src/utils/coord_arrays_from_json.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/default_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';
import '/src/vector_data/array/coordinates.dart';

import 'geometry.dart';
import 'geometry_builder.dart';

/// A point geometry with a position.
class Point implements SimpleGeometry {
  final Position _position;

  /// A point geometry with [position].
  const Point(Position position) : _position = position;

  /// A point geometry from [position].
  @Deprecated('Use the default constructor instead')
  const Point.from(Position position) : _position = position;

  /// Builds a point geometry from a [position].
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates. If
  /// not provided and an iterable has 3 items, then xyz coordinates are
  /// assumed.
  ///
  /// Supported coordinate value combinations for `Iterable<double>` are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
  ///
  /// An example to build a point geometry with 2D coordinates:
  /// ```dart
  ///    // using a coordinate value list (x, y)
  ///    Point.build([10, 20]);
  /// ```
  ///
  /// An example to build a point geometry with 3D coordinates:
  /// ```dart
  ///    // using a coordinate value list (x, y, z)
  ///    Point.build([10, 20, 30]);
  /// ```
  ///
  /// An example to build a point geometry with 2D coordinates with measurement:
  /// ```dart
  ///    // using a coordinate value list (x, y, m), need to specify type
  ///    Point.build([10, 20, 40], type: Coords.xym);
  /// ```
  ///
  /// An example to build a point geometry with 3D coordinates with measurement:
  /// ```dart
  ///    // using a coordinate value list (x, y, z, m)
  ///    Point.build([10, 20, 30, 40]);
  /// ```
  factory Point.build(
    Iterable<double> position, {
    Coords? type,
  }) =>
      Point(buildPositionCoords(position, type: type));

  /// Parses a point geometry from [text] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory Point.parse(
    String text, {
    TextReaderFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.parse<Point>(
        text,
        format: format,
        crs: crs,
        options: options,
      );

  /// Parses a point geometry from [coordinates] conforming to [DefaultFormat].
  ///
  /// Use [crs] and [crsLogic] to give hints (like axis order, and whether x
  /// and y must be swapped when read in) about coordinate reference system in
  /// text input.
  factory Point.parseCoords(
    String coordinates, {
    CoordRefSys? crs,
    GeoRepresentation? crsLogic,
  }) {
    final pos = requirePositionDouble(
      json.decode('[$coordinates]'),
      swapXY: crs?.swapXY(logic: crsLogic) ?? false,
    );
    if (pos.isEmpty) {
      return Point.build(const [double.nan, double.nan]);
    }
    final coordType = Coords.fromDimension(pos.length);
    return Point.build(pos, type: coordType);
  }

  /// Decodes a point geometry from [bytes] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory Point.decode(
    Uint8List bytes, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decode<Point>(
        bytes,
        format: format,
        options: options,
      );

  @override
  Geom get geomType => Geom.point;

  @override
  Coords get coordType => position.type;

  @override
  bool get isEmpty => position.x.isNaN && position.y.isNaN;

  /// The position of this point geometry.
  ///
  /// The returned object is of the type used for storing a position in this
  /// point geometry. That is, it can be any [Position] object, like
  /// `Projected`, `Geographic` or `PositionCoords`.
  ///
  /// The returned position can be typed using extension methods:
  /// * `asProjected`: the position as a `Projected` position
  /// * `asGeographic`: the position as a `Geographic` position
  /// * `coords`: the position as a `PositionCoords` position
  Position get position => _position;

  /// The bounding box for this point, min and max with the same point position.
  ///
  /// Uses [calculateBounds] to return value as bounds can be accessed directly.
  @override
  Box get bounds => calculateBounds();

  /// The bounding box for this point, min and max with the same point position.
  @override
  Box calculateBounds() => BoxCoords.create(
        minX: position.x,
        minY: position.y,
        minZ: position.optZ,
        minM: position.optM,
        maxX: position.x,
        maxY: position.y,
        maxZ: position.optZ,
        maxM: position.optM,
      );

  /// Returns this [Point] object without any calculations.
  @override
  Point bounded({bool recalculate = false}) => this;

  @override
  Point project(Projection projection) =>
      Point(projection.project(_position, to: PositionCoords.create));

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) => isEmpty
      ? writer.emptyGeometry(Geom.point, name: name)
      : writer.point(position.values, type: coordType, name: name);

  // NOTE: coordinates as raw data

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

  @override
  bool equalsCoords(Geometry other) =>
      other is Point && position == other.position;

  @override
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
  }) =>
      other is Point &&
      !isEmpty &&
      !other.isEmpty &&
      position.equals2D(
        other.position,
        toleranceHoriz: toleranceHoriz,
      );

  @override
  bool equals3D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) =>
      other is Point &&
      !isEmpty &&
      !other.isEmpty &&
      position.equals3D(
        other.position,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  @override
  String toString() => toText();

  @override
  bool operator ==(Object other) =>
      other is Point && position == other.position;

  @override
  int get hashCode => position.hashCode;
}
