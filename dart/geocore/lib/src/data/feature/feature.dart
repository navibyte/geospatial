// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector.dart';
import 'package:meta/meta.dart';

import '/src/base/spatial.dart';

import 'feature_writable.dart';

/// A feature is a geospatial entity with [id], [properties] and [geometry].
///
/// Implements also [Bounded].
///
/// Supports representing data from GeoJSON (https://geojson.org/) features.
@immutable
class Feature<T extends Geometry> extends FeatureWritable implements Bounded {
  final Object? _id;
  final Map<String, Object?>? _properties;
  final Geometry? _geometry;
  final Bounds? _featureBounds;

  /// A new feature of optional [id], [properties], [geometry] and [bounds].
  ///
  /// The [id] should be null, int, BigInt or String. Other types not allowed.
  ///
  /// The [properties] is used as a reference. Any changes on source reflect
  /// also on feature properties.
  ///
  /// If an optional [bounds] for a new feature is not provided then [geometry]
  /// bounds is used also as feature bounds when accessed.
  const Feature({
    Object? id,
    Map<String, Object?>? properties,
    T? geometry,
    Bounds? bounds,
  })  : assert(
          id == null || id is String || id is int || id is BigInt,
          'Id should be null, int, BigInt or String',
        ),
        _id = id,
        _properties = properties,
        _geometry = geometry,
        _featureBounds = bounds;

  /// An optional identifier (null, int, BigInt or String) for this feature.
  Object? get id => _id;

  /// Required properties for this feature (allowed to be empty).
  Map<String, Object?> get properties => _properties ?? const {};

  /// An optional geometry for this feature.
  Geometry? get geometry => _geometry;

  /// Returns a new feature with geometry transformed using [transform].
  ///
  /// Transforms only [geometry] of this feature. Other members, [id] and
  /// [properties], are set without modifications to a new feature object.
  @override
  Feature<T> transform(TransformPosition transform) => Feature(
        id: _id,
        properties: _properties,
        geometry: _geometry?.transform(transform) as T?,
      );

  /// Returns a new feature with geometry projected using [projection].
  ///
  /// Target points of [R] are created using [to] as a point factory.
  ///
  /// Transforms only [geometry] of this feature. Other members, [id] and
  /// [properties], are set without modifications to a new feature object.
  @override
  Feature project<R extends Point>(
    Projection projection, {
    required CreatePosition<R> to,
  }) =>
      Feature(
        id: _id,
        properties: _properties,
        geometry: _geometry?.project<R>(projection, to: to),
      );

  @override
  Bounds? get bounds => _featureBounds ?? _geometry?.bounds;

  @override
  Bounds? get boundsExplicit => _featureBounds;

  @override
  void writeTo(FeatureContent writer) {
    final geom = _geometry;
    writer.feature(
      id: _id,
      geometry: geom?.writeTo,
      properties: _properties,
      bounds:
          boundsExplicit != null ? Box.getDoubleList(boundsExplicit!) : null,
    );
  }

  @override
  String toString() => toStringAs();

  @override
  bool operator ==(Object other) =>
      other is Feature &&
      id == other.id &&
      properties == other.properties &&
      boundsExplicit == other.boundsExplicit &&
      geometry == other.geometry;

  @override
  int get hashCode => Object.hash(id, properties, boundsExplicit, geometry);
}
