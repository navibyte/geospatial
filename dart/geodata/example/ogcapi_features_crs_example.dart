// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print

/*
To test run this from command line: 
      dart example/ogcapi_features_crs_example.dart 
*/

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector_data.dart';
import 'package:geodata/ogcapi_features_client.dart';

Future<void> main(List<String> args) async {
  // create an OGC API Features client for the open ldproxy demo service
  // (see https://demo.ldproxy.net/zoomstack for more info)
  final client = OGCAPIFeatures.http(
    endpoint: Uri.parse('https://demo.ldproxy.net/zoomstack'),
  );

  // get service description and attribution info
  final meta = await client.meta();
  print('Service: ${meta.description}');
  print('Attribution: ${meta.attribution}');

  // get "airports" collection, and print spatial extent and storage CRS
  final airports = await client.collection('airports');
  final airportsMeta = await airports.meta();
  final extent = airportsMeta.extent?.spatial;
  if (extent != null) {
    final crs = extent.coordRefSys;
    print('Spatial bbox list (crs: $crs):');
    for (final box in extent.boxes) {
      print('  $box');
    }
  }
  final storageCrs = airportsMeta.storageCrs;
  if (storageCrs != null) {
    print('Storage CRS: $storageCrs');
  }

  // get all supported CRS identifiers
  final supportedCrs = airportsMeta.crs;
  for (final crs in supportedCrs) {
    print('---------------------');
    print('query crs: $crs');

    // get feature items filtered by name and result geometries in `crs`
    final itemsByName = await airports.items(
      BoundedItemsQuery(
        crs: crs,
        parameters: const {
          'name': 'London Oxford Airport',
        },
      ),
    );

    // print metadata about response
    final returned = itemsByName.numberReturned;
    final contentCrs = itemsByName.contentCrs;
    print('got $returned items');
    print('content crs: $contentCrs');

    // print features items contained in response feature collection
    for (final feature in itemsByName.collection.features) {
      final id = feature.id;
      final name = feature.properties['name'];
      final geometry = feature.geometry;
      if (geometry is Point) {
        if (crs.isGeographic()) {
          final position = geometry.position.asGeographic;
          const dms = Dms(type: DmsType.degMinSec, decimals: 3);
          print('$id $name ${position.lonDms(dms)},${position.latDms(dms)}');
        } else {
          final position = geometry.position;
          print('$id $name $position');
        }
      }
    }
  }
}
