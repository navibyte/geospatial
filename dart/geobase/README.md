[![pub package](https://img.shields.io/pub/v/geobase.svg)](https://pub.dev/packages/geobase) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

Geospatial data structures (coordinates, geometries, features, metadata), 
spherical geodesy, projections and tiling schemes. Vector data format support
for [GeoJSON](https://geojson.org/),
[WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
and [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary).

 <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPoint.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_MultiPoint.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_LineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_LineString.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_Polygon.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_Polygon_with_hole.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_GeometryCollection.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_GeometryCollection.svg"></a>

## Features

✨ New (2023-10): The stable version 1.0.0 is now ready. See also the article [Geospatial tools for Dart - version 1.0 published](https://medium.com/@navibyte/geospatial-tools-for-dart-version-1-0-published-0f9673e510b3) at Medium.

✨ New (2023-09): Optimizing data structures (*Position*, *PositionSeries*, *Box*) used by simple geometries. Fixes, tests and documentation.

✨ New (2023-07): Spherical geodesy functions (distance, bearing, destination point, etc.) for *great circle* and *rhumb line* paths.

<a title="Ktrinko, CC0, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Eckert4.jpg"><img alt="World map with Natural Earth data, Excert projection" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/projections/eckert4/320px-Eckert4.jpg" align="right"></a>

Key features:
* 🌐 geographic (longitude-latitude) and projected positions and bounding boxes
* 📐 spherical geodesy functions for *great circle* and *rhumb line* paths
* 🧩 simple geometries (point, line string, polygon, multi point, multi line string, multi polygon, geometry collection)
* 🔷 features (with id, properties and geometry) and feature collections
* 📅 temporal data structures (instant, interval) and spatial extents
* 📃 vector data formats supported ([GeoJSON](https://geojson.org/), [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry), [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary)
)
* 🗺️ coordinate projections (web mercator + based on the external [proj4dart](https://pub.dev/packages/proj4dart) library)
* 🔢 tiling schemes and tile matrix sets (web mercator, global geodetic)

## Introduction

General purpose positions, series of positions and bounding boxes:

```dart
  // A position as a view on a coordinate array containing x and y.
  Position.view([708221.0, 5707225.0]);

  // The sample above shorted.
  [708221.0, 5707225.0].xy;

  // A bounding box.
  Box.view([70800.0, 5707200.0, 70900.0, 5707300.0]);

  // A series of positions from an array of position objects.
  PositionSeries.from(
    [
      [70800.0, 5707200.0].xy, // position 0 with (x, y) coordinate values
      [70850.0, 5707250.0].xy, // position 1 with (x, y) coordinate values
      [70900.0, 5707300.0].xy, // position 2 with (x, y) coordinate values
    ],
    type: Coords.xy,
  );
```

*Geographic* and *projected* positions and bounding boxes:

```dart
  // A geographic position without and with an elevation.
  Geographic(lon: -0.0014, lat: 51.4778);
  Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0);

  // A projected position without and with z.
  Projected(x: 708221.0, y: 5707225.0);
  Projected(x: 708221.0, y: 5707225.0, z: 45.0);
  
  // Geographic and projected bounding boxes.
  GeoBox(west: -20, south: 50, east: 20, north: 60);
  GeoBox(west: -20, south: 50, minElev: 100, east: 20, north: 60, maxElev: 200);
  ProjBox(minX: 10, minY: 10, maxX: 20, maxY: 20);

  // Positions and bounding boxes can be also built from an array or parsed.
  Geographic.build([-0.0014, 51.4778]);
  Geographic.parse('-0.0014,51.4778');
  Geographic.parse('-0.0014 51.4778', delimiter: ' ');
  Geographic.parseDms(lon: '0° 00′ 05″ W', lat: '51° 28′ 40″ N');
  GeoBox.build([-20, 50, 100, 20, 60, 200]);
  GeoBox.parse('-20,50,100,20,60,200');
  GeoBox.parseDms(west: '20°W', south: '50°N', east: '20°E', north: '60°N');
```

Coordinates for *pixels* and *tiles* in tiling schemes:

```dart
  // Projected coordinates to represent *pixels* or *tiles* in tiling schemes.
  Scalable2i(zoom: 9, x: 23, y: 10);
```

Spherical geodesy functions for *great circle* (shown below) and *rhumb line*
paths:

```dart
  final greenwich = Geographic.parseDms(lat: '51°28′40″ N', lon: '0°00′05″ W');
  final sydney = Geographic.parseDms(lat: '33.8688° S', lon: '151.2093° E');

  // Distance (~ 16988 km)
  greenwich.spherical.distanceTo(sydney);

  // Initial and final bearing: 61° -> 139°
  greenwich.spherical.initialBearingTo(sydney);
  greenwich.spherical.finalBearingTo(sydney);

  // Destination point (10 km to bearing 61°): 51° 31.3′ N, 0° 07.5′ E
  greenwich.spherical.destinationPoint(distance: 10000, bearing: 61.0);

  // Midpoint: 28° 34.0′ N, 104° 41.6′ E
  greenwich.spherical.midPointTo(sydney);
```

Geometry primitive and multi geometry objects:

```dart
  // A point with a 2D position.
  Point.build([30.0, 10.0]);
 
  // A line string (polyline) with three 2D positions.
  LineString.build([30, 10, 10, 30, 40, 40]);

  // A polygon with an exterior ring (and without any holes).
  Polygon.build([
    [30, 10, 40, 40, 20, 40, 10, 20, 30, 10]
  ]);

  // A polygon with an exterior ring and an interior ring as a hole.
  Polygon.build([
    [35, 10, 45, 45, 15, 40, 10, 20, 35, 10],
    [20, 30, 35, 35, 30, 20, 20, 30],
  ]);

  // A multi point with four points:
  MultiPoint.build([
    [10, 40],
    [40, 30],
    [20, 20],
    [30, 10]
  ]);

  // A multi line string with two line strings (polylines):
  MultiLineString.build([
    [10, 10, 20, 20, 10, 40],
    [40, 40, 30, 30, 40, 20, 30, 10]
  ]);

  // A multi polygon with two polygons both with an outer ring (without holes).
  MultiPolygon.build([
    [
      [30, 20, 45, 40, 10, 40, 30, 20],
    ],
    [
      [15, 5, 40, 10, 10, 20, 5, 10, 15, 5],
    ],
  ]);

  // A geometry collection with a point, a line string and a polygon.
  GeometryCollection([
    Point.build([30.0, 10.0]),
    LineString.build([10, 10, 20, 20, 10, 40]),
    Polygon.build([
      [40, 40, 20, 45, 45, 30, 40, 40],
    ])
  ]);
```

Primitive geometries introduced above contain geographic or projected positions:
* `Point` with a single position
* `LineString` with a chain of positions (at least two positions)
* `Polygon` with an array of linear rings (exactly one exterior and 0 to N interior rings with each ring being a closed chain of positions)

In previous samples position data (chains of positions) is NOT modeled as
iterables of position objects, but as a flat structure represented by arrays of
coordinate values, for example:
* 2D position arrays: `[x0, y0, x1, y1, x2, y2, ...]`
* 3D position arrays: `[x0, y0, z0, x1, y1, z1, x2, y2, z2, ...]`

To distinguish between arrays of different spatial dimensions you can use
`Coords` enum:

```dart
  LineString.build([30, 10, 10, 30, 40, 40]); // default type == Coords.xy 
  LineString.build([30, 10, 10, 30, 40, 40], type: Coords.xy); 
  LineString.build([30, 10, 5.5, 10, 30, 5.5, 40, 40, 5.5], type: Coords.xyz);
```

GeoJSON, WKT and WKB formats are supported as input and output:

```dart
  // Parse a geometry from GeoJSON text.
  final geometry = LineString.parse(
    '{"type": "LineString", "coordinates": [[30,10],[10,30],[40,40]]}',
    format: GeoJSON.geometry,
  );

  // Encode a geometry as GeoJSON text.
  print(geometry.toText(format: GeoJSON.geometry));

  // Encode a geometry as WKT text.
  print(geometry.toText(format: WKT.geometry));

  // Encode a geometry as WKB bytes.
  final bytes = geometry.toBytes(format: WKB.geometry);

  // Decode a geometry from WKB bytes.
  LineString.decode(bytes, format: WKB.geometry);
```

*Features* represent geospatial entities with properies and geometries: 

```dart
  Feature(
    id: 'ROG',
    // a point geometry with a position (lon, lat, elev)
    geometry: Point.build([-0.0014, 51.4778, 45.0]),
    properties: {
      'title': 'Royal Observatory',
    },
  );
```

The GeoJSON format is supported as text input and output for features:

```dart
  final feature = Feature.parse(
    '''
      { 
        "type": "Feature", 
        "id": "ROG", 
        "geometry": {
          "type": "Point", 
          "coordinates": [-0.0014, 51.4778, 45.0]
        }, 
        "properties": {
          "title": "Royal Observatory"
        }
      }
    ''',
    format: GeoJSON.feature,
  );
  print(feature.toText(format: GeoJSON.feature));
```

Collections of feature objects are modeled as `FeatureCollection` objects. See
the chapter about [geospatial features](#geospatial-features) for more
information.

Temporal instants and intervals, and geospatial extents:

```dart
  // An instant and three intervals (open-started, open-ended, closed).
  Instant.parse('2020-10-31 09:30Z');
  Interval.parse('../2020-10-31');
  Interval.parse('2020-10-01/..');
  Interval.parse('2020-10-01/2020-10-31');

  // An extent with spatial (WGS 84 longitude-latitude) and temporal parts.
  GeoExtent.single(
    crs: CoordRefSys.CRS84,
    bbox: GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0),
    interval: Interval.parse('../2020-10-31'),
  );
```

Coordinate projections, tiling schemes (web mercator, global geodetic) and
coordinate array classes are some of the more advanced topics not introduced
here. Please see separate chapters about [projections](#projections),
[tiling schemes](#tiling-schemes) and [coordinate arrays](#coordinate-arrays) to
learn about them.

## Usage

The package requires at least [Dart](https://dart.dev/) SDK 2.17, and it
supports all [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/)
platforms.

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  geobase: ^1.1.0-dev.0
```

Import it:

```dart
import `package:geobase/geobase.dart`
```

There are also partial packages containing only a certain subset. See the
[Packages](#packages) section below.

Other resources:

> 📚 **Web APIs**: See also the [geodata](https://pub.dev/packages/geodata)
> package that extends capabilities of `geobase` by providing geospatial API
> clients to read [GeoJSON](https://geojson.org/) data sources and 
> [OGC API Features](https://ogcapi.ogc.org/features/) web services.
> 
> 🚀 **Samples**: 
> The [Geospatial demos for Dart](https://github.com/navibyte/geospatial_demos)
> repository contains more sample code showing also how to use this package!

## Coordinates

### Position data

The basic building blocks to represent position data in this package are:

Class            | Description
---------------- | -----------
`Position`       | A position with 2 to 4 coordinate values (x and y are required, z and m are optional) representing an exact location in some coordinate reference system.
`PositionSeries` | A series of 0 to N positions built from a coordinate value array or a list of position objects.
`Box`            | A bounding box with 4 to 8 coordinate values (minX, minY, maxX and maxY are required, minZ, minM, maxZ and maxM are optional).

These classes are used by [geometry classes](#geometries) as internal data
structures to store single positions and boxes, and series of positions.

Some basic samples to create position objects:

```dart
  // A position as a view on a coordinate array containing x and y.
  Position.view([708221.0, 5707225.0]);

  // A position as a view on a coordinate array containing x, y and z.
  Position.view([708221.0, 5707225.0, 45.0]);

  // A position as a view on a coordinate array containing x, y, z and m.
  Position.view([708221.0, 5707225.0, 45.0, 123.0]);

  // The samples above can be shorted using extension methods on `List<double>`.
  [708221.0, 5707225.0].xy;
  [708221.0, 5707225.0, 45.0].xyz;
  [708221.0, 5707225.0, 45.0, 123.0].xyzm;

  // There are also some other factory methods.
  Position.create(x: 708221.0, y: 5707225.0, z: 45.0, m: 123.0);
  Position.parse('708221.0,5707225.0,45.0,123.0');
  Position.parse('708221.0 5707225.0 45.0 123.0', delimiter: ' ');
```

Bounding boxes have similar factory methods too:

```dart
  // The same bounding box (limits on x and y) created with different factories.
  Box.view([70800.0, 5707200.0, 70900.0, 5707300.0]);
  Box.create(minX: 70800.0, minY: 5707200.0, maxX: 70900.0, maxY: 5707300.0);
  Box.parse('70800.0,5707200.0,70900.0,5707300.0');
  Box.parse('70800.0 5707200.0 70900.0 5707300.0', delimiter: ' ');

  // The same box using extension methods on `List<double>`.
  [70800.0, 5707200.0, 70900.0, 5707300.0].box;
```

`PositionSeries` is a fixed-length (and random-access) view to a series of
positions. There are two main structures to store coordinate values of positions
contained in a series:

* A list of `Position` objects (each object contains x and y coordinates, and
  optionally z and m too).
* A list of `double` values as a flat structure. For example a double list could
  contain coordinates like `[x0, y0, z0, x1, y1, z1, x2, y2, z2]` that
  represents three positions each with x, y and z coordinates.

These two structures are demonstrated by code:

```dart
  // A position series from a flat coordinate value array.
  PositionSeries.view(
    [
      70800.0, 5707200.0, // (x, y) coordinate values for position 0
      70850.0, 5707250.0, // (x, y) coordinate values for position 1
      70900.0, 5707300.0, // (x, y) coordinate values for position 2
    ],
    type: Coords.xy,
  );

  // A position series from an array of position objects.
  PositionSeries.from(
    [
      [70800.0, 5707200.0].xy, // position 0 with (x, y) coordinate values
      [70850.0, 5707250.0].xy, // position 1 with (x, y) coordinate values
      [70900.0, 5707300.0].xy, // position 2 with (x, y) coordinate values
    ],
    type: Coords.xy,
  );
```

Building PositionSeries objects from coordinate value arrays can be also
shortened. This can be handy when specifying position data in Dart code.

```dart
  // A position series from a flat coordinate value array (2D positions).
  [
    70800.0, 5707200.0, // (x, y) coordinate values for position 0
    70850.0, 5707250.0, // (x, y) coordinate values for position 1
    70900.0, 5707300.0, // (x, y) coordinate values for position 2
  ].positions(Coords.xy);

  // A position series from a flat coordinate value array (3D positions).
  [
    70800.0, 5707200.0, 40.0, // (x, y, z) coordinate values for position 0
    70850.0, 5707250.0, 45.0, // (x, y, z) coordinate values for position 1
    70900.0, 5707300.0, 50.0, // (x, y, z) coordinate values for position 2
  ].positions(Coords.xyz);
```

See also the appendix about [coordinate arrays](#coordinate-arrays) for more
advanced topic about handling coordinate value arrays for a single position,
series of positions and a single bounding box. 

Classes described above can be used to represented position data in various
coordinate reference systems, including *geographic*, *projected* and local
systems.

There are also very specific subtypes of `Position` and `Box` classes. 

`Projected` (extending `Position`) and `ProjBox` (extending `Box`) can be used
to represent *projected* or cartesian (XYZ) coordinates. Similarily `Geographic`
and `GeoBox` can be used to represent *geographic* coordinates. 

These special purpose subtypes for positions and boxes are discussed in next
few sections.

### Geographic coordinates

*Geographic* coordinates are based on a spherical or ellipsoidal coordinate
system representing positions on the Earth as longitude (`lon`) and latitude
(`lat`).

Elevation (`elev`) in meters and measure (`m`) coordinates are optional.

<a title="Djexplo, CC0, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Latitude_and_Longitude_of_the_Earth.svg"><img alt="Latitude and Longitude of the Earth" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/coordinates/geographic/Latitude_and_Longitude_of_the_Earth.svg"></a>

Geographic *positions*:

```dart
  // A geographic position with longitude and latitude.
  Geographic(lon: -0.0014, lat: 51.4778);

  // A geographic position with longitude, latitude and elevation.
  Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0);

  // A geographic position with longitude, latitude, elevation and measure.
  Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0, m: 123.0);

  // The last sample also from a double list or text (order: lon, lat, elev, m).
  Geographic.build([-0.0014, 51.4778, 45.0, 123.0]);
  Geographic.parse('-0.0014,51.4778,45.0,123.0');
  Geographic.parse('-0.0014 51.4778 45.0 123.0', delimiter: ' ');
```

Geographic *bounding boxes*:

```dart
  // A geographic bbox (-20 .. 20 in longitude, 50 .. 60 in latitude).
  GeoBox(west: -20, south: 50, east: 20, north: 60);

  // A geographic bbox with limits (100 .. 200) on the elevation coordinate too.
  GeoBox(west: -20, south: 50, minElev: 100, east: 20, north: 60, maxElev: 200);

  // The last sample also from a double list or text.
  GeoBox.build([-20, 50, 100, 20, 60, 200]);
  GeoBox.parse('-20,50,100,20,60,200');
```

### Geographic string representations (DMS)

A geographic position can also be parsed from sexagesimal degrees (latitude
and longitude subdivided to degrees, minutes and seconds):

```dart
  // Decimal degrees (DD) with signed numeric degree values.
  Geographic.parseDms(lat: '51.4778', lon: '-0.0014');

  // Decimal degrees (DD) with degree and cardinal direction symbols (N/E/S/W).
  Geographic.parseDms(lat: '51.4778°N', lon: '0.0014°W');

  // Degrees and minutes (DM).
  Geographic.parseDms(lat: '51°28.668′N', lon: '0°00.084′W');

  // Degrees, minutes and seconds (DMS).
  Geographic.parseDms(lat: '51° 28′ 40″ N', lon: '0° 00′ 05″ W');
```

Format geographic coordinates as string representations (DD, DM, DMS):

```dart
  const p = Geographic(lat: 51.4778, lon: -0.0014);

  // all three samples print decimal degrees: 51.4778°N 0.0014°W
  print(p.latLonDms(separator: ' '));
  print('${p.latDms()} ${p.lonDms()}');
  print('${Dms().lat(51.4778)} ${Dms().lon(-0.0014)}');

  // prints degrees and minutes: 51°28.668′N, 0°00.084′W
  const dm = Dms(type: DmsType.degMin, decimals: 3);
  print(p.latLonDms(format: dm));

  // prints degrees, minutes and seconds: 51° 28′ 40″ N, 0° 00′ 05″ W
  const dms = Dms.narrowSpace(type: DmsType.degMinSec);
  print(p.latLonDms(format: dms));

  // 51 degrees 28 minutes 40 seconds to N, 0 degrees 0 minutes 5 seconds to W
  const dmsTextual = Dms(
    type: DmsType.degMinSec,
    separator: ' ',
    decimals: 0,
    zeroPadMinSec: false,
    degree: ' degrees',
    prime: ' minutes',
    doublePrime: ' seconds to',
  );
  print(p.latLonDms(format: dmsTextual));
```

Parsing and formatting is supported also for geographic bounding boxes:

```dart
  // Parses box from decimal degrees (DD) with cardinal direction symbols.
  final box =
      GeoBox.parseDms(west: '20°W', south: '50°N', east: '20°E', north: '60°N');

  // prints degrees and minutes: 20°0′W 50°0′N, 20°0′E 60°0′N
  const dm0 = Dms(type: DmsType.degMin, decimals: 0, zeroPadMinSec: false);
  print('${box.westDms(dm0)} ${box.southDms(dm0)}'
      ' ${box.eastDms(dm0)} ${box.northDms(dm0)}');
```

In the previous example `dm`, `dm0`, `dms` and `dmsTextual` are instances of the
`Dms` class that implements `DmsFormat`. This defines multiple methods for
parsing and formatting decimal degrees and sexagesimal degrees
(degrees/minutes/seconds) on latitude, longitude and bearing values. 

The default format used by `Geographic` and `GeoBox` classes formats values as
decimal degrees with cardinal direction symbols. To use other formats
(degrees/minutes or degrees/minutes/seconds), or to set other parameters (like
separators, symbol characters, the number of decimals, zero padding or value
signing) you should create a custom `Dms` instance.

See the API documentation and [DMS test cases](test/coordinates/dms_test.dart)
for more samples.

### Projected coordinates

<a title="Sommacal alfonso, CC BY-SA 4.0 &lt;https://creativecommons.org/licenses/by-sa/4.0/deed.en&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Cartesian_coordinates.png"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/coordinates/cartesian/Cartesian_coordinates.png" align="right"></a>

*Projected* coordinates represent projected or cartesian (XYZ) coordinates with
an optional measure (m) coordinate. For projected map positions `x` often
represents *easting* (E) and `y` represents *northing* (N), however a coordinate
reference system might specify something else too. 

The `m` (measure) coordinate represents a measurement or a value on a linear
referencing system (like time). It could be associated with a 2D position
(x, y, m) or a 3D position (x, y, z, m).

Projected *positions*:

```dart
  // A projected position with x and y.
  Projected(x: 708221.0, y: 5707225.0);

  // A projected position with x, y and z.
  Projected(x: 708221.0, y: 5707225.0, z: 45.0);

  // A projected position with x, y, z and m.
  Projected(x: 708221.0, y: 5707225.0, z: 45.0, m: 123.0);

  // The last sample also from a double list or text (order: x, y, z, m).
  Projected.build([708221.0, 5707225.0, 45.0, 123.0]);
  Projected.parse('708221.0,5707225.0,45.0,123.0');
  Projected.parse('708221.0 5707225.0 45.0 123.0', delimiter: ' ');
```

Projected *bounding boxes*:

```dart
  // A projected bbox with limits on x and y.
  ProjBox(minX: 10, minY: 10, maxX: 20, maxY: 20);

  // A projected bbox with limits on x, y and z.
  ProjBox(minX: 10, minY: 10, minZ: 10, maxX: 20, maxY: 20, maxZ: 20);

  // The last sample also from a double list or text.
  ProjBox.build([10, 10, 10, 20, 20, 20]);
  ProjBox.parse('10,10,10,20,20,20');
```

### Scalable coordinates

*Scalable* coordinates are coordinates associated with a *level of detail* (LOD)
or a `zoom` level. They are used for example by
[tiling schemes](#tiling-schemes) to represent *pixels* or *tiles* in tile
matrices.

The `Scalable2i` class represents projected `x`, `y` coordinates at `zoom`
level, with all values as integers.

```dart
  // A pixel with a zoom level (or LOD = level of detail) coordinates.
  const pixel = Scalable2i(zoom: 9, x: 23, y: 10);

  // Such coordinates can be scaled to other zoom levels.
  pixel.zoomIn(); // => Scalable2i(zoom: 10, x: 46, y: 20);
  pixel.zoomOut(); // => Scalable2i(zoom: 8, x: 11, y: 5);
  pixel.zoomTo(13); // => Scalable2i(zoom: 13, x: 368, y: 160));
```

### Coordinates summary 

Classes representing *position*, *bounding box* and *scalable* coordinates:

<img src="https://raw.githubusercontent.com/navibyte/geospatial/v0.12.0/dart/geobase/assets/diagrams/position_box_scalable.svg" width="100%" title="Position, Box and Scalable classes" />

Coordinate values in *position* classes (*projected* and *geographic*):

Class         | Required coordinates      | Optional coordinates  | Values
------------- | ------------------------- | --------------------- | ------
`Position`    | x, y                      | z, m                  | double
`Projected`   | x, y                      | z, m                  | double
`Geographic`  | lon, lat                  | elev, m               | double

Coordinate values in *bounding box* classes (*projected* and *geographic*):

Class         | Required coordinates      | Optional coordinates         | Values
------------- | ------------------------- | ---------------------------- | ------
`Box`         | minX, minY, maxX, maxY    | minZ, minM, maxZ, maxM       | double
`ProjBox`     | minX, minY, maxX, maxY    | minZ, minM, maxZ, maxM       | double
`GeoBox`      | west, south, east, north  | minElev, minM, maxElev, maxM | double

Ccoordinate values in *scalable* classes:

Class         | Required coordinates      | Optional coordinates  | Values
------------- | ------------------------- | --------------------- | ------
`Scalable2i`  | zoom, x, y                |                       | int

In some interfaces, for example for positions, coordinate values are referenced
only by x, y, z and m property names. So in such a case and in the context of
this package, for geographic coordinates x represents *longitude*, y represents
*latitude*, and z represents *elevation* (or height or altitude).

Coordinates are stored as `double` values in all position and bounding box
classes but `Scalable2i` uses `int` coordinate values. 

The `Position` class is a super type for `Projected` and `Geographic`, and
the `Box` class is a super type for `ProjBox` and `GeoBox`. Please see more
information about them in the API reference.

## Coordinate reference systems

According to Wikipedia a
[Coordinate reference system](https://en.wikipedia.org/wiki/Spatial_reference_system) 
is *a coordinate-based local, regional or global system used to locate
geographical entities*. 

Coordinate reference systems are identified by `String` identifiers. Such ids
are specified by registries like [The EPSG dataset](https://epsg.org/).

The package also contains `CoordRefSys` class that has constant instaces for:

Constant    | Description
----------- | -----------
`CRS84`     | WGS 84 geographic coordinates (order: longitude, latitude).
`CRS84h`    | WGS 84 geographic coordinates (order: longitude, latitude) with ellipsoidal height (elevation).
`EPSG:4326` | WGS 84 geographic coordinates (order: latitude, longitude).
`EPSG:4258` | ETRS89 geographic coordinates (order: latitude, longitude).
`EPSG:3857` | WGS 84 projected (Web Mercator) metric coordinates based on "spherical development of ellipsoidal coordinates".
`EPSG:3395` | WGS 84 projected (World Mercator) metric coordinates based on "ellipsoidal coordinates".

The `String` identifiers for these constants are formatted using the
`http://www.opengis.net/def/crs/{authority}/{version}/{code}` template.
Identifiers using the common `EPSG:{code}` template are normalized also to it
when instantiating with the `CoordRefSys.normalized()` constructor.

Please note that `CRS84` and `EPSG:4326` both refer to the WGS 84 geographic
coordinate system, but in external data representations their axis order
differs.

To customize identifier normalization and axis order resolving algorithm you
should create a custom class implementing `CoordRefSysResolver` and register
it's global instance using `CoordRefSysResolver.register()`.

## Temporal coordinate reference systems

There is also a type `TemporalRefSys` for specifying a temporal coordinate
reference system. A custom logic can be registered using
`TemporalRefSysResolver.register()`.

Currently there is only one constant identifier defined by `TemporalRefSys`:

Constant    | Description
----------- | -----------
`gregorian` | References temporal coordinates, dates or timestamps, that are in the Gregorian calendar and conform to [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339.html).

## Spherical geodesy

### Overview

The package contains a port for Dart language of spherical geodesy tools,
originally written in JavaScript by Chris Veness. See the online form at the
[Movable Type Scripts](https://www.movable-type.co.uk/scripts/latlong.html) web
site and source
[code](https://github.com/chrisveness/geodesy/blob/master/latlon-spherical.js)
at GitHub.

These geodesy functions are based on calculations on a spherical earth model.
Distance, bearing, destination and other functions are provided both for great
circle paths and rhumb lines. All calculations use simple spherical
trigonometric algorithms.

Actually the earth is slightly ellipsoidal, not spherical. However errors are
typically up to 0.3% (see notes by
[Movable Type Scripts](https://www.movable-type.co.uk/scripts/latlong.html))
when using a spherical model instead of an ellipsoidal.

## Great circle vs rhumb line

According to Wikipedia, a
[great circle](https://en.wikipedia.org/wiki/Great_circle) or *orthodrome* is
the circular intersection of a sphere and a plane passing through the sphere's
center point. A [rhumb line](https://en.wikipedia.org/wiki/Rhumb_line) or
*loxodrome* is an arc crossing all meridians of longitude at the same angle,
that is, a path with constant bearing as measured relative to true north.

<a title="Jacob Rus CC BY-SA 4.0 &lt;https://creativecommons.org/licenses/by-sa/4.0/deed.en&gt;, via Wikimedia Commons" href="https://en.wikipedia.org/wiki/File:Rhumb_line_vs_great-circle_arc.png"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/geodesy/rhumb_line_vs_great_circle/197px_Rhumb_line_vs_great-circle_arc.png" align="right"></a>

Differences between a rhumb line (blue) compared to a great-circle arc (red) as
[described](https://en.wikipedia.org/wiki/Rhumb_line) by Wikipedia are
visualized in the illustration (top: orthographic projection, bottom: Mercator
projection) showing paths from Lisbon, Portugal to Havana, Cuba. 

The rhumb line path is slightly longer than the path along the great circle.
Rhumb lines are sometimes used in marine navigation as it's easier to follow a
constant compass bearing than adjusting bearings when following a great circle
path.

### Great circle paths

Examples using *great circle* paths (orthodromic) on a spherical earth model:

```dart
  // sample geographic positions
  final greenwich = Geographic.parseDms(lat: '51°28′40″ N', lon: '0°00′05″ W');
  final sydney = Geographic.parseDms(lat: '33.8688° S', lon: '151.2093° E');

  // decimal degrees (DD) and degrees-minutes (DM) formats
  const dd = Dms(decimals: 0);
  const dm = Dms.narrowSpace(type: DmsType.degMin, decimals: 1);

  // prints: 16988 km
  final distanceKm = greenwich.spherical.distanceTo(sydney) / 1000.0;
  print('${distanceKm.toStringAsFixed(0)} km');

  // prints (bearing varies along the great circle path): 61° -> 139°
  final initialBearing = greenwich.spherical.initialBearingTo(sydney);
  final finalBearing = greenwich.spherical.finalBearingTo(sydney);
  print('${dd.bearing(initialBearing)} -> ${dd.bearing(finalBearing)}');

  // prints: 51° 31.3′ N, 0° 07.5′ E
  final destPoint =
      greenwich.spherical.destinationPoint(distance: 10000, bearing: 61.0);
  print(destPoint.latLonDms(format: dm));

  // prints: 28° 34.0′ N, 104° 41.6′ E
  final midPoint = greenwich.spherical.midPointTo(sydney);
  print(midPoint.latLonDms(format: dm));

  // prints 10 intermediate points, like fraction 0.6: 16° 14.5′ N, 114° 29.3′ E
  for (var fr = 0.0; fr < 1.0; fr += 0.1) {
    final ip = greenwich.spherical.intermediatePointTo(sydney, fraction: fr);
    print('${fr.toStringAsFixed(1)}: ${ip.latLonDms(format: dm)}');
  }

  // prints: 0° 00.0′ N, 125° 19.0′ E
  final intersection = greenwich.spherical.intersectionWith(
    bearing: 61.0,
    other: const Geographic(lat: 0.0, lon: 179.0),
    otherBearing: 270.0,
  );
  if (intersection != null) {
    print(intersection.latLonDms(format: dm));
  }
```

### Rhumb line paths

Examples using *rhumb line* paths (loxodromic) on a spherical earth model:

```dart
  // prints: 17670 km
  final distanceKm = greenwich.rhumb.distanceTo(sydney) / 1000.0;
  print('${distanceKm.toStringAsFixed(0)} km');

  // prints (bearing remains the same along the rhumb line path): 122° -> 122°
  final initialBearing = greenwich.rhumb.initialBearingTo(sydney);
  final finalBearing = greenwich.rhumb.finalBearingTo(sydney);
  print('${dd.bearing(initialBearing)} -> ${dd.bearing(finalBearing)}');

  // prints: 51° 25.8′ N, 0° 07.3′ E
  final destPoint =
      greenwich.spherical.destinationPoint(distance: 10000, bearing: 122.0);
  print(destPoint.latLonDms(format: dm));

  // prints: 8° 48.3′ N, 80° 44.0′ E
  final midPoint = greenwich.rhumb.midPointTo(sydney);
  print(midPoint.latLonDms(format: dm));
```

More examples are provided in the API documentation and
[test cases](test/geodesy/spherical_ported_test.dart).

## Geometries

### Geometry types

Geometry primitive types supported by this package (with samples adapted from
the samples of the Wikipedia page about
[WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry),
and compatible also with [GeoJSON](https://geojson.org/)):

Geometry    | Shape       | Dart code to build objects
----------- | ----------- | --------------------------
Point       | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Point.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_Point.svg"></a> | `Point.build([30.0, 10.0])`
LineString  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_LineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_LineString.svg"></a> | `LineString.build([30, 10, 10, 30, 40, 40])`
Polygon     | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_Polygon.svg"></a> | `Polygon.build([[30, 10, 40, 40, 20, 40, 10, 20, 30, 10]])`
Polygon (with a hole) | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_Polygon_with_hole.svg"></a> | `Polygon.build([[35, 10, 45, 45, 15, 40, 10, 20, 35, 10], [20, 30, 35, 35, 30, 20, 20, 30]])`

Also multipart geometry classes are supported:

Geometry    | Shape       | Dart code to build objects
----------- | ----------- | --------------------------
MultiPoint  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPoint.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_MultiPoint.svg"></a> | `MultiPoint.build([[10, 40], [40, 30], [20, 20], [30, 10]])`
MultiLineString  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiLineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_MultiLineString.svg"></a> | `MultiLineString.build([[10, 10, 20, 20, 10, 40], [40, 40, 30, 30, 40, 20, 30, 10]])`
MultiPolygon | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPolygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_MultiPolygon.svg"></a> | `MultiPolygon.build([[[30, 20, 45, 40, 10, 40, 30, 20]], [[15, 5, 40, 10, 10, 20, 5, 10, 15, 5]]])`
MultiPolygon (with a hole) | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPolygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_MultiPolygon_with_hole.svg"></a> | `MultiPolygon.build([[[40, 40, 20, 45, 45, 30, 40, 40]], [[20, 35, 10, 30, 10, 10, 30, 5, 45, 20, 20, 35], [30, 20, 20, 15, 20, 25, 30, 20]]])`
GeometryCollection | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_GeometryCollection.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_GeometryCollection.svg"></a> | `GeometryCollection([Point.build([30.0, 10.0]), LineString.build([10, 10, 20, 20, 10, 40]), Polygon.build([[40, 40, 20, 45, 45, 30, 40, 40]])])`

Samples above expect 2D coordinates (x and y coordinates - or longitude and 
latitude).

When data contains more coordinates, like also z in 3D data, then the `type`
parameter in build methods (for geometries other than `Point`) must always be
used explicitely to define the coordinate type.

A line string with 3 points (2D coordinates with x and y) from the table above:

```dart
LineString.build([30, 10, 10, 30, 40, 40]);
```

In this call there was no need to specify the coordinate type, but the same
example adjusted to contain 3D coordinates (x, y and z) requires explicitely
also the `type` parameter (here each point has the `z` value of 5.5):

```dart
LineString.build([30, 10, 5.5, 10, 30, 5.5, 40, 40, 5.5], type: Coords.xyz);
```

This sample even extended, a line string with 3D and measured coordinates (x, y,
z and m) is created below (here the `m` value grows from 3.1 to 3.3):

```dart
LineString.build(
  [30, 10, 5.5, 3.1, 10, 30, 5.5, 3.2, 40, 40, 5.5, 3.3], 
  type: Coords.xyzm,
);
```

Geometry objects can be created also from iterables of `Position` objects
(instances of `Position` itself, or subtypes `Projected` and `Geographic`):

```dart
  // A line string with 3 points (2D coordinates with x and y).
  LineString.from([
    [30.0, 10.0].xy, // xy => Position.view()
    [10.0, 30.0].xy,
    [40.0, 40.0].xy,
  ]);

  // A line string with 3 points (3D coordinates with x, y and z).
  LineString.from([
    Geographic(lon: 30, lat: 10, elev: 5.5), // x = lon, y = lat, z = elev
    Geographic(lon: 10, lat: 30, elev: 5.5),
    Geographic(lon: 40, lat: 40, elev: 5.5),
  ]);

  // A line string with 3 points (3D and measured coordinates: x, y, z and m).
  LineString.from([
    Projected(x: 30, y: 10, z: 5.5, m: 3.1),
    Projected(x: 10, y: 30, z: 5.5, m: 3.2),
    Projected(x: 40, y: 40, z: 5.5, m: 3.3),
  ]);
```

In all geometry classes there are also some other ways to create objects:
* default constructors: creates a geometry object using [coordinate arrays](#coordinate-arrays)
* `parse`: parses a geometry object from text conforming to some text format like GeoJSON or WKT
* `decode`: decodes a geometry object from bytes conforming to some binary format like WKB

The following class diagram describes key members of `Point`, `LineString`
and `Polygon` geometry classes:

<img src="https://raw.githubusercontent.com/navibyte/geospatial/64852f5/dart/geobase/assets/diagrams/point_linestring_polygon.svg" width="100%" title="Point, LineString and Polygon geometry classes" />

Primitive geometry classes described by the diagram:
* `Point` with a single position represented by `Position`
* `LineString` with a chain of positions (at least two positions) represented by `PositionSeries`
* `Polygon` with an array of linear rings 
  * exactly one `exterior` ring represented by `PositionSeries`
  * 0 to N `interior` rings (holes) with each represented by `PositionSeries`

The `PositionSeries` class is described in the appendix
about [coordinate arrays](#coordinate-arrays) and the `SimpleGeometryContent`
interface visible in the diagram in [content interfaces](#content-interfaces).
The usage of `project()` method is described in the chapter about
[projections](#projections).

See also the class diagram about multi and collection geometries below:

<img src="https://raw.githubusercontent.com/navibyte/geospatial/64852f5/dart/geobase/assets/diagrams/multi_and_collection_geometries.svg" width="100%" title="Multi and collection geometry classes" />

For example `MultiLineString` stores `chains` of positions for all line strings
as a list of `PositionSeries`. It's also possible to get a mapped iterable of
`LineString` objects using the `lineStrings` getter. 

## Geospatial features

### Feature objects

According to the [OGC Glossary](https://www.ogc.org/resources/ogc-glossary/) a geospatial **feature** is *a digital representation of a real world entity. It has a spatial domain, a temporal domain, or a spatial/temporal domain as one of its attributes. Examples of features include almost anything that can be placed in time and space, including desks, buildings, cities, trees, forest stands, ecosystems, delivery vehicles, snow removal routes, oil wells, oil pipelines, oil spill, and so on*.

Below is an illustration of features in a simple vector map. *Wells* are features
with point geometries, *rivers* with line strings (or polyline) geometries, and
finally *lakes* are features with polygon geometries. Features normally contain
also an identifier and other attributes (or properties) along with a geometry.  

<a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Simple_vector_map.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/Simple_vector_map.svg"></a>

Sets of features are contained by **feature collections**.
 
As specified also by the [GeoJSON](https://geojson.org/) format a `Feature`
object contains a geometry object and additional members (like "id" and 
"properties"). A `FeatureCollection` object contains an array of `Feature`
objects. Both may also contain "bbox" or bounding box. Any other members on
`Feature` and  `FeatureCollection` objects are *foreign members*, allowed
property values or geometry objects, but not specified by the GeoJSON model
(and so potentially not known by many GeoJSON parsers).

This package models features and feature collections according to these
definitions:

<img src="https://raw.githubusercontent.com/navibyte/geospatial/64852f5/dart/geobase/assets/diagrams/feature_objects.svg" width="100%" title="Feature object classes" />

### Feature

A single `Feature` object: 

```dart
  // A geospatial feature with id, a point geometry and properties.
  Feature(
    id: 'ROG',
    // a point geometry with a position (lon, lat, elev)
    geometry: Point.build([-0.0014, 51.4778, 45.0]),
    properties: {
      'title': 'Royal Observatory',
      'place': 'Greenwich',
      'city': 'London',
      'isMuseum': true,
      'measure': 5.79,
    },
  );
```

Naturally, the `geometry` member could also contain any other geometry types
described earlier, not just points.

An optional `id`, when given, should be either a string or an integer. The 
`properties` member defines feature properties as a map with the JSON Object
compatible model (or `Map<String, dynamic>` as such data is typed in Dart).

### FeatureCollection

A `FeatureCollection` object with `Feature` objects:

```dart
  // A geospatial feature collection (with two features):
  FeatureCollection([
    Feature(
      id: 'ROG',
      // a point geometry with a position (lon, lat, elev)
      geometry: Point.build([-0.0014, 51.4778, 45.0]),
      properties: {
        'title': 'Royal Observatory',
        'place': 'Greenwich',
        'city': 'London',
        'isMuseum': true,
        'measure': 5.79,
      },
    ),
    Feature(
      id: 'TB',
      // a point geometry with a position (lon, lat)
      geometry: Point.build([-0.075406, 51.5055]),
      properties: {
        'title': 'Tower Bridge',
        'city': 'London',
        'built': 1886,
      },
    ),
  ]);
```

## Vector data formats

### GeoJSON with WGS 84 longitude/latitude

As already described [GeoJSON](https://geojson.org/) is a format for encoding
geometry, feature and feature collection objects. The data structures introduced
on previous [geometries](#geometries) and
[geospatial features](#geospatial-features) sections are modelled to support
encoding and decoding GeoJSON data.

As specified by the [RFC 7946](https://tools.ietf.org/html/rfc7946) standard,
all GeoJSON geometry objects use 
[WGS 84](https://en.wikipedia.org/wiki/World_Geodetic_System) longitude/latitude
geographic coordinates. Also alternative coordinate reference systems can be used when *involved parties have a prior arrangement* of using other systems.

In this package the default coordinate reference system (WGS 84 with longitude
before latitude) can also be referenced by the `CoordRefSys.CRS84` constant.
Normally when parsing and writing content in this default coordinate system you
don't need to specify a crs however.

This package supports encoding GeoJSON text from geometry and feature objects:

```dart
  // build a LineString sample geometry
  final lineString = LineString.build(
    [-1.1, -1.1, 2.1, -2.5, 3.5, -3.49],
    type: Coords.xy,
    bounds: [-1.1, -3.49, 3.5, -1.1].box,
  );

  // ... and print it as GeoJSON text:
  //   { 
  //     "type":"LineString",
  //     "bbox":[-1.1,-3.49,3.5,-1.1],
  //     "coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]
  //   }
  print(lineString.toText(format: GeoJSON.geometry));

  // GeoJSON representation for other geometries, features and feature
  // collections can be produced with `toText` methdod also.

  // here a Feature is printed as GeoJSON text (with 3 decimals on doubles):
  //   {
  //     "type":"Feature",
  //     "id":"TB",
  //     "geometry":{"type":"Point","coordinates":[-0.075,51.505]},
  //     "properties":{"title":"Tower Bridge","city":"London","built":1886}
  //   }
  final feature = Feature(
    id: 'TB',
    geometry: Point.build([-0.075406, 51.5055]),
    properties: {
      'title': 'Tower Bridge',
      'city': 'London',
      'built': 1886,
    },
  );
  print(feature.toText(format: GeoJSON.feature, decimals: 3));
```

Geometry and feature objects can be also parsed from their GeoJSON text 
representations:

```dart
  // sample GeoJSON text representation (a feature collection with two features)
  const sample = '''
    {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": "ROG",
          "geometry": {
            "type": "Point",
            "coordinates": [-0.0014, 51.4778, 45.0]  
          },
          "properties": {
            "title": "Royal Observatory",
            "place": "Greenwich"
          }
        }, 
        {
          "type": "Feature",
          "id": "TB",
          "geometry": {
            "type": "Point",
            "coordinates": [-0.075406, 51.5055]  
          },
          "properties": {
            "title": "Tower Bridge",
            "built": 1886
          }
        } 
      ]
    }
  ''';

  // parse a FeatureCollection object using the decoder of the GeoJSON format
  final collection = FeatureCollection.parse(sample, format: GeoJSON.feature);

  // loop through features and print id, geometry and properties for each
  for (final feature in collection.features) {
    print('Feature with id: ${feature.id}');
    print('  geometry: ${feature.geometry}');
    print('  properties:');
    for (final key in feature.properties.keys) {
      print('    $key: ${feature.properties[key]}');
    }
  }
```

All geometry, feature and feature collection classes has similar `parse` methods
to support parsing from GeoJSON.

### GeoJSONL - newline-delimited GeoJSON

[GeoJSONL](https://www.interline.io/blog/geojsonl-extracts/) or
[newline-delimited GeoJSON](https://stevage.github.io/ndgeojson/) (or
[GeoJSON Text Sequences](https://datatracker.ietf.org/doc/html/rfc8142)) is an
optimized variant of GeoJSON to encode sequences of geospatial features. A text
file conforming to this format represents one feature collection (without
*FeatureCollection* element encoded). Such a file may contain any number of
features that are separated by the newline character (`\n`).

Advantages of using GeoJSONL over the standard GeoJSON include efficiency when
streaming or storing very large number geospatial features. It's also much
simpler to decode newline-delimited GeoJSON data than hierarchically structured
standard GeoJSON data. A client could also skip some features on a stream
without parsing all data.

The decoder provided by `geobase` supports reading features delimited by
newline (`\n`), carriage-return followed by newline (`\r\n`) and
record-separator (RS) characters. By default the encoder delimits features using
the `\n` character.

A short sample describes how to use this format:

```dart
  /// a feature collection encoded as GeoJSONL and containing two features that
  /// are delimited by the newline character \n
  const sample = '''
    {"type":"Feature","id":"ROG","geometry":{"type":"Point","coordinates":[-0.0014,51.4778,45]},"properties":{"title":"Royal Observatory","place":"Greenwich"}}
    {"type":"Feature","id":"TB","geometry":{"type":"Point","coordinates":[-0.075406,51.5055]},"properties":{"title":"Tower Bridge","built":1886}}
    ''';

  // parse a FeatureCollection object using the decoder for the GeoJSONL format
  final collection = FeatureCollection.parse(sample, format: GeoJSONL.feature);

  // ... use features read and returned in a feature collection object ...

  // encode back to GeoJSONL data
  print(collection.toText(format: GeoJSONL.feature, decimals: 5));
```

### GeoJSON with alternative coordinate reference systems

When using GeoJSON to represent geospatial data in "alternative coordinate
reference systems", such a system must be explicitely defined (and known) before
reading in or before writing out GeoJSON content.

As described in the [coordinates summary](#coordinates-summary) internally all
classes in this package handle coordinate axis order so that x (or longitude) is
always before y (or latitude). However some coordinate reference systems require
other axis order when representing geometries in external data formats.

The `CoordRefSys` class introduced in the section about
[coordinate reference systems](#coordinate-reference-systems) has the `swapXY`
method that tells how axis order should be handled for a certain coordinate
reference system when dealing with external data representations (like the
current specification of GeoJSON) that do not specify a generic axis order for
alternative coordinate reference systems.

The sample below demonstrates the logic:

```dart
  // CRS for geographic coordinates with latitude before longitude in GeoJSON.
  const epsg4326 = CoordRefSys.EPSG_4326;

  // Read GeoJSON content with coordinate order: longitude, latitude, elevation.
  final point1 = Point.parse(
    '{"type": "Point", "coordinates": [-0.0014, 51.4778, 45.0]}',
    // no CRS must be specified for the default coordinate reference system:
    // `CoordRefSys.CRS84` or `http://www.opengis.net/def/crs/OGC/1.3/CRS84`
  );
  final pos1 = Geographic.from(point1.position);
  // prints: Point1: lon: 0.0014°W lat: 51.4778°N
  print('Point1: lon: ${pos1.lonDms()} lat: ${pos1.latDms()}');

  // Read GeoJSON content with coordinate order: latitude, longitude, elevation.
  final point2 = Point.parse(
    '{"type": "Point", "coordinates": [51.4778, -0.0014, 45.0]}',
    crs: epsg4326, // CRS must be explicitely specified
  );
  final pos2 = Geographic.from(point2.position);
  // prints: Point2: lon: 0.0014°W lat: 51.4778°N
  print('Point2: lon: ${pos2.lonDms()} lat: ${pos2.latDms()}');

  // Both `point1` and `point2` store coordinates internally in this order:
  // longitude, latitude, elevation.

  // Writing GeoJSON without crs information expects longitude-latitude order.
  // Prints: {"type":"Point","coordinates":[-0.0014,51.4778,45]}
  print(point2.toText(format: GeoJSON.geometry));

  // Writing with crs (EPSG:4326) results in latitude-longitude order.
  // Prints: {"type":"Point","coordinates":[51.4778,-0.0014,45]}
  print(point2.toText(format: GeoJSON.geometry, crs: epsg4326));
```

### WKT

[Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) (WKT) is 
*a text markup language for representing vector geometry objects*. It's 
specified by the [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa) standard.

Positions and geometries can be encoded to WKT text representations. However
feature and feature collections cannot be written to WKT even if those are
supported by GeoJSON.

WKT output has always x (or longitude) printed before y (or latitude) coordinate
regardless of a coordinate reference system used.

A sample to parse a `Point` geometry from WKT (with z and m coordinates too) and
then format it back to WKT encoded text:

```dart
void _wkt() {
  // parse a Point geometry from WKT text
  final point = Point.parse(
    'POINT ZM(10.123 20.25 -30.95 -1.999)',
    format: WKT.geometry,
  );

  // format it (back) as WKT text that is printed:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(point.toText(format: WKT.geometry));
```

If geometry type is not known when parsing text from external datasources, you
can use `GeometryBuilder` to parse geometries of any type:

```dart
  const geometriesWkt = [
    'POINT Z(10.123 20.25 -30.95)',
    'LINESTRING(-1.1 -1.1, 2.1 -2.5, 3.5 -3.49)',
  ];
  for(final geomWkt in geometriesWkt) {
    // parse geometry (Point and LineString inherits from Geometry)
    final Geometry geom = GeometryBuilder.parse(geomWkt, format: WKT.geometry);

    if(geom is Point) {
      // do something with point geometry
    } else if(geom is LineString) {
      // do something with line string geometry
    }
  }
```

It's possible to encode geometry data as WKT text also without creating geometry 
objects first. However this requires accessing an encoder instance from the WKT
format, and then writing content to that encoder. See sample below:

```dart
  // geometry text format encoder for WKT
  const format = WKT.geometry;
  final encoder = format.encoder();

  // prints:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  encoder.writer.point(
    [10.123, 20.25, -30.95, -1.999].xyzm,
  );
  print(encoder.toText());
```

Such format encoders (and formatting without geometry objects) are suppported
also for GeoJSON. However for both WKT and GeoJSON encoding might be easier
using concrete geometry model objects.

### EWKT

A PostGIS-specific variation of WKT is called Extended WKT (EWKT). See the
[specification](https://github.com/postgis/postgis/blob/2.1.0/doc/ZMSgeoms.txt).

Decoding EWKT text strings is supported:

```dart
  const wktPoints = [
    /// A 2D point represented as WKT text.
    'POINT(-0.0014 51.4778)',

    /// A 3D point represented as WKT text.
    'POINT Z(-0.0014 51.4778 45)',

    /// A 3D point with SRID represented as EWKT text.
    'SRID=4326;POINT(-0.0014 51.4778 45)',

    /// A measured point represented as EWKT text.
    'POINTM(-0.0014 51.4778 100.0)',
  ];

  // decode SRID, s coordType and a point geometry (with a position) from input
  for (final p in wktPoints) {
    final srid = WKT.decodeSRID(p);
    final coordType = WKT.decodeCoordType(p);
    final pos = Point.parse(p, format: WKT.geometry).position;
    print('$srid $coordType ${pos.x} ${pos.y} ${pos.optZ} ${pos.optM}');
  }

  // the previous sample prints:
  //   null Coords.xy -0.0014 51.4778 null null
  //   null Coords.xyz -0.0014 51.4778 45.0 null
  //   4326 Coords.xyz -0.0014 51.4778 45.0 null
  //   null Coords.xym -0.0014 51.4778 null 100.0
```

### WKB

The `WKB` class provides encoders and decoders for
[Well-known binary](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary)
binary format supporting simple geometry objects.

WKB input and output have always x (or longitude) encoded before y (or latitude)
coordinate regardless of a coordinate reference system used.

Two different approaches to use WKB encoders and decoders are presented in this
section.

First a *not-so-simple* sample below processes data for demo purposes in
following steps: 
1. write geometry content as a source
2. encode content as WKB bytes
3. decode those WKB bytes
4. WKT encoder receives input from WKB decoder, and prints WKT text

```dart
  // geometry binary format encoder for WKB
  const format = WKB.geometry;
  final encoder = format.encoder();

  // write geometries (here only point) to content writer of the encoder
  encoder.writer.point(
    [10.123, 20.25, -30.95, -1.999].xyzm,
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

  // now decode those WKB bytes (Uint8List) created already at the start
  decoder.decodeBytes(wkbBytes);

  // finally print WKT text:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(wktEncoder.toText());
```

The solution above can be simplified a lot by using geometry model objects:

```dart
  // create a Point object
  final point = Point.build([10.123, 20.25, -30.95, -1.999]);

  // get encoded bytes (Uint8List)
  final wkbBytes = point.toBytes(format: WKB.geometry);

  // at this point our WKB bytes could be sent to another system...

  // then create a Point object, but now decoding it from WKB bytes
  final pointDecoded = Point.decode(wkbBytes, format: WKB.geometry);

  // finally print WKT text:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(pointDecoded.toText(format: WKT.geometry));
```

This second solution uses same formats, encoders, decoders and builders as the
first one, but the details of using them is hidden under an easier interface.

As a small bonus let's continue the last sample a bit:

```dart
  // or as a bonus of this solution it's as easy to print it as GeoJSON text too
  //    {"type":"Point","coordinates":[10.123,20.25,-30.95,-1.999]}
  print(pointDecoded.toText(format: GeoJSON.geometry));

  // great, but, we just forgot that GeoJSON should not contain m coordinates...
  //    {"type":"Point","coordinates":[10.123,20.25,-30.95]}
  print(
    pointDecoded.toText(
      format: GeoJSON.geometryFormat(conf: GeoJsonConf(ignoreMeasured: true)),
    ),
  );
```

### Extended WKB (EWKB)

The `WKB` class supports also a variant of WKB called Extended WKB (EWKB) that
is a PostGIS-specific format. Geometry types for 3D (with z coordinates) and
measured (with m) coordinates are encoded differently to the standard WKB. It's
also possible to encode an optional SRID (or coordinate reference system id) to
EWKB data that's not possible with the standard WKB.

More information about EWKB can be read from
[PostGIS](https://postgis.net/docs/ST_AsEWKB.html) or
[GEOS](https://libgeos.org/specifications/wkb/) software documentation.

The following sample shows how to encode and decode WKB and EWKB binary data:

```dart
  // to get a sample point, first parse a 3D point from WKT encoded string
  final p = Point.parse('POINT Z(-0.0014 51.4778 45)', format: WKT.geometry);

  // to encode a geometry as WKB/EWKB use toBytes() or toBytesHex() methods

  // encode as standard WKB data (format: `WKB.geometry`), prints:
  // 01e9030000c7bab88d06f056bfb003e78c28bd49400000000000804640
  final wkbHex = p.toBytesHex(format: WKB.geometry);
  print(wkbHex);

  // encode as Extended WKB data (format: `WKB.geometryExtended`), prints:
  // 0101000080c7bab88d06f056bfb003e78c28bd49400000000000804640
  final ewkbHex = p.toBytesHex(format: WKB.geometryExtended);
  print(ewkbHex);

  // otherwise encoded data equals, but bytes for the geometry type varies

  // there are some helper methods to analyse WKB/EWKB bytes or hex strings
  // (decodeFlavor, decodeEndian, decodeSRID and versions with hex postfix)

  // prints: "WkbFlavor.standard - WkbFlavor.extended"
  print('${WKB.decodeFlavorHex(wkbHex)} - ${WKB.decodeFlavorHex(ewkbHex)}');

  // when decoding WKB or EWKB data, a variant is detected automatically, so
  // both `WKB.geometry` and `WKB.geometryExtended` can be used
  final pointFromWkb = Point.decodeHex(wkbHex, format: WKB.geometry);
  final pointFromEwkb = Point.decodeHex(ewkbHex, format: WKB.geometry);
  print(pointFromWkb.equals3D(pointFromEwkb)); // prints "true"

  // SRID can be encoded only on EWKB data, this sample prints:
  // 01010000a0e6100000c7bab88d06f056bfb003e78c28bd49400000000000804640
  final ewkbHexWithSRID =
      p.toBytesHex(format: WKB.geometryExtended, crs: CoordRefSys.EPSG_4326);
  print(ewkbHexWithSRID);

  // if you have WKB or EWKB data, but not sure which, then you can fist check
  // a flavor and whether it contains SRID, prints: "SRID from EWKB data: 4326"
  if (WKB.decodeFlavorHex(ewkbHexWithSRID) == WkbFlavor.extended) {
    final srid = WKB.decodeSRIDHex(ewkbHexWithSRID);
    if (srid != null) {
      print('SRID from EWKB data: $srid');

      // after finding out CRS, an actual point can be decoded
      // Point.decodeHex(ewkbHexWithSRID, format: WKB.geometry);
    }
  }
```

## Meta

### Metadata classes

The class diagram of temporal data and geospatial extent classes:

<img src="https://raw.githubusercontent.com/navibyte/geospatial/64852f5/dart/geobase/assets/diagrams/meta_temporal_extent.svg" width="100%" title="Temporal data and geospatial extent classes" />

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
    crs: CoordRefSys.CRS84,
    bbox: GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0),
    interval: Interval.parse('../2020-10-31'),
  );

  // An extent with multiple spatial bounds and temporal interval segments.
  GeoExtent.multi(
    crs: CoordRefSys.CRS84,
    boxes: [
      GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0),
      GeoBox(west: 40.0, south: 50.0, east: 60.0, north: 60.0),
    ],
    intervals: [
      Interval.parse('2020-10-01/2020-10-05'),
      Interval.parse('2020-10-27/2020-10-31'),
    ],
  );
```

See the section about
[coordinate reference systems](#coordinate-reference-systems) for the
description of `CoordRefSys`.

## Projections

### WGS 84 to Web Mercator

Built-in coordinate projections (currently only between WGS84 and Web Mercator). 

Here projected coordinates are metric coordinates with both x and y values 
having the valid value range of (-20037508.34, 20037508.34).

```dart
  // Sample point as geographic coordinates.
  const geographic = Geographic(lon: -0.0014, lat: 51.4778);

  // Geographic (WGS 84 longitude-latitude) to Projected (WGS 84 Web Mercator).
  final forward = WGS84.webMercator.forward;
  final projected = geographic.project(forward);

  // Projected (WGS 84 Web Mercator) to Geographic (WGS 84 longitude-latitude).
  final inverse = WGS84.webMercator.inverse;
  final unprojected = projected.project(inverse);

  print('$unprojected <=> $projected');
```

### With proj4dart

Coordinate projections based on the external
[proj4dart](https://pub.dev/packages/proj4dart) package requires imports like:

```dart
// import the default geobase library
import 'package:geobase/geobase.dart';

// need also an additional import with dependency to `proj4dart` 
import 'package:geobase/projections_proj4d.dart';
```

Then a sample to use coordinate projections:

```dart
  // The projection adapter between WGS84 (CRS84) and EPSG:23700 (definition)
  // (based on the sample at https://pub.dev/packages/proj4dart).
  final adapter = Proj4d.init(
    CoordRefSys.CRS84,
    CoordRefSys.normalized('EPSG:23700'),
    targetDef: '+proj=somerc +lat_0=47.14439372222222 +lon_0=19.04857177777778 '
        '+k_0=0.99993 +x_0=650000 +y_0=200000 +ellps=GRS67 '
        '+towgs84=52.17,-71.82,-14.9,0,0,0,0 +units=m +no_defs',
  );

  // The forward projection from WGS84 (CRS84) to EPSG:23700.
  final forward = adapter.forward;

  // A source geographic position.
  const geographic = Geographic(lat: 46.8922, lon: 17.8880);

  // Apply the forward projection returning a projected position in EPSG:23700.
  final projected = geographic.project(forward);

  // Prints: "561647.27300,172651.56518"
  print(projected.toText(decimals: 5));
```

Please see the documentation of [proj4dart](https://pub.dev/packages/proj4dart)
package about it's capabilities, and accuracy of forward and inverse
projections.

## Tiling schemes

### Web Mercator Quad

<a title="TheCrazyWhovian, CC BY-SA 4.0 &lt;https://creativecommons.org/licenses/by-sa/4.0/deed.en&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:WebMercator.png"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/projections/webmercator/267px-WebMercator.png" align="right"></a>

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

  // aligned points (world, pixel and position coordinates) inside tile or edges
  print(quad.tileToWorld(tile, align: Aligned.northWest));
  print(quad.tileToPixel(tile, align: Aligned.center));
  print(quad.tileToPosition(tile, align: Aligned.center));
  print(quad.tileToPosition(tile, align: Aligned.southEast));

  // get zoomed tile at the center of a source tile
  final centerOfTile2 = quad.tileToWorld(tile, align: Aligned.center);
  final tile7 = quad.worldToTile(centerOfTile2, zoom: 7);
  print('tile at zoom 2: $tile => center of tile: $centerOfTile2 '
      '=> tile at zoom 7: $tile7');

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

  // inverse: zoom from ground resolution and scale denominator
  print(quad.zoomFromPixelGroundResolution(152.87)); // ~ 10.0 (double value)
  print(quad.zoomFromScaleDenominator(545978.77)); // ~ 10.0 (double value)

  // ground resolutions and scale denominator for zoom level 10 at lat 51.4778
  print(quad.pixelGroundResolutionAt(latitude: 51.4778, zoom: 10)); // ~ 95.21
  print(quad.scaleDenominatorAt(latitude: 51.4778, zoom: 10)); // ~ 340045.31

  // inverse: zoom from ground resolution and scale denominator at lat 51.4778
  print(
    quad.zoomFromPixelGroundResolutionAt(
      latitude: 51.4778,
      resolution: 95.21,
    ),
  ); // ~ 10.0 (double value)
  print(
    quad.zoomFromScaleDenominatorAt(
      latitude: 51.4778,
      denominator: 340045.31,
    ),
  ); // ~ 10.0 (double value)
```

### Global Geodetic Quad

<a title="Daniel R. Strebe, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Equirectangular_projection_SW.jpg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/projections/platecarree/320px-Equirectangular_projection_SW.jpg" align="right"></a>

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

  // inverse: zoom from scale denominator at the Equator
  print(quad.zoomFromScaleDenominator(272989.39)); // ~ 10.0 (double value)
```

## Appendices

### Coordinate arrays

Position and bounding box classes introduced in the [Coordinates](#coordinates)
section are used when handling positions or bounding boxes (bounds)
individually.

However to handle coordinate data in geometry objects and geospatial data
formats also, efficient array data structures for coordinate values (as 
`double` numeric values) are needed. These structures are mostly used when
building or writing coordinate data of geometry objects described in the
[Geometries](#geometries) section.

Following factory methods allow creating `PositionSeries`, `Position` and `Box`
instances from coordinate arrays of double values.

Factory method        | Description
--------------------  | -------------------------------------------------------------
`PositionSeries.view` | Coordinate values of 0 to N positions as a flat structure.
`Position.view`       | Coordinate values of a single position.
`Box.view`            | Coordinate values of a single bounding box.

For example series of positions can be created as:

```dart
  // A position series with three positions each with x and y coordinates.
  PositionSeries.view(
    [
      10.0, 11.0, // (x, y) for position 0
      20.0, 21.0, // (x, y) for position 1
      30.0, 31.0, // (x, y) for position 2
    ],
    type: Coords.xy,
  );

  // A shortcut to create a position series with three positions (with x and y).
  [
    10.0, 11.0, // (x, y) for position 0
    20.0, 21.0, // (x, y) for position 1
    30.0, 31.0, // (x, y) for position 2
  ].positions(Coords.xy);

  // A position series with three positions each with x, y and z coordinates.
  PositionSeries.view(
    [
      10.0, 11.0, 12.0, // (x, y, z) for position 0
      20.0, 21.0, 22.0, // (x, y, z) for position 1
      30.0, 31.0, 32.0, // (x, y, z) for position 2
    ],
    type: Coords.xyz,
  );
```

The coordinate type (using a `Coords` enum value) must be defined when creating
series of positions. Expected coordinate values (exactly in this order) for each
type are described below:

Type          | Projected values | Geographic values
------------- | ---------------- | -----------------
`Coords.xy`   | x, y             | lon, lat
`Coords.xyz`  | x, y, z          | lon, lat, elev
`Coords.xym`  | x, y, m          | lon, lat, m
`Coords.xyzm` | x, y, z, m       | lon, lat, elev, m

See also specialized extension methods or getters on `List<double>`:

Method/getter | Created object   | Description
------------- | ---------------- | -----------
`positions()` | `PositionSeries` | An array of 0 to N positions from a flat structure of coordinate values. 
`position`    | `Position`       | A single position.
`box`         | `Box`            | A single bounding box.

For single positions there are also some more extension getters on
`List<double>` to create instances of `Position`:

Getter  | 2D/3D | Coords | Values   | x | y | z | m
------  | ----- | ------ | -------- | - | - | - | -
`.xy`   | 2D    | 2      | `double` | + | + |   |
`.xyz`  | 3D    | 3      | `double` | + | + | + |
`.xym`  | 2D    | 3      | `double` | + | + |   | +
`.xyzm` | 3D    | 4      | `double` | + | + | + | +

For geographic coordinates same getters on `List<double>` are used:

Getter  | 2D/3D | Coords | Values   | lon (x) | lat (y) | elev (z) | m
------- | ----- | ------ | -------- | ------- | ------- | -------- | -
`.xy`   | 2D    | 2      | `double` |    +    |    +    |          |
`.xyz`  | 3D    | 3      | `double` |    +    |    +    |    +     |
`.xym`  | 2D    | 3      | `double` |    +    |    +    |          | +
`.xyzm` | 3D    | 4      | `double` |    +    |    +    |    +     | +

### Content interfaces

Content interfaces allows writing geometry, property and feature data to format
encoders and object builders. They are used in this package for encoding
geometries and features to GeoJSON (text), WKT (text) and WKB (binary)
representations, and decoding geometry and feature objects from GeoJSON and WKB
representations.

Content interface       | Description
----------------------- | ----------- 
`CoordinateContent`     | Write coordinate data to format encoders and object builders.
`SimpleGeometryContent` | Write simple geometry data to format encoders and object builders.
`GeometryContent`       | Write geometry (both simple and collection geometries) data to format encoders and object builders.
`FeatureContent`        | Write geospatial feature objects to format encoders and object builders.

## Reference

### Packages

The **geobase** library contains also following partial packages, that can be
used to import only a certain subset instead of the whole **geobase** package:

Package                | Description 
---------------------- | ----------- 
**common**             | Common codes, constants, functions, presentation helpers and reference systems related to geospatial applications.
**coordinates**        | Position, bounding box and positions series (with coordinate arrays).
**geodesy**            | Spherical geodesy functions for *great circle* and *rhumb line* paths.
**meta**               | Temporal data structures (instant, interval) and spatial extents.
**projections**        | Geospatial projections (currently only between WGS84 and Web Mercator).
**projections_proj4d** | Projections provided by the external [proj4dart](https://pub.dev/packages/proj4dart) package.
**tiling**             | Tiling schemes and tile matrix sets (web mercator, global geodetic).
**vector**             | Text and binary formats for vector data (features, geometries, coordinates).
**vector_data**        | Data structures for geometries, features and feature collections.

External packages `geobase` is depending on:
* [equatable](https://pub.dev/packages/equatable) for equality and hash utils
* [meta](https://pub.dev/packages/meta) for annotations
* [proj4dart](https://pub.dev/packages/proj4dart) for coordinate projections

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).

## Derivative work

This project contains portions of derivative work. 

See details about [DERIVATIVE](DERIVATIVE.md) work.
