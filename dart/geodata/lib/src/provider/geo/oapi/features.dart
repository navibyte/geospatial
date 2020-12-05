// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:geodata/src/provider/geo/base.dart';
import 'package:synchronized/synchronized.dart';

import '../../../client/client.dart';
import '../../../client/content.dart';
import '../../../client/query.dart';
import '../../../model/geo/common.dart';
import '../../../model/geo/features.dart';
import '../../../model/geo/links.dart';
import '../../../parser/geo/oapi/provider_meta.dart';
import '../../../parser/geo/oapi/features.dart';

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

  ProviderMeta? _meta;
  final _metaLock = Lock();

  @override
  Future<ProviderMeta> meta() async {
    return _meta ??= await _metaLock.synchronized<ProviderMeta>(() async {
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
    });
  }

  @override
  Future<FeatureResource> collection(String id) async {
    return _FeatureResourceOAPIF(_client, this, id);
  }
}

class _FeatureResourceOAPIF extends FeatureResource {
  _FeatureResourceOAPIF(this.client, this.provider, this.id);

  final ApiClient client;
  final FeatureProvider provider;
  final String id;

  @override
  Future<FeatureItems> features({int limit = -1}) async {
    return (await featuresPaged(limit: limit)).current;
  }

  @override
  Future<Paged<FeatureItems>> featuresPaged({int limit = -1}) async {
    // read "/collections/{id}/items" and return as paged response
    return _PagedFeaturesOAPIF.parse(
        client,
        await client.read(Query.url(
            (e) => '${e.baseUrl}/collections/$id/items?f=json&limit=$limit')));
  }
}

class _PagedFeaturesOAPIF extends Paged<FeatureItems> {
  _PagedFeaturesOAPIF(this.client, this.features, {this.nextURL});

  factory _PagedFeaturesOAPIF.parse(ApiClient client, Content content) {
    // decode JSON content (supposed to be GeoJSON)
    if (content.mime.type != KnownType.geo_json &&
        content.mime.type != KnownType.json) {
      throw FormatException('Not GeoJSON content, cannot parse.');
    }
    final json = content.decodeJson();

    // check also for an optional "next" link
    final links = LinksMeta.fromJson(json['links']);
    final next = links.next(type: 'application/geo+json');

    // parse feature items (meta + actual features) and return a paged result
    return _PagedFeaturesOAPIF(client, featuresItemsFromJson(json),
        nextURL: next?.href);
  }

  final ApiClient client;
  final FeatureItems features;
  final String? nextURL;

  @override
  FeatureItems get current => features;

  @override
  bool get hasNext => nextURL != null;

  @override
  Future<Paged<FeatureItems>> next() async {
    if (nextURL == null) {
      throw StateError('No next URL.');
    }
    // read data from nextURL and return as paged response
    return _PagedFeaturesOAPIF.parse(
        client, await client.read(Query.url((e) => '$nextURL')));
  }
}
