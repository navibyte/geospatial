[![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

<a title="Public domain, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Winkel_triple_projection_SW.jpg"><img alt="Equirectangular projection" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/projections/winkel/320px-Winkel_triple_projection_SW.jpg" align="right"></a>

Geospatial feature service Web APIs with support for 
[GeoJSON](https://geojson.org/) and 
[OGC API Features](https://ogcapi.ogc.org/features/) clients for Dart.

## Features

✨ New: Updated with latest [geobase](https://pub.dev/packages/geobase) version
0.3.0 based on [Dart](https://dart.dev/) SDK 2.17, and no longer with dependency
on [geocore](https://pub.dev/packages/geocore).

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
  geodata: ^0.10.0
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
  print('GeoJSON features from HTTP');
  await _readFeatures(
    geoJsonHttpClient(
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
    if (e.cause != null) {
      print('Cause: ${e.cause}');
    }
    if (e.trace != null) {
      print(e.trace);
    }
  } catch (e, st) {
    print('Reading GeoJSON resource failed: $e');
    print(st);
  }
}
```

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

You can use `ogcApiFeaturesHttpClient` function to access a feature service
instance by giving at least an endpoint URL for an API service you want to use.
The class for service instances has following methods:

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

Actual data, features with geometries and properties in a feature collection, is
accessed by `collection` method. This returns a future for a feature source
(`OGCFeatureSource`) that let's you access feature items by following methods:

```dart
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

See [geodata_example.dart](example/geodata_example.dart) for a sample how to
read metadata and feature items from an API service conforming to
[OGC API Features](https://ogcapi.ogc.org/features/).

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
