// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/vector_data/array.dart';

import 'geometry.dart';

/// A line string geometry with a chain of positions.
class LineString extends Geometry {
  final PositionArray _chain;

  /// A line string geometry with a [chain] of positions.
  ///
  /// The [chain] array must contain at least two positions.
  const LineString(PositionArray chain)
      : _chain = chain,
        assert(
          chain.length >= 2,
          'Chain must contain at least two positions',
        );

  /// A line string geometry from a [chain] of positions.
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
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
  }) {
    assert(
      chain.length >= 2,
      'Chain must contain at least two positions',
    );
    if (chain is PositionArray) {
      return LineString(chain);
    } else {
      return LineString(
        PositionArray.view(
          chain is List<double> ? chain : chain.toList(growable: false),
          type: type,
        ),
      );
    }
  }

  @override
  Geom get type => Geom.lineString;

  /// The chain of positions in this line string geometry.
  PositionArray get chain => _chain;

  // todo: coordinates as raw data, ==, hashCode, toString
}
