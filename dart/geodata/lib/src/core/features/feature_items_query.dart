// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geocore/base.dart';

import 'basic_feature_items_query.dart';

/// A query defining parameters for requesting features from a feature source.
class FeatureItemsQuery extends BasicFeatureItemsQuery {
  /// Create a new feature items query with optional query parameters.
  const FeatureItemsQuery({
    String? crs,
    this.boundsCrs,
    this.bounds,
    this.datetime,
    int? limit,
    Map<String, String>? extraParams,
  }) : super(crs: crs, limit: limit, extraParams: extraParams);

  /// Create a new feature items query from an optional basic [query].
  factory FeatureItemsQuery.fromBasicOpt(BasicFeatureItemsQuery? query) =>
      FeatureItemsQuery(
        crs: query?.crs,
        limit: query?.limit,
        extraParams: query?.extraParams,
      );

  /// An optional coordinate reference system used by [bounds].
  final String? boundsCrs;

  /// An optional [bounds] as a geospatial bounding filter (like `bbox`).
  final Bounds? bounds;

  /// An optional datetime as a temporal object (instant or interval).
  final Temporal? datetime;

  @override
  List<Object?> get props => [crs, boundsCrs, bounds, limit, extraParams];
}
