# Geospatial - geocore

Geospatial data structures and geometry classes for [Dart](https://dart.dev/) 
and [Flutter](https://flutter.dev/) mobile developers.

**This package is at the alpha-stage, breaking changes are possible.** 

**This package supports Dart [null-safety](https://dart.dev/null-safety).**

This is a [Dart](https://dart.dev/) code package named `geocore` under the 
[geospatial](https://github.com/navibyte/geospatial) repository. 

## Usage

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
  geocore: ^0.1.0-nullsafety.2 
```

An example how to use geospatial data structures the package provides:

```dart
import 'package:geocore/geocore.dart';

main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // Cartesian points (XY, XYM, XYZ and XYZM) using doubles
  print(Point2.xy(291692.0, 5707473.0));
  print(Point2m.xym(291692.0, 5707473.0, 123.0));
  print(Point3.xyz(291692.0, 5707473.0, 11.0));
  print(Point3m.xyzm(291692.0, 5707473.0, 11.0, 123.0));

  // Cartesian points (XY, XYZ) using integers
  print(Point2i.xy(291692, 5707473));
  print(Point3i.xyz(291692, 5707473, 11));

  // Geographical points (lon-lat, lon-lat-elev) using doubles
  print(GeoPoint2.lonLat(0.0, 51.48));
  print(GeoPoint3.lonLatElev(0.0, 51.48, 11));
}
```

## Features

The package contains geospatial data structures:

- Cartesian points using doubles: Point2, Point2m, Point3, Point3m
- Cartesian points using integers: Point2i, Point3i
- Geographical points using doubles: GeoPoint2, GeoPoint3
- Geographical camera: GeoCamera
- Geographical bounds: GeoBounds
- Coordinate reference systems: CRS class with two predefined identifiers
- Temporal coordinates: Instant, Interval
- Geospatial extent: Extent
- Web links: Link

## Authors

This project is authored by **[Navibyte](https://navibyte.com)**.

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the [LICENSE](LICENSE).

