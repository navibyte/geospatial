// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:geocore/feature.dart';

import 'common.dart';

/// A feature items with wrapped feature collection and metadata.
@immutable
class FeatureItems<T extends Feature> extends FeatureCollection
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
  FeatureSeries<Feature> get features => collection.features;
}
