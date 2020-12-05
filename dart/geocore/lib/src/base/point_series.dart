// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'geometry.dart';
import 'point.dart';

/// A base interface for a point serie with getters to access point items.
///
/// A point serie could represents a geometry path, a line string, a polygon,
/// a multi point, a vertex array or any other collection for points.
abstract class PointSeries<T extends Point> extends GeomSeries<T> {
  const PointSeries();

  /// Create an unmodifiable [PointSeries] backed by [source].
  factory PointSeries.view(Iterable<T> source) = PointSeriesView<T>;

  /// Create an immutable [PointSeries] copied from [elements].
  factory PointSeries.from(Iterable<T> elements) =>
      PointSeries<T>.view(List<T>.unmodifiable(elements));

  /// X coordinate as double at [index].
  ///
  /// Throws RangeError if [index] is out of bounds.
  double x(int index);

  /// Y coordinate as double at [index].
  ///
  /// Throws RangeError if [index] is out of bounds.
  double y(int index);

  /// Z coordinate as double at [index].
  ///
  /// Returns 0.0 if Z is not available when an [index] >= 0 and < [length].
  ///
  /// Throws RangeError if [index] is out of bounds.
  double z(int index) => 0.0;

  /// M coordinate as double at [index].
  ///
  /// Returns 0.0 if M is not available when an [index] >= 0 and < [length].
  ///
  /// [m] represents a value on a linear referencing system (like time).
  /// Could be associated with a 2D point (x, y, m) or a 3D point (x, y, z, m).
  ///
  /// Throws RangeError if [index] is out of bounds.
  double m(int index) => 0.0;

  /// True if the first and last point equals in 2D.
  bool get isClosed;
}

/// A partial implementation of [PointSeries] as a mixin.
mixin PointSeriesMixin<T extends Point> implements PointSeries<T> {
  @override
  int get dimension => 0;

  @override
  bool get isClosed => length >= 2 && this[0].equals2D(this[length - 1]);
}

/// An unmodifiable [PointSeries] backed by another list.
@immutable
class PointSeriesView<T extends Point> extends GeomSeriesView<T>
    with PointSeriesMixin<T>
    implements PointSeries<T> {
  /// Create an unmodifiable [PointSeries] backed by [source].
  PointSeriesView(Iterable<T> source) : super(source);

  @override
  double x(int index) => this[index].x;

  @override
  double y(int index) => this[index].y;

  @override
  double z(int index) => this[index].z;

  @override
  double m(int index) => this[index].m;
}
