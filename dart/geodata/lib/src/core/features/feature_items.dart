// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:geocore/data.dart';
import 'package:meta/meta.dart';

import '/src/common/meta.dart';

/// A result from a feature source containing [collection] and [meta] data.
@immutable
class FeatureItems with MetaAware, EquatableMixin {
  /// Create a feature items instance with [collection] and optional [meta].
  const FeatureItems(this.collection, {Map<String, Object?>? meta})
      : meta = meta ?? const {};

  /// The wrapped feature collection.
  final FeatureCollection<Feature> collection;

  @override
  final Map<String, Object?> meta;

  @override
  List<Object?> get props => [collection, meta];
}
