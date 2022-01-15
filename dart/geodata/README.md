<h2 align="center">GeoJSON and OGC API clients for Dart</h2>

[![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

## Features

* Client-side data source abstractions
  * common geospatial Web APIs
  * geospatial feature services
* Data source implementations to read geospatial features
  * [GeoJSON](https://geojson.org/) features from Web APIs or files
  * [OGC API Features](https://ogcapi.ogc.org/features/) based services
* Also (partially) conforming to following standards
  * [OGC API Common](https://ogcapi.ogc.org/common/)

## Package

**This package is at BETA stage, interfaces not fully final yet.** 

This is a [Dart](https://dart.dev/) package named `geodata` under the 
[geospatial](https://github.com/navibyte/geospatial) code repository. 

To use, add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  geodata: ^0.8.0-a.8
```

The package contains also following mini-libraries, that can be used to import
only a certain subset instead of the whole **geodata** library:

Library            | Exports also | Description 
------------------ | ----------- | -----------------------------------------------
**common**         | | Common data structures and helpers (for links, metadata, paged responses).
**core**           | | Metadata and data source abstractions of geospatial Web APIs (ie. features).
**geojson_client** | common, core | A client-side data source to read GeoJSON data from web and file resources.
**ogcapi_features_client** |  common, core | A client-side data source to read features from OGC API Features services.

All the mini-libraries have dependencies to 
[equatable](https://pub.dev/packages/equatable) and 
[geocore](https://pub.dev/packages/geocore) packages. The **geojson_client**
and **ogcapi_features_client** libraries depends also on the
[http](https://pub.dev/packages/http) package. The **geojson_client** package
uses `dart:io` functions for file access too.

## Usage

This sample shows to read GeoJSON features from a web resource using a HTTP 
fetcher, and from a local file using a file fetcher.

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
  } on FeatureException catch (e) {
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

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).
