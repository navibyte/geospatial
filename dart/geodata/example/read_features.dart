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

dart --no-sound-null-safety example/read_features.dart https://demo.pygeoapi.io/master obs items 2
*/

/// A simple example to read features from standard OGC API Features services.
void main(List<String> args) async {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // parse args or use hard coded constants
  final baseURL = args.isNotEmpty ? args[0] : 'https://demo.pygeoapi.io/master';
  final collectionId = args.length >= 2 ? args[1] : 'obs';
  final operation = args.length >= 3 ? args[2] : 'items';
  final limit = args.length >= 4 ? int.tryParse(args[3]) ?? -1 : 2;

  try {
    // Create an API client accessing HTTP endpoints.
    final client = HttpApiClient.endpoints([
      Endpoint.url(baseURL),
    ]);

    // Create a feature provider for OGC API Features (OAPIF).
    final provider = FeatureProviderOAPIF.client(client);

    // Get feature resource for a collection by id
    final resource = await provider.collection(collectionId);

    // Execute an operation
    switch (operation) {
      case 'items':
        // fetch feature items as paged results (on demo loop max 5 results)
        var round = 0;
        var available = true;
        var features = await resource.featuresPaged(limit: limit);
        do {
          _printFeatures(features.current);
          if (features.hasNext) {
            // get next set
            features = await features.next();
          } else {
            available = false;
          }
        } while (available && ++round < 5);
        break;
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
  items.all.forEach((f) => _printFeature(f));
}

void _printFeature(Feature feature) {
  print('  Id: ${feature.id} Geometry: ${feature.geometry}');
  feature.properties.forEach((key, value) => print('    $key: $value'));
}
