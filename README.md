# :compass: Geospatial tools for Dart 

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/navibyte.svg?style=social&label=Follow%20%40navibyte)](https://twitter.com/navibyte)

**Geospatial** data structures, tools and utilities for 
[Dart](https://dart.dev/) and [Flutter](https://flutter.dev/) mobile developers.

Please see also generic (non-geospatial) data structures, tools and utilities at
the separate [Dataflow tools for Dart](https://github.com/navibyte/dataflow)
repository.

Packages and documentation are published at [pub.dev](https://pub.dev/). 

Latest package releases:

Package @ pub.dev | Version | Documentation | Example code 
----------------- | --------| ------------- | -----------
:globe_with_meridians: [geocore](https://pub.dev/packages/geocore) | [![pub package](https://img.shields.io/pub/v/geocore.svg)](https://pub.dev/packages/geocore) | [API reference](https://pub.dev/documentation/geocore/latest/) | [Example](https://pub.dev/packages/geocore/example)
:earth_americas: [geodata](https://pub.dev/packages/geodata) | [![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) | [API reference](https://pub.dev/documentation/geodata/latest/) | [Example](https://pub.dev/packages/geodata/example)

Previously part of this repository, but starting from the version 0.6.0 code for
these is hosted at the [dataflow](https://github.com/navibyte/dataflow)
repository:

Package @ pub.dev | Version | Documentation | Example code 
----------------- | --------| ------------- | -----------
:spiral_notepad: [attributes](https://pub.dev/packages/attributes) | [![pub package](https://img.shields.io/pub/v/attributes.svg)](https://pub.dev/packages/attributes) | [API reference](https://pub.dev/documentation/attributes/latest/) | [Example](https://pub.dev/packages/attributes/example)
:cloud: [datatools](https://pub.dev/packages/datatools) | [![pub package](https://img.shields.io/pub/v/datatools.svg)](https://pub.dev/packages/datatools) | [API reference](https://pub.dev/documentation/datatools/latest/) | [Example](https://pub.dev/packages/datatools/example)

All packages supports Dart [null-safety](https://dart.dev/null-safety) and 
using them requires at least
[Dart 2.12](https://medium.com/dartlang/announcing-dart-2-12-499a6e689c87)
from the stable channel. Please see the official 
[null-safety migration guide](https://dart.dev/null-safety/migration-guide).

## :page_facing_up: Code

**This repository is at BETA stage, interfaces not fully final yet.** 

This repository contains the following [Dart](https://dart.dev/) code 
packages:

Code @ GitHub | SDK | Description 
------------- | --- | -----------
:globe_with_meridians: [geocore](dart/geocore) | Dart | Geospatial data structures (features, geometry and metadata) and utilities [GeoJSON](https://geojson.org/) parser). 
:earth_americas: [geodata](dart/geodata) | Dart | A geospatial client to read [GeoJSON](https://geojson.org/) and other geospatial data sources. 

## :newspaper_roll: News

2021-04-25
* BETA version 0.6.0
* Some code packages were moved out from this repository to the new [dataflow](https://github.com/navibyte/dataflow) repository as they are not *geospatial* at all
  * [attributes](https://pub.dev/packages/attributes)
  * [datatools](https://pub.dev/packages/datatools)
* [Lint rules and analysis options updated](https://github.com/navibyte/geospatial/issues/8)
* Also `implicit-casts` and `implicit-dynamic` set to false requiring code changes

2021-03-03
* BETA version 0.5.0 with stable sound null-safety on all packages requiring the stable [Dart 2.12](https://medium.com/dartlang/announcing-dart-2-12-499a6e689c87)

2021-02-28 
* the first BETA version 0.5.0
* preparing to stabilize null-safety features as described by the official blog:
  * [Preparing the Dart and Flutter ecosystem for null safety](https://medium.com/dartlang/preparing-the-dart-and-flutter-ecosystem-for-null-safety-e550ce72c010)
* [datatools](https://pub.dev/packages/datatools) totally refactored
  * Fetch API abstraction (content, control data, exceptions, fetch interface).
  * Fetch API binding to HTTP and HTTPS resources (using [http](https://pub.dev/packages/http)).
  * Fetch API binding to file resources (based on `dart:io`).
* [geodata](https://pub.dev/packages/geodata) also refactored, now with data source implementations:
  * [GeoJSON](https://geojson.org/) features from Web APIs or files
  * [OGC API Features](https://ogcapi.ogc.org/features/) based services
* other cleanup on other packages too

2021-01-10 
* latest alpha version 0.4.1
* Point classes in [geocore](dart/geocore) refactored to have `num` getters 

2021-01-03 
* alpha version 0.4.0
* refactored some code to new packages:
  * [attributes](https://pub.dev/packages/attributes)
  * [datatools](https://pub.dev/packages/datatools)

2020-11-29 
* initial alpha version 0.1.0
* designed to Dart [null-safety](https://dart.dev/null-safety) from start
* the first version with following packages
  * [geocore](https://pub.dev/packages/geocore)
  * [geodata](https://pub.dev/packages/geodata)

## :house_with_garden: Authors

This project is authored by [Navibyte](https://navibyte.com).

## :copyright: License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the [LICENSE](LICENSE).


## :star: Links and other resources

Some external links and other resources.

### Geospatial data formats and APIs

Geospatial:
* [GeoJSON](https://geojson.org/) based on [RFC 7946](https://tools.ietf.org/html/rfc7946)
* [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) (Well-known text representation of geometry)  
* [Coordinate Reference Systems](https://www.w3.org/2015/spatial/wiki/Coordinate_Reference_Systems) by W3C
* [EPSG](https://epsg.org/home.html) (Geodetic Parameter Dataset)

OGC (The Open Geospatial Consortium) related:
* [OGC APIs](https://ogcapi.ogc.org/)
  * [OGC API Common](https://ogcapi.ogc.org/common/)
  * [OGC API Features](https://ogcapi.ogc.org/features/)
  * [OGC API Features - demo services](https://github.com/opengeospatial/ogcapi-features/blob/master/implementations.md)
* [OGC Web API Guidelines](https://github.com/opengeospatial/OGC-Web-API-Guidelines)

W3C
* [Spatial Data on the Web Best Practices](https://www.w3.org/TR/sdw-bp/)

### Dart and Flutter programming

SDKs:
* [Dart](https://dart.dev/)
* [Flutter](https://flutter.dev/) 

Latest on SDKs
* [Dart 2.12](https://medium.com/dartlang/announcing-dart-2-12-499a6e689c87)
* [Flutter 2](https://developers.googleblog.com/2021/03/announcing-flutter-2.html)
* [What’s New in Flutter 2](https://medium.com/flutter/whats-new-in-flutter-2-0-fe8e95ecc65)

Packages
* [pub.dev](https://pub.dev/)

Null-safety:
* Dart [null-safety](https://dart.dev/null-safety)
* The official [null-safety migration guide](https://dart.dev/null-safety/migration-guide)
* [Preparing the Dart and Flutter ecosystem for null safety](https://medium.com/dartlang/preparing-the-dart-and-flutter-ecosystem-for-null-safety-e550ce72c010)

Guidelines
* [Effective Dart](https://dart.dev/guides/language/effective-dart)

Roadmaps
* [Flutter roadmap](https://github.com/flutter/flutter/wiki/Roadmap)

### Dart and Flutter libraries

There are thousands of excellent libraries available at 
[pub.dev](https://pub.dev/).

Here listed only those that are used (depended directly) by code packages of
this repository:

Package @ pub.dev | Code @ GitHub | Description
----------------- | ------------- | -----------
[equatable](https://pub.dev/packages/equatable) | [felangel/equatable](https://github.com/felangel/equatable) | Simplify Equality Comparisons | A Dart abstract class that helps to implement equality without needing to explicitly override == and hashCode.
[meta](https://pub.dev/packages/meta) | [dart-lang/sdk](https://github.com/dart-lang/sdk/tree/master/pkg/meta) | This package defines annotations that can be used by the tools that are shipped with the Dart SDK.
[synchronized](https://pub.dev/packages/synchronized) | [tekartik/synchronized.dart](https://github.com/tekartik/synchronized.dart/tree/master/synchronized) | Basic lock mechanism to prevent concurrent access to asynchronous code.
