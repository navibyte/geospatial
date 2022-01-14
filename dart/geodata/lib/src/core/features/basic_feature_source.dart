// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/paged.dart';

import 'basic_feature_item_query.dart';
import 'basic_feature_items_query.dart';
import 'feature_exception.dart';
import 'feature_item.dart';
import 'feature_items.dart';
import 'feature_source.dart';

/// A basic feature source providing geospatial features.
///
/// This feature source has operations to get feature items by id or to get all
/// items. The [FeatureSource] extends this with queryable access to items.
abstract class BasicFeatureSource<ItemType extends FeatureItem,
    ItemsType extends FeatureItems> {
  /// Fetches a single feature by id (set in [query]) from this source.
  ///
  /// Throws [FeatureException] in a case of a failure.
  Future<ItemType> item(BasicFeatureItemQuery query);

  /// Fetches all features items from this source with optional [query] params.
  ///
  /// This call accesses only one set of feature items (number of returned items
  /// can be limited).
  ///
  /// Throws [FeatureException] in a case of a failure.
  Future<ItemsType> itemsAll({BasicFeatureItemsQuery? query});

  /// All features as paged sets from this source with optional [query] params.
  ///
  /// This call returns a first set of feature items (number of returned items
  /// can be limited), with a link to an optional next set of feature items.
  ///
  /// Throws [FeatureException] in a case of a failure.
  Future<Paged<ItemsType>> itemsAllPaged({BasicFeatureItemsQuery? query});
}
