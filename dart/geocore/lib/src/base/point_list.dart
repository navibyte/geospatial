// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'geometry.dart';
import 'point.dart';

/// A base interface for a point list with getters to access point items.
///
/// A point list could represents a geometry path, a line string, a polygon,
/// a multi point, a vertex array or any other collection for points.
abstract class PointList<T extends Point> extends Geometry {
  const PointList();

  @override
  int get dimension => 0;

  /// The count of points in this point list.
  int get length;

  /// Returns a point at the [index].
  T operator [](int index);

  /// Reads point coordinate values at [index] and stores them in [point].
  void read(int index, T point);

  /// Creates a new point object of [T] compatible with this list.
  T newPoint();

  /// X coordinate as double at [index].
  ///
  /// Must return a valid value for an [index] >= 0 and < [length].
  double x(int index);

  /// Y coordinate as double at [index].
  ///
  /// Must return a valid value for an [index] >= 0 and < [length].
  double y(int index);

  /// Z coordinate as double at [index].
  ///
  /// Returns NaN if Z is not available when an [index] >= 0 and < [length].
  double z(int index) => double.nan;

  /// M coordinate as double at [index].
  ///
  /// Returns NaN if M is not available when an [index] >= 0 and < [length].
  ///
  /// [m] represents a value on a linear referencing system (like time).
  /// Could be associated with a 2D point (x, y, m) or a 3D point (x, y, z, m).
  double m(int index) => double.nan;
}
