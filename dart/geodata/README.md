[![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

<a title="Public domain, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Winkel_triple_projection_SW.jpg"><img alt="Equirectangular projection" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/projections/winkel/320px-Winkel_triple_projection_SW.jpg" align="right"></a>

Geospatial feature service Web APIs with support for 
[GeoJSON](https://geojson.org/) and 
[OGC API Features](https://ogcapi.ogc.org/features/) clients for Dart.

## Features

✨ New (2023-07): better client-side support for OGC API Features (Part 1 and 2).

Key features:

* 🪄 Client-side data source abstraction for geospatial feature service Web APIs
* 🌐 The [GeoJSON](https://geojson.org/) client to read features from static web resources and local files
* 🌎 The [OGC API Features](https://ogcapi.ogc.org/features/) client to access metadata and feature items from a compliant geospatial Web API providing GeoJSON data

Client-side support for the OGC API Features standard:

Standard part | Support in this package
------------- | -----------------------
[OGC API - Features - Part 1: Core](https://docs.ogc.org/is/17-069r4/17-069r4.html) | Supported for accessing metadata and GeoJSON feature collections.
[OGC API - Features - Part 2: Coordinate Reference Systems by Reference](https://docs.ogc.org/is/18-058r1/18-058r1.html) | Supported.

## Introduction

As a background you might want first to check a good
[introduction about OGC API Features](https://opengeospatial.github.io/e-learning/ogcapi-features/text/basic-main.html) or a video about the
[OGC API standard family](https://www.youtube.com/watch?v=xpw_VvcPjaE),
both provided by OGC (The Open Geospatial Consortium) itself.

In this package see [geodata_example.dart](example/geodata_example.dart) for
a simple CLI tool reading metadata and feature items from GeoJSON and OGC API
Features data sources.

The following diagram describes a decision flowchart to select a client class
and a feature source to access GeoJSON feature collections and feature items:

<img src="https://raw.githubusercontent.com/navibyte/geospatial/main/dart/geodata/assets/diagrams/decision_flowchart.svg" width="100%" title="Decision flowchart to select a client class to access GeoJSON resources" />

Below you can find few step-by-step instructions how to get started in scenarios
represented in the decision flowchart.

### Static GeoJSON web resource

```dart
// 1. Get a feature source from a web resource using http.
final source = GeoJSONFeatures.http(location: Uri.parse('...'));

// 2. Access feature items.
final items = await source.itemsAll();

// 3. Get an iterable of feature objects.
final features = items.collection.features;

// 4. Loop through features (each with id, properties and geometry)
for (final feat in features) {
  print('Feature ${feat.id} with geometry: ${feat.geometry}');
}
```

### Static GeoJSON local resource

```dart
// 1. Get a feature source using an accessor to a file.
final source = GeoJSONFeatures.any(() async => File('...').readAsString());

// 2. Access feature items.
final items = await source.itemsAll();

// 3. Get an iterable of feature objects.
final features = items.collection.features;

// 4. Loop through features (each with id, properties and geometry)
for (final feat in features) {
  print('Feature ${feat.id} with geometry: ${feat.geometry}');
}
```

### Web API service conforming to OGC API Features

```dart
// 1. Get a client instance for a Web API endpoint.
final client = OGCAPIFeatures.http(endpoint: Uri.parse('...'));

// 2. Access/check metadata (meta, OpenAPI, conformance, collections) as needed.
final conformance = await client.conformance();
if (!conformance.conformsToFeaturesCore(geoJSON: true)) {
  return; // not conforming to core and GeoJSON - so return
}

// 3. Get a feature source for a specific collection.
final source = await client.collection('my_collection');

// 4. Access (and check) metadata for this collection.
final meta = await source.meta();
print('Collection title: ${meta.title}');

// 5. Access feature items.
final items = await source.itemsAll(limit: 100);

// 6. Check response metadata.
print('Timestamp: ${items.timeStamp}');

// 7. Get an iterable of feature objects.
final features = items.collection.features;

// 8. Loop through features (each with id, properties and geometry)
for (final feat in features) {
  print('Feature ${feat.id} with geometry: ${feat.geometry}');
}
```

For the step 5 other alternatives are:
* Use `source.items()` to get feature items by a filtered query (ie. bbox).
* Use `source.itemById()` to get a single feature by an identifier.
* Use `source.itemsAllPaged()` or `source.itemsPaged()` for accessing paged
feature sets.

In the step 6 it's also possible to get links to related resources, and
optionally also to get a number of matched or returned features in a response.

## Usage

The package requires at least [Dart](https://dart.dev/) SDK 2.17, and it
supports all [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/)
platforms.

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  geodata: ^0.12.0-dev.0
```

Import it:

```dart
import `package:geodata/geodata.dart`
```

There are also partial packages containing only a certain subset. See the
[Packages](#packages) section below.

Other documentation:

> 📚 **Concepts**: If coordinates, geometries, features and feature collections
> are unfamiliar concepts, you might want to read more about
> [geometries](https://pub.dev/packages/geobase#geometries),
> [geospatial features](https://pub.dev/packages/geobase#geospatial-features)
> and [GeoJSON](https://pub.dev/packages/geobase#geojson) in the documentation
> of the [geobase](https://pub.dev/packages/geobase) package.
> 
> 🚀 **Samples**: 
> The [Geospatial demos for Dart](https://github.com/navibyte/geospatial_demos)
> repository contains more sample code showing also how to use this package!

## Feature data sources

### GeoJSON client

The GeoJSON client allows fetching and reading geospatial feature collections
with their geometry objects (ie. point, line string, polygon, multi point,
multi line string, multi polygon and geometry collection) from following
resource types:
* a web resource (by URL) containing GeoJSON content - data is fetched using the HTTP client (as provided by the [http](https://pub.dev/packages/http) package)
* custom resources, ie. a local file or an app bundled containing valid GeoJSON data

Please note that this client is not related to OGC API Features or any other API
protocol either, but you can access any (static) web or local resource with
GeoJSON data.

The sample below shows to read GeoJSON features from a web resource using the
HTTP client.

```dart
import 'package:geodata/geojson_client.dart';

Future<void> main(List<String> args) async {
  // read GeoJSON for earthquakes from web using HTTP(S)
  await _readFeatures(
    GeoJSONFeatures.http(
      location: Uri.parse(
        'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/'
        '2.5_day.geojson',
      ),
    ),
  );
}

Future<void> _readFeatures(BasicFeatureSource source) async {
  // read features with error handling
  try {
    // get items or features from a source, maximum 5 features returned
    final items = await source.itemsAll(limit: 5);

    // do something with features, in this sample just print them out
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
```

The full sample for accessing GeoJSON feature sources is available in
[geojson_example.dart](example/geojson_example.dart).

### OGC API Features client

The GeoJSON client discussed above allows reading data from a static web
resource or a local file. However most often geospatial APIs contains huge
datasets, and data items to be queried must be selected and filtered. 

The [OGC API Features](https://ogcapi.ogc.org/features/) standard by the
[Open Geospatial Consortium](https://www.ogc.org/) (or OGC) specifies this -
how data is discovered and accessed:

> OGC API Features provides API building blocks to create, modify and query 
> features on the Web. OGC API Features is comprised of multiple parts, each of 
> them is a separate standard. This part, the "Core" specifies the core 
> capabilities and is restricted to fetching features where geometries are 
> represented in the coordinate reference system WGS 84 with axis order
> longitude/latitude. Additional capabilities that address more advanced needs
> will be specified in additional parts. 

A compliant (according to `Part 1: Core`) API service should provide at least
following resources:

Resource | Path | Description
-------- | ---- | ----------- 
Landing page | `/` | Metadata about the API.
Conformance classes | `/conformance` | Conformance classes supported by the API.
Feature collections | `/collections` | Metadata about all feature collections provided by the API.
Feature collection | `/collections/{collectionId}` | Metadata about a single feature collection provided by the API.
Features | `/collections/{collectionId}/items` | Feature items (with geometry and property data) in a specified feature collection provided by the API.
Feature (by id) | `/collections/{collectionId}/items/{featureId}` | A single feature item (with geometry and property data) in a specified feature collection provided by the API.

Most services also provide an API definition (ie. an Open API 3.0 document) at
`/api` describing the capabilities of the API service.

See [ogcapi_features_example.dart](example/ogcapi_features_example.dart) for a
sample how to read metadata and feature items from an API service conforming to
[OGC API Features](https://ogcapi.ogc.org/features/).

Some most relevant portions of this sample:

```dart
import 'package:geobase/coordinates.dart';
import 'package:geodata/ogcapi_features_client.dart';

Future<void> main(List<String> args) async {
  // create an OGC API Features client for the open pygeoapi demo service
  // (see https://pygeoapi.io/ and https://demo.pygeoapi.io for more info)
  final client = OGCAPIFeatures.http(
    endpoint: Uri.parse('https://demo.pygeoapi.io/master/'),
  );

  // resource meta contains the service title (+ links and optional description)
  final meta = await client.meta();
  print('Service: ${meta.title}');

  // access OpenAPI definition for the service and check for terms of service
  // (OpenAPI contains also other info of service, queries and responses, etc.)
  final info = (await meta.openAPI()).content['info'] as Map<String, dynamic>;
  print('Terms of service: ${info['termsOfService']}');

  // conformance classes (text ids) informs the capabilities of the service
  final conformance = await client.conformance();
  // the service should be compliant with OGC API Features - Part 1 and GeoJSON
  if (conformance.conformsToFeaturesCore(geoJSON: true)) {
    print('The service is compliant with OGC API Features, Part 1 and GeoJSON');
  } else {
    print('The service is NOT compliant.');
    return;
  }

  // get a feature source (`OGCFeatureSource`) for Dutch windmill point features
  final source = await client.collection('dutch_windmills');

  // the source for the collection also provides some metadata
  final collectionMeta = await source.meta();
  print('');
  print('Collection: ${collectionMeta.id} / ${collectionMeta.title}');
  print('Description: ${collectionMeta.description}');
  print('Spatial extent: ${collectionMeta.extent?.spatial}');
  print('Temporal extent: ${collectionMeta.extent?.temporal}');

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

  // next read actual data (wind mills) from this collection

  // `items` is used for filtered queries, here bounding box, WGS 84 coordinates
  final items = await source.items(
    const BoundedItemsQuery(
      bbox: GeoBox(west: 5.03, south: 52.21, east: 5.06, north: 52.235),
    ),
  );
  // Read features from "dutch_windmills" matching the bbox filter.
  // (... code omitted ...)

  // `BoundedItemsQuery` provides also following filters:
  // - `limit` sets the maximum number of features returned
  // - `timeFrame` sets a temporal filter
  // - `bboxCrs` sets the CRS used by the `bbox` filter (*)
  // - `crs` sets the CRS used by geometry objects of response features (*)
  // 
  // (*) supported only by services conforming to OGC API Features - Part 2: CRS

  // `items` allows also setting property filters when supported by a service.
  final itemsByPlace = await source.items(
    const BoundedItemsQuery(
      extra: {'PLAATS': 'Uitgeest'},
    ),
  );
  // Read features from "dutch_windmills" filtered by a place name.
  // (... code omitted ...)

  // samples above accessed feature collections (resuls with 0 to N features)
  // it's possible to access also a single specific feature item by ID
  final item = await source.itemById('Molens.5');
  // Read a single feature by ID from "dutch_windmills".
  // (... code omitted ...)
}
```

As mentioned above, see 
[ogcapi_features_example.dart](example/ogcapi_features_example.dart) for the
full sample.

## Reference

### Feature data interfaces

A diagram describing the most important interfaces and classes needed when
interacting with API services compliant with the
[OGC API Features](https://ogcapi.ogc.org/features/) standard:

<img src="https://raw.githubusercontent.com/navibyte/geospatial/main/dart/geodata/assets/diagrams/feature_data_interfaces.svg" width="100%" title="Feature data interfaces in the geodata package" />

The OGC API Features client created by `OGCAPIFeatures.http()` for some endpoint
has the following signature:

```dart
/// A feature service compliant with the OGC API Features standard.
abstract class OGCFeatureService {
  /// Get meta data (or "landing page" information) about this service.
  Future<OGCServiceMeta> meta();

  /// Conformance classes this service is conforming to.
  Future<OGCFeatureConformance> conformance();

  /// Get metadata about feature collections provided by this service.
  Future<Iterable<OGCCollectionMeta>> collections();

  /// Get a feature source for a feature collection identified by [id].
  Future<OGCFeatureSource> collection(String id);
}
```

The feature source returned by `collection()` provides following methods:

```dart
  /// Get metadata about the feature collection represented by this source.
  Future<OGCCollectionMeta> meta();

  /// Fetches a single feature by [id] from this source.
  ///
  /// An identifier should be an integer number (int or BigInt) or a string.
  Future<OGCFeatureItem> itemById(Object id);

  /// Fetches all features items from this source.
  ///
  /// An optional [limit] sets maximum number of items returned. If given, it
  /// must be a positive integer.
  ///
  /// This call accesses only one set of feature items (number of returned items
  /// can be limited).
  Future<OGCFeatureItems> itemsAll({int? limit});

  /// Fetches all features as paged sets from this source.
  ///
  /// An optional [limit] sets maximum number of items returned. If given, it
  /// must be a positive integer.
  ///
  /// This call returns a first set of feature items (number of returned items
  /// can be limited), with a link to an optional next set of feature items.
  Future<Paged<OGCFeatureItems>> itemsAllPaged({int? limit});

  /// Fetches a single feature by id (set in [query]) from this source.
  Future<OGCFeatureItem> item(ItemQuery query);

  /// Fetches features matching [query] from this source.
  ///
  /// This call accesses only one set of feature items (number of returned items
  /// can be limited).
  Future<OGCFeatureItems> items(BoundedItemsQuery query);

  /// Fetches features as paged sets matching [query] from this source.
  ///
  /// This call returns a first set of feature items (number of returned items
  /// can be limited), with a link to an optional next set of feature items.
  Future<Paged<OGCFeatureItems>> itemsPaged(BoundedItemsQuery query);
```

Methods accessing multiple feature items return a future of `OGCFeatureItems``
which provides:

```dart
  /// The wrapped feature collection.
  final FeatureCollection<Feature> collection;

  /// Links related to this object.
  Links get links;

  /// An optional coordinate reference system from "Content-Crs" response
  /// header.
  final CoordRefSys? contentCrs;

  /// The time stamp
  DateTime? get timeStamp;

  /// An optional count of items matched.
  int? get numberMatched;

  /// An optional count of items returned.
  int? get numberReturned;
```

Feature objects are available from the `collection` property. See the
[geospatial features](https://pub.dev/packages/geobase#geospatial-features)
chapter in the [geobase](https://pub.dev/packages/geobase) package for more
information about `Feature` and `FeatureCollection` objects.

### Packages

The **geodata** library contains also following partial packages, that can be
used to import only a certain subset instead of the whole **geodata** package:

Package            | Exports also | Description 
------------------ | ----------- | -----------------------------------------------
**common**         | | Common data structures and helpers (for links, metadata, paged responses).
**core**           | | Metadata and data source abstractions of geospatial Web APIs (ie. features).
**geojson_client** | common, core | A client-side data source to read GeoJSON data from web and file resources.
**ogcapi_features_client** |  common, core | A client-side data source to read features from OGC API Features services.

External packages `geodata` is depending on:
* [equatable](https://pub.dev/packages/equatable) for equality and hash utils
* [geobase](https://pub.dev/packages/geobase) for base geospatial data structures
* [http](https://pub.dev/packages/http) for a http client
* [meta](https://pub.dev/packages/meta) for annotations

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).
