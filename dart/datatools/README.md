# :cloud: Datatools

[![pub package](https://img.shields.io/pub/v/datatools.svg)](https://pub.dev/packages/datatools) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

**Datatools** is a library package for [Dart](https://dart.dev/) and 
[Flutter](https://flutter.dev/) mobile developers to help on accessing Web APIs
and other data sources. 

Key features:
* Web API client abstraction.
* Web API client binding to HTTP.
* Metadata structures to handle links.

Please note that **all features and classes are still under heavy development**,
and not finished yet.

## :package: Package

This is a [Dart](https://dart.dev/) code package named `datatools` under the 
[geospatial](https://github.com/navibyte/geospatial) repository. 

**This package is at the alpha-stage, breaking changes are possible.** 

The package is associated with (but not depending on) the
[geodata](https://pub.dev/packages/geodata) package. The `datatools` package 
contains non-geospatial Web API data structures and utilities that are extended
and utilized by the `geodata` package to provide client-side access for some
geospatial APIs. 

## :electric_plug: Installing

The package supports Dart [null-safety](https://dart.dev/null-safety) and 
using it requires the latest SDK from a beta channel. However your package using
it doesn't have to be migrated to null-safety yet.    

Please see the official 
[null-safety migration guide](https://dart.dev/null-safety/migration-guide)
how to switch to the latest beta release of Dart or Flutter SDKs.

In the `pubspec.yaml` of your project add the dependency:

```yaml
dependencies:
  datatools: ^0.4.0-nullsafety.0  
```

Please note that following dependencies used by `datatools` are not yet migrated 
to [null-safety](https://dart.dev/null-safety) or null-safety version is not
depended from the `datatools` package: 

* [http](https://pub.dev/packages/http)
* [http_parser](https://pub.dev/packages/http_parser)

## :house_with_garden: Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## :copyright: License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).