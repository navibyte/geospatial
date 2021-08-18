// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../../base.dart';
import '../../feature.dart';

import 'range.dart';

/// A function to parse bounds from [coords] and using [pointFactory].
///
/// Throws FormatException if cannot create bounds.
typedef CreateBounds<T extends Point> = Bounds<T> Function(Iterable<num> coords,
    {required PointFactory<T> pointFactory});

/// A function to create a feature of [id], [properties], [geometry] + [bounds].
///
/// If a feature is read from JSON data then an optional [jsonObject] contains
/// an JSON Object for a feature as-is. If source is other than JSON then this
/// may be unavailable.
typedef CreateFeature = Feature<T> Function<T extends Geometry>(
    {Object? id,
    required Map<String, Object?> properties,
    T? geometry,
    Bounds? bounds,
    Map<String, Object?>? jsonObject});

/// A factory to create geospatial geometries and features from source data.
///
/// The factory class and all its sub classes must be stateless.
abstract class GeoFactory {
  /// Default `const` constructor to allow extending this abstract class.
  const GeoFactory();

  /// Parses a geometry from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  T geometry<T extends Geometry>(dynamic data);

  /// Parses a feature from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  Feature<T> feature<T extends Geometry>(dynamic data);

  /// Parses a series of features from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  BoundedSeries<Feature<T>> featureSeries<T extends Geometry>(dynamic data,
      {Range? range});

  /// Parses a feature collection from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  FeatureCollection<Feature<T>> featureCollection<T extends Geometry>(
      dynamic data,
      {Range? range});

  /// Count number of features on a collection parsed from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  int featureCount(dynamic data, {Range? range});
}

/// A base implementation of [GeoFactory] with point and feature factories.
///
/// This class also introduces some helper methods to parse specific geometries.
abstract class GeoFactoryBase<PointType extends Point> extends GeoFactory {
  /// A constructor of [GeoFactoryBase] with point and feature factories given.
  const GeoFactoryBase(
      {required this.pointFactory,
      required this.boundsFactory,
      required this.featureFactory});

  /// A factory to create point objects from coordinate values.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom point instances.
  final PointFactory<PointType> pointFactory;

  /// A function to create bounds objects from min and max points.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom bounds instances.
  final CreateBounds<PointType> boundsFactory;

  /// A factory function to create a [Feature] object.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom [Feature] instances.
  final CreateFeature featureFactory;

  /// Parses a point geometry from [coords] containing at least 2 valid values.
  ///
  /// Assumes that [coords] contains only `num` objects (that is either `double`
  /// or `int` objects).
  ///
  /// Throws FormatException if cannot create point.
  PointType point(Iterable<dynamic> coords) => pointFactory
      .newFrom(coords is Iterable<num> ? coords : coords.cast<num>());

  /// Parses bounds geometry from [coords].
  ///
  /// Assumes that [coords] contains only `num` objects (that is either `double`
  /// or `int` objects).
  ///
  /// Throws FormatException if cannot create bounds.
  Bounds<PointType> bounds(Iterable<dynamic> coords) =>
      boundsFactory(coords is Iterable<num> ? coords : coords.cast<num>(),
          pointFactory: pointFactory);

  /// Parses a series of [points] (an iterable of iterables of nums).
  ///
  /// Throws FormatException if cannot create a series or points on it.
  PointSeries<PointType> pointSeries(Iterable<dynamic> points) =>
      PointSeries<PointType>.from(
          points.map<PointType>((dynamic coords) => point(coords as Iterable)));

  /// Parses a line string from series of [points].
  ///
  /// Throws FormatException if cannot create a line string.
  LineString<PointType> lineString(Iterable<dynamic> points,
          {LineStringType type = LineStringType.any}) =>
      LineString<PointType>(pointSeries(points), type: type);

  /// Parses a series of line strings.
  ///
  /// Throws FormatException if cannot create a series of line strings.
  BoundedSeries<LineString<PointType>> lineStringSeries(
          Iterable<dynamic> lineStrings,
          {LineStringType type = LineStringType.any}) =>
      BoundedSeries<LineString<PointType>>.from(
          lineStrings.map<LineString<PointType>>(
              (dynamic points) => lineString(points as Iterable, type: type)));

  /// Parses a polygon from a series of rings (closed and simple line strings).
  ///
  /// Throws FormatException if cannot create a polygon.
  Polygon<PointType> polygon(Iterable<dynamic> rings) =>
      Polygon<PointType>(lineStringSeries(rings, type: LineStringType.ring));

  /// Parses a series of polygons.
  ///
  /// Throws FormatException if cannot create a series of polygons.
  BoundedSeries<Polygon<PointType>> polygonSeries(Iterable<dynamic> polygons) =>
      BoundedSeries<Polygon<PointType>>.from(polygons.map<Polygon<PointType>>(
          (dynamic rings) => polygon(rings as Iterable)));

  /// Parses a multi point geometry from [points].
  ///
  /// Throws FormatException if cannot create a multi point geometry.
  MultiPoint<PointType> multiPoint(Iterable<dynamic> points) =>
      MultiPoint<PointType>(pointSeries(points));

  /// Parses a multi line string geometry from [lineStrings].
  ///
  /// Throws FormatException if cannot create a multi line string geometry.
  MultiLineString<PointType> multiLineString(Iterable<dynamic> lineStrings) =>
      MultiLineString<PointType>(lineStringSeries(lineStrings));

  /// Parses a multi polygon geometry from [polygons].
  ///
  /// Throws FormatException if cannot create a multi polygon geometry.
  MultiPolygon<PointType> multiPolygon(Iterable<dynamic> polygons) =>
      MultiPolygon<PointType>(polygonSeries(polygons));

  /// Parses a series of geometries from [geometries].
  ///
  /// Throws FormatException if cannot create a a series of geometrie.
  BoundedSeries<T> geometrySeries<T extends Geometry>(
          Iterable<dynamic> geometries) =>
      BoundedSeries<T>.from(
          geometries.map<T>((dynamic geom) => geometry<T>(geom)));

  /// Parses a geometry collection from [geometries].
  ///
  /// Throws FormatException if cannot create a geometry collection.
  GeometryCollection<T> geometryCollection<T extends Geometry>(
          Iterable<dynamic> geometries) =>
      GeometryCollection<T>(geometrySeries<T>(geometries));
}

/*
import '../../base.dart';
import '../../feature.dart';

import 'range.dart';

/// A function to parse bounds from [coords] and using [pointFactory].
///
/// Throws FormatException if cannot create bounds.
typedef CreateBounds<T extends Point> = Bounds<T> Function(Iterable<num> coords,
    {required PointFactory<T> pointFactory});

/// A function to create a feature of [id], [properties], [geometry] + [bounds].
///
/// If a feature is read from JSON data then an optional [jsonObject] contains
/// an JSON Object for a feature as-is. If source is other than JSON then this
/// may be unavailable.
typedef CreateFeature = Feature<T> Function<T extends Geometry>(
    {Object? id,
    required Map<String, Object?> properties,
    T? geometry,
    Bounds? bounds,
    Map<String, Object?>? jsonObject});

/// A factory to create geospatial geometries and features from source data.
///
/// The factory class and all its sub classes must be stateless.
abstract class GeoFactory {
  const GeoFactory();

  /// Parses a geometry from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  T geometry<T extends Geometry>(Object data);

  /// Parses a feature from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  Feature<T> feature<T extends Geometry>(Object data);

  /// Parses a series of features from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  BoundedSeries<Feature<T>> featureSeries<T extends Geometry>(Object data,
      {Range? range});

  /// Parses a feature collection from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  FeatureCollection<Feature<T>> featureCollection<T extends Geometry>(
      Object data,
      {Range? range});

  /// Count number of features on a collection parsed from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  int featureCount(Object data, {Range? range});
}

/// A base implementation of [GeoFactory] with point and feature factories.
///
/// This class also introduces some helper methods to parse specific geometries.
abstract class GeoFactoryBase<PointType extends Point> extends GeoFactory {
  /// A constructor of [GeoFactoryBase] with point and feature factories given.
  const GeoFactoryBase(
      {required this.pointFactory,
      required this.boundsFactory,
      required this.featureFactory});

  /// A factory to create point objects from coordinate values.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom point instances.
  final PointFactory<PointType> pointFactory;

  /// A function to create bounds objects from min and max points.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom bounds instances.
  final CreateBounds<PointType> boundsFactory;

  /// A factory function to create a [Feature] object.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom [Feature] instances.
  final CreateFeature featureFactory;

  /// Parses a point geometry from [coords] containing at least 2 valid values.
  ///
  /// Assumes that [coords] contains only `num` objects (that is either `double`
  /// or `int` objects).
  ///
  /// Throws FormatException if cannot create point.
  PointType point(Iterable<Object> coords) => pointFactory
      .newFrom(coords is Iterable<num> ? coords : coords.cast<num>());

  /// Parses bounds geometry from [coords].
  ///
  /// Assumes that [coords] contains only `num` objects (that is either `double`
  /// or `int` objects).
  ///
  /// Throws FormatException if cannot create bounds.
  Bounds<PointType> bounds(Iterable<Object> coords) =>
      boundsFactory(coords is Iterable<num> ? coords : coords.cast<num>(),
          pointFactory: pointFactory);

  /// Parses a series of [points] (an iterable of iterables of nums).
  ///
  /// Throws FormatException if cannot create a series or points on it.
  PointSeries<PointType> pointSeries(Iterable<Object> points) =>
      PointSeries<PointType>.from(
          points.whereType<Iterable<Object>>().map<PointType>(point));

  /// Parses a line string from series of [points].
  ///
  /// Throws FormatException if cannot create a line string.
  LineString<PointType> lineString(Iterable<Object> points,
          {LineStringType type = LineStringType.any}) =>
      LineString<PointType>(pointSeries(points), type: type);

  /// Parses a series of line strings.
  ///
  /// Throws FormatException if cannot create a series of line strings.
  BoundedSeries<LineString<PointType>> lineStringSeries(
          Iterable<Object> lineStrings,
          {LineStringType type = LineStringType.any}) =>
      BoundedSeries<LineString<PointType>>.from(lineStrings
          .whereType<Iterable<Object>>()
          .map<LineString<PointType>>(
              (points) => lineString(points, type: type)));

  /// Parses a polygon from a series of rings (closed and simple line strings).
  ///
  /// Throws FormatException if cannot create a polygon.
  Polygon<PointType> polygon(Iterable<Object> rings) =>
      Polygon<PointType>(lineStringSeries(rings, type: LineStringType.ring));

  /// Parses a series of polygons.
  ///
  /// Throws FormatException if cannot create a series of polygons.
  BoundedSeries<Polygon<PointType>> polygonSeries(Iterable<Object> polygons) =>
      BoundedSeries<Polygon<PointType>>.from(polygons
          .whereType<Iterable<Object>>()
          .map<Polygon<PointType>>(polygon));

  /// Parses a multi point geometry from [points].
  ///
  /// Throws FormatException if cannot create a multi point geometry.
  MultiPoint<PointType> multiPoint(Iterable<Object> points) =>
      MultiPoint<PointType>(pointSeries(points));

  /// Parses a multi line string geometry from [lineStrings].
  ///
  /// Throws FormatException if cannot create a multi line string geometry.
  MultiLineString<PointType> multiLineString(Iterable<Object> lineStrings) =>
      MultiLineString<PointType>(lineStringSeries(lineStrings));

  /// Parses a multi polygon geometry from [polygons].
  ///
  /// Throws FormatException if cannot create a multi polygon geometry.
  MultiPolygon<PointType> multiPolygon(Iterable<Object> polygons) =>
      MultiPolygon<PointType>(polygonSeries(polygons));

  /// Parses a series of geometries from [geometries].
  ///
  /// Throws FormatException if cannot create a a series of geometrie.
  BoundedSeries<T> geometrySeries<T extends Geometry>(
          Iterable<Object> geometries) =>
      BoundedSeries<T>.from(
          geometries.whereType<Object>().map<T>((geom) => geometry<T>(geom)));

  /// Parses a geometry collection from [geometries].
  ///
  /// Throws FormatException if cannot create a geometry collection.
  GeometryCollection<T> geometryCollection<T extends Geometry>(
          Iterable<Object> geometries) =>
      GeometryCollection<T>(geometrySeries<T>(geometries));
}
*/

/*

import '../../base.dart';
import '../../feature.dart';

import 'range.dart';

/// A function to parse bounds from [coords] and using [pointFactory].
///
/// Throws FormatException if cannot create bounds.
typedef CreateBounds<T extends Point> = Bounds<T> Function(Iterable<num> coords,
    {required PointFactory<T> pointFactory});

/// A function to create a feature of [id], [properties], [geometry] + [bounds].
///
/// If a feature is read from JSON data then an optional [jsonObject] contains
/// an JSON Object for a feature as-is. If source is other than JSON then this
/// may be unavailable.
typedef CreateFeature = Feature<T> Function<T extends Geometry>(
    {Object? id,
    required Map<String, Object?> properties,
    T? geometry,
    Bounds? bounds,
    Map<String, Object?>? jsonObject});

/// A factory to create geospatial geometries and features from source data.
///
/// The factory class and all its sub classes must be stateless.
abstract class GeoFactory {
  const GeoFactory();

  /// Parses a geometry from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  T geometry<T extends Geometry>(Object data);

  /// Parses a feature from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  Feature<T> feature<T extends Geometry>(Object data);

  /// Parses a series of features from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  BoundedSeries<Feature<T>> featureSeries<T extends Geometry>(Object data,
      {Range? range});

  /// Parses a feature collection from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  FeatureCollection<Feature<T>> featureCollection<T extends Geometry>(
      Object data,
      {Range? range});

  /// Count number of features on a collection parsed from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  int featureCount(Object data, {Range? range});
}

/// A base implementation of [GeoFactory] with point and feature factories.
///
/// This class also introduces some helper methods to parse specific geometries.
abstract class GeoFactoryBase<PointType extends Point> extends GeoFactory {
  /// A constructor of [GeoFactoryBase] with point and feature factories given.
  const GeoFactoryBase(
      {required this.pointFactory,
      required this.boundsFactory,
      required this.featureFactory});

  /// A factory to create point objects from coordinate values.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom point instances.
  final PointFactory<PointType> pointFactory;

  /// A function to create bounds objects from min and max points.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom bounds instances.
  final CreateBounds<PointType> boundsFactory;

  /// A factory function to create a [Feature] object.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom [Feature] instances.
  final CreateFeature featureFactory;

  /// Parses a point geometry from [coords] containing at least 2 valid values.
  ///
  /// Assumes that [coords] contains only `num` objects (that is either `double`
  /// or `int` objects).
  ///
  /// Throws FormatException if cannot create point.
  PointType point(Iterable<Object?> coords) => pointFactory
      .newFrom(coords is Iterable<num> ? coords : coords.cast<num>());

  /// Parses bounds geometry from [coords].
  ///
  /// Assumes that [coords] contains only `num` objects (that is either `double`
  /// or `int` objects).
  ///
  /// Throws FormatException if cannot create bounds.
  Bounds<PointType> bounds(Iterable<Object?> coords) =>
      boundsFactory(coords is Iterable<num> ? coords : coords.cast<num>(),
          pointFactory: pointFactory);

  /// Parses a series of [points] (an iterable of iterables of nums).
  ///
  /// Throws FormatException if cannot create a series or points on it.
  PointSeries<PointType> pointSeries(Iterable<Object?> points) =>
      PointSeries<PointType>.from(
          points.whereType<Iterable<Object?>>().map<PointType>(point));

  /// Parses a line string from series of [points].
  ///
  /// Throws FormatException if cannot create a line string.
  LineString<PointType> lineString(Iterable<Object?> points,
          {LineStringType type = LineStringType.any}) =>
      LineString<PointType>(pointSeries(points), type: type);

  /// Parses a series of line strings.
  ///
  /// Throws FormatException if cannot create a series of line strings.
  BoundedSeries<LineString<PointType>> lineStringSeries(
          Iterable<Object?> lineStrings,
          {LineStringType type = LineStringType.any}) =>
      BoundedSeries<LineString<PointType>>.from(lineStrings
          .whereType<Iterable<Object?>>()
          .map<LineString<PointType>>(
              (points) => lineString(points, type: type)));

  /// Parses a polygon from a series of rings (closed and simple line strings).
  ///
  /// Throws FormatException if cannot create a polygon.
  Polygon<PointType> polygon(Iterable<Object?> rings) =>
      Polygon<PointType>(lineStringSeries(rings, type: LineStringType.ring));

  /// Parses a series of polygons.
  ///
  /// Throws FormatException if cannot create a series of polygons.
  BoundedSeries<Polygon<PointType>> polygonSeries(Iterable<Object?> polygons) =>
      BoundedSeries<Polygon<PointType>>.from(polygons
          .whereType<Iterable<Object?>>()
          .map<Polygon<PointType>>(polygon));

  /// Parses a multi point geometry from [points].
  ///
  /// Throws FormatException if cannot create a multi point geometry.
  MultiPoint<PointType> multiPoint(Iterable<Object?> points) =>
      MultiPoint<PointType>(pointSeries(points));

  /// Parses a multi line string geometry from [lineStrings].
  ///
  /// Throws FormatException if cannot create a multi line string geometry.
  MultiLineString<PointType> multiLineString(Iterable<Object?> lineStrings) =>
      MultiLineString<PointType>(lineStringSeries(lineStrings));

  /// Parses a multi polygon geometry from [polygons].
  ///
  /// Throws FormatException if cannot create a multi polygon geometry.
  MultiPolygon<PointType> multiPolygon(Iterable<Object?> polygons) =>
      MultiPolygon<PointType>(polygonSeries(polygons));

  /// Parses a series of geometries from [geometries].
  ///
  /// Throws FormatException if cannot create a a series of geometrie.
  BoundedSeries<T> geometrySeries<T extends Geometry>(
          Iterable<Object?> geometries) =>
      BoundedSeries<T>.from(
          geometries.whereType<Object>().map<T>((geom) => geometry<T>(geom)));

  /// Parses a geometry collection from [geometries].
  ///
  /// Throws FormatException if cannot create a geometry collection.
  GeometryCollection<T> geometryCollection<T extends Geometry>(
          Iterable<Object?> geometries) =>
      GeometryCollection<T>(geometrySeries<T>(geometries));
}



*/

/*

import '../../base.dart';
import '../../feature.dart';

import 'range.dart';

/// A function to parse bounds from [coords] and using [pointFactory].
///
/// Throws FormatException if cannot create bounds.
typedef CreateBounds<T extends Point> = Bounds<T> Function(Iterable<num> coords,
    {required PointFactory<T> pointFactory});

/// A function to create a feature of [id], [properties], [geometry] + [bounds].
///
/// If a feature is read from JSON data then an optional [jsonObject] contains
/// an JSON Object for a feature as-is. If source is other than JSON then this
/// may be unavailable.
typedef CreateFeature = Feature<T> Function<T extends Geometry>(
    {Object? id,
    required Map<String, Object?> properties,
    T? geometry,
    Bounds? bounds,
    Map<String, Object?>? jsonObject});

/// A factory to create geospatial geometries and features from source data.
///
/// The factory class and all its sub classes must be stateless.
abstract class GeoFactory {
  const GeoFactory();

  /// Parses a geometry from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  T geometry<T extends Geometry>(Object data);

  /// Parses a feature from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  Feature<T> feature<T extends Geometry>(Object data);

  /// Parses a series of features from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  BoundedSeries<Feature<T>> featureSeries<T extends Geometry>(Object data,
      {Range? range});

  /// Parses a feature collection from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  FeatureCollection<Feature<T>> featureCollection<T extends Geometry>(
      Object data,
      {Range? range});

  /// Count number of features on a collection parsed from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  int featureCount(Object data, {Range? range});
}

/// A base implementation of [GeoFactory] with point and feature factories.
///
/// This class also introduces some helper methods to parse specific geometries.
abstract class GeoFactoryBase<PointType extends Point> extends GeoFactory {
  /// A constructor of [GeoFactoryBase] with point and feature factories given.
  const GeoFactoryBase(
      {required this.pointFactory,
      required this.boundsFactory,
      required this.featureFactory});

  /// A factory to create point objects from coordinate values.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom point instances.
  final PointFactory<PointType> pointFactory;

  /// A function to create bounds objects from min and max points.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom bounds instances.
  final CreateBounds<PointType> boundsFactory;

  /// A factory function to create a [Feature] object.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom [Feature] instances.
  final CreateFeature featureFactory;

  /// Parses a point geometry from [coords] containing at least 2 valid values.
  ///
  /// Assumes that [coords] contains only `num` objects (that is either `double`
  /// or `int` objects).
  ///
  /// Throws FormatException if cannot create point.
  PointType point(Iterable<Object> coords) => pointFactory
      .newFrom(coords is Iterable<num> ? coords : coords.cast<num>());

  /// Parses bounds geometry from [coords].
  ///
  /// Assumes that [coords] contains only `num` objects (that is either `double`
  /// or `int` objects).
  ///
  /// Throws FormatException if cannot create bounds.
  Bounds<PointType> bounds(Iterable<Object> coords) =>
      boundsFactory(coords is Iterable<num> ? coords : coords.cast<num>(),
          pointFactory: pointFactory);

  /// Parses a series of [points] (an iterable of iterables of nums).
  ///
  /// Throws FormatException if cannot create a series or points on it.
  PointSeries<PointType> pointSeries(Iterable<Object> points) =>
      PointSeries<PointType>.from(
          points.map<PointType>((coords) => point(coords as Iterable<Object>)));

  /// Parses a line string from series of [points].
  ///
  /// Throws FormatException if cannot create a line string.
  LineString<PointType> lineString(Iterable<Object> points,
          {LineStringType type = LineStringType.any}) =>
      LineString<PointType>(pointSeries(points), type: type);

  /// Parses a series of line strings.
  ///
  /// Throws FormatException if cannot create a series of line strings.
  BoundedSeries<LineString<PointType>> lineStringSeries(
          Iterable<Object> lineStrings,
          {LineStringType type = LineStringType.any}) =>
      BoundedSeries<LineString<PointType>>.from(
          lineStrings.map<LineString<PointType>>(
              (points) => lineString(points as Iterable<Object>, type: type)));

  /// Parses a polygon from a series of rings (closed and simple line strings).
  ///
  /// Throws FormatException if cannot create a polygon.
  Polygon<PointType> polygon(Iterable<Object> rings) =>
      Polygon<PointType>(lineStringSeries(rings, type: LineStringType.ring));

  /// Parses a series of polygons.
  ///
  /// Throws FormatException if cannot create a series of polygons.
  BoundedSeries<Polygon<PointType>> polygonSeries(Iterable<Object> polygons) =>
      BoundedSeries<Polygon<PointType>>.from(polygons.map<Polygon<PointType>>(
          (rings) => polygon(rings as Iterable<Object>)));

  /// Parses a multi point geometry from [points].
  ///
  /// Throws FormatException if cannot create a multi point geometry.
  MultiPoint<PointType> multiPoint(Iterable<Object> points) =>
      MultiPoint<PointType>(pointSeries(points));

  /// Parses a multi line string geometry from [lineStrings].
  ///
  /// Throws FormatException if cannot create a multi line string geometry.
  MultiLineString<PointType> multiLineString(Iterable<Object> lineStrings) =>
      MultiLineString<PointType>(lineStringSeries(lineStrings));

  /// Parses a multi polygon geometry from [polygons].
  ///
  /// Throws FormatException if cannot create a multi polygon geometry.
  MultiPolygon<PointType> multiPolygon(Iterable<Object> polygons) =>
      MultiPolygon<PointType>(polygonSeries(polygons));

  /// Parses a series of geometries from [geometries].
  ///
  /// Throws FormatException if cannot create a a series of geometrie.
  BoundedSeries<T> geometrySeries<T extends Geometry>(
          Iterable<Object> geometries) =>
      BoundedSeries<T>.from(geometries.map<T>((geom) => geometry<T>(geom)));

  /// Parses a geometry collection from [geometries].
  ///
  /// Throws FormatException if cannot create a geometry collection.
  GeometryCollection<T> geometryCollection<T extends Geometry>(
          Iterable<Object> geometries) =>
      GeometryCollection<T>(geometrySeries<T>(geometries));
}

*/
