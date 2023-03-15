// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print

/*
To test run this from command line: dart example/ogcapi_features_example.dart 
*/

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector_data.dart';
import 'package:geodata/ogcapi_features_client.dart';

Future<void> main(List<String> args) async {
  // create an OGC API Features client for the open pygeoapi demo service
  // (see https://pygeoapi.io/ and https://demo.pygeoapi.io for more info)
  final client = OGCAPIFeatures.http(
    endpoint: Uri.parse('https://demo.pygeoapi.io/master/'),
  );

  // the client provides resource, conformance and collections meta accessors
  // (those are not needed in all use cases, but let's check them for demo)

  // resource meta contains the service title (+ links and optional description)
  final meta = await client.meta();
  print('Service: ${meta.title}');

  // conformance classes (text ids) informs the capabilities of the service
  final conformance = await client.conformance();
  print('Conformance classes:');
  for (final e in conformance) {
    print('  $e');
  }
  // the service should be compliant with OGC API Features - Part 1 and GeoJSON
  const c1 = 'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/core';
  const c2 = 'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/geojson';
  if (conformance.contains(c1) && conformance.contains(c2)) {
    print('The service is compliant with OGC API Features, Part 1 and GeoJSON');
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

  // next read actual data (wind mills) from this collection

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
  //
  // (*) supported only by services conforming to OGC API Features - Part 2: CRS

  // `items` allows also setting property filters when supported by a service.
  //
  // In this case check the following queryables resource from the service:
  // https://demo.pygeoapi.io/master/collections/dutch_windmills/queryables
  // (currently the geodata client does not decode queryables yet)
  final itemsByPlace = await source.items(
    const BoundedItemsQuery(
      extra: {'PLAATS': 'Uitgeest'},
    ),
  );
  await _readFeatureItems(
    useCase: 'Read features from "dutch_windmills" filtered by a place name',
    items: itemsByPlace,
    propertyNames: ['NAAM', 'PLAATS'],
  );

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
  for (final link in links.items) {
    print('  ${link.rel}: ${link.href}');
  }
}
