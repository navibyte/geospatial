// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/crs/coord_ref_sys.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/coord_arrays.dart';
import '/src/utils/coord_arrays_from_json.dart';
import '/src/utils/tolerance.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/default_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';
import '/src/vector_data/array/coordinates.dart';

import 'geometry.dart';
import 'geometry_builder.dart';
import 'polygon.dart';

/// A multi polygon with an array of polygons (each with an array of rings).
class MultiPolygon extends SimpleGeometry {
  final List<List<PositionArray>> _polygons;
  final Coords? _type;

  /// A multi polygon with an array of [polygons] (each with an array of rings).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each polygon is represented by `List<PositionArray>` instances containing
  /// one exterior and 0 to N interior rings. The first element is the exterior
  /// ring, and any other rings are interior rings (or holes). All rings must be
  /// closed linear rings. As specified by GeoJSON, they should "follow the
  /// right-hand rule with respect to the area it bounds, i.e., exterior rings
  /// are counterclockwise, and holes are clockwise".
  const MultiPolygon(List<List<PositionArray>> polygons, {BoxCoords? bounds})
      : this._(polygons, bounds: bounds);

  const MultiPolygon._(this._polygons, {super.bounds, Coords? type})
      : _type = type;

  /// Builds a multi polygon from an array of [polygons] (each with an array of
  /// rings).
  ///
  /// Use [type] to specify the type of coordinates, by default `Coords.xy` is
  /// expected.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each polygon is represented by `Iterable<Iterable<double>>` instances
  /// containing one exterior and 0 to N interior rings. The first element is
  /// the exterior ring, and any other rings are interior rings (or holes). All
  /// rings must be closed linear rings. As specified by GeoJSON, they should
  /// "follow the right-hand rule with respect to the area it bounds, i.e.,
  /// exterior rings are counterclockwise, and holes are clockwise".
  ///
  /// Each ring in the polygon is represented by `Iterable<double>` arrays. Such
  /// arrays contain coordinate values as a flat structure. For example for
  /// `Coords.xyz` the first three coordinate values are x, y and z of the first
  /// position, the next three coordinate values are x, y and z of the second
  /// position, and so on.
  ///
  /// An example to build a multi polygon geometry with two polygons:
  /// ```dart
  ///  MultiPolygon.build(
  ///      // an array of polygons
  ///      [
  ///        // an array of linear rings of the first polygon
  ///        [
  ///          // a linear ring as a flat structure with four (x, y) points
  ///          [
  ///            10.1, 10.1,
  ///            5.0, 9.0,
  ///            12.0, 4.0,
  ///            10.1, 10.1,
  ///          ],
  ///        ],
  ///        // an array of linear rings of the second polygon
  ///        [
  ///          // a linear ring as a flat structure with four (x, y) points
  ///          [
  ///            110.1, 110.1,
  ///            15.0, 19.0,
  ///            112.0, 14.0,
  ///            110.1, 110.1,
  ///          ],
  ///        ],
  ///      ],
  ///  );
  /// ```
  factory MultiPolygon.build(
    Iterable<Iterable<Iterable<double>>> polygons, {
    Coords type = Coords.xy,
    Iterable<double>? bounds,
  }) =>
      MultiPolygon._(
        buildListOfListOfPositionArrays(polygons, type: type),
        type: type,
        bounds: buildBoxCoordsOpt(bounds, type: type),
      );

  /// Parses a multi polygon geometry from [text] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory MultiPolygon.parse(
    String text, {
    TextReaderFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.parse<MultiPolygon>(
        text,
        format: format,
        crs: crs,
        options: options,
      );

  /// Parses a multi polygon geometry from [coordinates] conforming to
  /// [DefaultFormat].
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  factory MultiPolygon.parseCoords(
    String coordinates, {
    CoordRefSys? crs,
  }) {
    final array = json.decode('[$coordinates]') as List<dynamic>;
    if (array.isEmpty) {
      return MultiPolygon.build(const []);
    }
    final coordType = resolveCoordType(array, positionLevel: 3);
    return MultiPolygon.build(
      createFlatPositionArrayArrayArrayDouble(array, coordType, crs),
      type: coordType,
    );
  }

  /// Decodes a multi polygon geometry from [bytes] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory MultiPolygon.decode(
    Uint8List bytes, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decode<MultiPolygon>(
        bytes,
        format: format,
        options: options,
      );

  @override
  Geom get geomType => Geom.multiPolygon;

  @override
  Coords get coordType =>
      _type ??
      (_polygons.isNotEmpty && _polygons.first.isNotEmpty
          ? _polygons.first.first.type
          : Coords.xy);

  @override
  bool get isEmpty => _polygons.isEmpty;

  /// The ring arrays of all polygons.
  List<List<PositionArray>> get ringArrays => _polygons;

  /// All polygons as a lazy iterable of [Polygon] geometries.
  Iterable<Polygon> get polygons => ringArrays.map<Polygon>(Polygon.new);

  @override
  MultiPolygon project(Projection projection) => MultiPolygon._(
        _polygons
            .map<List<PositionArray>>(
              (rings) => rings
                  .map<PositionArray>((ring) => ring.project(projection))
                  .toList(growable: false),
            )
            .toList(growable: false),
        type: _type,
      );

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) => isEmpty
      ? writer.emptyGeometry(Geom.multiPolygon, name: name)
      : writer.multiPolygon(
          _polygons,
          type: coordType,
          name: name,
          bounds: bounds,
        );

  // NOTE: coordinates as raw data

  @override
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = doublePrecisionEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    if (other is! MultiPolygon) return false;
    if (isEmpty || other.isEmpty) return false;
    if (bounds != null &&
        other.bounds != null &&
        !bounds!.equals2D(
          other.bounds!,
          toleranceHoriz: toleranceHoriz,
        )) {
      // both geometries has bound boxes and boxes do not equal in 2D
      return false;
    }
    // ensure both multi polygons has same amount of arrays of ring data
    final arr1 = ringArrays;
    final arr2 = other.ringArrays;
    if (arr1.length != arr2.length) return false;
    // loop all arrays of ring data
    for (var j = 0; j < arr1.length; j++) {
      // get linear ring lists from arrays by index j
      final r1 = arr1[j];
      final r2 = arr2[j];
      // ensure r1 and r2 has same amount of linear rings
      if (r1.length != r2.length) return false;
      // loop all linear rings and test 2D coordinates
      for (var i = 0; i < r1.length; i++) {
        if (!r1[i].data.equals2D(
              r2[i].data,
              toleranceHoriz: toleranceHoriz,
            )) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  bool equals3D(
    Geometry other, {
    double toleranceHoriz = doublePrecisionEpsilon,
    double toleranceVert = doublePrecisionEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    assertTolerance(toleranceVert);
    if (other is! MultiPolygon) return false;
    if (isEmpty || other.isEmpty) return false;
    if (!coordType.is3D || !other.coordType.is3D) return false;
    if (bounds != null &&
        other.bounds != null &&
        !bounds!.equals3D(
          other.bounds!,
          toleranceHoriz: toleranceHoriz,
          toleranceVert: toleranceVert,
        )) {
      // both geometries has bound boxes and boxes do not equal in 3D
      return false;
    }
    // ensure both multi polygons has same amount of arrays of ring data
    final arr1 = ringArrays;
    final arr2 = other.ringArrays;
    if (arr1.length != arr2.length) return false;
    // loop all arrays of ring data
    for (var j = 0; j < arr1.length; j++) {
      // get linear ring lists from arrays by index j
      final r1 = arr1[j];
      final r2 = arr2[j];
      // ensure r1 and r2 has same amount of linear rings
      if (r1.length != r2.length) return false;
      // loop all linear rings and test 2D coordinates
      for (var i = 0; i < r1.length; i++) {
        if (!r1[i].data.equals3D(
              r2[i].data,
              toleranceHoriz: toleranceHoriz,
              toleranceVert: toleranceVert,
            )) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is MultiPolygon &&
      bounds == other.bounds &&
      ringArrays == other.ringArrays;

  @override
  int get hashCode => Object.hash(bounds, ringArrays);
}
