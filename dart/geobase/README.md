<h2 align="center">Geospatial data writers</h2>

[![pub package](https://img.shields.io/pub/v/geobase.svg)](https://pub.dev/packages/geobase) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

The package provides data writers for geospatial features, geometries, 
coordinates and properties. Currently the supported formats are
[GeoJSON](https://geojson.org/) and [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) (Well-known text representation of geometry).

There are also data structures to represent positions and bounding boxes, both
for *geographic* coordinate systems and *projected* (or cartesian) coordinate
systems.

## Features

* 🔢 enums for geospatial coordinate and geometry types
* 🌐 *geographic* positions and bounding boxes (longitude-latitude-elevation)
* 🗺️ *projected* positions and bounding boxes (cartesian XYZ)
* 📃 geospatial data writers for features, geometries, coordinates, properties:
  * 🌎 supported formats: [GeoJSON](https://geojson.org/) 
* 📃 geospatial data writers for geometries and coordinates:
  * 🪧 supported formats: [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)

**This package is at BETA stage, interfaces not fully final yet.** 

## Getting started

The package requires at least [Dart](https://dart.dev/) SDK 2.12, and it
supports all [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/)
platforms.

## Usage

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  geobase: ^0.1.0-a.0
```

Import it:

```dart
import `package:geobase/geobase.dart`
```

TODO: more examples

## Package

TODO: description

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).