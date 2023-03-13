[![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

<a title="Public domain, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Winkel_triple_projection_SW.jpg"><img alt="Equirectangular projection" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/projections/winkel/320px-Winkel_triple_projection_SW.jpg" align="right"></a>

Geospatial feature service Web APIs with support for 
[GeoJSON](https://geojson.org/) and 
[OGC API Features](https://ogcapi.ogc.org/features/) clients for Dart.

## Features

Key features:

* 🪄 Client-side data source abstraction for geospatial feature service Web APIs
* 🌐 The [GeoJSON](https://geojson.org/) client to read features from static web resources and local files
* 🌎 The [OGC API Features](https://ogcapi.ogc.org/features/) client to access metadata and feature items from a compliant geospatial Web API providing GeoJSON data

The client-side support for the
[OGC API Features](https://ogcapi.ogc.org/features/) standard is not complete,
however key functionality of `Part1 : Core` of the standard is supported.

## Usage

The package requires at least [Dart](https://dart.dev/) SDK 2.17, and it
supports all [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/)
platforms.

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  geodata: ^0.11.0
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
> repository contains more sample code showing also how to use this package! But
> read the documentation below first.

## Introduction

See [geodata_example.dart](example/geodata_example.dart) for a simple CLI tool
reading metadata and feature items from GeoJSON and OGC API Features data 
sources.

To use the GeoJSON client for a remote web resource:
1. Get a feature source with `GeoJSONFeatures.http(location: Uri.parse('...'))`
2. Access feature items from a source using `source.itemsAll()`

To use the GeoJSON client for a local reosurce like a file:
1. Get a feature source with `GeoJSONFeatures.any(() async => File('...').readAsString())`
2. Access feature items from a source using `source.itemsAll()`

To use the OGC API Features client for a remote Web API:
1. Get a client instance with `OGCAPIFeatures.http(endpoint: Uri.parse('...'))`
2. Access metadata using `client.meta()`, `client.conformance()` and `client.collections()` as needed
3. Get a feature source for a specific collection with `client.collection('...')` 
4. Access metadata for a collection with `source.meta()`
5. Access feature items from a collection using `source.items()` and `source.itemsAll()` or a single feature using `source.itemsById()`
6. Also paginated access is supported by `source.itemsPaged()` and `source.itemsAllPaged()`

## GeoJSON client

The GeoJSON client allows fetching and reading geospatial feature collections
with their geometry objects (ie. point, line string, polygon, multi point,
multi line string, multi polygon and geometry collection) from following
resource types:
* a web resource (by URL) containing GeoJSON content - data is fetched using the HTTP client (as provided by the [http](https://pub.dev/packages/http) package)
* custom resources, ie. a local file or an app bundled containing valid GeoJSON data

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

## OGC API Features client

The GeoJSON client discussed above allows reading data from a static web
resource or a local file. However most often geospatial APIs contains huge
datasets, and data items to be queried must be selected and filtered. 

The [OGC API Features](https://ogcapi.ogc.org/features/) standard by the
[Open Geospatial Consortium](https://www.ogc.org/) (or OGC) specifies this -
how data is discovered and accessed, or as described by the standard itself:

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

This package supports key features of the `Part1 : Core` specification of the
[OGC API Features](https://ogcapi.ogc.org/features/) standard. 

To access such a service create a client using the `OGCAPIFeatures.http`
factory, and then get a feature source (`OGCFeatureSource`) for a collection
using `collection()` method of a client. This collection source provides methods
to access metadata and actual data (feature items).

See [ogcapi_features_example.dart](example/ogcapi_features_example.dart) for a
sample how to read metadata and feature items from an API service conforming to
[OGC API Features](https://ogcapi.ogc.org/features/).

Some key portions of this sample:

```dart
import 'package:geobase/coordinates.dart';
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

  // get a feature source (`OGCFeatureSource`) for this collection
  final source = await client.collection('dutch_windmills');

  // the source for the collection also provides some metadata
  final collectionMeta = await source.meta();
  print('');
  print('Collection: ${collectionMeta.id} / ${collectionMeta.title}');
  print('Description: ${collectionMeta.description}');
  print('Spatial extent: ${collectionMeta.extent?.spatial}');
  print('Temporal extent: ${collectionMeta.extent?.temporal}');

  // next read actual data (wind mills) from this collection

  // `itemsAll` lets access all features on source (optionally limited by limit)
  final itemsAll = await source.itemsAll(
    limit: 2,
  );
  // Read max 2 (limit) features from "dutch_windmills" collection
  // (... code omitted ...)

  // `itemsAllPaged` helps paginating through a large dataset with many features
  // (here each page is limited to 2 features, and max 3 pages are looped)
  var pageIndex = 0;
  Paged<OGCFeatureItems>? page = await source.itemsAllPaged(limit: 2);
  while (page != null && pageIndex <= 2) {
    // Read page $pageIndex with max 2 features in paginated access
    // (... code omitted ...)

    page = await page.next();
    pageIndex++;
  }

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
  // 
  // In this case check the following queryables resource from the service: 
  // https://demo.pygeoapi.io/master/collections/dutch_windmills/queryables
  // (currently the geodata client does not decode queryables yet)
  final itemsByPlace = await source.items(
    const BoundedItemsQuery(
      extra: {'PLAATS': 'Uitgeest'},
    ),
  );
  // Read features from "dutch_windmills" filtered by a place name.
  // (... code omitted ...)

  // `itemsPaged` is used for paginated access on filtered queries
  // (not demostrated here, see `itemsAllPaged` sample above about paggination)

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

An OGC API Features client created by `OGCAPIFeatures.http` has the following
signature:

```dart
/// A feature service compliant with the OGC API Features standard.
abstract class OGCFeatureService {
  /// Get meta data (or "landing page" information) about this service.
  Future<ResourceMeta> meta();

  /// Conformance classes this service is conforming to.
  Future<Iterable<String>> conformance();

  /// Get metadata about feature collections provided by this service.
  Future<Iterable<CollectionMeta>> collections();

  /// Get a feature source for a feature collection identified by [id].
  Future<OGCFeatureSource> collection(String id);
}
```

The feature source returned by `collection()` provides following methods:

```dart
  /// Get metadata about the feature collection represented by this source.
  Future<CollectionMeta> meta();

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
  Future<OGCFeatureItem> itemsAll({int? limit});

  /// Fetches all features as paged sets from this source.
  ///
  /// An optional [limit] sets maximum number of items returned. If given, it
  /// must be a positive integer.
  ///
  /// This call returns a first set of feature items (number of returned items
  /// can be limited), with a link to an optional next set of feature items.
  Future<Paged<OGCFeatureItem>> itemsAllPaged({int? limit});

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

## Reference

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
