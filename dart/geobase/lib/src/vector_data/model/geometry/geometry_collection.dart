// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/reference/coord_ref_sys.dart';
import '/src/utils/bounded_utils.dart';
import '/src/utils/bounds_builder.dart';
import '/src/utils/coord_type.dart';
import '/src/vector/content/geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';
import '/src/vector_data/model/bounded/bounded.dart';

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
  /// Format or decoder implementation specific options can be set by [options].
  static GeometryCollection<T> decode<T extends Geometry>(
    Uint8List bytes, {
    BinaryFormat<GeometryContent> format = WKB.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decodeCollection<T>(
        bytes,
        format: format,
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
  /// If [bounds] object is available on this, it's recalculated after
  /// mapping geometries. If [bounds] is null, then it's null after mapping too.
  GeometryCollection<E> map(E Function(E geometry) toGeometry) {
    final mapped = geometries.map<E>(toGeometry).toList(growable: false);
    final type = resolveCoordTypeFrom(collection: mapped);

    return GeometryCollection<E>._(
      mapped,
      type,
      bounds: bounds != null ? _buildBoundsFrom(mapped, type) : null,
    );
  }

  @override
  Box? calculateBounds() => BoundsBuilder.calculateBounds(
        collection: _geometries,
        type: coordType,
        recalculateChilds: true,
      );

  @override
  @Deprecated('Use populated or unpopulated instead.')
  GeometryCollection<E> bounded({bool recalculate = false}) {
    if (isEmptyByGeometry) return this;

    // ensure all geometries contained are processed first
    final collection = _geometries
        .map<E>(
          // ignore: deprecated_member_use_from_same_package
          (geometry) => geometry.bounded(recalculate: recalculate) as E,
        )
        .toList(growable: false);

    // return a new collection with processed geometries and populated bounds
    return GeometryCollection<E>._(
      collection,
      coordType,
      bounds: recalculate || bounds == null
          ? _buildBoundsFrom(collection, coordType)
          : bounds,
    );
  }

  @override
  GeometryCollection populated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // populate geometries when traversing is asked
      final coll = traverse > 0 && geometries.isNotEmpty
          ? geometries
              .map<E>(
                (f) => f.populated(traverse: traverse - 1, onBounds: onBounds)
                    as E,
              )
              .toList(growable: false)
          : geometries;

      // create a new collection if geometries changed or bounds was unpopulated
      if (coll != geometries || (bounds == null && coll.isNotEmpty)) {
        return GeometryCollection<E>._(
          coll,
          coordType,
          bounds: _buildBoundsFrom(coll, coordType),
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

    return GeometryCollection<E>._(
      projected,
      coordType,

      // bounds calculated from projected collection if there was bounds before
      bounds: bounds != null ? _buildBoundsFrom(projected, coordType) : null,
    );
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
  bool equalsCoords(Bounded other) => testEqualsCoords<GeometryCollection<E>>(
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
    Bounded other, {
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
    Bounded other, {
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

/// Returns bounds calculated from a geometry collection.
Box? _buildBoundsFrom(Iterable<Geometry> geometries, Coords type) =>
    BoundsBuilder.calculateBounds(
      collection: geometries,
      type: type,
      recalculateChilds: false,
    );

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
