// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/core/features/feature_source.dart';
import '/src/ogcapi_common/model/ogc_collection_meta.dart';

import 'ogc_feature_item.dart';
import 'ogc_feature_items.dart';

/// A feature source compliant with the OGC API Features standard.
abstract class OGCFeatureSource
    extends FeatureSource<OGCFeatureItem, OGCFeatureItems> {
  /// Get metadata about the feature collection represented by this source.
  Future<OGCCollectionMeta> meta();
}
