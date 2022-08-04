// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/vector_data/array.dart';

import 'geometry.dart';
import 'linestring.dart';

/// A multi line string with a series of line strings (each with a chain of
/// positions).
class MultiLineString extends Geometry {
  final List<PositionArray> _lineStrings;

  /// A multi line string with a series of [lineStrings] (each with a chain of
  /// positions).
  ///
  /// Each line string or a chain of positions is represented by [PositionArray]
  /// instances.
  const MultiLineString(List<PositionArray> lineStrings)
      : _lineStrings = lineStrings;

  /// A multi line string from a series of [lineStrings] (each with a chain of
  /// positions).
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
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
  }) {
    if (lineStrings is List<PositionArray>) {
      return MultiLineString(lineStrings);
    } else if (lineStrings is Iterable<PositionArray>) {
      return MultiLineString(lineStrings.toList(growable: false));
    } else {
      return MultiLineString(
        lineStrings
            .map<PositionArray>(
              (chain) => PositionArray.view(
                chain is List<double> ? chain : chain.toList(growable: false),
                type: type,
              ),
            )
            .toList(growable: false),
      );
    }
  }

  @override
  Geom get type => Geom.multiLineString;

  /// The chains of all line strings.
  List<PositionArray> get chains => _lineStrings;

  /// All line strings as a lazy iterable of [LineString] geometries.
  Iterable<LineString> get lineStrings =>
      chains.map<LineString>(LineString.new);

  // todo: coordinates as raw data, ==, hashCode, toString
}
