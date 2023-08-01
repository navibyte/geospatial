// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'geospatial_query.dart';

/// A query for requesting items from a geospatial data source.
class ItemsQuery extends GeospatialQuery {
  /// A query for requesting items from a geospatial data source.
  const ItemsQuery({
    super.crs,
    this.limit,
    super.parameters,
  });

  /// An optional [limit] setting maximum number of items returned.
  ///
  /// If given, must be a positive integer.
  final int? limit;

  @override
  List<Object?> get props => [crs, limit, parameters];
}
