// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A geometry collection.
@immutable
class GeometryCollection<T extends Geometry> extends Geometry
    with EquatableMixin {
  /// Creates [GeometryCollection] from [geometries].
  GeometryCollection(this.geometries);

  /// Create an [GeometryCollection] instance backed by [source].
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory GeometryCollection.view(Iterable<T> source, {Bounds? bounds}) =>
      GeometryCollection(BoundedSeries<T>.view(source, bounds: bounds));

  /// Create an immutable [GeometryCollection] with items copied from [source].
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory GeometryCollection.from(Iterable<T> source, {Bounds? bounds}) =>
      GeometryCollection(BoundedSeries<T>.from(source, bounds: bounds));

  /// All the [geometries] for this multi point.
  final BoundedSeries<T> geometries;

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
  Bounds get bounds => geometries.bounds;

  @override
  List<Object?> get props => [geometries];
}

/// A multi point geometry.
@immutable
class MultiPoint<T extends Point> extends Geometry with EquatableMixin {
  /// Create [MultiPoint] from [points].
  MultiPoint(this.points);

  /// Create [MultiPoint] from [values] with a list of points.
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory MultiPoint.make(
          Iterable<Iterable<num>> values, PointFactory<T> pointFactory,
          {Bounds? bounds}) =>
      MultiPoint<T>(PointSeries<T>.make(values, pointFactory, bounds: bounds));

  /// Create [MultiPoint] parsed from [text] with a list of points.
  ///
  /// If [parser] is null, then WKT [text] like "25.1 53.1, 25.2 53.2" is
  /// expected.
  ///
  /// Throws FormatException if cannot parse.
  factory MultiPoint.parse(String text, PointFactory<T> pointFactory,
          {ParseCoordsList? parser}) =>
      parser != null
          ? MultiPoint<T>.make(parser.call(text), pointFactory)
          : parseWktMultiPoint<T>(text, pointFactory);

  /// All the [points] for this multi point.
  final PointSeries<T> points;

  @override
  int get dimension => 0;

  @override
  bool get isEmpty => points.isEmpty;

  @override
  Bounds get bounds => points.bounds;

  @override
  List<Object?> get props => [points];
}

/// A multi line string geometry.
@immutable
class MultiLineString<T extends Point> extends Geometry with EquatableMixin {
  /// Create a multi line string from [lineStrings].
  MultiLineString(this.lineStrings);

  /// Create [MultiLineString] from [values] with line strings.
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory MultiLineString.make(Iterable<Iterable<Iterable<num>>> values,
          PointFactory<T> pointFactory,
          {LineStringType type = LineStringType.any, Bounds? bounds}) =>
      MultiLineString<T>(BoundedSeries.from(
          values.map<LineString<T>>((pointSeries) =>
              LineString<T>.make(pointSeries, pointFactory, type: type)),
          bounds: bounds));

  /// Create [MultiLineString] parsed from [text] with line strings.
  ///
  /// If [parser] is null, then WKT [text] like
  /// "(25.1 53.1, 25.2 53.2), (35.1 63.1, 35.2 63.2)" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory MultiLineString.parse(String text, PointFactory<T> pointFactory,
          {ParseCoordsListList? parser}) =>
      parser != null
          ? MultiLineString<T>.make(parser.call(text), pointFactory)
          : parseWktMultiLineString<T>(text, pointFactory);

  /// All the [lineStrings] for this multi line string.
  final BoundedSeries<LineString<T>> lineStrings;

  @override
  int get dimension => 1;

  @override
  bool get isEmpty => lineStrings.isEmpty;

  @override
  Bounds get bounds => lineStrings.bounds;

  @override
  List<Object?> get props => [lineStrings];
}

/// A multi polygon geometry.
@immutable
class MultiPolygon<T extends Point> extends Geometry with EquatableMixin {
  /// Create [MultiPolygon] from [polygons].
  MultiPolygon(this.polygons);

  /// Create [MultiPolygon] from [values] with a list of rings for polygons.
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory MultiPolygon.make(Iterable<Iterable<Iterable<Iterable<num>>>> values,
          PointFactory<T> pointFactory, {Bounds? bounds}) =>
      MultiPolygon<T>(BoundedSeries.from(
          values.map<Polygon<T>>(
              (polygon) => Polygon<T>.make(polygon, pointFactory)),
          bounds: bounds));

  /// Create [MultiPolygon] from [text] with a list of rings for polygons.
  ///
  /// If [parser] is null, then WKT [text] like
  /// "((40 15, 50 50, 15 45, 40 15)), ((80 55, 90 90, 55 85, 50 55, 80 55))"
  /// is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory MultiPolygon.parse(String text, PointFactory<T> pointFactory,
          {ParseCoordsListListList? parser}) =>
      parser != null
          ? MultiPolygon<T>.make(parser.call(text), pointFactory)
          : parseWktMultiPolygon<T>(text, pointFactory);

  /// All the [polygons] for this multi polygon.
  final BoundedSeries<Polygon<T>> polygons;

  @override
  int get dimension => 2;

  @override
  bool get isEmpty => polygons.isEmpty;

  @override
  Bounds get bounds => polygons.bounds;

  @override
  List<Object?> get props => [polygons];
}
