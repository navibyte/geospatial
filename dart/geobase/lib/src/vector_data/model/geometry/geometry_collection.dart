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
import '/src/coordinates/projection/projection.dart';
import '/src/utils/bounded_utils.dart';
import '/src/utils/coord_type.dart';
import '/src/utils/geometry_calculations_cartesian.dart';
import '/src/vector/content/geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';

import 'geometry.dart';
import 'geometry_builder.dart';

/// A geometry collection with geometries.
class GeometryCollection<E extends Geometry> extends Geometry {
  final List<E> _geometries;
  final Coords _coordType;

  /// A geometry collection with [geometries] and optional [bounds].
  ///
  /// An optional [type] specifies the coordinate type of geometry objects in a
  /// collection. When not provided, the type can be resolved from objects.
  ///
  /// Examples:
  ///
  /// ```dart
  /// GeometryCollection([
  ///   // a point with a 2D position
  ///   Point([10.0, 20.0].xy),
  ///
  ///   // a point with a 3D position
  ///   Point([10.0, 20.0, 30.0].xyz),
  ///
  ///   // a line string from three 3D positions
  ///   LineString.from([
  ///     [10.0, 20.0, 30.0].xyz,
  ///     [12.5, 22.5, 32.5].xyz,
  ///     [15.0, 25.0, 35.0].xyz,
  ///   ])
  /// ]);
  /// ```
  GeometryCollection(List<E> geometries, {Coords? type, super.bounds})
      : _geometries = geometries,
        _coordType = type ?? resolveCoordTypeFrom(collection: geometries);

  const GeometryCollection._(this._geometries, this._coordType, {super.bounds});

  /// Builds a geometry collection from the content provided by [geometries].
  ///
  /// Only geometry objects of [E] are built, any other geometries are ignored.
  ///
  /// An optional [type] specifies the coordinate type of geometry objects in a
  /// collection. When not provided, the type can be resolved from objects.
  ///
  /// An optional expected [count], when given, specifies the number of geometry
  /// objects in a content stream. Note that when given the count MUST be exact.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry
  /// collection.
  ///
  /// Examples:
  ///
  /// ```dart
  /// GeometryCollection.build(
  ///   count: 3,
  ///   (GeometryContent geom) {
  ///     geom
  ///       // a point with a 2D position
  ///       ..point([10.0, 20.0].xy)
  ///
  ///       // a point with a 3D position
  ///       ..point([10.0, 20.0, 30.0].xyz)
  ///
  ///       // a line string from three 3D positions
  ///       ..lineString(
  ///         [
  ///           10.0, 20.0, 30.0,
  ///           12.5, 22.5, 32.5,
  ///           15.0, 25.0, 35.0,
  ///           //
  ///         ].positions(Coords.xyz),
  ///       );
  ///   },
  /// );
  /// ```
  factory GeometryCollection.build(
    WriteGeometries geometries, {
    Coords? type,
    int? count,
    Box? bounds,
  }) =>
      GeometryCollection<E>(
        GeometryBuilder.buildList<E>(geometries, count: count),
        bounds: bounds,
        type: type,
      );

  /// Parses a geometry collection with elements of [T] from [text] conforming
  /// to [format].
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
  /// GeometryCollection.parse(
  ///   format: GeoJSON.geometry,
  ///   '''
  ///   {
  ///     "type": "GeometryCollection",
  ///     "geometries": [
  ///       {"type": "Point", "coordinates": [10.0, 20.0]},
  ///       {"type": "Point", "coordinates": [10.0, 20.0, 30.0]},
  ///       {"type": "LineString",
  ///         "coordinates": [
  ///           [10.0, 20.0, 30.0],
  ///           [12.5, 22.5, 32.5],
  ///           [15.0, 25.0, 35.0]
  ///         ]
  ///       }
  ///     ]
  ///   }
  ///   ''',
  /// );
  ///
  /// GeometryCollection.parse(
  ///   format: WKT.geometry,
  ///   '''
  ///   GEOMETRYCOLLECTION (
  ///     POINT (10.0 20.0),
  ///     POINT Z (10.0 20.0 30.0),
  ///     LINESTRING Z (
  ///       (10.0 20.0 30.0),
  ///       (12.5 22.5 32.5),
  ///       (15.0 25.0 35.0)
  ///     )
  ///   )
  ///   ''',
  /// );
  /// ```
  static GeometryCollection<T> parse<T extends Geometry>(
    String text, {
    TextReaderFormat<GeometryContent> format = GeoJSON.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.parseCollection<T>(
        text,
        format: format,
        crs: crs,
        options: options,
      );

  /// Decodes a geometry collection with elements of [T] from [bytes] conforming
  /// to [format].
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
  /// See also [decodeHex] to decode from bytes represented as a hex string.
  static GeometryCollection<T> decode<T extends Geometry>(
    Uint8List bytes, {
    BinaryFormat<GeometryContent> format = WKB.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decodeCollection<T>(
        bytes,
        format: format,
        crs: crs,
        options: options,
      );

  /// Decodes a geometry collection with elements of [T] from [bytesHex] (as a
  /// hex string) conforming to [format].
  ///
  /// See [decode] for more information.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a geometry collection from a WKB encoded hex string - same geometry as
  /// // WKT: "GEOMETRYCOLLECTION(POINT(10.1 20.2),POINT(10.1 20.2),LINESTRING(10.1 10.1,20.2 20.2,30.3 30.3))"
  /// GeometryCollection.decodeHex('0107000000030000000101000000333333333333244033333333333334400101000000333333333333244033333333333334400102000000030000003333333333332440333333333333244033333333333334403333333333333440cdcccccccc4c3e40cdcccccccc4c3e40');
  /// ```
  static GeometryCollection<T> decodeHex<T extends Geometry>(
    String bytesHex, {
    BinaryFormat<GeometryContent> format = WKB.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decodeCollectionHex<T>(
        bytesHex,
        format: format,
        crs: crs,
        options: options,
      );

  @override
  Geom get geomType => Geom.geometryCollection;

  @override
  Coords get coordType => _coordType;

  @override
  bool get isEmptyByGeometry => _geometries.isEmpty;

  /// All geometry items in this geometry collection.
  List<E> get geometries => _geometries;

  /// Returns a new geometry collection with all geometries mapped using
  /// [toGeometry].
  ///
  /// If [bounds] object is available on this, then it's not recalculated and
  /// the returned object has it set null.
  GeometryCollection<E> map(E Function(E geometry) toGeometry) {
    final mapped = geometries.map<E>(toGeometry).toList(growable: false);
    final type = resolveCoordTypeFrom(collection: mapped);

    return GeometryCollection<E>._(mapped, type);
  }

  @override
  Box? calculateBounds({PositionScheme scheme = Position.scheme}) => geometries
      .map((geom) => geom.calculateBounds(scheme: scheme))
      .merge()
      ?.copyByType(coordType);

  @override
  GeometryCollection populated({
    int traverse = 0,
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  }) {
    if (onBounds) {
      // populate geometries when traversing is asked
      final coll = traverse > 0 && geometries.isNotEmpty
          ? geometries
              .map<E>(
                (f) => f.populated(
                  traverse: traverse - 1,
                  onBounds: onBounds,
                  scheme: scheme,
                ) as E,
              )
              .toList(growable: false)
          : geometries;

      // create a new collection if geometries changed or bounds was unpopulated
      // or of other scheme
      final b = bounds;
      final empty = coll.isEmpty;
      if (coll != geometries ||
          (b == null && !empty) ||
          (b != null && !b.conforming.conformsWith(scheme))) {
        return GeometryCollection<E>._(
          coll,
          coordType,
          bounds: empty
              ? null
              : coll
                  .map((geom) => geom.getBounds(scheme: scheme))
                  .merge()
                  ?.copyByType(coordType),
        );
      }
    }
    return this;
  }

  @override
  GeometryCollection unpopulated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // unpopulate geometries when traversing is asked
      final coll = traverse > 0 && geometries.isNotEmpty
          ? geometries
              .map<E>(
                (f) => f.unpopulated(traverse: traverse - 1, onBounds: onBounds)
                    as E,
              )
              .toList(growable: false)
          : geometries;

      // create a new collection if geometries changed or bounds was populated
      if (coll != geometries || bounds != null) {
        return GeometryCollection<E>._(coll, coordType);
      }
    }
    return this;
  }

  @override
  GeometryCollection<E> project(Projection projection) {
    final projected = _geometries
        .map<E>((geometry) => geometry.project(projection) as E)
        .toList(growable: false);

    return GeometryCollection<E>._(projected, coordType);
  }

  @override
  double length2D() {
    var length = 0.0;
    for (final geom in geometries) {
      length += geom.length2D();
    }
    return length;
  }

  @override
  double length3D() {
    var length = 0.0;
    for (final geom in geometries) {
      length += geom.length3D();
    }
    return length;
  }

  @override
  double area2D() {
    var area = 0.0;
    for (final geom in geometries) {
      area += geom.area2D();
    }
    return area;
  }

  @override
  Position? centroid2D({PositionScheme scheme = Position.scheme}) {
    final calculator = CompositeCentroid();
    for (final geom in geometries) {
      final centroid = geom.centroid2D(scheme: scheme);
      if (centroid != null) {
        calculator.addCentroid2D(
          centroid,
          area: geom.area2D(),
          length: geom.length2D(),
        );
      }
    }
    return calculator.centroid2D(scheme: scheme);
  }

  @override
  void writeTo(GeometryContent writer, {String? name}) => isEmptyByGeometry
      ? writer.emptyGeometry(Geom.geometryCollection, name: name)
      : writer.geometryCollection(
          type: coordType,
          count: _geometries.length,
          name: name,
          (output) {
            for (final geom in _geometries) {
              geom.writeTo(output);
            }
          },
          bounds: bounds,
        );

  @override
  bool equalsCoords(Geometry other) => testEqualsCoords<GeometryCollection<E>>(
        this,
        other,
        (collection1, collection2) => _testGeometryCollections<E>(
          collection1,
          collection2,
          (geometry1, geometry2) => geometry1.equalsCoords(geometry2),
        ),
      );

  @override
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
  }) =>
      testEquals2D<GeometryCollection<E>>(
        this,
        other,
        (collection1, collection2) => _testGeometryCollections<E>(
          collection1,
          collection2,
          (geometry1, geometry2) => geometry1.equals2D(
            geometry2,
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
      testEquals3D<GeometryCollection<E>>(
        this,
        other,
        (collection1, collection2) => _testGeometryCollections<E>(
          collection1,
          collection2,
          (geometry1, geometry2) => geometry1.equals3D(
            geometry2,
            toleranceHoriz: toleranceHoriz,
            toleranceVert: toleranceVert,
          ),
        ),
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  @override
  bool operator ==(Object other) =>
      other is GeometryCollection &&
      bounds == other.bounds &&
      geometries == other.geometries;

  @override
  int get hashCode => Object.hash(bounds, geometries);
}

bool _testGeometryCollections<E extends Geometry>(
  GeometryCollection<E> collection1,
  GeometryCollection<E> collection2,
  bool Function(E, E) testGeometries,
) {
  // test geometries contained
  final geoms1 = collection1.geometries;
  final geoms2 = collection2.geometries;
  if (geoms1.length != geoms2.length) return false;
  for (var i = 0; i < geoms1.length; i++) {
    // use given function to test geometries by index from both
    // collections
    if (!testGeometries(geoms1[i], geoms2[i])) {
      return false;
    }
  }

  // got here, geometries equals by coordinates
  return true;
}
