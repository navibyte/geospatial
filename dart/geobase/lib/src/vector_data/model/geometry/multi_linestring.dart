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
import 'linestring.dart';

/// A multi line string with an array of line strings (each with a chain of
/// positions).
class MultiLineString extends SimpleGeometry {
  final List<PositionArray> _lineStrings;
  final Coords? _type;

  /// A multi line string with an array of [lineStrings] (each with a chain of
  /// positions).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each line string or a chain of positions is represented by [PositionArray]
  /// instances.
  const MultiLineString(List<PositionArray> lineStrings, {BoxCoords? bounds})
      : this._(lineStrings, bounds: bounds);

  const MultiLineString._(this._lineStrings, {super.bounds, Coords? type})
      : _type = type;

  /// A multi line string from an array of [lineStrings] (each with a chain of
  /// positions).
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each line string or a chain of positions is represented by `
  /// Iterable<double>` instances. They contain coordinate values as a flat
  /// structure. For example for `Coords.xyz` the first three coordinate values
  /// are x, y and z of the first position, the next three coordinate values are
  /// x, y and z of the second position, and so on.
  ///
  /// An example to build a multi line string with two line strings:
  /// ```dart
  ///  MultiLineString.build(
  ///      // an array of chains (one chain for each line string)
  ///      [
  ///        // a chain as a flat structure with four (x, y) points
  ///        [
  ///          10.1, 10.1,
  ///          5.0, 9.0,
  ///          12.0, 4.0,
  ///          10.1, 10.1,
  ///        ],
  ///        // a chain as a flat structure with three (x, y) points
  ///        [
  ///          -1.1, -1.1,
  ///          2.1, -2.5,
  ///          3.5, -3.49,
  ///        ],
  ///      ],
  ///      type: Coords.xy,
  ///  );
  /// ```
  factory MultiLineString.build(
    Iterable<Iterable<double>> lineStrings, {
    required Coords type,
    Iterable<double>? bounds,
  }) =>
      MultiLineString._(
        listOfPositionArraysFromCoords(lineStrings, type: type),
        type: type,
        bounds: boxFromCoordsOpt(bounds, type: type),
      );

  /// Decodes a multi line string geometry from [text] conforming to [format].
  ///
  /// When [format] is not given, then [GeoJSON] is used as a default.
  factory MultiLineString.fromText(
    String text, {
    TextReaderFormat<GeometryContent> format = GeoJSON.geometry,
  }) =>
      GeometryBuilder.decode<MultiLineString>(text, format: format);

  @override
  Geom get geomType => Geom.multiLineString;

  @override
  Coords get coordType =>
      _type ?? (_lineStrings.isNotEmpty ? _lineStrings.first.type : Coords.xy);

  /// The chains of all line strings.
  List<PositionArray> get chains => _lineStrings;

  /// All line strings as a lazy iterable of [LineString] geometries.
  Iterable<LineString> get lineStrings =>
      chains.map<LineString>(LineString.new);

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      writer.multiLineString(
        _lineStrings,
        type: coordType,
        name: name,
        bounds: bounds,
      );

  // todo: coordinates as raw data

  @override
  bool operator ==(Object other) =>
      other is MultiLineString &&
      bounds == other.bounds &&
      chains == other.chains;

  @override
  int get hashCode => Object.hash(bounds, chains);
}
