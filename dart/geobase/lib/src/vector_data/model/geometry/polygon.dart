// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/vector_data/array.dart';

import 'geometry.dart';

/// A polygon geometry with exactly one exterior and 0 to N interior rings.
class Polygon extends Geometry {
  final List<PositionArray> _rings;

  /// A polygon geometry with exactly one exterior and 0 to N interior [rings].
  ///
  /// Each ring in the polygon is represented by `PositionArray` instances.
  ///
  /// The [rings] list must be non-empty. The first element is the exterior
  /// ring, and any other rings are interior rings (or holes). All rings must be
  /// closed linear rings. As specified by GeoJSON, they should "follow the
  /// right-hand rule with respect to the area it bounds, i.e., exterior rings
  /// are counterclockwise, and holes are clockwise".
  const Polygon(List<PositionArray> rings)
      : _rings = rings,
        assert(
          rings.length > 0,
          'Polygon must contain at least the exterior ring',
        );

  /// A polygon geometry from one exterior and 0 to N interior [rings].
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
  ///
  /// Each ring in the polygon is represented by `Iterable<double>` arrays. Such
  /// arrays contain coordinate values as a flat structure. For example for
  /// `Coords.xyz` the first three coordinate values are x, y and z of the first
  /// position, the next three coordinate values are x, y and z of the second
  /// position, and so on.
  ///
  /// The [rings] list must be non-empty. The first element is the exterior
  /// ring, and any other rings are interior rings (or holes). All rings must be
  /// closed linear rings. As specified by GeoJSON, they should "follow the
  /// right-hand rule with respect to the area it bounds, i.e., exterior rings
  /// are counterclockwise, and holes are clockwise".
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
    required Coords type,
  }) {
    assert(
      rings.isNotEmpty,
      'Polygon must contain at least the exterior ring',
    );
    if (rings is List<PositionArray>) {
      return Polygon(rings);
    } else if (rings is Iterable<PositionArray>) {
      return Polygon(rings.toList(growable: false));
    } else {
      return Polygon(
        rings
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
  Geom get type => Geom.polygon;

  /// The rings (exterior + interior) of this polygon.
  List<PositionArray> get rings => _rings;

  /// The exterior ring of this polygon.
  PositionArray get exterior => _rings[0];

  /// The interior rings of this polygon.
  Iterable<PositionArray> get interiorRings => rings.skip(1);

  /// The count of interior rings in this polygon.
  int get interiorLength => _rings.length - 1;

  /// The interior ring at the given index.
  ///
  /// The index refers to the index of interior rings, not all rings in the
  /// polygon. It's required that `0 <= index < interiorLength`.
  PositionArray interior(int index) => _rings[1 + index];

  // todo: coordinates as raw data, toString

  @override
  bool operator ==(Object other) =>
      other is Polygon && rings == other.rings;

  @override
  int get hashCode => rings.hashCode;
}
