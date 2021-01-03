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
  /// Creates a geometry collection from [geometries].
  GeometryCollection(this.geometries);

  /// All the [geometries] for this multi point.
  final BoundedSeries<T> geometries;

  @override
  int get dimension {
    // A base implementation for calculating a maximum dimension for a series by
    // looping through all items. Should be overridden to provide more efficient
    // implementation as needed.
    var dim = 0;
    geometries.forEach((element) => dim = math.max(dim, element.dimension));
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
  /// Creates a multi point from [points].
  MultiPoint(this.points);

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
  /// Creates a multi line string from [lineStrings].
  MultiLineString(this.lineStrings);

  /// All the [lineStrings] for this multi line strings.
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
  /// Creates a multi polygon from [polygons].
  MultiPolygon(this.polygons);

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
