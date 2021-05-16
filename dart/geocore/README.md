# Geocore

[![pub package](https://img.shields.io/pub/v/geocore.svg)](https://pub.dev/packages/geocore) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

**Geocore** is a library package for [Dart](https://dart.dev/) and 
[Flutter](https://flutter.dev/) mobile developers to help on handling geospatial
data like geometries, features and metadata. It also contains utilities for 
parsing [GeoJSON](https://geojson.org/) content and partial support for [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
(Well-known text representation of geometry). 

The package supports representing both geographic (decimal degrees or 
longitude-latitude) and projected coordinates in 2D and 3D. Points may have also
a M (measure) coordinate associated as needed. There are classes for common
geometries including points, bounding boxes, line strings (polylines), polygons
and various multi-geometries known by [GeoJSON](https://geojson.org/) and 
[WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) 
specifications.

Key features:
* Base geometry classes
  * `Point` abstraction to represent coordinate values, different variations:
    * x, y
    * x, y, m (measure)
    * x, y, z
    * x, y, z, m (measure)
  * Num-based Point classes: `Point2`, `Point2m`, `Point3`, `Point3m`
    * coordinate values can be any `num` (that is `double` or `int`)
  * Int-based Point classes: `Point2i`, `Point3i`
  * `PointSeries` is a custom iterable for points with intersect methods
  * `BoundedSeries` is a custom iterable for to support other geometries too
  * `Bounds` to represents bounding boxes
  * `LineString` and `Polygon` to represent line string (polylines) and polygons
  * `MultiPoint`, `MultiLineString`, `MultiPolygon`, `GeometryCollection`
  * Temporal coordinates: `Instant`, `Interval`  
* Coordinate reference system (`CRS`) identifiers
* Geographic coordinate based on decimal degrees (longitude, latitude)
  * `GeoPoint` abstraction to represent geographic coordinate values:
    * lon, lat
    * lon, lat, m (measure)
    * lon, lat, elev
    * lon, lat, elev, m (measure)
  * Concrete classes: `GeoPoint2`, `GeoPoint2m`, `GeoPoint3`, `GeoPoint3m`
  * `GeoBounds` for geographic bounds
* Feature data
  * `Feature` is a geospatial entity with id, properties and geometry
  * `FeatureCollection` is a collection of features
* Meta data structures
  * `Extent` with spatial and temporal parts
* Geospatial data parsers
  * Parse [GeoJSON](https://geojson.org/) from text strings.
  * Parse [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) from text strings
    * Currently supported: POINT, LINESTRING, POLYGON, MULTIPOINT, MULTILINESTRING, MULTIPOLYGON

**This package is at BETA stage, interfaces not fully final yet.** 

## Usage

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
  wktProjected.parse('POINT Z (708221.0 5707225.0 45.0)');
```

All other point classes have similar constructors.

### Geographic points

The base class for all *geographic* point geometries is `GeoPoint`, that extends
also `Point`. Geographic coordinates are longitude (`lon`) and latitude (`lat`),
in degrees and preferable always in this order. Elevation (`elev`) in meters and 
measure (`m`) coordinates are optional.

Class        | Coordinates   | lon | lat | elev | m 
------------ | ------------- | --- | --- | ---- | -
`GeoPoint2`  | `double`      | +   | +   |      |  
`GeoPoint2m` | `double`      | +   | +   |      | + 
`GeoPoint3`  | `double`      | +   | +   | +    |  
`GeoPoint3m` | `double`      | +   | +   | +    | + 

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
  wktGeographic.parse('POINT ZM (-0.0014 51.4778 45.0 123.0)');
```

### Point series

Other geometries are composed of point geometries in different structures. 
`PointSeries` is a class that contains a series of points and can represent
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
    Point3.geometry,
  );

  // Parsing a point series of `GeoPoint` from WKT compatible text with 
  // `GeoPoint3` as a concrete point class. 
  PointSeries<GeoPoint>.parse(
      '10.0 11.0 12.0, '
      '20.0 21.0 22.0, '
      '30.0 31.0 32.0',
      GeoPoint3.geometry);
```

Other geometries described in following sections use `PointSeries` as a building
block.

### Line strings

A line string contains a *chain* of points with a chain implemented as 
`PointSeries` instance. 

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
    Point3m.geometry,
  );

  // Parsing using the WKT factory produces the result as the previous sample.
  wktProjected.parse<Point3m>('LINESTRING ZM (10.0 11.0 12.0 5.1, '
      '20.0 21.0 22.0 5.2, 30.0 31.0 32.0 5.3)');
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
    GeoPoint2.geometry,
  );

  // The same polygon geometry as above, but parsed from a WKT compatible text.
  Polygon.parse(
      '(35 10, 45 45, 15 40, '
      '10 20, 35 10) (20 30, 35 35, 30 20, 20 30)',
      GeoPoint2.geometry);
```

### Multi geometries

Multi points, multi line strings and multi polygons can also be constructed
in similar ways described already for other geometries. 

Below only a shorter sample of parsing such multi geometries:

```dart
  // A multi point of `GeoPoint2` with four lon-lat points.
  MultiPoint.parse('10 40, 40 30, 20 20, 30 10', GeoPoint2.geometry);

  // A multi line string of `Point2` with two line strings.
  MultiLineString.parse(
      '(10 10, 20 20, 10 40), (40 40, 30 30, 40 20, 30 10)', Point2.geometry);

  // A multi polygon of `GeoPoint2` with two polygon (both with exterior 
  // boundary without holes).
  MultiPolygon.parse(
      '((30 20, 45 40, 10 40, 30 20)), ((15 5, 40 10, 10 20, 5 10, 15 5))',
      GeoPoint2.geometry);
```

There is also `GeometryCollection` that can contain any type of geometry 
instances at same time.

### Geospatial features

The [attributes](https://pub.dev/packages/attributes) package has a `Entity` 
class that represents a structured data entity that has an optional 
identification by an `Identifier` object and contains associated property values
in a `PropertyMap` object.

The `Feature` class of this package extends `Entity`, and has also geospatial
`geometry` and `bounds` as fields along with `id` and `properties` fields. That
is a *feature* is a geospatial *entity* object.

Below a feature from id, geometry and properties is constructed:

```dart
  // Geospatial feature
  Feature.view(
    id: 'ROG',
    geometry: GeoPoint3.from([-0.0014, 51.4778, 45.0]),
    properties: <String, dynamic>{
      'title': 'Royal Observatory',
      'place': 'Greenwich',
      'city': 'London',
    },
  );
```

The `geometry` could be also other geometry instances described earlier, not
just points.

### Parsing GeoJSON data

The [GeoJSON](https://geojson.org/) format supports encoding of geographic data
structures. Below is an example with sample GeoJSON data and code to parse it.

Imports:

```dart
import 'package:geocore/parse_geojson.dart';
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

  // parse FeatureCollection using the default GeoJSON factory
  final fc = geoJSON.featureCollection(sample);

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

### Non-geospatial data

Classes described above and provided by this package are designed for geospatial
use cases.

When geospatial geometries and features are not needed, then 
the [attributes](https://pub.dev/packages/attributes) package might be 
useful for representing dynamic data objects, property maps and identifiers. 

## Installing

The package supports Dart [null-safety](https://dart.dev/null-safety) and 
using it requires at least
[Dart 2.12](https://medium.com/dartlang/announcing-dart-2-12-499a6e689c87)
from the stable channel. Please see the official 
[null-safety migration guide](https://dart.dev/null-safety/migration-guide).

In the `pubspec.yaml` of your project add the dependency:

```yaml
dependencies:
  geocore: ^0.6.1
```

All dependencies used by `geocore` are also ready for 
[null-safety](https://dart.dev/null-safety)!

## Package

This is a [Dart](https://dart.dev/) code package named `geocore` under the 
[geospatial](https://github.com/navibyte/geospatial) repository. 

The package is associated with and depending on the 
[attributes](https://pub.dev/packages/attributes) package containing 
non-geospatial data structures that are extended and utilized by the 
`geocore` to provide geospatial data structures and utilities. 

The package is used by the [geodata](https://pub.dev/packages/geodata) package
that provides a geospatial client for fetching data from different data sources.

## Libraries

The package contains following mini-libraries:

Library              | Description 
-------------------- | -----------
**base**             | Geometry classes including points, bounds, line strings, polygons and more.
**crs**              | Classes to represent coordinate reference system (CRS) identifiers.
**feature**          | Feature and FeatureCollection to handle dynamic geospatial data objects.
**geo**              | Geographic points and bounds classes to represent longitude-latitude data
**meta_extent**      | Metadata structures to handle extents with spatial and temporal parts.
**parse_factory**    | Base interfaces and implementations for geospatial data factories.
**parse_geojson**    | Geospatial data factory to parse GeoJSON from text strings.
**parse_wkt**        | Geospatial data factory to parse WKT from text strings.

For example to access a mini library you should use an import like:

```dart
import 'package:geocore/base.dart';
```

To use all libraries of the package:

```dart
import 'package:geocore/geocore.dart';
```

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).

