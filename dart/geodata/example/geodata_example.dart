// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print
// ignore_for_file: avoid_catches_without_on_clauses

import 'package:equatable/equatable.dart';

import 'package:attributes/values.dart';
import 'package:datatools/fetch_http.dart';
import 'package:geocore/geo.dart';
import 'package:geocore/feature.dart';

import 'package:geodata/geojson_features.dart';
import 'package:geodata/oapi_features.dart';

/*
To test run this from command line: 

GeoJSON (file) resource as a data source:
dart example/geodata_example.dart geojson https://earthquake.usgs.gov/earthquakes/feed/v1.0/ summary/2.5_day.geojson 3 items

OGC API Features data sources:
dart example/geodata_example.dart oapif https://demo.pygeoapi.io/master/ lakes 2 items
dart example/geodata_example.dart oapif https://demo.pygeoapi.io/master/ lakes 2 items id 3
dart example/geodata_example.dart oapif https://www.ldproxy.nrw.de/kataster/ verwaltungseinheit 2 items bbox 7,50.6,7.2,50.8
dart example/geodata_example.dart oapif https://weather.obs.fmibeta.com/ fmi_aws_observations 2 items bbox 23,62,24,63

More demo APIs (however this page seems to be somewhat outdated, be careful!):
https://github.com/opengeospatial/ogcapi-features/blob/master/implementations.md
*/

const _defaultOperation = 'items';
const _defaultLimit = 2;
const _defaultMaxPagedResults = 2;

/// A simple example to read features from standard OGC API Features services.
Future<void> main(List<String> args) async {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // check enough args
  if (args.length < 3) {
    print('Args: {source} {baseUrl} {collectionIds} '
        '[limit] [operation] [param] [value]');
    print('Allowed sources: oapif, geojson');
    return;
  }

  // parse args
  final sourceType = args[0];
  final baseURL = args[1];
  final collectionIds = args[2].split(',');
  final limit = args.length >= 4 ? int.tryParse(args[3]) : _defaultLimit;
  final operation = args.length >= 5 ? args[4] : _defaultOperation;
  var maxPagedResults = _defaultMaxPagedResults;
  var filter = FeatureFilter(
    limit: limit,
  );
  if (args.length >= 7) {
    switch (args[5]) {
      case 'id':
        filter = FeatureFilter(
          limit: limit,
          id: Identifier.fromString(args[6]),
        );
        maxPagedResults = 1;
        break;
      case 'bbox':
        final bbox = args[6].split(',');
        if (bbox.length == 4 || bbox.length == 6) {
          filter = FeatureFilter(
            limit: limit,
            bounds: GeoBounds.from(bbox.map<num>(toDoubleValue)),
          );
        }
        break;
    }
  }

  try {
    // Create a fetcher to read data from an endpoint.
    final client = HttpFetcher.simple(
      endpoints: [Uri.parse(baseURL)],
    );

    // Create a feature source for plain GeoJSON or OGC API Features (OAPIF)
    final FeatureSource source;
    switch (sourceType) {
      case 'geojson':
        // GeoJSON source for a plain resource (the resource provides only
        // items, metadata is setup here as statically)
        source = FeatureSourceGeoJSON.of(
            client: client,
            meta: DataSourceMeta.collectionIds(
              collectionIds,
              title: 'Sample GeoJSON service',
            ));
        break;
      case 'oapif':
        // OGC API Features source (the service provides both meta and items)
        source = FeatureServiceOAPIF.of(
          client: client,
        );
        break;
      default:
        throw ArgumentError('Unknow source type $sourceType');
    }

    // Loop over all collections
    for (final collectionId in collectionIds) {
      // Execute an operation
      switch (operation) {
        case 'items':
          // fetch feature items as paged results, max rounds by maxPagedResults
          var round = 0;
          var available = true;
          var items = await source.itemsPaged(collectionId, filter: filter);
          do {
            _printFeatures(items.current);
            if (items.hasNext) {
              // get next set
              items = await items.next();
            } else {
              available = false;
            }
          } while (available && ++round < maxPagedResults);
          break;
      }
    }
  } catch (e, st) {
    print('Calling $baseURL failed: $e');
    print(st);
  }
}

void _printFeatures(FeatureItems items) {
  print('Features:');
  if (items.meta.numberMatched != null) {
    print('  number matched ${items.meta.numberMatched}');
    print('  number returned ${items.meta.numberReturned}');
  }
  items.features.forEach(_printFeature);
}

void _printFeature(Feature f) {
  print('Feature with id: ${f.id}');
  print('  geometry: ${f.geometry}');
  print('  properties:');
  for (final key in f.properties.keys) {
    print('    $key: ${f.properties[key]}');
  }
}
