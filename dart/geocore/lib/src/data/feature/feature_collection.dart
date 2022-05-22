// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector.dart';
import 'package:meta/meta.dart';

import '/src/base/spatial.dart';

import 'feature.dart';
import 'feature_writable.dart';

/// A feature collection with a series of [features].
///
/// Implements also [Bounded].
///
/// Supports representing data from GeoJSON (https://geojson.org/) feature
/// collections.
@immutable
class FeatureCollection<E extends Feature> extends FeatureWritable
    implements Bounded {
  final BoundedSeries<E> _features;
  final Bounds? _collectionBounds;

  /// Creates a feature collection from a series of [features].
  ///
  /// The [features] must be an iterable or [BoundedSeries] containing feature
  /// objects.
  ///
  /// If an optional [bounds] for a new feature collection is not provided then
  /// bounds of the series of [features] is used also as collection bounds.
  factory FeatureCollection({
    required Iterable<E> features,
    Bounds? bounds,
  }) =>
      FeatureCollection.of(
        features: features is BoundedSeries<E>
            ? features
            : BoundedSeries.view(features),
        bounds: bounds,
      );

  /// Creates a feature collection from a series of [features].
  ///
  /// The [features] must [BoundedSeries] containing feature objects.
  ///
  /// If an optional [bounds] for a new feature collection is not provided then
  /// bounds of the series of [features] is used also as collection bounds.
  const FeatureCollection.of({
    required BoundedSeries<E> features,
    Bounds? bounds,
  })  : _features = features,
        _collectionBounds = bounds;

  /// All the [features] for this collection.
  BoundedSeries<E> get features => _features;

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

  /// Returns a new collection with features transformed using [transform].
  @override
  FeatureCollection<E> transform(TransformPosition transform) =>
      FeatureCollection(
        features: features.transform(
          transform,
          lazy: false,
        ),
      );

  /// Returns a new collection with features projected using [projection].
  ///
  /// When [to] is provided, then target points of [R] are created using
  /// that as a point factory. Otherwise [projection] uses it's own factory.
  @override
  FeatureCollection project<R extends Point>(
    Projection<R> projection, {
    CreatePosition<R>? to,
  }) =>
      // Note: returns FeatureCollection, not FeatureCollection<E> as projected
      // feature elements could be other than E as a result of some projections.
      FeatureCollection(
        features: features.convert<Feature>(
          (feature) => feature.project(projection, to: to),
          lazy: false,
        ),
      );

  @override
  String toString() => toStringAs();

  @override
  bool operator ==(Object other) =>
      other is FeatureCollection &&
      boundsExplicit == other.boundsExplicit &&
      features == other.features;

  @override
  int get hashCode => Object.hash(boundsExplicit, features);
}
