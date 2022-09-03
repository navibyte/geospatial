// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/coordinates/projection.dart';
import '/src/utils/coord_arrays.dart';
import '/src/utils/coord_arrays_from_json.dart';
import '/src/vector/content.dart';
import '/src/vector/encoding.dart';
import '/src/vector/formats.dart';
import '/src/vector_data/array.dart';

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
  /// Format or decoder implementation specific options can be set by [options].
  factory MultiPolygon.parse(
    String text, {
    TextReaderFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.parse<MultiPolygon>(
        text,
        format: format,
        options: options,
      );

  /// Parses a multi polygon geometry from [coordinates] conforming to
  /// [DefaultFormat].
  factory MultiPolygon.parseCoords(String coordinates) {
    final array = json.decode('[$coordinates]') as List<dynamic>;
    final coordType = resolveCoordType(array, positionLevel: 3);
    return MultiPolygon.build(
      createFlatPositionArrayArrayArrayDouble(array, coordType),
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
  void writeTo(SimpleGeometryContent writer, {String? name}) => writer
      .multiPolygon(_polygons, type: coordType, name: name, bounds: bounds);

  // todo: coordinates as raw data

  @override
  bool operator ==(Object other) =>
      other is MultiPolygon &&
      bounds == other.bounds &&
      ringArrays == other.ringArrays;

  @override
  int get hashCode => Object.hash(bounds, ringArrays);
}
