// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A point with getters to access the wrapped [point].
///
/// This class is surely immutable, but the aggregated [point] object may
/// or may not to be immutable.
@immutable
class PointWrapper<T extends Point> extends Point with EquatableMixin {
  const PointWrapper(this.point);

  final T point;

  @override
  List<Object?> get props => [point];

  @override
  bool get isEmpty => point.isEmpty;

  @override
  Bounds get bounds => point.bounds;

  @override
  int get coordinateDimension => point.coordinateDimension;

  @override
  int get spatialDimension => point.spatialDimension;

  @override
  bool get is3D => point.is3D;

  @override
  bool get hasM => point.hasM;

  @override
  double operator [](int i) => point[i];

  @override
  double get x => point.x;

  @override
  double get y => point.y;

  @override
  double get z => point.z;

  @override
  double get m => point.m;

  @override
  Point newPoint(
          {double x = 0.0, double y = 0.0, double z = 0.0, double m = 0.0}) =>
      point.newPoint(x: x, y: y, z: z, m: m);
}
