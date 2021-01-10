# :globe_with_meridians: Geocore

[![pub package](https://img.shields.io/pub/v/geocore.svg)](https://pub.dev/packages/geocore) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

**Geocore** is a library package for [Dart](https://dart.dev/) and 
[Flutter](https://flutter.dev/) mobile developers to help on handling geospatial
data like geometries, features and metadata. It also contains utilities for 
parsing [GeoJSON](https://geojson.org/) content. 

The package supports representing both geographic (decimal degrees or 
longitude-latitude) and projected coordinates in 2D and 3D. Points may have also
a M (measure) coordinate associated as needed. There are classes for common
geometries including points, bounding boxes, line strings (polylines), polygons
and various multi-geometries known by [GeoJSON](https://geojson.org/) and 
[WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
(Well-known text representation of geometry) specifications.

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
  * Implementation to parse GeoJSON from text strings.

## :package: Package

This is a [Dart](https://dart.dev/) code package named `geocore` under the 
[geospatial](https://github.com/navibyte/geospatial) repository. 

**This package is at the alpha-stage, breaking changes are possible.** 

The package is associated with and depending on the 
[attributes](https://pub.dev/packages/attributes) package containing 
non-geospatial data structures that are extended and utilized by the 
`geocore` to provide geospatial data structures and utilities. 

The package is used by the [geodata](https://pub.dev/packages/geodata) package
that provides a geospatial client for fetching data from different data sources.

## :electric_plug: Installing

The package supports Dart [null-safety](https://dart.dev/null-safety) and 
using it requires the latest SDK from a beta channel. However your package using
it doesn't have to be migrated to null-safety yet.    

Please see the official 
[null-safety migration guide](https://dart.dev/null-safety/migration-guide)
how to switch to the latest beta release of Dart or Flutter SDKs.

In the `pubspec.yaml` of your project add the dependency:

```yaml
dependencies:
  geocore: ^0.4.0-nullsafety.0
```

All dependencies used by `geocore` are also ready for 
[null-safety](https://dart.dev/null-safety)!

## :card_file_box: Libraries

The package contains following mini-libraries:

Library              | Description 
-------------------- | -----------
**base**             | Geometry classes including points, bounds, line strings, polygons and more.
**crs**              | Classes to represent coordinate reference system (CRS) identifiers.
**feature**          | Feature and FeatureCollection to handle dynamic geospatial data objects.
**geo**              | Geographic points and bounds classes to represent longitude-latitude data
**meta_extent**      | Metadata structures to handle extents with spatial and temporal parts.
**parse_factory**    | Base interfaces and implementations for geospatial data factories.
**parse_geojson**    | Geospatial data factory implementation to parse GeoJSON from text strings.

For example to access a mini library you should use an import like:

```dart
import 'package:geocore/base.dart';
```

To use all libraries of the package:

```dart
import 'package:geocore/geocore.dart';
```

## :keyboard: Usage

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
  fc.features.forEach((f) {
    print('Feature with id: ${f.id}');
    print('  geometry: ${f.geometry}');
    print('  properties:');
    f.properties.map.forEach((key, value) => print('    $key: $value'));
  });
```

At this stage the package supports reading following GeoJSON elements:

* FeatureCollection
* Feature
* Point, LineString and Polygon
* MultiPoint, MultiLineString and MultiPolygon
* GeometryCollection

### Using geospatial data structures

It's also possible to create feature, geometry and metadata structures by hand.

Please see [example code](example/geocore_example.dart) for more information.

Some samples also below.

Imports:

```dart
import 'package:geocore/geocore.dart';
```

The sample code:

```dart
  // Geospatial feature
  final f = Feature.view(
    id: 'ROG',
    geometry: GeoPoint3.from([-0.0014, 51.4778, 45.0]),
    properties: {
      'title': 'Royal Observatory',
      'place': 'Greenwich',
      'city': 'London',
    },
  );

  // Geographical points (lon-lat, lon-lat-m, lon-lat-elev, lon-lat-elev-m)
  final geo2 = GeoPoint2.lonLat(-0.0014, 51.4778);
  final geo2m = GeoPoint2m.lonLatM(-0.0014, 51.4778, 123.0);
  final geo3 = GeoPoint3.lonLatElev(-0.0014, 51.4778, 45.0);
  final geo3m = GeoPoint3m.lonLatElevM(-0.0014, 51.4778, 45.0, 123.0);
```

### Non-geospatial data

Classes described above and provided by this package are designed for geospatial
use cases.

When geospatial geometries and features are not needed, then 
the [attributes](https://pub.dev/packages/attributes) package might be 
useful for representing dynamic data objects, property maps and identifiers. 

## :house_with_garden: Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## :copyright: License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).

