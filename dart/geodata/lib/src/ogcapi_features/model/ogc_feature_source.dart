// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/paged/paged.dart';
import '/src/core/data/bounded_items_query.dart';
import '/src/core/features/feature_source.dart';
import '/src/formats/cql2/cql_query.dart';
import '/src/ogcapi_common/model/ogc_collection_meta.dart';
import '/src/ogcapi_common/model/ogc_queryable_object.dart';

import 'ogc_feature_item.dart';
import 'ogc_feature_items.dart';

/// A feature source compliant with the OGC API Features standard.
abstract class OGCFeatureSource
    extends FeatureSource<OGCFeatureItem, OGCFeatureItems> {
  /// Get metadata about the feature collection represented by this source.
  Future<OGCCollectionMeta> meta();

  /// Get optional metadata about queryable properties for the feature
  /// collection represented by this source.
  ///
  /// Returns null if no "queryables" metadata is available for this feature
  /// source.
  ///
  /// An instance of `OGCQueryableObject` contains metadata about supported
  /// queryable parameters (in `properties`) instantiated as
  /// `OGCQueryableProperty` objects. You may use this information when
  /// specifying actual query parameters (for feature collection properties)
  /// using `BoundedItemsQuery` class when calling `items` or `itemsAll`.
  ///
  /// An OGC API Features service providing "queryables" metadata must publish
  /// support for the `Queryables` conformance class specified in the
  /// `OGC API - Features - Part 3: Filtering` standard.
  Future<OGCQueryableObject?> queryables();

  /// Fetches features matching [query] (and an optional [cql] query) from this
  /// source.
  ///
  /// If both [query] and [cql] are provided, then a service returns only
  /// features that match both [query] AND the [cql] query.
  ///
  /// This call accesses only one set of feature items (number of returned items
  /// can be limited).
  ///
  /// [query] defines a filter or query parameters based on standards:
  /// * `OGC API - Features - Part 1: Core`
  /// * `OGC API - Features - Part 2: Coordinate Reference Systems by Reference`
  /// * `OGC API - Features - Part 3: Filtering`: Queryables as Query Parameters
  ///
  /// [cql] defines a filter or query parameters based on standards:
  /// * `OGC API - Features - Part 3: Filtering`: Filter / Features Filter
  /// * `Common Query Language (CQL2)`
  ///
  /// Throws `ServiceException<FeatureFailure>` in a case of a failure.
  @override
  Future<OGCFeatureItems> items(
    BoundedItemsQuery query, {
    CQLQuery? cql,
  });

  /// Fetches features as paged sets matching [query] (and an optional [cql]
  /// query) from this source.
  ///
  /// If both [query] and [cql] are provided, then a service returns only
  /// features that match both [query] AND the [cql] query.
  ///
  /// This call returns a first set of feature items (number of returned items
  /// can be limited), with a link to an optional next set of feature items.
  ///
  /// [query] defines a filter or query parameters based on standards:
  /// * `OGC API - Features - Part 1: Core`
  /// * `OGC API - Features - Part 2: Coordinate Reference Systems by Reference`
  /// * `OGC API - Features - Part 3: Filtering`: Queryables as Query Parameters
  ///
  /// [cql] defines a filter or query parameters based on standards:
  /// * `OGC API - Features - Part 3: Filtering`: Filter / Features Filter
  /// * `Common Query Language (CQL2)`
  ///
  /// Throws `ServiceException<FeatureFailure>` in a case of a failure.
  @override
  Future<Paged<OGCFeatureItems>> itemsPaged(
    BoundedItemsQuery query, {
    CQLQuery? cql,
  });
}
