// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/coordinates/base.dart';
import '/src/utils/property_builder.dart';
import '/src/vector/content.dart';
import '/src/vector_data/model/geometry.dart';

import 'entity.dart';
import 'feature.dart';

/// A feature collection with a series of features.
///
/// Some implementations may contain also [custom] data or "foreign members"
/// containing property objects.
///
/// Supports representing data from GeoJSON (https://geojson.org/) features.
@immutable
class FeatureCollection<E extends Feature> extends Entity {
  final List<E> _features;
  final Map<String, Object?>? _custom;

  /// A feature collection with a series of [features].
  const FeatureCollection(List<E> features)
      : _features = features,
        _custom = null;

  const FeatureCollection._(this._features, this._custom);

  /// A feature collection from the content provided by [features].
  ///
  /// Feature objects on a collection have an optional primary geometry of [T].
  ///
  /// Only [Feature] objects of `Feature<T>` provided by [features] are built,
  /// any other objects are ignored.
  ///
  /// An optional expected [count], when given, specifies the number of feature
  /// objects in a content stream. Note that when given the count MUST be exact.
  ///
  /// Use an optional [custom] parameter to set any custom or "foreign member"
  /// properties.
  ///
  /// An example to create a feature collection with feature containing point
  /// geometries, the returned type is `FeatureCollection<Feature<Point>>`:
  ///
  /// ```dart
  ///   FeatureCollection.build<Point>(
  ///       count: 2,
  ///       (features) => features
  ///           ..feature(
  ///               id: '1',
  ///               geometry: (geom) => geom.point([10.123, 20.25]),
  ///               properties: {
  ///                  'foo': 100,
  ///                  'bar': 'this is property value',
  ///                  'baz': true,
  ///               },
  ///           )
  ///           ..feature(
  ///               id: '2',
  ///               // ...
  ///           ),
  ///   );
  /// ```
  static FeatureCollection<Feature<T>> build<T extends Geometry>(
    WriteFeatures features, {
    int? count,
    WriteProperties? custom,
  }) {
    // todo: use optional count to create a list in right size at build start

    // build any feature objects on a list
    final builder = _FeatureBuilder<T>();
    features.call(builder);

    // build any custom properties on a map
    final builtCustom =
        custom != null ? PropertyBuilder.buildMap(custom) : null;

    // create a feature collection with feature list and optional custom props
    return FeatureCollection<Feature<T>>._(builder.list, builtCustom);
  }

  /// All feature items in this feature collection.
  List<E> get features => _features;

  /// Optional custom or "foreign member" properties as a map.
  ///
  /// The primary feature items are accessed via [features]. However any custom
  /// property data outside it is stored in this member.
  Map<String, Object?>? get custom => _custom;

  @override
  void writeTo(FeatureContent writer) {
    final cust = custom;
    writer.featureCollection(
      (feat) {
        for (final item in features) {
          item.writeTo(feat);
        }
      },
      count: features.length,
      custom: cust != null
          ? (props) {
              cust.forEach((name, value) {
                props.property(name, value);
              });
            }
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FeatureCollection &&
      features == other.features &&
      custom == other.custom;

  @override
  int get hashCode => Object.hash(features, custom);
}

class _FeatureBuilder<T extends Geometry> implements FeatureContent {
  final List<Feature<T>> list;

  _FeatureBuilder() : list = [];

  @override
  void feature({
    Object? id,
    WriteGeometries? geometry,
    Map<String, Object?>? properties,
    Box? bbox,
    WriteProperties? custom,
  }) {
    list.add(
      Feature<T>.build(
        id: id,
        geometry: geometry,
        properties: properties,
        custom: custom,
      ),
    );
  }

  @override
  void featureCollection(
    WriteFeatures features, {
    int? count,
    Box? bbox,
    WriteProperties? custom,
  }) {
    // nop (feature collection are not features)
  }
}
