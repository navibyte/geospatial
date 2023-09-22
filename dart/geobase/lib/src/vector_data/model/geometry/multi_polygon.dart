// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import '/src/codes/coords.dart';
import '/src/codes/geo_representation.dart';
import '/src/codes/geom.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_series.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/reference/coord_ref_sys.dart';
import '/src/utils/bounded_utils.dart';
import '/src/utils/bounds_builder.dart';
import '/src/utils/coord_positions.dart';
import '/src/utils/coord_type.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/default_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';
import '/src/vector_data/model/bounded/bounded.dart';

import 'geometry.dart';
import 'geometry_builder.dart';
import 'polygon.dart';

/// A multi polygon with an array of polygons (each with an array of rings).
class MultiPolygon extends SimpleGeometry {
  final List<List<PositionSeries>> _polygons;

  /// A multi polygon with an array of [polygons] (each with an array of rings).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each polygon is represented by a `List<PositionSeries>` instance
  /// containing one exterior and 0 to N interior rings. The first element is
  /// the exterior ring, and any other rings are interior rings (or holes). All
  /// rings must be closed linear rings. As specified by GeoJSON, they should
  /// "follow the right-hand rule with respect to the area it bounds, i.e.,
  /// exterior rings are counterclockwise, and holes are clockwise".
  const MultiPolygon(List<List<PositionSeries>> polygons, {super.bounds})
      : _polygons = polygons;

  /// A multi polygon with an array of [polygons] (each with an array of rings).
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each polygon is represented by a `Iterable<Iterable<Position>>` instance
  /// containing one exterior and 0 to N interior rings. The first element is
  /// the exterior ring, and any other rings are interior rings (or holes). All
  /// rings must be closed linear rings. As specified by GeoJSON, they should
  /// "follow the right-hand rule with respect to the area it bounds, i.e.,
  /// exterior rings are counterclockwise, and holes are clockwise".
  ///
  /// The coordinate type of all positions in rings should be the same.
  factory MultiPolygon.from(
    Iterable<Iterable<Iterable<Position>>> polygons, {
    Box? bounds,
  }) =>
      MultiPolygon(
        polygons
            .map(
              (polygon) =>
                  polygon.map(PositionSeries.from).toList(growable: false),
            )
            .toList(growable: false),
        bounds: bounds,
      );

  /// Builds a multi polygon from an array of [polygons] (each with an array of
  /// rings).
  ///
  /// Use [type] to specify the type of coordinates, by default `Coords.xy` is
  /// expected.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// Each polygon is represented by a `Iterable<Iterable<double>>` instance
  /// containing one exterior and 0 to N interior rings. The first element is
  /// the exterior ring, and any other rings are interior rings (or holes). All
  /// rings must be closed linear rings. As specified by GeoJSON, they should
  /// "follow the right-hand rule with respect to the area it bounds, i.e.,
  /// exterior rings are counterclockwise, and holes are clockwise".
  ///
  /// Each ring in the polygon is represented by an `Iterable<double>` array.
  /// Such arrays contain coordinate values as a flat structure. For example for
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
    Box? bounds,
  }) =>
      MultiPolygon(
        polygons
            .map(
              (rings) => rings
                  .map(
                    (ring) => PositionSeries.view(
                      ring is List<double> ? ring : toFloatNNList(ring),
                      type: type,
                    ),
                  )
                  .toList(growable: false),
            )
            .toList(growable: false),
        bounds: bounds,
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
  /// Use [crs] and [crsLogic] to give hints (like axis order, and whether x
  /// and y must be swapped when read in) about coordinate reference system in
  /// text input.
  factory MultiPolygon.parseCoords(
    String coordinates, {
    CoordRefSys? crs,
    GeoRepresentation? crsLogic,
  }) {
    final str = coordinates.trim();
    if (str.isEmpty) {
      return MultiPolygon.build(const []);
    }
    final array = json.decode('[$str]') as List<dynamic>;
    return MultiPolygon(
      createPositionSeriesArrayArray(
        array,
        swapXY: crs?.swapXY(logic: crsLogic) ?? false,
      ),
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
  Coords get coordType => positionSeriesArrayArrayType(ringArrays);

  @override
  bool get isEmptyByGeometry => _polygons.isEmpty;

  /// The ring arrays of all polygons.
  List<List<PositionSeries>> get ringArrays => _polygons;

  /// All polygons as a lazy iterable of [Polygon] geometries.
  Iterable<Polygon> get polygons => ringArrays.map<Polygon>(Polygon.new);

  static Iterable<PositionSeries> _allRings(
    List<List<PositionSeries>> ringArrays,
  ) {
    Iterable<PositionSeries>? iter;
    for (final rings in ringArrays) {
      iter = iter == null ? rings : iter.followedBy(rings);
    }
    return iter ?? [];
  }

  @override
  Box? calculateBounds() => BoundsBuilder.calculateBounds(
        seriesArray: _allRings(_polygons),
        type: coordType,
      );

  @override
  @Deprecated('Use populated or unpopulated instead.')
  MultiPolygon bounded({bool recalculate = false}) {
    if (isEmptyByGeometry) return this;

    if (recalculate || bounds == null) {
      // a new MultiPolygon (rings array kept intact) with populated bounds
      return MultiPolygon(
        ringArrays,
        bounds: BoundsBuilder.calculateBounds(
          seriesArray: _allRings(ringArrays),
          type: coordType,
        ),
      );
    } else {
      // bounds was already populated and not asked to recalculate
      return this;
    }
  }

  @override
  MultiPolygon populated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was unpopulated and geometry not empty
      if (bounds == null && !isEmptyByGeometry) {
        return MultiPolygon(
          ringArrays,
          bounds: BoundsBuilder.calculateBounds(
            seriesArray: _allRings(ringArrays),
            type: coordType,
          ),
        );
      }
    }
    return this;
  }

  @override
  MultiPolygon unpopulated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was populated
      if (bounds != null) {
        return MultiPolygon(ringArrays);
      }
    }
    return this;
  }

  @override
  MultiPolygon project(Projection projection) {
    final projected = _polygons
        .map<List<PositionSeries>>(
          (rings) => rings
              .map<PositionSeries>((ring) => ring.project(projection))
              .toList(growable: false),
        )
        .toList(growable: false);

    return MultiPolygon(
      projected,

      // bounds calculated from projected geometry if there was bounds before
      bounds: bounds != null
          ? BoundsBuilder.calculateBounds(
              seriesArray: _allRings(projected),
              type: coordType,
            )
          : null,
    );
  }

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      isEmptyByGeometry
          ? writer.emptyGeometry(Geom.multiPolygon, name: name)
          : writer.multiPolygon(ringArrays, name: name, bounds: bounds);

  // NOTE: coordinates as raw data

  @override
  bool equalsCoords(Bounded other) => testEqualsCoords<MultiPolygon>(
        this,
        other,
        (mp1, mp2) => _testMultiPolygons(
          mp1,
          mp2,
          (posArray1, posArray2) => posArray1.equalsCoords(posArray2),
        ),
      );

  @override
  bool equals2D(
    Bounded other, {
    double toleranceHoriz = defaultEpsilon,
  }) =>
      testEquals2D<MultiPolygon>(
        this,
        other,
        (mp1, mp2) => _testMultiPolygons(
          mp1,
          mp2,
          (posArray1, posArray2) => posArray1.equals2D(
            posArray2,
            toleranceHoriz: toleranceHoriz,
          ),
        ),
        toleranceHoriz: toleranceHoriz,
      );

  @override
  bool equals3D(
    Bounded other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) =>
      testEquals3D<MultiPolygon>(
        this,
        other,
        (mp1, mp2) => _testMultiPolygons(
          mp1,
          mp2,
          (posArray1, posArray2) => posArray1.equals3D(
            posArray2,
            toleranceHoriz: toleranceHoriz,
            toleranceVert: toleranceVert,
          ),
        ),
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  @override
  bool operator ==(Object other) =>
      other is MultiPolygon &&
      bounds == other.bounds &&
      ringArrays == other.ringArrays;

  @override
  int get hashCode => Object.hash(bounds, ringArrays);
}

bool _testMultiPolygons(
  MultiPolygon mp1,
  MultiPolygon mp2,
  bool Function(PositionSeries, PositionSeries) testPositionArrays,
) {
  // ensure both multi polygons has same amount of arrays of ring data
  final arr1 = mp1.ringArrays;
  final arr2 = mp2.ringArrays;
  if (arr1.length != arr2.length) return false;
  // loop all arrays of ring data
  for (var j = 0; j < arr1.length; j++) {
    // get linear ring lists from arrays by index j
    final r1 = arr1[j];
    final r2 = arr2[j];
    // ensure r1 and r2 has same amount of linear rings
    if (r1.length != r2.length) return false;
    // loop all linear rings and test coordinates
    for (var i = 0; i < r1.length; i++) {
      if (!testPositionArrays.call(r1[i], r2[i])) {
        return false;
      }
    }
  }
  return true;
}
