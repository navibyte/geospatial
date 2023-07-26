// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/common/links/link.dart';
import '/src/common/links/links.dart';
import '/src/common/service/service_exception.dart';
import '/src/core/api/open_api_document.dart';
import '/src/ogcapi_common/model/ogc_service.dart';
import '/src/ogcapi_common/model/ogc_service_meta.dart';
import '/src/utils/feature_http_adapter.dart';
import '/src/utils/resolve_api_call.dart';

// -----------------------------------------------------------------------------
// Private / Internal implementation code below.
// The implementation may change in future.

// OpenAPI definition resources
const _acceptJSONOpenAPI = {
  'accept': 'application/vnd.oai.openapi+json, application/openapi+json'
};
const _expectJSONOpenAPI = [
  'application/vnd.oai.openapi+json',
  'application/openapi+json',
  'application/json',
];

/// A client for accessing `OGC API - Common` compliant sources via http(s).
@internal
abstract class OGCClientHttp implements OGCService {
  /// Create a http client with HTTP(S) [endpoint] and [adapter].
  const OGCClientHttp(
    this.endpoint, {
    required this.adapter,
  });

  /// The endpoint for this client.
  final Uri endpoint;

  /// An adapter used to access HTTP(S) resource.
  final FeatureHttpAdapter adapter;

  @override
  Future<OGCServiceMeta> meta() async {
    // fetch data as JSON Object, and parse meta data
    return adapter.getEntityFromJsonObject(
      endpoint,
      toEntity: (data) {
        final links = Links.fromJson(data['links'] as Iterable<dynamic>);
        return _OGCServiceMetaImpl(
          service: this,
          title: data['title'] as String? ??
              links.self().first.title ??
              'An OGC API service',
          links: links,
          description: data['description'] as String?,
          attribution: data['attribution'] as String?,
        );
      },
    );
  }
}

class _OGCServiceMetaImpl extends OGCServiceMeta {
  final OGCClientHttp service;

  const _OGCServiceMetaImpl({
    required this.service,
    required super.title,
    super.description,
    super.attribution,
    required super.links,
  });

  @override
  Future<OpenAPIDocument> openAPI() {
    // 1. Get a link for the relation "service-desc".
    // 2. Ensure it's type is "application/vnd.oai.openapi+json".
    //    (here we are allowing other JSON based content types too)
    final link = _resolveServiceDescLink();
    if (link == null) {
      throw const ServiceException('No valid service-desc link.');
    }
    final url = resolveLinkReferenceUri(service.endpoint, link.href);

    // 3. Read JSON content from a HTTP service.
    // 4. Decode content received as JSON Object using the standard JSON decoder
    // 5. Wrap such decoded object in an [OpenAPIDefinition] instance.
    final type = link.type;
    if (type != null) {
      return service.adapter.getEntityFromJsonObject(
        url,
        headers: {'accept': type},
        expect: _expectJSONOpenAPI,
        toEntity: (data) => OpenAPIDocument(content: data),
      );
    } else {
      return service.adapter.getEntityFromJsonObject(
        url,
        headers: _acceptJSONOpenAPI,
        expect: _expectJSONOpenAPI,
        toEntity: (data) => OpenAPIDocument(content: data),
      );
    }
  }

  /// Resolve an url that's providing OpenAPI or JSON service description.
  Link? _resolveServiceDescLink() {
    // check for links of "service-desc" rel type
    final serviceDesc = links.serviceDesc();
    for (final type in _expectJSONOpenAPI) {
      for (final link in serviceDesc) {
        if (link.type?.startsWith(type) ?? false) {
          return link;
        }
      }
    }
    // check for links of "service" rel type (NOT STANDARD)
    final service = links.service();
    for (final type in _expectJSONOpenAPI) {
      for (final link in service) {
        if (link.type?.startsWith(type) ?? false) {
          return link;
        }
      }
    }
    return null;
  }
}
