// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/ogcapi_common/model/ogc_collection_meta.dart';
import '/src/ogcapi_common/model/ogc_service.dart';

import 'ogc_feature_conformance.dart';
import 'ogc_feature_source.dart';

/// A feature service compliant with the OGC API Features standard.
abstract class OGCFeatureService extends OGCService {
  @override
  Future<OGCFeatureConformance> conformance();

  /// Get metadata about feature collections provided by this service.
  Future<Iterable<OGCCollectionMeta>> collections();

  /// Get a feature source for a feature collection identified by [id].
  Future<OGCFeatureSource> collection(String id);
}
