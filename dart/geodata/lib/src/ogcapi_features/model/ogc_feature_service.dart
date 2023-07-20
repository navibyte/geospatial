// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/core/api/open_api_document.dart';
import '/src/core/base/collection_meta.dart';
import '/src/core/base/resource_meta.dart';

import 'ogc_feature_conformance.dart';
import 'ogc_feature_source.dart';

/// A feature service compliant with the OGC API Features standard.
abstract class OGCFeatureService {
  /// Get meta data (or "landing page" information) about this service.
  Future<ResourceMeta> meta();

  /// Get an OpenAPI documentation (API definition) for this service.
  /// 
  /// The API definition is retrieved:
  /// 1. Get a link from [meta] for the relation "service-desc".
  /// 2. Ensure it's type is "application/vnd.oai.openapi+json".
  /// 3. Read JSON content from a HTTP service.
  /// 4. Decode content received as JSON Object using the standard JSON decoder.
  /// 5. Wrap such decoded object in an [OpenAPIDocument] instance.
  /// 
  /// If a service does not provide an OpenAPI definition in JSON or retrieving
  /// it fails, then a `ServiceException` is thrown.
  /// 
  /// Most often for an OGC API Features service an API definition is an
  /// OpenAPI 3.0 document, but this is not required by the standard. You could
  /// also check whether [conformance] suggests a service conforming to 
  /// `openAPI30` before calling [openAPI].
  Future<OpenAPIDocument> openAPI();

  /// Conformance classes this service is conforming to.
  Future<OGCFeatureConformance> conformance();

  /// Get metadata about feature collections provided by this service.
  Future<Iterable<CollectionMeta>> collections();

  /// Get a feature source for a feature collection identified by [id].
  Future<OGCFeatureSource> collection(String id);
}
