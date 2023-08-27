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
import '/src/utils/bounds_builder.dart';
import '/src/utils/coord_type.dart';
import '/src/utils/tolerance.dart';
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
  GeometryCollection(List<E> geometries, {super.bounds})
      : _geometries = geometries,
        _coordType = resolveCoordTypeFrom(collection: geometries);

  const GeometryCollection._(this._geometries, this._coordType, {super.bounds});

  /// Builds a geometry collection from the content provided by [geometries].
  ///
  /// Only geometry objects of [E] are built, any other geometries are ignored.
  ///
  /// An optional expected [count], when given, specifies the number of geometry
  /// objects in a content stream. Note that when given the count MUST be exact.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry
  /// collection.
  ///
  /// An example to build a geometry collection with two child geometries:
  /// ```dart
  ///   GeometryCollection.build(
  ///       count: 2,
  ///       (geom) => geom
  ///         ..point([10.123, 20.25])
  ///         ..polygon(
  ///           [
  ///              [
  ///                 10.1, 10.1,
  ///                 5.0, 9.0,
  ///                 12.0, 4.0,
  ///                 10.1, 10.1,
  ///              ],
  ///           ],
  ///           type: Coords.xy,
  ///         ),
  ///     );
  /// ```
  ///
  /// An example to build a type geometry collection with points only:
  /// ```dart
  ///   GeometryCollection<Point>.build(
  ///       count: 3,
  ///       (geom) => geom
  ///         ..point([-1.1, -1.1])
  ///         ..point([2.1, -2.5])
  ///         ..point([3.5, -3.49]),
  ///     );
  /// ```
  factory GeometryCollection.build(
    WriteGeometries geometries, {
    int? count,
    Box? bounds,
  }) =>
      GeometryCollection<E>(
        GeometryBuilder.buildList<E>(geometries, count: count),
        bounds: bounds,
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
  bool get isEmpty => _geometries.isEmpty;

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
  GeometryCollection<E> bounded({bool recalculate = false}) {
    if (isEmpty) return this;

    // ensure all geometries contained are processed first
    final collection = _geometries
        .map<E>(
          (geometry) => geometry.bounded(recalculate: recalculate) as E,
        )
        .toList(growable: false);
    final type = resolveCoordTypeFrom(collection: collection);

    // return a new collection with processed geometries and populated bounds
    return GeometryCollection<E>._(
      collection,
      type,
      bounds: recalculate || bounds == null
          ? _buildBoundsFrom(collection, type)
          : bounds,
    );
  }

  @override
  GeometryCollection<E> project(Projection projection) {
    final projected = _geometries
        .map<E>((geometry) => geometry.project(projection) as E)
        .toList(growable: false);
    final type = resolveCoordTypeFrom(collection: projected);

    return GeometryCollection<E>._(
      projected,
      type,

      // bounds calculated from projected collection if there was bounds before
      bounds: bounds != null ? _buildBoundsFrom(projected, type) : null,
    );
  }

  @override
  void writeTo(GeometryContent writer, {String? name}) => isEmpty
      ? writer.emptyGeometry(Geom.geometryCollection, name: name)
      : writer.geometryCollection(
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
  bool equalsCoords(Geometry other) {
    if (other is! GeometryCollection) return false;
    if (identical(this, other)) return true;
    if (bounds != null && other.bounds != null && !(bounds! == other.bounds!)) {
      // both geometries has bound boxes and boxes do not equal
      return false;
    }

    final g1 = geometries;
    final g2 = other.geometries;
    if (g1.length != g2.length) return false;
    for (var i = 0; i < g1.length; i++) {
      if (!g1[i].equalsCoords(g2[i])) return false;
    }
    return true;
  }

  @override
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    if (other is! GeometryCollection) return false;
    if (isEmpty || other.isEmpty) return false;
    if (bounds != null &&
        other.bounds != null &&
        !bounds!.equals2D(
          other.bounds!,
          toleranceHoriz: toleranceHoriz,
        )) {
      // both geometries has bound boxes and boxes do not equal in 2D
      return false;
    }
    // ensure both collections has same amount of geometries
    final g1 = geometries;
    final g2 = other.geometries;
    if (g1.length != g2.length) return false;
    // loop all geometries and test 2D coordinates
    for (var i = 0; i < g1.length; i++) {
      if (!g1[i].equals2D(
        g2[i],
        toleranceHoriz: toleranceHoriz,
      )) {
        return false;
      }
    }
    return true;
  }

  @override
  bool equals3D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    assertTolerance(toleranceVert);
    if (other is! GeometryCollection) return false;
    if (isEmpty || other.isEmpty) return false;
    if (bounds != null &&
        other.bounds != null &&
        !bounds!.equals3D(
          other.bounds!,
          toleranceHoriz: toleranceHoriz,
          toleranceVert: toleranceVert,
        )) {
      // both geometries has bound boxes and boxes do not equal in 3D
      return false;
    }
    // ensure both collections has same amount of geometries
    final g1 = geometries;
    final g2 = other.geometries;
    if (g1.length != g2.length) return false;
    // loop all geometries and test 3D coordinates
    for (var i = 0; i < g1.length; i++) {
      if (!g1[i].equals3D(
        g2[i],
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      )) {
        return false;
      }
    }
    return true;
  }

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
