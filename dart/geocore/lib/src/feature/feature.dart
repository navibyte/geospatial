// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import '../base/common.dart';
import '../base/geometry.dart';

/// A geospatial feature.
///
/// Supports representing data from GeoJSON (https://geojson.org/) features.
abstract class Feature {
  const Feature();

  /// Create a new feature with [id] and [geometry] and optional [properites].
  factory Feature.of(
      {required String id,
      required Geometry geometry,
      Map<String, Object> properties}) = FeatureBase;

  /// The [id] for this feature.
  String get id;

  /// The [geometry] for this feature.
  Geometry get geometry;

  /// Properties for this feature, allowed to be empty.
  Map<String, Object> get properties;
}

/// An immutable base implementation of [Feature].
@immutable
class FeatureBase extends Feature with EquatableMixin {
  /// Create a new feature with [id] and [geometry] and optional [properites].
  const FeatureBase(
      {required this.id, required this.geometry, this.properties = const {}});

  @override
  final String id;

  @override
  final Geometry geometry;

  @override
  final Map<String, Object> properties;

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
