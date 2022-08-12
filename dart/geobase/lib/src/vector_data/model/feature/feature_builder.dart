// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/vector/content.dart';

import 'feature.dart';
import 'feature_collection.dart';
import 'feature_object.dart';

/// A builder to create geospatial feature objects of [T] from [FeatureContent].
///
/// This builder supports creating [Feature] and [FeatureCollection] objects.
///
/// See [FeatureContent] for more information about these objects.
class FeatureBuilder<T extends FeatureObject> with FeatureContent {
  final void Function(T object) _addObject;

  FeatureBuilder._(this._addObject);

  void _add(FeatureObject object) {
    if (object is T) {
      _addObject.call(object);
    }
  }

  /// Builds geospatial feature objects from the content provided by [features].
  ///
  /// Built feature object are sent into [to] callback function.
  ///
  /// Only feature objects of [T] are built, any other objects are ignored. [T]
  /// should be [FeatureObject] (building both features and feature
  /// collections), [Feature] or [FeatureCollection].
  static void build<T extends FeatureObject>(
    WriteFeatures features, {
    required void Function(T feature) to,
  }) {
    final builder = FeatureBuilder<T>._(to);
    features.call(builder);
  }

  /// Builds a list of geospatial feature objects from the content provided by
  /// [features].
  ///
  /// Only feature objects of [T] are built, any other objects are ignored. [T]
  /// should be [FeatureObject] (building both features and feature
  /// collections), [Feature] or [FeatureCollection].
  ///
  /// An optional expected [count], when given, specifies the number of feature
  /// objects in the content. Note that when given the count MUST be exact.
  static List<T> buildList<T extends FeatureObject>(
    WriteFeatures features, {
    int? count,
  }) {
    final list = <T>[];
    final builder = FeatureBuilder<T>._(list.add);
    features.call(builder);
    return list;
  }

  @override
  void feature({
    Object? id,
    WriteGeometries? geometry,
    Map<String, Object?>? properties,
    Iterable<double>? bounds,
    WriteProperties? custom,
  }) {
    _add(
      Feature.build(
        id: id,
        geometry: geometry,
        properties: properties,
        bounds: bounds,
        custom: custom,
      ),
    );
  }

  @override
  void featureCollection(
    WriteFeatures features, {
    int? count,
    Iterable<double>? bounds,
    WriteProperties? custom,
  }) {
    _add(
      FeatureCollection.build(
        features,
        count: count,
        bounds: bounds,
        custom: custom,
      ),
    );
  }
}
