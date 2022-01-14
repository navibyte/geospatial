// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/paged.dart';

import 'basic_feature_source.dart';
import 'feature_exception.dart';
import 'feature_item.dart';
import 'feature_items.dart';
import 'feature_items_query.dart';

/// A feature source providing geospatial features.
abstract class FeatureSource<ItemType extends FeatureItem,
        ItemsType extends FeatureItems>
    extends BasicFeatureSource<ItemType, ItemsType> {
  /// Fetches features matching [query] from this source.
  ///
  /// This call accesses only one set of feature items (number of returned items
  /// can be limited).
  ///
  /// Throws [FeatureException] in a case of a failure.
  Future<ItemsType> items(FeatureItemsQuery query);

  /// Fetches features as paged sets matching [query] from this source.
  ///
  /// This call returns a first set of feature items (number of returned items
  /// can be limited), with a link to an optional next set of feature items.
  ///
  /// Throws [FeatureException] in a case of a failure.
  Future<Paged<ItemsType>> itemsPaged(FeatureItemsQuery query);
}
