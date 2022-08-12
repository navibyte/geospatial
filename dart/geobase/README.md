[![pub package](https://img.shields.io/pub/v/geobase.svg)](https://pub.dev/packages/geobase) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

<a title="Ktrinko, CC0, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Eckert4.jpg"><img alt="World map with Natural Earth data, Excert projection" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/projections/eckert4/320px-Eckert4.jpg" align="right"></a>

Geospatial coordinates (geographic and projected), projections, tiling schemes,
and vector data support for [GeoJSON](https://geojson.org/),
[WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
and [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary).

## Features

✨ New: Support for [Well-know binary](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary) (WKB). Text and
binary data formats, encodings and content interfaces also redesigned.

Key features:
* 🌐 *geographic* positions and bounding boxes (longitude-latitude-elevation)
* 🗺️ *projected* positions and bounding boxes (cartesian XYZ)
* 🏗️ coordinate transformations and projections (initial support)
* 🔢 tiling schemes and tile matrix sets (web mercator, global geodetic)
* 📅 temporal data structures (instant, interval) and spatial extents
* 🧩 simple geometries (point, line string, polygon, multi point, multi line string, multi polygon, geometry collection)
* 🔷 feature objects (with id, properties and geometry) and feature collections
* 📃 text format encoders for features, geometries, coordinates, properties:
  * 🌎 supported formats: [GeoJSON](https://geojson.org/) 
* 📃 text format encoders for geometries and coordinates:
  * 🪧 supported formats: [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
* 📃 binary format encoders and decoders for geometries:
  * 🪧 supported formats: [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary)

## Package

The package requires at least [Dart](https://dart.dev/) SDK 2.17, and it
supports all [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/)
platforms.

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  geobase: ^0.3.0-dev.2
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
**projections**        | Geospatial projections (currently only between WGS84 and Web Mercator).
**projections_proj4d** | Projections provided by the external [proj4dart](https://pub.dev/packages/proj4dart) package.
**tiling**             | Tiling schemes and tile matrix sets (web mercator, global geodetic).
**transforms**         | Basic coordinate transformations (initial support).
**vector**             | Data writers for geospatial vector data (features, geometries, coordinates).
**vector_data**        | Data structures for positions, geometries, features and feature collections.

See also the [geodata](https://pub.dev/packages/geodata) package provding a
geospatial API client to read [GeoJSON](https://geojson.org/) and other
geospatial data sources.  

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

A sample to encode a `Point` geometry to [GeoJSON](https://geojson.org/):

```dart
  // geometry encoder for GeoJSON, with number of decimals for text output set
  final encoder = GeoJSON.geometry.encoder(decimals: 1);

  // prints:
  //    {"type":"Point","coordinates":[10.1,20.3]}
  encoder.writer.point([10.123, 20.25]);
  print(encoder.toText());
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

## Geospatial vector data

### Content interfaces

Content interfaces are used for two main use cases:
* *writing geospatial data* (coordinates, geometry and features) to text or binary format encoders 
* *building objects* in decoders reading geospatial data from text or binary formats

Content interface   | Description
------------------- | -----------
`CoordinateContent` | Write coordinate objects (bounding boxes, positions, position arrays).
`GeometryContent`   | Write geometry objects (supported geometry types: `point`, `lineString`, `polygon`, `multiPoint`, `multiLineString`, `multiPolygon` , `geometryCollection`)
`FeatureContent`    | Write features (with properties and geometry objects) and feature collections

### Text format encoders

Text formats supported:

Format   | Format class | Content encoders
-------- | ------------ | ---------------------------
[GeoJSON](https://geojson.org/)  | `GeoJSON` | Coordinates, Geometries, Features
[WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) | `WKT` | Coordinates, Geometries

There are also formats `DefaultFormat` (a text format aligned with GeoJSON but
output is somewhat simpler) and `WktLikeFormat` (a text format aligned with
WKT).

All formats mentioned above have following content specific formats:

```dart
  /// The text format for coordinate objects.
  static const TextFormat<CoordinateContent> coordinate;

  /// The text format for geometry objects.
  static const TextFormat<GeometryContent> geometry;
```

`GeoJSON` provides also:

```dart
  /// The text format for feature objects.
  static const TextFormat<FeatureContent> feature;
```

See samples below how to use text formats and encoders.

### GeoJSON encoder

The `GeoJSON` class can be used to access text format encoders for coordinates, 
geometries and features producing [GeoJSON](https://geojson.org/) compatible
text.

A sample to encode a `LineString` geometry to GeoJSON:

```dart
  // geometry text format encoder for GeoJSON
  final encoder = GeoJSON.geometry.encoder();

  // prints (however without line breaks):
  //    {"type":"LineString",
  //     "bbox":[-1.1,-3.49,3.5,-1.1],
  //     "coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]}
  encoder.writer.lineString(
    [-1.1, -1.1, 2.1, -2.5, 3.5, -3.49],
    type: Coords.xy,
    bounds: [-1.1, -3.49, 3.5, -1.1],
  );
  print(encoder.toText());
```

A sample to encode a `Feature` geometry to GeoJSON:

```dart
  // feature text format encoder for GeoJSON
  final encoder = GeoJSON.feature.encoder();

  // prints (however without line breaks):
  //    {"type":"Feature",
  //     "id":"fid-1",
  //     "geometry":
  //        {"type":"Point","coordinates":[10.123,20.25]},
  //     "properties":
  //        {"foo":100,"bar":"this is property value","baz":true}}
  encoder.writer.feature(
    id: 'fid-1',
    geometry: (geom) => geom.point([10.123, 20.25]),
    properties: {
      'foo': 100,
      'bar': 'this is property value',
      'baz': true,
    },
  );
  print(encoder.toText());
```

### WKT encoder

The `WKT` class can be used to access text format encoders for coordinates and 
geometries producing 
[Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
compatible text. However feature objects cannot be written to WKT even if 
supported by GeoJSON.

A sample to encode a `Point` geometry to WKT (with z and m coordinates too):

```dart
  // geometry text format encoder for WKT
  final encoder = WKT.geometry.encoder();

  // prints:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  encoder.writer.point(
    [10.123, 20.25, -30.95, -1.999],
    type: Coords.xyzm,
  );
  print(encoder.toText());
```

### WKB encoder and decoder

The `WKB` class provides encoders and decoders for
[Well-known binary](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary)
binary format supporting simple geometry objects.

See sample below:

```dart
  // geometry binary format encoder for WKB
  final encoder = WKB.geometry.encoder();

  // write geometries (here only point) to content writer of the encoder
  encoder.writer.point(
    [10.123, 20.25, -30.95, -1.999],
    type: Coords.xyzm,
  );

  // get encoded bytes (Uint8List) and Base64 encoded text (String)
  final wkbBytes = encoder.toBytes();
  final wkbBytesAsBase64 = encoder.toText();

  // prints (point encoded to WKB binary data, formatted as Base64 text):
  //    AAAAC7lAJD752yLQ5UA0QAAAAAAAwD7zMzMzMzO///vnbItDlg==
  print(wkbBytesAsBase64);

  // next decode this WKB binary data and use WKT text format encoder as target

  // geometry text format encoder for WKT
  final wktEncoder = WKT.geometry.encoder();

  // geometry binary format decoder for WKB
  // (with content writer of the WKT encoder set as a target for decoding)
  final decoder = WKB.geometry.decoder(wktEncoder.writer);

  // now decode those WKB bytes created already at the start
  decoder.decodeBytes(wkbBytes.buffer);

  // finally print WKT text:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(wktEncoder.toText());
```

As descibed above `WKB.geometry.decoder` takes `wktEncoder.writer` as a
parameter. It implements `GeometryContent` interface with following methods:

```dart
  /// Writes a point geometry with [position].
  ///
  /// Use an optional [type] to explicitely specify the type of coordinates. If
  /// not provided and an iterable has 3 items, then xyz coordinates are
  /// assumed.
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  ///
  /// Supported coordinate value combinations for `Iterable<double>` are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
  ///
  /// An example to write a point geometry with 2D coordinates:
  /// ```dart
  ///    // using a coordinate value list (x, y)
  ///    content.point([10, 20]);
  /// ```
  void point(
    Iterable<double> position, {
    Coords? type,
    String? name,
  });

  /// Writes a line string geometry with a [chain] of positions.
  void lineString(
    Iterable<double> chain, {
    required Coords type,
    String? name,
    Iterable<double>? bounds,
  });

  /// Writes a polygon geometry with one exterior and 0 to N interior [rings].
  void polygon(
    Iterable<Iterable<double>> rings, {
    required Coords type,
    String? name,
    Iterable<double>? bounds,
  });

  /// Writes a multi point geometry with an array of [points] (each with a
  /// position).
  void multiPoint(
    Iterable<Iterable<double>> points, {
    required Coords type,
    String? name,
    Iterable<double>? bounds,
  });

  // Omitted: multiLineString, multiPolygon, geometryCollection, emptyGeometry
```

By implementing this interface, it's possible to implement a custom geometry
object builder that receives geometry content via method calls to the interface. 

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
`xy`          | Projected (x, y) or geographic (longitude, latitude) coordinates
`xyz`         | Projected (x, y, z) or geographic (longitude, latitude, elevation) coordinates
`xym`         | Projected (x, y, m) or geographic (longitude, latitude, m) coordinates
`xyzm`        | Projected (x, y, z, m) or geographic (longitude, latitude, elevation, m) coordinates

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