// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:geobase/geobase.dart';
import 'package:meta/meta.dart';

import '/src/base/spatial.dart';

import 'feature.dart';
import 'feature_writable.dart';

/// A feature collection with a series of features.
abstract class FeatureCollection<E extends Feature> extends FeatureWritable
    implements Bounded {
  /// Default `const` constructor to allow extending this abstract class.
  const FeatureCollection();

  /// Creates a feature collection from a series of [features].
  ///
  /// If an optional [bounds] for a new feature collection is not provided then
  /// bounds of the series of [features] is used also as collection bounds.
  factory FeatureCollection.of({
    required Iterable<E> features,
    Bounds? bounds,
  }) = _FeatureCollectionBase<E>;

  /// All the [features] for this collection.
  BoundedSeries<E> get features;

  /// Returns a new collection with features transformed using [transform].
  @override
  FeatureCollection<E> transform(TransformPoint transform);

  /// Returns a new collection with features projected using [projection].
  ///
  /// When [to] is provided, then target points of [R] are created using
  /// that as a point factory. Otherwise [projection] uses it's own factory.
  @override
  FeatureCollection project<R extends Point>(
    Projection<R> projection, {
    PointFactory<R>? to,
  });
}

/// Private implementation of [FeatureCollection].
/// The implementation may change in future.
@immutable
class _FeatureCollectionBase<E extends Feature> extends FeatureCollection<E>
    with EquatableMixin {
  _FeatureCollectionBase({required Iterable<E> features, Bounds? bounds})
      : features = features is BoundedSeries<E>
            ? features
            : BoundedSeries.view(features),
        _collectionBounds = bounds;

  final Bounds? _collectionBounds;

  @override
  final BoundedSeries<E> features;

  @override
  List<Object?> get props => [features];

  @override
  Bounds? get bounds => _collectionBounds ?? features.bounds;

  @override
  Bounds? get boundsExplicit => _collectionBounds ?? features.boundsExplicit;

  @override
  void writeTo(FeatureWriter writer) {
    writer.featureCollection(
      features: (fw) {
        for (final item in features) {
          item.writeTo(writer);
        }
      },
      count: features.length,
      bbox: boundsExplicit,
    );
  }

  @override
  FeatureCollection<E> transform(TransformPoint transform) =>
      _FeatureCollectionBase(
        features: features.transform(
          transform,
          lazy: false,
        ),
      );

  @override
  FeatureCollection project<R extends Point>(
    Projection<R> projection, {
    PointFactory<R>? to,
  }) =>
      // Note: returns FeatureCollection, not FeatureCollection<E> as projected
      // feature elements could be other than E as a result of some projections.
      _FeatureCollectionBase(
        features: features.convert<Feature>(
          (feature) => feature.project(projection, to: to),
          lazy: false,
        ),
      );

  @override
  String toString() => toStringAs();
}
