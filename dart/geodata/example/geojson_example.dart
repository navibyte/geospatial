// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print

/*
To test run this from command line: dart example/geojson_example.dart 
*/

import 'package:datatools/fetch_file.dart';
import 'package:datatools/fetch_http.dart';

import 'package:geodata/geojson_features.dart';

Future<void> main(List<String> args) async {
  // read GeoJSON for earthquakes from web using HTTP fetcher
  print('GeoJSON features from HTTP');
  await _readFeatures(
    HttpFetcher.simple(
      endpoints: [
        Uri.parse('https://earthquake.usgs.gov/earthquakes/feed/v1.0/')
      ],
    ),
    'summary/2.5_day.geojson',
  );

  // same thing but files using a file fetcher to read a local file
  print('');
  print('GeoJSON features from file');
  await _readFeatures(
    FileFetcher.basePath('test/usgs'),
    'summary/2.5_day.geojson',
  );
}

Future<void> _readFeatures(Fetcher client, String collectionId) async {
  // create feature source using the given Fetch API client
  final source = FeatureSourceGeoJSON.of(
    client: client,
    meta: DataSourceMeta.collectionIds([collectionId], title: 'Earthquakes'),
  );

  // read features with error handling
  try {
    // get items or features from collection id, maximum 5 features returned
    final items = await source.items(
      collectionId,
      filter: const FeatureFilter(limit: 5),
    );

    // do something with features, in this sample just print them out
    for (final f in items.features) {
      print('Feature with id: ${f.id}');
      print('  geometry: ${f.geometry}');
      print('  properties:');
      for (final key in f.properties.keys) {
        print('    $key: ${f.properties[key]}');
      }
    }
  } on OriginException catch (e) {
    final msg = e.isNotFound ? 'not found' : 'status code ${e.statusCode}';
    print('Origin exception: $msg');
  } on Exception catch (e) {
    print('Other exception: $e');
  }
}
