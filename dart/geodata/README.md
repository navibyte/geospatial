# Geospatial - geodata

A geospatial client reading [OGC API](https://ogcapi.ogc.org/) and other data 
sources for [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/) mobile developers.

Currently the package has a partial (and still quite limited) support for 
[OGC API Features](https://ogcapi.ogc.org/features/) services with functions
to read metadata and feature items.

**This package is at the alpha-stage, breaking changes are possible.** 

This is a [Dart](https://dart.dev/) code package named `geodata` under the 
[geospatial](https://github.com/navibyte/geospatial) repository. The package 
supports Dart [null-safety](https://dart.dev/null-safety).

## Installing

The package is designed null-safety in mind and requires SDK from beta channel:

```yaml
environment:
  sdk: '>=2.12.0-0 <3.0.0'
```

More information about how to switch to the latest beta release of Dart or 
Flutter SDKs is available in the official 
[null-safety migration guide](https://dart.dev/null-safety/migration-guide).
Please consult it first about null-safety.

Dependencies defined in the `pubspec.yaml` when using the package:

```yaml
dependencies:
  geodata: ^0.3.0-nullsafety.0  
```

Please note that following dependencies used by `geodata` are not yet migrated 
to [null-safety](https://dart.dev/null-safety) or null-safety version is not
depended from the `geodata` package: 

* [http](https://pub.dev/packages/http)
* [http_parser](https://pub.dev/packages/http_parser)

## Usage

An example how to setup an API client and a provider for 
[OGC API Features](https://ogcapi.ogc.org/features/) service.

Imports:

```dart
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
final items1 = await resource.itemsPaged(limit: 10);

// do something with feature items fetched

// check for next set (of max 10 features) and fetch it too if available
if (items1.hasNext) {
  final items2 = await items1.next();

  // do something with feature items fetched
}
```

Please see full [example code](example/geodata_example.dart) for more details.

## Authors

This project is authored by [Navibyte](https://navibyte.com).

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the [LICENSE](LICENSE).

