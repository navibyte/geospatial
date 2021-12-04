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

**This package is at BETA stage, interfaces not fully final yet.** 

## Usage

This sample shows to read GeoJSON features from a web resource using a HTTP 
fetcher, and from a local file using a file fetcher.

Please see other [examples](example/geodata_example.dart) too.

```dart
import 'package:datatools/fetch_http.dart';

import 'package:geodata/geojson_features.dart';

Future<void> main(List<String> args) async {
  // read GeoJSON for earthquakes from web using HTTP fetcher
  print('GeoJSON features from HTTP');
  await _readFeatures(
    HttpFetcher.simple(
      endpoints: [
        Uri.parse('https://earthquake.usgs.gov/earthquakes/feed/v1.0/')
      ],
    ),
    'summary/2.5_day.geojson',
  );
}

Future<void> _readFeatures(Fetcher client, String collectionId) async {
  // create feature source using the given Fetch API client
  final source = FeatureSourceGeoJSON.of(
    client: client,
    meta: DataSourceMeta.collectionIds([collectionId], title: 'Earthquakes'),
  );

  // read features with error handling
  try {
    // get items or features from collection id, maximum 5 features returned
    final items = await source.items(
      collectionId,
      filter: const FeatureFilter(limit: 5),
    );

    // do something with features, in this sample just print them out
    for (final f in items.features) {
      print('Feature with id: ${f.id}');
      print('  geometry: ${f.geometry}');
      print('  properties:');
      for (final key in f.properties.keys) {
        print('    $key: ${f.properties[key]}');
      }
    }
  } on OriginException catch (e) {
    final msg = e.isNotFound ? 'not found' : 'status code ${e.statusCode}';
    print('Origin exception: $msg');
  } on Exception catch (e) {
    print('Other exception: $e');
  }
}
```

## Installing

The package supports Dart [null-safety](https://dart.dev/null-safety) and 
using it requires at least
[Dart 2.12](https://medium.com/dartlang/announcing-dart-2-12-499a6e689c87)
from the stable channel. 

In the `pubspec.yaml` of your project add the dependency:

```yaml
dependencies:
  geodata: ^0.7.1 
```

All dependencies used by `geodata` are also ready for 
[null-safety](https://dart.dev/null-safety)!

## Package

This is a [Dart](https://dart.dev/) code package named `geodata` under the 
[geospatial](https://github.com/navibyte/geospatial) repository. 

The package is associated with and depending on the
[datatools](https://pub.dev/packages/datatools) package containing 
non-geospatial tools to fetch data from HTTP and file resources. The `geodata` 
package then provides client-side access for geospatial APIs and data sources. 

This package also utilizes the [geocore](https://pub.dev/packages/geocore) 
package for geometry, metadata and feature data structures and 
[GeoJSON](https://geojson.org/) parser, and the 
[attributes](https://pub.dev/packages/attributes) package for non-geospatial
data structures. 

## Libraries

The package contains following mini-libraries:

Library               | Description 
----------------------| -----------
**api_common**        | Data source abstraction for client access of common geospatial Web APIs.
**api_features**      | Data source abstraction for client access of geospatial features Web APIs.
**geojson_features**  | A client-side data source to read [GeoJSON](https://geojson.org/) features from a Web API or files.
**oapi_common**       | Data source abstraction for client access of [OGC API Common](https://ogcapi.ogc.org/common/) based services.
**oapi_features**     | A client-side data source to read features from [OGC API Features](https://ogcapi.ogc.org/features/) services.

For example to access a mini library you should use an import like:

```dart
import 'package:geodata/oapi_features.dart';
```

To use all libraries of the package:

```dart
import 'package:geodata/geodata.dart';
```

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).

