// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geocore/data.dart';

import '/src/common/meta.dart';

/// A result from a feature source containing [feature] and [meta] data.
class FeatureItem with MetaAware {
  /// Create a feature item instance with [feature] and optional [meta].
  const FeatureItem(this.feature, {Map<String, Object?>? meta})
      : meta = meta ?? const {};

  /// The wrapped feature.
  final Feature feature;

  @override
  final Map<String, Object?> meta;
}
