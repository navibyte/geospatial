# :compass: Geospatial tools for Dart 

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/navibyte.svg?style=social&label=Follow%20%40navibyte)](https://twitter.com/navibyte) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

<a title="Stefan Kühn (Fotograf), CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Azimutalprojektion-schief_kl-cropped.png"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/projections/azimutal/Azimutalprojektion-schief_kl-cropped.png" align="right"></a>

**Geospatial** data structures, tools and utilities for 
[Dart](https://dart.dev/) and [Flutter](https://flutter.dev/) mobile developers.

The [geocore](https://pub.dev/packages/geocore) library package, based on
Dart code hosted by this repository, provides geospatial data 
structures (features, geometry and metadata) and utilities to parse
[GeoJSON](https://geojson.org/) and [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
(Well-known text representation of geometry) data. The package also supports
representing both geographic (decimal degrees or longitude-latitude) and 
projected (or cartesian XYZ) coordinates in 2D and 3D. 

## :package: Packages

[Dart](https://dart.dev/) code packages published at 
[pub.dev](https://pub.dev/publishers/navibyte.com/packages):

Code           | Package | Description 
-------------- | --------| -----------
:globe_with_meridians: [geocore](dart/geocore) | [![pub package](https://img.shields.io/pub/v/geocore.svg)](https://pub.dev/packages/geocore) | Geospatial data structures (features, geometry and metadata) and parsers ([GeoJSON](https://geojson.org/) and partial support for [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)).
:earth_americas: [geodata](dart/geodata) | [![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) | A geospatial API client to read [GeoJSON](https://geojson.org/) and other geospatial data sources. 

**Code packages are at BETA stage, interfaces not fully final yet.** 

## Sample

Some samples from the [geocore](https://pub.dev/packages/geocore) package, 
please see the package itself for more documentation:

<br clear=“right”/>

Geometry    | Shape       | Samples to create instances
----------- | ----------- | ---------------------------
Point       | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Point.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Point.svg"></a> | `Point2(x: 30.0, y: 10.0)`<br>`Point2.from([30.0, 10.0])`<br>`Point2.parse('30 10')`
LineString  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_LineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_LineString.svg"></a> | `LineString.parse('30 10, 10 30, 40 40', Point2.geometry)`
Polygon     | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Polygon.svg"></a> | `Polygon.parse('(30 10, 40 40, 20 40, 10 20, 30 10)', Point2.geometry)`
Polygon (with a hole) | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Polygon_with_hole.svg"></a> | `Polygon.parse('(35 10, 45 45, 15 40, 10 20, 35 10), (20 30, 35 35, 30 20, 20 30)', Point2.geometry)`

As another library package, [geodata](https://pub.dev/packages/geodata) provides
a geospatial API client supporting reading [GeoJSON](https://geojson.org/), and 
other geospatial data sources (like partial and initial support for
[OGC API Features](https://ogcapi.ogc.org/features/)) from web and file sources.

Please see also generic (non-geospatial) data structures, tools and utilities at
the separate [Dataflow tools for Dart](https://github.com/navibyte/dataflow)
repository providing source code for 
[attributes](https://pub.dev/packages/attributes) and
[datatools](https://pub.dev/packages/datatools) packages.

## :newspaper_roll: News

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

Future enhancement **candidates** for [geocore](dart/geocore), not in any order:
* [Optimizations and consistency for geometry, feature and meta classes #27](https://github.com/navibyte/geospatial/issues/27) 
* [Coordinate reference system (CRS) identifiers enhanced #28](https://github.com/navibyte/geospatial/issues/28)
* [Add EWKT support, handle axis order when reading WKT #29](https://github.com/navibyte/geospatial/issues/29)
* [Coordinate transformations on core classes and reading datasource #15](https://github.com/navibyte/geospatial/issues/15)
* [Add support for other geometry classes known by WKT #30](https://github.com/navibyte/geospatial/issues/30)
* [Define consistent mini library exports with base classes included #31](https://github.com/navibyte/geospatial/issues/31)
* [Add support for empty geometries other than Point and abstract Geometry #35](https://github.com/navibyte/geospatial/issues/35)

Some **candidates** also for [geodata](dart/geodata):
* [Add support for reading geospatial features from in-memory storages #34](https://github.com/navibyte/geospatial/issues/34)
* [Full client-side support for calling OGC API Features service according to Part 1 + 2 #9](https://github.com/navibyte/geospatial/issues/9)

See [other issues](https://github.com/navibyte/geospatial/issues) too.

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

W3C
* [Spatial Data on the Web Best Practices](https://www.w3.org/TR/sdw-bp/)

### Dart and Flutter programming

SDKs:
* [Dart](https://dart.dev/)
* [Flutter](https://flutter.dev/) 

Latest on SDKs
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
[meta](https://pub.dev/packages/meta) | [dart-lang/sdk](https://github.com/dart-lang/sdk/tree/master/pkg/meta) | This package defines annotations that can be used by the tools that are shipped with the Dart SDK.
[synchronized](https://pub.dev/packages/synchronized) | [tekartik/synchronized.dart](https://github.com/tekartik/synchronized.dart/tree/master/synchronized) | Basic lock mechanism to prevent concurrent access to asynchronous code.
