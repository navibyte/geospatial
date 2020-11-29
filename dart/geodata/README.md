# Geospatial - geodata

A geospatial client reading OGC API and other data sources for 
[Dart](https://dart.dev/) and [Flutter](https://flutter.dev/) mobile developers.

**This package is at the alpha-stage, breaking changes are possible.** 

**This package supports Dart [null-safety](https://dart.dev/null-safety).**

This is a [Dart](https://dart.dev/) code package named `geodata` under the 
[geospatial](https://github.com/navibyte/geospatial) repository. 

## Usage

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
  geodata: ^0.1.0-nullsafety.0  
```

An example how to setup an API client and a provider for 
<a href="https://ogcapi.ogc.org/features/">OGC API Features</a> service.

At this alpha-stage the package supports only reading metadata from a service.
Other functions **are not yet supported**.

```dart
import 'package:geodata/geodata.dart';

Future<ProviderMeta> _readMeta(String baseURL) async {
  // Create an API client accessing HTTP endpoints.
  final client = HttpApiClient.endpoints([
    Endpoint.url(baseURL),
  ]);

  // Create a feature provider for OGC API Features (OAPIF).
  final provider = FeatureProviderOAPIF.client(client);

  // Read metadata 
  return provider.meta();
}
```

## Authors

This project is authored by **[Navibyte](https://navibyte.com)**.

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the [LICENSE](LICENSE).

