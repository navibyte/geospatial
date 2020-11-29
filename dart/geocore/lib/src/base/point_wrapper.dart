// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import 'point.dart';

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
  int get coordinateDimension => point.coordinateDimension;

  @override
  int get spatialDimension => point.spatialDimension;

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
}
