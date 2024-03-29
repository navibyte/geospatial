// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
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
    GeoJSONFeatures.http(
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
    GeoJSONFeatures.any(
      () async => File('test/usgs/summary/2.5_day.geojson').readAsString(),
    ),
  );
}

Future<void> _readFeatures(BasicFeatureSource source) async {
  // read features with error handling
  try {
    // get items or features from a source, maximum 5 features returned
    final items = await source.itemsAll(limit: 5);

    // do something with actual data (features), in this sample just print them
    for (final f in items.collection.features) {
      print('Feature with id: ${f.id}');
      print('  geometry: ${f.geometry}');
      print('  properties:');
      for (final key in f.properties.keys) {
        print('    $key: ${f.properties[key]}');
      }
    }
  } on ServiceException<FeatureFailure> catch (e) {
    print('Reading GeoJSON resource failed: ${e.failure.name}');
    print('Cause: ${e.cause}');
  } catch (e) {
    print('Reading GeoJSON resource failed: $e');
  }
}
