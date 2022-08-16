// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/links.dart';
import '/src/core/features.dart';

/// A result from a feature source containing [collection] and [meta] data.
///
/// This class extends [FeatureItems] defining some getters ([timeStamp],
/// [numberMatched], [numberReturned], [links]) that are OGC API Features
/// specific.
class OGCFeatureItems extends FeatureItems with LinksAware {
  /// Create a feature items instance with [collection] and optional [meta].
  const OGCFeatureItems(
    super.collection, {
    super.meta,
  });

  // Note : Following getters access external data outside actual parsing code,
  // so there's some extra care to ensure nulls or empty data is returned if
  // accessing data throws.

  /// The time stamp
  DateTime? get timeStamp => _tryParseDateTime(meta['timeStamp']);

  /// An optional count of items matched.
  int? get numberMatched => _tryParseInt(meta['numberMatched']);

  /// An optional count of items returned.
  int? get numberReturned => _tryParseInt(meta['numberReturned']);

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
}

DateTime? _tryParseDateTime(Object? data) {
  if (data != null) {
    return data is DateTime ? data : DateTime.tryParse(data.toString());
  }
  return null;
}

int? _tryParseInt(Object? data) {
  if (data != null) {
    return data is num ? data.toInt() : int.tryParse(data.toString());
  }
  return null;
}
