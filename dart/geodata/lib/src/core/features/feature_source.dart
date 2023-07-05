// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/paged/paged.dart';
import '/src/core/data/bounded_items_query.dart';
import '/src/core/data/item_query.dart';

import 'basic_feature_source.dart';
import 'feature_item.dart';
import 'feature_items.dart';

/// A feature source providing geospatial features.
abstract class FeatureSource<ItemType extends FeatureItem,
        ItemsType extends FeatureItems>
    extends BasicFeatureSource<ItemType, ItemsType> {
  /// Fetches a single feature by id (set in [query]) from this source.
  ///
  /// Throws `ServiceException<FeatureFailure>` in a case of a failure.
  Future<ItemType> item(ItemQuery query);

  /// Fetches features matching [query] from this source.
  ///
  /// This call accesses only one set of feature items (number of returned items
  /// can be limited).
  ///
  /// Throws `ServiceException<FeatureFailure>` in a case of a failure.
  Future<ItemsType> items(BoundedItemsQuery query);

  /// Fetches features as paged sets matching [query] from this source.
  ///
  /// This call returns a first set of feature items (number of returned items
  /// can be limited), with a link to an optional next set of feature items.
  ///
  /// Throws `ServiceException<FeatureFailure>` in a case of a failure.
  Future<Paged<ItemsType>> itemsPaged(BoundedItemsQuery query);
}
