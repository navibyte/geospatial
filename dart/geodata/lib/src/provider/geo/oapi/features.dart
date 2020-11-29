// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import '../../../client/client.dart';
import '../../../client/query.dart';
import '../../../model/geo/common.dart';
import '../../../model/geo/features.dart';
import '../../../parser/geo/oapi/provider_meta.dart';

import '../features.dart';

/// A feature provider for the OGC API Features (OAPIF) standard.
///
/// See: https://github.com/opengeospatial/ogcapi-features
/// Demos: https://github.com/opengeospatial/ogcapi-features/blob/master/implementations.md
class FeatureProviderOAPIF extends FeatureProvider {
  /// Ceate a feature provider (for OGC API Features) using API client.
  factory FeatureProviderOAPIF.client(ApiClient client) {
    return FeatureProviderOAPIF._client(client);
  }

  FeatureProviderOAPIF._client(ApiClient client) : _client = client;

  final ApiClient _client;

  @override
  Future<ProviderMeta> meta() async {
    // read "/"
    final landing = await _client.read(Query.url((e) => '${e.baseUrl}/'));
    final landingJson = landing.decodeJson();

    // read "/conformance"
    final conformance =
        await _client.read(Query.url((e) => '${e.baseUrl}/conformance'));
    final conformanceJson = conformance.decodeJson();

    // read "/collections"
    final collections =
        await _client.read(Query.url((e) => '${e.baseUrl}/collections'));
    final collectionsJson = collections.decodeJson();

    // combine ProviderMeta object from different meta resources just fetched
    return providerFromJson(
      landing: landingJson,
      conformance: conformanceJson,
      collections: collectionsJson,
    );
  }

  @override
  Future<Features> items() async {
    throw UnimplementedError('Not yet implemented on 0.0.1 release. Sorry!');
  }
}
