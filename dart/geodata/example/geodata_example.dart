// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print

/*
To test run this from command line: dart example/geodata_example.dart 
*/

import 'package:geobase/geobase.dart';
import 'package:geodata/ogcapi_features_client.dart';

/// This example demonstrates accessing metadata and geospatial feature items
/// from a GeoJSON based feature collection provided by a RESTful service
/// conforming to the [OGC API Features](https://ogcapi.ogc.org/features/)
/// standard. The standard itself descibes how it works:
///
/// "OGC API Features provides API building blocks to create, modify and query
/// features on the Web. OGC API Features is comprised of multiple parts, each
/// of them is a separate standard. The "Core" part specifies the core
/// capabilities and is restricted to fetching features where geometries are
/// represented in the coordinate reference system WGS 84 with axis order
/// longitude/latitude. Additional capabilities that address more advanced needs
/// will be specified in additional parts."
///
/// The `geodata` package support following standard parts:
/// * [OGC API - Features - Part 1: Core](https://docs.ogc.org/is/17-069r4/17-069r4.html):
///   Supported for accessing metadata and GeoJSON feature collections.
/// * [OGC API - Features - Part 2: Coordinate Reference Systems by Reference](https://docs.ogc.org/is/18-058r1/18-058r1.html)
/// * OGC API - Features - Part 3: Filtering (draft): Partially supported
///   (conformance classes, queryables, features filter).
Future<void> main(List<String> args) async {
  // create an OGC API Features client for the open pygeoapi demo service
  // (see https://pygeoapi.io/ and https://demo.pygeoapi.io for more info)
  final client = OGCAPIFeatures.http(
    // The API endpoint serving an OGC API Features demo service (of pygeoapi)
    endpoint: Uri.parse('https://demo.pygeoapi.io/master/'),
  );

  // the client provides resource, conformance and collections meta accessors
  // (those are not needed in all use cases, but let's check them for demo)

  // resource meta contains the service title (+ links and optional description)
  final meta = await client.meta();
  print('Service: ${meta.title}');

  // access OpenAPI definition for the service and check for terms of service
  // (OpenAPI contains also other info of service, queries and responses, etc.)
  final openAPI = await meta.openAPI();
  final info = openAPI.content['info'] as Map<String, dynamic>;
  print('Terms of service: ${info['termsOfService']}');

  // conformance classes (text ids) informs the capabilities of the service
  final conformance = await client.conformance();
  print('Conformance classes:');
  for (final e in conformance.classes) {
    print('  $e');
  }
  // service should (at least) be compliant with Part 1 (Core + GeoJSON)
  if (!conformance.conformsToFeaturesCore(geoJSON: true)) {
    print('NOT compliant with Part 1 (Core, GeoJSON).');
    return;
  }

  // get metadata about all feature collections provided by the service
  final collections = await client.collections();
  print('Collections:');
  for (final e in collections) {
    print('  ${e.id}: ${e.title}');
    // other collection meta: ie. spatial and temporal extent and resource links
  }

  // in this sample, the pygeoapi service contains over 10 collections, but in
  // the following parts we use a collection named 'dutch_windmills'

  // get a feature source (`OGCFeatureSource`) for Dutch windmill point features
  final source = await client.collection('dutch_windmills');

  // the source for the collection also provides some metadata
  final collectionMeta = await source.meta();
  print('');
  print('Collection: ${collectionMeta.id} / ${collectionMeta.title}');
  print('Description: ${collectionMeta.description}');
  print('Spatial extent: ${collectionMeta.extent?.spatial}');
  print('Temporal extent: ${collectionMeta.extent?.temporal}');
  _printLinks(collectionMeta.links);

  // **** next read actual data (wind mills) from this collection

  // `itemsAll` lets access all features on source (optionally limited by limit)
  final itemsAll = await source.itemsAll(
    limit: 2,
  );
  await _readFeatureItems(
    useCase: 'Read max 2 (limit) features from "dutch_windmills" collection',
    items: itemsAll,
    propertyNames: ['gid', 'NAAM', 'PLAATS'],
    printLinks: true,
  );

  // `itemsAllPaged` helps paginating through a large dataset with many features
  // (here each page is limited to 2 features, and max 3 pages are looped)
  var pageIndex = 0;
  Paged<OGCFeatureItems>? page = await source.itemsAllPaged(limit: 2);
  while (page != null && pageIndex <= 2) {
    await _readFeatureItems(
      useCase: 'Read page $pageIndex with max 2 features in paginated access',
      items: page.current,
      propertyNames: ['NAAM'],
    );
    page = await page.next();
    pageIndex++;
  }

  // `items` is used for filtered queries, here bounding box, WGS 84 coordinates
  final items = await source.items(
    const BoundedItemsQuery(
      limit: 2,
      bbox: GeoBox(west: 5.03, south: 52.21, east: 5.06, north: 52.235),
    ),
  );
  await _readFeatureItems(
    useCase: 'Read features from "dutch_windmills" matching the bbox filter',
    items: items,
    propertyNames: ['NAAM'],
  );

  // `BoundedItemsQuery` provides also following filters:
  // - `limit` sets the maximum number of features returned
  // - `timeFrame` sets a temporal filter
  // - `bboxCrs` sets the CRS used by the `bbox` filter (*)
  // - `crs` sets the CRS used by geometry objects of response features (*)
  // - `parameters` sets queryable properties as a query parameter filter (#)
  //
  // (*) supported by services conforming to Part 2: CRS
  // (#) supported by services conforming to Part 3: Filtering

  // `itemsPaged` is used for paginated access on filtered queries
  // (not demostrated here, see `itemsAllPaged` sample above about paggination)

  // samples above accessed feature collections (resuls with 0 to N features)
  // it's possible to access also a single specific feature item by ID
  final item = await source.itemById('Molens.5');
  await _readFeatureItem(
    useCase: 'Read a single feature by ID from "dutch_windmills"',
    item: item,
    printLinks: true,
  );

  // **** next require also support for alternative coordinate reference systems

  // service should be compliant with OGC API Features - Part 2 (CRS)
  if (!conformance.conformsToFeaturesCrs()) {
    print('NOT compliant with Part 2 (CRS).');
    return;
  }

  // metadata also has info about coordinate systems supported by a collection
  final storageCrs = collectionMeta.storageCrs;
  if (storageCrs != null) {
    print('Storage CRS: $storageCrs');
  }
  final supportedCrs = collectionMeta.crs;
  print('All supported CRS identifiers:');
  for (final crs in supportedCrs) {
    print('  $crs');
  }

  // bounding box query for `items` - here adjusted to return using other CRS
  const webMercatorCRS = CoordRefSys.EPSG_3857;
  if (supportedCrs.contains(webMercatorCRS)) {
    // Web Mercator (EPSG:3857) is supported by the service, so let's get data
    final itemsWebMercator = await source.items(
      const BoundedItemsQuery(
        // ask result geometries in Web Mercator projection
        crs: webMercatorCRS,

        // bbox query is still WGS 84 longitude / latitude coordinates
        // (if other CRS is used for `bbox`, also `bboxCrs` must be given)
        bbox: GeoBox(west: 5.03, south: 52.21, east: 5.06, north: 52.235),
      ),
    );
    await _readFeatureItems(
      useCase: 'Read features from "dutch_windmills" matching the bbox filter,'
          ' result as Web Mercator',
      items: itemsWebMercator,
      propertyNames: ['NAAM'],
    );
  }

  // **** next require also support for filtering capabilities

  // service should be compliant with OGC API Features - Part 3 (Filtering)
  if (!conformance.conformsToFeaturesQueryables(queryParameters: true)) {
    print(
      'NOT compliant with Part 3 Filtering (Queryables + Query Parameters).',
    );
    return;
  }

  // optional metadata about queryable properties
  final queryables = await source.queryables();
  if (queryables != null) {
    print('Queryables for ${queryables.title}:');
    for (final prop in queryables.properties.values) {
      print('  ${prop.name} (${prop.title}): ${prop.type}');
    }
  }

  // metadata about queryables can be utilized as query parameters (of HTTP
  // request) or as more complex Common Query Language (CQL2) filters

  // here query parameters is set to define a simple filter by a place name
  final itemsByPlace = await source.items(
    const BoundedItemsQuery(
      // queryables as query parameters (`PLAATS` is a queryable property)
      parameters: {
        'PLAATS': 'Uitgeest',
      },
    ),
  );
  await _readFeatureItems(
    useCase: 'Read features from "dutch_windmills" filtered by a place name',
    items: itemsByPlace,
    propertyNames: ['NAAM', 'PLAATS'],
  );
}

Future<void> _readFeatureItems({
  String? useCase,
  required OGCFeatureItems items,
  bool printLinks = false,
  Iterable<String>? propertyNames,
}) async {
  print('---------------------');
  if (useCase != null) {
    print(useCase);
    print('');
  }

  // read metadata and features with error handling
  try {
    // responses may contain optional metadata
    if (items.timeStamp != null) {
      print('Timestamp: ${items.timeStamp}');
    }
    if (items.numberMatched != null) {
      print('Count of features matched to query: ${items.numberMatched}');
    }
    if (items.numberReturned != null) {
      print('Count of features returned in response: ${items.numberReturned}');
    }

    // responses contain also links to other resources (like alternative
    // encodings, metadata about a source collection, or next set of features)
    if (printLinks) {
      _printLinks(items.links);
    }

    // do something with actual data (features), in this sample just print them
    for (final f in items.collection.features) {
      _printFeature(f, propertyNames);
    }
  } on ServiceException<FeatureFailure> catch (e) {
    print('Reading OGC API Features resource failed: ${e.failure.name}');
    print('Cause: ${e.cause}');
  } catch (e) {
    print('Reading OGC API Features resource failed: $e');
  }
}

Future<void> _readFeatureItem({
  String? useCase,
  required OGCFeatureItem item,
  bool printLinks = false,
  Iterable<String>? propertyNames,
}) async {
  print('---------------------');
  if (useCase != null) {
    print(useCase);
    print('');
  }

  // read metadata and a feature with error handling
  try {
    // responses contain also links to other resources
    if (printLinks) {
      _printLinks(item.links);
    }

    // do something with actual data (a feature), in this sample just print it
    _printFeature(item.feature, propertyNames);
  } on ServiceException<FeatureFailure> catch (e) {
    print('Reading OGC API Features resource failed: ${e.failure.name}');
    print('Cause: ${e.cause}');
  } catch (e) {
    print('Reading OGC API Features resource failed: $e');
  }
}

void _printFeature(
  Feature feature, [
  Iterable<String>? propertyNames,
]) {
  print('Feature with id: ${feature.id}');
  print('  geometry: ${feature.geometry}');
  print('  properties:');
  if (propertyNames != null) {
    // print only selected properties
    for (final key in propertyNames) {
      print('    $key: ${feature.properties[key]}');
    }
  } else {
    // print all properties associated with an feature
    for (final key in feature.properties.keys) {
      print('    $key: ${feature.properties[key]}');
    }
  }
}

void _printLinks(Links links) {
  print('Links');
  for (final link in links.all) {
    print('  ${link.rel}: ${link.href}');
  }
}
