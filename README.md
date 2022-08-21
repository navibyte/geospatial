# :compass: Geospatial tools for Dart 

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/navibyte.svg?style=social&label=Follow%20%40navibyte)](https://twitter.com/navibyte) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis) 

<a title="Stefan Kühn (Fotograf), CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Azimutalprojektion-schief_kl-cropped.png"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/projections/azimutal/Azimutalprojektion-schief_kl-cropped.png" align="right"></a>

**Geospatial** data structures, tools and utilities for 
[Dart](https://dart.dev/) and [Flutter](https://flutter.dev/) - coordinates,
geometries, feature objects, metadata, projections, tiling schemes, vector data
models and formats, and gespatial Web APIs.

[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/) [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)

## :package: Packages

[Dart](https://dart.dev/) code packages published at 
[pub.dev](https://pub.dev/publishers/navibyte.com/packages):

Code           | Package | Description 
-------------- | --------| -----------
:globe_with_meridians: [geobase](dart/geobase) | [![pub package](https://img.shields.io/pub/v/geobase.svg)](https://pub.dev/packages/geobase) | Geospatial data structures (coordinates, geometries, features, metadata), projections and tiling schemes. Vector data format support for [GeoJSON](https://geojson.org/), [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) and [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary).
:earth_americas: [geodata](dart/geodata) | [![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) | Geospatial feature service Web APIs with support for [GeoJSON](https://geojson.org/) and [OGC API Features](https://ogcapi.ogc.org/features/) clients.

## :sparkles: Features

Key features of the [geobase](https://pub.dev/packages/geobase) package:

* 🌐 geographic (longitude-latitude) and projected positions and bounding boxes
* 🧩 simple geometries (point, line string, polygon, multi point, multi line string, multi polygon, geometry collection)
* 🔷 features (with id, properties and geometry) and feature collections
* 📅 temporal data structures (instant, interval) and spatial extents
* 📃 vector data formats supported ([GeoJSON](https://geojson.org/), [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry), [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary)
)
* 🗺️ coordinate projections (web mercator + based on the external [proj4dart](https://pub.dev/packages/proj4dart) library)
* 🔢 tiling schemes and tile matrix sets (web mercator, global geodetic)

Key features of the [geodata](https://pub.dev/packages/geodata) package:

* Client-side data source abstraction for geospatial feature service Web APIs
* Implementations to read geospatial features
  * [GeoJSON](https://geojson.org/) features from Web APIs or files
  * [OGC API Features](https://ogcapi.ogc.org/features/) based services (partial support)

## :newspaper_roll: News

2022-08-21
* [geobase](https://pub.dev/packages/geobase/versions/0.3.0) (0.3.0), see [changelog](dart/geobase/CHANGELOG.md#030) for details
  * ✨ New: Data structures for simple geometries, features and feature collections.
  * ✨ New: Support for [Well-known binary](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary) (WKB). Text and binary data formats, encodings and content interfaces also redesigned.  
* [geodata](https://pub.dev/packages/geodata/versions/0.10.0) (0.10.0), see [changelog](dart/geodata/CHANGELOG.md#0100) for details
  * ✨ New: Updated with latest [geobase](https://pub.dev/packages/geobase) version 0.3.0, and no longer with dependency on [geocore](https://pub.dev/packages/geocore).
* [geocore](https://pub.dev/packages/geocore/versions/0.10.0) (0.10.0), see [changelog](dart/geocore/CHANGELOG.md#0100) for details

See also older news in the [changelog](CHANGELOG.md) of this repository.

## :building_construction: Roadmap

🧩 See [open issues](https://github.com/navibyte/geospatial/issues) for planned features, requests for change, and observed bugs.

💡 Any comments, questions, suggestions of new features and other other
contributions are welcome, of course!

🪄 New features shall be **actively added and development continues** on 
[geobase](https://pub.dev/packages/geobase) and 
[geodata](https://pub.dev/packages/geodata) packages. 

⚠️ However after the `geocore` version 0.10.0 (published at 2022-08-21), no new
features are currently planned on the
[geocore](https://pub.dev/packages/geocore) package. Still this package too
shall be maintained as a part of this repository.

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
* [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary) (Well-known binary)
* [Coordinate Reference Systems](https://www.w3.org/2015/spatial/wiki/Coordinate_Reference_Systems) by W3C
* [EPSG](https://epsg.org/home.html) (Geodetic Parameter Dataset)
* [World Geodetic System](https://en.wikipedia.org/wiki/World_Geodetic_System), see also [EPSG:4326](https://epsg.io/4326) about WGS 84
* [Web Mercator projection](https://en.wikipedia.org/wiki/Web_Mercator_projection), see also [EPSG:3857](https://epsg.io/3857) and [Bing Maps Tile System](https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system)

OGC (The Open Geospatial Consortium) related:
* [OGC APIs](https://ogcapi.ogc.org/)
  * [OGC API Common](https://ogcapi.ogc.org/common/)
  * [OGC API Features](https://ogcapi.ogc.org/features/)
  * [OGC API Features - demo services](https://github.com/opengeospatial/ogcapi-features/blob/master/implementations.md)
* [OGC Web API Guidelines](https://github.com/opengeospatial/OGC-Web-API-Guidelines)
* [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
* [OGC Two Dimensional Tile Matrix Set](https://docs.opengeospatial.org/is/17-083r2/17-083r2.html)

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
* Waiting for [new features](https://github.com/dart-lang/language/projects/1) on the Dart [language](https://github.com/dart-lang/language) too ...
  * [Views on an object without a wrapper object #1474](https://github.com/dart-lang/language/issues/1474), see also [working spec](https://github.com/dart-lang/language/blob/master/working/1426-extension-types/feature-specification-views.md)
  * [Static metaprogramming #1482](https://github.com/dart-lang/language/issues/1482) with data classes

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
