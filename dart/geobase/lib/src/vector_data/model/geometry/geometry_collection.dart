// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/geom.dart';
import '/src/utils/coord_arrays.dart';
import '/src/vector/content.dart';
import '/src/vector/encoding.dart';
import '/src/vector/formats.dart';

import 'geometry.dart';
import 'geometry_builder.dart';

/// A geometry collection with geometries.
class GeometryCollection<E extends Geometry> extends Geometry {
  final List<E> _geometries;

  /// A geometry collection with [geometries] and optional [bounds].
  const GeometryCollection(List<E> geometries, {super.bounds})
      : _geometries = geometries;

  /// A geometry collection from the content provided by [geometries].
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
    Iterable<double>? bounds,
  }) =>
      GeometryCollection<E>(
        GeometryBuilder.buildList<E>(geometries, count: count),
        bounds: boxFromCoordsOpt(bounds),
      );

  /// Decodes a geometry collection with elements of [T] from [text] conforming
  /// to [format].
  ///
  /// When [format] is not given, then [GeoJSON] is used as a default.
  static GeometryCollection<T> fromText<T extends Geometry>(
    String text, {
    TextReaderFormat<GeometryContent> format = GeoJSON.geometry,
  }) =>
      GeometryBuilder.decodeTextAsCollection<T>(
        text,
        format: format,
      );

  @override
  Geom get geomType => Geom.geometryCollection;

  /// All geometry items in this geometry collection.
  List<E> get geometries => _geometries;

  @override
  void writeTo(GeometryContent writer, {String? name}) =>
      writer.geometryCollection(
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
  bool operator ==(Object other) =>
      other is GeometryCollection &&
      bounds == other.bounds &&
      geometries == other.geometries;

  @override
  int get hashCode => Object.hash(bounds, geometries);
}
