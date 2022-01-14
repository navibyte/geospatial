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
///
/// An optional [parser] argument specifies a GeoJSON parser. If not given then
/// `geoJsonGeographic(geographicPoints)` defined by the
/// `package:geocore/parse.dart` package is used as a default. When excpecting
/// cartesian or projected coordinates, you might want to use
/// `geoJsonCartesian(cartesianPoints)` as a parser. Or if expecting specific
/// type of points, you could also use a factory like
/// `geoJson(Point3.coordinates)`.
BasicFeatureSource geoJsonHttpClient({
  required Uri location,
  http.Client? client,
  Map<String, String>? headers,
  GeoJsonFactory? parser,
}) =>
    _GeoJSONFeatureSource(
      location,
      adapter: FeatureHttpAdapter(
        client: client,
        headers: headers,
      ),
      parser: parser ?? geoJsonGeographic(geographicPoints),
    );

/// A client for accessing a `GeoJSON` feature collection from [source];
///
/// The source function returns a future that fetches data from a file, a web
/// resource or other sources. Contents must be GeoJSON compliant data.
///
/// An optional [parser] argument specifies a GeoJSON parser. If not given then
/// `geoJsonGeographic(geographicPoints)` defined by the
/// `package:geocore/parse.dart` package is used as a default. When excpecting
/// cartesian or projected coordinates, you might want to use
/// `geoJsonCartesian(cartesianPoints)` as a parser. Or if expecting specific
/// type of points, you could also use a factory like
/// `geoJson(Point3.coordinates)`.
BasicFeatureSource geoJsonFutureClient(
  Future<String> Function() source, {
  GeoJsonFactory? parser,
}) =>
    _GeoJSONFeatureSource(
      source,
      parser: parser ?? geoJsonGeographic(geographicPoints),
    );

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

class _GeoJSONFeatureSource implements BasicFeatureSource {
  const _GeoJSONFeatureSource(
    this.source, {
    this.adapter,
    required this.parser,
  });

  // source can be
  //    `Uri` (a location for a web resource)
  //    `Future<String> Function()` (for any async resource like file)
  final Object source;

  // todo: final String sourceCrs;

  // for a web resource adapter must be set
  final FeatureHttpAdapter? adapter;

  final GeoJsonFactory parser;

  @override
  Future<FeatureItem> item(BasicFeatureItemQuery query) async {
    // get items as paged response
    Paged<FeatureItems>? page = await itemsAllPaged(
      query: BasicFeatureItemsQuery(
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
  Future<FeatureItems> itemsAll({BasicFeatureItemsQuery? query}) async =>
      (await itemsAllPaged(query: query)).current;

  @override
  Future<Paged<FeatureItems>> itemsAllPaged({BasicFeatureItemsQuery? query}) {
    final src = source;

    // fetch data as JSON Object + parse GeoJSON feature or feature collection
    if (src is Uri) {
      // read web resource and convert to entity
      return adapter!.getEntityFromJsonObject(
        src,
        toEntity: (data) => _parseFeatureItems(query, data, parser),
      );
    } else if (src is Future<String> Function()) {
      // read a future returned by a function
      return readEntityFromJsonObject(
        src,
        toEntity: (data) => _parseFeatureItems(query, data, parser),
      );
    }

    // not valid implementation (actually this should not occur)
    throw UnimplementedError('Data source for GeoJSON not implemented.');
  }
}

_GeoJSONPagedFeaturesItems _parseFeatureItems(
  BasicFeatureItemsQuery? query,
  Map<String, Object?> data,
  GeoJsonFactory parser,
) {
  final count = parser.featureCount(data);

  // analyze if only a first set or all items should be returned
  final Range? range;
  if (query != null && query.limit != null) {
    // first set
    range = Range(start: 0, limit: query.limit);
  } else {
    // no limit => all features
    range = null;
  }

  // return as paged collection (paging through already fetched data)
  return _GeoJSONPagedFeaturesItems.parse(parser, data, count, range);
}

class _GeoJSONPagedFeaturesItems with Paged<FeatureItems> {
  _GeoJSONPagedFeaturesItems(
    this.parser,
    this.features,
    this.count, [
    this.data,
    this.nextRange,
  ]);

  factory _GeoJSONPagedFeaturesItems.parse(
    GeoJsonFactory parser,
    Map<String, Object?> data,
    int count,
    Range? range,
  ) {
    // parse feature items for the range and
    final collection = parser.featureCollection(data, range: range);
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
        ? _GeoJSONPagedFeaturesItems(parser, items, count, data, nextRange)
        : _GeoJSONPagedFeaturesItems(
            parser,
            items,
            count,
          );
  }

  final GeoJsonFactory parser;
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
    return _GeoJSONPagedFeaturesItems.parse(parser, data!, count, nextRange);
  }
}
