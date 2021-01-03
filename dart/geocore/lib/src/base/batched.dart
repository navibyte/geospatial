// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A private base interface for "batched series" defining spatial operations.
///
/// Known sub classes: [BoundedSeries], [PointSeries].
abstract class _BatchedSeries<S extends _BatchedSeries<S, T>, T> extends Bounded
    implements Iterable<T> {
  const _BatchedSeries();

  /// Returns an item of the type T at [index].
  ///
  /// Throws RangeError if [index] is out of bounds.
  T operator [](int index);

  /// Returns a new lazy series where items intersects with [bounds].
  ///
  /// Even if a item on this series has a complex geometry, only bounds
  /// of that geometry is tested (intersection) with the given [bounds].
  ///
  /// Those items that has empty bounds are not matched.
  S intersectByBounds(Bounds bounds);

  /// Returns a new lazy series where items intersects with [bounds] in 2D.
  ///
  /// Even if a item on this series has a complex geometry, only bounds
  /// of that geometry is tested (intersection) with the given [bounds].
  ///
  /// Those items that has empty bounds are not matched.
  S intersectByBounds2D(Bounds bounds);
}

/// Private implementation of [_BatchedSeries] based on UnmodifiableListView.
/// The implementation may change in future.
///
/// Known sub classes: [_BoundedSeriesView], [_PointSeriesView].
abstract class _BatchedSeriesView<S extends _BatchedSeries<S, T>, T>
    extends UnmodifiableListView<T> implements _BatchedSeries<S, T> {
  _BatchedSeriesView(Iterable<T> source, {required this.bounds})
      : super(source);

  @override
  @nonVirtual
  final Bounds bounds;
}
