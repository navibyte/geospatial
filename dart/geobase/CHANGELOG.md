## 1.3.0

NOTE: Version 1.3.0 currently under development (1.3.0-dev.0).

[geobase release 1.3.0](https://github.com/navibyte/geospatial/milestone/5)

🧩 Features:
* [Add visual center point calculations for polygons #237](https://github.com/navibyte/geospatial/issues/237)
* [Centroid2D as available from sub package geometric #240](https://github.com/navibyte/geospatial/issues/240)
* [Add point-in-polygon function #236](https://github.com/navibyte/geospatial/issues/236)
* [Add distance-to-from-point function #238](https://github.com/navibyte/geospatial/issues/238)

🛠 Maintenance:
* Add dependency on the `collections` package (for `PriorityQueue`).
* [New sub package for cartesian calculations #239](https://github.com/navibyte/geospatial/issues/239)

## 1.2.0

[geobase release 1.2.0](https://github.com/navibyte/geospatial/milestone/4)

✨ New (2024-05-26): The new documentation website ([geospatial.navibyte.dev](https://geospatial.navibyte.dev/)) for the [geobase](https://geospatial.navibyte.dev/v1/geobase/)
package documentation published along with the stable version 1.2.0.

🛠 Refactoring:
* [Shorten and streamline package readme docs #234](https://github.com/navibyte/geospatial/issues/234)

No functional changes on classes and functions, but major changes on
documentation with the publication of the new docs website.

## 1.1.0

[geobase release 1.1.0](https://github.com/navibyte/geospatial/milestone/1)

✨ New (2024-04-22): Support for Newline-delimited GeoJSON, EWKT and EWKB added. Check out [the blog post](https://medium.com/@navibyte/decode-and-encode-geojson-wkt-and-wkb-in-dart-and-flutter-apps-ab2ef4ece2f1).

🧩 Features:
* [Enhanced coordinate value output for positions and text data formats #98](https://github.com/navibyte/geospatial/issues/98)
* [Add decodeHex and toBytesHex to geometry objects and builders #227](https://github.com/navibyte/geospatial/issues/227)
* [Add EWKB encoding and decoding support on geobase #165](https://github.com/navibyte/geospatial/issues/165)
* [Add EWKT support](https://github.com/navibyte/geospatial/issues/29)
* [Support for GeoJSON Text Sequences](https://github.com/navibyte/geospatial/issues/217)
* [Centroid for all geometry objects #223](https://github.com/navibyte/geospatial/issues/223)
* [Factories to create multi geometries from geometry lists #229](https://github.com/navibyte/geospatial/issues/229)
* [Item accessor operator and length in geometry and feature collections #230](https://github.com/navibyte/geospatial/issues/230)
* [True dimensionality for geometry #231](https://github.com/navibyte/geospatial/issues/231)

## 1.0.2

🧩 Features:
* [Add Extended WKB or EWKB support #224](https://github.com/navibyte/geospatial/issues/224)
  * Support decoding also EWKB data (no support for accessing an optional srid).
  * These changes on WKB decoder internal logic without any library API changes.
  * Quite extensive tests.
  * Encoding EWKB data not yet implemented (see #165, coming in future version).

## 1.0.1

🐛 Bugs fixed:
* [Bug: special case POINT EMPTY encoding x and y as double.nan in WKB encoder / byte writer #225](https://github.com/navibyte/geospatial/issues/225)

🛠 Maintenance:
* Adding trailing commas to avoid "Missing a required trailing comma" message.
* Small documentation fixes.

## 1.0.0

[geobase version 1.0.0 #175](https://github.com/navibyte/geospatial/issues/175)

✨ New (2023-10): The stable version 1.0.0 is now ready. See also the article [Geospatial tools for Dart - version 1.0 published](https://medium.com/@navibyte/geospatial-tools-for-dart-version-1-0-published-0f9673e510b3) at Medium.

⚠️ Breaking changes:
* [Remove previous deprecations for geobase 1.0.0 #207](https://github.com/navibyte/geospatial/issues/207)
* [Restructure abstract base classes Positionable and Bounded #213](https://github.com/navibyte/geospatial/issues/213)
* [Change signature of TransformPosition typedef #216](https://github.com/navibyte/geospatial/issues/216)

🧩 Features:
* [Handle the special case of bbox or geometries spanning the anti-meridian (longitude 180 degrees) #185](https://github.com/navibyte/geospatial/issues/185)
* [Merge and split on Box #211](https://github.com/navibyte/geospatial/issues/211)
* [PositionScheme for generic, geographic and projected position data #214](https://github.com/navibyte/geospatial/issues/214)
* [Add basic geometry calculation functions #191](https://github.com/navibyte/geospatial/issues/191)
* [Operators in Position, Box and PositionSeries #215](https://github.com/navibyte/geospatial/issues/215)
* [Transform and filter positions and position series #218](https://github.com/navibyte/geospatial/issues/218)
* [Position element manipulation in PositionSeries #219](https://github.com/navibyte/geospatial/issues/219)
* [Enum for dimensionality or topological dimension #220](https://github.com/navibyte/geospatial/issues/220)

🛠 Refactoring:
* [Normalize longitude with inclusive limit on east 180 degrees #210](https://github.com/navibyte/geospatial/issues/210)
* [Move Bounded to coordinates and implement it by PositionSeries #212](https://github.com/navibyte/geospatial/issues/212)
* [Restructure codes and constants sub packages #221](https://github.com/navibyte/geospatial/issues/221)

🚥 Tests:
* [Handle the special case of bbox or geometries containing or touching north (latitude 90 deg) or south (latitude -90 deg) poles #209](https://github.com/navibyte/geospatial/issues/209)

## 0.6.0

[geobase version 0.6.0 #193](https://github.com/navibyte/geospatial/issues/193)

✨ New (2023-09): Optimizing data structures (*Position*, *PositionSeries*, *Box*) used by simple geometries. Fixes, tests and documentation.

🧩 Features:
* [Add copyWith (and map) methods to coordinate, meta, feature and geometry classes #189](https://github.com/navibyte/geospatial/issues/189)
* [Populating and unpopulating bounds in geometries and feature objects #197](https://github.com/navibyte/geospatial/issues/197)
* [Testing feature and geometry equality #188](https://github.com/navibyte/geospatial/issues/188)
* [Factories on Position and Box to create from double arrays #199](https://github.com/navibyte/geospatial/issues/199)
* [Redesigned PositionData supporting positions from coordinate value array and position objects #200](https://github.com/navibyte/geospatial/issues/200)
* [Coordinates using data structures from typed data #203](https://github.com/navibyte/geospatial/issues/203)
* [Position from subview of coordinate value array as doubles #204](https://github.com/navibyte/geospatial/issues/204)
* [PositionSeries and geometries with reversed positions #205](https://github.com/navibyte/geospatial/issues/205)
* [Get a subseries of positions in PositionSeries #206](https://github.com/navibyte/geospatial/issues/206)

⚠️ Breaking changes:
* [Allow a position stored as "Position" in Point, and a bounding box as "Box" in Geometry classes #192](https://github.com/navibyte/geospatial/issues/192)
* [Simplify Feature and FeatureCollection types #195](https://github.com/navibyte/geospatial/issues/195)
* [Remove deprecated types in geobase version 0.6.0 #194](https://github.com/navibyte/geospatial/issues/194)
* [Consistent crs and trs references in meta classes #196](https://github.com/navibyte/geospatial/issues/196)
* [Deprecate PositionArray, PositionCoords and BoxCoords #201](https://github.com/navibyte/geospatial/issues/201)
* [Refactor SimpleGeometryContent #202](https://github.com/navibyte/geospatial/issues/202)

🛠 Refactoring:
* isEmptyByGeometry on Bounded (and feature objects too, not only geometries)

🛠 Maintenance:
* PositionArray, PositionCoords and BoxCoords moved from vector_data to vector
  (and later deprecated by #201).
* Enhanced class documentation and tests.

## 0.5.1

Small document fixes (readme links to assets), no code changes.

## 0.5.0

[geobase version 0.5.0 #161](https://github.com/navibyte/geospatial/issues/174)

✨ New (2023-07): spherical geodesy functions (distance, bearing, destination point, etc.) for *great circle* and *rhumb line* paths.

⚠️ Breaking changes:
* The `WkbConf` class removed, added `buildEmptyGeometries` for WKB decoder.
* `Position` and `Box`: tolerance type from `num?` to `double` (see #146).
* [Remove inheritance of Scalable2i from Projected #183](https://github.com/navibyte/geospatial/issues/183)
* `Measurable` abstract class removed, `isMeasured` defined in `Positionable`.
* [Coordinate values as doubles instead of num #186](https://github.com/navibyte/geospatial/issues/186)

🧩 Features:
* [Add common geospatial and geodesy functions #106](https://github.com/navibyte/geospatial/issues/106)
* [Add parse and format functions for dms representations of degrees #173](https://github.com/navibyte/geospatial/issues/173)
* [Axis order information of coordinate reference systems #178](https://github.com/navibyte/geospatial/issues/178)
* [GeoJSON output for non-default coordinate reference systems #179](https://github.com/navibyte/geospatial/issues/179)
* [WKT decoder on geobase #159](https://github.com/navibyte/geospatial/issues/159)
* [Consistent equals, equals2D, equals3D (and equalsBy) for coordinates, geometries and features #146](https://github.com/navibyte/geospatial/issues/146)
* [Geometry objects instantiated from instances or iterables of Position objects #171](https://github.com/navibyte/geospatial/issues/171)
* [Alternative logics to resolve axis order #182](https://github.com/navibyte/geospatial/issues/182)
* [Handle explicit and implicit bounds in geometries and features on geobase #141](https://github.com/navibyte/geospatial/issues/141)
* [Add project method for Position class #184](https://github.com/navibyte/geospatial/issues/184)
* [Project bounding box #96](https://github.com/navibyte/geospatial/issues/96)

🛠 Refactoring:
* [Enforce "geometry" under "Feature" when encoding GeoJSON text output #91](https://github.com/navibyte/geospatial/issues/91)
* Deprecate XY, XYZ, XYM, XYZM, LonLat, LonLatElev, LonLatM, LonLatElevM special classes extending PositionCoords - to be removed for version 1.0 of the package.

🐛 Bugs fixed:
* [Clipping when projection WGS 84 to Web Mercator metric coordinates #123](https://github.com/navibyte/geospatial/issues/123)

🛠 Maintenance:
* Removed extra internal export files and made internal imports more excplicit.

✍️ In-progress:
* [Geographic string representations (DMS) enhancements #176](https://github.com/navibyte/geospatial/issues/176)
  * DMS lat/lon representatio default separator changed.

## 0.4.2

📚 Documentation updates:
* Readme enhanced with multiple class diagrams.

## 0.4.1

📚 Documentation updates
* An introduction chapter for the readme.

🛠 Maintenance:
* The SDK constraint updated from '>=2.17.0 <3.0.0' to '>=2.17.0 <4.0.0'.

## 0.4.0

[geobase version 0.4.0 #161](https://github.com/navibyte/geospatial/issues/161)

🧩 Features:
* [Add methods to calculate a pixel or a position from tile coordinates in tile matrix sets #158](https://github.com/navibyte/geospatial/issues/158)
* [Add toText and writeValues on Position and Box #153](https://github.com/navibyte/geospatial/issues/153)
* [Calculate zoom from pixel resolution or scale denominator #160](https://github.com/navibyte/geospatial/issues/160)
* [GeoBox.center2D #157](https://github.com/navibyte/geospatial/issues/157) implemented as "aligned2D"

## 0.3.2

📚 Documentation updates.

🛠 Refactoring:
- [Expect XY data in geometry build methods by default #154](https://github.com/navibyte/geospatial/issues/154)

## 0.3.1

📚 Small documentation updates. Also a link to the [Geospatial demos for Dart](https://github.com/navibyte/geospatial_demos) repository.

## 0.3.0

✨ New: Data structures for simple geometries, features and feature collections.
✨ New: Support for [Well-known binary](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary) (WKB). Text and
binary data formats, encodings and content interfaces also redesigned.

⚠️ Breaking changes:
- Content interfaces, content encoders and text formats redesigned
- [Rename writers and content interfaces to generalize #127](https://github.com/navibyte/geospatial/issues/127)
- [Geometry content written with more specific methods #128](https://github.com/navibyte/geospatial/issues/128)
- [Allow coordinate value arrays along with position arrays on content interfaces #129](https://github.com/navibyte/geospatial/issues/129)
- [Simplify Coords enum #130](https://github.com/navibyte/geospatial/issues/130)
- [Type changes on projections and adapters #151](https://github.com/navibyte/geospatial/issues/151)
- [Move "basic transforms" from geobase to geocore #152](https://github.com/navibyte/geospatial/issues/152)

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
- [Decode GeoJSON and build data structures using new data structures by geobase #140](https://github.com/navibyte/geospatial/issues/140)
- [Handle explicit and implicit bounds in geometries and features on geobase](https://github.com/navibyte/geospatial/issues/141)
- [Handle projections and transforms of geometries and features on geobase #142](https://github.com/navibyte/geospatial/issues/142)

🛠 Refactoring:
- [Optimize reading from iterable of coordinate values #131](https://github.com/navibyte/geospatial/issues/131)
- [Feature properties and data maps as Map<String, dynamic> instead of Map<String, Object?> #147](https://github.com/navibyte/geospatial/issues/147)
- [Refactor fromJson / toJson methods on model classes #150](https://github.com/navibyte/geospatial/issues/150)

🛠 Maintenance:
- [Lint rules without old strong mode, but with new "stricter type checks" #148](https://github.com/navibyte/geospatial/issues/148)
- [Mark internal classes with @internal #149](https://github.com/navibyte/geospatial/issues/149)

📚 Documentation
- [Documentation about content builders, geometries and features on geobase #145](https://github.com/navibyte/geospatial/issues/145)

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
