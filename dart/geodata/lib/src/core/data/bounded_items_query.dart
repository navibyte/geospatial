// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/geobase.dart';

import 'items_query.dart';

/// A query with bounds for requesting items from a geospatial data source.
class BoundedItemsQuery extends ItemsQuery {
  /// A query with bounds for requesting items from a geospatial data source.
  const BoundedItemsQuery({
    super.crs,
    this.bboxCrs,
    this.bbox,
    this.timeFrame,
    super.limit,
    super.extra,
  });

  /// A new query with query parameters copied from an optional [query].
  ///
  /// Supports reading [query] parameters from [ItemsQuery] and
  /// [BoundedItemsQuery].
  ///
  /// If [query] is null, then returns an instance with all parameters set null.
  factory BoundedItemsQuery.fromOpt(ItemsQuery? query) =>
      query is BoundedItemsQuery
          ? BoundedItemsQuery(
              crs: query.crs,
              bboxCrs: query.bboxCrs,
              bbox: query.bbox,
              timeFrame: query.timeFrame,
              limit: query.limit,
              extra: query.extra,
            )
          : BoundedItemsQuery(
              crs: query?.crs,
              limit: query?.limit,
              extra: query?.extra,
            );

  /// An optional coordinate reference system used by [bbox].
  final String? bboxCrs;

  /// An optional [bbox] as a geospatial bounding filter (like `bbox`).
  final Box? bbox;

  /// An optional time frame as a temporal object (ie. instant or interval).
  final Temporal? timeFrame;

  @override
  List<Object?> get props => [crs, bboxCrs, bbox, timeFrame, limit, extra];
}
