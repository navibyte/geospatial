[![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

<a title="Public domain, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Winkel_triple_projection_SW.jpg"><img alt="Equirectangular projection" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/projections/winkel/320px-Winkel_triple_projection_SW.jpg" align="right"></a>

Geospatial feature service Web APIs with support for 
[GeoJSON](https://geojson.org/) and 
[OGC API Features](https://ogcapi.ogc.org/features/) clients for Dart.

## Features

✨ New (2024-05-26): The new documentation website ([geospatial.navibyte.dev](https://geospatial.navibyte.dev/)) for the [geodata](https://geospatial.navibyte.dev/v1/geodata/)
package documentation published along with the stable version 1.2.0.

✨ New (2024-04-22):  The stable version 1.1.0 adds support for Newline-delimited GeoJSON. See the related [blog post](https://medium.com/@navibyte/decode-and-encode-geojson-wkt-and-wkb-in-dart-and-flutter-apps-ab2ef4ece2f1) about geobase changes.

✨ New (2023-10): The stable version 1.0.0 is now ready. See also the article [Geospatial tools for Dart - version 1.0 published](https://medium.com/@navibyte/geospatial-tools-for-dart-version-1-0-published-0f9673e510b3) at Medium.

✨ New (2023-07): better client-side support for OGC API Features (Part 1 and 2).

Key features:

* 🪄 Client-side data source abstraction for geospatial feature service Web APIs.
* 🌐 The [GeoJSON](https://geojson.org/) client to read features from static web resources and local files, supports also [Newline-delimited GeoJSON](https://stevage.github.io/ndgeojson/) data.
* 🌎 The [OGC API Features](https://ogcapi.ogc.org/features/) client to access metadata and feature items from a compliant geospatial Web API providing GeoJSON data.

Client-side support for the OGC API Features standard:

Standard part | Support in this package
------------- | -----------------------
[OGC API - Features - Part 1: Core](https://docs.ogc.org/is/17-069r4/17-069r4.html) | Supported for accessing metadata and GeoJSON feature collections.
[OGC API - Features - Part 2: Coordinate Reference Systems by Reference](https://docs.ogc.org/is/18-058r1/18-058r1.html) | Supported.
OGC API - Features - Part 3: Filtering (draft) | Partially supported (conformance classes, queryables, features filter).

## Documentation

Comprehensive guidance on how to use this package and about
*Geospatial tools for Dart* (the package is part of) is available on the
[geospatial.navibyte.dev](https://geospatial.navibyte.dev/) website.

Shortcuts to the [geodata](https://geospatial.navibyte.dev/v1/geodata/)
package documentation by chapters:

* [🌐 GeoJSON Web API client](https://geospatial.navibyte.dev/v1/geodata/geojson-client/)
* [🌎 OGC API Features client](https://geospatial.navibyte.dev/v1/geodata/ogcfeat-client/)

See also overview topics about *Geospatial tools for Dart*:

* [⛳️ Getting started](https://geospatial.navibyte.dev/v1/start/)
* [📖 Introduction](https://geospatial.navibyte.dev/v1/start/intro/)
* [💼 Code project](https://geospatial.navibyte.dev/reference/project/)
* [📚 API documentation](https://geospatial.navibyte.dev/reference/api/)

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
  geodata: ^1.2.1
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
> [geometries](https://geospatial.navibyte.dev/v1/geobase/geometry/),
> [geospatial features](https://geospatial.navibyte.dev/v1/geobase/features/)
> and [GeoJSON](https://geospatial.navibyte.dev/v1/geobase/formats/#geojson) in
> the [geobase](https://geospatial.navibyte.dev/v1/geobase/) package
> documentation.
> 
> 🚀 **Samples**: 
> The [Geospatial demos for Dart](https://github.com/navibyte/geospatial_demos)
> repository contains more sample code showing also how to use this package!

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

## Reference

### Documentation

Please see the [geospatial.navibyte.dev](https://geospatial.navibyte.dev/)
website for the [geodata](https://geospatial.navibyte.dev/v1/geodata/)
package documentation.

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).
