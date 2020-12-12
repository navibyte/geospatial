// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import '../base/common.dart';
import '../base/geometry.dart';

import 'id.dart';

/// A geospatial feature.
///
/// Supports representing data from GeoJSON (https://geojson.org/) features.
abstract class Feature {
  const Feature();

  /// Create a new feature with [id] and [geometry] and optional [properites].
  factory Feature.of(
      {required dynamic id,
      required Geometry geometry,
      Map<String, dynamic> properties = const {}}) {
    return FeatureBase(
      id: id is FeatureId ? id : FeatureId.of(id),
      geometry: geometry,
      properties: properties,
    );
  }

  /// The [id] for this feature.
  FeatureId get id;

  /// The [geometry] for this feature.
  Geometry get geometry;

  /// Properties for this feature, allowed to be empty.
  Map<String, dynamic> get properties;
}

/// An immutable base implementation of [Feature].
@immutable
class FeatureBase extends Feature with EquatableMixin {
  /// Create a new feature with [id] and [geometry] and optional [properites].
  const FeatureBase(
      {required this.id, required this.geometry, this.properties = const {}});

  @override
  final FeatureId id;

  @override
  final Geometry geometry;

  @override
  final Map<String, dynamic> properties;

  @override
  List<Object?> get props => [id, geometry, properties];
}

/// A base interface for a series (list) of feature items of type [T].
///
/// For example this class may represent data for "FeatureCollection".
abstract class FeatureSeries<T extends Feature> implements Series<T> {
  const FeatureSeries();

  /// Create an unmodifiable [FeatureSeries] backed by [source].
  factory FeatureSeries.view(Iterable<T> source) = FeatureSeriesView<T>;

  /// Create an immutable [FeatureSeries] copied from [elements].
  factory FeatureSeries.from(Iterable<T> elements) =>
      FeatureSeries<T>.view(List<T>.unmodifiable(elements));
}

/// An unmodifiable [FeatureSeries] backed by another list.
@immutable
class FeatureSeriesView<T extends Feature> extends SeriesView<T>
    implements FeatureSeries<T> {
  /// Create an unmodifiable [FeatureSeriesView] backed by [source].
  FeatureSeriesView(Iterable<T> source) : super(source);
}

/// A feature collection with a series of features.
abstract class FeatureCollection<T extends Feature> {
  const FeatureCollection();

  /// Creates a feature collection from a series of [features].
  factory FeatureCollection.of(FeatureSeries<T> features) =
      FeatureCollectionBase<T>;

  /// All the [features] for this collection.
  FeatureSeries<T> get features;
}

/// A base implementation for a [FeatureCollection].
@immutable
class FeatureCollectionBase<T extends Feature> extends FeatureCollection<T>
    with EquatableMixin {
  /// Creates a feature collection from a series of [features].
  const FeatureCollectionBase(this.features);

  @override
  final FeatureSeries<T> features;

  @override
  List<Object?> get props => [features];
}
