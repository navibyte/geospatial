// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:geocore/data.dart';
import 'package:meta/meta.dart';

import '../common.dart';

/// Feature items with wrapped feature collection and metadata.
@immutable
class FeatureItems<E extends Feature> extends FeatureCollection<E>
    with EquatableMixin {
  /// Create feature items by wrapping [collection] and [meta] data.
  const FeatureItems({required this.collection, required this.meta});

  /// The wrapped feature [collection].
  final FeatureCollection<E> collection;

  /// The wrapped [meta] data.
  final ItemsMeta meta;

  @override
  List<Object?> get props => [collection, meta];

  @override
  BoundedSeries<E> get features => collection.features;

  @override
  Bounds get bounds => collection.bounds;

  @override
  FeatureItems<E> transform(TransformPoint transform) => FeatureItems(
        collection: collection.transform(transform),
        meta: meta,
      );

  @override
  FeatureCollection project<R extends Point>(
    ProjectPoint<R> projection, {
    PointFactory<R>? to,
  }) =>
      FeatureItems(
        collection: collection.project(projection, to: to),
        meta: meta,
      );
}
