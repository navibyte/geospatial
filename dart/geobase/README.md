<h2 align="center">Geospatial coordinates, projections and writers</h2>

[![pub package](https://img.shields.io/pub/v/geobase.svg)](https://pub.dev/packages/geobase) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

The package provides geospatial coordinates (geographic and projected), 
projections, and data writers for geospatial features, geometries, coordinates
and properties. 

## Features

* 🔢 enums for geospatial coordinate and geometry types
* 🌐 *geographic* positions and bounding boxes (longitude-latitude-elevation)
* 🗺️ *projected* positions and bounding boxes (cartesian XYZ)
* 🏗️ coordinate transformations and projections (initial support)
* 📅 temporal data structures (instant, interval)
* 📃 geospatial data writers for features, geometries, coordinates, properties:
  * 🌎 supported formats: [GeoJSON](https://geojson.org/) 
* 📃 geospatial data writers for geometries and coordinates:
  * 🪧 supported formats: [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)

## Getting started

The package requires at least [Dart](https://dart.dev/) SDK 2.17, and it
supports all [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/)
platforms.

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  geobase: ^0.2.0-dev.1
```

Import it:

```dart
import `package:geobase/geobase.dart`
```

A sample to write a `Point` geometry with a geographic position to GeoJSON:

```dart
  // geometry writer for GeoJSON, with number of decimals for text output set
  final writer = geoJsonFormat().geometriesToText(decimals: 1);

  // prints:
  //    {"type":"Point","coordinates":[10.1,20.3]}
  print(
    writer
      ..geometryWithPosition(
        type: Geom.point,
        coordinates: const Geographic(lon: 10.123, lat: 20.25),
      )
      ..toString(),
  );
```

## User guide

### About coordinates

Coordinate types supported are defined by the `Coords` enum.

Type          | Description
------------- | -----------
`xy`          | Projected or cartesian coordinates (x, y)
`xyz`         | Projected or cartesian coordinates (x, y, z)
`xym`         | Projected or cartesian coordinates (x, y, m)
`xyzm`        | Projected or cartesian coordinates (x, y, z, m)
`lonLat`      | Geographic coordinates (longitude, latitude)
`lonLatElev`  | Geographic coordinates (longitude, latitude, elevation)
`lonLatM`     | Geographic coordinates (longitude, latitude, m)
`lonLatElevM` | Geographic coordinates (longitude, latitude, elevation, m)

The `m` coordinate represents a measurement or a value on a linear referencing
system (like time).

There are base interfaces (abstract classes) for positions and bounding boxes.

Interface     | Description
------------- | -----------
`Position`    | A base interface for geospatial positions.
`Box`         | A base interface for axis-aligned bounding boxes with min & max coordinates.

This package provides four classes (extending these interface) for representing
coordinates for positions and bounding boxes. These classes can act also as
interfaces (sub implementations allowed) or as concrete classes to represent
data.

Class         | Description
------------- | -----------
`Geographic`  | A geographic position with longitude, latitude and optional elevation and m.
`Projected`   | A projected position with x, y, and optional z and m coordinates.
`GeoBox`      | A geographic bounding box with west, south, east and north coordinates.
`ProjBox`     | A bounding box with minX, minY, maxX and maxY coordinates.

### Geographic coordinates

Geographic positions:

```dart
  // Geographic position with longitude and latitude
  const Geographic(lon: -0.0014, lat: 51.4778);

  // Geographic position with longitude, latitude and elevation.
  const Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0);

  // Geographic position with longitude, latitude, elevation and measure.
  const Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0, m: 123.0);

  // The last sample also from num iterable or text.
  Geographic.fromCoords(const [-0.0014, 51.4778, 45.0, 123.0]);
  Geographic.fromText('-0.0014,51.4778,45.0,123.0');
  Geographic.fromText('-0.0014 51.4778 45.0 123.0', delimiter: ' ');
```

Geographic bounding boxes:

```dart
  // Geographic bbox (-20.0 .. 20.0 in longitude, 50.0 .. 60.0 in latitude).
  const GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0);

  // Geographic bbox with limits on elevation coordinate too.
  const GeoBox(
    west: -20.0,
    south: 50.0,
    minElev: 100.0,
    east: 20.0,
    north: 60.0,
    maxElev: 200.0,
  );

  // The last sample also from num iterable or text.
  ProjBox.fromCoords(const [-20.0, 50.0, 100.0, 20.0, 60.0, 200.0]);
  ProjBox.fromText('-20.0,50.0,100.0,20.0,60.0,200.0');

  // Geographic bbox with limits on elevation and measure coordinates too.
  const GeoBox(
    west: -20.0,
    south: 50.0,
    minElev: 100.0,
    minM: 5.0,
    east: 20.0,
    north: 60.0,
    maxElev: 200.0,
    maxM: 6.0,
  );
```

### Projected coordinates

Projected positions:

```dart
  // Projected position with x and y.
  const Projected(x: 708221.0, y: 5707225.0);

  // Projected position with x, y and z.
  const Projected(x: 708221.0, y: 5707225.0, z: 45.0);

  // Projected position with x, y, z and m.
  const Projected(x: 708221.0, y: 5707225.0, z: 45.0, m: 123.0);

  // The last sample also from num iterable or text.
  Projected.fromCoords(const [708221.0, 5707225.0, 45.0, 123.0]);
  Projected.fromText('708221.0,5707225.0,45.0,123.0');
  Projected.fromText('708221.0 5707225.0 45.0 123.0', delimiter: ' ');
```

Projected bounding boxes:

```dart
  // Projected bbox with limits on x and y.
  const ProjBox(minX: 10, minY: 10, maxX: 20, maxY: 20);

  // Projected bbox with limits on x, y and z.
  const ProjBox(minX: 10, minY: 10, minZ: 10, maxX: 20, maxY: 20, maxZ: 20);

  // The last sample also from num iterable or text.
  ProjBox.fromCoords(const [10, 10, 10, 20, 20, 20]);
  ProjBox.fromText('10,10,10,20,20,20');

  // Projected bbox with limits on x, y, z and m.
  const ProjBox(
    minX: 10,
    minY: 10,
    minZ: 10,
    minM: 10,
    maxX: 20,
    maxY: 20,
    maxZ: 20,
    maxM: 20,
  );
```

### Geometry types

Geometry types introduced above are based on the
[Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
standard by [The Open Geospatial Consortium](https://www.ogc.org/).

The types are also compatible with [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry).

Geometry types supported are defined by the `Geom` enum.

Type                 | Description
-------------------- | -----------
`point`              | The type for the `POINT` geometry
`lineString`         | The type for the `LINESTRING` geometry.
`polygon`            | The type for the `POLYGON` geometry.
`geometryCollection` | The type for the `GEOMETRYCOLLECTION` geometry.
`multiPoint`         | The type for the `MULTIPOINT` geometry.
`multiLineString`    | The type for the `MULTILINESTRING` geometry.
`multiPolygon`       | The type for the `MULTIPOLYGON` geometry.

The *geobase* package does not however provide data structure classes for these
geometry types, but types are used by geospatial data writers. Please see the
[geocore](https://pub.dev/packages/geocore) package also for geometry data
structures.

### GeoJSON writer

The `geoJsonFormat()` function can be used to access writers for coordinates, 
geometries and features producing [GeoJSON](https://geojson.org/) compatible
text.

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
          const Geographic(lon: -1.1, lat: -1.1),
          const Geographic(lon: 2.1, lat: -2.5),
          const Geographic(lon: 3.5, lat: -3.49),
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
          coordinates: const Geographic(lon: 10.123, lat: 20.25),
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

### WKT writer

The `wktFormat()` function can be used to access writers for coordinates and 
geometries producing 
[WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
compatible text. However feature objects cannot be written to WKT even if 
supported by GeoJSON.

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
        coordinates:
            const Geographic(lon: 10.123, lat: 20.25, elev: -30.95, m: -1.999),
      )
      ..toString(),
  );
```

### Temporal data

Temporal data can be represented as *instants* (a time stamp) and *intervals*
(an open or a closed interval between time stamps).

```dart
  // Instants can be created from `DateTime` or parsed from text.
  Instant(DateTime.utc(2020, 10, 31, 09, 30));
  Instant.parse('2020-10-31 09:30Z');

  // Intervals (open-started, open-ended, closed).
  Interval.openStart(DateTime.utc(2020, 10, 31));
  Interval.openEnd(DateTime.utc(2020, 10, 01));
  Interval.closed(DateTime.utc(2020, 10, 01), DateTime.utc(2020, 10, 31));

  // Same intervals parsed (by the "start/end" format, ".." for open limits).
  Interval.parse('../2020-10-31');
  Interval.parse('2020-10-01/..');
  Interval.parse('2020-10-01/2020-10-31');
```

### Geospatial extents

Extent objects have both spatial bounds and temporal interval, and they are
useful in metadata structures for geospatial data sources.

```dart
  // An extent with spatial (WGS 84 longitude-latitude) and temporal parts.
  GeoExtent.single(
    crs: 'EPSG:4326',
    bbox: const GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0),
    interval: Interval.parse('../2020-10-31'),
  );

  // An extent with multiple spatial bounds and temporal interval segments.
  GeoExtent.multi(
    crs: 'EPSG:4326',
    boxes: const [
      GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0),
      GeoBox(west: 40.0, south: 50.0, east: 60.0, north: 60.0),
    ],
    intervals: [
      Interval.parse('2020-10-01/2020-10-05'),
      Interval.parse('2020-10-27/2020-10-31'),
    ],
  );
```

The `crs` property in extents above refer to a 
[Coordinate reference system](https://en.wikipedia.org/wiki/Spatial_reference_system) 
that is *a coordinate-based local, regional or global system used to locate geographical entities*. 

This library does not define any `crs` constants, please refer to registries
like [The EPSG dataset](https://epsg.org/).

### Projections

Built-in coordinate projections (currently only between WGS84 and Web Mercator):

```dart
  // Geographic (WGS 84 longitude-latitude) to Projected (Web Mercator metric)
  final forward = wgs84ToWebMercator.forward();
  final projected =
      forward.project(const Geographic(lon: -0.0014, lat: 51.4778));

  // Projected (Web Mercator metric) to Geographic (WGS 84 longitude-latitude)
  final inverse = wgs84ToWebMercator.inverse();
  final unprojected = inverse.project(projected);

  print('$unprojected <=> $projected');
```

Coordinate projections based on the external
[proj4dart](https://pub.dev/packages/proj4dart) package:

```dart
// need the special import instead of 'package:geobase/geobase.dart'
import 'package:geobase/with_proj4d.dart';

// A projection adapter from WGS84 (EPSG:4326) to EPSG:23700 (with definition)
// (based on the sample at https://pub.dev/packages/proj4dart).
final adapter = proj4dart(
  'EPSG:4326',
  'EPSG:23700',
  toDef: '+proj=somerc +lat_0=47.14439372222222 +lon_0=19.04857177777778 '
      '+k_0=0.99993 +x_0=650000 +y_0=200000 +ellps=GRS67 '
      '+towgs84=52.17,-71.82,-14.9,0,0,0,0 +units=m +no_defs',
);

// Apply a forward projection to EPSG:23700 with points represented as Point2.
final forward = adapter.forward();
print(forward.project(const Geographic(lon: 17.8880, lat: 46.8922)));
```

Please see the documentation of [proj4dart](https://pub.dev/packages/proj4dart)
package about it's capabilities, and accuracy of forward and inverse 
projections.

### Transforms

Projections described above project coordinates between `Projected` and 
`Geographic` positions.

Coordinate transformations transform coordinate value without changing the type.

This sample uses the built-int `translatePoint` function:

```dart
  // Create a point and transform it with the built-in translation that returns
  // `Position(x: 110.0, y: 220.0, z: 50.0, m: 1.25)` after transform.
  print(
    const Projected(x: 100.0, y: 200.0, z: 50.0, m: 1.25)
        .transform(translatePosition(dx: 10.0, dy: 20.0)),
  );
```

### Geographic algorithms

Currently supported, a distance between geographic positions using the
[Haversine formula](https://en.wikipedia.org/wiki/Haversine_formula).

```dart
/// Returns a distance in meters between [position1] and [position2].
/// 
/// Given [earthRadius] is used for calculation with the approximate mean radius
/// as a default.
double distanceHaversine(
  Geographic position1,
  Geographic position2, {
  double earthRadius = 6371000.0,
});
```

## Package

This is a [Dart](https://dart.dev/) package named `geobase` under the 
[geospatial](https://github.com/navibyte/geospatial) code repository. 

See also the [geocore](https://pub.dev/packages/geocore) package for geometry
and feature data structures, data parsers and other utilities.  

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).