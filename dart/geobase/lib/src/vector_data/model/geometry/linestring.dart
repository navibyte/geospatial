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

/// A line string geometry with a chain of positions.
class LineString extends SimpleGeometry {
  final PositionArray _chain;

  /// A line string geometry with a [chain] of positions and optional [bounds].
  ///
  /// The [chain] array must contain at least two positions.
  const LineString(PositionArray chain, {super.bounds})
      : _chain = chain,
        assert(
          chain.length >= 2,
          'Chain must contain at least two positions',
        );

  /// Builds a line string geometry from a [chain] of positions.
  ///
  /// Use [type] to specify the type of coordinates, by default `Coords.xy` is
  /// expected.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// The [chain] array must contain at least two positions. It contains
  /// coordinate values of chain positions as a flat structure. For example for
  /// `Coords.xyz` the first three coordinate values are x, y and z of the first
  /// position, the next three coordinate values are x, y and z of the second
  /// position, and so on.
  ///
  /// An example to build a line string with 3 points:
  /// ```dart
  ///   LineString.build(
  ///       // points as a flat structure with three (x, y) points
  ///       [
  ///            -1.1, -1.1,
  ///            2.1, -2.5,
  ///            3.5, -3.49,
  ///       ],
  ///       type: Coords.xy,
  ///   );
  /// ```
  factory LineString.build(
    Iterable<double> chain, {
    Coords type = Coords.xy,
    Iterable<double>? bounds,
  }) =>
      LineString(
        buildPositionArray(chain, type: type),
        bounds: buildBoxCoordsOpt(bounds, type: type),
      );

  /// Parses a line string geometry from [text] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [GeoJSON] is used
  /// as a default.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory LineString.parse(
    String text, {
    TextReaderFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.parse<LineString>(text, format: format, options: options);

  /// Parses a line string geometry from [coordinates] conforming to
  /// [DefaultFormat].
  factory LineString.parseCoords(String coordinates) {
    final array = json.decode('[$coordinates]') as List<dynamic>;
    final coordType = resolveCoordType(array, positionLevel: 1);
    // todo: validate line string (at least two points)
    return LineString.build(
      createFlatPositionArrayDouble(array, coordType),
      type: coordType,
    );
  }

  /// Decodes a line string geometry from [bytes] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory LineString.decode(
    Uint8List bytes, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decode<LineString>(
        bytes,
        format: format,
        options: options,
      );

  @override
  Geom get geomType => Geom.lineString;

  @override
  Coords get coordType => _chain.type;

  /// The chain of positions in this line string geometry.
  PositionArray get chain => _chain;

  @override
  LineString project(Projection projection) =>
      LineString(_chain.project(projection));

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      writer.lineString(_chain, type: coordType, name: name, bounds: bounds);

  // todo: coordinates as raw data

  @override
  bool operator ==(Object other) =>
      other is LineString && bounds == other.bounds && chain == other.chain;

  @override
  int get hashCode => Object.hash(bounds, chain);
}
