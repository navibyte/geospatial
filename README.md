# :compass: Geospatial tools for Dart 

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/navibyte.svg?style=social&label=Follow%20%40navibyte)](https://twitter.com/navibyte)

**Geospatial** data structures, tools and utilities for 
[Dart](https://dart.dev/) and [Flutter](https://flutter.dev/) mobile developers.
Contains also some non-geospatial library packages.

Packages and documentation are published at [pub.dev](https://pub.dev/). 

Latest package releases:

Package @ pub.dev | Version | Documentation | Example code 
----------------- | --------| ------------- | -----------
:spiral_notepad: [attributes](https://pub.dev/packages/attributes) | [![pub package](https://img.shields.io/pub/v/attributes.svg)](https://pub.dev/packages/attributes) | [API reference](https://pub.dev/documentation/attributes/latest/) | [Example](https://pub.dev/packages/attributes/example)
:cloud: [datatools](https://pub.dev/packages/datatools) | [![pub package](https://img.shields.io/pub/v/datatools.svg)](https://pub.dev/packages/datatools) | [API reference](https://pub.dev/documentation/datatools/latest/) | [Example](https://pub.dev/packages/datatools/example)
:globe_with_meridians: [geocore](https://pub.dev/packages/geocore) | [![pub package](https://img.shields.io/pub/v/geocore.svg)](https://pub.dev/packages/geocore) | [API reference](https://pub.dev/documentation/geocore/latest/) | [Example](https://pub.dev/packages/geocore/example)
:earth_americas: [geodata](https://pub.dev/packages/geodata) | [![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) | [API reference](https://pub.dev/documentation/geodata/latest/) | [Example](https://pub.dev/packages/geodata/example)

All packages supports Dart [null-safety](https://dart.dev/null-safety) and using
them requires the latest SDK from a beta channel. However your package using
them doesn't have to be migrated to null-safety yet.    

Please see the official 
[null-safety migration guide](https://dart.dev/null-safety/migration-guide)
how to switch to the latest beta release of Dart or Flutter SDKs.

## :page_facing_up: Code

**This repository is at BETA stage, interfaces not fully final yet.** 

This repository contains the following [Dart](https://dart.dev/) code 
packages:

Code @ GitHub | SDK | Description 
------------- | --- | -----------
:spiral_notepad: [attributes](dart/attributes) | Dart | Data structures and utilities for values, identifiers and entities.
:cloud: [datatools](dart/datatools) | Dart | Utilities to fetch data from HTTP and file resources and other data sources.
:globe_with_meridians: [geocore](dart/geocore) | Dart | Geospatial data structures (features, geometry and metadata) and utilities [GeoJSON](https://geojson.org/) parser). 
:earth_americas: [geodata](dart/geodata) | Dart | A geospatial client to read ([GeoJSON](https://geojson.org/) and other geospatial data sources. 

## :newspaper_roll: News

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

Here listed only those that are used (depended) by code packages of this 
repository:

Package @ pub.dev | Code @ GitHub | Description
----------------- | ------------- | -----------
[equatable](https://pub.dev/packages/equatable) | [felangel/equatable](https://github.com/felangel/equatable) | Simplify Equality Comparisons | A Dart abstract class that helps to implement equality without needing to explicitly override == and hashCode.
[http](https://pub.dev/packages/http) | [dart-lang/http](https://github.com/dart-lang/http) | A composable API for making HTTP requests in Dart.
[http_parser](https://pub.dev/packages/http_parser) | [dart-lang/http_parser](https://github.com/dart-lang/http_parser) | A platform-independent Dart package for parsing and serializing HTTP formats.
[intl](https://pub.dev/packages/intl) | [dart-lang/intl](https://github.com/dart-lang/intl) | Internationalization and localization support.
[meta](https://pub.dev/packages/meta) | [dart-lang/sdk](https://github.com/dart-lang/sdk/tree/master/pkg/meta) | This package defines annotations that can be used by the tools that are shipped with the Dart SDK.
[path](https://pub.dev/packages/path) | [dart-lang/path](https://github.com/dart-lang/path) | A string-based path manipulation library.
[synchronized](https://pub.dev/packages/synchronized) | [tekartik/synchronized.dart](https://github.com/tekartik/synchronized.dart/tree/master/synchronized) | Basic lock mechanism to prevent concurrent access to asynchronous code.
