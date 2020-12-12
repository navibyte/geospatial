# Geospatial - geocore

Geospatial data structures (features, geometry and metadata) and utilities 
([GeoJSON](https://geojson.org/) parser) for Dart for [Dart](https://dart.dev/) 
and [Flutter](https://flutter.dev/) mobile developers.

**This package is at the alpha-stage, breaking changes are possible.** 

This is a [Dart](https://dart.dev/) code package named `geocore` under the 
[geospatial](https://github.com/navibyte/geospatial) repository. The package supports Dart [null-safety](https://dart.dev/null-safety).

## Installing

The package is designed null-safety in mind and requires SDK from beta channel:

```yaml
environment:
  sdk: '>=2.12.0-0 <3.0.0'
```

More information about how to switch to the latest beta release of Dart or 
Flutter SDKs is available in the official 
[null-safety migration guide](https://dart.dev/null-safety/migration-guide).
Please consult it first about null-safety.

Dependencies defined in the `pubspec.yaml` when using the package:

```yaml
dependencies:
  geocore: ^0.3.0-nullsafety.0
```

All dependencies used by `geocore` are also ready for 
[null-safety](https://dart.dev/null-safety)!

## Parsing GeoJSON data

The [GeoJSON](https://geojson.org/) format supports encoding of geographic data structures. Below is an example with sample GeoJSON data and code to parse it.

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
          "id": "greenwich",
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
    f.properties.forEach((key, value) => print('    $key: $value'));
  });
```

At this stage the package supports reading following GeoJSON elements:

* FeatureCollection
* Feature
* Point, LineString and Polygon
* MultiPoint, MultiLineString and MultiPolygon
* GeometryCollection

## Using geospatial data structures

It's also possible to create feature, geometry and metadata structure by hand.

Please see [example code](example/geocore_example.dart) for more information.

Some samples also below.

Imports:

```dart
import 'package:geocore/geocore.dart';
```

The sample code:

```dart
  // Geospatial feature
  final f = Feature.of(
    id: 'greenwich',
    geometry: GeoPoint.from([-0.0014, 51.4778, 45.0]),
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

## Features

*Please note that this library is under developement, so classes and their features may still change*.

The package contains geospatial data structures:

- Cartesian points using doubles: Point2, Point2m, Point3, Point3m
- Cartesian points using integers: Point2i, Point3i
- Geographical points: GeoPoint2, GeoPoint2m, GeoPoint3, GeoPoint3m
- Geographical camera: GeoCamera
- Geographical bounds: GeoBounds
- More geometries: LineString (any line string or linear ring), Polygon
- Multi geometry: MultiPoint, MultiLineString, MultiPolygon, GeometryCollection
- Custom Iterable interface and sub implementation: Series, SeriesView
- Geometry series: GeometrySeries, PointSeries, LineStringSeries, PolygonSeries
- Features: FeatureId, Feature, FeatureSeries, FeatureCollection
- Coordinate reference system (id): CRS class with two predefined identifiers
- Temporal coordinates: Instant, Interval
- Geospatial extent: Extent
- Web links: Link

An abstraction for parsing geospatial data:

```dart
/// A factory to create geospatial geometries and features from source data.
abstract class GeoFactory {
  const GeoFactory();

  /// Parses a geometry from a [data] object.
  Geometry geometry(dynamic data);

  /// Parses a feature from a [data] object.
  Feature feature(dynamic data);

  /// Parses a series of features from a [data] object.
  FeatureSeries featureSeries(dynamic data);

  /// Parses a feature collection from a [data] object.
  FeatureCollection featureCollection(dynamic data);
}
```

As described on an example earlier there is an implementation for this
abstraction to support reading and parsing [GeoJSON](https://geojson.org/) data.

## Authors

This project is authored by [Navibyte](https://navibyte.com).

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the [LICENSE](LICENSE).

