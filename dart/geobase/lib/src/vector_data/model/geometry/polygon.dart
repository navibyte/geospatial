// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/vector/content.dart';
import '/src/vector_data/array.dart';

import 'geometry.dart';

/// A polygon geometry with exactly one exterior and 0 to N interior rings.
class Polygon extends SimpleGeometry {
  final List<PositionArray> _rings;
  final Coords? _type;

  /// A polygon geometry with exactly one exterior and 0 to N interior [rings].
  ///
  /// An optional [bounds] can used set a minimum bounding box for a polygon.
  ///
  /// Each ring in the polygon is represented by `PositionArray` instances.
  ///
  /// The [rings] list must be non-empty. The first element is the exterior
  /// ring, and any other rings are interior rings (or holes). All rings must be
  /// closed linear rings. As specified by GeoJSON, they should "follow the
  /// right-hand rule with respect to the area it bounds, i.e., exterior rings
  /// are counterclockwise, and holes are clockwise".
  const Polygon(List<PositionArray> rings, {BoxCoords? bounds})
      : this._(rings, bounds: bounds);

  const Polygon._(this._rings, {super.bounds, Coords? type})
      : _type = type,
        assert(
          _rings.length > 0,
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
      return Polygon._(rings, type: type);
    } else if (rings is Iterable<PositionArray>) {
      return Polygon._(rings.toList(growable: false), type: type);
    } else {
      return Polygon._(
        rings
            .map<PositionArray>(
              (chain) => PositionArray.view(
                chain is List<double> ? chain : chain.toList(growable: false),
                type: type,
              ),
            )
            .toList(growable: false),
        type: type,
      );
    }
  }

  @override
  Geom get geomType => Geom.polygon;

  @override
  Coords get coordType => _type ?? exterior.type;

  /// The rings (exterior + interior) of this polygon.
  ///
  /// The returned list is non-empty. The first element is the exterior ring,
  /// and any other rings are interior rings (or holes). All rings must be
  /// closed linear rings.
  List<PositionArray> get rings => _rings;

  /// The (required) exterior ring of this polygon.
  PositionArray get exterior => _rings[0];

  /// The interior rings (or holes) of this polygon, allowed to be empty.
  Iterable<PositionArray> get interior => rings.skip(1);

/*
  /// The count of interior rings in this polygon.
  int get interiorLength => _rings.length - 1;

  /// The interior ring at the given index.
  ///
  /// The index refers to the index of interior rings, not all rings in the
  /// polygon. It's required that `0 <= index < interiorLength`.
  PositionArray interior(int index) => _rings[1 + index];
*/

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      writer.polygon(_rings, type: coordType, name: name, bbox: bounds);

  // todo: coordinates as raw data

  @override
  bool operator ==(Object other) =>
      other is Polygon && bounds == other.bounds && rings == other.rings;

  @override
  int get hashCode => Object.hash(bounds, rings);
}
