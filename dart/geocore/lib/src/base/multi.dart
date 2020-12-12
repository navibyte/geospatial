// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

import 'geometry.dart';
import 'linestring.dart';
import 'point.dart';
import 'point_series.dart';
import 'polygon.dart';

/// A geometry collection.
@immutable
class GeometryCollection<T extends Geometry> extends Geometry
    with EquatableMixin {
  /// Creates a geometry collection from [geometries].
  GeometryCollection(this.geometries);

  /// All the [geometries] for this multi point.
  final GeomSeries<T> geometries;

  @override
  int get dimension => geometries.dimension;

  @override
  bool get isEmpty => geometries.isEmpty;

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
  List<Object?> get props => [points];
}

/// A multi line string geometry.
@immutable
class MultiLineString<T extends Point> extends Geometry with EquatableMixin {
  /// Creates a multi line string from [lineStrings].
  MultiLineString(this.lineStrings);

  /// All the [lineStrings] for this multi line strings.
  final LineStringSeries<T> lineStrings;

  @override
  int get dimension => 1;

  @override
  bool get isEmpty => lineStrings.isEmpty;

  @override
  List<Object?> get props => [lineStrings];
}

/// A multi polygon geometry.
@immutable
class MultiPolygon<T extends Point> extends Geometry with EquatableMixin {
  /// Creates a multi polygon from [polygons].
  MultiPolygon(this.polygons);

  /// All the [polygons] for this multi polygon.
  final PolygonSeries<T> polygons;

  @override
  int get dimension => 2;

  @override
  bool get isEmpty => polygons.isEmpty;

  @override
  List<Object?> get props => [polygons];
}
