// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/coordinates/crs/coord_ref_sys.dart';
import '/src/coordinates/projection/projection.dart';
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

/// A polygon geometry with one exterior and 0 to N interior rings.
///
/// An empty polygon has no rings.
class Polygon extends SimpleGeometry {
  final List<PositionArray> _rings;
  final Coords? _type;

  /// A polygon geometry with one exterior and 0 to N interior [rings].
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each ring in the polygon is represented by `PositionArray` instances.
  ///
  /// An empty polygon has no rings.
  ///
  /// For "normal" polygons the [rings] list must be non-empty. The first
  /// element is the exterior ring, and any other rings are interior rings (or
  /// holes). All rings must be closed linear rings. As specified by GeoJSON,
  /// they should "follow the right-hand rule with respect to the area it
  /// bounds, i.e., exterior rings are counterclockwise, and holes are
  /// clockwise".
  const Polygon(List<PositionArray> rings, {BoxCoords? bounds})
      : this._(rings, bounds: bounds);

  const Polygon._(this._rings, {super.bounds, Coords? type}) : _type = type;

  /*
  // NOTE: changed so that no assert - empty polygon do not have any rings
        assert(
          _rings.length > 0,
          'Polygon must contain at least the exterior ring',
        );
        */

  /// Builds a polygon geometry from one exterior and 0 to N interior [rings].
  ///
  /// Use [type] to specify the type of coordinates, by default `Coords.xy` is
  /// expected.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each ring in the polygon is represented by `Iterable<double>` arrays. Such
  /// arrays contain coordinate values as a flat structure. For example for
  /// `Coords.xyz` the first three coordinate values are x, y and z of the first
  /// position, the next three coordinate values are x, y and z of the second
  /// position, and so on.
  ///
  /// An empty polygon has no rings.
  ///
  /// For "normal" polygons the [rings] list must be non-empty. The first
  /// element is the exterior ring, and any other rings are interior rings (or
  /// holes). All rings must be closed linear rings. As specified by GeoJSON,
  /// they should "follow the right-hand rule with respect to the area it
  /// bounds, i.e., exterior rings are counterclockwise, and holes are
  /// clockwise".
  ///
  /// An example to build a polygon geometry with one linear ring containing
  /// 4 points:
  /// ```dart
  ///  Polygon.build(
  ///      // an array of linear rings
  ///      [
  ///        // a linear ring as a flat structure with four (x, y) points
  ///        [
  ///          10.1, 10.1,
  ///          5.0, 9.0,
  ///          12.0, 4.0,
  ///          10.1, 10.1,
  ///        ],
  ///      ],
  ///      type: Coords.xy,
  ///  );
  /// ```
  factory Polygon.build(
    Iterable<Iterable<double>> rings, {
    Coords type = Coords.xy,
    Iterable<double>? bounds,
  }) =>
      Polygon._(
        buildListOfPositionArrays(rings, type: type),
        type: type,
        bounds: buildBoxCoordsOpt(bounds, type: type),
      );

  /// Parses a polygon geometry from [text] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory Polygon.parse(
    String text, {
    TextReaderFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.parse<Polygon>(
        text,
        format: format,
        crs: crs,
        options: options,
      );

  /// Parses a polygon geometry from [coordinates] conforming to
  /// [DefaultFormat].
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  factory Polygon.parseCoords(
    String coordinates, {
    CoordRefSys? crs,
  }) {
    final array = json.decode('[$coordinates]') as List<dynamic>;
    if (array.isEmpty) {
      return Polygon.build(const []);
    }
    final coordType = resolveCoordType(array, positionLevel: 2);
    return Polygon.build(
      createFlatPositionArrayArrayDouble(array, coordType, crs),
      type: coordType,
    );
  }

  /// Decodes a polygon geometry from [bytes] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory Polygon.decode(
    Uint8List bytes, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decode<Polygon>(
        bytes,
        format: format,
        options: options,
      );

  @override
  Geom get geomType => Geom.polygon;

  @override
  Coords get coordType => _type ?? exterior?.type ?? Coords.xy;

  @override
  bool get isEmpty => _rings.isEmpty;

  /// The rings (exterior + interior) of this polygon.
  ///
  /// For non-empty polygons the first element is the exterior ring,
  /// and any other rings are interior rings (or holes). All rings must be
  /// closed linear rings.
  List<PositionArray> get rings => _rings;

  /// An exterior ring of this polygon.
  ///
  /// For empty polygon this returns null.
  PositionArray? get exterior => _rings.isEmpty ? null : _rings[0];

  /// The interior rings (or holes) of this polygon, allowed to be empty.
  Iterable<PositionArray> get interior => rings.skip(1);

  @override
  Polygon project(Projection projection) => Polygon._(
        _rings.map((ring) => ring.project(projection)).toList(growable: false),
        type: _type,
      );

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) => isEmpty
      ? writer.emptyGeometry(Geom.polygon, name: name)
      : writer.polygon(_rings, type: coordType, name: name, bounds: bounds);

  // NOTE: coordinates as raw data

  @override
  bool operator ==(Object other) =>
      other is Polygon && bounds == other.bounds && rings == other.rings;

  @override
  int get hashCode => Object.hash(bounds, rings);
}
