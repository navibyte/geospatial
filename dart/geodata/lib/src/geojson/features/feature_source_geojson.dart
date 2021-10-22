// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:datatools/fetch_api.dart';
import 'package:geocore/parse_factory.dart';
import 'package:geocore/parse_geojson.dart';

import 'package:meta/meta.dart';

import '../../api/common.dart';
import '../../api/features.dart';

/// A feature source providing GeoJSON data from resources like web or files.
class FeatureSourceGeoJSON implements FeatureSource {
  FeatureSourceGeoJSON._(this.client, this._meta);

  /// Create a feature source providing GeoJSON using [client] and metadata.
  factory FeatureSourceGeoJSON.of({
    required Fetcher client,
    required DataSourceMeta meta,
  }) =>
      FeatureSourceGeoJSON._(client, meta);

  final DataSourceMeta _meta;

  /// The [client] to fetch data from resources like web or files.
  @protected
  final Fetcher client;

  @override
  Future<DataSourceMeta> meta() async => _meta;

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
    // read "{collectionId}", parse JSON and get number of features
    final dynamic json = await client.fetchJson(Uri(path: collectionId));
    final count = geoJSON.featureCount(json);

    // analyze if only a range should be returned on a "first page" or all items
    final Range? range;
    if (filter?.limit != null) {
      range = Range(start: 0, limit: filter?.limit);
    } else {
      // no limit => all features to "first page"
      range = null;
    }

    // return as paged collection (paging through fetched feature collection)
    return _PagedFeaturesGeoJSON.parse(json, count, DateTime.now(), range);
  }
}

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

class _PagedFeaturesGeoJSON extends Paged<FeatureItems> {
  _PagedFeaturesGeoJSON(
    this.features,
    this.count,
    this.timeStamp, [
    this.json,
    this.nextRange,
  ]);

  factory _PagedFeaturesGeoJSON.parse(
    dynamic json,
    int count,
    DateTime timeStamp,
    Range? range,
  ) {
    // parse feature items for the range and
    final collection = geoJSON.featureCollection(json, range: range);
    final items = FeatureItems(
      collection: collection,
      meta: ItemsMeta(
        timeStamp: timeStamp,
        numberMatched: count,
        numberReturned: collection.features.length,
      ),
    );

    // check if there is next range after current one just parsed
    Range? nextRange;
    if (range != null) {
      final limit = range.limit;
      if (limit != null) {
        final nextStart = range.start + items.features.length;
        if (nextStart < count) {
          nextRange = Range(start: nextStart, limit: limit);
        }
      }
    }

    // return a paged result either with ref to next range or without
    return nextRange != null
        ? _PagedFeaturesGeoJSON(items, count, timeStamp, json, nextRange)
        : _PagedFeaturesGeoJSON(items, count, timeStamp);
  }

  final FeatureItems features;
  final int count;
  final DateTime timeStamp;

  final dynamic json;
  final Range? nextRange;

  @override
  FeatureItems get current => features;

  @override
  bool get hasNext => nextRange != null;

  @override
  Future<Paged<FeatureItems>> next() async {
    if (nextRange == null) {
      throw StateError('No next set.');
    }
    return _PagedFeaturesGeoJSON.parse(json, count, timeStamp, nextRange);
  }
}
