## 0.5.0-nullsafety.0

- BETA version 0.5.0 with (relative small) breaking changes compared to 0.4.1
- Enhancing geospatial data factories, for example range filter
- Bounds and Point with new methods: writeValues and valuesAsString

## 0.4.1-nullsafety.0

- Alpha version 0.4.1 with minor feature changes compared to 0.4.0
  - may require migrations
  - Point interface has now x, y, z and m getters of type num, not double
  - However GeoPoint still has lon, lat, elev getters as double as previously 
  - GeoJSON parser has breaking changes on point, bounds and feature factories
- [Coordinate value getter properties as num on points #2](https://github.com/navibyte/geospatial/issues/2)
- [Point and geometry factory interfaces and implementations #3](https://github.com/navibyte/geospatial/issues/3)
- [Point factory constructor consistency #4](https://github.com/navibyte/geospatial/issues/4)
- [Adapt factory changes to GeoJSON parser #5](https://github.com/navibyte/geospatial/issues/5)
- [GeoJSON parser to allow extended Feature data #6](https://github.com/navibyte/geospatial/issues/6)
  - at least partial implementation, forward json object to factory function too
- [BoundsBuilder as utility class #7](https://github.com/navibyte/geospatial/issues/7)
 
## 0.4.0-nullsafety.0

- Alpha version 0.4.0 with breaking changes compared to 0.3.0
- New dependency: `attributes` (^0.4.0-nullsafety.0) for common data structures
- Non-geospatial data structures moved to `attributes`
- Removed dependency: fixnum (1.0.0-nullsafety.0)
- Restructured lib/src folder:
  - base
  - crs
  - feature
  - geo
  - meta
    - extent
  - parse
    - factory
    - geojson
  - utils
    - geography     
- Restructured mini-libraries provided by the package:
  - 'package:geocore/base.dart'
  - 'package:geocore/crs.dart'
  - 'package:geocore/feature.dart'
  - 'package:geocore/geo.dart'
  - 'package:geocore/meta_extent.dart'
  - 'package:geocore/parse_factory.dart'
  - 'package:geocore/parse_geojson.dart'
- Still the whole library is available by:
  - 'package:geocore/geocore.dart'
- Refactoring code in many places too

## 0.3.0-nullsafety.0

- Alpha version 0.3.0 with breaking changes compared to 0.2.0
- New dependency: fixnum (^1.0.0-nullsafety.0) for Int64 (Dart VM / JavaScript)
- New constructors on Point and GeoPoint for creating points from coordinates
- GeoPoint sub classes to support representing also M-coordinate
- New enumerated type: enum CRSType { geographic, projected, local }
- Empty geometry to map null geometries (ie. from GeoJSON) to such instance
- Multi geometry: MultiPoint, MultiLineString, MultiPoint, GeometryCollection
- Feature class changes: FeatureId, Feature, FeatureSeries, FeatureCollection
- Factory abstraction for creating geometries, features and feature collections
- Factory implementation for GeoJSON, initial version, not full coverage
  - FeatureCollection, Feature 
  - Point, LineString, Polygon
  - MultiPoint, MultiLineString, MultiPoint
  - GeometryCollection
- Refactoring also some other constructors for consistent naming conventions
- Some tests added also to test parsing GeoJSON data

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

