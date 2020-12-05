// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'base.dart';

import '../../model/geo/common.dart';
import '../../model/geo/features.dart';

abstract class FeatureProvider extends Provider<ProviderMeta, FeatureResource> {
}

abstract class FeatureResource extends Resource {
  // todo : bbox, time and other filtering parameters on features() methods

  /// Fetches feature items from this feature (collection) resource.
  ///
  /// This accessed only one set of feature items.
  Future<FeatureItems> features({int limit = -1});

  /// Fetches paged feature items from this feature (collection) resource.
  ///
  /// This call returns a first set of feature items with link to next set.
  Future<Paged<FeatureItems>> featuresPaged({int limit = -1});
}
