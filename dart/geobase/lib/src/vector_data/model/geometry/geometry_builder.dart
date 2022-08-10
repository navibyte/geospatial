// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/coordinates/base.dart';
import '/src/vector/content.dart';

import 'geometry.dart';
import 'geometry_collection.dart';
import 'linestring.dart';
import 'multi_linestring.dart';
import 'multi_point.dart';
import 'multi_polygon.dart';
import 'point.dart';
import 'polygon.dart';

/// A function to add [geometry] to some collection with an optional [name].
typedef AddGeometry<T extends Geometry> = void Function(
  T geometry, {
  String? name,
});

/// A builder to create geometry instances of [T] from [GeometryContent].
///
/// This builder ignore "empty geometry" types.
class GeometryBuilder<T extends Geometry> with GeometryContent {
  final AddGeometry<T> _addGeometry;

  GeometryBuilder._(this._addGeometry);

  void _add(Geometry geometry, {String? name}) {
    if (geometry is T) {
      _addGeometry.call(geometry, name: name);
    }
  }

  /// Builds geometries from the content provided by [geometries].
  ///
  /// Built geometry object are sent into [to] callback function.
  ///
  /// Only geometry objects of [T] are built, any other geometries are ignored.
  static void build<T extends Geometry>(
    WriteGeometries geometries, {
    required AddGeometry<T> to,
  }) {
    final builder = GeometryBuilder<T>._(to);
    geometries.call(builder);
  }

  /// Builds a geometry list from the content provided by [geometries].
  ///
  /// Only geometry objects of [T] are built, any other geometries are ignored.
  ///
  /// An optional expected [count], when given, specifies the number of geometry
  /// objects in the content. Note that when given the count MUST be exact.
  static List<T> buildList<T extends Geometry>(
    WriteGeometries geometries, {
    int? count,
  }) {
    final list = <T>[];
    final builder = GeometryBuilder<T>._((T geometry, {String? name}) {
      list.add(geometry);
    });
    geometries.call(builder);
    return list;
  }

  /// Builds a geometry map from the content provided by [geometries].
  ///
  /// Only geometry objects of [T] are built, any other geometries are ignored.
  ///
  /// The content provided by [GeometryContent] should provide also the `name`
  /// attribute for each geometry object. When `name` is not available, then
  /// an index as String is used a key.
  ///
  /// An optional expected [count], when given, specifies the number of geometry
  /// objects in the content. Note that when given the count MUST be exact.
  static Map<String, T> buildMap<T extends Geometry>(
    WriteGeometries geometries, {
    int? count,
  }) {
    final map = <String, T>{};
    var index = 0;
    final builder = GeometryBuilder<T>._((T geometry, {String? name}) {
      map[name ?? index.toString()] = geometry;
      index++;
    });
    geometries.call(builder);
    return map;
  }

  @override
  void point(
    Iterable<double> position, {
    Coords? type,
    String? name,
  }) {
    _add(
      Point.build(position, type: type),
      name: name,
    );
  }

  @override
  void lineString(
    Iterable<double> chain, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    if (chain.length < 2) {
      // note: ignore empty geometries for this implementation
    }
    _add(
      LineString.build(chain, type: type),
      name: name,
    );
  }

  @override
  void polygon(
    Iterable<Iterable<double>> rings, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    if (rings.isEmpty) {
      // note: ignore empty geometries for this implementation
    }
    _add(
      Polygon.build(rings, type: type),
      name: name,
    );
  }

  @override
  void multiPoint(
    Iterable<Iterable<double>> points, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    _add(
      MultiPoint.build(points, type: type),
      name: name,
    );
  }

  @override
  void multiLineString(
    Iterable<Iterable<double>> lineStrings, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    _add(
      MultiLineString.build(lineStrings, type: type),
      name: name,
    );
  }

  @override
  void multiPolygon(
    Iterable<Iterable<Iterable<double>>> polygons, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    _add(
      MultiPolygon.build(polygons, type: type),
      name: name,
    );
  }

  @override
  void geometryCollection(
    WriteGeometries geometries, {
    int? count,
    String? name,
    Box? bbox,
  }) {
    _add(
      GeometryCollection.build(geometries, count: count),
      name: name,
    );
  }

  @override
  void emptyGeometry(Geom type, {String? name}) {
    // note: ignore empty geometries for this implementation
  }
}
