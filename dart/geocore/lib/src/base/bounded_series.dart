// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A base interface for a series (list) of bounded items of type [E].
abstract class BoundedSeries<E extends Bounded>
    extends _BatchedSeries<BoundedSeries<E>, E> {
  /// Default `const` constructor to allow extending this abstract class.
  const BoundedSeries();

  /// Create an [BoundedSeries] instance backed by [source].
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory BoundedSeries.view(Iterable<E> source, {Bounds? bounds}) =
      _BoundedSeriesView<E>;

  /// Create an immutable [BoundedSeries] with items copied from [source].
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory BoundedSeries.from(Iterable<E> source, {Bounds? bounds}) =>
      BoundedSeries<E>.view(List<E>.unmodifiable(source), bounds: bounds);

  /// Returns a new series with all items converted using [conversion] function.
  ///
  /// The converted series is populated by default. If [lazy] is set true then
  /// returns a new lazy series with itmes of the series converted lazily.
  BoundedSeries<T> convert<T extends Bounded>(
    T Function(E source) conversion, {
    bool lazy = false,
  });
}

/// A partial implementation of [BoundedSeries] as a mixin.
mixin BoundedSeriesMixin<E extends Bounded> implements BoundedSeries<E> {
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
  static Bounds initBounds<E extends Bounded>(
    Iterable<E> source, {
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
class _BoundedSeriesView<E extends Bounded>
    extends _BatchedSeriesView<BoundedSeries<E>, E> with BoundedSeriesMixin<E> {
  _BoundedSeriesView(Iterable<E> source, {Bounds? bounds})
      : super(
          source,
          bounds: BoundedSeriesMixin.initBounds(source, bounds: bounds),
        );

  @override
  BoundedSeries<E> intersectByBounds(Bounds bounds, {bool lazy = false}) {
    final intersected = where((element) => bounds.intersects(element.bounds));
    return _BoundedSeriesView(
      lazy ? intersected : intersected.toList(growable: false),
    );
  }

  @override
  BoundedSeries<E> intersectByBounds2D(Bounds bounds, {bool lazy = false}) {
    final intersected = where((element) => bounds.intersects2D(element.bounds));
    return _BoundedSeriesView(
      lazy ? intersected : intersected.toList(growable: false),
    );
  }

  @override
  BoundedSeries<E> transform(TransformPoint transform, {bool lazy = false}) {
    final transformed = map<E>((bounded) => bounded.transform(transform) as E);
    return _BoundedSeriesView(
      lazy ? transformed : transformed.toList(growable: false),
    );
  }

  @override
  BoundedSeries<T> convert<T extends Bounded>(
    T Function(E source) conversion, {
    bool lazy = false,
  }) {
    final converted = map(conversion);
    return _BoundedSeriesView(
      lazy ? converted : converted.toList(growable: false),
    );
  }
}
