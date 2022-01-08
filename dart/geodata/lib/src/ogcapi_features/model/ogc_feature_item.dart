// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geocore/data.dart';

import '/src/common/links.dart';
import '/src/core/features.dart';

/// A result from a feature source containing [feature] and [meta] data.
///
/// This class extends [FeatureItem] defining some getters ([links]) that are 
/// OGC API Features specific.
class OGCFeatureItem extends FeatureItem with LinksAware {
  /// Create a feature item instance with [feature] and optional [meta].
  const OGCFeatureItem(
    Feature feature, {
    Map<String, Object?>? meta,
  }) : super(feature, meta: meta);

  // Note : Following getters access external data outside actual parsing code,
  // so there's some extra care to ensure nulls or empty data is returned if
  // accessing data throws.

  @override
  Links get links {
    final data = meta['links'];
    if (data is Iterable<Object?>) {
      try {
        return Links.fromData(data);
      } on FormatException {
        // nop, could not parse, but then let empty links to be returned
      }
    }
    return const Links.empty();
  }
}
