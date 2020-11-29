// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'geometry.dart';
import 'point.dart';

/// A base interface for bounding geometry classes (aka a bounding box in 2D).
abstract class Bounds<T extends Point> extends Geometry {
  const Bounds();

  @override
  int get dimension => 2;

  /// Minimum point of bounds. Must return a non-null value.
  T get min;

  /// Maximum point of bounds. Must return a non-null value.
  T get max;
}

/// A base interface for geometry classes that know their bounds.
abstract class BoundedGeometry<T extends Point> extends Geometry {
  const BoundedGeometry();

  /// The [bounds] for this geometry.
  Bounds<T> get bounds;
}
