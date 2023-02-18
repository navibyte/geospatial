// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:geobase/vector_data.dart';
import 'package:meta/meta.dart';

import '/src/common/meta.dart';

/// A result from a feature source containing [collection] and [meta] data.
@immutable
class FeatureItems with MetaAware, EquatableMixin {
  /// Create a feature items instance with [collection] and optional [meta].
  const FeatureItems(this.collection, {Map<String, dynamic>? meta})
      : meta = meta ?? const {};

  /// The wrapped feature collection.
  final FeatureCollection<Feature> collection;

  @override
  final Map<String, dynamic> meta;

  @override
  List<Object?> get props => [collection, meta];
}
