// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import 'package:geocore/base.dart';
import 'package:geocore/feature.dart';

import 'package:meta/meta.dart';

import '../common.dart';

/// Feature items with wrapped feature collection and metadata.
@immutable
class FeatureItems<T extends Feature> extends FeatureCollection<T>
    with EquatableMixin {
  /// Create feature items by wrapping [collection] and [meta] data.
  const FeatureItems({required this.collection, required this.meta});

  /// The wrapped feature [collection].
  final FeatureCollection<T> collection;

  /// The wrapped [meta] data.
  final ItemsMeta meta;

  @override
  List<Object?> get props => [collection, meta];

  @override
  BoundedSeries<T> get features => collection.features;

  @override
  Bounds get bounds => collection.bounds;

  @override
  FeatureItems<T> project(TransformPoint transform) =>
      FeatureItems(collection: collection.project(transform), meta: meta);
}
