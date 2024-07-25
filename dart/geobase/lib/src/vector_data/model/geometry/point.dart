// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import '/src/common/codes/coords.dart';
import '/src/common/codes/dimensionality.dart';
import '/src/common/codes/geom.dart';
import '/src/common/constants/epsilon.dart';
import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/base/aligned.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_scheme.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/byte_utils.dart';
import '/src/utils/coord_positions.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';

import 'geometry.dart';
import 'geometry_builder.dart';

/// A point geometry with a position.
class Point implements SimpleGeometry {
  final Position _position;

  /// A point geometry with [position].
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a point with a 2D position (x: 10.0, y: 20.0)
  /// Point([10.0, 20.0].xy));
  ///
  /// // a point with a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// Point([10.0, 20.0, 30.0].xyz);
  ///
  /// // a point with a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
  /// Point([10.0, 20.0, 40.0].xym);
  ///
  /// // a point with a measured 3D position
  /// // (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// Point([10.0, 20.0, 30.0, 40.0].xyzm);
  /// ```
  const Point(Position position) : _position = position;

  /// Builds a point geometry from a [position].
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates. If
  /// not provided and an iterable has 3 items, then xyz coordinates are
  /// assumed.
  ///
  /// Supported coordinate value combinations for `Iterable<double>` are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a point with a 2D position (x: 10.0, y: 20.0)
  /// Point.build([10.0, 20.0]);
  ///
  /// // a point with a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// Point.build([10.0, 20.0, 30.0]);
  ///
  /// // a point with a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
  /// // (need to specify the coordinate type XYM)
  /// Point.build([10.0, 20.0, 40.0], type: Coords.xym);
  ///
  /// // a point with a measured 3D position
  /// // (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// Point.build([10.0, 20.0, 30.0, 40.0]);
  /// ```
  factory Point.build(
    Iterable<double> position, {
    Coords? type,
  }) =>
      Point(
        Position.view(
          // ensure list structure
          position is List<double> ? position : toFloatNNList(position),
          // resolve type if not known
          type: type ?? Coords.fromDimension(position.length),
        ),
      );

  /// Parses a point geometry from [text] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  /// When data itself have CRS information it overrides this value.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a point with a 2D position (x: 10.0, y: 20.0)
  /// Point.parse(
  ///   format: GeoJSON.geometry,
  ///   '{"type": "Point", "coordinates": [10.0, 20.0]}',
  /// );
  /// Point.parse(
  ///   format: WKT.geometry,
  ///   'POINT (10.0 20.0)',
  /// );
  ///
  /// // a point with a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// Point.parse(
  ///   format: GeoJSON.geometry,
  ///   '{"type": "Point", "coordinates": [10.0, 20.0, 30.0]}',
  /// );
  /// Point.parse(
  ///   format: WKT.geometry,
  ///   'POINT Z (10.0 20.0 30.0)',
  /// );
  ///
  /// // a point with a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
  /// Point.parse(
  ///   format: WKT.geometry,
  ///   'POINT M (10.0 20.0 40.0)',
  /// );
  ///
  /// // a point with a measured 3D position
  /// // (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// Point.parse(
  ///   format: GeoJSON.geometry,
  ///   '{"type": "Point", "coordinates": [10.0, 20.0, 30.0, 40]}',
  /// );
  /// Point.parse(
  ///   format: WKT.geometry,
  ///   'POINT ZM (10.0 20.0 30.0 40.0)',
  /// );
  /// ```
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

  /// Parses a point geometry from [text] with coordinate values separated by
  /// [delimiter].
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [text] has 3 items, then xyz coordinates are assumed.
  ///
  /// If [swapXY] is true, then swaps x and y for the result.
  ///
  /// If [singlePrecision] is true, then coordinate values of a position are
  /// stored in `Float32List` instead of the `Float64List` (default).
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a point with a 2D position (x: 10.0, y: 20.0)
  /// Point.parseCoords('10.0,20.0');
  ///
  /// // a point with a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// Point.parseCoords('10.0,20.0,30.0');
  ///
  /// // a point with a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
  /// // (need to specify the coordinate type XYM)
  /// Point.parseCoords('10.0,20.0,40.0', type: Coords.xym);
  ///
  /// // a point with a measured 3D position
  /// // (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// Point.parseCoords('10.0,20.0,30.0,40.0');
  ///
  /// // a point with a 2D position (x: 10.0, y: 20.0) using an alternative
  /// // delimiter
  /// Point.parseCoords('10.0;20.0', delimiter: ';');
  ///
  /// // a point with a 2D position (x: 10.0, y: 20.0) from an array with y
  /// // before x
  /// Point.parseCoords('20.0,10.0', swapXY: true);
  ///
  /// // a point with a 2D position (x: 10.0, y: 20.0) with the internal storage
  /// // using single precision floating point numbers (`Float32List` in this
  /// // case)
  /// Point.parseCoords('10.0,20.0', singlePrecision: true);
  /// ```
  factory Point.parseCoords(
    String text, {
    Pattern delimiter = ',',
    Coords? type,
    bool swapXY = false,
    bool singlePrecision = false,
  }) {
    final str = text.trim();
    if (str.isEmpty) {
      return Point.build(const [double.nan, double.nan]);
    }
    return Point(
      parsePositionFromText(
        str,
        delimiter: delimiter,
        type: type,
        swapXY: swapXY,
        singlePrecision: singlePrecision,
      ),
    );
  }

  /// Decodes a point geometry from [bytes] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in binary
  /// input. When data itself have CRS information it overrides this value.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  ///
  /// See also [Point.decodeHex] to decode from bytes represented as a hex
  /// string.
  factory Point.decode(
    Uint8List bytes, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decode<Point>(
        bytes,
        format: format,
        crs: crs,
        options: options,
      );

  /// Decodes a point geometry from [bytesHex] (as a hex string)
  /// conforming to [format].
  ///
  /// See [Point.decode] for more information.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a point with a 2D position (x: 10.1, y: 20.2) from a WKB encoded hex
  /// // string
  /// Point.decodeHex('010100000033333333333324403333333333333440');
  /// ```
  factory Point.decodeHex(
    String bytesHex, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decodeHex<Point>(
        bytesHex,
        format: format,
        crs: crs,
        options: options,
      );

  @override
  Geom get geomType => Geom.point;

  @override
  Coords get coordType => position.coordType;

  @override
  bool get isEmptyByGeometry => position.x.isNaN && position.y.isNaN;

  /// The position of this point geometry.
  ///
  /// The returned object is of the type used for storing a position in this
  /// point geometry. That is, it can be any [Position] object, like
  /// `Position` itself, `Projected` or `Geographic`.
  Position get position => _position;

  /// The bounding box for this point, min and max with the same point position.
  @override
  Box get bounds => calculateBounds();

  /// The bounding box for this point, min and max with the same point position.
  @override
  Box? getBounds({PositionScheme scheme = Position.scheme}) =>
      calculateBounds(scheme: scheme);

  @override
  Position? boundsAligned2D({
    Aligned align = Aligned.center,
    PositionScheme scheme = Position.scheme,
  }) =>
      scheme.position.call(
        x: position.x,
        y: position.y,
      );

  /// The bounding box for this point, min and max with the same point position.
  @override
  Box calculateBounds({PositionScheme scheme = Position.scheme}) =>
      scheme.box.call(
        minX: position.x,
        minY: position.y,
        minZ: position.optZ,
        minM: position.optM,
        maxX: position.x,
        maxY: position.y,
        maxZ: position.optZ,
        maxM: position.optM,
      );

  @override
  Point populated({
    int traverse = 0,
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  }) =>
      onBounds && scheme != Position.scheme
          ? _BoundedPoint(position, bounds: calculateBounds(scheme: scheme))
          : this;

  @override
  Point unpopulated({
    int traverse = 0,
    bool onBounds = true,
  }) =>
      this;

  @override
  Point project(Projection projection) => Point(position.project(projection));

  @override
  double length2D() => 0.0;

  @override
  double length3D() => 0.0;

  @override
  double area2D() => 0.0;

  @override
  Dimensionality dimensionality2D() => Dimensionality.punctual;

  @override
  Position? centroid2D({PositionScheme scheme = Position.scheme}) =>
      scheme.conformsWith(position.conforming)
          ? position
          : scheme.position(
              x: position.x,
              y: position.y,
            );

  @override
  double distanceTo2D(Position destination) =>
      position.distanceTo2D(destination);

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      isEmptyByGeometry
          ? writer.emptyGeometry(Geom.point, name: name)
          : writer.point(position, name: name);

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
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) {
    final encoder = format.encoder(endian: endian, options: options, crs: crs);
    writeTo(encoder.writer);
    return encoder.toBytes();
  }

  @override
  String toBytesHex({
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    Endian? endian,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      toBytes(format: format, endian: endian, options: options, crs: crs)
          .toHex();

  @override
  bool equalsCoords(Geometry other) =>
      other is Point && position == other.position;

  @override
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
  }) =>
      other is Point &&
      !isEmptyByGeometry &&
      !other.isEmptyByGeometry &&
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
      !isEmptyByGeometry &&
      !other.isEmptyByGeometry &&
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

class _BoundedPoint extends Point {
  final Box _bounds;

  const _BoundedPoint(super.position, {required Box bounds}) : _bounds = bounds;

  @override
  Box get bounds => _bounds;

  @override
  Box? getBounds({PositionScheme scheme = Position.scheme}) =>
      bounds.conforming.conformsWith(scheme)
          ? bounds
          : calculateBounds(scheme: scheme);

  @override
  Point populated({
    int traverse = 0,
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  }) =>
      onBounds && !bounds.conforming.conformsWith(scheme)
          ? _BoundedPoint(position, bounds: calculateBounds(scheme: scheme))
          : this;

  @override
  Point unpopulated({
    int traverse = 0,
    bool onBounds = true,
  }) =>
      onBounds ? Point(position) : this;
}
