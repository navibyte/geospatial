## 0.2.0-nullsafety.0

- Alpha version 0.2.0 with breaking changes compared to 0.1.0.
- More geometries: LineString (any line string or linear ring), Polygon
- Custom Iterable interface and sub implementation: Series, SeriesView
- Geometry series: GeometrySeries, PointSeries, LineStringSeries, PolygonSeries
- Features and collections: Feature, FeatureSeries

## 0.1.0-nullsafety.2

- Small fixes on README.md

## 0.1.0-nullsafety.1

- Small fixes on links of pubspec.yaml

## 0.1.0-nullsafety.0

- Initial pre-release version, the API of the library is not stable
- Designed for null-safety (requires sdk: '>=2.12.0-0 <3.0.0')
- Uses as dependency: Equatable (^2.0.0-nullsafety.0)
- Cartesian points using doubles: Point2, Point2m, Point3, Point3m
- Cartesian points using integers: Point2i, Point3i
- Geographical points using doubles: GeoPoint2, GeoPoint3
- Geographical camera: GeoCamera
- Geographical bounds: GeoBounds
- Coordinate reference systems: CRS class with two predefined identifiers
- Temporal coordinates: Instant, Interval
- Geospatial extent: Extent
- Web links: Link

