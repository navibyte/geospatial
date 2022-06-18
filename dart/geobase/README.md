[![pub package](https://img.shields.io/pub/v/geobase.svg)](https://pub.dev/packages/geobase) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

<a title="Ktrinko, CC0, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Eckert4.jp"><img alt="World map with Natural Earth data" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/projections/eckert4/320px-Eckert4.jpg" align="right"></a>

Geospatial coordinates (geographic and projected), projections, tiling schemes,
and data writers for [GeoJSON](https://geojson.org/) and [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry).

## Features

✨ New: Tiling schemes and tile matrix sets (web mercator, global geodetic). 
Also other improvements on coordinates, and refactorings on the code structure.

Key features:
* 🌐 *geographic* positions and bounding boxes (longitude-latitude-elevation)
* 🗺️ *projected* positions and bounding boxes (cartesian XYZ)
* 🏗️ coordinate transformations and projections (initial support)
* 🔢 tiling schemes and tile matrix sets (web mercator, global geodetic)
* 📅 temporal data structures (instant, interval) and spatial extents
* 📃 geospatial data writers for features, geometries, coordinates, properties:
  * 🌎 supported formats: [GeoJSON](https://geojson.org/) 
* 📃 geospatial data writers for geometries and coordinates:
  * 🪧 supported formats: [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)

## Package

The package requires at least [Dart](https://dart.dev/) SDK 2.17, and it
supports all [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/)
platforms.

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  geobase: ^0.2.1
```

Import it:

```dart
import `package:geobase/geobase.dart`
```

The package contains also following mini-libraries, that can be used to import
only a certain subset instead of the whole **geobase** library:

Library                | Description 
---------------------- | ----------- 
**codes**              | Enums (codes) for geospatial coordinate, geometry types and canvas origin.
**constants**          | Geodetic and screen related constants.
**coordinates**        | Geographic and projected positions and bounding boxes.
**meta**               | Temporal data structures (instant, interval) and spatial extents.
**projections_proj4d** | Projections provided by the external [proj4dart](https://pub.dev/packages/proj4dart) package.
**tiling**             | Tiling schemes and tile matrix sets (web mercator, global geodetic).
**vector**             | Data writers for geospatial vector data (features, geometries, coordinates).

See also the [geocore](https://pub.dev/packages/geocore) package for geometry
and feature data structures, data parsers and other utilities. The 
[geodata](https://pub.dev/packages/geodata) package provdies a geospatial API
client to read [GeoJSON](https://geojson.org/) and other geospatial data
sources.  

## Introduction

Geographic, projected and scalable coordinates:

```dart
  // Geographic position with longitude, latitude and elevation.
  const Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0);

  // Projected position with x, y and z.
  const Projected(x: 708221.0, y: 5707225.0, z: 45.0);

  // A pixel or a tile with a zoom level (or LOD = level of detail) coordinates.
  const Scalable2i(zoom: 9, x: 23, y: 10);
```

Bounding boxes:

```dart
  // Geographic bbox (-20.0 .. 20.0 in longitude, 50.0 .. 60.0 in latitude).
  const GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0);

  // Projected bbox with limits on x and y.
  const ProjBox(minX: 10, minY: 10, maxX: 20, maxY: 20);
```

Tiling schemes, a sample with Web Mercator:

```dart
  // "WebMercatorQuad" tile matrix set with 256 x 256 pixel tiles
  const quad = WebMercatorQuad.epsg3857();

  // converting a geographic position to tile coordinates at zoom level 2
  quad.positionToTile(Geographic(lon: -0.0014, lat: 51.4778), zoom: 2)); 
```

A sample to write a `Point` geometry with a geographic position to
[GeoJSON](https://geojson.org/):

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

See more examples and instructions how to use the package on chapters below.

## Coordinates

### Geographic coordinates

*Geographic* coordinates are based on a spherical or ellipsoidal coordinate
system representing positions on the Earth as longitude (`lon`) and latitude
(`lat`).

Elevation (`elev`) in meters and measure (`m`) coordinates are optional.

<a title="Djexplo, CC0, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Latitude_and_Longitude_of_the_Earth.svg"><img alt="Latitude and Longitude of the Earth" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/coordinates/geographic/Latitude_and_Longitude_of_the_Earth.svg"></a>

Geographic positions:

```dart
  // Geographic position with longitude and latitude.
  const Geographic(lon: -0.0014, lat: 51.4778);

  // Geographic position with longitude, latitude and elevation.
  const Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0);

  // Geographic position with longitude, latitude, elevation and measure.
  const Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0, m: 123.0);

  // The last sample also from num iterable or text (order: lon, lat, elev, m).
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
  GeoBox.fromCoords(const [-20.0, 50.0, 100.0, 20.0, 60.0, 200.0]);
  GeoBox.fromText('-20.0,50.0,100.0,20.0,60.0,200.0');

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

<a title="Sommacal alfonso, CC BY-SA 4.0 &lt;https://creativecommons.org/licenses/by-sa/4.0/deed.en&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Cartesian_coordinates.png"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/coordinates/cartesian/Cartesian_coordinates.png" align="right"></a>

*Projected* coordinates represent projected or cartesian (XYZ) coordinates with
an optional measure (m) coordinate. For projected map positions `x` often
represents *easting* (E) and `y` represents *northing* (N), however a coordinate
reference system might specify something else too. 

The `m` coordinate represents
a measurement or a value on a linear referencing system (like time). It could be
associated with a 2D position (x, y, m) or a 3D position (x, y, z, m).

Projected positions:

```dart
  // Projected position with x and y.
  const Projected(x: 708221.0, y: 5707225.0);

  // Projected position with x, y and z.
  const Projected(x: 708221.0, y: 5707225.0, z: 45.0);

  // Projected position with x, y, z and m.
  const Projected(x: 708221.0, y: 5707225.0, z: 45.0, m: 123.0);

  // The last sample also from num iterable or text (order: x, y, z, m).
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

### Scalable coordinates

*Scalable* coordinates are *projected* coordinates associated with some level of
detail (LOD) or `zoom` level. They are used for example by tiling schemes to
represent *pixels* and *tiles* of tile matrices.

The `Scalable2i` class represents projected `x`, `y` coordinates at `zoom`
level, with all value as integers.

```dart
  // A pixel or a tile with a zoom level (or LOD = level of detail) coordinates.
  const pixel = Scalable2i(zoom: 9, x: 23, y: 10);

  // Such coordinates can be scaled to other zoom levels.
  pixel.zoomIn(); // => Scalable2i(zoom: 10, x: 46, y: 20);
  pixel.zoomOut(); // => Scalable2i(zoom: 8, x: 11, y: 5);
  pixel.zoomTo(13); // => Scalable2i(zoom: 13, x: 368, y: 160));
```

## Tiling schemes

### Web Mercator Quad

<a title="TheCrazyWhovian, CC BY-SA 4.0 &lt;https://creativecommons.org/licenses/by-sa/4.0/deed.en&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:WebMercator.png"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/projections/webmercator/267px-WebMercator.png" align="right"></a>

`WebMercatorQuad` is a "Google Maps Compatible" tile matrix set with tiles
defined in the WGS 84 / Web Mercator projection ("EPSG:3857").

Using `WebMercatorQuad` involves following coordinates:
* *position*: geographic coordinates (longitude, latitude)
* *world*: a position projected to the pixel space of the map at level 0
* *pixel*: pixel coordinates (x, y) in the pixel space of the map at zoom
* *tile*: tile coordinates (x, y) in the tile matrix at zoom

[OGC Two Dimensional Tile Matrix Set](https://docs.opengeospatial.org/is/17-083r2/17-083r2.html) specifies:

> Level 0 allows representing most of the world (limited to latitudes between approximately ±85 degrees) in a single tile of 256x256 pixels (Mercator projection cannot cover the whole world because mathematically the poles are at infinity). The next level represents most of the world in 2x2 tiles of 256x256 pixels and so on in powers of 2. Mercator projection distorts the pixel size closer to the poles. The pixel sizes provided here are only valid next to the equator.

See below how to calcalate between geographic positions, world coordinates,
pixel coordinates and tile coordinates:

```dart
  // "WebMercatorQuad" tile matrix set with 256 x 256 pixel tiles and with
  // "top-left" origin for the tile matrix and map pixel space
  const quad = WebMercatorQuad.epsg3857();

  // source position as geographic coordinates
  const position = Geographic(lon: -0.0014, lat: 51.4778);

  // get world, tile and pixel coordinates for a geographic position
  print(quad.positionToWorld(position)); // ~ x=127.999004 y=85.160341
  print(quad.positionToTile(position, zoom: 2)); // zoom=2 x=1 y=1
  print(quad.positionToPixel(position, zoom: 2)); // zoom=2 x=511 y=340
  print(quad.positionToPixel(position, zoom: 4)); // zoom=4 x=2047 y=1362

  // world coordinates can be instantiated as projected coordinates
  // x range: (0.0, 256.0) / y range: (0.0, 256.0)
  const world = Projected(x: 127.99900444444444, y: 85.16034098329446);

  // from world coordinates to tile and pixel coordinates
  print(quad.worldToTile(world, zoom: 2)); // zoom=2 x=1 y=1
  print(quad.worldToPixel(world, zoom: 2)); // zoom=2 x=511 y=340
  print(quad.worldToPixel(world, zoom: 4)); // zoom=4 x=2047 y=1362

  // tile and pixel coordinates with integer values can be defined too
  const tile = Scalable2i(zoom: 2, x: 1, y: 1);
  const pixel = Scalable2i(zoom: 2, x: 511, y: 340);

  // tile and pixel coordinates can be zoomed (scaled to other level of details)
  print(pixel.zoomIn()); // zoom=3 x=1022 y=680
  print(pixel.zoomOut()); // zoom=1 x=255 y=170

  // get tile bounds and pixel position (accucy lost) as geographic coordinates
  print(quad.tileToBounds(tile)); // west: -90 south: 0 east: 0 north: 66.51326
  print(quad.pixelToPosition(pixel)); // longitude: -0.17578 latitude: 51.50874

  // world coordinates returns geographic positions still accurately
  print(quad.worldToPosition(world)); // longitude: -0.00140 latitude: 51.47780

  // a quad key is a string identifier for tiles
  print(quad.tileToQuadKey(tile)); // "03"
  print(quad.quadKeyToTile('03')); // zoom=2 x=1 y=1
  print(quad.quadKeyToTile('0321')); // zoom=4 x=5 y=6

  // tile size and map bounds can be checked dynamically
  print(quad.tileSize); // 256
  print(quad.mapBounds()); // ~ west: -180 south: -85.05 east: 180 north: 85.05

  // matrix width and height tells number of tiles in a given zoom level
  print('${quad.matrixWidth(2)} x ${quad.matrixHeight(2)}'); // 4 x 4
  print('${quad.matrixWidth(10)} x ${quad.matrixHeight(10)}'); // 1024 x 1024

  // map width and height tells number of pixels in a given zoom level
  print('${quad.mapWidth(2)} x ${quad.mapHeight(2)}'); // 1024 x 1024
  print('${quad.mapWidth(10)} x ${quad.mapHeight(10)}'); // 262144 x 262144

  // ground resolutions and scale denominator for zoom level 10 at the Equator
  print(quad.tileGroundResolution(10)); // ~ 39135.76 (meters)
  print(quad.pixelGroundResolution(10)); // ~ 152.87 (meters)
  print(quad.scaleDenominator(10)); // ~ 545978.77

  // ground resolutions and scale denominator for zoom level 10 at lat 51.4778
  print(quad.pixelGroundResolutionAt(latitude: 51.4778, zoom: 10)); // ~ 95.21
  print(quad.scaleDenominatorAt(latitude: 51.4778, zoom: 10)); // ~ 340045.31
```

### Global Geodetic Quad

<a title="Daniel R. Strebe, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Equirectangular_projection_SW.jpg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/projections/platecarree/320px-Equirectangular_projection_SW.jpg" align="right"></a>

`GlobalGeodeticQuad` (or "World CRS84 Quad" for WGS 84) is a tile matrix set
with tiles defined in the *Equirectangular Plate Carrée* projection.

At the zoom level 0 the world is covered by two tiles (tile matrix width is 2
and matrix height is 1). The western tile (x=0, y=0) is for the negative
longitudes and the eastern tile (x=1, y=0) for the positive longitudes.

```dart
  // "World CRS 84" tile matrix set with 256 x 256 pixel tiles and with
  // "top-left" origin for the tile matrix and map pixel space
  const quad = GlobalGeodeticQuad.worldCrs84();

  // source position as geographic coordinates
  const position = Geographic(lon: -0.0014, lat: 51.4778);

  // get world, tile and pixel coordinates for a geographic position
  print(quad.positionToWorld(position)); // ~ x=255.998009 y=54.787129
  print(quad.positionToTile(position, zoom: 2)); // zoom=2 x=3 y=0
  print(quad.positionToPixel(position, zoom: 2)); // zoom=2 x=1023 y=219
  print(quad.positionToPixel(position, zoom: 4)); // zoom=4 x=4095 y=876

  // world coordinates can be instantiated as projected coordinates
  // x range: (0.0, 512.0) / y range: (0.0, 256.0)
  const world = Projected(x: 255.99800888888888, y: 54.78712888888889);

  // from world coordinates to tile and pixel coordinates
  print(quad.worldToTile(world, zoom: 2)); // zoom=2 x=3 y=0
  print(quad.worldToPixel(world, zoom: 2)); // zoom=2 x=1023 y=219
  print(quad.worldToPixel(world, zoom: 4)); //  zoom=4 x=4095 y=876

  // tile and pixel coordinates with integer values can be defined too
  const tile = Scalable2i(zoom: 2, x: 3, y: 0);
  const pixel = Scalable2i(zoom: 2, x: 1023, y: 219);

  // get tile bounds and pixel position (accucy lost) as geographic coordinates
  print(quad.tileToBounds(tile)); // west: -45 south: 45 east: 0 north: 90
  print(quad.pixelToPosition(pixel)); // longitude: -0.08789 latitude: 51.41602

  // world coordinates returns geographic positions still accurately
  print(quad.worldToPosition(world)); // longitude: -0.00140 latitude: 51.4778

  // tile size and map bounds can be checked dynamically
  print(quad.tileSize); // 256
  print(quad.mapBounds()); // west: -180 south: -90 east: 180 north: 90

  // matrix width and height tells number of tiles in a given zoom level
  print('${quad.matrixWidth(2)} x ${quad.matrixHeight(2)}'); // 8 x 4
  print('${quad.matrixWidth(10)} x ${quad.matrixHeight(10)}'); // 2048 x 1024

  // map width and height tells number of pixels in a given zoom level
  print('${quad.mapWidth(2)} x ${quad.mapHeight(2)}'); // 2048 x 1024
  print('${quad.mapWidth(10)} x ${quad.mapHeight(10)}'); // 524288 x 262144

  // arc resolutions and scale denominator for zoom level 10 at the Equator
  print(quad.tileArcResolution(10)); // ~ 0.175781 (° degrees)
  print(quad.pixelArcResolution(10)); // ~ 0.000686646 (° degrees)
  print(quad.scaleDenominator(10)); // ~ 272989.39
```

## Projections

### WGS 84 to Web Mercator

Built-in coordinate projections (currently only between WGS84 and Web Mercator). 

Here projected coordinates are metric coordinates with both x and y values 
having the valid value range of (-20037508.34, 20037508.34).

```dart
  // Geographic (WGS 84 longitude-latitude) to Projected (WGS 84 Web Mercator)
  final forward = wgs84ToWebMercator.forward();
  final projected =
      forward.project(const Geographic(lon: -0.0014, lat: 51.4778));

  // Projected (WGS 84 Web Mercator) to Geographic (WGS 84 longitude-latitude)
  final inverse = wgs84ToWebMercator.inverse();
  final unprojected = inverse.project(projected);

  print('$unprojected <=> $projected');
```

### With proj4dart

Coordinate projections based on the external
[proj4dart](https://pub.dev/packages/proj4dart) package:

```dart
// import the default geobase library
import 'package:geobase/geobase.dart';

// need also an additional import with dependency to `proj4dart` 
import 'package:geobase/projections_proj4d.dart';

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

## Vector (data writers)

### About formats and writers

*Format* classes provide methods for accessing *writers* that allow writing 
coordinate, geometry and feature objects to a output stream (like text buffer).

Formats available:

Format   | Factory function | Writers supported by Format
-------- | ---------------- | ---------------------------
[GeoJSON](https://geojson.org/)  | `geoJsonFormat()` | Coordinates, Geometries, Features
[WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) | `wktFormat()` | Coordinates, Geometries

There are also constants `defaultFormat` (a text format aligned with GeoJSON but
output is somewhat simpler) and `wktLikeFormat` (a text format aligned with
WKT).

All formats mentioned above have following writers:

```dart
  /// Returns a writer formatting string representations of coordinate data.
  ///
  /// When an optional [buffer] is given, then representations are written into
  /// it (without clearing any content it might already contain).
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// After writing some objects with coordinate data into a writer, the string
  /// representation can be accessed using `toString()` of it (or via [buffer]
  /// when such is given).
  CoordinateWriter coordinatesToText({StringSink? buffer, int? decimals});

  /// Returns a writer formatting string representations of geometry objects.
  GeometryWriter geometriesToText({StringSink? buffer, int? decimals});
}
```

A format object returned by `geoJsonFormat()` has also the following writer:

```dart
  /// Returns a writer formatting string representations of feature objects.
  FeatureWriter featuresToText({StringSink? buffer, int? decimals});
```

See `CoordinateWriter`, `GeometryWriter` and `FeatureWriter` for more 
information how to use those writers. Some samples in next chapters.

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

## Meta

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

## Codes

### Coordinate types

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

Also `Scalable2i` implements `Projected` providing 2D projected coordinates with
`x` and `y` scaled at `zoom` (level of detail).

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

## Other features

### Constants

Constants defined by the package:

Constant                  | Value          | Description
------------------------- | -------------- | -----------
`minLongitude`            | `-180.0`       | The minimum value for geographic longitude.
`maxLongitude`            | `180.0`        | The maximum value for geographic longitude.
`minLatitude`             | `-90.0`        | The minimum value for geographic latitude.
`maxLatitude `            | `90.0`         | The maximum value for geographic latitude.
`minLatitudeWebMercator`  | `-85.05112878` | The minimum value for geographic latitude inside Web Mercator coverage
`maxLatitudeWebMercator`  | `85.05112878`  | The maximum value for geographic latitude inside Web Mercator coverage
`earthRadiusWgs84`        | `6378137.0`    | The earth equatorial radius in meters as specified by WGS 84.
`earthCircumferenceWgs84` | `2 * math.pi * earthRadiusWgs84` |  The earth circumference in meters (from earth equatorial radius by WGS 84).
`screenPPIbyOGC`          | `0.0254 / 0.00028` | OGC defines a screen pixel of 0.28 mm that approximates to 90.7 ppi.

### Transforms

*Projections* described in previous chaperts project coordinates between
`Projected` and `Geographic` positions.

Coordinate *transformations* however transform coordinate value without changing
the type.

This sample uses the built-int `translatePoint` function:

```dart
  // Create a point and transform it with the built-in translation that returns
  // `Position(x: 110.0, y: 220.0, z: 50.0, m: 1.25)` after transform.
  print(
    const Projected(x: 100.0, y: 200.0, z: 50.0, m: 1.25)
        .transform(translatePosition(dx: 10.0, dy: 20.0)),
  );
```

### Geodesy algorithms

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

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).