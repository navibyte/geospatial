// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/vector_data/array.dart';

import 'geometry.dart';
import 'polygon.dart';

/// A multi polygon with a series of polygons (each with a series of rings).
class MultiPolygon extends Geometry {
  final List<List<PositionArray>> _polygons;

  /// A multi polygon with a series of [polygons] (each with a series of rings).
  ///
  /// Each polygon is represented by `List<PositionArray>` instances containing
  /// one exterior and 0 to N interior rings. The first element is the exterior
  /// ring, and any other rings are interior rings (or holes). All rings must be
  /// closed linear rings. As specified by GeoJSON, they should "follow the
  /// right-hand rule with respect to the area it bounds, i.e., exterior rings
  /// are counterclockwise, and holes are clockwise".
  const MultiPolygon(List<List<PositionArray>> polygons) : _polygons = polygons;

  /// A multi polygon from a series of [polygons] (each with a series of rings).
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
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
    required Coords type,
  }) {
    if (polygons is List<List<PositionArray>>) {
      return MultiPolygon(polygons);
    } else if (polygons is Iterable<List<PositionArray>>) {
      return MultiPolygon(polygons.toList(growable: false));
    } else {
      return MultiPolygon(
        polygons
            .map<List<PositionArray>>(
              (rings) => rings
                  .map<PositionArray>(
                    (ring) => PositionArray.view(
                      ring is List<double>
                          ? ring
                          : ring.toList(growable: false),
                      type: type,
                    ),
                  )
                  .toList(growable: false),
            )
            .toList(growable: false),
      );
    }
  }

  @override
  Geom get type => Geom.multiPolygon;

  /// The ring arrays of all polygons.
  List<List<PositionArray>> get ringArrays => _polygons;

  /// All polygons as a lazy iterable of [Polygon] geometries.
  Iterable<Polygon> get polygons => ringArrays.map<Polygon>(Polygon.new);

  // todo: coordinates as raw data, ==, hashCode, toString
}
