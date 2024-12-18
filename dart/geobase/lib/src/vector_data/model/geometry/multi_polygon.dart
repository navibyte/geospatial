// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

import 'dart:typed_data';

import '/src/common/codes/coords.dart';
import '/src/common/codes/geom.dart';
import '/src/common/constants/epsilon.dart';
import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_extensions.dart';
import '/src/coordinates/base/position_scheme.dart';
import '/src/coordinates/base/position_series.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/geometric/cartesian/areal/cartesian_areal_extension.dart';
import '/src/utils/bounded_utils.dart';
import '/src/utils/coord_positions.dart';
import '/src/utils/coord_type.dart';
import '/src/utils/geometry_calculations_cartesian.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';

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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi polygon with one polygon from 2D positions
  /// MultiPolygon(
  ///   [
  ///     // polygon
  ///     [
  ///       // an exterior ring with values of five (x, y) positions
  ///       [
  ///         10.0, 20.0,
  ///         12.5, 22.5,
  ///         15.0, 25.0,
  ///         11.5, 27.5,
  ///         10.0, 20.0,
  ///       ].positions(Coords.xy),
  ///     ],
  ///   ],
  /// );
  ///
  /// // a multi polygon with one polygon from 3D positions
  /// MultiPolygon(
  ///   [
  ///     // polygon
  ///     [
  ///       // an exterior ring with values of five (x, y, z) positions
  ///       [
  ///         10.0, 20.0, 30.0,
  ///         12.5, 22.5, 32.5,
  ///         15.0, 25.0, 35.0,
  ///         11.5, 27.5, 37.5,
  ///         10.0, 20.0, 30.0,
  ///       ].positions(Coords.xyz),
  ///     ],
  ///   ],
  /// );
  /// ```
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi polygon with one polygon from 2D positions
  /// MultiPolygon.from(
  ///   [
  ///     // polygon
  ///     [
  ///       // an exterior ring with five (x, y) positions
  ///       [
  ///         [10.0, 20.0].xy,
  ///         [12.5, 22.5].xy,
  ///         [15.0, 25.0].xy,
  ///         [11.5, 27.5].xy,
  ///         [10.0, 20.0].xy,
  ///       ],
  ///     ],
  ///   ],
  /// );
  ///
  /// // a multi polygon with one polygon from 3D positions
  /// MultiPolygon.from(
  ///   [
  ///     // polygon
  ///     [
  ///       // an exterior ring with five (x, y, z) positions
  ///       [
  ///         [10.0, 20.0, 30.0].xyz,
  ///         [12.5, 22.5, 32.5].xyz,
  ///         [15.0, 25.0, 35.0].xyz,
  ///         [11.5, 27.5, 37.5].xyz,
  ///         [10.0, 20.0, 30.0].xyz,
  ///       ],
  ///     ],
  ///   ],
  /// );
  /// ```
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

  /// A multi polygon from an array of [polygons] (each item as an instance
  /// of [Polygon]).
  ///
  /// A new instance shares arrays of linear rings with the source.
  ///
  /// An optional [bounds] set a minimum bounding box for a geometry.
  factory MultiPolygon.fromGeometries(
    Iterable<Polygon> polygons, {
    Box? bounds,
  }) =>
      MultiPolygon(
        polygons.map((polygon) => polygon.rings).toList(growable: false),
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
  /// Examples:
  ///
  /// ```dart
  /// // a multi polygon with one polygon from 2D positions
  /// MultiPolygon.build(
  ///   [
  ///     // polygon
  ///     [
  ///       // an exterior ring with values of five (x, y) positions
  ///       [
  ///         10.0, 20.0,
  ///         12.5, 22.5,
  ///         15.0, 25.0,
  ///         11.5, 27.5,
  ///         10.0, 20.0,
  ///       ],
  ///     ],
  ///   ],
  ///   type: Coords.xy,
  /// );
  ///
  /// // a multi polygon with one polygon from 3D positions
  /// MultiPolygon.build(
  ///   [
  ///     // polygon
  ///     [
  ///       // an exterior ring with values of five (x, y, z) positions
  ///       [
  ///         10.0, 20.0, 30.0,
  ///         12.5, 22.5, 32.5,
  ///         15.0, 25.0, 35.0,
  ///         11.5, 27.5, 37.5,
  ///         10.0, 20.0, 30.0,
  ///       ],
  ///     ],
  ///   ],
  ///   type: Coords.xyz,
  /// );
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
  /// When data itself have CRS information it overrides this value.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi polygon with one polygon from 2D positions
  /// MultiPolygon.parse(
  ///   format: GeoJSON.geometry,
  ///   '''
  ///   {
  ///     "type": "MultiPolygon",
  ///     "coordinates": [
  ///       [
  ///         [
  ///           [10.0,20.0],
  ///           [12.5,22.5],
  ///           [15.0,25.0],
  ///           [11.5,27.5],
  ///           [10.0,20.0]
  ///         ]
  ///       ]
  ///     ]
  ///   }
  ///   ''',
  /// );
  /// MultiPolygon.parse(
  ///   format: WKT.geometry,
  ///   '''
  ///   MULTIPOLYGON (
  ///     (
  ///       (
  ///         10.0 20.0,
  ///         12.5 22.5,
  ///         15.0 25.0,
  ///         11.5 27.5,
  ///         10.0 20.0
  ///       )
  ///     )
  ///   )
  ///   ''',
  /// );
  ///
  /// // a multi polygon with one polygon from 3D positions
  /// MultiPolygon.parse(
  ///   format: GeoJSON.geometry,
  ///   '''
  ///   {
  ///     "type": "MultiPolygon",
  ///     "coordinates": [
  ///       [
  ///         [
  ///           [10.0,20.0,30.0],
  ///           [12.5,22.5,32.5],
  ///           [15.0,25.0,35.0],
  ///           [11.5,27.5,37.5],
  ///           [10.0,20.0,30.0]
  ///         ]
  ///       ]
  ///     ]
  ///   }
  ///   ''',
  /// );
  /// MultiPolygon.parse(
  ///   format: WKT.geometry,
  ///   '''
  ///   MULTIPOLYGON Z (
  ///     (
  ///       (
  ///         10.0 20.0 30.0,
  ///         12.5 22.5 32.5,
  ///         15.0 25.0 35.0,
  ///         11.5 27.5 37.5,
  ///         10.0 20.0 30.0
  ///       )
  ///     )
  ///   )
  ///   ''',
  /// );
  /// ```
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

  /// Parses a multi polygon geometry from [polygons] with each polygon
  /// containing rings that are formatted as texts (with coordinate values
  /// separated by [delimiter]).
  ///
  /// Use the required optional [type] to explicitely set the coordinate type.
  ///
  /// If [swapXY] is true, then swaps x and y for all positions in the result.
  ///
  /// If [singlePrecision] is true, then coordinate values of positions are
  /// stored in `Float32List` instead of the `Float64List` (default).
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi polygon with one polygon from 2D positions
  /// MultiPolygon.parseCoords(
  ///   [
  ///     // polygon
  ///     [
  ///       // an exterior ring with values of five (x, y) positions
  ///       '10.0,20.0,'
  ///       '12.5,22.5,'
  ///       '15.0,25.0,'
  ///       '11.5,27.5,'
  ///       '10.0,20.0'
  ///     ],
  ///   ],
  ///   type: Coords.xy,
  /// );
  ///
  /// // a multi polygon with one polygon from 3D positions
  /// MultiPolygon.parseCoords(
  ///   [
  ///     // polygon
  ///     [
  ///       // an exterior ring with values of five (x, y, z) positions
  ///       '10.0,20.0,30.0,'
  ///       '12.5,22.5,32.5,'
  ///       '15.0,25.0,35.0,'
  ///       '11.5,27.5,37.5,'
  ///       '10.0,20.0,30.0'
  ///     ],
  ///   ],
  ///   type: Coords.xyz,
  /// );
  ///
  /// // a multi polygon with one polygon from 2D positions using an
  /// // alternative delimiter
  /// MultiPolygon.parseCoords(
  ///   [
  ///     // polygon
  ///     [
  ///       // an exterior ring with values of five (x, y) positions
  ///       '10.0;20.0;'
  ///       '12.5;22.5;'
  ///       '15.0;25.0;'
  ///       '11.5;27.5;'
  ///       '10.0;20.0'
  ///     ],
  ///   ],
  ///   type: Coords.xy,
  ///   delimiter: ';',
  /// ),
  ///
  /// // a multi polygon with one polygon from 2D positions with x before y
  /// MultiPolygon.parseCoords(
  ///   [
  ///     // polygon
  ///     [
  ///       // an exterior ring with values of five (x, y) positions
  ///       '20.0,10.0,'
  ///       '22.5,12.5,'
  ///       '25.0,15.0,'
  ///       '27.5,11.5,'
  ///       '20.0,10.0'
  ///     ],
  ///   ],
  ///   type: Coords.xy,
  ///   swapXY: true,
  /// );
  ///
  /// // a multi polygon with one polygon from 2D positions with the
  /// // internal storage using single precision floating point numbers
  /// // (`Float32List` in this case)
  /// MultiPolygon.parseCoords(
  ///   [
  ///     // polygon
  ///     [
  ///       // an exterior ring with values of five (x, y) positions
  ///       '10.0,20.0,'
  ///       '12.5,22.5,'
  ///       '15.0,25.0,'
  ///       '11.5,27.5,'
  ///       '10.0,20.0'
  ///     ],
  ///   ],
  ///   type: Coords.xy,
  ///   singlePrecision: true,
  /// );
  /// ```
  factory MultiPolygon.parseCoords(
    Iterable<Iterable<String>> polygons, {
    Pattern delimiter = ',',
    Coords type = Coords.xy,
    bool swapXY = false,
    bool singlePrecision = false,
  }) {
    if (polygons.isEmpty) {
      return MultiPolygon.build(const []);
    } else {
      return MultiPolygon(
        polygons
            .map(
              (polygon) => polygon
                  .map(
                    (ring) => parsePositionSeriesFromTextDim1(
                      ring,
                      delimiter: delimiter,
                      type: type,
                      swapXY: swapXY,
                      singlePrecision: singlePrecision,
                    ),
                  )
                  .toList(growable: false),
            )
            .toList(growable: false),
      );
    }
  }

  /// Decodes a multi polygon geometry from [bytes] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in binary
  /// input. When data itself have CRS information it overrides this value.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  ///
  /// See also [MultiPolygon.decodeHex] to decode from bytes represented as a
  /// hex string.
  factory MultiPolygon.decode(
    Uint8List bytes, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decode<MultiPolygon>(
        bytes,
        format: format,
        crs: crs,
        options: options,
      );

  /// Decodes a multi polygon geometry from [bytesHex] (as a hex string)
  /// conforming to [format].
  ///
  /// See [MultiPolygon.decode] for more information.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a multi polygon from a WKB encoded hex string - same geometry as WKT:
  /// // "MULTIPOLYGON(((35 10,45 45,15 40,10 20,35 10)))"
  /// MultiPolygon.decodeHex('0106000000010000000103000000010000000500000000000000008041400000000000002440000000000080464000000000008046400000000000002e4000000000000044400000000000002440000000000000344000000000008041400000000000002440');
  /// ```
  factory MultiPolygon.decodeHex(
    String bytesHex, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decodeHex<MultiPolygon>(
        bytesHex,
        format: format,
        crs: crs,
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

  @override
  Box? calculateBounds({PositionScheme scheme = Position.scheme}) =>
      ringArrays.map((polygon) {
        if (polygon.isNotEmpty) {
          return polygon.first.calculateBounds(scheme: scheme);
        }
        return null;
      }).merge();

  @override
  MultiPolygon populated({
    int traverse = 0,
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was unpopulated or of other scheme
      final b = bounds;
      final empty = ringArrays.isEmpty;
      if ((b == null && !empty) ||
          (b != null && !b.conforming.conformsWith(scheme))) {
        return MultiPolygon(
          ringArrays,
          bounds: empty
              ? null
              : ringArrays.map((polygon) {
                  if (polygon.isNotEmpty) {
                    return polygon.first.getBounds(scheme: scheme);
                  }
                  return null;
                }).merge(),
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

    return MultiPolygon(projected);
  }

  @override
  double length2D() {
    var length = 0.0;
    for (final polygon in ringArrays) {
      for (final ring in polygon) {
        length += ring.length2D();
      }
    }
    return length;
  }

  @override
  double length3D() {
    var length = 0.0;
    for (final polygon in ringArrays) {
      for (final ring in polygon) {
        length += ring.length3D();
      }
    }
    return length;
  }

  @override
  double area2D() {
    var area = 0.0;
    for (final polygon in ringArrays) {
      if (polygon.isNotEmpty) {
        // area of an exterior ring
        area += polygon.first.signedArea2D().abs();

        // areas of interior rings
        for (final hole in polygon.skip(1)) {
          area -= hole.signedArea2D().abs();
        }
      }
    }
    return area;
  }

  @override
  Position? centroid2D({PositionScheme scheme = Position.scheme}) {
    final calculator = CompositeCentroid();
    for (final pol in polygons) {
      final centroid = pol.centroid2D(scheme: scheme);
      if (centroid != null) {
        calculator.addCentroid2D(
          centroid,
          area: pol.area2D(),
          length: pol.exterior?.length2D(),
        );
      }
    }
    return calculator.centroid2D(scheme: scheme);
  }

  @override
  double distanceTo2D(Position destination) {
    var minDistance = double.infinity;
    for (final pol in polygons) {
      final dist = pol.distanceTo2D(destination);
      if (dist < minDistance) {
        minDistance = dist;
      }
    }
    return minDistance;
  }

  /// Returns true if [point] is inside this multi polygon.
  ///
  /// See also [CartesianArealExtension.isPointInPolygon2D] and
  /// [Polygon.isPointInPolygon2D] for reference.
  bool isPointInPolygon2D(Position point) {
    for (final pol in polygons) {
      if (pol.isPointInPolygon2D(point)) {
        return true;
      }
    }
    return false;
  }

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      isEmptyByGeometry
          ? writer.emptyGeometry(Geom.multiPolygon, name: name)
          : writer.multiPolygon(ringArrays, name: name, bounds: bounds);

  // NOTE: coordinates as raw data

  @override
  bool equalsCoords(Geometry other) => testEqualsCoords<MultiPolygon>(
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
    Geometry other, {
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
    Geometry other, {
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
      identical(this, other) ||
      (other is MultiPolygon &&
          bounds == other.bounds &&
          ringArrays == other.ringArrays);

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
