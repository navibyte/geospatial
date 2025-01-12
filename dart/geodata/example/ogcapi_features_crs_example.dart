// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print, avoid_redundant_argument_values

/*
To test run this from command line: 
      dart example/ogcapi_features_crs_example.dart 
*/

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';
import 'package:geodata/ogcapi_features_client.dart';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

/// This example demonstrates accessing metadata and geospatial feature items
/// from a GeoJSON based feature collection provided by a RESTful service
/// conforming to the [OGC API Features](https://ogcapi.ogc.org/features/)
/// standard from the viewpoint of *coordinate reference systems*.
///
/// Sample code expects a service to conform at least for following standard
/// parts:
/// * [OGC API - Features - Part 1: Core](https://docs.ogc.org/is/17-069r4/17-069r4.html):
///   Supported for accessing metadata and GeoJSON feature collections.
/// * [OGC API - Features - Part 2: Coordinate Reference Systems by Reference](https://docs.ogc.org/is/18-058r1/18-058r1.html)
Future<void> main(List<String> args) async {
  // Create an instance of the standard HTTP retry client for API calls
  final httpClient = RetryClient(http.Client(), retries: 4);

  try {
    await _testOGCFeatService(httpClient);
  } finally {
    // ensure the HTTP client is closed after using
    httpClient.close();
  }
}

Future<void> _testOGCFeatService(http.Client httpClient) async {
  // create an OGC API Features client for the open ldproxy demo service
  // (see https://demo.ldproxy.net/zoomstack for more info)
  final client = OGCAPIFeatures.http(
    // set HTTP client (if not set the default `http.Client()` is used)
    client: httpClient,

    // an URI to the landing page of the service
    endpoint: Uri.parse('https://demo.ldproxy.net/zoomstack'),

    // customize GeoJSON format
    format: GeoJSON.featureFormat(
      conf: const GeoJsonConf(
        // specify that CRS authorities should be respected for axis order in
        // GeoJSON data (actually this is the default - here for demonstration)
        crsLogic: GeoRepresentation.crsAuthority,
      ),
    ),
  );

  // get service description and attribution info
  final meta = await client.meta();
  print('Service: ${meta.description}');
  print('Attribution: ${meta.attribution}');

  // service should be compliant with Part 1 (Core, GeoJSON) and Part 2 (CRS)
  final conformance = await client.conformance();
  if (!(conformance.conformsToFeaturesCore(geoJSON: true) &&
      conformance.conformsToFeaturesCrs())) {
    print('NOT compliant with Part 1 (Core, GeoJSON) and Part 2 (CRS).');
    return;
  }

  // get "airports" collection, and print spatial extent and storage CRS
  final airports = await client.collection('airports');
  final airportsMeta = await airports.meta();
  final extent = airportsMeta.extent?.spatial;
  if (extent != null) {
    final crs = extent.crs;
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
        // output result geometries in crs of the loop
        crs: crs,

        // bbox in EPSG:27700
        bboxCrs: CoordRefSys.normalized(
          'http://www.opengis.net/def/crs/EPSG/0/27700',
        ),
        bbox: const ProjBox(
          minX: 447000,
          minY: 215500,
          maxX: 448000,
          maxY: 215600,
        ),
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
          final position = Geographic.from(geometry.position);
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
