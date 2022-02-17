// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/geobase.dart';
import 'package:geocore/parse.dart';
import 'package:http/http.dart' as http;

import '/src/common/links.dart';
import '/src/common/paged.dart';
import '/src/core/base.dart';
import '/src/core/data.dart';
import '/src/ogcapi_features/model.dart';
import '/src/utils/features.dart';

/// A client for accessing `OGC API Features` compliant sources via http(s).
///
/// The required [endpoint] should refer to a base url of a feature service.
///
/// When given the optional [client] is used for http requests, otherwise the
/// default client of the `package:http/http.dart` package is used.
///
/// When given [headers] are injected to http requests (however some can be
/// overridden by the feature service implementation).
///
/// An optional [parser] argument specifies a GeoJSON parser. If not given then
/// `geoJsonGeographic(geographicPoints)` defined by the
/// `package:geocore/parse.dart` package is used as a default. When excpecting
/// cartesian or projected coordinates, you might want to use
/// `geoJsonCartesian(cartesianPoints)` as a parser. Or if expecting specific
/// type of points, you could also use a factory like
/// `geoJson(Point3.coordinates)`.
OGCFeatureService ogcApiFeaturesHttpClient({
  required Uri endpoint,
  http.Client? client,
  Map<String, String>? headers,
  GeoJsonFactory? parser,
}) =>
    _OGCFeatureClientHttp(
      endpoint,
      adapter: FeatureHttpAdapter(
        client: client,
        headers: headers,
      ),
      parser: parser ?? geoJsonGeographic(geographicPoints),
    );

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

const _acceptGeoJSON = {'accept': 'application/geo+json'};
const _expectGeoJSON = ['application/geo+json', 'application/json'];
const _nextAndPrevLinkType = 'application/geo+json';

/// A client for accessing `OGC API Features` compliant sources via http(s).
class _OGCFeatureClientHttp implements OGCFeatureService {
  const _OGCFeatureClientHttp(
    this.endpoint, {
    required this.adapter,
    required this.parser,
  });

  final Uri endpoint;
  final FeatureHttpAdapter adapter;
  final GeoJsonFactory parser;

  @override
  Future<OGCFeatureSource> collection(String id) =>
      Future.value(_OGCFeatureSourceHttp(this, id));

  @override
  Future<ResourceMeta> meta() async {
    // fetch data as JSON Object, and parse meta data
    return adapter.getEntityFromJsonObject(
      endpoint,
      toEntity: (data) {
        final links = Links.fromData(data['links']! as Iterable<Object?>);
        return ResourceMeta(
          title: data['title'] as String? ??
              links.self().first.title ??
              'An OGC API service',
          links: links,
          description: data['description'] as String?,
        );
      },
    );
  }

  @override
  Future<Iterable<String>> conformance() async {
    // fetch data as JSON Object, and parse conformance classes
    final url = endpoint.resolve('conformance');
    return adapter.getEntityFromJsonObject(
      url,
      toEntity: (data) =>
          (data['conformsTo'] as Iterable<Object?>?)?.cast<String>() ?? [],
    );
  }

  @override
  Future<Iterable<CollectionMeta>> collections() async {
    // fetch data as JSON Object, and parse conformance classes
    final url = endpoint.resolve('collections');
    return adapter.getEntityFromJsonObject(
      url,
      toEntity: (data) {
        final list = data['collections']! as Iterable<Object?>;
        return list
            .map<CollectionMeta>(
              (e) => _collectionFromData(e! as Map<String, Object?>),
            )
            .toList(growable: false);
      },
    );
  }
}

/// A data source for accessing a `OGC API Features` collection.
class _OGCFeatureSourceHttp implements OGCFeatureSource {
  const _OGCFeatureSourceHttp(this.service, this.collectionId);

  final _OGCFeatureClientHttp service;
  final String collectionId;

  @override
  Future<CollectionMeta> meta() async {
    // read "collections/{collectionId}

    final url = service.endpoint.resolve('collections/$collectionId');
    return service.adapter.getEntityFromJsonObject(
      url,
      toEntity: (data) {
        // data should contain a single collection as JSON Object
        // but some services seem to return this under "collections"...
        final collections = data['collections'];
        if (collections is Iterable<Object?>) {
          for (final coll in collections) {
            final collObj = coll! as Map<String, Object?>;
            if (collObj['id'] == collectionId) {
              return _collectionFromData(collObj);
            }
          }
        }

        // this is the way the standard suggests
        // (single collection meta as JSON object)
        return _collectionFromData(data);
      },
    );
  }

  @override
  Future<OGCFeatureItem> itemById(String id) => item(ItemQuery(id: id));

  @override
  Future<OGCFeatureItems> itemsAll({int? limit}) =>
      items(BoundedItemsQuery(limit: limit));

  @override
  Future<Paged<OGCFeatureItems>> itemsAllPaged({int? limit}) =>
      itemsPaged(BoundedItemsQuery(limit: limit));

  @override
  Future<OGCFeatureItem> item(ItemQuery query) async {
    // read "collections/{collectionId}/items/{query.id}"

    // form a query url
    final crs = query.crs;
    var params = <String, String>{
      //'f': 'json',
      if (crs != null) 'crs': crs,
    };
    if (query.extraParams != null) {
      params = Map.of(query.extraParams!)..addAll(params);
    }
    final url = service.endpoint.resolveUri(
      Uri(
        path: 'collections/$collectionId/items/${query.id}',
        queryParameters: params,
      ),
    );

    // fetch data as JSON Object, and parse a feature and meta data
    return service.adapter.getEntityFromJsonObject(
      url,
      toEntity: (data) {
        // todo : should allow other geojson parsers / point types too

        // parses Feature object from GeoJSON data using the parser of `geocore`
        final feature = service.parser.feature(data);

        // meta as Map<String, Object?> by removing Feature geometry and props
        final meta = Map.of(data)
          ..remove('geometry')
          ..remove('properties');

        return OGCFeatureItem(feature, meta: Map.unmodifiable(meta));
      },
    );
  }

  @override
  Future<OGCFeatureItems> items(BoundedItemsQuery query) async =>
      // read only first set of feature items
      (await itemsPaged(query)).current;

  @override
  Future<Paged<OGCFeatureItems>> itemsPaged(BoundedItemsQuery query) async {
    // read "collections/{collectionId}/items" and return as paged response

    // form a query url
    final limit = query.limit;
    final crs = query.crs;
    final bboxCrs = query.boundsCrs;
    final bbox = query.bounds?.valuesAsString();
    final datetime = query.timeFrame?.toString();
    var params = <String, String>{
      //'f': 'json',
      if (limit != null) 'limit': limit.toString(),
      if (crs != null) 'crs': crs,
      if (bboxCrs != null) 'bbox-crs': bboxCrs,
      if (bbox != null) 'bbox': bbox,
      if (datetime != null) 'datetime': datetime,
    };
    if (query.extraParams != null) {
      params = Map.of(query.extraParams!)..addAll(params);
    }

    // read from client and return paged feature collection response
    return _OGCPagedFeaturesItems.parse(
      service,
      service.endpoint.resolveUri(
        Uri(
          path: 'collections/$collectionId/items',
          queryParameters: params,
        ),
      ),
    );
  }
}

class _OGCPagedFeaturesItems with Paged<OGCFeatureItems> {
  _OGCPagedFeaturesItems(
    this.service,
    this.features, {
    this.nextURL,
    this.prevURL,
  });

  final _OGCFeatureClientHttp service;
  final OGCFeatureItems features;
  final Uri? nextURL;
  final Uri? prevURL;

  static Future<_OGCPagedFeaturesItems> parse(
    _OGCFeatureClientHttp service,
    Uri url,
  ) async {
    // fetch data as JSON Object and parse paged response
    return service.adapter.getEntityFromJsonObject(
      url,
      headers: _acceptGeoJSON,
      expect: _expectGeoJSON,
      toEntity: (data) {
        // check JSON Object for optional "next" and "prev" links
        Uri? nextURL;
        Uri? prevURL;
        final links = data['links'];
        if (links is Iterable<Object?>) {
          final parsedLinks = Links.fromData(links);
          final next = parsedLinks.next(type: _nextAndPrevLinkType);
          nextURL = next.isNotEmpty ? next.first.href : null;
          final prev = parsedLinks.prev(type: _nextAndPrevLinkType);
          prevURL = prev.isNotEmpty ? prev.first.href : null;
        }

        // todo : should allow other geojson parsers / point types too

        // parses FeatureCollection object from GeoJSON data using the
        // parser of `geocore`
        final collection = service.parser.featureCollection(data);

        // meta as Map<String, Object?> by removing features
        final meta = Map.of(data)..remove('features');

        // parse feature items (meta + actual features), return a paged result
        return _OGCPagedFeaturesItems(
          service,
          OGCFeatureItems(collection, meta: Map.unmodifiable(meta)),
          nextURL: nextURL,
          prevURL: prevURL,
        );
      },
    );
  }

  @override
  OGCFeatureItems get current => features;

  @override
  bool get hasNext => nextURL != null;

  @override
  Future<Paged<OGCFeatureItems>?> next() async {
    final url = nextURL;
    if (url != null) {
      // read data from nextURL and return as paged response
      return _OGCPagedFeaturesItems.parse(
        service,
        url,
      );
    } else {
      return null;
    }
  }

  @override
  bool get hasPrevious => prevURL != null;

  @override
  Future<Paged<OGCFeatureItems>?> previous() async {
    final url = prevURL;
    if (url != null) {
      // read data from prevURL and return as paged response
      return _OGCPagedFeaturesItems.parse(
        service,
        url,
      );
    } else {
      return null;
    }
  }
}

/// Parses a '/collections/{collectionId}' meta data from a OGC API service.
CollectionMeta _collectionFromData(Map<String, Object?> data) {
  final links = Links.fromData(data['links']! as Iterable<Object?>);
  final extent = data['extent'] as Map<String, Object?>?;
  final id = data['id'] as String? ??
      data['name']! as String; // "name" not really standard, but somewhere used
  return CollectionMeta(
    id: id,
    title: data['title'] as String? ?? links.self().first.title ?? id,
    description: data['description'] as String?,
    links: links,
    extent: extent != null ? _extentFromData(extent) : null,
  );
}

/// Parses [Extent] data structure from a json snippet.
Extent _extentFromData(Map<String, Object?> data) {
  final spatial = data['spatial'];
  final spatialIsMap = spatial is Map<String, Object?>;
  final crs = (spatialIsMap ? spatial['crs'] as String? : null) ??
      'http://www.opengis.net/def/crs/OGC/1.3/CRS84';

  // try to parse bboxes
  Iterable<GeoBounds> allBounds;
  final bbox = spatialIsMap ? spatial['bbox'] as Iterable<Object?>? : null;
  if (bbox != null) {
    // by standard: "bbox" is a list of bboxes
    allBounds = bbox.map(
      (dynamic e) => GeoBounds.from((e as Iterable<Object?>).cast<num>()),
    );
  } else {
    // not standard: assume "spatial" as one bbox
    try {
      allBounds = [GeoBounds.from((spatial! as Iterable<Object?>).cast<num>())];
    } catch (_) {
      // fallback
      allBounds = [GeoBounds.world()];
    }
  }

  // try to parse temporal intervals
  Iterable<Interval>? allIntervals;
  final temporal = data['temporal'];
  if (temporal != null) {
    final interval =
        temporal is Map<String, Object?> ? temporal['interval'] : null;
    if (interval != null && interval is Iterable<Object?>) {
      // by standard: "interval" is a list of intervals
      allIntervals =
          interval.map((e) => Interval.fromData(e! as Iterable<Object?>));
    } else {
      // not standard: assume "temporal" as one interval
      try {
        allIntervals = [Interval.fromData(temporal as Iterable<Object?>)];
      } catch (_) {
        // no fallback need, just no temporal interval then
      }
    }
  }

  // combine to Extent
  if (allIntervals != null) {
    return Extent.multi(
      crs: crs,
      allBounds: allBounds,
      allIntervals: allIntervals,
    );
  } else {
    return Extent.multi(crs: crs, allBounds: allBounds);
  }
}
