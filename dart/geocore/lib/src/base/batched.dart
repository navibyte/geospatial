// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A private base interface for "batched series" defining spatial operations.
///
/// Known sub classes: [BoundedSeries], [PointSeries].
abstract class _BatchedSeries<S extends _BatchedSeries<S, E>, E>
    extends _BoundedBase implements Iterable<E> {
  const _BatchedSeries();

  /// Returns an item of the type E at [index].
  ///
  /// Throws RangeError if [index] is out of bounds.
  E operator [](int index);

  /// Returns a new series where items intersects with [bounds].
  ///
  /// The intersected series is populated by default. If [lazy] is set true then
  /// returns a new lazy series with items intersected lazily.
  ///
  /// Even if an item on this series has a complex geometry, only bounds
  /// of that geometry is tested (intersection) with the given [bounds].
  ///
  /// Those items that has empty bounds are not matched.
  S intersectByBounds(Bounds bounds, {bool lazy = false});

  /// Returns a new series where items intersects with [bounds] in 2D.
  ///
  /// The intersected series is populated by default. If [lazy] is set true then
  /// returns a new lazy series with items intersected lazily.
  ///
  /// Even if an item on this series has a complex geometry, only bounds
  /// of that geometry is tested (intersection) with the given [bounds].
  ///
  /// Those items that has empty bounds are not matched.
  S intersectByBounds2D(Bounds bounds, {bool lazy = false});

  /// Returns a new series with all points transformed using [transformation].
  ///
  /// The transformed series is populated by default. If [lazy] is set true then
  /// returns a new lazy series with points of the series transformed lazily.
  S transform(TransformPoint transformation, {bool lazy = false});
}

/// Private implementation of [_BatchedSeries] based on UnmodifiableListView.
/// The implementation may change in future.
///
/// Known sub classes: [_BoundedSeriesView], [_PointSeriesView].
abstract class _BatchedSeriesView<S extends _BatchedSeries<S, E>, E>
    extends UnmodifiableListView<E> implements _BatchedSeries<S, E> {
  _BatchedSeriesView(Iterable<E> source, {required this.bounds})
      : super(source);

  @override
  @nonVirtual
  final Bounds bounds;
}
