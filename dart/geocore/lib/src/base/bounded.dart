// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A base interface for classes that know their [bounds].
abstract class Bounded {
  /// Default `const` constructor to allow extending this abstract class.
  const Bounded();

  /// The [bounds] geometry for this object.
  ///
  /// Please note that in some cases bounds could be pre-calculated but it's
  /// possible that accessing this property may cause extensive calculations.
  ///
  /// Bounds returned can be "empty" when isEmpty returns true - if so such
  /// bounds does not intersect with any other bounds.
  Bounds get bounds;
}

/// A base interface for a series (list) of bounded items of type [T].
abstract class BoundedSeries<T extends Bounded>
    extends _BatchedSeries<BoundedSeries<T>, T> {
  /// Default `const` constructor to allow extending this abstract class.
  const BoundedSeries();

  /// Create an [BoundedSeries] instance backed by [source].
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory BoundedSeries.view(Iterable<T> source, {Bounds? bounds}) =
      _BoundedSeriesView<T>;

  /// Create an immutable [BoundedSeries] with items copied from [source].
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory BoundedSeries.from(Iterable<T> source, {Bounds? bounds}) =>
      BoundedSeries<T>.view(List<T>.unmodifiable(source), bounds: bounds);
}

/// A partial implementation of [BoundedSeries] as a mixin.
mixin BoundedSeriesMixin<T extends Bounded> implements BoundedSeries<T> {
  /// Initializes a [Bounds] object for [source] of bounded objects.
  ///
  /// If [bounds] is non-null, then it's returned as is.
  ///
  /// In other cases the current implementation returns a [_LazyBounds]
  /// instance with bounds lazy calculated when first needed. However this
  /// implementation can internally be optimized in future (ie. bounds for
  /// small series of bounded objects is initialized right a way, and for large
  /// series with lazy calculations).
  @protected
  static Bounds initBounds<T extends Bounded>(
    Iterable<T> source, {
    Bounds? bounds,
  }) =>
      bounds ??
      _LazyBounds.calculate(() {
        final builder = BoundsBuilder();
        for (final element in source) {
          builder.addBounds(element.bounds);
        }
        return builder.bounds;
      });
}

/// Private implementation of [BoundedSeries].
/// The implementation may change in future.
class _BoundedSeriesView<T extends Bounded>
    extends _BatchedSeriesView<BoundedSeries<T>, T> with BoundedSeriesMixin<T> {
  _BoundedSeriesView(Iterable<T> source, {Bounds? bounds})
      : super(
          source,
          bounds: BoundedSeriesMixin.initBounds(source, bounds: bounds),
        );

  @override
  BoundedSeries<T> intersectByBounds(Bounds bounds) =>
      _BoundedSeriesView(where((element) => bounds.intersects(element.bounds)));

  @override
  BoundedSeries<T> intersectByBounds2D(Bounds bounds) => _BoundedSeriesView(
        where((element) => bounds.intersects2D(element.bounds)),
      );
}
