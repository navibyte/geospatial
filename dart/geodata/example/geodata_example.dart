// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:equatable/equatable.dart';

import 'package:geocore/feature.dart';
import 'package:geodata/client_http.dart';
import 'package:geodata/model_geo.dart';
import 'package:geodata/provider_geo_oapi.dart';

/*
To test run this from command line: 

dart --no-sound-null-safety example/geodata_example.dart https://demo.pygeoapi.io/master obs items 2

Please not that even if this package is null-safe, some dependencies are not 
yet. So running code from the package is not sound-null-safe.

More demo APIs (however this page seems to be somewhat outdated, be careful!):
https://github.com/opengeospatial/ogcapi-features/blob/master/implementations.md
*/

const _defaultBaseURL = 'https://demo.pygeoapi.io/master';
const _defaultCollectionIds = [
  'ogr_gpkg_wales_railway_lines',
  'lakes',
  'obs',
];
const _defaultOperation = 'items';
const _defaultLimit = 2;

/// A simple example to read features from standard OGC API Features services.
void main(List<String> args) async {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // parse args or use hard coded constants
  final baseURL = args.isNotEmpty ? args[0] : _defaultBaseURL;
  final collectionIds =
      args.length >= 2 ? args[1].split(',') : _defaultCollectionIds;
  final operation = args.length >= 3 ? args[2] : _defaultOperation;
  final limit = args.length >= 4 ? int.tryParse(args[3]) ?? -1 : _defaultLimit;

  try {
    // Create an API client accessing HTTP endpoints.
    final client = HttpApiClient.endpoints([
      Endpoint.url(baseURL),
    ]);

    // Create a feature provider for OGC API Features (OAPIF).
    final provider = FeatureProviderOAPIF.client(client);

    // Loop over all collections
    for (var collectionId in collectionIds) {
      // Get feature resource for a collection by id
      final resource = await provider.collection(collectionId);

      // Execute an operation
      switch (operation) {
        case 'items':
          // fetch feature items as paged results (on demo loop max 5 results)
          var round = 0;
          var available = true;
          var items = await resource.itemsPaged(limit: limit);
          do {
            _printFeatures(items.current);
            if (items.hasNext) {
              // get next set
              items = await items.next();
            } else {
              available = false;
            }
          } while (available && ++round < 5);
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
  items.features.forEach((f) => _printFeature(f));
}

void _printFeature(Feature f) {
  print('Feature with id: ${f.id}');
  print('  geometry: ${f.geometry}');
  print('  properties:');
  f.properties.forEach((key, value) => print('    $key: $value'));
}
