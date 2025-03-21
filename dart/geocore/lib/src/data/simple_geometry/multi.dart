// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_redundant_argument_values

import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:geobase/coordinates.dart';
import 'package:geobase/vector.dart';
import 'package:meta/meta.dart';

import '/src/base/spatial.dart';
import '/src/utils/wkt_data.dart';

import 'linestring.dart';
import 'polygon.dart';

/// A geometry collection.
@immutable
class GeometryCollection<E extends Geometry> extends Geometry
    with EquatableMixin {
  /// Creates [GeometryCollection] from [geometries].
  GeometryCollection(Iterable<E> geometries)
      : geometries = geometries is BoundedSeries<E>
            ? geometries
            : BoundedSeries.view(geometries);

  /// All [geometries] for this geometry collection.
  final BoundedSeries<E> geometries;

  @override
  Geom get typeGeom => Geom.geometryCollection;

  @override
  int get dimension {
    // A base implementation for calculating a maximum dimension for a series by
    // looping through all items. Should be overridden to provide more efficient
    // implementation as needed.
    var dim = 0;
    for (final element in geometries) {
      dim = math.max(dim, element.dimension);
    }
    return dim;
  }

  @override
  bool get isEmpty => geometries.isEmpty;

  @override
  Bounds? get bounds => geometries.bounds;

  @override
  Bounds? get boundsExplicit => geometries.boundsExplicit;

  @override
  Point? get onePoint =>
      geometries.isNotEmpty ? geometries.first.onePoint : null;

  @override
  List<Object?> get props => [geometries];

  @override
  void writeTo(GeometryContent writer) {
    // note: no need to inform is3D/hasM of the first point, as sub items on
    // a collection are geometries, and each of them should inform those
    writer.geometryCollection(
      (geom) {
        for (final item in geometries) {
          item.writeTo(geom);
        }
      },
      count: geometries.length,
      bounds:
          boundsExplicit != null ? Box.getDoubleList(boundsExplicit!) : null,
    );
  }

  @override
  GeometryCollection<E> transform(TransformPosition transform) =>
      GeometryCollection(geometries.transform(transform, lazy: false));

  @override
  GeometryCollection project<R extends Point>(
    Projection projection, {
    required CreatePosition<R> to,
  }) =>
      // Note: returns GeometryCollection, not GeometryCollection<E> as
      // projected geometries could be other than E as a result of some
      // projections.
      GeometryCollection(
        geometries.convert<Geometry>(
          (geom) => geom.project(projection, to: to),
          lazy: false,
        ),
      );

  @override
  String toString() => toStringAs();
}

/// A multi point geometry.
@immutable
class MultiPoint<E extends Point> extends Geometry with EquatableMixin {
  /// Create [MultiPoint] from [points].
  MultiPoint(Iterable<E> points)
      : points = points is PointSeries<E> ? points : PointSeries.view(points);

  /// Create [MultiPoint] from [values] with a list of points.
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory MultiPoint.make(
    Iterable<Iterable<num>> values,
    PointFactory<E> pointFactory, {
    Bounds? bounds,
  }) =>
      MultiPoint<E>(PointSeries<E>.make(values, pointFactory, bounds: bounds));

  /// Create [MultiPoint] parsed from [text] with a list of points.
  ///
  /// If [parser] is null, then WKT [text] like "25.1 53.1, 25.2 53.2" is
  /// expected.
  ///
  /// Throws FormatException if cannot parse.
  factory MultiPoint.parse(
    String text,
    PointFactory<E> pointFactory, {
    ParseCoordsList? parser,
  }) =>
      parser != null
          ? MultiPoint<E>.make(parser.call(text), pointFactory)
          : parseWktMultiPoint<E>(text, pointFactory);

  /// All the [points] for this multi point.
  final PointSeries<E> points;

  @override
  Geom get typeGeom => Geom.multiPoint;

  @override
  int get dimension => 0;

  @override
  bool get isEmpty => points.isEmpty;

  @override
  Bounds? get bounds => points.bounds;

  @override
  Bounds? get boundsExplicit => points.boundsExplicit;

  @override
  Point? get onePoint => points.isNotEmpty ? points.first : null;

  @override
  List<Object?> get props => [points];

  /// Coordinates of [points] as 1-dimensional array of Position objects.
  Iterable<Position> get coordinates => points;

  @override
  void writeTo(SimpleGeometryContent writer) {
    final type = onePoint?.type ?? Coords.xy;
    writer.multiPoint(
      points.map<Iterable<double>>(Position.getDoubleList),
      type: type,
      bounds:
          boundsExplicit != null ? Box.getDoubleList(boundsExplicit!) : null,
    );
  }

  @override
  MultiPoint<E> transform(TransformPosition transform) =>
      MultiPoint(points.transform(transform, lazy: false));

  @override
  MultiPoint<R> project<R extends Point>(
    Projection projection, {
    required CreatePosition<R> to,
  }) =>
      MultiPoint(points.project(projection, lazy: false, to: to));

  @override
  String toString() => toStringAs();
}

/// A multi line string geometry.
@immutable
class MultiLineString<T extends Point> extends Geometry with EquatableMixin {
  /// Create a multi line string from [lineStrings].
  MultiLineString(Iterable<LineString<T>> lineStrings)
      : lineStrings = lineStrings is BoundedSeries<LineString<T>>
            ? lineStrings
            : BoundedSeries.view(lineStrings);

  /// Create [MultiLineString] from [values] with line strings.
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory MultiLineString.make(
    Iterable<Iterable<Iterable<num>>> values,
    PointFactory<T> pointFactory, {
    LineStringType type = LineStringType.any,
    Bounds? bounds,
  }) =>
      MultiLineString<T>(
        BoundedSeries.from(
          values.map<LineString<T>>(
            (pointSeries) => LineString<T>.make(
              pointSeries,
              pointFactory,
              type: type,
            ),
          ),
          bounds: bounds,
        ),
      );

  /// Create [MultiLineString] parsed from [text] with line strings.
  ///
  /// If [parser] is null, then WKT [text] like
  /// "(25.1 53.1, 25.2 53.2), (35.1 63.1, 35.2 63.2)" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory MultiLineString.parse(
    String text,
    PointFactory<T> pointFactory, {
    ParseCoordsListList? parser,
  }) =>
      parser != null
          ? MultiLineString<T>.make(parser.call(text), pointFactory)
          : parseWktMultiLineString<T>(text, pointFactory);

  /// All the [lineStrings] for this multi line string.
  final BoundedSeries<LineString<T>> lineStrings;

  @override
  Geom get typeGeom => Geom.multiLineString;

  @override
  int get dimension => 1;

  @override
  bool get isEmpty => lineStrings.isEmpty;

  @override
  Bounds? get bounds => lineStrings.bounds;

  @override
  Bounds? get boundsExplicit => lineStrings.boundsExplicit;

  @override
  Point? get onePoint =>
      lineStrings.isNotEmpty ? lineStrings.first.onePoint : null;

  @override
  List<Object?> get props => [lineStrings];

  /// Coordinates of all linestrings as 2-dimensional array of Position objects.
  Iterable<Iterable<Position>> get coordinates =>
      lineStrings.map<Iterable<Position>>((e) => e.chain);

  @override
  void writeTo(SimpleGeometryContent writer) {
    final type = onePoint?.type ?? Coords.xy;
    writer.multiLineString(
      lineStrings.map<Iterable<double>>((e) => e.chain.valuesFlat(type)),
      type: type,
      bounds:
          boundsExplicit != null ? Box.getDoubleList(boundsExplicit!) : null,
    );
  }

  @override
  MultiLineString<T> transform(TransformPosition transform) =>
      MultiLineString(lineStrings.transform(transform, lazy: false));

  @override
  MultiLineString<R> project<R extends Point>(
    Projection projection, {
    required CreatePosition<R> to,
  }) =>
      MultiLineString<R>(
        BoundedSeries.from(
          lineStrings
              .map((lineString) => lineString.project(projection, to: to)),
        ),
      );

  @override
  String toString() => toStringAs();
}

/// A multi polygon geometry.
@immutable
class MultiPolygon<T extends Point> extends Geometry with EquatableMixin {
  /// Create [MultiPolygon] from [polygons].
  MultiPolygon(Iterable<Polygon<T>> polygons)
      : polygons = polygons is BoundedSeries<Polygon<T>>
            ? polygons
            : BoundedSeries.view(polygons);

  /// Create [MultiPolygon] from [values] with a list of rings for polygons.
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory MultiPolygon.make(
    Iterable<Iterable<Iterable<Iterable<num>>>> values,
    PointFactory<T> pointFactory, {
    Bounds? bounds,
  }) =>
      MultiPolygon<T>(
        BoundedSeries.from(
          values.map<Polygon<T>>(
            (polygon) => Polygon<T>.make(
              polygon,
              pointFactory,
            ),
          ),
          bounds: bounds,
        ),
      );

  /// Create [MultiPolygon] from [text] with a list of rings for polygons.
  ///
  /// If [parser] is null, then WKT [text] like
  /// "((40 15, 50 50, 15 45, 40 15)), ((80 55, 90 90, 55 85, 50 55, 80 55))"
  /// is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory MultiPolygon.parse(
    String text,
    PointFactory<T> pointFactory, {
    ParseCoordsListListList? parser,
  }) =>
      parser != null
          ? MultiPolygon<T>.make(parser.call(text), pointFactory)
          : parseWktMultiPolygon<T>(text, pointFactory);

  /// All the [polygons] for this multi polygon.
  final BoundedSeries<Polygon<T>> polygons;

  @override
  Geom get typeGeom => Geom.multiPolygon;

  @override
  int get dimension => 2;

  @override
  bool get isEmpty => polygons.isEmpty;

  @override
  Bounds? get bounds => polygons.bounds;

  @override
  Bounds? get boundsExplicit => polygons.boundsExplicit;

  @override
  Point? get onePoint => polygons.isNotEmpty ? polygons.first.onePoint : null;

  @override
  List<Object?> get props => [polygons];

  /// Coordinates of rings of all polygons as 3-dim array of Position objects.
  Iterable<Iterable<Iterable<Position>>> get coordinates =>
      polygons.map<Iterable<Iterable<Position>>>(
        (e) => e.rings.map<Iterable<Position>>((e) => e.chain),
      );

  @override
  void writeTo(SimpleGeometryContent writer) {
    final type = onePoint?.type ?? Coords.xy;
    writer.multiPolygon(
      polygons.map<Iterable<Iterable<double>>>(
        (e) => e.rings.map<Iterable<double>>((e) => e.chain.valuesFlat(type)),
      ),
      type: type,
      bounds:
          boundsExplicit != null ? Box.getDoubleList(boundsExplicit!) : null,
    );
  }

  @override
  MultiPolygon<T> transform(TransformPosition transform) =>
      MultiPolygon(polygons.transform(transform, lazy: false));

  @override
  MultiPolygon<R> project<R extends Point>(
    Projection projection, {
    required CreatePosition<R> to,
  }) =>
      MultiPolygon<R>(
        BoundedSeries.from(
          polygons.map((polygon) => polygon.project(projection, to: to)),
        ),
      );

  @override
  String toString() => toStringAs();
}
