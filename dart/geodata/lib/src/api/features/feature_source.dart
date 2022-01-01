// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../common.dart';
import '../features.dart';

/// A feature source to access data source providing geospatial feature objects.
abstract class FeatureSource<M extends DataSourceMeta> extends DataSource<M> {
  /// Default `const` constructor to allow extending this abstract class.
  const FeatureSource();

  /// Fetches features matching [filter] from a feature collection resource.
  ///
  /// This call accesses only one set of feature items.
  Future<FeatureItems> items(String collectionId, {FeatureFilter? filter});

  /// Fetches feature items matching [filter] as paged responses.
  ///
  /// This call returns a first set of feature items with a link to a next set.
  Future<Paged<FeatureItems>> itemsPaged(
    String collectionId, {
    FeatureFilter? filter,
  });
}
