// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import 'package:attributes/collection.dart';
import 'package:attributes/entity.dart';

import '../base.dart';

/// A feature is a geospatial entity with [id], [properties] and [geometry].
///
/// The [Feature] class extends [Entity] that can be used to represent
/// non-geospatial data object with id and properties.
///
/// Supports representing data from GeoJSON (https://geojson.org/) features.
abstract class Feature<T extends Geometry> extends Entity implements Bounded {
  const Feature();

  /// A new feature of optional [id], [properties], [geometry] and [bounds].
  ///
  /// If an optional [bounds] for a new feature is not provided then [geometry]
  /// bounds is used also as feature bounds when accessed.
  factory Feature.of(
          {Identifier? id,
          required PropertyMap properties,
          T? geometry,
          Bounds? bounds}) =>
      _FeatureBase<T>(
        id: id,
        geometry: geometry,
        properties: properties,
        bounds: bounds,
      );

  /// A new feature of optional [id], and [properties], [geometry] and [bounds].
  ///
  /// This factory allows [id] to be null or an instance of [Identifier],
  /// `String`, `BigInt` or `int`. In other cases an ArgumentError is thrown.
  ///
  /// The [properties] is used as a source view for a feature. Any changes on
  /// source reflect also on feature properties.
  ///
  /// If an optional [bounds] for a new feature is not provided then [geometry]
  /// bounds is used also as feature bounds when accessed.
  factory Feature.view(
          {Object? id,
          required Map<String, dynamic> properties,
          T? geometry,
          Bounds? bounds}) =>
      _FeatureBase<T>(
        id: Identifier.idOrNull(id),
        properties: PropertyMap.view(properties),
        geometry: geometry,
        bounds: bounds,
      );

  /// An optional [geometry] for this feature.
  Geometry? get geometry;
}

/// Private implementation of [Feature].
/// The implementation may change in future.
class _FeatureBase<T extends Geometry> extends EntityBase
    implements Feature<T> {
  const _FeatureBase(
      {Identifier? id,
      required PropertyMap properties,
      required this.geometry,
      Bounds? bounds})
      : _featureBounds = bounds,
        super(id: id, properties: properties);

  final Bounds? _featureBounds;

  @override
  final T? geometry;

  @override
  List<Object?> get props => [id, properties, geometry, _featureBounds];

  @override
  Bounds get bounds => _featureBounds ?? geometry?.bounds ?? Bounds.empty();
}

/// A feature collection with a series of features.
abstract class FeatureCollection<T extends Feature> extends Bounded {
  const FeatureCollection();

  /// Creates a feature collection from a series of [features].
  ///
  /// If an optional [bounds] for a new feature collection is not provided then
  /// bounds of the series of [features] is used also as collection bounds.
  factory FeatureCollection.of(
      {required BoundedSeries<T> features,
      Bounds? bounds}) = _FeatureCollectionBase<T>;

  /// All the [features] for this collection.
  BoundedSeries<T> get features;
}

/// Private implementation of [FeatureCollection].
/// The implementation may change in future.
@immutable
class _FeatureCollectionBase<T extends Feature> extends FeatureCollection<T>
    with EquatableMixin {
  const _FeatureCollectionBase({required this.features, Bounds? bounds})
      : _collectionBounds = bounds;

  final Bounds? _collectionBounds;

  @override
  final BoundedSeries<T> features;

  @override
  List<Object?> get props => [features];

  @override
  Bounds get bounds => _collectionBounds ?? features.bounds;
}
