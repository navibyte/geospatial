[![pub package](https://img.shields.io/pub/v/geocore.svg)](https://pub.dev/packages/geocore) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

Geospatial data structures (points, geometry, features, meta) and parsers 
([GeoJSON](https://geojson.org/), [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)) for Dart. 

 <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPoint.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_MultiPoint.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_LineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_LineString.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Polygon.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Polygon_with_hole.svg"></a> <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_GeometryCollection.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_GeometryCollection.svg"></a>

## Features

Key features:
* 🚀 geospatial data structures (geometry, features and metadata)
* 🌐 *geographic* coordinates (longitude-latitude)
* 🗺️ *projected* coordinates (cartesian XYZ)
* 🔷 geometry primitives (bounds or bbox, point, line string, polygon)
* 🧩 multi geometries (multi point, multi line string, multi polygon, geometry collections)
* ⭐ feature objects (with id, properties and geometry) and feature collections
* 🌎 [GeoJSON](https://geojson.org/) data parser
* 🪧 [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) 
(Well-known text representation of geometry) data parser 

## Usage

The package requires at least [Dart](https://dart.dev/) SDK 2.17, and it
supports all [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/)
platforms.

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  geocore: ^0.10.0
```

Import it:

```dart
import `package:geocore/geocore.dart`
```

There are also partial packages containing only a certain subset. See the
[Packages](#packages) section below.

## Roadmap

> **Note**: After the `geocore` version 0.10.0 (published at 2022-08-21), no new
> features are currently planned on this package. 

New features shall be actively added and development continues on following
packages:
* [geobase](https://pub.dev/packages/geobase) : Geospatial data structures (coordinates, geometries, features, metadata), projections and tiling schemes. Vector data format support for [GeoJSON](https://geojson.org/), [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) and [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary).
* [geodata](https://pub.dev/packages/geodata) : Geospatial feature service Web APIs with support for [GeoJSON](https://geojson.org/) and [OGC API Features](https://ogcapi.ogc.org/features/) clients.

Also `geocore` package shall be maintained as a part of the
[geospatial](https://github.com/navibyte/geospatial) repository. See also
GitHub [issues](https://github.com/navibyte/geospatial/issues).

## Introduction

Geometry primitives supported by this library package (with samples adapted from
the samples of the Wikipedia page about
[WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)):

Geometry    | Shape       | Samples to create instances
----------- | ----------- | ---------------------------
Point       | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Point.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Point.svg"></a> | `Point2(x: 30.0, y: 10.0)`<br>`Point2.from([30.0, 10.0])`<br>`Point2.parse('30 10')`
LineString  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_LineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_LineString.svg"></a> | `LineString.parse('30 10, 10 30, 40 40', Point2.coordinates)`
Polygon     | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Polygon.svg"></a> | `Polygon.parse('(30 10, 40 40, 20 40, 10 20, 30 10)', Point2.coordinates)`
Polygon (with a hole) | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_Polygon_with_hole.svg"></a> | `Polygon.parse('(35 10, 45 45, 15 40, 10 20, 35 10), (20 30, 35 35, 30 20, 20 30)', Point2.coordinates)`

Also multipart geometry classes are provided:

Geometry    | Shape       | Samples to create instances
----------- | ----------- | ---------------------------
MultiPoint  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPoint.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_MultiPoint.svg"></a> | `MultiPoint.parse('10 40, 40 30, 20 20, 30 10', Point2.coordinates)`
MultiLineString  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiLineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_MultiLineString.svg"></a> | `MultiLineString.parse('(10 10, 20 20, 10 40), (40 40, 30 30, 40 20, 30 10)', Point2.coordinates)`
MultiPolygon | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPolygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_MultiPolygon.svg"></a> | `MultiPolygon.parse('((30 20, 45 40, 10 40, 30 20)), ((15 5, 40 10, 10 20, 5 10, 15 5))', Point2.coordinates)`
MultiPolygon (with a hole) | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPolygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_MultiPolygon_with_hole.svg"></a> | `MultiPolygon.parse('((40 40, 20 45, 45 30, 40 40)), ((20 35, 10 30, 10 10, 30 5, 45 20, 20 35),(30 20, 20 15, 20 25, 30 20))', Point2.coordinates)`
GeometryCollection | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_GeometryCollection.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/SFA_GeometryCollection.svg"></a> | `GeometryCollection([Point2i(x: 40, y: 10), LineString.make([[10, 10], [20, 20], [10, 40]], Point2i.coordinates), Polygon.parse('(40 40, 20 45, 45 30, 40 40)', Point2i.coordinates)])`

Geometry types introduced above are based on the 
[Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
standard by [The Open Geospatial Consortium](https://www.ogc.org/) (OGC).

Spatial bounds:

```dart
  Bounds.of(min: Point2(x: 10.1, y: 10.1), max: Point2(x: 20.2, y: 20.2));
  Bounds.of(min: Point3i(x: 10, y: 10, z: 3), max: Point3i(x: 20, y: 20, z: 5));
  GeoBounds.bboxLonLat(-20.3, 50.2, 20.5, 60.9);
```

A feature (a geospatial entity) contains an id, a geometry and properties:

```dart
  Feature(
    id: 'ROG',
    geometry: GeoPoint3(lon: -0.0014, lat: 51.4778, elev: 45.0),
    properties: {
      'place': 'Greenwich',
      'city': 'London',
    },
  );
```

Parsing [GeoJSON](https://geojson.org/) data:

```dart
  final geoJsonParser = GeoJSON().parserGeographic(GeoPoint3.coordinates);
  geoJsonParser.feature(
    '''
    {
      "type": "Feature",
      "id": "ROG",
      "geometry": {
        "type": "Point",
        "coordinates": [-0.0014, 51.4778, 45.0]  
      },
      "properties": {
        "place": "Greenwich",
        "city": "London"
      }
    }  
  ''',
  );
```

Parsing [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) 
(Well-known text representation of geometry) data:

```dart
  // Parse using specific point factories for coordinates with and without M
  final wktParser = WKT().parser(Point2.coordinates, Point2m.coordinates);
  wktParser.parse('POINT (100.0 200.0)'); // => Point2;
  wktParser.parse('POINT M (100.0 200.0 5.0)'); // => Point2m;

  // Projected (or cartesian) coordinates (Point2, Point2m, Point3 or Point3m)
  WKT().parserProjected().parse('LINESTRING (200.1 500.9, 210.2 510.4)');

  // Geographic coordinates (GeoPoint2, GeoPoint2m, GeoPoint3 or GeoPoint3m)
  WKT().parserGeographic().parse(
        'POLYGON ((40 15, 50 50, 15 45, 10 15, 40 15),'
        ' (25 25, 25 40, 35 30, 25 25))',
      );
```

## User guide

### Cartesian or projected points

The abstract base class for all point geometries is `Point`. It's implemented by 
following concrete classes to represent projected or cartesian (XYZ) 
coordinates with an optional measure (m) coordinate:

Class       | Coordinates | x | y | z | m 
----------- | ----------- | - | - | - | -
`Point2`    | `num`       | + | + |   |  
`Point2m`   | `num`       | + | + |   | + 
`Point3`    | `num`       | + | + | + |  
`Point3m`   | `num`       | + | + | + | + 
`Point2i`   | `int`       | + | + |   |  
`Point3i`   | `int`       | + | + | + |  

Points are created by geometry parsers or point factory implementations. Each
point geometry class has also multiple factory constructors.

For example `Point3` can be created in many ways:

```dart
  // Projected point with X, Y and Z coordinates in two ways.
  Point3(x: 708221.0, y: 5707225.0, z: 45.0);
  Point3.xyz(708221.0, 5707225.0, 45.0);

  // The same point created from `Iterable<num>`.
  Point3.from([708221.0, 5707225.0, 45.0]);

  // The same point parsed from WKT compatible text.
  // Actually WKT representation would be : "POINT (708221.0 5707225.0 45.0)",
  // but this parser takes only coordinate data between paranthesis.
  Point3.parse('708221.0 5707225.0 45.0');

  // The `parse` method throws when text is invalid, but `tryParse` returns null
  // in such case. This can be utilized for fallbacks.
  Point3.tryParse('nop') ?? Point3.parse('708221.0 5707225.0 45.0');

  // The same point parsed using the WKT parser for projected geometries.
  // Here `wktProjected` is a global constant for a WKT factory implementation.
  WKT().parserProjected().parse('POINT Z (708221.0 5707225.0 45.0)');
```

All other point classes have similar constructors.

If you have a point instance of one of the point classes, then there are some 
methods that help to create another instance of the same type.

```dart
  // A sample point with x, y, z and m coordinates.
  final source = Point3m.xyzm(708221.0, 5707225.0, 45.0, 123.0);

  // Return new points of the same type by changing only some coordinate values.
  source.copyWith(m: 150.0);
  source.copyWith(x: 708221.7, z: 46.2);

  // Returns a point of the same type, but no previous values are preserved
  // (result here is Point3m.xyzm(1.0, 2.0, 3.0, 0.0)) with default 0.0 for m).
  source.newWith(x: 1.0, y: 2.0, z: 3.0);

  // This returns also Point3m.xyzm(1.0, 2.0, 3.0, 0.0)).
  source.newFrom([1.0, 2.0, 3.0, 0.0]);
```

### Geographic points

The base class for all *geographic* point geometries is `GeoPoint`, that extends
also `Point`. Geographic coordinates are longitude (`lon`) and latitude (`lat`),
in degrees and preferable always in this order. Elevation (`elev`) in meters and 
measure (`m`) coordinates are optional.

<a title="Djexplo, CC0, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Latitude_and_Longitude_of_the_Earth.svg"><img alt="Latitude and Longitude of the Earth" src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/coordinates/geographic/Latitude_and_Longitude_of_the_Earth.svg"></a>

Class        | Coordinates   | lon (x) | lat (y) | elev (z) | m 
------------ | ------------- | ------- | ------- | -------- | -
`GeoPoint2`  | `double`      |    +    |    +    |          |  
`GeoPoint2m` | `double`      |    +    |    +    |          | + 
`GeoPoint3`  | `double`      |    +    |    +    |    +     |  
`GeoPoint3m` | `double`      |    +    |    +    |    +     | + 

In the context of this package geographic coordinate axes are related with axes
defined in the base `Point`-class: 

* Longitude: `lon` == `x`
* Latitude: `lat` == `y`
* Elevation: `elev` == `z`

See below how to create `GeoPoint3m` instances (other classes in similar ways):

```dart
  // Geographic point with longitude, latitude, elevation and measure.
  GeoPoint3m(lon: -0.0014, lat: 51.4778, elev: 45.0, m: 123.0);
  GeoPoint3m.lonLatElevM(-0.0014, 51.4778, 45.0, 123.0);

  // Someone might want to represent latitude before longitude, it's fine too.
  GeoPoint3m.latLonElevM(51.4778, -0.0014, 45.0, 123.0);

  // When creating from value array, the order is: lon, lat, elev, m.
  GeoPoint3m.from([-0.0014, 51.4778, 45.0, 123.0]);

  // Also here it's possible to parse from WKT compatible text.
  GeoPoint3m.parse('-0.0014 51.4778 45.0 123.0');

  // The WKT parser for geographic coordinates parses full representations.
  WKT().parserGeographic().parse('POINT ZM (-0.0014 51.4778 45.0 123.0)');
```

### Point series

Other geometries are composed of point geometries in different structures. 
`PointSeries` is a collection class with a series of points and it can represent
a geometry path, a line string, an outer or inner linear ring of a polygon, 
a multi point, a vertex array or any any other collection for points.

```dart
  // A point series of `Point2` composed of list of points that are of `Point2`
  // or it's sub classes.
  PointSeries<Point2>.from([
    Point2(x: 10.0, y: 10.0),
    Point2(x: 20.0, y: 20.0),
    Point2m(x: 30.0, y: 30.0, m: 5.0),
    Point3(x: 40.0, y: 40.0, z: 40.0),
    Point3m(x: 50.0, y: 50.0, z: 50.0, m: 5.0),
  ]);

  // Making a point series of `Point3` from a list of a list of nums.
  PointSeries.make(
    // three points each with x, y and z coordinates
    [
      [10.0, 11.0, 12.0],
      [20.0, 21.0, 22.0],
      [30.0, 31.0, 32.0],
    ],
    // This is `PointFactory` that converts `Iterable<num>` to a point instance,
    // in this example using a factory creating `Point3` instances.
    Point3.coordinates,
  );

  // Parsing a point series of `GeoPoint` from WKT compatible text with
  // `GeoPoint3` as a concrete point class.
  PointSeries<GeoPoint>.parse(
    '10.0 11.0 12.0, 20.0 21.0 22.0, 30.0 31.0 32.0',
    GeoPoint3.coordinates,
  );
```

The `PointSeries` class is not extending the `Geometry` class, but it's used by
actual geometry classes, described in following sections, as a building block. 

### Line strings

A line string contains a *chain* of points, implemented using `PointSeries`. 

You can use `LineString.any` factory constructor to create a line string with
any chain, or `LineString.ring` constructor to create a linear ring with a 
closed chain. Both constructors simply take an instance of `PointSeries`.

Or below are examples of more direct ways to construct line strings:

```dart
  // This makes a a line string of `Point3m` from a list of points.
  LineString.make(
    [
      [10.0, 11.0, 12.0, 5.1],
      [20.0, 21.0, 22.0, 5.2],
      [30.0, 31.0, 32.0, 5.3],
    ],
    Point3m.coordinates,
  );

  // Using the WKT factory produces the same result as the previous sample.
  WKT().parserProjected().parse<Point3m>(
        'LINESTRING ZM(10.0 11.0 12.0 5.1, 20.0 21.0'
        ' 22.0 5.2, 30.0 31.0 32.0 5.3)',
      );

  // Also this sample, parsing from WKT compatible text, gives the same result.
  LineString.parse(
    '10.0 11.0 12.0 5.1, 20.0 21.0 22.0 5.2, 30.0 31.0 32.0 5.3',
    Point3m.coordinates,
  );
```

### Polygons

A polygon contains one exterior boundary and optional interior boundaries
(representing holes). All boundaries are *linear rings* implemented as
`LineString` instances each with a closed chain of points as a ring.

The default constructor of `Polygon` takes a series of `LineString` instances, 
with at least an exterior boundary at index 0.

Other ways to construct polygons are familiar from previous samples:

```dart
  // Making a polygon of `GeoPoint2` from a list of a list of a list of nums:
  Polygon.make(
    [
      // this is an exterior boundary or an outer ring
      [
        [35, 10],
        [45, 45],
        [15, 40],
        [10, 20],
        [35, 10]
      ],
      // this is an interior boundary or an inner ring representing a hole
      [
        [20, 30],
        [35, 35],
        [30, 20],
        [20, 30]
      ],
    ],
    GeoPoint2.coordinates,
  );

  // The same polygon geometry as above, but parsed from a WKT compatible text.
  Polygon.parse(
    '(35 10, 45 45, 15 40, 10 20, 35 10) (20 30, 35 35, 30 20, 20 30)',
    GeoPoint2.coordinates,
  );
```

### Multi geometries

Multi points, multi line strings and multi polygons can also be constructed
in similar ways described already for other geometries. Also parsed from text:

```dart
  // A multi point of `GeoPoint2` with four lon-lat points.
  MultiPoint.parse('10 40, 40 30, 20 20, 30 10', GeoPoint2.coordinates);

  // A multi line string of `Point2` with two line strings.
  MultiLineString.parse(
    '(10 10, 20 20, 10 40), (40 40, 30 30, 40 20, 30 10)',
    Point2.coordinates,
  );

  // A multi polygon of `GeoPoint2` with two polygon (both with exterior
  // boundary without holes).
  MultiPolygon.parse(
    '((30 20, 45 40, 10 40, 30 20)), ((15 5, 40 10, 10 20, 5 10, 15 5))',
    GeoPoint2.coordinates,
  );
```

There is also `GeometryCollection`:

```dart
  // A geometry collection can contain any other geometry types. Items for such
  // a collection can be constructed using different ways.
  GeometryCollection([
    // A point with integer values using a constructor with named parameters.
    Point2(x: 40, y: 10),
    // A line string made from a list of points (each a list of nums).
    LineString.make(
      [
        [10, 10],
        [20, 20],
        [10, 40]
      ],
      Point2.coordinates,
    ),
    // A polygon parsed from WKT compatible text.
    Polygon.parse('(40 40, 20 45, 45 30, 40 40)', Point2.coordinates)
  ]);

  // A geometry collection can also be parsed from WKT text.
  WKT().parserProjected().parse<Point2>(
    '''
      GEOMETRYCOLLECTION (
        POINT (40 10),
        LINESTRING (10 10, 20 20, 10 40),
        POLYGON ((40 40, 20 45, 45 30, 40 40)))
      ''',
  );
```

### Spatial bounds

Bounding boxes or spatial bounds objects can be represented in 2D or 3D, and
with an optional measure coordinates.

Bounds samples with projected or cartesian coordinates:

```dart
  // Bounds (2D) or bounding box from minimum and maximum 2D projected points.
  Bounds.of(min: Point2(x: 10.0, y: 10.0), max: Point2(x: 20.0, y: 20.0));

  // Bounds (3D) made from a list of list of nums.
  Bounds.make(
    [
      [10.0, 10.0, 10.0],
      [20.0, 20.0, 20.0]
    ],
    Point3.coordinates,
  );

  // Bounds (3D with measure) parsed from WKT compatible text.
  Bounds.parse('10.0 10.0 10.0 5.0, 20.0 20.0 20.0 5.0', Point3m.coordinates);
```

Bounds samples with geographic coordinates:

```dart
  // Geographical bounds (-20.0 .. 20.0 in longitude, 50.0 .. 60.0 in latitude).
  GeoBounds.bboxLonLat(-20.0, 50.0, 20.0, 60.0);

  // The same bounds created of 2D geographic point instances.
  GeoBounds.of(
    min: GeoPoint2(lon: -20.0, lat: 50.0),
    max: GeoPoint2(lon: 20.0, lat: 60.0),
  );
```

### Geospatial features

According to the [OGC Glossary](https://www.ogc.org/ogc/glossary/f) a geospatial
**feature** is *a digital representation of a real world entity. It has a spatial domain, a temporal domain, or a spatial/temporal domain as one of its attributes. Examples of features include almost anything that can be placed in time and space, including desks, buildings, cities, trees, forest stands, ecosystems, delivery vehicles, snow removal routes, oil wells, oil pipelines, oil spill, and so on*.

Below is an illustration of features in a simple vector map. *Wells* are features
with a point geometry, *rivers* with a line string (or polyline) geometry, and
finally *lakes* are features with a polygon geometry. Features normally contain
also an identifier and other attributes (or properties) along with a geometry.  

<a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Simple_vector_map.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/main/assets/doc/data/features/Simple_vector_map.svg"></a>


The `Feature` class of this package has geospatial `geometry` and `bounds` as fields along with `id` and `properties` fields. 

```dart
  // Geospatial feature with an identification, a point geometry and properties.
  Feature(
    id: 'ROG',
    geometry: GeoPoint3(lon: -0.0014, lat: 51.4778, elev: 45.0),
    properties: {
      'title': 'Royal Observatory',
      'place': 'Greenwich',
      'city': 'London',
      'isMuseum': true,
      'measure': 5.79,
    },
  );
```

Naturally, the `geometry` field could also contain other geometries described
earlier, not just points.

### Parsing GeoJSON data

[GeoJSON, as described](https://en.wikipedia.org/wiki/GeoJSON) by Wikipedia, is 
*an open standard format designed for representing simple geographical features, along with their non-spatial attributes*. 

See also the official [GeoJSON website](https://geojson.org/). As specified by
the referenced [RFC 7946](https://tools.ietf.org/html/rfc7946)
standard, all GeoJSON geometries use 
[WGS 84](https://en.wikipedia.org/wiki/World_Geodetic_System) geographic 
coordinates. Alternative coordinate reference systems can also be used when 
*involved parties have a prior arrangement* of using other systems.

Below is an example with sample GeoJSON data and code to parse it.

Imports:

```dart
import 'package:geocore/parse.dart';
```

The sample code:

```dart
  // sample GeoJSON data
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
            "place": "Greenwich",
            "city": "London"
          }
        }  
      ]
    }
  ''';

  // parse FeatureCollection using a GeoJSON parser with geographic coordinates
  final format = GeoJSON();
  final parser = format.parserGeographic(geographicPoints);
  final fc = parser.featureCollection(sample);

  // loop through features and print id, geometry and properties for each
  for (final f in fc.features) {
    print('Feature with id: ${f.id}');
    print('  geometry: ${f.geometry}');
    print('  properties:');
    for (final key in f.properties.keys) {
      print('    $key: ${f.properties[key]}');
    }
  }
```

At this stage the package supports reading following GeoJSON elements:

* FeatureCollection
* Feature
* Point, LineString and Polygon
* MultiPoint, MultiLineString and MultiPolygon
* GeometryCollection

### Parsing WKT data

[Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) (WKT) is 
*a text markup language for representing vector geometry objects*. It's 
specified by the [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa) standard.

WKT representations for coordinate data has already been discussed on previous
sections introducing geometry objects. Geometry classes have factory 
constructors that allows parsing coordinate values from WKT compatible text
(like a point using `Point2.parse('100.0 200.0')` factory).

When parsing full WKT geometry text representations, with a geometry type id and
coordinate values, the `WktFactory` class can be used. There are two main parser
implementations for different use cases:

Parser factory             | Use cases
-------------------------- | ---------
`WKT().parserProjected()`  | Parsing geometries with projected or cartesian coordinates.
`WKT().parserGeographic()` | Parsing geometries with geographic coordinates (like WGS 84).

Other custom parsers for WKT format can be created via `WKT().parser()` method.

Imports:

```dart
import 'package:geocore/parse.dart';
```

Samples to parse from WKT text representation of geometry:

```dart
  // get WKT format
  final format = WKT();

  // Parse projected points from WKT (result is different concrete classes).
  final parser1 = format.parserProjected();
  parser1.parse('POINT (100.0 200.0)'); // => Point2
  parser1.parse('POINT M (100.0 200.0 5.0)'); // => Point2m
  parser1.parse('POINT (100.0 200.0 300.0)'); // => Point3
  parser1.parse('POINT Z (100.0 200.0 300.0)'); // => Point3
  parser1.parse('POINT ZM (100.0 200.0 300.0 5.0)'); // => Point3m

  // Parse geographical line string, from (10.0 50.0) to (11.0 51.0).
  final parser2 = format.parser(GeoPoint2.coordinates);
  parser2.parse('LINESTRING (10.0 50.0, 11.0 51.0)');

  // Parse geographical polygon with a hole.
  final parser3 = format.parserGeographic();
  parser3.parse(
    'POLYGON ((40 15, 50 50, 15 45, 10 15, 40 15),'
    ' (25 25, 25 40, 35 30, 25 25))',
  );
```

Supported WKT geometry types: `POINT`, `LINESTRING`, `POLYGON`, `MULTIPOINT`, 
`MULTILINESTRING`, `MULTIPOLYGON` and `GEOMETRYCOLLECTION`.

### GeoJSON and WKT writers

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

Formats, content interfaces and writers are re-exported from the 
[geobase](https://pub.dev/packages/geobase) package that also provides more
documentation.

See samples below how to use text formats and encoders.

A sample to print coordinates of a point geometry below.

```dart
  // create a point (XYZ)
  final point = Point3(x: 10.123, y: 20.25, z: -30.95);

  // print with default format
  print('Default format: ${point.toString()}');
  print('Default format (decimals = 0): ${point.toStringAs(decimals: 0)}');

  // print with WKT format
  print('WKT format: ${point.toStringAs(format: WKT.geometry)}');

  // print with GeoJSON format
  print('GeoJSON format: ${point.toStringAs(format: GeoJSON.geometry)}');
  print(
    'GeoJSON (decimals = 1) format: ${point.toStringAs(
      format: GeoJSON.geometry,
      decimals: 1,
    )}',
  );
```

The sample below creates a GeoJSON format and feature writer, then create a
feature collection, and finally uses a writer to print it as GeoJSON text.

```dart
  // feature text encoder for GeoJSON
  final encoder = GeoJSON.feature.encoder();

  // create a feature collection with two features
  final collection = FeatureCollection(
    bounds: GeoBounds.of(
      min: GeoPoint2(lon: -1.1, lat: -3.49),
      max: GeoPoint2(lon: 10.12, lat: 20.25),
    ),
    features: [
      Feature(
        id: 'fid-1',
        geometry: GeoPoint2(lon: 10.123, lat: 20.25),
        properties: {
          'foo': 100,
          'bar': 'this is property value',
        },
      ),
      Feature(
        geometry: LineString.make(
          [
            [-1.1, -1.1],
            [2.1, -2.5],
            [3.5, -3.49]
          ],
          GeoPoint2.coordinates,
          type: LineStringType.any,
          bounds: GeoBounds.make(
            [
              [-1.1, -3.49],
              [3.5, -1.1]
            ],
            GeoPoint2.coordinates,
          ),
        ),
        properties: {},
      ),
    ],
  );

  // write the feture collection to the content writer of the encoder
  // (encoder.writer is FeatureContent)
  collection.writeTo(encoder.writer);

  // print GeoJSON text
  print(encoder.toText());

  // the previous line prints (however without line breaks):
  //    {"type":"FeatureCollection",
  //     "bbox":[-1.1,-3.49,10.123,20.25],
  //     "features":[
  //        {"type":"Feature",
  //         "id":"fid-1",
  //         "geometry":{"type":"Point","coordinates":[10.123,20.25]},
  //         "properties":{"foo":100,"bar":"this is property value"}},
  //        {"type":"Feature",
  //         "geometry":{"type":"LineString",
  //                     "bbox":[-1.1,-3.49,3.5,-1.1],
  //                     "coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]},
  //         "properties":{}}]}
```

## Reference

### Packages

The **geocore** library contains also following partial packages, that can be
used to import only a certain subset instead of the whole **geocore** package:

Package            | Exports also | Description 
------------------ | ----------- | -----------------------------------------------
**base**        | | Base classes for geospatial geometry objects.
**coordinates** | base | Projected and geographic coordinates.
**data**        | base, coordinates | Geospatial features and geometries (linestring, polygon, multi geometries).

Please note that some of the most often used classes from 
[geobase](https://pub.dev/packages/geobase) are also re-exported by `geocore`.

External packages `geocore` is depending on:
* [equatable](https://pub.dev/packages/equatable) for equality and hash utils
* [geobase](https://pub.dev/packages/geobase) for base geospatial data structures
* [meta](https://pub.dev/packages/meta) for annotations

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).