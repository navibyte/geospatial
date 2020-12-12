// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import '../base/crs.dart';
import '../base/geometry.dart';
import '../base/linestring.dart';
import '../base/multi.dart';
import '../base/point.dart';
import '../base/point_series.dart';
import '../base/polygon.dart';
import '../geo/geopoint.dart';
import '../feature/feature.dart';
import '../utils/parse/values.dart';

/// A factory to create geospatial geometries and features from source data.
abstract class GeoFactory {
  const GeoFactory();

  /// Parses a geometry from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  Geometry geometry(dynamic data);

  /// Parses a feature from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  Feature feature(dynamic data);

  /// Parses a series of features from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  FeatureSeries featureSeries(dynamic data);

  /// Parses a feature collection from a [data] object.
  ///
  /// Throws FormatException if parsing fails.
  FeatureCollection featureCollection(dynamic data);
}

/// A base implementation of [GeoFactory] with expectations (like CRS) set.
///
/// This class also introduces some helper methods to parse specific geometries.
abstract class GeoFactoryBase extends GeoFactory {
  const GeoFactoryBase({this.expectedCRS = CRS84, this.expectM = false});

  /// The expected coordinate reference system for coordinates to be parsed.
  final CRS expectedCRS;

  /// Whether to expect M coordinate for coordinates to be parsed.
  final bool expectM;

  /// Parses a point geometry from [coords] containing at least 2 valid values.
  ///
  /// Throws FormatException if cannot create point.
  Point point(Iterable coords) {
    if (coords is Iterable<double>) {
      if (expectedCRS.type == CRSType.geographic) {
        return GeoPoint.from(
          coords,
          expectM: expectM,
        );
      } else {
        return Point.from(
          coords,
          expectM: expectM,
        );
      }
    } else {
      if (expectedCRS.type == CRSType.geographic) {
        return GeoPoint.from(
          coords.map<double>((e) => valueToDouble(e)),
          expectM: expectM,
        );
      } else {
        return Point.from(
          coords.map<double>((e) => valueToDouble(e)),
          expectM: expectM,
        );
      }
    }
  }

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
  LineStringSeries lineStringSeries(Iterable lineStrings,
          {LineStringType type = LineStringType.any}) =>
      LineStringSeries.from(lineStrings
          .map<LineString>((points) => lineString(points, type: type)));

  /// Parses a polygon from a series of rings (closed and simple line strings).
  ///
  /// Throws FormatException if cannot create a polygon.
  Polygon polygon(Iterable rings) =>
      Polygon(lineStringSeries(rings, type: LineStringType.ring));

  /// Parses a series of polygons.
  ///
  /// Throws FormatException if cannot create a series of polygons.
  PolygonSeries polygonSeries(Iterable polygons) =>
      PolygonSeries.from(polygons.map<Polygon>((rings) => polygon(rings)));

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
  GeomSeries geometrySeries(Iterable geometries) =>
      GeomSeries.from(geometries.map<Geometry>((geom) => geometry(geom)));

  /// Parses a geometry collection from [geometries].
  ///
  /// Throws FormatException if cannot create a geometry collection.
  GeometryCollection geometryCollection(Iterable geometries) =>
      GeometryCollection(geometrySeries(geometries));
}
