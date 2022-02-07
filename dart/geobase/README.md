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
  geobase: ^0.1.0-a.1
```

Import it:

```dart
import `package:geobase/geobase.dart`
```

A sample to write a `Point` geometry to WKT (with z and m coordinates too):

```dart
  // geometry writer for WKT
  final writer = wktFormat().geometriesToText();

  // prints:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(
    writer
      ..geometryWithPosition(
        type: Geom.point,
        coordType: Coords.xyzm,
        coordinates: const Position(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
      )
      ..toString(),
  );
```

A sample to write a `LineString` geometry to GeoJSON:

```dart
  // geometry writer for GeoJSON
  final writer = geoJsonFormat().geometriesToText();

  // prints (however without line breaks):
  //    {"type":"LineString",
  //     "bbox":[-1.1,-3.49,3.5,-1.1],
  //     "coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]}
  print(
    writer
      ..geometryWithPositions1D(
        type: Geom.lineString,
        bbox: const GeoBox(west: -1.1, south: -3.49, east: 3.5, north: -1.1),
        coordinates: [
          const GeoPosition(lon: -1.1, lat: -1.1),
          const GeoPosition(lon: 2.1, lat: -2.5),
          const GeoPosition(lon: 3.5, lat: -3.49),
        ],
      )
      ..toString(),
  );
```

A sample to write a `Feature` geometry to GeoJSON:

```dart
  // feature writer for GeoJSON
  final writer = geoJsonFormat().featuresToText();

  // prints (however without line breaks):
  //    {"type":"Feature",
  //     "id":"fid-1",
  //     "geometry":
  //        {"type":"Point","coordinates":[10.123,20.25]},
  //     "properties":
  //        {"foo":100,"bar":"this is property value","baz":true}}
  print(
    writer
      ..feature(
        id: 'fid-1',
        geometries: (gw) => gw.geometryWithPosition(
          type: Geom.point,
          coordinates: const GeoPosition(lon: 10.123, lat: 20.25),
        ),
        properties: {
          'foo': 100,
          'bar': 'this is property value',
          'baz': true,
        },
      )
      ..toString(),
  );
```

## Package

This is a [Dart](https://dart.dev/) package named `geobase` under the 
[geospatial](https://github.com/navibyte/geospatial) code repository. 

See also the [geocore](https://pub.dev/packages/geocore) package for geometry
and feature data structures, data parsers, coordinate transformations and other
utitilies.  

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).