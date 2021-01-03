# Geodata

[![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

**Geodata** is a library package for [Dart](https://dart.dev/) and 
[Flutter](https://flutter.dev/) mobile developers to help on accessing 
[OGC API](https://ogcapi.ogc.org/) and other geospatial data sources. 

Currently the package has a partial (and still quite limited) support for 
[OGC API Features](https://ogcapi.ogc.org/features/) services with functions
to read metadata and feature items.

## Package

This is a [Dart](https://dart.dev/) code package named `geodata` under the 
[geospatial](https://github.com/navibyte/geospatial) repository. 

**This package is at the alpha-stage, breaking changes are possible.** 

The package is associated with and depending on the
[datatools](https://pub.dev/packages/datatools) package containing 
non-geospatial Web API data structures and utilities that are extended
and utilized by the `geodata` package to provide client-side access for
geospatial APIs. 

This package also utilizes the [geocore](https://pub.dev/packages/geocore) 
package for geometry, metadata and feature data structures and 
[GeoJSON](https://geojson.org/) parser, and the 
[attributes](https://pub.dev/packages/attributes) package for non-geospatial
data structures. 

## Installing

The package supports Dart [null-safety](https://dart.dev/null-safety) and 
using it requires the latest SDK from a beta channel. However your package using
it doesn't have to be migrated to null-safety yet.    

Please see the official 
[null-safety migration guide](https://dart.dev/null-safety/migration-guide)
how to switch to the latest beta release of Dart or Flutter SDKs.

In the `pubspec.yaml` of your project add the dependency:

```yaml
dependencies:
  geodata: ^0.4.0-nullsafety.0  
```

Please note that following dependencies used by `geodata` (indirect dependencies
via [datatools](https://pub.dev/packages/datatools)) are not yet migrated
to [null-safety](https://dart.dev/null-safety) or null-safety version is not
depended from the `datatools` package: 

* [http](https://pub.dev/packages/http)
* [http_parser](https://pub.dev/packages/http_parser)

## Libraries

The package contains following mini-libraries:

Library                  | Description 
------------------------ | -----------
**model_base**           | Data structures for client access of generic Web API clients.
**model_common**         | Data structures for client access of common geospatial Web APIs.
**model_features**       | Data structures for client access of "geospatial features" Web APIs.
**provider_common**      | An abstract client-side data provider to read common geospatial Web APIs.
**provider_features**    | An abstract client-side data provider to read "geospatial features" APIs.
**source_oapi_common**   | An abstract client-side data provider to read OGC API Common services.
**source_oapi_features** | A client-side data provider to read services conforming to OGC API Features.

For example to access a mini library you should use an import like:

```dart
import 'package:geodata/source_oapi_features.dart';
```

To use all libraries of the package:

```dart
import 'package:geodata/geodata.dart';
```

## Usage

An example how to setup an API client and a provider for 
[OGC API Features](https://ogcapi.ogc.org/features/) service.

Imports:

```dart
import 'package:datatools/datatools.dart';
import 'package:geodata/geodata.dart';
```

Setting up an API client and a feature provider:

```dart
// Create an API client accessing HTTP endpoints.
final client = HttpApiClient.endpoints([
  Endpoint.url(baseURL),
]);

// Create a feature provider for OGC API Features (OAPIF).
final provider = FeatureProviderOAPIF.client(client);
```

Now it's possible to access metadata (the provider implementation calls 
a landing page or '/', '/conformance' and '/collections' resources under a
base URL and combines all metadata fetched):

```dart
// Read metadata 
final meta = await provider.meta();

// do something with meta data accessed
```

Fetching items (or features of a OGC API Features service) as paged sets:

```dart
// Get feature resource for a collection by id
final resource = await provider.collection(collectionId);

// fetch feature items as paged results with max 10 features on one query
final items1 = await resource.itemsPaged(FeatureFilter(limit: 10));

// do something with feature items fetched

// check for next set (of max 10 features) and fetch it too if available
if (items1.hasNext) {
  final items2 = await items1.next();

  // do something with next set of feature items fetched
}
```

Please see full [example code](example/geodata_example.dart) for more details.

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the [LICENSE](LICENSE).

