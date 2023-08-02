// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/core/base/resource_meta.dart';
import '/src/formats/openapi/open_api_document.dart';

/// Basic metadata about OGC API service.
@immutable
abstract class OGCServiceMeta extends ResourceMeta {
  /// A new OGC API service metadata instance with [title], [description],
  /// [attribution] and [links].
  const OGCServiceMeta({
    required super.title,
    super.description,
    super.attribution,
    required super.links,
  });

  /// Get an OpenAPI documentation (API definition) for this service.
  ///
  /// The API definition is retrieved:
  /// 1. Get a link for the relation "service-desc".
  /// 2. Ensure it's type is "application/vnd.oai.openapi+json".
  /// 3. Read JSON content from a HTTP service.
  /// 4. Decode content received as JSON Object using the standard JSON decoder.
  /// 5. Wrap such decoded object in an [OpenAPIDocument] instance.
  ///
  /// If a service does not provide an OpenAPI definition in JSON or retrieving
  /// it fails, then a `ServiceException` is thrown.
  ///
  /// Most often for an OGC API Features service an API definition is an
  /// OpenAPI 3.0 document, but this is not required by the standard.
  Future<OpenAPIDocument> openAPI();

  @override
  List<Object?> get props => [title, description, attribution, links];
}
