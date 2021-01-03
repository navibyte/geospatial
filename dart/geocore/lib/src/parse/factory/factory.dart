// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../../base.dart';
import '../../crs.dart';
import '../../feature.dart';

/// A function to parse a point from [coords] with at least 2 valid values.
///
/// Throws FormatException if cannot create point.
typedef CreatePoint = Point Function(Iterable coords,
    {CRS expectedCRS, bool expectM});

/// A function to parse bounds from [coords].
///
/// Throws FormatException if cannot create bounds.
typedef CreateBounds = Bounds Function(Iterable coords,
    {CRS expectedCRS, bool expectM});

/// A function to create a feature of [id], [properties], [geometry] + [bounds].
typedef CreateFeature = Feature<T> Function<T extends Geometry>(
    {dynamic? id,
    required Map<String, dynamic> properties,
    T? geometry,
    Bounds? bounds});

/// A factory to create geospatial geometries and features from source data.
///
/// The factory class and all its sub classes must be stateless.
abstract class GeoFactory {
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
  BoundedSeries<Feature<T>> featureSeries<T extends Geometry>(dynamic data);

  /// Parses a feature collection from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  FeatureCollection<Feature<T>> featureCollection<T extends Geometry>(
      dynamic data);
}

/// A base implementation of [GeoFactory] with expectations (like CRS) set.
///
/// This class also introduces some helper methods to parse specific geometries.
abstract class GeoFactoryBase extends GeoFactory {
  const GeoFactoryBase(
      {required this.createPoint,
      required this.createBounds,
      required this.createFeature,
      this.expectedCRS = CRS84,
      this.expectM = false});

  /// A function to parse a point.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom point instances.
  final CreatePoint createPoint;

  /// A function to parse bounds.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom bounds instances.
  final CreateBounds createBounds;

  /// A function to create a [Feature] object.
  ///
  /// The factory can be adjusted by setting a custom function that creates
  /// custom [Feature] instances.
  final CreateFeature createFeature;

  /// The expected coordinate reference system for coordinates to be parsed.
  final CRS expectedCRS;

  /// Whether to expect M coordinate for coordinates to be parsed.
  final bool expectM;

  /// Parses a point geometry from [coords] containing at least 2 valid values.
  ///
  /// Throws FormatException if cannot create point.
  Point point(Iterable coords) =>
      createPoint(coords, expectedCRS: expectedCRS, expectM: expectM);

  /// Parses bounds geometry from [coords].
  ///
  /// Throws FormatException if cannot create bounds.
  Bounds bounds(Iterable coords) =>
      createBounds(coords, expectedCRS: expectedCRS, expectM: expectM);

  /// Parses a series of [points] (an iterable of iterables of doubles).
  ///
  /// Throws FormatException if cannot create a series or points on it.
  PointSeries pointSeries(Iterable points) =>
      PointSeries.from(points.map<Point>((coords) => point(coords)));

  /// Parses a line string from series of [points].
  ///
  /// Throws FormatException if cannot create a line string.
  LineString lineString(Iterable points,
          {LineStringType type = LineStringType.any}) =>
      LineString(pointSeries(points), type: type);

  /// Parses a series of line strings.
  ///
  /// Throws FormatException if cannot create a series of line strings.
  BoundedSeries<LineString> lineStringSeries(Iterable lineStrings,
          {LineStringType type = LineStringType.any}) =>
      BoundedSeries<LineString>.from(lineStrings
          .map<LineString>((points) => lineString(points, type: type)));

  /// Parses a polygon from a series of rings (closed and simple line strings).
  ///
  /// Throws FormatException if cannot create a polygon.
  Polygon polygon(Iterable rings) =>
      Polygon(lineStringSeries(rings, type: LineStringType.ring));

  /// Parses a series of polygons.
  ///
  /// Throws FormatException if cannot create a series of polygons.
  BoundedSeries<Polygon> polygonSeries(Iterable polygons) =>
      BoundedSeries<Polygon>.from(
          polygons.map<Polygon>((rings) => polygon(rings)));

  /// Parses a multi point geometry from [points].
  ///
  /// Throws FormatException if cannot create a multi point geometry.
  MultiPoint multiPoint(Iterable points) => MultiPoint(pointSeries(points));

  /// Parses a multi line string geometry from [lineStrings].
  ///
  /// Throws FormatException if cannot create a multi line string geometry.
  MultiLineString multiLineString(Iterable lineStrings) =>
      MultiLineString(lineStringSeries(lineStrings));

  /// Parses a multi polygon geometry from [polygons].
  ///
  /// Throws FormatException if cannot create a multi polygon geometry.
  MultiPolygon multiPolygon(Iterable polygons) =>
      MultiPolygon(polygonSeries(polygons));

  /// Parses a series of geometries from [geometries].
  ///
  /// Throws FormatException if cannot create a a series of geometrie.
  BoundedSeries<T> geometrySeries<T extends Geometry>(Iterable geometries) =>
      BoundedSeries<T>.from(geometries.map<T>((geom) => geometry<T>(geom)));

  /// Parses a geometry collection from [geometries].
  ///
  /// Throws FormatException if cannot create a geometry collection.
  GeometryCollection geometryCollection(Iterable geometries) =>
      GeometryCollection(geometrySeries(geometries));
}
