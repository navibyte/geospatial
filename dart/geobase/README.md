[![pub package](https://img.shields.io/pub/v/geobase.svg)](https://pub.dev/packages/geobase) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

Geospatial data structures (coordinates, geometries, features, metadata), 
ellipsoidal and spherical geodesy, projections and tiling schemes. Vector data
format support for [GeoJSON](https://geojson.org/),
[WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
and [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary).

 <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPoint.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_MultiPoint.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_LineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_LineString.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_Polygon.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_Polygon_with_hole.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_GeometryCollection.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_GeometryCollection.svg"></a>

## Features

✨ New (2024-07-26): The stable version 1.3.0 with centroid, polylabel, point-in-polygon and other cartesian 2D calculations enhanced - [read more](https://geospatial.navibyte.dev/v1/geobase/geometry-calculations/)!

✨ New (2024-05-26): The new documentation website ([geospatial.navibyte.dev](https://geospatial.navibyte.dev/)) for the [geobase](https://geospatial.navibyte.dev/v1/geobase/)
package documentation published along with the stable version 1.2.0.

✨ New (2024-04-22): Support for Newline-delimited GeoJSON, EWKT and EWKB added. Check out [the blog post](https://medium.com/@navibyte/decode-and-encode-geojson-wkt-and-wkb-in-dart-and-flutter-apps-ab2ef4ece2f1).

<a title="Ktrinko, CC0, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Eckert4.jpg"><img alt="World map with Natural Earth data, Excert projection" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/projections/eckert4/320px-Eckert4.jpg" align="right"></a>

Key features:
* 🌐 geographic (longitude-latitude) and projected positions and bounding boxes
* 🧩 simple geometries (point, line string, polygon, multi point, multi line string, multi polygon, geometry collection)
* 📏 cartesian 2D calculations (centroid, polylabel, point-in-polygon, distance).
* 🔷 features (with id, properties and geometry) and feature collections
* 📐 ellipsoidal (*vincenty*) and spherical (*great circle*, *rhumb line*) geodesy tools
* 📅 temporal data structures (instant, interval) and spatial extents
* 📃 vector data formats supported ([GeoJSON](https://geojson.org/), [Newline-delimited GeoJSON](https://stevage.github.io/ndgeojson/), [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry), [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary)
)
* 🗺️ coordinate projections (web mercator + based on the external [proj4dart](https://pub.dev/packages/proj4dart) library)
* 🔢 tiling schemes and tile matrix sets (web mercator, global geodetic)

## Documentation

Comprehensive guidance on how to use this package and about
*Geospatial tools for Dart* (the package is part of) is available on the
[geospatial.navibyte.dev](https://geospatial.navibyte.dev/) website.

Shortcuts to the [geobase](https://geospatial.navibyte.dev/v1/geobase/)
package documentation by chapters:

* [📍 Coordinates](https://geospatial.navibyte.dev/v1/geobase/coordinates/)
* [🧩 Simple geometries](https://geospatial.navibyte.dev/v1/geobase/geometry/)
* [📏 Geometry calculations](https://geospatial.navibyte.dev/v1/geobase/geometry-calculations/)
* [🔷 Geospatial features](https://geospatial.navibyte.dev/v1/geobase/features/)
* [📃 Vector formats](https://geospatial.navibyte.dev/v1/geobase/formats/)
* [🔵 Ellipsoidal geodesy](https://geospatial.navibyte.dev/v1/geobase/ellipsoidal-geodesy/)
* [📐 Spherical geodesy](https://geospatial.navibyte.dev/v1/geobase/spherical-geodesy/)
* [📅 Metadata](https://geospatial.navibyte.dev/v1/geobase/metadata/)
* [🗺️ Projections](https://geospatial.navibyte.dev/v1/geobase/projections/)
* [🔢 Tiling schemes](https://geospatial.navibyte.dev/v1/geobase/tiling-schemes/)

See also overview topics about *Geospatial tools for Dart*:

* [⛳️ Getting started](https://geospatial.navibyte.dev/v1/start/)
* [📖 Introduction](https://geospatial.navibyte.dev/v1/start/intro/)
* [💼 Code project](https://geospatial.navibyte.dev/reference/project/)
* [📚 API documentation](https://geospatial.navibyte.dev/reference/api/)

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

*Ellipsoidal* and *spherical* geodesy functions to calculate distances etc.:

```dart
  final greenwich = Geographic.parseDms(lat: '51°28′40″ N', lon: '0°00′05″ W');
  final sydney = Geographic.parseDms(lat: '33.8688° S', lon: '151.2093° E');

  // How to calculate distances using ellipsoidal Vincenty, spherical
  // great-circle and spherical rhumb line methods is shown first.

  // The distance along a geodesic on the ellipsoid surface (16983.3 km).
  greenwich.vincenty().distanceTo(sydney);

  // By default the WGS84 reference ellipsoid is used but this can be changed.
  greenwich.vincenty(ellipsoid: Ellipsoid.GRS80).distanceTo(sydney);

  // The distance along a spherical great-circle path (16987.9 km).
  greenwich.spherical.distanceTo(sydney);

  // The distance along a spherical rhumb line path (17669.8 km).
  greenwich.rhumb.distanceTo(sydney);

  // Also bearings, destination points and mid points (or intermediate points)
  // are provided for all methods, but below shown only for great-circle paths.

  // Destination point (10 km to bearing 61°): 51° 31.3′ N, 0° 07.5′ E
  greenwich.spherical.initialBearingTo(sydney);
  greenwich.spherical.finalBearingTo(sydney);

  // Destination point: 51° 31.3′ N, 0° 07.5′ E
  greenwich.spherical.destinationPoint(distance: 10000, bearing: 61.0);

  // Midpoint: 28° 34.0′ N, 104° 41.6′ E
  greenwich.spherical.midPointTo(sydney);

  // Vincenty ellipsoidal geodesy functions provide also `inverse` and `direct`
  // methods to calculate shortest arcs along a geodesic on the ellipsoid. The
  // returned arc object contains origin and destination points, initial and
  // final bearings, and distance between points.
  greenwich.vincenty().inverse(sydney);
  greenwich.vincenty().direct(distance: 10000, bearing: 61.0);
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
the documentation chapter about
[geospatial features](https://geospatial.navibyte.dev/v1/geobase/features/)
for more information.

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
here. Please see chapters about
[projections](https://geospatial.navibyte.dev/v1/geobase/projections/),
[tiling schemes](https://geospatial.navibyte.dev/v1/geobase/tiling-schemes/) and
[coordinate arrays](https://geospatial.navibyte.dev/v1/geobase/topics/#-coordinate-arrays)
on the [documentation website](https://geospatial.navibyte.dev/) to learn about
them.

## Usage

The package requires at least [Dart](https://dart.dev/) SDK 2.17, and it
supports all [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/)
platforms.

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  geobase: ^1.4.0-dev.1
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

## Reference

### Documentation

Please see the [geospatial.navibyte.dev](https://geospatial.navibyte.dev/)
website for the [geobase](https://geospatial.navibyte.dev/v1/geobase/)
package documentation.

### Packages

The **geobase** library contains also following partial packages, that can be
used to import only a certain subset instead of the whole **geobase** package:

Package                | Description 
---------------------- | ----------- 
**common**             | Common codes, constants, functions, presentation helpers and reference systems related to geospatial applications.
**coordinates**        | Position, bounding box and positions series (with coordinate arrays).
**geodesy**            | Ellipsoidal (*vincenty*) and spherical (*great circle*, *rhumb line*) geodesy tools.
**geometric**          | Cartesian 2D calculations (centroid, polylabel, point-in-polygon, distance).
**meta**               | Temporal data structures (instant, interval) and spatial extents.
**projections**        | Geospatial projections (currently only between WGS84 and Web Mercator).
**projections_proj4d** | Projections provided by the external [proj4dart](https://pub.dev/packages/proj4dart) package.
**tiling**             | Tiling schemes and tile matrix sets (web mercator, global geodetic).
**vector**             | Text and binary formats for vector data (features, geometries, coordinates).
**vector_data**        | Data structures for geometries, features and feature collections.

External packages `geobase` is depending on:
* [collection](https://pub.dev/packages/collection) for priority queues and collection utilities
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

See details about
[DERIVATIVE](https://github.com/navibyte/geospatial/blob/main/dart/geobase/)
work.

Source repositories used when porting functionality to Dart and this project:
* [geodesy](https://github.com/chrisveness/geodesy) by Chris Veness 2002-2024
* [polylabel](https://github.com/mapbox/polylabel) by Mapbox 2016-2024
* [tinyqueue](https://github.com/mourner/tinyqueue) by Vladimir Agafonkin 2017-2024
