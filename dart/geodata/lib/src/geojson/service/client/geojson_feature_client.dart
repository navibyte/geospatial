// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';
import 'package:http/http.dart';

import '/src/common/paged/paged.dart';
import '/src/common/service/service_exception.dart';
import '/src/core/features/basic_feature_source.dart';
import '/src/core/features/feature_failure.dart';
import '/src/core/features/feature_item.dart';
import '/src/core/features/feature_items.dart';
import '/src/utils/feature_future_adapter.dart';
import '/src/utils/feature_http_adapter.dart';

/// A class with static factory methods to create feature sources conforming to
/// the GeoJSON format.
class GeoJSONFeatures {
  /// A client for accessing a `GeoJSON` data resource at [location] via http(s)
  /// conforming to [format].
  ///
  /// The required [location] should refer to a web resource containing GeoJSON
  /// compliant data.
  ///
  /// When given an optional [client] is used for http requests, otherwise the
  /// default client of the `package:http/http.dart` package is used (a new
  /// instance of default client for each service request). When [client] is
  /// given, this allows a client to better maintain persistent connections to a
  /// service, but it's also responsibility of a caller to close it
  /// appropriately.
  ///
  /// When given [headers] are injected to http requests (however some can be
  /// overridden by the feature source implementation).
  ///
  /// When [format] is not given, then [GeoJSON] with default settings is used
  /// as a default. Note that currently only GeoJSON is supported, but it's
  /// possible to inject another format implementation (or with custom
  /// configuration) to the default one.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  static BasicFeatureSource http({
    required Uri location,
    Client? client,
    Map<String, String>? headers,
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
    CoordRefSys? crs,
  }) =>
      _GeoJSONFeatureSource(
        location,
        adapter: FeatureHttpAdapter(
          client: client,
          headers: headers,
        ),
        format: format,
        crs: crs,
      );

  /// A client for accessing a `GeoJSON` feature collection from any [source];
  ///
  /// The source function returns a future that fetches data from a file, a web
  /// resource or other sources. Contents must be GeoJSON compliant data.
  ///
  /// When [format] is not given, then [GeoJSON] with default settings is used
  /// as a default. Note that currently only GeoJSON is supported, but it's
  /// possible to inject another format implementation (or with custom
  /// configuration) to the default one.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  static BasicFeatureSource any(
    Future<String> Function() source, {
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
    CoordRefSys? crs,
  }) =>
      _GeoJSONFeatureSource(
        source,
        format: format,
        crs: crs,
      );
}

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

class _GeoJSONFeatureSource implements BasicFeatureSource {
  const _GeoJSONFeatureSource(
    this.source, {
    this.adapter,
    required this.format,
    this.crs,
  });

  // source can be
  //    `Uri` (a location for a web resource)
  //    `Future<String> Function()` (for any async resource like file)
  final Object source;

  // for a web resource adapter must be set
  final FeatureHttpAdapter? adapter;

  final TextReaderFormat<FeatureContent> format;

  final CoordRefSys? crs;

  @override
  Future<FeatureItem> itemById(Object id) async {
    // get items as paged response
    Paged<FeatureItems>? page = await itemsAllPaged();

    // loop through pages
    while (page != null) {
      // get items from current page
      final items = page.current;

      // loop through features in a returned collection to find a feature by id
      final collection = items.collection;
      for (final f in collection.features) {
        if (f.id == id) {
          // found one, so return it
          return FeatureItem(f);
        }
      }

      // check if there exists a next page
      page = await page.next();
    }

    // did not find a feature by id
    throw const ServiceException(FeatureFailure.notFound);
  }

  @override
  Future<FeatureItems> itemsAll({int? limit}) async =>
      (await itemsAllPaged(limit: limit)).current;

  @override
  Future<Paged<FeatureItems>> itemsAllPaged({int? limit}) {
    final src = source;

    // fetch data as JSON Object + parse GeoJSON feature or feature collection
    if (src is Uri) {
      // read web resource and convert to entity
      return adapter!.getEntityFromJsonObject(
        src,
        toEntity: (data, _) => _parseFeatureItems(limit, data, format, crs),
      );
    } else if (src is Future<String> Function()) {
      // read a future returned by a function
      return readEntityFromJsonObject(
        src,
        toEntity: (data) => _parseFeatureItems(limit, data, format, crs),
      );
    }

    // not valid implementation (actually this should not occur)
    throw UnimplementedError('Data source for GeoJSON not implemented.');
  }
}

_GeoJSONPagedFeaturesItems _parseFeatureItems(
  int? limit,
  Map<String, dynamic> data,
  TextReaderFormat<FeatureContent> format,
  CoordRefSys? crs,
) {
  // NOTE: get count without actually parsing the whole feature collection

  // get the whole collection to get count
  final collection = FeatureCollection.fromData(data, format: format, crs: crs);
  final count = collection.features.length;

  // analyze if only a first set or all items should be returned
  final _Range? range;
  if (limit != null) {
    // first set
    range = _Range(start: 0, limit: limit);
  } else {
    // no limit => all features
    range = null;
  }

  // return as paged collection (paging through already fetched data)
  return _GeoJSONPagedFeaturesItems.parse(format, crs, data, count, range);
}

class _GeoJSONPagedFeaturesItems with Paged<FeatureItems> {
  const _GeoJSONPagedFeaturesItems(
    this.format,
    this.crs,
    this.features,
    this.count, [
    this.data,
    this.nextRange,
  ]);

  factory _GeoJSONPagedFeaturesItems.parse(
    TextReaderFormat<FeatureContent> format,
    CoordRefSys? crs,
    Map<String, dynamic> data,
    int count,
    _Range? range,
  ) {
    // parse feature items for the range and
    final collection = FeatureCollection.fromData(
      data,
      format: format,
      crs: crs,
      options: range != null
          ? {'itemOffset': range.start, 'itemLimit': range.limit}
          : null,
    );
    final items = FeatureItems(
      collection,
    );

    // check if there is next range after current one just parsed
    _Range? nextRange;
    if (range != null) {
      final limit = range.limit;
      if (limit != null) {
        final nextStart = range.start + items.collection.features.length;
        if (nextStart < count) {
          nextRange = _Range(start: nextStart, limit: limit);
        }
      }
    }

    // return a paged result either with ref to next range or without
    return nextRange != null
        ? _GeoJSONPagedFeaturesItems(format, crs, items, count, data, nextRange)
        : _GeoJSONPagedFeaturesItems(format, crs, items, count);
  }

  final TextReaderFormat<FeatureContent> format;
  final CoordRefSys? crs;

  final FeatureItems features;
  final int count;

  final Map<String, dynamic>? data;
  final _Range? nextRange;

  @override
  FeatureItems get current => features;

  @override
  bool get hasNext => !(nextRange == null || data == null);

  @override
  Future<Paged<FeatureItems>?> next() async {
    if (nextRange == null || data == null) {
      return null;
    }
    return _GeoJSONPagedFeaturesItems.parse(
      format,
      crs,
      data!,
      count,
      nextRange,
    );
  }
}

class _Range {
  /// A new range definition with [start] (>= 0) and optional positive [limit].
  const _Range({required this.start, this.limit})
      : assert(start >= 0, 'Start index must be >= 0.'),
        assert(limit == null || limit >= 0, 'Limit must be null or >= 0.');

  /// The index to specify the first item (by index) of the range.
  final int start;

  /// An optional [limit] setting maximum number of items for the range.
  ///
  /// If null, then the range contains all items starting from [start].
  final int? limit;
}
