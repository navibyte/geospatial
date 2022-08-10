## 0.3.0

Development version `0.3.0-dev.2`.

✨ New: Data structures for simple geometries, features and feature collections.
✨ New: Support for [Well-know binary](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary) (WKB). Text and
binary data formats, encodings and content interfaces also redesigned.

⚠️ Breaking changes:
- Content interfaces, content encoders and text formats redesigned
- [Rename writers and content interfaces to generalize #127](https://github.com/navibyte/geospatial/issues/127)
- [Geometry content written with more specific methods #128](https://github.com/navibyte/geospatial/issues/128)
- [Allow coordinate value arrays along with position arrays on content interfaces #129](https://github.com/navibyte/geospatial/issues/129)
- [Simplify Coords enum #130](https://github.com/navibyte/geospatial/issues/130)

🧩 Features:
- [Combine writers and parsers for formats (GeoJSON, WKT) consistently #125](https://github.com/navibyte/geospatial/issues/125)
- [Add WKB encoding/decoding support #115](https://github.com/navibyte/geospatial/issues/115)
- [Text and Binary outputs on writers #126](https://github.com/navibyte/geospatial/issues/126)
- [Text and Binary outputs on decoders #132](https://github.com/navibyte/geospatial/issues/132)
- [Coordinate order on box and position consistently #134](https://github.com/navibyte/geospatial/issues/134)
- [Positions as iterable of coordinate values on geobase #136](https://github.com/navibyte/geospatial/issues/136)
- [PositionData access (on lists or buffers) #137](https://github.com/navibyte/geospatial/issues/137)
- new mini library "transforms" and "projections"
- [Simple geometry data structures on geobase #133](https://github.com/navibyte/geospatial/issues/133)
- [Feature data structures on geobase #138](https://github.com/navibyte/geospatial/issues/138)
- [GeoJSON text decoder building new geometry and feature data structures on geobase #139]()(https://github.com/navibyte/geospatial/issues/139)
- [Equals, hashCode and toString for geometries and features on geobase #143](https://github.com/navibyte/geospatial/issues/143)
- [Encode / write methods directly from geometry and feature classes on geobase #144](https://github.com/navibyte/geospatial/issues/144)

🛠 Refactoring:
- [Optimize reading from iterable of coordinate values #131](https://github.com/navibyte/geospatial/issues/131)

## 0.2.1

🐛 Bugs fixed:
- [Ambiguous reexports on geobase 0.2.0 with constants #122](https://github.com/navibyte/geospatial/issues/122)

## 0.2.0

✨ New: Tiling schemes and tile matrix sets (web mercator, global geodetic). 
Also other improvements on coordinates, and refactorings on the code structure.

🧩 Features:
- [Mini-libraries for geobase #109](https://github.com/navibyte/geospatial/issues/109)
- [Conversion between WGS84 (lon-lat) and Web Mercator Quad tile matrix set #57](https://github.com/navibyte/geospatial/issues/57)
- [MapPoint2i renamed to ScalableXY, and implementing Projected and Scalable #116](https://github.com/navibyte/geospatial/issues/116)
- [Use OGC specified screen pixel size / ppi when calculating scale denominator #119](https://github.com/navibyte/geospatial/issues/119)
- [Add World CRS84 TileMatrixSet #114](https://github.com/navibyte/geospatial/issues/114)
- [Add zoomIn, zoomOut and zoomOut to Scalable2i #121](https://github.com/navibyte/geospatial/issues/121)

🛠 Maintenance:
- [Upgrade to Dart 2.17 #105](https://github.com/navibyte/geospatial/issues/105)
- [Apply very_good_analysis 3.0.0+ lint rules #104](https://github.com/navibyte/geospatial/issues/104)
- [Restructure code folders on geobase package #107](https://github.com/navibyte/geospatial/issues/107)

## 0.1.1

🧩 Features:
- [Create position instances from num iterables or text #101](https://github.com/navibyte/geospatial/issues/101)
- [Distance (haversine) between geographic positions #102](https://github.com/navibyte/geospatial/issues/102)
- [Create box instances from num iterables or text #103](https://github.com/navibyte/geospatial/issues/103)

## 0.1.0

Initial version with some code originating from `geocore` package:
* 🔢 enums for geospatial coordinate and geometry types
* 🌐 *geographic* positions and bounding boxes (longitude-latitude-elevation)
* 🗺️ *projected* positions and bounding boxes (cartesian XYZ)
* 🏗️ coordinate transformations and projections (initial support)
* 📅 temporal data structures (instant, interval)
* 📃 geospatial data writers for features, geometries, coordinates, properties:
  * 🌎 supported formats: [GeoJSON](https://geojson.org/) 
* 📃 geospatial data writers for geometries and coordinates:
  * 🪧 supported formats: [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)

🧩 Features:
- [Separate some common features of geocore to separate common package #86](https://github.com/navibyte/geospatial/issues/86)
- [Base interface for bounding boxes compatible with RFC7946 #87](https://github.com/navibyte/geospatial/issues/87)
- [Separate basic point properties as position interface #84](https://github.com/navibyte/geospatial/issues/84)
- [Formatting to text on Point (and other geometries) more flexible #81](https://github.com/navibyte/geospatial/issues/81)
- [Coordinate types enhanced #92](https://github.com/navibyte/geospatial/issues/92)
- [Coordinate value accessors on position classes #94](https://github.com/navibyte/geospatial/issues/94)
- [Equality and hashcode for (Geo)Position and (Geo)Box classes #89](https://github.com/navibyte/geospatial/issues/89)
- [Generalize and move project and transform from geocore to geobase #95](https://github.com/navibyte/geospatial/issues/95)
- [Intersects bounds generalized on geobase #97](https://github.com/navibyte/geospatial/issues/97)
- [Renewed GeoExtent with spatial and temporal parts #99](https://github.com/navibyte/geospatial/issues/99)

🛠 Maintenance:
- [Upgrade to Dart 2.15 #90](https://github.com/navibyte/geospatial/issues/90)
