// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/core/data.dart';

/// A query for requesting items from a geospatial data source.
class ItemsQuery extends GeospatialQuery {
  /// A query for requesting items from a geospatial data source.
  const ItemsQuery({
    String? crs,
    this.limit,
    final Map<String, Object?>? extra,
  }) : super(crs: crs, extra: extra);

  /// An optional [limit] setting maximum number of items returned.
  ///
  /// If given, must be a positive integer.
  final int? limit;

  @override
  List<Object?> get props => [crs, limit, extra];
}
