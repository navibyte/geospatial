## 0.9.0

Development version: 0.9.0-dev.0

⚠️ Breaking changes:
- Removed previously deprecated classes and members

🛠 Maintenance:
- [Upgrade to Dart 2.17 #105](https://github.com/navibyte/geospatial/issues/105)
- [Apply very_good_analysis 3.0.0+ lint rules #104](https://github.com/navibyte/geospatial/issues/104)

## 0.8.1

Small fix with latest dependency to `geobase` version 0.1.1.

## 0.8.0

Major and breaking changes compared to version 0.7.2.

Some classes generalized and moved to the 
[geobase](https://pub.dev/packages/geobase) package, that is depended on.

After changes key features of this [geocore](https://pub.dev/packages/geocore)
package:

* 🚀 geospatial data structures (geometry, features and metadata)
* 🌐 *geographic* coordinates (longitude-latitude)
* 🗺️ *projected* coordinates (cartesian XYZ)
* 🔷 geometry primitives (bounds or bbox, point, line string, polygon)
* 🧩 multi geometries (multi point, multi line string, multi polygon, geometry collections)
* ⭐ feature objects (with id, properties and geometry) and feature collections
* 🌎 [GeoJSON](https://geojson.org/) data parser
* 🪧 [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) 
(Well-known text representation of geometry) data parser 

⚠️ Breaking changes:
- [Refactor Feature class inheritance and types of id and properties members #39](https://github.com/navibyte/geospatial/issues/39)
- [Define more specific return type on newWith and newFrom methods of Point sub classes #41](https://github.com/navibyte/geospatial/issues/41)
- [Populate results by default when intersecting with bounds on point and bounded series #42](https://github.com/navibyte/geospatial/issues/42)
- [Define consistent mini library exports with base classes included #31](https://github.com/navibyte/geospatial/issues/31)
- [Move temporal classes to "base" mini-library #69](https://github.com/navibyte/geospatial/issues/69)
- [Generalize and move project and transform from geocore to geobase #95](https://github.com/navibyte/geospatial/issues/95)
- [Intersects bounds generalized on geobase #97](https://github.com/navibyte/geospatial/issues/97)

🧩 Features:
- [Add copyWith method to Point classes #43](https://github.com/navibyte/geospatial/issues/43)
- Initial support and abstractions for [Coordinate transformations on core classes and reading datasource #15](https://github.com/navibyte/geospatial/issues/15)
- [Test point equality in 2D or 3D by tolerance in Point class #47](https://github.com/navibyte/geospatial/issues/47)
- [Check if point series is closed by tolerance #48](https://github.com/navibyte/geospatial/issues/48)
- [Add CartesianPoint to the Point-class hierarchy #54](https://github.com/navibyte/geospatial/issues/54)
- [Coordinate conversion between WGS84 (lon-lat) and Web Mercator projection (meters)](https://github.com/navibyte/geospatial/issues/55)
- [Add simpler constructors on geometry classes expecting bounded or point series #59](https://github.com/navibyte/geospatial/issues/59)
- [Add projection support provided by the proj4dart package #60](https://github.com/navibyte/geospatial/issues/60)
- [Common base class or interface for temporal Instant and Interval classes #70](https://github.com/navibyte/geospatial/issues/70)
- [Add support for empty geometries other than Point and abstract Geometry #35](https://github.com/navibyte/geospatial/issues/35)

🛠 Refactoring:
- [Refactor coordinate value members of immutable Point classes #44](https://github.com/navibyte/geospatial/issues/44)
- [Elev and m coordinate values as default in some GeoPoint classes #45](https://github.com/navibyte/geospatial/issues/45)
- [Rename point factories of Point classes #49](https://github.com/navibyte/geospatial/issues/49)
- [Separate some common features of geocore to separate common package #86](https://github.com/navibyte/geospatial/issues/86)
- [Remove "empty point" concept #85](https://github.com/navibyte/geospatial/issues/85)
- [Simplify Feature and FeatureCollection classes #88](https://github.com/navibyte/geospatial/issues/88)
- [Simplify temporal classes (Instant, Interval) and add equality and hashCode impls #93](https://github.com/navibyte/geospatial/issues/93)
- [Equality and hashcodes on Point and other Geometry classes #12](https://github.com/navibyte/geospatial/issues/12)

🛠 Maintenance:
- [Upgrade to Dart 2.15 #90](https://github.com/navibyte/geospatial/issues/90)

📚 Documentation:
- [Readme documentation updates for 0.8.0 release #63](https://github.com/navibyte/geospatial/issues/63)
- [Document coordinate ordering of Point class #64](https://github.com/navibyte/geospatial/issues/64)
- [Update copyright clauses (years 2020-2022) and licenses #66](https://github.com/navibyte/geospatial/issues/66)

## 0.7.2

- [Apply very_good_analysis 2.4.0+ lint rules #36](https://github.com/navibyte/geospatial/issues/36)
- [Enhance methods of Point returning coordinate values as String #37](https://github.com/navibyte/geospatial/issues/37)
- [Add fromText and toText serialization to Point classes #38](https://github.com/navibyte/geospatial/issues/38)

## 0.7.1

- BETA version 0.7.1
- [Apply very_good_analysis 2.3.0+ lint rules #33](https://github.com/navibyte/geospatial/issues/33)
- [WKT parser - add support for parsing GEOMETRYCOLLECTION #24](https://github.com/navibyte/geospatial/issues/24)

## 0.7.0

- BETA version 0.7.0 with minor breaking changes
- Use `Map<String, Object?>` instead of `Map<String, dynamic>` as properties
  - Factory: `Feature.view()`
  - Function typedef: `CreateFeature`
- updated dependency 0.7.1 on [attributes](https://pub.dev/packages/attributes)
    - required changes visible in Feature class and GeoJSON factories
- [Official Dart lint rules applied with recommend set #32](https://github.com/navibyte/geospatial/issues/32)

## 0.6.2

- BETA version 0.6.2 with documentation updates
- [Documentation updates with explaining features, geometries and other classes #25](https://github.com/navibyte/geospatial/issues/25)
- [Factory and other fixes on Bounds, GeometryCollection, Instant etc. #26](https://github.com/navibyte/geospatial/issues/26)

## 0.6.1

- BETA version 0.6.1 with partial support for [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) or WKT
- Also easier to use factories for points, line strings, polygons, etc.
  - Make geometries from arrays of num values.
  - Parse geometries from text with default implementation based on WKT.
    - Other text encodings can be implemented using custom parsers. 
- [Initial WKT support](https://github.com/navibyte/geospatial/issues/22)
- [Easier constructor to make point and other geometry instances.](https://github.com/navibyte/geospatial/issues/23)    
- Some other minor fixes.    

## 0.6.0

- BETA version 0.6.0 with minor breaking changes
- [Lint rules and analysis options updated](https://github.com/navibyte/geospatial/issues/8)
- Also `implicit-casts` and `implicit-dynamic` to false requiring code changes
- many other smaller changes and optimizations partially due issues #8 

## 0.5.0

- BETA version 0.5.0 with stable null-safety requiring the stable Dart 2.12

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

