// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/common.dart';

import '/src/common/links/links.dart';
import '/src/common/links/links_aware.dart';
import '/src/core/features/feature_items.dart';

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
    this.contentCrs,
  });

  /// An optional coordinate reference system from "Content-Crs" response
  /// header.
  final CoordRefSys? contentCrs;

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

  @override
  String toString() {
    return '${super.toString()};$contentCrs';
  }

  @override
  bool operator ==(Object other) =>
      other is OGCFeatureItems &&
      super == other &&
      contentCrs == other.contentCrs;

  @override
  int get hashCode => Object.hash(super.hashCode, contentCrs);
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
