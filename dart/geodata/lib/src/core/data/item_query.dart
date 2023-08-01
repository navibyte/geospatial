// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'geospatial_query.dart';

/// A query for requesting an item from a geospatial data source.
class ItemQuery extends GeospatialQuery {
  /// A query for requesting an item from a geospatial data source by [id].
  const ItemQuery({
    required this.id,
    super.crs,
    super.parameters,
  });

  /// An identifier specifying an item on a geodata source.
  ///
  /// An identifier should be an integer number (int or BigInt) or a string.
  final Object id;

  @override
  List<Object?> get props => [id, crs, parameters];
}
