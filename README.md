# :compass: Geospatial tools for Dart 

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/navibyte.svg?style=social&label=Follow%20%40navibyte)](https://twitter.com/navibyte) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis) 

<a title="Stefan Kühn (Fotograf), CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Azimutalprojektion-schief_kl-cropped.png"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/projections/azimutal/Azimutalprojektion-schief_kl-cropped.png" align="right"></a>

**Geospatial** data structures, tools and utilities for 
[Dart](https://dart.dev/) and [Flutter](https://flutter.dev/).

[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/) [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)

## :package: Packages

[Dart](https://dart.dev/) code packages published at 
[pub.dev](https://pub.dev/publishers/navibyte.com/packages):

Code           | Package | Description 
-------------- | --------| -----------
:triangular_ruler: [geobase](dart/geobase) | [![pub package](https://img.shields.io/pub/v/geobase.svg)](https://pub.dev/packages/geobase) | Geospatial coordinates, projections, tiling schemes, and data writers for [GeoJSON](https://geojson.org/) and [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry).
:globe_with_meridians: [geocore](dart/geocore) | [![pub package](https://img.shields.io/pub/v/geocore.svg)](https://pub.dev/packages/geocore) | Geospatial data (points, geometry, features, meta) structures, and parsers ([GeoJSON](https://geojson.org/), [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)).
:earth_americas: [geodata](dart/geodata) | [![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) | A geospatial API client to read [GeoJSON](https://geojson.org/) and other geospatial data sources.  

## :sparkles: Features

Key features of the [geobase](https://pub.dev/packages/geobase) package:

* 🌐 *geographic* positions and bounding boxes (longitude-latitude-elevation)
* 🗺️ *projected* positions and bounding boxes (cartesian XYZ)
* 🏗️ coordinate transformations and projections (initial support)
* 🔢 tiling schemes and tile matrix sets (web mercator, global geodetic)
* 📅 temporal data structures (instant, interval) and spatial extents
* 📃 geospatial data writers for features, geometries, coordinates, properties:
  * 🌎 supported formats: [GeoJSON](https://geojson.org/) 
* 📃 geospatial data writers for geometries and coordinates:
  * 🪧 supported formats: [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)

Key features of the [geocore](https://pub.dev/packages/geocore) package:

* 🚀 geospatial data structures (geometry, features and metadata)
* 🌐 *geographic* coordinates (longitude-latitude)
* 🗺️ *projected* coordinates (cartesian XYZ)
* 🔷 geometry primitives (bounds or bbox, point, line string, polygon)
* 🧩 multi geometries (multi point, multi line string, multi polygon, geometry collections)
* ⭐ feature objects (with id, properties and geometry) and feature collections
* 🌎 [GeoJSON](https://geojson.org/) data parser
* 🪧 [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) 
(Well-known text representation of geometry) data parser 

Key features of the [geodata](https://pub.dev/packages/geodata) package:

* Client-side data source abstraction for geospatial feature service Web APIs
* Implementations to read geospatial features
  * [GeoJSON](https://geojson.org/) features from Web APIs or files
  * [OGC API Features](https://ogcapi.ogc.org/features/) based services (partial support)

## :newspaper_roll: News

2022-06-18
* [geobase](https://pub.dev/packages/geobase/versions/0.2.0) (0.2.0), see [changelog](dart/geobase/CHANGELOG.md#020) for details
  * ✨ New: Tiling schemes and tile matrix sets (web mercator, global geodetic). 
Also other improvements on coordinates, and refactorings on the code structure.  
* [geocore](https://pub.dev/packages/geocore/versions/0.9.0) (0.9.0), see [changelog](dart/geocore/CHANGELOG.md#090) for details
* [geodata](https://pub.dev/packages/geodata/versions/0.9.0) (0.9.0), see [changelog](dart/geodata/CHANGELOG.md#090) for details

2022-03-09
* [geobase](https://pub.dev/packages/geobase/versions/0.1.0) (0.1.0), see [changelog](dart/geobase/CHANGELOG.md#010) for details
* [geocore](https://pub.dev/packages/geocore/versions/0.8.0) (0.8.0), see [changelog](dart/geocore/CHANGELOG.md#080) for details
* [geodata](https://pub.dev/packages/geodata/versions/0.8.0) (0.8.0), see [changelog](dart/geodata/CHANGELOG.md#080) for details

2022-02-06
* A new package `geobase` with code originating and generalized from `geocore`:
   * The pre-release version `0.1.0-a.0` of the upcoming BETA-release 0.1.0
   * [geobase](https://pub.dev/packages/geobase/versions/0.1.0-a.0)
* Also the pre-release version `0.8.0-a.9` of the upcoming BETA-release 0.8.0 for:
   * [geocore](https://pub.dev/packages/geocore/versions/0.8.0-a.9)
   * [geodata](https://pub.dev/packages/geodata/versions/0.8.0-a.9)


2022-01-09
* The pre-release version `0.8.0-a.7` of the upcoming BETA-release 0.8.0
   * [geocore](https://pub.dev/packages/geocore/versions/0.8.0-a.7)
   * [geodata](https://pub.dev/packages/geodata/versions/0.8.0-a.7)

2021-12-04
* The first pre-release of the upcoming 0.8.0 version of [geocore](https://pub.dev/packages/geocore/versions/0.8.0-a.2)
  * breaking changes with Feature classes, removed dependency to the [attributes](https://pub.dev/packages/attributes) package
  * also the preview of coordinate transformation abstractions and other enhancements

2021-10-31
* BETA version 0.7.2 [geocore](https://pub.dev/packages/geocore): 
  * Some text serialization enhancements on Point coordinate values: [#37](https://github.com/navibyte/geospatial/issues/37) and [#38](https://github.com/navibyte/geospatial/issues/38)
* Changes on all packages:
  * [Apply very_good_analysis 2.4.0+ lint rules #36](https://github.com/navibyte/geospatial/issues/36)

2021-10-09
* BETA version 0.7.1
* Changes on [geocore](https://pub.dev/packages/geocore):
  * [WKT parser - add support for parsing GEOMETRYCOLLECTION #24](https://github.com/navibyte/geospatial/issues/24)
* Changes on all packages:
  * [Apply very_good_analysis 2.3.0+ lint rules #33](https://github.com/navibyte/geospatial/issues/33)

2021-08-10
* BETA version 0.7.0
* Mostly relatively small changes, but required (breaking) changes due
  * updated dependency 0.7.1 on [attributes](https://pub.dev/packages/attributes)
    * required changes visible in Feature class and GeoJSON factories
* [Official Dart lint rules applied with recommend set](https://github.com/navibyte/geospatial/issues/32)

2021-05-22
* [geocore](dart/geocore) with new BETA version 0.6.2 (updated documentation)

2021-05-16
* [geocore](dart/geocore) with new BETA version 0.6.1
  * initial support for [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) or WKT
  * Also easier to use factories for points, line strings, polygons, etc.
    * Make geometries from arrays of num values.
    * Parse geometries from text with default implementation based on WKT.

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

## :building_construction: Roadmap

See [issues](https://github.com/navibyte/geospatial/issues).

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
* [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
* [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) (Well-known text representation of geometry)  
* [Coordinate Reference Systems](https://www.w3.org/2015/spatial/wiki/Coordinate_Reference_Systems) by W3C
* [EPSG](https://epsg.org/home.html) (Geodetic Parameter Dataset)

OGC (The Open Geospatial Consortium) related:
* [OGC APIs](https://ogcapi.ogc.org/)
  * [OGC API Common](https://ogcapi.ogc.org/common/)
  * [OGC API Features](https://ogcapi.ogc.org/features/)
  * [OGC API Features - demo services](https://github.com/opengeospatial/ogcapi-features/blob/master/implementations.md)
* [OGC Web API Guidelines](https://github.com/opengeospatial/OGC-Web-API-Guidelines)
* [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)

W3C
* [Spatial Data on the Web Best Practices](https://www.w3.org/TR/sdw-bp/)

### Dart and Flutter programming

SDKs:
* [Dart](https://dart.dev/)
* [Flutter](https://flutter.dev/) 

Latest on SDKs
* [Dart 2.17](https://medium.com/dartlang/dart-2-17-b216bfc80c5d) with enum member support, parameter forwarding to super classes, flexibility for named parameters, and more
* [Dart 2.17](https://medium.com/dartlang/dart-2-16-improved-tooling-and-platform-handling-dd87abd6bad1) with improved tooling and platform handling
* [Dart 2.15](https://medium.com/dartlang/dart-2-15-7e7a598e508a) with fast concurrency, constructor tear-offs, improved enums, and more
* [Dart 2.14](https://medium.com/dartlang/announcing-dart-2-14-b48b9bb2fb67) with Apple Silicon support, default lints etc.
* [Dart 2.13](https://medium.com/dartlang/announcing-dart-2-13-c6d547b57067) with new type aliases and more
* [Dart 2.12](https://medium.com/dartlang/announcing-dart-2-12-499a6e689c87) with sound null safety
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
[http](https://pub.dev/packages/http) | [dart-lang/http](https://github.com/dart-lang/http) | A composable API for making HTTP requests in Dart.
[meta](https://pub.dev/packages/meta) | [dart-lang/sdk](https://github.com/dart-lang/sdk/tree/master/pkg/meta) | This package defines annotations that can be used by the tools that are shipped with the Dart SDK.
[proj4dart](https://pub.dev/packages/proj4dart) | [maRci002/proj4dart](https://github.com/maRci002/proj4dart) | Proj4dart is a Dart library to transform point coordinates from one coordinate system to another, including datum transformations (Dart version of proj4js/proj4js).

In some previous releases also following are utilized:

Package @ pub.dev | Code @ GitHub | Description
----------------- | ------------- | -----------
[synchronized](https://pub.dev/packages/synchronized) | [tekartik/synchronized.dart](https://github.com/tekartik/synchronized.dart/tree/master/synchronized) | Basic lock mechanism to prevent concurrent access to asynchronous code.
