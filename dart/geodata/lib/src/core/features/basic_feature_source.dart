// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/paged/paged.dart';

import 'feature_item.dart';
import 'feature_items.dart';
import 'feature_source.dart';

/// A basic feature source providing geospatial features.
///
/// This feature source has operations to get feature items by id or to get all
/// items. The [FeatureSource] extends this with queryable access to items.
abstract class BasicFeatureSource<ItemType extends FeatureItem,
    ItemsType extends FeatureItems> {
  /// Fetches a single feature by [id] from this source.
  ///
  /// An identifier should be an integer number (int or BigInt) or a string.
  ///
  /// Throws `ServiceException<FeatureFailure>` in a case of a failure.
  Future<ItemType> itemById(Object id);

  /// Fetches all features items from this source.
  ///
  /// An optional [limit] sets maximum number of items returned. If given, it
  /// must be a positive integer.
  ///
  /// This call accesses only one set of feature items (number of returned items
  /// can be limited).
  ///
  /// Throws `ServiceException<FeatureFailure>` in a case of a failure.
  Future<ItemsType> itemsAll({int? limit});

  /// Fetches all features as paged sets from this source.
  ///
  /// An optional [limit] sets maximum number of items returned. If given, it
  /// must be a positive integer.
  ///
  /// This call returns a first set of feature items (number of returned items
  /// can be limited), with a link to an optional next set of feature items.
  ///
  /// Throws `ServiceException<FeatureFailure>` in a case of a failure.
  Future<Paged<ItemsType>> itemsAllPaged({int? limit});
}
