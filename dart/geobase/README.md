[![pub package](https://img.shields.io/pub/v/geobase.svg)](https://pub.dev/packages/geobase) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

Geospatial data structures (coordinates, geometries, features, metadata),
projections and tiling schemes. Vector data format support for
[GeoJSON](https://geojson.org/),
[WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
and [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary).

 <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPoint.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_MultiPoint.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_LineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_LineString.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Polygon.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Polygon_with_hole.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_GeometryCollection.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_GeometryCollection.svg"></a>

## Features

✨ New: Data structures for simple geometries, features and feature collections.
✨ New: Support for [Well-known binary](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary) (WKB). Text and
binary data formats, encodings and content interfaces also redesigned.

<a title="Ktrinko, CC0, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Eckert4.jpg"><img alt="World map with Natural Earth data, Excert projection" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/projections/eckert4/320px-Eckert4.jpg" align="right"></a>

Key features:
* 🌐 geographic (longitude-latitude) and projected positions and bounding boxes
* 🧩 simple geometries (point, line string, polygon, multi point, multi line string, multi polygon, geometry collection)
* 🔷 features (with id, properties and geometry) and feature collections
* 📅 temporal data structures (instant, interval) and spatial extents
* 📃 vector data formats supported ([GeoJSON](https://geojson.org/), [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry), [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary)
)
* 🗺️ coordinate projections (web mercator + based on the external [proj4dart](https://pub.dev/packages/proj4dart) library)
* 🔢 tiling schemes and tile matrix sets (web mercator, global geodetic)

## Usage

The package requires at least [Dart](https://dart.dev/) SDK 2.17, and it
supports all [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/)
platforms.

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  geobase: ^0.3.0
```

Import it:

```dart
import `package:geobase/geobase.dart`
```

There are also partial packages containing only a certain subset. See the
[Packages](#Packages) section below.

See also the [geodata](https://pub.dev/packages/geodata) package that extends
capabilities of `geobase` by providing geospatial API clients to read 
[GeoJSON](https://geojson.org/) data sources and 
[OGC API Features](https://ogcapi.ogc.org/features/) web services.

## Coordinates

### Geographic coordinates

*Geographic* coordinates are based on a spherical or ellipsoidal coordinate
system representing positions on the Earth as longitude (`lon`) and latitude
(`lat`).

Elevation (`elev`) in meters and measure (`m`) coordinates are optional.

<a title="Djexplo, CC0, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Latitude_and_Longitude_of_the_Earth.svg"><img alt="Latitude and Longitude of the Earth" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/coordinates/geographic/Latitude_and_Longitude_of_the_Earth.svg"></a>

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

### Projected coordinates

<a title="Sommacal alfonso, CC BY-SA 4.0 &lt;https://creativecommons.org/licenses/by-sa/4.0/deed.en&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Cartesian_coordinates.png"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/coordinates/cartesian/Cartesian_coordinates.png" align="right"></a>

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

*Scalable* coordinates are *projected* coordinates associated with
a *level of detail* (LOD) or a `zoom` level. They are used for example by
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

### Summary 

The summary of *projected*, *geographic* and *scalable* coordinate values in the
basic *position* classes:

Class         | Required coordinates      | Optional coordinates
------------- | ------------------------- | ------------------------------------
`Projected`   | x, y                      | z, m
`Geographic`  | lon, lat                  | elev, m
`Scalable2i`  | zoom, x, y                |

The summary of basic *bounding box* classes:

Class         | Required coordinates      | Optional coordinates
------------- | ------------------------- | ------------------------------------
`ProjBox`     | minX, minY, maxX, maxY    | minZ, minM, maxZ, maxM
`GeoBox`      | west, south, east, north  | minElev, minM, maxElev, maxM

In some interfaces, for example for positions, coordinate values are referenced
only by x, y, z and m property names. So in such a case and in the context of
this package, for geographic coordinates x represents *longitude*, y represents
*latitude*, and z represents *elevation* (or height or altitude).

The `Position` interface is a super type for `Projected` and `Geographic`, and
the `Box` interface is a super type for `ProjBox` and `GeoBox`. Please see more
information about them in the API reference.

## Coordinate arrays

Position and bounding box classes introduced in the previous section are used
when handling positions or bounding boxes (bounds) individually.

However to handle coordinate data in geometry objects and geospatial data
formats also, efficient array data structures for coordinate values (as 
`double` numeric values) are needed:

Class            | Description
---------------- | -------------------------------------------------------------
`PositionArray`  | Coordinate values of 0 to N positions as a flat structure.
`PositionCoords` | Coordinate values of a single position.
`BoxCoords`      | Coordinate values of a single bounding box.

All these classes implement `Iterable<double>` allowing instances of them to be
used in places requiring the `Iterable<double>` type. At the same time, for
example `PositionCoords` is also a valid `Position` and `BoxCoords` is a valid
`Box`.

There are also specialized sub classes of `PositionCoords` for projected 
coordinates (enabling more compact code when creating instances):

Class  | 2D/3D | Coords | Values   | x | y | z | m
------ | ----- | ------ | -------- | - | - | - | -
`XY`   | 2D    | 2      | `double` | + | + |   |
`XYZ`  | 3D    | 3      | `double` | + | + | + |
`XYM`  | 2D    | 3      | `double` | + | + |   | +
`XYZM` | 3D    | 4      | `double` | + | + | + | +

And similar classes for geographic coordinates:

Class         | 2D/3D | Coords | Values   | lon (x) | lat (y) | elev (z) | m
------------- | ----- | ------ | -------- | ------- | ------- | -------- | -
`LonLat`      | 2D    | 2      | `double` |    +    |    +    |          |
`LonLatElev`  | 3D    | 3      | `double` |    +    |    +    |    +     |
`LonLatM`     | 2D    | 3      | `double` |    +    |    +    |          | +
`LonLatElevM` | 3D    | 4      | `double` |    +    |    +    |    +     | +

As described above, `PositionArray` represents coordinate values of 0 to N
positions as a flat structure. That is, there is no array of positions with 
each having an array of coordinate values, but a single flat array of coordinate
values (double). This is best illustrated by code samples below:

```dart
  // A position array with three positions each with x and y coordinates.
  PositionArray.view(
    [
      10.0, 11.0, // (x, y) for position 0
      20.0, 21.0, // (x, y) for position 1
      30.0, 31.0, // (x, y) for position 2
    ],
    type: Coords.xy,
  );

  // A position array with three positions each with x, y and z coordinates.
  PositionArray.view(
    [
      10.0, 11.0, 12.0, // (x, y, z) for position 0
      20.0, 21.0, 22.0, // (x, y, z) for position 1
      30.0, 31.0, 32.0, // (x, y, z) for position 2
    ],
    type: Coords.xyz,
  );
```

The coordinate type (using a `Coords` enum value) must be defined when creating
position arrays. Expected coordinate values (exactly in this order) for each
type are described below:

Type          | Projected values | Geographic values
------------- | ---------------- | -----------------
`Coords.xy`   | x, y             | lon, lat
`Coords.xyz`  | x, y, z          | lon, lat, elev
`Coords.xym`  | x, y, m          | lon, lat, m
`Coords.xyzm` | x, y, z, m       | lon, lat, elev, m

## Geometries

### Geometry types

Geometry primitive types supported by this package (with samples adapted from
the samples of the Wikipedia page about
[WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry),
and compatible also with [GeoJSON](https://geojson.org/)):

Geometry    | Shape       | Dart code to build objects
----------- | ----------- | --------------------------
Point       | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Point.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Point.svg"></a> | `Point(XY(30.0, 10.0))`<br>`Point.build([30.0, 10.0])`
LineString  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_LineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_LineString.svg"></a> | `LineString.build([30, 10, 10, 30, 40, 40], type: Coords.xy)`
Polygon     | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Polygon.svg"></a> | `Polygon.build([[30, 10, 40, 40, 20, 40, 10, 20, 30, 10]], type: Coords.xy)`
Polygon (with a hole) | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Polygon_with_hole.svg"></a> | `Polygon.build([[35, 10, 45, 45, 15, 40, 10, 20, 35, 10], [20, 30, 35, 35, 30, 20, 20, 30]], type: Coords.xy)`

Also multipart geometry classes are supported:

Geometry    | Shape       | Dart code to build objects
----------- | ----------- | --------------------------
MultiPoint  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPoint.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_MultiPoint.svg"></a> | `MultiPoint.build([[10, 40], [40, 30], [20, 20], [30, 10]], type: Coords.xy)`
MultiLineString  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiLineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_MultiLineString.svg"></a> | `MultiLineString.build([[10, 10, 20, 20, 10, 40], [40, 40, 30, 30, 40, 20, 30, 10]], type: Coords.xy)`
MultiPolygon | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPolygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_MultiPolygon.svg"></a> | `MultiPolygon.build([[[30, 20, 45, 40, 10, 40, 30, 20]], [[15, 5, 40, 10, 10, 20, 5, 10, 15, 5]]], type: Coords.xy)`
MultiPolygon (with a hole) | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPolygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_MultiPolygon_with_hole.svg"></a> | `MultiPolygon.build([[[40, 40, 20, 45, 45, 30, 40, 40]], [[20, 35, 10, 30, 10, 10, 30, 5, 45, 20, 20, 35], [30, 20, 20, 15, 20, 25, 30, 20]]], type: Coords.xy)`
GeometryCollection | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_GeometryCollection.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_GeometryCollection.svg"></a> | `GeometryCollection([Point(XY(40, 10)), LineString.build([10, 10, 20, 20, 10, 40], type: Coords.xy), Polygon.build([[40, 40, 20, 45, 45, 30, 40, 40]], type: Coords.xy)])`

## Geospatial features

### Feature objects

According to the [OGC Glossary](https://www.ogc.org/ogc/glossary/f) a geospatial
**feature** is *a digital representation of a real world entity. It has a spatial domain, a temporal domain, or a spatial/temporal domain as one of its attributes. Examples of features include almost anything that can be placed in time and space, including desks, buildings, cities, trees, forest stands, ecosystems, delivery vehicles, snow removal routes, oil wells, oil pipelines, oil spill, and so on*.

Below is an illustration of features in a simple vector map. *Wells* are features
with point geometries, *rivers* with line strings (or polyline) geometries, and
finally *lakes* are features with polygon geometries. Features normally contain
also an identifier and other attributes (or properties) along with a geometry.  

<a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Simple_vector_map.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/Simple_vector_map.svg"></a>

Sets of features are contained by **feature collections**.
 
As specified also by the [GeoJSON](https://geojson.org/) format a `Feature`
object contains a geometry object and additional members (like "id" and 
"properties"). A `FeatureCollection` object contains an array of `Feature`
objects. Both may also contain "bbox" or bounding box. Any other members on
`Feature` and  `FeatureCollection` objects are *foreign members*, allowed
property values or geometry objects, but not specified by the GeoJSON model
(and so potentially not known by many GeoJSON parsers).

This package models features and feature collections according to these
definitions.

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
      geometry: Point(LonLatElev(-0.0014, 51.4778, 45.0)),
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
      geometry: Point(LonLat(-0.075406, 51.5055)),
      properties: {
        'title': 'Tower Bridge',
        'city': 'London',
        'built': 1886,
      },
    ),
  ]);
```

## Vector data formats

### GeoJSON

As already described [GeoJSON](https://geojson.org/) is a format for encoding
geometry, feature and feature collection objects. The data structures introduced
on previous [geometries](#geometries) and
[geospatial features](#geospatial-features) sections are modelled to support
encoding and decoding GeoJSON data.

As specified by the [RFC 7946](https://tools.ietf.org/html/rfc7946) standard,
all GeoJSON geometry objects use 
[WGS 84](https://en.wikipedia.org/wiki/World_Geodetic_System) geographic 
coordinates. Also alternative coordinate reference systems can be used when 
*involved parties have a prior arrangement* of using other systems.

This package supports encoding GeoJSON text from geometry and feature objects:

```dart
  // build a LineString sample geometry
  final lineString = LineString.build(
    [-1.1, -1.1, 2.1, -2.5, 3.5, -3.49],
    type: Coords.xy,
    bounds: [-1.1, -3.49, 3.5, -1.1],
  );

  // ... and print it as GeoJSON text
  print(lineString.toText(format: GeoJSON.geometry));

  // GeoJSON representation for other geometries, features and feature
  // collections can be produced with `toText` methdod also.

  // in this sample a Feature is printed in GeoJSON (with 3 decimals on doubles)
  final feature = Feature(
    id: 'TB',
    geometry: Point(LonLat(-0.075406, 51.5055)),
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

### WKT

[Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) (WKT) is 
*a text markup language for representing vector geometry objects*. It's 
specified by the [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa) standard.

Positions and geometries can be encoded to WKT text representations. However
feature and feature collections cannot be written to WKT even if those are
supported by GeoJSON.

A sample to encode a `Point` geometry to WKT (with z and m coordinates too):

```dart
  // create a Point geometry, format it as WKT text that is printed
  final point = Point.build([10.123, 20.25, -30.95, -1.999], type: Coords.xyzm);
  final wkt = point.toText(format: WKT.geometry);
  print(wkt);
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
    [10.123, 20.25, -30.95, -1.999],
    type: Coords.xyzm,
  );
  print(encoder.toText());
```

Such format encoders (and formatting without geometry objects) are suppported
also for GeoJSON. However for both WKT and GeoJSON encoding might be easier
using concrete geometry model objects.

Currently this package does not (yet) support parsing from WKT text.

### WKB

The `WKB` class provides encoders and decoders for
[Well-known binary](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary)
binary format supporting simple geometry objects.

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

  // now decode those WKB bytes (Uint8List) created already at the start
  decoder.decodeBytes(wkbBytes);

  // finally print WKT text:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(wktEncoder.toText());
```

The solution above can be simplied a lot by using geometry model objects:

```dart
  // create a Point object
  final point = Point(XYZM(10.123, 20.25, -30.95, -1.999));

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
    bbox: GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0),
    interval: Interval.parse('../2020-10-31'),
  );

  // An extent with multiple spatial bounds and temporal interval segments.
  GeoExtent.multi(
    crs: 'EPSG:4326',
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

The `crs` property in extents above refer to a 
[Coordinate reference system](https://en.wikipedia.org/wiki/Spatial_reference_system) 
that is *a coordinate-based local, regional or global system used to locate geographical entities*. 

This package does not define any `crs` constants, please refer to registries
like [The EPSG dataset](https://epsg.org/).

## Projections

### WGS 84 to Web Mercator

Built-in coordinate projections (currently only between WGS84 and Web Mercator). 

Here projected coordinates are metric coordinates with both x and y values 
having the valid value range of (-20037508.34, 20037508.34).

```dart
  // Built-in coordinate projections (currently only between WGS 84 and
  // Web Mercator)

  // Geographic (WGS 84 longitude-latitude) to Projected (WGS 84 Web Mercator)
  final forward = WGS84.webMercator.forward;
  final projected = forward.project(
    const Geographic(lon: -0.0014, lat: 51.4778),
    to: Projected.create,
  );

  // Projected (WGS 84 Web Mercator) to Geographic (WGS 84 longitude-latitude)
  final inverse = WGS84.webMercator.inverse;
  final unprojected = inverse.project(
    projected,
    to: Geographic.create,
  );

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
  // A projection adapter from WGS84 (EPSG:4326) to EPSG:23700 (with definition)
  // (based on the sample at https://pub.dev/packages/proj4dart).
  final adapter = Proj4d.resolve(
    'EPSG:4326',
    'EPSG:23700',
    toDef: '+proj=somerc +lat_0=47.14439372222222 +lon_0=19.04857177777778 '
        '+k_0=0.99993 +x_0=650000 +y_0=200000 +ellps=GRS67 '
        '+towgs84=52.17,-71.82,-14.9,0,0,0,0 +units=m +no_defs',
  );

  // Apply a forward projection to EPSG:23700.
  print(
    adapter.forward.project(
      const Geographic(lon: 17.8880, lat: 46.8922),
      to: Projected.create,
    ),
  );
```

Please see the documentation of [proj4dart](https://pub.dev/packages/proj4dart)
package about it's capabilities, and accuracy of forward and inverse
projections.

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

## Reference

### Packages

The **geobase** library contains also following partial packages, that can be
used to import only a certain subset instead of the whole **geobase** package:

Package                | Description 
---------------------- | ----------- 
**codes**              | Enums (codes) for geospatial coordinate, geometry types and canvas origin.
**constants**          | Geodetic and screen related constants.
**coordinates**        | Geographic (longitude-latitude) and projected positions and bounding boxes.
**meta**               | Temporal data structures (instant, interval) and spatial extents.
**projections**        | Geospatial projections (currently only between WGS84 and Web Mercator).
**projections_proj4d** | Projections provided by the external [proj4dart](https://pub.dev/packages/proj4dart) package.
**tiling**             | Tiling schemes and tile matrix sets (web mercator, global geodetic).
**vector**             | Text and binary formats for vector data (features, geometries, coordinates).
**vector_data**        | Data structures for positions, geometries, features and feature collections.

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