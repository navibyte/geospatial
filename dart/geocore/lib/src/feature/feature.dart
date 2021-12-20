// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

import '../base.dart';

/// A feature is a geospatial entity with [id], [properties] and [geometry].
///
/// Supports representing data from GeoJSON (https://geojson.org/) features.
abstract class Feature<T extends Geometry> implements Bounded {
  /// Default `const` constructor to allow extending this abstract class.
  const Feature();

  /// A new feature of optional [id], [properties], [geometry] and [bounds].
  ///
  /// The [properties] is copied as `Map.of(properties)` to a feature.
  ///
  /// If an optional [bounds] for a new feature is not provided then [geometry]
  /// bounds is used also as feature bounds when accessed.
  factory Feature.of({
    String? id,
    required Map<String, Object?> properties,
    T? geometry,
    Bounds? bounds,
  }) =>
      _FeatureBase<T>(
        id: id,
        geometry: geometry,
        properties: Map.of(properties),
        bounds: bounds,
      );

  /// A new feature of optional [id], and [properties], [geometry] and [bounds].
  ///
  /// The [properties] is used as a reference by a feature. Any changes on
  /// source reflect also on feature properties.
  ///
  /// If an optional [bounds] for a new feature is not provided then [geometry]
  /// bounds is used also as feature bounds when accessed.
  factory Feature.view({
    String? id,
    required Map<String, Object?> properties,
    T? geometry,
    Bounds? bounds,
  }) =>
      _FeatureBase<T>(
        id: id,
        properties: properties,
        geometry: geometry,
        bounds: bounds,
      );

  /// An optional identifier for this feature.
  ///
  /// Note that an identifier could be textual or a number but reprensented here
  /// as a nullable String object.
  String? get id;

  /// Required properties for this feature allowed to be empty.
  Map<String, Object?> get properties;

  /// An optional geometry for this feature.
  Geometry? get geometry;

  /// Returns a new feature with geometry transformed using [transformation].
  ///
  /// Transforms only [geometry] of this feature. Other members, [id] and
  /// [properties], are set without modifications to a new feature object.
  @override
  Feature<T> transform(TransformPoint transformation);

  /// Returns a new feature with geometry projected using [projection].
  ///
  /// When [to] is provided, then target points of [R] are created using
  /// that as a point factory. Otherwise [projection] uses it's own factory.
  ///
  /// Transforms only [geometry] of this feature. Other members, [id] and
  /// [properties], are set without modifications to a new feature object.
  @override
  Feature project<R extends Point>(
    ProjectPoint<R> projection, {
    PointFactory<R>? to,
  });
}

/// Private implementation of [Feature].
/// The implementation may change in future.
class _FeatureBase<T extends Geometry>
    with EquatableMixin
    implements Feature<T> {
  const _FeatureBase({
    this.id,
    required this.properties,
    required this.geometry,
    Bounds? bounds,
  }) : _featureBounds = bounds;

  final Bounds? _featureBounds;

  @override
  final String? id;

  @override
  final Map<String, Object?> properties;

  @override
  final T? geometry;

  @override
  List<Object?> get props => [id, properties, geometry, _featureBounds];

  @override
  Bounds get bounds => _featureBounds ?? geometry?.bounds ?? Bounds.empty();

  @override
  Feature<T> transform(TransformPoint transformation) => _FeatureBase(
        id: id,
        properties: properties,
        geometry: geometry?.transform(transformation) as T?,
      );

  @override
  Feature project<R extends Point>(
    ProjectPoint<R> projection, {
    PointFactory<R>? to,
  }) =>
      _FeatureBase(
        id: id,
        properties: properties,
        geometry: geometry?.project<R>(projection, to: to),
      );
}

/// A feature collection with a series of features.
abstract class FeatureCollection<E extends Feature> extends Bounded {
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

  /// Returns a new collection with features transformed using [transformation].
  @override
  FeatureCollection<E> transform(TransformPoint transformation);

  /// Returns a new collection with features projected using [projection].
  ///
  /// When [to] is provided, then target points of [R] are created using
  /// that as a point factory. Otherwise [projection] uses it's own factory.
  @override
  FeatureCollection project<R extends Point>(
    ProjectPoint<R> projection, {
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
  Bounds get bounds => _collectionBounds ?? features.bounds;

  @override
  FeatureCollection<E> transform(TransformPoint transformation) =>
      _FeatureCollectionBase(
        features: features.transform(
          transformation,
          lazy: false,
        ),
      );

  @override
  FeatureCollection project<R extends Point>(
    ProjectPoint<R> projection, {
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
}
