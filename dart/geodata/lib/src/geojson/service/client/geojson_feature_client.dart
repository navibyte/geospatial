// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geocore/parse.dart';
import 'package:http/http.dart' as http;

import '/src/common/paged.dart';
import '/src/core/features.dart';
import '/src/utils/features.dart';

/// A client for accessing a `GeoJSON` data resource at [location] via http(s).
///
/// The required [location] should refer to a web resource containing GeoJSON
/// compliant data.
///
/// When given the optional [client] is used for http requests, otherwise the
/// default client of the `package:http/http.dart` package is used.
///
/// When given [headers] are injected to http requests (however some can be
/// overridden by the feature source implementation).
FeatureSource geoJsonHttpClient({
  required Uri location,
  http.Client? client,
  Map<String, String>? headers,
}) =>
    _GeoJSONFeatureSource(
      location,
      adapter: FeatureHttpAdapter(
        client: client,
        headers: headers,
      ),
    );

/// A client for accessing a `GeoJSON` feature collection from [source];
///
/// The source function returns a future that fetches data from a file, a web
/// resource or other sources. Contents must be GeoJSON compliant data.
FeatureSource geoJsonFutureClient(Future<String> Function() source) =>
    _GeoJSONFeatureSource(source);

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

class _GeoJSONFeatureSource implements FeatureSource {
  const _GeoJSONFeatureSource(this.source, {this.adapter});

  // source can be
  //    `Uri` (a location for a web resource)
  //    `Future<String> Function()` (for any async resource like file)
  final Object source;

  // todo: final String sourceCrs;

  // for a web resource adapter must be set
  final FeatureHttpAdapter? adapter;

  @override
  Future<FeatureItem> item(FeatureItemQuery query) async {
    // get items as paged response
    Paged<FeatureItems>? page = await itemsPaged(
      FeatureItemsQuery(
        crs: query.crs,
        extraParams: query.extraParams,
      ),
    );

    // loop through pages
    while (page != null) {
      // get items from current page
      final items = page.current;

      // loop through features in a returned collection to find a feature by id
      final collection = items.collection;
      for (final f in collection.features) {
        if (f.id == query.id) {
          // found one, so return it
          return FeatureItem(f);
        }
      }

      // check if there exists a next page
      page = await page.next();
    }

    // did not find a feature by id
    throw const FeatureException(FeatureFailure.notFound);
  }

  @override
  Future<FeatureItems> items(FeatureItemsQuery query) async =>
      (await itemsPaged(query)).current;

  @override
  Future<Paged<FeatureItems>> itemsPaged(FeatureItemsQuery query) {
    final src = source;

    // fetch data as JSON Object + parse GeoJSON feature or feature collection
    if (src is Uri) {
      // read web resource and convert to entity
      return adapter!.getEntityFromJsonObject(
        src,
        toEntity: (data) => _parseFeatureItems(query, data),
      );
    } else if (src is Future<String> Function()) {
      // read a future returned by a function
      return readEntityFromJsonObject(
        src,
        toEntity: (data) => _parseFeatureItems(query, data),
      );
    }

    // not valid implementation (actually this should not occur)
    throw UnimplementedError('Data source for GeoJSON not implemented.');
  }
}

_GeoJSONPagedFeaturesItems _parseFeatureItems(
  FeatureItemsQuery query,
  Map<String, Object?> data,
) {
  final count = geoJSON.featureCount(data);

  // analyze if only a first set or all items should be returned
  final Range? range;
  if (query.limit != null) {
    // first set
    range = Range(start: 0, limit: query.limit);
  } else {
    // no limit => all features
    range = null;
  }

  // todo:  filter data using query params (crs, boundsCrs, bounds, limit)

  // return as paged collection (paging through already fetched data)
  return _GeoJSONPagedFeaturesItems.parse(data, count, range);
}

class _GeoJSONPagedFeaturesItems with Paged<FeatureItems> {
  _GeoJSONPagedFeaturesItems(
    this.features,
    this.count, [
    this.data,
    this.nextRange,
  ]);

  factory _GeoJSONPagedFeaturesItems.parse(
    Map<String, Object?> data,
    int count,
    Range? range,
  ) {
    // parse feature items for the range and
    final collection = geoJSON.featureCollection(data, range: range);
    final items = FeatureItems(
      collection,
    );

    // check if there is next range after current one just parsed
    Range? nextRange;
    if (range != null) {
      final limit = range.limit;
      if (limit != null) {
        final nextStart = range.start + items.collection.features.length;
        if (nextStart < count) {
          nextRange = Range(start: nextStart, limit: limit);
        }
      }
    }

    // return a paged result either with ref to next range or without
    return nextRange != null
        ? _GeoJSONPagedFeaturesItems(items, count, data, nextRange)
        : _GeoJSONPagedFeaturesItems(
            items,
            count,
          );
  }

  final FeatureItems features;
  final int count;

  final Map<String, Object?>? data;
  final Range? nextRange;

  @override
  FeatureItems get current => features;

  @override
  bool get hasNext => !(nextRange == null || data == null);

  @override
  Future<Paged<FeatureItems>?> next() async {
    if (nextRange == null || data == null) {
      return null;
    }
    return _GeoJSONPagedFeaturesItems.parse(data!, count, nextRange);
  }
}
