// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/core/base.dart';

import 'ogc_feature_conformance.dart';
import 'ogc_feature_source.dart';

/// A feature service compliant with the OGC API Features standard.
abstract class OGCFeatureService {
  /// Get meta data (or "landing page" information) about this service.
  Future<ResourceMeta> meta();

  // NOTE: API description: api();

  /// Conformance classes this service is conforming to.
  Future<OGCFeatureConformance> conformance();

  /// Get metadata about feature collections provided by this service.
  Future<Iterable<CollectionMeta>> collections();

  /// Get a feature source for a feature collection identified by [id].
  Future<OGCFeatureSource> collection(String id);
}
