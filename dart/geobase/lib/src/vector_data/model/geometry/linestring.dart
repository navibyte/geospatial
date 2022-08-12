// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/utils/coord_arrays.dart';
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

  /// A line string geometry from a [chain] of positions.
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
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
    required Coords type,
    Iterable<double>? bounds,
  }) =>
      LineString(
        positionArrayFromCoords(chain, type: type),
        bounds: boxFromCoordsOpt(bounds, type: type),
      );

  /// Decodes a line string geometry from [text] conforming to [format].
  ///
  /// When [format] is not given, then [GeoJSON] is used as a default.
  factory LineString.fromText(
    String text, {
    TextReaderFormat<GeometryContent> format = GeoJSON.geometry,
  }) =>
      GeometryBuilder.decode<LineString>(text, format: format);

  @override
  Geom get geomType => Geom.lineString;

  @override
  Coords get coordType => _chain.type;

  /// The chain of positions in this line string geometry.
  PositionArray get chain => _chain;

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
