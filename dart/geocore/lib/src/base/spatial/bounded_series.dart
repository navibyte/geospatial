// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'spatial.dart';

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

/// Private implementation of [BoundedSeries].
/// The implementation may change in future.
class _BoundedSeriesView<E extends Bounded>
    extends _BatchedSeriesView<BoundedSeries<E>, E>
    implements BoundedSeries<E> {
  _BoundedSeriesView(Iterable<E> source, {Bounds? bounds})
      : super(source, boundsExplicit: bounds);

  @override
  Bounds? _calculateBounds() {
    final builder = BoundsBuilder();
    for (final element in this) {
      final b = element.bounds;
      if (b != null) {
        builder.addBounds(b);
      }
    }
    return builder.bounds;
  }

  @override
  BoundedSeries<E> intersectByBounds(Bounds bounds, {bool lazy = false}) {
    // first check if current bounds (without triggering calculation) do
    // not intersect at all => in such case, return empty series
    final currBounds = _boundsCurrent;
    if (currBounds != null && !bounds.intersects(currBounds)) {
      return _BoundedSeriesView([]);
    }
    // do actual intersection
    final intersected = where((element) {
      final b = element.bounds;
      if (b != null) {
        //print('${bounds.intersects(b)} - $bounds / $b');
        return bounds.intersects(b);
      } else {
        //print('no bounds for $element');
        return false;
      }
    });
    return _BoundedSeriesView(
      lazy ? intersected : intersected.toList(growable: false),
    );
  }

  @override
  BoundedSeries<E> intersectByBounds2D(Bounds bounds, {bool lazy = false}) {
    // first check if current bounds (without triggering calculation) do
    // not intersect at all => in such case, return empty series
    final currBounds = _boundsCurrent;
    if (currBounds != null && !bounds.intersects2D(currBounds)) {
      return _BoundedSeriesView([]);
    }
    // do actual intersection
    final intersected = where((element) {
      final b = element.bounds;
      if (b != null) {
        return bounds.intersects2D(b);
      } else {
        return false;
      }
    });
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
