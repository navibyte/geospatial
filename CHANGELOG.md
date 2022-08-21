
## 2022-08-21

* [geobase](https://pub.dev/packages/geobase/versions/0.3.0) (0.3.0), see [changelog](dart/geobase/CHANGELOG.md#030) for details
  * ✨ New: Data structures for simple geometries, features and feature collections.
  * ✨ New: Support for [Well-known binary](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary) (WKB). Text and binary data formats, encodings and content interfaces also redesigned.  
* [geodata](https://pub.dev/packages/geodata/versions/0.10.0) (0.10.0), see [changelog](dart/geodata/CHANGELOG.md#0100) for details
  ✨ New: Updated with latest [geobase](https://pub.dev/packages/geobase) version 0.3.0, and no longer with dependency on [geocore](https://pub.dev/packages/geocore).
* [geocore](https://pub.dev/packages/geocore/versions/0.10.0) (0.10.0), see [changelog](dart/geocore/CHANGELOG.md#0100) for details

## 2022-06-18

* [geobase](https://pub.dev/packages/geobase/versions/0.2.0) (0.2.0), see [changelog](dart/geobase/CHANGELOG.md#020) for details
  * ✨ New: Tiling schemes and tile matrix sets (web mercator, global geodetic). 
Also other improvements on coordinates, and refactorings on the code structure.  
* [geocore](https://pub.dev/packages/geocore/versions/0.9.0) (0.9.0), see [changelog](dart/geocore/CHANGELOG.md#090) for details
* [geodata](https://pub.dev/packages/geodata/versions/0.9.0) (0.9.0), see [changelog](dart/geodata/CHANGELOG.md#090) for details

## 2022-03-09

* [geobase](https://pub.dev/packages/geobase/versions/0.1.0) (0.1.0), see [changelog](dart/geobase/CHANGELOG.md#010) for details
* [geocore](https://pub.dev/packages/geocore/versions/0.8.0) (0.8.0), see [changelog](dart/geocore/CHANGELOG.md#080) for details
* [geodata](https://pub.dev/packages/geodata/versions/0.8.0) (0.8.0), see [changelog](dart/geodata/CHANGELOG.md#080) for details

## 2022-02-06

* A new package `geobase` with code originating and generalized from `geocore`:
   * The pre-release version `0.1.0-a.0` of the upcoming BETA-release 0.1.0
   * [geobase](https://pub.dev/packages/geobase/versions/0.1.0-a.0)
* Also the pre-release version `0.8.0-a.9` of the upcoming BETA-release 0.8.0 for:
   * [geocore](https://pub.dev/packages/geocore/versions/0.8.0-a.9)
   * [geodata](https://pub.dev/packages/geodata/versions/0.8.0-a.9)

## 2022-01-09

* The pre-release version `0.8.0-a.7` of the upcoming BETA-release 0.8.0
   * [geocore](https://pub.dev/packages/geocore/versions/0.8.0-a.7)
   * [geodata](https://pub.dev/packages/geodata/versions/0.8.0-a.7)

## 2021-12-04

* The first pre-release of the upcoming 0.8.0 version of [geocore](https://pub.dev/packages/geocore/versions/0.8.0-a.2)
  * breaking changes with Feature classes, removed dependency to the [attributes](https://pub.dev/packages/attributes) package
  * also the preview of coordinate transformation abstractions and other enhancements

## 2021-10-31

* BETA version 0.7.2 [geocore](https://pub.dev/packages/geocore): 
  * Some text serialization enhancements on Point coordinate values: [#37](https://github.com/navibyte/geospatial/issues/37) and [#38](https://github.com/navibyte/geospatial/issues/38)
* Changes on all packages:
  * [Apply very_good_analysis 2.4.0+ lint rules #36](https://github.com/navibyte/geospatial/issues/36)

## 2021-10-09

* BETA version 0.7.1
* Changes on [geocore](https://pub.dev/packages/geocore):
  * [WKT parser - add support for parsing GEOMETRYCOLLECTION #24](https://github.com/navibyte/geospatial/issues/24)
* Changes on all packages:
  * [Apply very_good_analysis 2.3.0+ lint rules #33](https://github.com/navibyte/geospatial/issues/33)

## 2021-08-10

* BETA version 0.7.0
* Mostly relatively small changes, but required (breaking) changes due
  * updated dependency 0.7.1 on [attributes](https://pub.dev/packages/attributes)
    * required changes visible in Feature class and GeoJSON factories
* [Official Dart lint rules applied with recommend set](https://github.com/navibyte/geospatial/issues/32)

## 2021-05-22

* [geocore](dart/geocore) with new BETA version 0.6.2 (updated documentation)

## 2021-05-16

* [geocore](dart/geocore) with new BETA version 0.6.1
  * initial support for [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) or WKT
  * Also easier to use factories for points, line strings, polygons, etc.
    * Make geometries from arrays of num values.
    * Parse geometries from text with default implementation based on WKT.

## 2021-04-25

* BETA version 0.6.0
* Some code packages were moved out from this repository to the new [dataflow](https://github.com/navibyte/dataflow) repository as they are not *geospatial* at all
  * [attributes](https://pub.dev/packages/attributes)
  * [datatools](https://pub.dev/packages/datatools)
* [Lint rules and analysis options updated](https://github.com/navibyte/geospatial/issues/8)
* Also `implicit-casts` and `implicit-dynamic` set to false requiring code changes

2021-03-03
* BETA version 0.5.0 with stable sound null-safety on all packages requiring the stable [Dart 2.12](https://medium.com/dartlang/announcing-dart-2-12-499a6e689c87)

## 2021-02-28 

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

## 2021-01-10 

* latest alpha version 0.4.1
* Point classes in [geocore](dart/geocore) refactored to have `num` getters 

## 2021-01-03 

* alpha version 0.4.0
* refactored some code to new packages:
  * [attributes](https://pub.dev/packages/attributes)
  * [datatools](https://pub.dev/packages/datatools)

## 2020-11-29 

* initial alpha version 0.1.0
* designed to Dart [null-safety](https://dart.dev/null-safety) from start
* the first version with following packages
  * [geocore](https://pub.dev/packages/geocore)
  * [geodata](https://pub.dev/packages/geodata)
