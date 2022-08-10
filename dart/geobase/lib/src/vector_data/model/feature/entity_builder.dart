// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/base.dart';
import '/src/vector/content.dart';

import 'entity.dart';
import 'feature.dart';
import 'feature_collection.dart';

/// A function to add [entity] to some collection.
typedef AddEntity<T extends Entity> = void Function(T entity);

/// A builder to create entity instances of [T] from [FeatureContent].
class EntityBuilder<T extends Entity> with FeatureContent {
  final AddEntity<T> _addEntity;

  EntityBuilder._(this._addEntity);

  void _add(Entity entity) {
    if (entity is T) {
      _addEntity.call(entity);
    }
  }

  /// Builds entities from the content provided by [entities].
  ///
  /// Built entity object are sent into [to] callback function.
  ///
  /// Only entity objects of [T] are built, any other entities are ignored.
  static void build<T extends Entity>(
    WriteFeatures entities, {
    required AddEntity<T> to,
  }) {
    final builder = EntityBuilder<T>._(to);
    entities.call(builder);
  }

  /// Builds an entity list from the content provided by [entities].
  ///
  /// Only entity objects of [T] are built, any other entities are ignored.
  ///
  /// An optional expected [count], when given, specifies the number of entity
  /// objects in the content. Note that when given the count MUST be exact.
  static List<T> buildList<T extends Entity>(
    WriteFeatures entities, {
    int? count,
  }) {
    final list = <T>[];
    final builder = EntityBuilder<T>._((T geometry, {String? name}) {
      list.add(geometry);
    });
    entities.call(builder);
    return list;
  }

  @override
  void feature({
    Object? id,
    WriteGeometries? geometry,
    Map<String, Object?>? properties,
    Box? bbox,
    WriteProperties? custom,
  }) {
    _add(
      Feature.build(
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
    _add(
      FeatureCollection.build(
        features,
        count: count,
        custom: custom,
      ),
    );
  }
}
