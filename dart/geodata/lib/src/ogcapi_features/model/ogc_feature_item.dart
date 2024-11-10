// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/common.dart';

import '/src/common/links/links.dart';
import '/src/common/links/links_aware.dart';
import '/src/core/features/feature_item.dart';

/// A result from a feature source containing [feature] and [meta] data.
///
/// This class extends [FeatureItem] defining some getters ([links]) that are
/// OGC API Features specific.
class OGCFeatureItem extends FeatureItem with LinksAware {
  /// Create a feature item instance with [feature] and optional [meta].
  const OGCFeatureItem(
    super.feature, {
    super.meta,
    this.contentCrs,
  });

  /// An optional coordinate reference system from "Content-Crs" response
  /// header.
  final CoordRefSys? contentCrs;

  // Note : Following getters access external data outside actual parsing code,
  // so there's some extra care to ensure nulls or empty data is returned if
  // accessing data throws.

  @override
  Links get links {
    final data = meta['links'];
    if (data is Iterable<dynamic>) {
      try {
        return Links.fromJson(data);
      } on FormatException {
        // nop, could not parse, but then let empty links to be returned
      }
    }
    return const Links.empty();
  }

  @override
  String toString() {
    return '${super.toString()};$contentCrs';
  }

  @override
  bool operator ==(Object other) =>
      other is OGCFeatureItem &&
      super == other &&
      contentCrs == other.contentCrs;

  @override
  int get hashCode => Object.hash(super.hashCode, contentCrs);
}
