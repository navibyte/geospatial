// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/core/data.dart';

/// A query for requesting an item from a geospatial data source.
class ItemQuery extends GeospatialQuery {
  /// A query for requesting an item from a geospatial data source by [id].
  const ItemQuery({
    required this.id,
    String? crs,
    Map<String, String>? extraParams,
  }) : super(crs: crs, extraParams: extraParams);

  /// An identifier specifying an item on a geodata source.
  ///
  /// Note that an identifier could be textual or a number but reprensented here
  /// as a String object.
  final String id;

  @override
  List<Object?> get props => [id, crs, extraParams];
}
