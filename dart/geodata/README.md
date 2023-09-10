[![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

<a title="Public domain, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Winkel_triple_projection_SW.jpg"><img alt="Equirectangular projection" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/projections/winkel/320px-Winkel_triple_projection_SW.jpg" align="right"></a>

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
OGC API - Features - Part 3: Filtering (draft) | Partially supported (conformance classes, queryables, features filter).

## Introduction

As a background you might want first to check a good
[introduction about OGC API Features](https://opengeospatial.github.io/e-learning/ogcapi-features/text/basic-main.html) or a video about the
[OGC API standard family](https://www.youtube.com/watch?v=xpw_VvcPjaE),
both provided by OGC (The Open Geospatial Consortium) itself.

The following diagram describes a decision flowchart to select a client class
and a feature source to access GeoJSON feature collections and feature items:

<img src="https://raw.githubusercontent.com/navibyte/geospatial/v0.12.0/dart/geodata/assets/diagrams/decision_flowchart.svg" width="100%" title="Decision flowchart to select a client class to access GeoJSON resources" />

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
  geodata: ^0.12.1
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
> and [GeoJSON](https://pub.dev/packages/geobase#vector-data-formats) in the
> documentation of the [geobase](https://pub.dev/packages/geobase) package.
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

#### Part 1: Core

The GeoJSON client discussed above allows reading data from a static web
resource or a local file. However most often geospatial APIs contains huge
datasets, and data items to be queried must be selected and filtered. 

The [OGC API Features](https://ogcapi.ogc.org/features/) standard by the
[Open Geospatial Consortium](https://www.ogc.org/) (or OGC) specifies this -
how data is discovered and accessed:

> OGC API Features provides API building blocks to create, modify and query 
> features on the Web. OGC API Features is comprised of multiple parts, each of 
> them is a separate standard. The "Core" part specifies the core 
> capabilities and is restricted to fetching features where geometries are 
> represented in the coordinate reference system WGS 84 with axis order
> longitude/latitude. Additional capabilities that address more advanced needs
> will be specified in additional parts. 

A compliant (according to `OGC API - Features - Part 1: Core`) API service
should provide at least following resources:

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

See [geodata_example.dart](example/geodata_example.dart) for a sample how to
read metadata and feature items from an API service conforming to
[OGC API Features](https://ogcapi.ogc.org/features/).

Most relevant portions of this sample:

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
  final openAPI = await meta.openAPI();
  final info = openAPI.content['info'] as Map<String, dynamic>;
  print('Terms of service: ${info['termsOfService']}');

  // conformance classes (text ids) informs the capabilities of the service
  final conformance = await client.conformance();
  // service should (at least) be compliant with Part 1 (Core + GeoJSON)
  if (!conformance.conformsToFeaturesCore(geoJSON: true)) {
    print('NOT compliant with Part 1 (Core, GeoJSON).');
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

  // **** next read actual data (wind mills) from this collection

  // `itemsAll` lets access all features on source (optionally limited by limit)
  final itemsAll = await source.itemsAll(
    limit: 2,
  );
  // (... code omitted ...)

  // `itemsAllPaged` helps paginating through a large dataset with many features
  // (here each page is limited to 2 features)
  Paged<OGCFeatureItems>? page = await source.itemsAllPaged(limit: 2);
  // (... code omitted ...)

  // `items` is used for filtered queries, here bounding box, WGS 84 coordinates
  final items = await source.items(
    const BoundedItemsQuery(
      limit: 2,
      bbox: GeoBox(west: 5.03, south: 52.21, east: 5.06, north: 52.235),
    ),
  );
  // (... code omitted ...)

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
  // (... code omitted ...)
}
```

As mentioned above, see [geodata_example.dart](example/geodata_example.dart) for
the full sample.

#### Part 2: Coordinate Reference Systems by Reference

The `Part 1: Core` defined feature services that support only accessing data
using WGS 84 longitude / latitude coordinates (with optional height or
elevation).

The second part of the `OGC API - Features` standard is
`Part 2: Coordinate Reference Systems by Reference` that specifies how servers
publish supported coordinate refererence systems (as CRS identifiers) and how
clients request and receive geospatial feature items whose geometries
(coordinates) are in "alternative coordinate reference systems" (other than
WGS 84 longitude/latitude).

The following example demonstrates these capabilities (see the full sample at
[ogcapi_features_crs_example.dart](example/ogcapi_features_crs_example.dart)): 

```dart
  // create an OGC API Features client for the open ldproxy demo service
  // (see https://demo.ldproxy.net/zoomstack for more info)
  final client = OGCAPIFeatures.http(
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
```

#### Part 3: Filtering

The third part - `Part 3: Filtering` of `OGC API - Features` - further extends
capabilities of feature services.

For example when `client` is `OGCFeatureService` and `source` is
`OGCFeatureSource`, and both are initialized just like in the previous samples,
then it's possible to check for the support of filtering, get queryable
properties, and utilize properties in simple (queryables as query parameters in
HTTP requests):

```dart
  // service should be compliant with OGC API Features - Part 3 (Filtering)
  final conformance = await client.conformance();
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

  // here query parameters is set to define a simple filter by a place name
  final itemsByPlace = await source.items(
    const BoundedItemsQuery(
      // queryables as query parameters (`PLAATS` is a queryable property)
      parameters: {
        'PLAATS': 'Uitgeest',
      },
    ),
  );
  // (... code omitted ...)
```

Queryable properties can also be utilized in more complex filters (based on the
`Common Query Language` or CQL2). See the API documentation of `items` and
`itemsPaged` methods in `OGCFeatureSource` for more information.

## Reference

### Feature data interfaces

A diagram describing the most important interfaces and classes needed when
interacting with API services compliant with the
[OGC API Features](https://ogcapi.ogc.org/features/) standard:

<img src="https://raw.githubusercontent.com/navibyte/geospatial/v0.12.0/dart/geodata/assets/diagrams/feature_data_interfaces.svg" width="100%" title="Feature data interfaces in the geodata package" />

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

  /// Get optional metadata about queryable properties for the feature
  /// collection represented by this source.
  ///
  /// Returns null if no "queryables" metadata is available for this feature
  /// source.
  Future<OGCQueryableObject?> queryables();

  /// Fetches a single feature by [id] from this source.
  ///
  /// An identifier should be an integer number (int or BigInt) or a string.
  Future<OGCFeatureItem> itemById(Object id);

  /// Fetches a single feature by id (set in [query]) from this source.
  Future<OGCFeatureItem> item(ItemQuery query);
  
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

  /// Fetches features matching [query] (and an optional [cql] query) from this
  /// source.
  ///
  /// If both [query] and [cql] are provided, then a service returns only
  /// features that match both [query] AND the [cql] query.
  ///
  /// This call accesses only one set of feature items (number of returned items
  /// can be limited).
  Future<OGCFeatureItems> items(
    BoundedItemsQuery query, {
    CQLQuery? cql,
  });

  /// Fetches features as paged sets matching [query] (and an optional [cql]
  /// query) from this source.
  ///
  /// If both [query] and [cql] are provided, then a service returns only
  /// features that match both [query] AND the [cql] query.
  ///
  /// This call returns a first set of feature items (number of returned items
  /// can be limited), with a link to an optional next set of feature items.
  Future<Paged<OGCFeatureItems>> itemsPaged(
    BoundedItemsQuery query, {
    CQLQuery? cql,
  });
```

Queries for `items` and `itemsPaged` are normally specified by
`BoundedItemsQuery` instances:

```dart
  /// An optional coordinate reference system used by [bbox].
  final CoordRefSys? bboxCrs;

  /// An optional [bbox] as a geospatial bounding filter (like `bbox`).
  final Box? bbox;

  /// An optional time frame as a temporal object (ie. instant or interval).
  final Temporal? timeFrame;

  /// An optional id defining a coordinate reference system for result data.
  final CoordRefSys? crs;

  /// Optional query parameters for queries as a map of named parameters.
  final Map<String, dynamic>? parameters;

  /// An optional [limit] setting maximum number of items returned.
  final int? limit;
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

The `queryables` metadata from a feature source is provide information about
queryable properties that a service supports:

```dart
/// Represents `Queryables` document for an OGC API service parsed from JSON
/// Schema data.
class OGCQueryableObject {
  /// JSON Schema based data representing `Queryables` document for an OGC API
  /// service.
  ///
  /// This is data that is directly parsed from JSON Schema data an OGC API
  /// Service has published. Use this for more detailed inspection of
  /// Queryables metadata when other class members are not enough.
  final Map<String, dynamic> content;

  /// The URI of the resource without query parameters.
  final String id;

  /// The schema id of JSON Schema data in content.
  ///
  /// Should be either "https://json-schema.org/draft/2019-09/schema" or
  /// "https://json-schema.org/draft/2020-12/schema" according to the
  /// `OGC API - Features - Part 3: Filtering` standard.
  final String schemaId;

  /// The human readable title for this queryable object.
  final String title;

  /// An optional human readable description.
  final String? description;

  /// If true, any properties are valid in filter expressions even when not
  /// declared in a queryable schema.
  final bool additionalProperties;

  /// A map of queryable properties for this queryable object.
  ///
  /// The map key represents a property name (that is accessible also from
  /// the `name` property of `OGCQueryableProperty` object).
  ///
  /// NOTE: currently this contains only non-geospatial properties that SHOULD
  /// have at least "type" and "title" attributes.
  final Map<String, OGCQueryableProperty> properties;
}

/// A queryable non-geospatial property.
class OGCQueryableProperty {
  /// The property name.
  final String name;

  /// The human readable title for this property.
  final String title;

  /// An optional human readable description.
  final String? description;

  /// The type for this property.
  ///
  /// According to the `OGC API - Features - Part 3: Filtering` standard a type
  /// SHOULD be one of the following:
  /// * `string` (string or temporal properties)
  /// * `number` / `integer` (numeric properties)
  /// * `boolean` (boolean properties)
  /// * `array` (array properties)
  ///
  /// In practise different OGC API Features implementations seem also to use
  /// different specifiers for types.
  final String type;
}
```

### Packages

The **geodata** library contains also following partial packages, that can be
used to import only a certain subset instead of the whole **geodata** package:

Package            | Exports also | Description 
------------------ | ----------- | -----------------------------------------------
**common**         | | Common data structures and helpers (for links, metadata, paged responses).
**core**           | | Metadata and data source abstractions of geospatial Web APIs (ie. features).
**formats**        | |  OpenAPI document and Common Query Language (CQL2) formats (partial support).
**geojson_client** | common, core | A client-side data source to read GeoJSON data from web and file resources.
**ogcapi_features_client** |  common, core, formats | A client-side data source to read features from OGC API Features services.

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
