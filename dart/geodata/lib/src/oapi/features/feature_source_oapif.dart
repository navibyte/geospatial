// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:datatools/fetch_api.dart';
import 'package:datatools/meta_link.dart';
import 'package:geocore/parse_geojson.dart';

import '../../api/common.dart';
import '../../api/features.dart';

import '../common.dart';

/// A feature source providing data from OGC API Features (OAPIF) services.
///
/// See: https://ogcapi.ogc.org/features/
/// See: https://github.com/opengeospatial/ogcapi-features
/// Demos: https://github.com/opengeospatial/ogcapi-features/blob/master/implementations.md
class FeatureServiceOAPIF extends DataSourceOAPI implements FeatureSource {
  FeatureServiceOAPIF._(Fetcher client) : super(client: client);

  /// Ceate a feature source for OGC API Features using a [client].
  factory FeatureServiceOAPIF.of({required Fetcher client}) =>
      FeatureServiceOAPIF._(client);

  @override
  DataSourceMeta createMeta({
    required String title,
    String? description,
    required Links links,
    required List<String> conformance,
    required List<CollectionMeta> collections,
  }) =>
      DataSourceMeta(
        title: title,
        description: description,
        links: links,
        conformance: conformance,
        collections: collections,
      );

  @override
  Future<FeatureItems> items(
    String collectionId, {
    FeatureFilter? filter,
  }) async =>
      (await itemsPaged(collectionId, filter: filter)).current;

  @override
  Future<Paged<FeatureItems>> itemsPaged(
    String collectionId, {
    FeatureFilter? filter,
  }) async {
    // read "collections/{collectionId}/items" and return as paged response

    // resolve key-value parameters needed for a items request
    final Map<String, dynamic> params;
    if (filter == null) {
      params = <String, dynamic>{
        //'f': 'json',
      };
    } else {
      // todo : need to check if server supports CRS extension

      final limit = filter.limit;
      final crs = filter.crs;
      final boundsCrs = filter.boundsCrs;
      final bounds = filter.bounds?.valuesAsString();
      params = <String, dynamic>{
        //'f': 'json',
        if (limit != null) 'limit': limit.toString(),
        if (crs != null) 'crs': crs.id,
        if (boundsCrs != null) 'bbox-crs': boundsCrs.id,
        if (bounds != null) 'bbox': bounds,
      };
    }

    // read from client and return paged feature collection response
    final id = filter?.id;
    return _PagedFeaturesOAPIF.parse(
      client,
      await client.headers(_acceptGeoJSON).fetch(
            Uri(
              path: id != null
                  ? 'collections/$collectionId/items/$id'
                  : 'collections/$collectionId/items',
              queryParameters: params,
            ),
          ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

const _acceptGeoJSON = {'accept': 'application/geo+json'};

class _PagedFeaturesOAPIF extends Paged<FeatureItems> {
  _PagedFeaturesOAPIF(this.client, this.features, {this.nextURL});

  static Future<_PagedFeaturesOAPIF> parse(Fetcher client, Content body) async {
    // decode JSON content (supposed to be GeoJSON)
    if (!body.hasType('application', 'geo+json', 'json')) {
      throw const FormatException('GeoJSON content required.');
    }
    final json = await body.decodeJson() as Map<String, dynamic>;

    // check also for an optional "next" link
    final links = Links.fromJson(json['links'] as Iterable);
    final next = links.next(type: 'application/geo+json');

    // parse feature items (meta + actual features) and return a paged result
    return _PagedFeaturesOAPIF(
      client,
      _featureItemsFromJson(json),
      nextURL: next.isNotEmpty ? next.first.href : null,
    );
  }

  final Fetcher client;
  final FeatureItems features;
  final String? nextURL;

  @override
  FeatureItems get current => features;

  @override
  bool get hasNext => nextURL != null;

  @override
  Future<Paged<FeatureItems>> next() async {
    final url = nextURL;
    if (url != null) {
      // read data from nextURL and return as paged response
      return _PagedFeaturesOAPIF.parse(
        client,
        await client.headers(_acceptGeoJSON).fetch(Uri.parse(url)),
      );
    } else {
      throw StateError('No next URL.');
    }
  }
}

/// Parses a "collections/{id}/items" feature items from a OGC API service.
FeatureItems _featureItemsFromJson(Map<String, dynamic> json) {
  return FeatureItems(
    collection: geoJSON.featureCollection(json),
    meta: ItemsMeta(
      timeStamp: _parseTimeStamp(json['timeStamp']) ?? DateTime.now(),
      numberMatched: json['numberMatched'] as int?,
      numberReturned: json['numberReturned'] as int?,
    ),
  );
}

DateTime? _parseTimeStamp(dynamic data) {
  if (data != null) {
    return DateTime.tryParse(data as String);
  }
  return null;
}
