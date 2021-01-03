// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geocore/parse_geojson.dart';
import 'package:datatools/client_base.dart';

import '../../../model/common.dart';
import '../../../model/features.dart';

import '../../../provider/common.dart';
import '../../../provider/features.dart';

import '../common.dart';

/// A feature provider for the OGC API Features (OAPIF) standard.
///
/// See: https://ogcapi.ogc.org/features/
/// See: https://github.com/opengeospatial/ogcapi-features
/// Demos: https://github.com/opengeospatial/ogcapi-features/blob/master/implementations.md
class FeatureProviderOAPIF extends ProviderOAPI<ProviderMeta, FeatureResource>
    implements FeatureProvider {
  FeatureProviderOAPIF._(ApiClient client) : super(client: client);

  /// Ceate a feature provider (for OGC API Features) using API client.
  factory FeatureProviderOAPIF.client(ApiClient client) =>
      FeatureProviderOAPIF._(client);

  @override
  ProviderMeta createProviderMeta(
      {required LinksMeta links,
      required List<String> conformance,
      required List<CollectionMeta> collections,
      required String title,
      String? description}) {
    return ProviderMeta(
      links: links,
      conformance: conformance,
      collections: collections,
      title: title,
      description: description,
    );
  }

  @override
  Future<FeatureResource> collection(String id) async {
    return _FeatureResourceOAPIF(client, this, id);
  }
}

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

class _FeatureResourceOAPIF extends FeatureResource {
  _FeatureResourceOAPIF(this.client, this.provider, this.collectionId);

  final ApiClient client;
  final FeatureProvider provider;
  final String collectionId;

  @override
  Future<FeatureItems> items({FeatureFilter? filter}) async {
    return (await itemsPaged(filter: filter)).current;
  }

  @override
  Future<Paged<FeatureItems>> itemsPaged({FeatureFilter? filter}) async {
    // read "/collections/{id}/items" and return as paged response
    return _PagedFeaturesOAPIF.parse(
        client,
        await client.read(
          Query.url((endpoint) {
            final buf = StringBuffer(endpoint.baseUrl);
            buf..write('/collections/')..write(collectionId)..write('/items');
            final id = filter?.id;
            if (id != null) {
              buf..write('/')..write(id)..write('?f=json');
            } else {
              buf..write('?f=json&limit=')..write(filter?.limit ?? -1);
              if (filter != null) {
                // todo : need to check if server supports CRS extension

                final crs = filter.crs;
                if (crs != null) {
                  buf..write('&crs=')..write(crs.id);
                }
                final boundsCrs = filter.boundsCrs;
                if (boundsCrs != null) {
                  buf..write('&bbox-crs=')..write(boundsCrs.id);
                }
                final bounds = filter.bounds;
                if (bounds != null) {
                  buf.write('&bbox=');
                  if (bounds.is3D) {
                    buf
                      ..write(bounds.min.x)
                      ..write(',')
                      ..write(bounds.min.y)
                      ..write(',')
                      ..write(bounds.min.z)
                      ..write(',')
                      ..write(bounds.max.x)
                      ..write(',')
                      ..write(bounds.max.y)
                      ..write(',')
                      ..write(bounds.max.z);
                  } else {
                    buf
                      ..write(bounds.min.x)
                      ..write(',')
                      ..write(bounds.min.y)
                      ..write(',')
                      ..write(bounds.max.x)
                      ..write(',')
                      ..write(bounds.max.y);
                  }
                }
              }
            }

            // todo: now just simple logging on console, need better solution
            print(buf);

            return buf.toString();
          }),
        ));
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
    return _PagedFeaturesOAPIF(client, _featureItemsFromJson(json),
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

/// Parses a "/collections/{id}/items" feature items from a OGC API service.
FeatureItems _featureItemsFromJson(Map<String, dynamic> json) => FeatureItems(
      collection: geoJSON.featureCollection(json),
      meta: ItemsMeta(
        timeStamp: DateTime.now(),
        numberMatched: json['numberMatched'],
        numberReturned: json['numberReturned'],
      ),
    );
