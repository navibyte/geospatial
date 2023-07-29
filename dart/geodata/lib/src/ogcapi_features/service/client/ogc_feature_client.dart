// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/coordinates.dart';
import 'package:geobase/meta.dart';
import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';
import 'package:http/http.dart';

import '/src/common/links/links.dart';
import '/src/common/paged/paged.dart';
import '/src/common/service/service_exception.dart';
import '/src/core/data/bounded_items_query.dart';
import '/src/core/data/item_query.dart';
import '/src/ogcapi_common/model/ogc_collection_meta.dart';
import '/src/ogcapi_common/service/client/ogc_client.dart';
import '/src/ogcapi_features/model/ogc_feature_conformance.dart';
import '/src/ogcapi_features/model/ogc_feature_item.dart';
import '/src/ogcapi_features/model/ogc_feature_items.dart';
import '/src/ogcapi_features/model/ogc_feature_service.dart';
import '/src/ogcapi_features/model/ogc_feature_source.dart';
import '/src/utils/feature_http_adapter.dart';
import '/src/utils/resolve_api_call.dart';

/// A class with static factory methods to create feature sources conforming to
/// the OGC API Features standard.
class OGCAPIFeatures {
  /// A client for accessing `OGC API Features` compliant sources via http(s)
  /// conforming to [format].
  ///
  /// The required [endpoint] should refer to a base url of a feature service.
  ///
  /// When given the optional [client] is used for http requests, otherwise the
  /// default client of the `package:http/http.dart` package is used.
  ///
  /// When given [headers] are injected to http requests as http headers
  /// (however some can be overridden by the feature service implementation).
  ///
  /// When given [extraParams] are injected to query part of http requests
  /// (however some can be overridden by the feature service implementation).
  ///
  /// When [format] is not given, then [GeoJSON] with default settings is used
  /// as a default. Note that currently only GeoJSON is supported, but it's
  /// possible to inject another format implementation (or with custom
  /// configuration) to the default one.
  static OGCFeatureService http({
    required Uri endpoint,
    Client? client,
    Map<String, String>? headers,
    Map<String, String>? extraParams,
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
  }) =>
      _OGCFeatureClientHttp(
        endpoint,
        adapter: FeatureHttpAdapter(
          client: client,
          headers: headers,
          extraParams: extraParams,
        ),
        format: format,
      );
}

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

// collection items of geospatial features (actual data)
const _acceptGeoJSON = {'accept': 'application/geo+json'};
const _expectGeoJSON = ['application/geo+json', 'application/json'];
const _nextAndPrevLinkType = 'application/geo+json';

/// A client for accessing `OGC API Features` compliant sources via http(s).
class _OGCFeatureClientHttp extends OGCClientHttp implements OGCFeatureService {
  const _OGCFeatureClientHttp(
    super.endpoint, {
    required super.adapter,
    required this.format,
  });

  final TextReaderFormat<FeatureContent> format;

  @override
  Future<OGCFeatureSource> collection(String id) =>
      Future.value(_OGCFeatureSourceHttp(this, id));

  @override
  Future<OGCFeatureConformance> conformance() async {
    // fetch data as JSON Object, and parse conformance classes
    final url = resolveSubResource(endpoint, 'conformance');
    return adapter.getEntityFromJson(
      url,
      toEntity: (data, _) {
        if (data is Map<String, dynamic>) {
          // standard: root has JSON Object with "conformsTo" containing classes
          return OGCFeatureConformance(
            (data['conformsTo'] as Iterable<dynamic>?)?.cast<String>() ?? [],
          );
        } else if (data is Iterable<dynamic>) {
          // NOT STANDARD: root has JSON Array containing conformance classes
          return OGCFeatureConformance(data.cast<String>());
        }
        throw const ServiceException('Could not parse conformance classes');
      },
    );
  }

  @override
  Future<Iterable<OGCCollectionMeta>> collections() async {
    // fetch data as JSON Object, and parse conformance classes
    final url = resolveSubResource(endpoint, 'collections');
    return adapter.getEntityFromJsonObject(
      url,
      toEntity: (data, _) {
        // global crs identifiers supported by all collection that refer to them
        final globalCrs = (data['crs'] as Iterable<dynamic>?)?.cast<String>();

        // get collections and parse each of them as `OGCCollectionMeta`
        final list = data['collections'] as Iterable<dynamic>;
        return list
            .map<OGCCollectionMeta>(
              (e) => _collectionFromJson(
                e as Map<String, dynamic>,
                globalCrs: globalCrs,
              ),
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
  Future<OGCCollectionMeta> meta() async {
    // read "collections/{collectionId}

    final url =
        resolveSubResource(service.endpoint, 'collections/$collectionId');
    return service.adapter.getEntityFromJsonObject(
      url,
      toEntity: (data, _) {
        // data should contain a single collection as JSON Object
        // but some services seem to return this under "collections"...
        final collections = data['collections'];
        if (collections is Iterable<dynamic>) {
          for (final coll in collections) {
            final collObj = coll as Map<String, dynamic>;
            if (collObj['id'] == collectionId) {
              return _collectionFromJson(collObj);
            }
          }
        }

        // this is the way the standard suggests
        // (single collection meta as JSON object)
        return _collectionFromJson(data);
      },
    );
  }

  @override
  Future<OGCFeatureItem> itemById(Object id) => item(ItemQuery(id: id));

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
      if (crs != null) 'crs': crs.toString(),
    };
    if (query.extraParams != null) {
      params = Map.of(query.extraParams!)..addAll(params);
    }
    final url = resolveSubResourceUri(
      service.endpoint,
      Uri(
        path: 'collections/$collectionId/items/${query.id}',
        queryParameters: params,
      ),
    );

    // fetch data as JSON Object, and parse a feature and meta data
    return service.adapter.getEntityFromJsonObject(
      url,
      toEntity: (data, headers) {
        // whether there is a non-default (other than WGS84 lon-lat) query crs
        final isDefaultCrs =
            query.crs?.isGeographic(wgs84: true, order: AxisOrder.xy) ?? true;
        final queryCrs = isDefaultCrs ? null : query.crs;

        // get crs from "Content-Crs" header
        final contentCrs = _parseContentCrs(headers);

        // parses Feature object from GeoJSON data decoded using format
        final feature = Feature.fromData(
          data,
          format: service.format,

          // if crs suggest y-x (or lat-lon) order then fromData swaps x and y
          crs: contentCrs ?? queryCrs,
        );

        // meta as Map<String, dynamic> by removing Feature geometry and props
        final meta = Map.of(data)
          ..remove('type')
          ..remove('id')
          ..remove('geometry')
          ..remove('properties');

        return OGCFeatureItem(
          feature,
          meta: meta.isNotEmpty ? Map.unmodifiable(meta) : null,
          contentCrs: contentCrs,
        );
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
    final bboxCrs = query.bboxCrs;
    final bbox = query.bbox?.toText(swapXY: bboxCrs?.swapXY ?? false);
    final datetime = query.timeFrame?.toString();
    var params = <String, String>{
      //'f': 'json',
      if (limit != null) 'limit': limit.toString(),
      if (crs != null) 'crs': crs.toString(),
      if (bboxCrs != null) 'bbox-crs': bboxCrs.toString(),
      if (bbox != null) 'bbox': bbox,
      if (datetime != null) 'datetime': datetime,
    };
    if (query.extraParams != null) {
      params = Map.of(query.extraParams!)..addAll(params);
    }

    /*
    print(resolveSubResourcelUri(service.endpoint,
        Uri(
          path: 'collections/$collectionId/items',
          queryParameters: params,
        ),
      ));
    */

    // read from client and return paged feature collection response
    return _OGCPagedFeaturesItems.parse(
      service,
      query,
      resolveSubResourceUri(
        service.endpoint,
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
    this.query,
    this.features, {
    this.nextURL,
    this.prevURL,
  });

  final _OGCFeatureClientHttp service;
  final BoundedItemsQuery query;
  final OGCFeatureItems features;
  final Uri? nextURL;
  final Uri? prevURL;

  static Future<_OGCPagedFeaturesItems> parse(
    _OGCFeatureClientHttp service,
    BoundedItemsQuery query,
    Uri url,
  ) async {
    // fetch data as JSON Object and parse paged response
    return service.adapter.getEntityFromJsonObject(
      url,
      headers: _acceptGeoJSON,
      expect: _expectGeoJSON,
      toEntity: (data, headers) {
        // check JSON Object for optional "next" and "prev" links
        Uri? nextURL;
        Uri? prevURL;
        final links = data['links'];
        if (links is Iterable<dynamic>) {
          final parsedLinks = Links.fromJson(links);
          final next = parsedLinks.next(type: _nextAndPrevLinkType);
          nextURL = next.isNotEmpty
              ? resolveLinkReferenceUri(service.endpoint, next.first.href)
              : null;
          final prev = parsedLinks.prev(type: _nextAndPrevLinkType);
          prevURL = prev.isNotEmpty
              ? resolveLinkReferenceUri(service.endpoint, prev.first.href)
              : null;
        }

        // whether there is a non-default (other than WGS84 lon-lat) query crs
        final isDefaultCrs =
            query.crs?.isGeographic(wgs84: true, order: AxisOrder.xy) ?? true;
        final queryCrs = isDefaultCrs ? null : query.crs;

        // get crs from "Content-Crs" header
        final contentCrs = _parseContentCrs(headers);

        // parses Feature collection from GeoJSON data decoded using format
        final collection = FeatureCollection.fromData(
          data,
          format: service.format,

          // if crs suggest y-x (or lat-lon) order then fromData swaps x and y
          crs: contentCrs ?? queryCrs,
        );

        // meta as Map<String, dynamic> by removing features
        final meta = Map.of(data)
          ..remove('type')
          ..remove('features');

        // parse feature items (meta + actual features), return a paged result
        return _OGCPagedFeaturesItems(
          service,
          query,
          OGCFeatureItems(
            collection,
            meta: meta.isNotEmpty ? Map.unmodifiable(meta) : null,
            contentCrs: contentCrs,
          ),
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
        query,
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
        query,
        url,
      );
    } else {
      return null;
    }
  }
}

/// Parses a '/collections/{collectionId}' meta data from a OGC API service.
OGCCollectionMeta _collectionFromJson(
  Map<String, dynamic> data, {
  Iterable<String>? globalCrs,
}) {
  // get basic properties
  final links = Links.fromJson(data['links'] as Iterable<dynamic>);
  final extentObject = data['extent'] as Map<String, dynamic>?;
  final extent = extentObject != null ? _extentFromJson(extentObject) : null;
  final id = data['id'] as String? ??
      data['name'] as String; // "name" not really standard, but somewhere used
  final title = data['title'] as String? ?? links.self().first.title ?? id;
  final description = data['description'] as String?;
  final attribution = data['attribution'] as String?;

  // Resolve supported ids from optional global and collection specific ids.
  // See the section 6.2 of the standard
  // `OGC API - Features - Part 2: Coordinate Reference Systems by Reference`.
  final Iterable<String>? supportedCrs;
  final collectionCrs = (data['crs'] as Iterable<dynamic>?)?.cast<String>();
  if (collectionCrs != null) {
    if (globalCrs != null) {
      if (collectionCrs.contains('#/crs')) {
        // collection has json pointer to global crs, so combine without pointer
        // (remove also any duplicates)
        final seen = <String>{};
        supportedCrs = globalCrs.followedBy(
          collectionCrs.where((crs) => crs != '#/crs' && seen.add(crs)),
        );
      } else {
        supportedCrs = collectionCrs;
      }
    } else {
      supportedCrs = collectionCrs;
    }
  } else {
    supportedCrs = globalCrs;
  }

  // storage crs
  final storageCrs = data['storageCrs'] as String?;
  final storageCoordRefSys =
      storageCrs != null ? CoordRefSys.normalized(storageCrs) : null;
  final storageCrsCoordinateEpoch = data['storageCrsCoordinateEpoch'] as num?;

  // return as collection meta object
  if (supportedCrs != null) {
    return OGCCollectionMeta(
      id: id,
      title: title,
      description: description,
      attribution: attribution,
      links: links,
      extent: extent,
      //itemType: 'feature', // no need to specify default
      crs: supportedCrs.map(CoordRefSys.normalized).toList(growable: false),
      storageCrs: storageCoordRefSys,
      storageCrsCoordinateEpoch: storageCrsCoordinateEpoch,
    );
  } else {
    return OGCCollectionMeta(
      id: id,
      title: title,
      description: description,
      attribution: attribution,
      links: links,
      extent: extent,
      //itemType: 'feature', // no need to specify default
      storageCrs: storageCoordRefSys,
      storageCrsCoordinateEpoch: storageCrsCoordinateEpoch,
    );
  }
}

/// Parses [GeoExtent] data structure from a json snippet.
GeoExtent _extentFromJson(Map<String, dynamic> data) {
  final spatial = data['spatial'];
  final spatialIsMap = spatial is Map<String, dynamic>;
  final crs = (spatialIsMap ? spatial['crs'] as String? : null) ??
      'http://www.opengis.net/def/crs/OGC/1.3/CRS84';

  // try to parse bboxes
  SpatialExtent<GeoBox> spatialExtent;
  final bbox = spatialIsMap ? spatial['bbox'] as Iterable<dynamic>? : null;
  if (bbox != null) {
    // by standard: "bbox" is a list of bboxes
    spatialExtent = SpatialExtent.multi(
      bbox.map((e) => _bboxFromJson(e! as List<dynamic>)),
      crs: crs,
    );
  } else {
    // not standard: assume "spatial" as one bbox
    try {
      spatialExtent =
          SpatialExtent.single(_bboxFromJson(spatial! as List<dynamic>));
    } catch (_) {
      // fallback (world extent)
      spatialExtent = const SpatialExtent(
        GeoBox(west: -180.0, south: -90.0, east: 180.0, north: 90.0),
      );
    }
  }

  // try to parse temporal intervals
  TemporalExtent? temporalExtent;
  final temporal = data['temporal'];
  if (temporal != null) {
    final interval =
        temporal is Map<String, dynamic> ? temporal['interval'] : null;
    if (interval != null && interval is Iterable<dynamic>) {
      // by standard: "interval" is a list of intervals
      temporalExtent = TemporalExtent.multi(
        interval.map((e) => Interval.fromJson(e as Iterable<dynamic>)),
      );
    } else {
      // not standard: assume "temporal" as one interval
      try {
        temporalExtent = TemporalExtent.single(
          Interval.fromJson(temporal as Iterable<dynamic>),
        );
      } catch (_) {
        // no fallback need, just no temporal interval then
      }
    }
  }

  return GeoExtent(
    spatial: spatialExtent,
    temporal: temporalExtent,
  );
}

GeoBox _bboxFromJson(List<dynamic> bbox) {
  if (bbox.length == 4 || bbox.length == 6) {
    final is3D = bbox.length == 6;
    return is3D
        ? GeoBox(
            west: _parseDouble(bbox[0]),
            south: _parseDouble(bbox[1]),
            minElev: _parseDouble(bbox[2]),
            east: _parseDouble(bbox[3]),
            north: _parseDouble(bbox[4]),
            maxElev: _parseDouble(bbox[5]),
          )
        : GeoBox(
            west: _parseDouble(bbox[0]),
            south: _parseDouble(bbox[1]),
            east: _parseDouble(bbox[2]),
            north: _parseDouble(bbox[3]),
          );
  }
  throw const FormatException('Cannot parse bbox');
}

double _parseDouble(Object? data) {
  if (data != null) {
    if (data is num) {
      return data.toDouble();
    } else if (data is String) {
      return double.parse(data);
    }
  }
  throw FormatException('Cannot parse $data to double');
}

CoordRefSys? _parseContentCrs(Map<String, String> headers) {
  // According to OGC API Features - Part 2 (CRS) response header example:
  //    Content-Crs: <http://www.opengis.net/def/crs/EPSG/0/4258>

  final header = headers['content-crs']; // lowercase for getting headers!
  if (header != null &&
      header.length > 3 &&
      header.startsWith('<') &&
      header.endsWith('>')) {
    final contentCrs = CoordRefSys.normalized(
      header.substring(1, header.length - 1),
    );
    return contentCrs;
  }
  return null;
}
