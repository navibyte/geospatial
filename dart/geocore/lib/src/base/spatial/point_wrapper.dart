// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'spatial.dart';

/// A point with getters to access the wrapped [point].
///
/// This class is surely immutable, but the aggregated [point] object may
/// or may not to be immutable.
@immutable
class PointWrapper<T extends Point<C>, C extends num> extends Point<C> {
  /// Create a point wrapping another [point].
  const PointWrapper(this.point);

  /// The wrapped [point].
  final T point;

  @override
  Bounds? get bounds => point.bounds;

  @override
  Bounds? get boundsExplicit => point.boundsExplicit;

  @override
  int get coordinateDimension => point.coordinateDimension;

  @override
  int get spatialDimension => point.spatialDimension;

  @override
  bool get isGeographic => point.isGeographic;

  @override
  bool get is3D => point.is3D;

  @override
  bool get isMeasured => point.isMeasured;

  @override
  Coords get typeCoords => point.typeCoords;

  @override
  C operator [](int i) => point[i];

  @override
  C get x => point.x;

  @override
  C get y => point.y;

  @override
  C get z => point.z;

  @override
  C get m => point.m;

  @override
  C? get optZ => point.optZ;

  @override
  C? get optM => point.optM;

  @override
  T copyWith({num? x, num? y, num? z, num? m}) =>
      point.copyWith(x: x, y: y, z: z, m: m) as T;

  @override
  T newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      point.newWith(x: x, y: y, z: z, m: m) as T;

  @override
  T newFrom(Iterable<num> coords, {int? offset, int? length}) =>
      point.newFrom(coords, offset: offset, length: length) as T;

  @override
  T transform(TransformPoint transform) => point.transform(transform) as T;

  @override
  R project<R extends Point>(
    Projection<R> projection, {
    PointFactory<R>? to,
  }) =>
      point.project(projection, to: to);


  @override
  String toString() => point.toString();
}
