// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print

/*
To test run this from command line: dart example/geojson_example.dart 
*/

// importing `dart:io` not supported on the Flutter web platform
import 'dart:io' show File;

import 'package:geodata/geojson_client.dart';

Future<void> main(List<String> args) async {
  // read GeoJSON for earthquakes from web using HTTP(S)
  print('GeoJSON features from HTTP');
  await _readFeatures(
    geoJsonHttpClient(
      location: Uri.parse(
        'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/'
        '2.5_day.geojson',
      ),
    ),
  );

  // same thing but reading a local file
  print('');
  print('GeoJSON features from file');
  await _readFeatures(
    geoJsonFutureClient(
      () async => File('test/usgs/summary/2.5_day.geojson').readAsString(),
    ),
  );
}

Future<void> _readFeatures(FeatureSource source) async {
  // read features with error handling
  try {
    // get items or features from a source, maximum 5 features returned
    final items = await source.items(
      const FeatureItemsQuery(limit: 5),
    );

    // do something with features, in this sample just print them out
    for (final f in items.collection.features) {
      print('Feature with id: ${f.id}');
      print('  geometry: ${f.geometry}');
      print('  properties:');
      for (final key in f.properties.keys) {
        print('    $key: ${f.properties[key]}');
      }
    }
  } on FeatureException catch (e) {
    print('Reading GeoJSON resource failed: ${e.failure.name}');
    if (e.cause != null) {
      print('Cause: ${e.cause}');
    }
    if (e.trace != null) {
      print(e.trace);
    }
  } catch (e, st) {
    print('Reading GeoJSON resource failed: $e');
    print(st);
  }
}
