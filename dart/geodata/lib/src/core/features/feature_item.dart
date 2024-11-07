// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/vector_data.dart';
import 'package:meta/meta.dart';

import '/src/common/meta/meta_aware.dart';

/// A result from a feature source containing [feature] and [meta] data.
@immutable
class FeatureItem with MetaAware {
  /// Create a feature item instance with [feature] and optional [meta].
  const FeatureItem(this.feature, {Map<String, dynamic>? meta})
      : meta = meta ?? const {};

  /// The wrapped feature.
  final Feature feature;

  @override
  final Map<String, dynamic> meta;

  @override
  String toString() {
    return '$feature;$meta';
  }

  @override
  bool operator ==(Object other) =>
      other is FeatureItem && feature == other.feature && meta == other.meta;

  @override
  int get hashCode => Object.hash(feature, meta);
}
