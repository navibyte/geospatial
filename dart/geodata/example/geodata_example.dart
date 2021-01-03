// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import 'package:attributes/entity.dart';
import 'package:datatools/client_base.dart';
import 'package:datatools/client_http.dart';
import 'package:geocore/feature.dart';
import 'package:geocore/parse_factory.dart';

import 'package:geodata/model_features.dart';
import 'package:geodata/source_oapi_features.dart';

/*
To test run this from command line: 

dart --no-sound-null-safety example/geodata_example.dart https://demo.pygeoapi.io/master lakes 2 items
dart --no-sound-null-safety example/geodata_example.dart https://demo.pygeoapi.io/master lakes 2 items id 3
dart --no-sound-null-safety example/geodata_example.dart https://www.ldproxy.nrw.de/kataster verwaltungseinheit 2 items bbox 7,50.6,7.2,50.8
dart --no-sound-null-safety example/geodata_example.dart https://weather.obs.fmibeta.com fmi_aws_observations 2 items bbox 23,62,24,63

Please not that even if this package is null-safe, some dependencies are not 
yet. So running code from the package is not sound-null-safe.

More demo APIs (however this page seems to be somewhat outdated, be careful!):
https://github.com/opengeospatial/ogcapi-features/blob/master/implementations.md
*/

const _defaultOperation = 'items';
const _defaultLimit = 2;
const _defaultMaxPagedResults = 2;

/// A simple example to read features from standard OGC API Features services.
void main(List<String> args) async {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // check enough args
  if (args.length < 2) {
    print(
        'Args: {baseUrl} {collectionIds} [limit] [operation] [param] [value]');
    return;
  }

  // parse args
  final baseURL = args[0];
  final collectionIds = args[1].split(',');
  final limit = args.length >= 3 ? int.tryParse(args[2]) ?? -1 : _defaultLimit;
  final operation = args.length >= 4 ? args[3] : _defaultOperation;
  var maxPagedResults = _defaultMaxPagedResults;
  var filter = FeatureFilter(
    limit: limit,
  );
  if (args.length >= 6) {
    switch (args[4]) {
      case 'id':
        filter = FeatureFilter(
          limit: limit,
          id: Identifier.fromString(args[5]),
        );
        maxPagedResults = 1;
        break;
      case 'bbox':
        final bbox = args[5].split(',');
        if (bbox.length == 4 || bbox.length == 6) {
          filter = FeatureFilter(
            limit: limit,
            bounds: createGeoBounds(bbox),
          );
        }
        break;
    }
  }

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
          // fetch feature items as paged results, max rounds by maxPagedResults
          var round = 0;
          var available = true;
          var items = await resource.itemsPaged(filter: filter);
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
  items.features.forEach((f) => _printFeature(f));
}

void _printFeature(Feature f) {
  print('Feature with id: ${f.id}');
  print('  geometry: ${f.geometry}');
  print('  properties:');
  f.properties.map.forEach((key, value) => print('    $key: $value'));
}
