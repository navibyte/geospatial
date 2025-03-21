# :compass: Geospatial tools for Dart 

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/navibyte.svg?style=social&label=Follow%20%40navibyte)](https://twitter.com/navibyte) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis) 

<a title="Stefan Kühn (Fotograf), CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Azimutalprojektion-schief_kl-cropped.png"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/projections/azimutal/Azimutalprojektion-schief_kl-cropped.png" align="right"></a>

**Geospatial** data structures, tools and utilities for 
[Dart](https://dart.dev/) and [Flutter](https://flutter.dev/) - coordinates,
geometries, feature objects, metadata, spherical geodesy, projections, tiling
schemes, vector data models and formats, and geospatial Web APIs.

Read the docs 👉 [geospatial.navibyte.dev](https://geospatial.navibyte.dev/)! 

[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/) [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)

🗺️ [Roadmap 2025: The current state and candidate issues for the geobase package](https://github.com/navibyte/geospatial/issues/254).

✨ New (2025-03-11): The stable version 1.5.0 with [global grids](https://geospatial.navibyte.dev/v1/geobase/global-grids/), better WGS84 [projection](https://geospatial.navibyte.dev/v1/geobase/projections/) support and [unit conversions](https://geospatial.navibyte.dev/v1/geobase/unit-conversions/).

✨ New (2024-11-10): The stable release with [ellipsoidal geodesy functions](https://geospatial.navibyte.dev/v1/geobase/ellipsoidal-geodesy/) letting you calculate distances, bearings, destination positions and intermediate points along the Earth surface accurately.

✨ New (2024-07-26): The stable version 1.3.0 with centroid, polylabel, point-in-polygon and other cartesian 2D calculations enhanced - [read more](https://geospatial.navibyte.dev/v1/geobase/geometry-calculations/)!

## :package: Packages

[Dart](https://dart.dev/) code packages published at 
[pub.dev](https://pub.dev/publishers/navibyte.com/packages):

Code           | Package | Description 
-------------- | --------| -----------
:globe_with_meridians: [geobase](dart/geobase) | [![pub package](https://img.shields.io/pub/v/geobase.svg)](https://pub.dev/packages/geobase) | Geospatial data structures (coordinates, geometries, features, metadata), ellipsoidal and spherical geodesy, projections and tiling schemes. Vector data format support for [GeoJSON](https://geojson.org/), [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) and [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary).
:earth_americas: [geodata](dart/geodata) | [![pub package](https://img.shields.io/pub/v/geodata.svg)](https://pub.dev/packages/geodata) | Geospatial feature service Web APIs with support for [GeoJSON](https://geojson.org/) and [OGC API Features](https://ogcapi.ogc.org/features/) clients.

## 📚 Documentation

Comprehensive guidance on how to use package and about
*Geospatial tools for Dart* is available on the
[geospatial.navibyte.dev](https://geospatial.navibyte.dev/) website.

Overview topics about *Geospatial tools for Dart*:

* [⛳️ Getting started](https://geospatial.navibyte.dev/v1/start/)
* [📖 Introduction](https://geospatial.navibyte.dev/v1/start/intro/)
* [💼 Code project](https://geospatial.navibyte.dev/reference/project/)
* [📚 API documentation](https://geospatial.navibyte.dev/reference/api/)

The [geobase](https://geospatial.navibyte.dev/v1/geobase/)
package documentation by chapters:

* [📍 Coordinates](https://geospatial.navibyte.dev/v1/geobase/coordinates/)
* [🧩 Simple geometries](https://geospatial.navibyte.dev/v1/geobase/geometry/)
* [📏 Geometry calculations](https://geospatial.navibyte.dev/v1/geobase/geometry-calculations/)
* [🔷 Geospatial features](https://geospatial.navibyte.dev/v1/geobase/features/)
* [📃 Vector formats](https://geospatial.navibyte.dev/v1/geobase/formats/)
* [🔵 Ellipsoidal geodesy](https://geospatial.navibyte.dev/v1/geobase/ellipsoidal-geodesy/)
* [📐 Spherical geodesy](https://geospatial.navibyte.dev/v1/geobase/spherical-geodesy/)
* [📅 Metadata](https://geospatial.navibyte.dev/v1/geobase/metadata/)
* [🌐 Global grids](https://geospatial.navibyte.dev/v1/geobase/global-grids/)
* [🗺️ Projections](https://geospatial.navibyte.dev/v1/geobase/projections/)
* [🔢 Tiling schemes](https://geospatial.navibyte.dev/v1/geobase/tiling-schemes/)
* [⚖️ Unit conversions](https://geospatial.navibyte.dev/v1/geobase/unit-conversions/)

The [geodata](https://geospatial.navibyte.dev/v1/geodata/)
package documentation by chapters:

* [🌐 GeoJSON Web API client](https://geospatial.navibyte.dev/v1/geodata/geojson-client/)
* [🌎 OGC API Features client](https://geospatial.navibyte.dev/v1/geodata/ogcfeat-client/)

## :sparkles: Features

Key features of the [geobase](https://pub.dev/packages/geobase) package:

* 🌐 geographic (longitude-latitude) and projected positions and bounding boxes
* 🧩 simple geometries (point, line string, polygon, multi point, multi line string, multi polygon, geometry collection)
* 📏 cartesian 2D calculations (centroid, polylabel, point-in-polygon, distance).
* 🔷 features (with id, properties and geometry) and feature collections
* 📐 ellipsoidal (*vincenty*) and spherical (*great circle*, *rhumb line*) geodesy tools, with ellipsoidal datum, [UTM](https://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system), [MGRS](https://en.wikipedia.org/wiki/Military_Grid_Reference_System) and ECEF (earth-centric earth-fixed) support
* 📅 temporal data structures (instant, interval) and spatial extents
* 📃 vector data formats supported ([GeoJSON](https://geojson.org/), [Newline-delimited GeoJSON](https://stevage.github.io/ndgeojson/), [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry), [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary)
)
* 🗺️ coordinate projections (built-in WGS84 based projections on geographic, geocentric, UTM and Web Mercator coordinates + external [proj4dart](https://pub.dev/packages/proj4dart) support)
* 🔢 tiling schemes and tile matrix sets (web mercator, global geodetic)
* ⚖️ unit conversions (angle, angular velocity, area, distance, speed and time)

Key features of the [geodata](https://pub.dev/packages/geodata) package:

* 🪄 Client-side data source abstraction for geospatial feature service Web APIs.
* 🌐 The [GeoJSON](https://geojson.org/) client to read features from static web resources and local files, supports also [Newline-delimited GeoJSON](https://stevage.github.io/ndgeojson/) data.
* 🌎 The [OGC API Features](https://ogcapi.ogc.org/features/) client to access metadata and feature items from a compliant geospatial Web API providing GeoJSON data.

Client-side support for the OGC API Features standard:

Standard part | Support in this package
------------- | -----------------------
[OGC API - Features - Part 1: Core](https://docs.ogc.org/is/17-069r4/17-069r4.html) | Supported for accessing metadata and GeoJSON feature collections.
[OGC API - Features - Part 2: Coordinate Reference Systems by Reference](https://docs.ogc.org/is/18-058r1/18-058r1.html) | Supported.
[OGC API - Features - Part 3: Filtering](https://docs.ogc.org/is/19-079r2/19-079r2.html)<br/>[Common Query Language (CQL2)](https://docs.ogc.org/is/21-065r2/21-065r2.html) | Partially supported (conformance classes, queryables, features filter).

## :keyboard: Sample code

### Geodesy functions with geobase

*Ellipsoidal* and *spherical* geodesy functions to calculate distances etc.:

```dart
  final greenwich = Geographic.parseDms(lat: '51°28′40″ N', lon: '0°00′05″ W');
  final sydney = Geographic.parseDms(lat: '33.8688° S', lon: '151.2093° E');

  // How to calculate distances using ellipsoidal Vincenty, spherical
  // great-circle and spherical rhumb line methods is shown first.

  // The distance along a geodesic on the ellipsoid surface (16983.3 km).
  greenwich.vincenty().distanceTo(sydney);

  // By default the WGS84 reference ellipsoid is used but this can be changed.
  greenwich.vincenty(ellipsoid: Ellipsoid.GRS80).distanceTo(sydney);

  // The distance along a spherical great-circle path (16987.9 km).
  greenwich.spherical.distanceTo(sydney);

  // The distance along a spherical rhumb line path (17669.8 km).
  greenwich.rhumb.distanceTo(sydney);

  // Also bearings, destination points and mid points (or intermediate points)
  // are provided for all methods, but below shown only for great-circle paths.

  // Destination point (10 km to bearing 61°): 51° 31.3′ N, 0° 07.5′ E
  greenwich.spherical.initialBearingTo(sydney);
  greenwich.spherical.finalBearingTo(sydney);

  // Destination point: 51° 31.3′ N, 0° 07.5′ E
  greenwich.spherical.destinationPoint(distance: 10000, bearing: 61.0);

  // Midpoint: 28° 34.0′ N, 104° 41.6′ E
  greenwich.spherical.midPointTo(sydney);

  // Vincenty ellipsoidal geodesy functions provide also `inverse` and `direct`
  // methods to calculate shortest arcs along a geodesic on the ellipsoid. The
  // returned arc object contains origin and destination points, initial and
  // final bearings, and distance between points.
  greenwich.vincenty().inverse(sydney);
  greenwich.vincenty().direct(distance: 10000, bearing: 61.0);
```

### Geospatial data structures with geobase

As a quick sample, this is how geometry objects with 2D coordinate are created
using [geobase](https://pub.dev/packages/geobase):

Geometry    | Shape       | Dart code to build objects
----------- | ----------- | --------------------------
Point       | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Point.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_Point.svg"></a> | `Point.build([30.0, 10.0])`
LineString  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_LineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_LineString.svg"></a> | `LineString.build([30, 10, 10, 30, 40, 40])`
Polygon     | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_Polygon.svg"></a> | `Polygon.build([[30, 10, 40, 40, 20, 40, 10, 20, 30, 10]])`
Polygon (with a hole) | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_Polygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_Polygon_with_hole.svg"></a> | `Polygon.build([[35, 10, 45, 45, 15, 40, 10, 20, 35, 10], [20, 30, 35, 35, 30, 20, 20, 30]])`
MultiPoint  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPoint.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_MultiPoint.svg"></a> | `MultiPoint.build([[10, 40], [40, 30], [20, 20], [30, 10]])`
MultiLineString  | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiLineString.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_MultiLineString.svg"></a> | `MultiLineString.build([[10, 10, 20, 20, 10, 40], [40, 40, 30, 30, 40, 20, 30, 10]])`
MultiPolygon | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPolygon.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_MultiPolygon.svg"></a> | `MultiPolygon.build([[[30, 20, 45, 40, 10, 40, 30, 20]], [[15, 5, 40, 10, 10, 20, 5, 10, 15, 5]]])`
MultiPolygon (with a hole) | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_MultiPolygon_with_hole.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_MultiPolygon_with_hole.svg"></a> | `MultiPolygon.build([[[40, 40, 20, 45, 45, 30, 40, 40]], [[20, 35, 10, 30, 10, 10, 30, 5, 45, 20, 20, 35], [30, 20, 20, 15, 20, 25, 30, 20]]])`
GeometryCollection | <a title="Mwtoews, CC BY-SA 3.0 &lt;https://creativecommons.org/licenses/by-sa/3.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SFA_GeometryCollection.svg"><img src="https://raw.githubusercontent.com/navibyte/geospatial_docs/v2023-08-12/assets/doc/data/features/SFA_GeometryCollection.svg"></a> | `GeometryCollection([Point.build([30.0, 10.0]), LineString.build([10, 10, 20, 20, 10, 40]), Polygon.build([[40, 40, 20, 45, 45, 30, 40, 40]])])`

Geospatial feature and feature collections can be instantiated easily too:

```dart
  // A geospatial feature collection (with two features):
  FeatureCollection([
    Feature(
      id: 'ROG',
      // a point geometry with a position (lon, lat, elev)
      geometry: Point.build([-0.0014, 51.4778, 45.0]),
      properties: {
        'title': 'Royal Observatory',
        'city': 'London',
        'isMuseum': true,
      },
    ),
    Feature(
      id: 'TB',
      // a point geometry with a position (lon, lat)
      geometry: Point.build([-0.075406, 51.5055]),
      properties: {
        'title': 'Tower Bridge',
        'built': 1886,
      },
    ),
  ]);
```

### GeoJSON, WKT and WKB with geobase

More details in the article (2024-04-14) [Decode and encode GeoJSON, WKT and WKB in Dart and Flutter apps](https://medium.com/@navibyte/decode-and-encode-geojson-wkt-and-wkb-in-dart-and-flutter-apps-ab2ef4ece2f1).

GeoJSON, WKT and WKB formats are supported as input and output:

```dart
  // Parse a geometry from GeoJSON text.
  final geometry = LineString.parse(
    '{"type": "LineString", "coordinates": [[30,10],[10,30],[40,40]]}',
    format: GeoJSON.geometry,
  );

  // Encode a geometry as GeoJSON text.
  print(geometry.toText(format: GeoJSON.geometry));

  // Encode a geometry as WKT text.
  print(geometry.toText(format: WKT.geometry));

  // Encode a geometry as WKB bytes.
  final bytes = geometry.toBytes(format: WKB.geometry);

  // Decode a geometry from WKB bytes.
  LineString.decode(bytes, format: WKB.geometry);
```

A sample showing more deeply how to handle WKB and EWKB binary data:

```dart
  // to get a sample point, first parse a 3D point from WKT encoded string
  final p = Point.parse('POINT Z(-0.0014 51.4778 45)', format: WKT.geometry);

  // to encode a geometry as WKB/EWKB use toBytes() or toBytesHex() methods

  // encode as standard WKB data (format: `WKB.geometry`), prints:
  // 01e9030000c7bab88d06f056bfb003e78c28bd49400000000000804640
  final wkbHex = p.toBytesHex(format: WKB.geometry);
  print(wkbHex);

  // encode as Extended WKB data (format: `WKB.geometryExtended`), prints:
  // 0101000080c7bab88d06f056bfb003e78c28bd49400000000000804640
  final ewkbHex = p.toBytesHex(format: WKB.geometryExtended);
  print(ewkbHex);

  // otherwise encoded data equals, but bytes for the geometry type varies

  // there are some helper methods to analyse WKB/EWKB bytes or hex strings
  // (decodeFlavor, decodeEndian, decodeSRID and versions with hex postfix)

  // prints: "WkbFlavor.standard - WkbFlavor.extended"
  print('${WKB.decodeFlavorHex(wkbHex)} - ${WKB.decodeFlavorHex(ewkbHex)}');

  // when decoding WKB or EWKB data, a variant is detected automatically, so
  // both `WKB.geometry` and `WKB.geometryExtended` can be used
  final pointFromWkb = Point.decodeHex(wkbHex, format: WKB.geometry);
  final pointFromEwkb = Point.decodeHex(ewkbHex, format: WKB.geometry);
  print(pointFromWkb.equals3D(pointFromEwkb)); // prints "true"

  // SRID can be encoded only on EWKB data, this sample prints:
  // 01010000a0e6100000c7bab88d06f056bfb003e78c28bd49400000000000804640
  final ewkbHexWithSRID =
      p.toBytesHex(format: WKB.geometryExtended, crs: CoordRefSys.EPSG_4326);
  print(ewkbHexWithSRID);

  // if you have WKB or EWKB data, but not sure which, then you can fist check
  // a flavor and whether it contains SRID, prints: "SRID from EWKB data: 4326"
  if (WKB.decodeFlavorHex(ewkbHexWithSRID) == WkbFlavor.extended) {
    final srid = WKB.decodeSRIDHex(ewkbHexWithSRID);
    if (srid != null) {
      print('SRID from EWKB data: $srid');

      // after finding out CRS, an actual point can be decoded
      // Point.decodeHex(ewkbHexWithSRID, format: WKB.geometry);
    }
  }
```

Using Newline-delimited GeoJSON (or "GeoJSONL") is as easy as using the
standard GeoJSON:

```dart
  /// a feature collection encoded as GeoJSONL and containing two features that
  /// are delimited by the newline character \n
  const sample = '''
    {"type":"Feature","id":"ROG","geometry":{"type":"Point","coordinates":[-0.0014,51.4778,45]},"properties":{"title":"Royal Observatory","place":"Greenwich"}}
    {"type":"Feature","id":"TB","geometry":{"type":"Point","coordinates":[-0.075406,51.5055]},"properties":{"title":"Tower Bridge","built":1886}}
    ''';

  // parse a FeatureCollection object using the decoder for the GeoJSONL format
  final collection = FeatureCollection.parse(sample, format: GeoJSONL.feature);

  // ... use features read and returned in a feature collection object ...

  // encode back to GeoJSONL data
  print(collection.toText(format: GeoJSONL.feature, decimals: 5));
```

### Access GeoJSON resources with geodata

The [geodata](https://pub.dev/packages/geodata) package has the following
diagram describing a decision flowchart how to select a client class to access
GeoJSON features:

<img src="https://raw.githubusercontent.com/navibyte/geospatial/v0.12.0/dart/geodata/assets/diagrams/decision_flowchart.svg" width="100%" title="Decision flowchart to select a client class to access GeoJSON resources" />

Quick start code to access a Web API service conforming to OGC API Features:

```dart
// 1. Get a client instance for a Web API endpoint.
final client = OGCAPIFeatures.http(endpoint: Uri.parse('...'));

// 2. Access/check metadata (meta, OpenAPI, conformance, collections) as needed.
final conformance = await client.conformance();
if (!conformance.conformsToFeaturesCore(geoJSON: true)) {
  return; // not conforming to core and GeoJSON - so return
}

// 3. Get a feature source for a specific collection.
final source = await client.collection('my_collection');

// 4. Access (and check) metadata for this collection.
final meta = await source.meta();
print('Collection title: ${meta.title}');

// 5. Access feature items.
final items = await source.itemsAll(limit: 100);

// 6. Check response metadata.
print('Timestamp: ${items.timeStamp}');

// 7. Get an iterable of feature objects.
final features = items.collection.features;

// 8. Loop through features (each with id, properties and geometry)
for (final feat in features) {
  print('Feature ${feat.id} with geometry: ${feat.geometry}');
}
```

## :rocket: Demos and samples

More guidance and code examples are provided on the
[geospatial.navibyte.dev](https://geospatial.navibyte.dev/) documentation site.

✨ See also the
[Geospatial demos for Dart](https://github.com/navibyte/geospatial_demos) code
repository for demo and sample apps demonstrating the usage of
[geobase](https://pub.dev/packages/geobase) and
[geodata](https://pub.dev/packages/geodata) packages along with other topics.

Code          | Description 
------------- | -----------
[earthquake_map](https://github.com/navibyte/geospatial_demos/tree/main/earthquake_map) | Shows earthquakes fetched from the [USGS web service](https://earthquake.usgs.gov/earthquakes/feed/) on a basic map view. The demo uses both [geobase](https://pub.dev/packages/geobase) and [geodata](https://pub.dev/packages/geodata) packages for geospatial data accesss. Discusses also state management based on [Riverpod](https://riverpod.dev/). The map UI is based on the [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter) plugin.

## :newspaper_roll: News

2025-03-11
* ✨ The stable version 1.5.0 with [global grids](https://geospatial.navibyte.dev/v1/geobase/global-grids/), better WGS84 [projection](https://geospatial.navibyte.dev/v1/geobase/projections/) support and [unit conversions](https://geospatial.navibyte.dev/v1/geobase/unit-conversions/).
* All docs: [geospatial.navibyte.dev](https://geospatial.navibyte.dev/).
* Published packages at pub.dev:
  * [geobase version 1.5.0](https://pub.dev/packages/geobase/versions/1.5.0)

2024-11-10
* ✨ The stable release with [ellipsoidal geodesy functions](https://geospatial.navibyte.dev/v1/geobase/ellipsoidal-geodesy/) letting you calculate distances, bearings, destination positions and intermediate points along the Earth surface accurately.
* All docs: [geospatial.navibyte.dev](https://geospatial.navibyte.dev/).
* Published packages at pub.dev:
  * [geobase version 1.4.0](https://pub.dev/packages/geobase/versions/1.4.0+1)
  * [geodata version 1.3.0](https://pub.dev/packages/geodata/versions/1.3.0)

2024-07-26
* ✨ The [stable version 1.3.0](https://github.com/navibyte/geospatial/milestone/5) with centroid, polylabel, point-in-polygon and other cartesian 2D calculations enhanced - [read more](https://geospatial.navibyte.dev/v1/geobase/geometry-calculations/)!
* All docs: [geospatial.navibyte.dev](https://geospatial.navibyte.dev/).
* Published packages at pub.dev:
  * [geobase version 1.3.0](https://pub.dev/packages/geobase/versions/1.3.0)

2024-05-26
* ✨ The stable version 1.2.0 with the brand new documentation site published at [geospatial.navibyte.dev](https://geospatial.navibyte.dev/).
* Published packages at pub.dev:
  * [geobase version 1.2.0](https://pub.dev/packages/geobase/versions/1.2.0)
  * [geodata version 1.2.1](https://pub.dev/packages/geodata/versions/1.2.1)

2024-04-22
* ✨ The [stable version 1.1.0](https://github.com/navibyte/geospatial/milestone/1) adds support for Newline-delimited GeoJSON, EWKT and EWKB.
* See also the article [Decode and encode GeoJSON, WKT and WKB in Dart and Flutter apps](https://medium.com/@navibyte/decode-and-encode-geojson-wkt-and-wkb-in-dart-and-flutter-apps-ab2ef4ece2f1).
* Published packages at pub.dev:
  * [geobase version 1.1.0](https://pub.dev/packages/geobase/versions/1.1.0)
  * [geodata version 1.1.0](https://pub.dev/packages/geodata/versions/1.1.0)

2023-10-29
* ✨ The stable version 1.0.0 is now ready. See also the article [Geospatial tools for Dart - version 1.0 published](https://medium.com/@navibyte/geospatial-tools-for-dart-version-1-0-published-0f9673e510b3) at Medium
* [geobase version 1.0.0](https://github.com/navibyte/geospatial/issues/175)
* [geodata version 1.0.0](https://github.com/navibyte/geospatial/issues/187)

See also older news in the [changelog](CHANGELOG.md) of this repository.

## :building_construction: Roadmap

🗺️ [Roadmap 2025: The current state and candidate issues for the geobase package](https://github.com/navibyte/geospatial/issues/254).

🧩 See [open issues](https://github.com/navibyte/geospatial/issues) for planned features, requests for change, and observed bugs.

💡 Any comments, questions, suggestions of new features and other other contributions are welcome, of course!

📚 Documentation: [geospatial.navibyte.dev](https://geospatial.navibyte.dev/)

🪄 Active packages in this repository: 
* [geobase](https://pub.dev/packages/geobase) 
* [geodata](https://pub.dev/packages/geodata) 

⚠️ Not active packages in this repository:
* [geocore](https://pub.dev/packages/geocore)

## :house_with_garden: Authors

This project is authored by [Navibyte](https://navibyte.com).

## :copyright: License

### The project

This project is licensed under the "BSD-3-Clause"-style license.

Please see the [LICENSE](LICENSE).

### Included derivative work

This project contains portions of derivative work: 

* [geobase](dart/geobase): details about [DERIVATIVE](dart/geobase/DERIVATIVE.md) work.

Source repositories used when porting functionality to Dart and this project:
* [geodesy](https://github.com/chrisveness/geodesy) by Chris Veness 2002-2024
* [polylabel](https://github.com/mapbox/polylabel) by Mapbox 2016-2024
* [tinyqueue](https://github.com/mourner/tinyqueue) by Vladimir Agafonkin 2017-2024

## :star: Links and other resources

Some external links and other resources.

### Geospatial data formats and APIs

Geospatial:
* [GeoJSON](https://geojson.org/) based on [RFC 7946](https://tools.ietf.org/html/rfc7946)
* [Newline-delimited GeoJSON](https://stevage.github.io/ndgeojson/) with variants specified elsewhere:
  * [GeoJSONL](https://www.interline.io/blog/geojsonl-extracts/)
  * [GeoJSON Text Sequences](https://datatracker.ietf.org/doc/html/rfc8142)
* [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
* [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) (Well-known text representation of geometry)  
* [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary) (Well-known binary)
* [Coordinate Reference Systems](https://www.w3.org/2015/spatial/wiki/Coordinate_Reference_Systems) by W3C
* [EPSG](https://epsg.org/home.html) (Geodetic Parameter Dataset)
* [World Geodetic System](https://en.wikipedia.org/wiki/World_Geodetic_System), see also [EPSG:4326](https://epsg.io/4326) about WGS 84
* [Web Mercator projection](https://en.wikipedia.org/wiki/Web_Mercator_projection), see also [EPSG:3857](https://epsg.io/3857) and [Bing Maps Tile System](https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system)
* [Geographic coordinate conversion](https://en.wikipedia.org/wiki/Geographic_coordinate_conversion)
* [Geodetic datum](https://en.wikipedia.org/wiki/Geodetic_datum)
* [Ellipsoid](https://en.wikipedia.org/wiki/Ellipsoid)
* [Geodesic](https://en.wikipedia.org/wiki/Geodesic)
* [Geodesic on ellipsoid](https://en.wikipedia.org/wiki/Geodesics_on_an_ellipsoid)
* [Helmert transformation](en.wikipedia.org/wiki/Helmert_transformation)
* [ECEF](https://en.wikipedia.org/wiki/Earth-centered,_Earth-fixed_coordinate_system) (Earth-centered, Earth-fixed coordinate system)
* [UTM](https://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system) (Universal Transverse Mercator)
* [MGRS](https://en.wikipedia.org/wiki/Military_Grid_Reference_System) (Military Grid Reference System)
* [ISO 6709](https://en.wikipedia.org/wiki/ISO_6709) on standard representation of geographic point location by coordinates

OGC (The Open Geospatial Consortium) related:
* [OGC APIs](https://ogcapi.ogc.org/)
  * [OGC API Common](https://ogcapi.ogc.org/common/)
  * [OGC API Features](https://ogcapi.ogc.org/features/)
  * [OGC API Features - demo services](https://github.com/opengeospatial/ogcapi-features/tree/master/implementations)
  * [OGC API Features - github resources](https://github.com/opengeospatial/ogcapi-features)
  * [OGC API Features - schemas](http://schemas.opengis.net/ogcapi/features/)
* [OGC Web API Guidelines](https://github.com/opengeospatial/OGC-Web-API-Guidelines)
* [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
* [OGC Two Dimensional Tile Matrix Set](https://docs.opengeospatial.org/is/17-083r2/17-083r2.html)

W3C
* [Spatial Data on the Web Best Practices](https://www.w3.org/TR/sdw-bp/)
  * [Spatial Things, Features and Geometry](https://www.w3.org/TR/sdw-bp/#spatial-things-features-and-geometry)

The OpenAPI Initiative (OAI) 
* [OpenAPI home](https://www.openapis.org/)
* [OpenAPI specification - latest](https://spec.openapis.org/oas/latest.html)

### Dart and Flutter programming

SDKs:
* [Dart](https://dart.dev/)
* [Flutter](https://flutter.dev/) 

Latest on Dart SDKs
* [Dart 3.7](https://medium.com/dartlang/announcing-dart-3-7-bf864a1b195c) with developer productivity enhancements.
* [Dart 3.6](https://medium.com/dartlang/announcing-dart-3-6-778dd7a80983) with digit separators and new features in the pub ecosystem (pub download counts and pub workspaces)
* [Dart 3.5](https://medium.com/dartlang/dart-3-5-6ca36259fa2f) with improvements in interoperability and an update on the Dart roadmap.
* [Dart 3.4](https://medium.com/dartlang/dart-3-4-bd8d23b4462a) with WebAssembly (WASM) updates and the roadmap for Dart *macros*. 
* [Dart 3.3](https://medium.com/dartlang/dart-3-3-325bf2bf6c13) with extension types,  evolving JavaScript-interoperability and experimental support for WebAssembly.
* [Dart 3.2](https://medium.com/dartlang/dart-3-2-c8de8fe1b91f) with improved language & developer experience.
* [Dart 3](https://medium.com/dartlang/announcing-dart-3-53f065a10635) with 100% sound null safety, new features (records, patterns, and class modifiers), and a peek into the future.
* [Dart 3 alpha](https://medium.com/dartlang/dart-3-alpha-f1458fb9d232) with records, patterns, access controls, portability advancements and the new Dart 3 type system (100% sound null safety)
* [Dart 2.18](https://medium.com/dartlang/dart-2-18-f4b3101f146c) with Objective-C & Swift interop, and improved type inference
* [Dart 2.17](https://medium.com/dartlang/dart-2-17-b216bfc80c5d) with enum member support, parameter forwarding to super classes, flexibility for named parameters, and more
* [Dart 2.16](https://medium.com/dartlang/dart-2-16-improved-tooling-and-platform-handling-dd87abd6bad1) with improved tooling and platform handling
* [Dart 2.15](https://medium.com/dartlang/dart-2-15-7e7a598e508a) with fast concurrency, constructor tear-offs, improved enums, and more
* [Dart 2.14](https://medium.com/dartlang/announcing-dart-2-14-b48b9bb2fb67) with Apple Silicon support, default lints etc.
* [Dart 2.13](https://medium.com/dartlang/announcing-dart-2-13-c6d547b57067) with new type aliases and more
* [Dart 2.12](https://medium.com/dartlang/announcing-dart-2-12-499a6e689c87) with sound null safety

Latest on Flutter SDKs
* [Flutter 3.29](https://medium.com/flutter/whats-new-in-flutter-3-29-f90c380c2317) running on Dart 3.7 and with updates to Impeller, Cupertino and DevTools.
* [Flutter 3.27](https://medium.com/flutter/whats-new-in-flutter-3-27-28341129570c) running on Dart 3.6 and with enhanced Impeller and improvements to Cupertino widgets.
* [Flutter 3.24](https://medium.com/flutter/whats-new-in-flutter-3-24-6c040f87d1e4) running on Dart 3.5 and with Multi-View Embedding and preview on Flutter GPU. 
* [Flutter 3.22](https://medium.com/flutter/whats-new-in-flutter-3-22-fbde6c164fe3) running on Dart 3.4 and stable support for WebAssembly (WASM), Graphics rendering enhancements, and AI updates.
* [Flutter 3.19](https://medium.com/flutter/whats-new-in-flutter-3-19-58b1aae242d2) running on Dart 3.3 and Gemini API integration, Impeller updates, and Windows Arm64 support.
* [Flutter 3.16](https://medium.com/flutter/whats-new-in-flutter-3-16-dba6cb1015d1) running on Dart 3.2 and with Material 3 by default, Impeller preview for Android, etc.
* [Flutter 3.13](https://medium.com/flutter/whats-new-in-flutter-3-13-479d9b11df4d) running on Dart 3.1 and with new 2D scrolling widgets and faster graphics.
* [Flutter 3.10](https://medium.com/flutter/whats-new-in-flutter-3-10-b21db2c38c73) running on Dart 3 and with seamless web and mobile integration, and stable Impleller for iOS.
* [Flutter 3.7](https://medium.com/flutter/whats-new-in-flutter-3-7-38cbea71133c) with Material 3 updates and iOS improvements
* [Flutter 3.3](https://medium.com/flutter/announcing-flutter-3-3-at-flutter-vikings-6f213e068793)
  * [What’s New in Flutter 3.3](https://medium.com/flutter/whats-new-in-flutter-3-3-893c7b9af1ff)
* [Flutter 3](https://medium.com/flutter/introducing-flutter-3-5eb69151622f)

Packages
* [pub.dev](https://pub.dev/)

Dart 3 migration
* [Dart 3 migration guide](https://dart.dev/resources/dart-3-migration)

Null-safety (Dart 2):
* Dart [null-safety](https://dart.dev/null-safety)
* The official [null-safety migration guide](https://dart.dev/null-safety/migration-guide)
* [Preparing the Dart and Flutter ecosystem for null safety](https://medium.com/dartlang/preparing-the-dart-and-flutter-ecosystem-for-null-safety-e550ce72c010)

Guidelines
* [Effective Dart](https://dart.dev/guides/language/effective-dart)

Roadmaps
* [Flutter roadmap](https://github.com/flutter/flutter/wiki/Roadmap)
* [The road to Dart 3: A fully sound, null safe language](https://medium.com/dartlang/the-road-to-dart-3-afdd580fbefa)
* [Dart language evolution](https://dart.dev/guides/language/evolution)
* [Dart SDK milestones](https://github.com/dart-lang/sdk/milestones)
* Waiting for [new features](https://github.com/dart-lang/language/projects/1) on the Dart [language](https://github.com/dart-lang/language) too ...
  * [Patterns and related features #546](https://github.com/dart-lang/language/issues/546)
  * [Type capability modifiers #2242](https://github.com/dart-lang/language/issues/2242)
  * [Inline classes #2727](https://github.com/dart-lang/language/issues/2727)
  * [Static metaprogramming #1482](https://github.com/dart-lang/language/issues/1482) with data classes

### Dart and Flutter libraries

There are thousands of excellent libraries available at 
[pub.dev](https://pub.dev/).

Here listed only those that are used (depended directly) by code packages of
this repository (on the latest release):

Package @ pub.dev | Code @ GitHub | Description
----------------- | ------------- | -----------
[http](https://pub.dev/packages/http) | [dart-lang/http](https://github.com/dart-lang/http) | A composable API for making HTTP requests in Dart.
[meta](https://pub.dev/packages/meta) | [dart-lang/sdk](https://github.com/dart-lang/sdk/tree/master/pkg/meta) | This package defines annotations that can be used by the tools that are shipped with the Dart SDK.
[proj4dart](https://pub.dev/packages/proj4dart) | [maRci002/proj4dart](https://github.com/maRci002/proj4dart) | Proj4dart is a Dart library to transform point coordinates from one coordinate system to another, including datum transformations (Dart version of proj4js/proj4js).
[very_good_analysis](https://pub.dev/packages/very_good_analysis) | [VeryGoodOpenSource/very_good_analysis](https://github.com/VeryGoodOpenSource/very_good_analysis) | Lint rules for Dart and Flutter.

In some previous releases also following are utilized:

Package @ pub.dev | Code @ GitHub | Description
----------------- | ------------- | -----------
[collection](https://pub.dev/packages/collection) | [dart-lang/collection](https://github.com/dart-lang/collection) | Collections and utilities functions and classes related to collections. 
[equatable](https://pub.dev/packages/equatable) | [felangel/equatable](https://github.com/felangel/equatable) | Simplify Equality Comparisons | A Dart abstract class that helps to implement equality without needing to explicitly override == and hashCode.
[synchronized](https://pub.dev/packages/synchronized) | [tekartik/synchronized.dart](https://github.com/tekartik/synchronized.dart/tree/master/synchronized) | Basic lock mechanism to prevent concurrent access to asynchronous code.
