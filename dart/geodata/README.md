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
* Client-side data source abstraction for geospatial feature service Web APIs
* Implementations to read geospatial features
  * [GeoJSON](https://geojson.org/) features from Web APIs or files
  * [OGC API Features](https://ogcapi.ogc.org/features/) based services (partial support)

The client-side support for the
[OGC API Features](https://ogcapi.ogc.org/features/) standard is not complete,
however key functionality of `Part1` of the standard is supported.

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
[Packages](#Packages) section below.

See also the [geobase](https://pub.dev/packages/geobase) package, used also by 
`geodata`, that provides geospatial data structures (coordinates, geometries,
features, metadata) and vector data format support (encoding and decoding) for
[GeoJSON](https://geojson.org/).  

## Example

This sample shows to read GeoJSON features from a web resource using a HTTP 
fetcher.

Please see other [examples](example/geodata_example.dart) too.

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
