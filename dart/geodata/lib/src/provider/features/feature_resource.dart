// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../../model/features.dart';
import '../../provider/common.dart';

abstract class FeatureResource extends Resource {
  /// Fetches features matching [filter] from a feature collection resource.
  ///
  /// This call accesses only one set of feature items.
  Future<FeatureItems> items({FeatureFilter? filter});

  /// Fetches feature items matching [filter] as paged responses.
  ///
  /// This call returns a first set of feature items with a link to a next set.
  Future<Paged<FeatureItems>> itemsPaged({FeatureFilter? filter});
}
