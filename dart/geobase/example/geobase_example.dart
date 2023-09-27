// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, cascade_invocations, lines_longer_than_80_chars, avoid_redundant_argument_values, omit_local_variable_types

import 'package:geobase/geobase.dart';

/*
To test run this from command line: 

dart example/geobase_example.dart
*/

void main() {
  // introduction
  _intro();

  // coordinates
  _positionSeries();
  _geographicCoordinates();
  _geographicCoordinatesDMS();
  _projectedCoordinates();
  _scalableCoordinates();

  // geodesy
  _sphericalGeodesyGreatCircle();
  _sphericalGeodesyRhumbLine();

  // geometries
  _geometryTypes2D();
  _point();
  _lineString();
  _polygon();
  _multiPoint();
  _multiLineString();
  _multiPolygon();
  _geometryCollection();

  // geospatial features
  _feature();
  _featureCollection();

  // meta
  _temporalData();
  _geospatialExtents();

  // vector data
  _geoJsonWithDefaultCRS();
  _geoJsonWithAlternativeCRS();
  _wkt();
  _wkbSample1();
  _wkbSample2();

  // projections
  _wgs84ToWebMercatorViaPositions();
  _wgs84ToWebMercatorViaProjections();
  // see also separate file "geobase_with_proj4d_example.dart"

  // tiling schemes
  _webMercatorQuad();
  _globalGeodeticQuad();
}

void _intro() {
  // Geographic and projected *positions* and *bounding boxes*.

  // A geographic position without and with an elevation.
  Geographic(lon: -0.0014, lat: 51.4778);
  Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0);

  // A projected position without and with z.
  Projected(x: 708221.0, y: 5707225.0);
  Projected(x: 708221.0, y: 5707225.0, z: 45.0);

  // Geographic and projected bounding boxes.
  GeoBox(west: -20, south: 50, east: 20, north: 60);
  GeoBox(west: -20, south: 50, minElev: 100, east: 20, north: 60, maxElev: 200);
  ProjBox(minX: 10, minY: 10, maxX: 20, maxY: 20);

  // Positions and bounding boxes can be also built from an array or parsed.
  Geographic.build([-0.0014, 51.4778]);
  Geographic.parse('-0.0014,51.4778');
  Geographic.parse('-0.0014 51.4778', delimiter: ' ');
  Geographic.parseDms(lon: '0° 00′ 05″ W', lat: '51° 28′ 40″');
  GeoBox.build([-20, 50, 100, 20, 60, 200]);
  GeoBox.parse('-20,50,100,20,60,200');
  GeoBox.parseDms(west: '20°W', south: '50°N', east: '20°E', north: '60°N');

  // -------

  // Coordinates for *pixels* and *tiles* in tiling schemes.

  // Projected coordinates to represent *pixels* or *tiles* in tiling schemes.
  Scalable2i(zoom: 9, x: 23, y: 10);

  // -------

  // Spherical geodesy functions for great circle (shown) and rhumb line paths.

  final greenwich = Geographic.parseDms(lat: '51°28′40″ N', lon: '0°00′05″ W');
  final sydney = Geographic.parseDms(lat: '33.8688° S', lon: '151.2093° E');

  // Distance (~ 16988 km)
  greenwich.spherical.distanceTo(sydney);

  // Destination point (10 km to bearing 61°): 51° 31.3′ N, 0° 07.5′ E
  greenwich.spherical.initialBearingTo(sydney);
  greenwich.spherical.finalBearingTo(sydney);

  // Destination point: 51° 31.3′ N, 0° 07.5′ E
  greenwich.spherical.destinationPoint(distance: 10000, bearing: 61.0);

  // Midpoint: 28° 34.0′ N, 104° 41.6′ E
  greenwich.spherical.midPointTo(sydney);

  // -------

  // Geometry primitive and multi geometry objects.

  // A point with a 2D position.
  Point.build([30.0, 10.0]);

  // A line string (polyline) with three 2D positions.
  LineString.build([30, 10, 10, 30, 40, 40]);

  // A polygon with an exterior ring (and without any holes).
  Polygon.build([
    [30, 10, 40, 40, 20, 40, 10, 20, 30, 10]
  ]);

  // A polygon with an exterior ring and an interior ring as a hole.
  Polygon.build([
    [35, 10, 45, 45, 15, 40, 10, 20, 35, 10],
    [20, 30, 35, 35, 30, 20, 20, 30],
  ]);

  // A multi point with four points:
  MultiPoint.build([
    [10, 40],
    [40, 30],
    [20, 20],
    [30, 10]
  ]);

  // A multi line string with two line strings (polylines):
  MultiLineString.build([
    [10, 10, 20, 20, 10, 40],
    [40, 40, 30, 30, 40, 20, 30, 10]
  ]);

  // A multi polygon with two polygons both with an outer ring (without holes).
  MultiPolygon.build([
    [
      [30, 20, 45, 40, 10, 40, 30, 20],
    ],
    [
      [15, 5, 40, 10, 10, 20, 5, 10, 15, 5],
    ],
  ]);

  // A geometry collection with a point, a line string and a polygon.
  GeometryCollection([
    Point.build([30.0, 10.0]),
    LineString.build([10, 10, 20, 20, 10, 40]),
    Polygon.build([
      [40, 40, 20, 45, 45, 30, 40, 40],
    ])
  ]);

  // -------

  // To distinguish between arrays of different spatial dimensions you can use
  // `Coords` enum.
  LineString.build([30, 10, 10, 30, 40, 40]); // default type == Coords.xy
  LineString.build([30, 10, 10, 30, 40, 40], type: Coords.xy);
  LineString.build([30, 10, 5.5, 10, 30, 5.5, 40, 40, 5.5], type: Coords.xyz);

  // Position iterables can be used for building geomtries too.
  LineString.from([
    Projected(x: 30, y: 10),
    Projected(x: 10, y: 30),
    Projected(x: 40, y: 40),
  ]);
  LineString.from([
    Geographic(lon: 30, lat: 10, elev: 5.5), // x = lon, y = lat, z = elev
    Geographic(lon: 10, lat: 30, elev: 5.5),
    Geographic(lon: 40, lat: 40, elev: 5.5),
  ]);

  // -------

  // GeoJSON, WKT and WKB formats are supported as input and output.

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

  // -------

  // Features represent geospatial entities with properies and geometries.
  Feature(
    id: 'ROG',
    // a point geometry with a position (lon, lat, elev)
    geometry: Point.build([-0.0014, 51.4778, 45.0]),
    properties: {
      'title': 'Royal Observatory',
    },
  );

  // The GeoJSON format is supported as text input and output for features.
  final feature = Feature.parse(
    '''
      { 
        "type": "Feature", 
        "id": "ROG", 
        "geometry": {
          "type": "Point", 
          "coordinates": [-0.0014, 51.4778, 45.0]
        }, 
        "properties": {
          "title": "Royal Observatory"
        }
      }
    ''',
    format: GeoJSON.feature,
  );
  print(feature.toText(format: GeoJSON.feature));
}

void _positionSeries() {
  // A position series with three positions each with x and y coordinates.
  PositionSeries.view(
    [
      10.0, 11.0, // (x, y) for position 0
      20.0, 21.0, // (x, y) for position 1
      30.0, 31.0, // (x, y) for position 2
    ],
    type: Coords.xy,
  );

  // A shortcut to create a position series with three positions (with x and y).
  [
    10.0, 11.0, // (x, y) for position 0
    20.0, 21.0, // (x, y) for position 1
    30.0, 31.0, // (x, y) for position 2
  ].positions(Coords.xy);

  // A position series with three positions each with x, y and z coordinates.
  PositionSeries.view(
    [
      10.0, 11.0, 12.0, // (x, y, z) for position 0
      20.0, 21.0, 22.0, // (x, y, z) for position 1
      30.0, 31.0, 32.0, // (x, y, z) for position 2
    ],
    type: Coords.xyz,
  );
}

void _geographicCoordinates() {
  // A geographic position with longitude and latitude.
  Geographic(lon: -0.0014, lat: 51.4778);

  // A geographic position with longitude, latitude and elevation.
  Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0);

  // A geographic position with longitude, latitude, elevation and measure.
  Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0, m: 123.0);

  // The last sample also from a double list or text (order: lon, lat, elev, m).
  Geographic.build([-0.0014, 51.4778, 45.0, 123.0]);
  Geographic.parse('-0.0014,51.4778,45.0,123.0');
  Geographic.parse('-0.0014 51.4778 45.0 123.0', delimiter: ' ');

  // -------

  // A geographic bbox (-20 .. 20 in longitude, 50 .. 60 in latitude).
  GeoBox(west: -20, south: 50, east: 20, north: 60);

  // A geographic bbox with limits (100 .. 200) on the elevation coordinate too.
  GeoBox(west: -20, south: 50, minElev: 100, east: 20, north: 60, maxElev: 200);

  // The last sample also from a double list or text.
  GeoBox.build([-20, 50, 100, 20, 60, 200]);
  GeoBox.parse('-20,50,100,20,60,200');
}

void _geographicCoordinatesDMS() {
  // A geographic position can also be parsed from sexagesimal degrees (latitude
  // and longitude subdivided to degrees, minutes and seconds).

  // Decimal degrees (DD) with signed numeric degree values.
  Geographic.parseDms(lat: '51.4778', lon: '-0.0014');

  // Decimal degrees (DD) with degree and cardinal direction symbols (N/E/S/W).
  Geographic.parseDms(lat: '51.4778°N', lon: '0.0014°W');

  // Degrees and minutes (DM).
  Geographic.parseDms(lat: '51°28.668′N', lon: '0°00.084′W');

  // Degrees, minutes and seconds (DMS).
  Geographic.parseDms(lat: '51° 28′ 40″ N', lon: '0° 00′ 05″ W');

  // -------

  // Format geographic coordinates as string representations (DD, DM, DMS).

  const p = Geographic(lat: 51.4778, lon: -0.0014);

  // all three samples print decimal degrees: 51.4778°N 0.0014°W
  print(p.latLonDms(separator: ' '));
  print('${p.latDms()} ${p.lonDms()}');
  print('${Dms().lat(51.4778)} ${Dms().lon(-0.0014)}');

  // prints degrees and minutes: 51°28.668′N, 0°00.084′W
  const dm = Dms(type: DmsType.degMin, decimals: 3);
  print(p.latLonDms(format: dm));

  // prints degrees, minutes and seconds: 51° 28′ 40″ N, 0° 00′ 05″ W
  const dms = Dms.narrowSpace(type: DmsType.degMinSec);
  print(p.latLonDms(format: dms));

  // 51 degrees 28 minutes 40 seconds to N, 0 degrees 0 minutes 5 seconds to W
  const dmsTextual = Dms(
    type: DmsType.degMinSec,
    separator: ' ',
    decimals: 0,
    zeroPadMinSec: false,
    degree: ' degrees',
    prime: ' minutes',
    doublePrime: ' seconds to',
  );
  print(p.latLonDms(format: dmsTextual));

  // -------

  // Parsing and formatting is supported also for geographic bounding boxes.

  // Parses box from decimal degrees (DD) with cardinal direction symbols.
  final box =
      GeoBox.parseDms(west: '20°W', south: '50°N', east: '20°E', north: '60°N');

  // prints degrees and minutes: 20°0′W 50°0′N, 20°0′E 60°0′N
  const dm0 = Dms(type: DmsType.degMin, decimals: 0, zeroPadMinSec: false);
  print('${box.westDms(dm0)} ${box.southDms(dm0)}'
      ' ${box.eastDms(dm0)} ${box.northDms(dm0)}');
}

void _projectedCoordinates() {
  // A projected position with x and y.
  Projected(x: 708221.0, y: 5707225.0);

  // A projected position with x, y and z.
  Projected(x: 708221.0, y: 5707225.0, z: 45.0);

  // A projected position with x, y, z and m.
  Projected(x: 708221.0, y: 5707225.0, z: 45.0, m: 123.0);

  // The last sample also from a double list or text (order: x, y, z, m).
  Projected.build([708221.0, 5707225.0, 45.0, 123.0]);
  Projected.parse('708221.0,5707225.0,45.0,123.0');
  Projected.parse('708221.0 5707225.0 45.0 123.0', delimiter: ' ');

  // -------

  // A projected bbox with limits on x and y.
  ProjBox(minX: 10, minY: 10, maxX: 20, maxY: 20);

  // A projected bbox with limits on x, y and z.
  ProjBox(minX: 10, minY: 10, minZ: 10, maxX: 20, maxY: 20, maxZ: 20);

  // The last sample also from a double list or text.
  ProjBox.build([10, 10, 10, 20, 20, 20]);
  ProjBox.parse('10,10,10,20,20,20');
}

void _scalableCoordinates() {
  // A pixel with a zoom level (or LOD = level of detail) coordinates.
  const pixel = Scalable2i(zoom: 9, x: 23, y: 10);

  // Such coordinates can be scaled to other zoom levels.
  pixel.zoomIn(); // => Scalable2i(zoom: 10, x: 46, y: 20);
  pixel.zoomOut(); // => Scalable2i(zoom: 8, x: 11, y: 5);
  pixel.zoomTo(13); // => Scalable2i(zoom: 13, x: 368, y: 160));
}

void _sphericalGeodesyGreatCircle() {
  // sample geographic positions
  final greenwich = Geographic.parseDms(lat: '51°28′40″ N', lon: '0°00′05″ W');
  final sydney = Geographic.parseDms(lat: '33.8688° S', lon: '151.2093° E');

  // decimal degrees (DD) and degrees-minutes (DM) formats
  const dd = Dms(decimals: 0);
  const dm = Dms.narrowSpace(type: DmsType.degMin, decimals: 1);

  // prints: 16988 km
  final distanceKm = greenwich.spherical.distanceTo(sydney) / 1000.0;
  print('${distanceKm.toStringAsFixed(0)} km');

  // prints (bearing varies along the great circle path): 61° -> 139°
  final initialBearing = greenwich.spherical.initialBearingTo(sydney);
  final finalBearing = greenwich.spherical.finalBearingTo(sydney);
  print('${dd.bearing(initialBearing)} -> ${dd.bearing(finalBearing)}');

  // prints: 51° 31.3′ N, 0° 07.5′ E
  final destPoint =
      greenwich.spherical.destinationPoint(distance: 10000, bearing: 61.0);
  print(destPoint.latLonDms(format: dm));

  // prints: 28° 34.0′ N, 104° 41.6′ E
  final midPoint = greenwich.spherical.midPointTo(sydney);
  print(midPoint.latLonDms(format: dm));

  // prints 10 intermediate points, like fraction 0.6: 16° 14.5′ N, 114° 29.3′ E
  for (var fr = 0.0; fr < 1.0; fr += 0.1) {
    final ip = greenwich.spherical.intermediatePointTo(sydney, fraction: fr);
    print('${fr.toStringAsFixed(1)}: ${ip.latLonDms(format: dm)}');
  }

  // prints: 0° 00.0′ N, 125° 19.0′ E
  final intersection = greenwich.spherical.intersectionWith(
    bearing: 61.0,
    other: const Geographic(lat: 0.0, lon: 179.0),
    otherBearing: 270.0,
  );
  if (intersection != null) {
    print(intersection.latLonDms(format: dm));
  }
}

void _sphericalGeodesyRhumbLine() {
  // sample geographic positions
  final greenwich = Geographic.parseDms(lat: '51°28′40″ N', lon: '0°00′05″ W');
  final sydney = Geographic.parseDms(lat: '33.8688° S', lon: '151.2093° E');

  // decimal degrees (DD) and degrees-minutes (DM) formats
  const dd = Dms(decimals: 0);
  const dm = Dms.narrowSpace(type: DmsType.degMin, decimals: 1);

  // prints: 17670 km
  final distanceKm = greenwich.rhumb.distanceTo(sydney) / 1000.0;
  print('${distanceKm.toStringAsFixed(0)} km');

  // prints (bearing remains the same along the rhumb line path): 122° -> 122°
  final initialBearing = greenwich.rhumb.initialBearingTo(sydney);
  final finalBearing = greenwich.rhumb.finalBearingTo(sydney);
  print('${dd.bearing(initialBearing)} -> ${dd.bearing(finalBearing)}');

  // prints: 51° 25.8′ N, 0° 07.3′ E
  final destPoint =
      greenwich.spherical.destinationPoint(distance: 10000, bearing: 122.0);
  print(destPoint.latLonDms(format: dm));

  // prints: 8° 48.3′ N, 80° 44.0′ E
  final midPoint = greenwich.rhumb.midPointTo(sydney);
  print(midPoint.latLonDms(format: dm));
}

void _geometryTypes2D() {
  // point (with a position)
  Point.build([30.0, 10.0]);

  // line string (with a chain)
  LineString.build([30, 10, 10, 30, 40, 40]);

  // polygon (with an exterior ring)
  Polygon.build([
    [30, 10, 40, 40, 20, 40, 10, 20, 30, 10],
  ]);

  // polygon (with an exterior ring and one interior ring as a hole)
  Polygon.build(
    [
      [35, 10, 45, 45, 15, 40, 10, 20, 35, 10],
      [20, 30, 35, 35, 30, 20, 20, 30],
    ],
  );

  // multi point (with four points)
  MultiPoint.build(
    [
      [10, 40],
      [40, 30],
      [20, 20],
      [30, 10],
    ],
  );

  // multi line string (with two line strings)
  MultiLineString.build(
    [
      [10, 10, 20, 20, 10, 40],
      [40, 40, 30, 30, 40, 20, 30, 10],
    ],
  );

  // multi polygon (with two polygons)
  MultiPolygon.build(
    [
      [
        [30, 20, 45, 40, 10, 40, 30, 20],
      ],
      [
        [15, 5, 40, 10, 10, 20, 5, 10, 15, 5],
      ],
    ],
  );

  // multi polygon (with one polygon without a hole, and another with a hole)
  MultiPolygon.build(
    [
      [
        [40, 40, 20, 45, 45, 30, 40, 40],
      ],
      [
        [20, 35, 10, 30, 10, 10, 30, 5, 45, 20, 20, 35],
        [30, 20, 20, 15, 20, 25, 30, 20],
      ],
    ],
  );

  // geometry collection (with point, line string and polygon geometries)
  GeometryCollection([
    Point.build([30.0, 10.0]),
    LineString.build([10, 10, 20, 20, 10, 40]),
    Polygon.build([
      [40, 40, 20, 45, 45, 30, 40, 40],
    ])
  ]);
}

/*
void _geometryTypesOneliners() {
  // same samples as in "_geometryTypes" but formatted to fit README table

  // point (with a position)
  Point.build([30.0, 10.0]);

  // line string (with a chain)
  LineString.build([30, 10, 10, 30, 40, 40]);

  // polygon (with an exterior ring)
  Polygon.build([[30, 10, 40, 40, 20, 40, 10, 20, 30, 10]]);

  // polygon (with an exterior ring and one interior ring as a hole)
  Polygon.build([[35, 10, 45, 45, 15, 40, 10, 20, 35, 10], [20, 30, 35, 35, 30, 20, 20, 30]]);

  // multi point (with four points)
  MultiPoint.build([[10, 40], [40, 30], [20, 20], [30, 10]]);

  // multi line string (with two line strings)
  MultiLineString.build([[10, 10, 20, 20, 10, 40], [40, 40, 30, 30, 40, 20, 30, 10]]);

  // multi polygon (with two polygons)
  MultiPolygon.build([[[30, 20, 45, 40, 10, 40, 30, 20]], [[15, 5, 40, 10, 10, 20, 5, 10, 15, 5]]]);

  // multi polygon (with one polygon without a hole, and another with a hole)
  MultiPolygon.build([[[40, 40, 20, 45, 45, 30, 40, 40]], [[20, 35, 10, 30, 10, 10, 30, 5, 45, 20, 20, 35], [30, 20, 20, 15, 20, 25, 30, 20]]]);

  // geometry collection (with point, line string and polygon geometries)
  GeometryCollection([Point.build([30.0, 10.0]), LineString.build([10, 10, 20, 20, 10, 40], type: Coords.xy), Polygon.build([[40, 40, 20, 45, 45, 30, 40, 40]])]);
}
*/

void _point() {}

void _lineString() {
  // A line string with 3 points (2D coordinates with x and y).
  LineString.from([
    Projected(x: 30, y: 10),
    Projected(x: 10, y: 30),
    Projected(x: 40, y: 40),
  ]);

  // A line string with 3 points (3D coordinates with x, y and z).
  LineString.from([
    Geographic(lon: 30, lat: 10, elev: 5.5), // x = lon, y = lat, z = elev
    Geographic(lon: 10, lat: 30, elev: 5.5),
    Geographic(lon: 40, lat: 40, elev: 5.5),
  ]);

  // A line string with 3 points (3D and measured coordinates: x, y, z and m).
  LineString.from([
    Projected(x: 30, y: 10, z: 5.5, m: 3.1),
    Projected(x: 10, y: 30, z: 5.5, m: 3.2),
    Projected(x: 40, y: 40, z: 5.5, m: 3.3),
  ]);
}

void _polygon() {}

void _multiPoint() {}

void _multiLineString() {}

void _multiPolygon() {}

void _geometryCollection() {}

void _feature() {
  // A geospatial feature with id, a point geometry and properties.
  Feature(
    id: 'ROG',
    // a point geometry with a position (lon, lat, elev)
    geometry: Point.build([-0.0014, 51.4778, 45.0]),
    properties: {
      'title': 'Royal Observatory',
      'place': 'Greenwich',
      'city': 'London',
      'isMuseum': true,
      'measure': 5.79,
    },
  );
}

void _featureCollection() {
  // A geospatial feature collection (with two features):
  FeatureCollection([
    Feature(
      id: 'ROG',
      // a point geometry with a position (lon, lat, elev)
      geometry: Point.build([-0.0014, 51.4778, 45.0]),
      properties: {
        'title': 'Royal Observatory',
        'place': 'Greenwich',
        'city': 'London',
        'isMuseum': true,
        'measure': 5.79,
      },
    ),
    Feature(
      id: 'TB',
      // a point geometry with a position (lon, lat)
      geometry: Point.build([-0.075406, 51.5055]),
      properties: {
        'title': 'Tower Bridge',
        'city': 'London',
        'built': 1886,
      },
    ),
  ]);
}

void _geoJsonWithDefaultCRS() {
  // build a LineString sample geometry
  final lineString = LineString.build(
    [-1.1, -1.1, 2.1, -2.5, 3.5, -3.49],
    type: Coords.xy,
    bounds: [-1.1, -3.49, 3.5, -1.1].box,
  );

  // ... and print it as GeoJSON text:
  //   {
  //     "type":"LineString",
  //     "bbox":[-1.1,-3.49,3.5,-1.1],
  //     "coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]
  //   }
  print(lineString.toText(format: GeoJSON.geometry));

  // GeoJSON representation for other geometries, features and feature
  // collections can be produced with `toText` methdod also.

  // here a Feature is printed as GeoJSON text (with 3 decimals on doubles):
  //   {
  //     "type":"Feature",
  //     "id":"TB",
  //     "geometry":{"type":"Point","coordinates":[-0.075,51.505]},
  //     "properties":{"title":"Tower Bridge","city":"London","built":1886}
  //   }
  final feature = Feature(
    id: 'TB',
    geometry: Point.build([-0.075406, 51.5055]),
    properties: {
      'title': 'Tower Bridge',
      'city': 'London',
      'built': 1886,
    },
  );
  print(feature.toText(format: GeoJSON.feature, decimals: 3));

  // -------

  // sample GeoJSON text representation (a feature collection with two features)
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
            "place": "Greenwich"
          }
        }, 
        {
          "type": "Feature",
          "id": "TB",
          "geometry": {
            "type": "Point",
            "coordinates": [-0.075406, 51.5055]  
          },
          "properties": {
            "title": "Tower Bridge",
            "built": 1886
          }
        } 
      ]
    }
  ''';

  // parse a FeatureCollection object using the decoder of the GeoJSON format
  final collection = FeatureCollection.parse(sample, format: GeoJSON.feature);

  // loop through features and print id, geometry and properties for each
  for (final feature in collection.features) {
    print('Feature with id: ${feature.id}');
    print('  geometry: ${feature.geometry}');
    print('  properties:');
    for (final key in feature.properties.keys) {
      print('    $key: ${feature.properties[key]}');
    }
  }
}

void _geoJsonWithAlternativeCRS() {
  // CRS for geographic coordinates with latitude before longitude in GeoJSON.
  const epsg4326 = CoordRefSys.EPSG_4326;

  // Read GeoJSON content with coordinate order: longitude, latitude, elevation.
  final point1 = Point.parse(
    '{"type": "Point", "coordinates": [-0.0014, 51.4778, 45.0]}',
    // no CRS must be specified for the default coordinate reference system:
    // `CoordRefSys.CRS84` or `http://www.opengis.net/def/crs/OGC/1.3/CRS84`
  );
  final pos1 = Geographic.from(point1.position);
  // prints: Point1: lon: 0.0014°W lat: 51.4778°N
  print('Point1: lon: ${pos1.lonDms()} lat: ${pos1.latDms()}');

  // Read GeoJSON content with coordinate order: latitude, longitude, elevation.
  final point2 = Point.parse(
    '{"type": "Point", "coordinates": [51.4778, -0.0014, 45.0]}',
    crs: epsg4326, // CRS must be explicitely specified
  );
  final pos2 = Geographic.from(point2.position);
  // prints: Point2: lon: 0.0014°W lat: 51.4778°N
  print('Point2: lon: ${pos2.lonDms()} lat: ${pos2.latDms()}');

  // Both `point1` and `point2` store coordinates internally in this order:
  // longitude, latitude, elevation.

  // Writing GeoJSON without crs information expects longitude-latitude order.
  // Prints: {"type":"Point","coordinates":[-0.0014,51.4778,45.0]}
  print(point2.toText(format: GeoJSON.geometry));

  // Writing with crs (EPSG:4326) results in latitude-longitude order.
  // Prints: {"type":"Point","coordinates":[51.4778,-0.0014,45.0]}
  print(point2.toText(format: GeoJSON.geometry, crs: epsg4326));
}

void _wkt() {
  // parse a Point geometry from WKT text
  final point = Point.parse(
    'POINT ZM(10.123 20.25 -30.95 -1.999)',
    format: WKT.geometry,
  );

  // format it (back) as WKT text that is printed:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(point.toText(format: WKT.geometry));

  // -------

  // if geometry type is not known when parsing text from external datasources,
  // you can use `GeometryBuilder` to parse geometries of any type

  const geometriesWkt = [
    'POINT Z(10.123 20.25 -30.95)',
    'LINESTRING(-1.1 -1.1, 2.1 -2.5, 3.5 -3.49)',
  ];
  for (final geomWkt in geometriesWkt) {
    // parse geometry (Point and LineString inherits from Geometry)
    final Geometry geom = GeometryBuilder.parse(geomWkt, format: WKT.geometry);

    if (geom is Point) {
      // do something with point geometry
    } else if (geom is LineString) {
      // do something with line string geometry
    }
  }

  // -------

  // It's possible to encode geometry data as WKT text also without creating
  // geometry objects first. However this requires accessing an encoder instance
  // from the WKT format, and then writing content to that encoder.

  // geometry text format encoder for WKT
  const format = WKT.geometry;
  final encoder = format.encoder();

  // prints:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  encoder.writer.point(
    [10.123, 20.25, -30.95, -1.999].xyzm,
  );
  print(encoder.toText());
}

void _wkbSample1() {
  // geometry binary format encoder for WKB
  const format = WKB.geometry;
  final encoder = format.encoder();

  // write geometries (here only point) to content writer of the encoder
  encoder.writer.point(
    [10.123, 20.25, -30.95, -1.999].xyzm,
  );

  // get encoded bytes (Uint8List) and Base64 encoded text (String)
  final wkbBytes = encoder.toBytes();
  final wkbBytesAsBase64 = encoder.toText();

  // prints (point encoded to WKB binary data, formatted as Base64 text):
  //    AAAAC7lAJD752yLQ5UA0QAAAAAAAwD7zMzMzMzO///vnbItDlg==
  print(wkbBytesAsBase64);

  // next decode this WKB binary data and use WKT text format encoder as target

  // geometry text format encoder for WKT
  final wktEncoder = WKT.geometry.encoder();

  // geometry binary format decoder for WKB
  // (with content writer of the WKT encoder set as a target for decoding)
  final decoder = WKB.geometry.decoder(wktEncoder.writer);

  // now decode those WKB bytes (Uint8List) created already at the start
  decoder.decodeBytes(wkbBytes);

  // finally print WKT text:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(wktEncoder.toText());
}

/// The previous sample ("_wkbSample1") using geometry model objects.
void _wkbSample2() {
  // create a Point object
  final point = Point.build([10.123, 20.25, -30.95, -1.999]);

  // get encoded bytes (Uint8List)
  final wkbBytes = point.toBytes(format: WKB.geometry);

  // at this point our WKB bytes could be sent to another system...

  // then create a Point object, but now decoding it from WKB bytes
  final pointDecoded = Point.decode(wkbBytes, format: WKB.geometry);

  // finally print WKT text:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(pointDecoded.toText(format: WKT.geometry));

  // -------

  // or as a bonus of this solution it's as easy to print it as GeoJSON text too
  //    {"type":"Point","coordinates":[10.123,20.25,-30.95,-1.999]}
  print(pointDecoded.toText(format: GeoJSON.geometry));

  // great, but, we just forgot that GeoJSON should not contain m coordinates...
  //    {"type":"Point","coordinates":[10.123,20.25,-30.95]}
  print(
    pointDecoded.toText(
      format: GeoJSON.geometryFormat(conf: GeoJsonConf(ignoreMeasured: true)),
    ),
  );
}

void _temporalData() {
  // Instants can be created from `DateTime` or parsed from text.
  Instant(DateTime.utc(2020, 10, 31, 09, 30));
  Instant.parse('2020-10-31 09:30Z');

  // Intervals (open-started, open-ended, closed).
  Interval.openStart(DateTime.utc(2020, 10, 31));
  Interval.openEnd(DateTime.utc(2020, 10, 01));
  Interval.closed(DateTime.utc(2020, 10, 01), DateTime.utc(2020, 10, 31));

  // Same intervals parsed (by the "start/end" format, ".." for open limits).
  Interval.parse('../2020-10-31');
  Interval.parse('2020-10-01/..');
  Interval.parse('2020-10-01/2020-10-31');
}

void _geospatialExtents() {
  // An extent with spatial (WGS 84 longitude-latitude) and temporal parts.
  GeoExtent.single(
    crs: CoordRefSys.CRS84,
    bbox: GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0),
    interval: Interval.parse('../2020-10-31'),
  );

  // An extent with multiple spatial bounds and temporal interval segments.
  GeoExtent.multi(
    crs: CoordRefSys.CRS84,
    boxes: [
      GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0),
      GeoBox(west: 40.0, south: 50.0, east: 60.0, north: 60.0),
    ],
    intervals: [
      Interval.parse('2020-10-01/2020-10-05'),
      Interval.parse('2020-10-27/2020-10-31'),
    ],
  );
}

void _wgs84ToWebMercatorViaPositions() {
  // Built-in coordinate projections (currently only between WGS 84 and
  // Web Mercator)

  // Sample point as geographic coordinates.
  const geographic = Geographic(lon: -0.0014, lat: 51.4778);

  // Geographic (WGS 84 longitude-latitude) to Projected (WGS 84 Web Mercator).
  final forward = WGS84.webMercator.forward;
  final projected = geographic.project(forward);

  // Projected (WGS 84 Web Mercator) to Geographic (WGS 84 longitude-latitude).
  final inverse = WGS84.webMercator.inverse;
  final unprojected = projected.project(inverse);

  print('${unprojected.toText(decimals: 5)}'
      ' <=> ${projected.toText(decimals: 5)}');
}

void _wgs84ToWebMercatorViaProjections() {
  // Built-in coordinate projections (currently only between WGS 84 and
  // Web Mercator)

  // Geographic (WGS 84 longitude-latitude) to Projected (WGS 84 Web Mercator)
  final forward = WGS84.webMercator.forward;
  final projected = forward.project(
    const Geographic(lon: -0.0014, lat: 51.4778),
    to: Projected.create,
  );

  // Projected (WGS 84 Web Mercator) to Geographic (WGS 84 longitude-latitude)
  final inverse = WGS84.webMercator.inverse;
  final unprojected = inverse.project(
    projected,
    to: Geographic.create,
  );

  print('${unprojected.toText(decimals: 5)}'
      ' <=> ${projected.toText(decimals: 5)}');
}

/// "Web Mercator Quad" tile matrix set.
///
/// [OGC Two Dimensional Tile Matrix Set](https://docs.opengeospatial.org/is/17-083r2/17-083r2.html):
/// "Level 0 allows representing most of the world (limited to latitudes
/// between approximately ±85 degrees) in a single tile of 256x256 pixels
/// (Mercator projection cannot cover the whole world because mathematically
/// the poles are at infinity). The next level represents most of the world
/// in 2x2 tiles of 256x256 pixels and so on in powers of 2. Mercator
/// projection distorts the pixel size closer to the poles. The pixel sizes
/// provided here are only valid next to the equator."
///
/// Using "Web Mercator Quad" involves following coordinates:
/// * *position*: geographic coordinates (longitude, latitude)
/// * *world*: a position projected to the pixel space of the map at level 0
/// * *pixel*: pixel coordinates (x, y) in the pixel space of the map at zoom
/// * *tile*: tile coordinates (x, y) in the tile matrix at zoom
void _webMercatorQuad() {
  // "WebMercatorQuad" tile matrix set with 256 x 256 pixel tiles and with
  // "top-left" origin for the tile matrix and map pixel space
  const quad = WebMercatorQuad.epsg3857();

  // source position as geographic coordinates
  const position = Geographic(lon: -0.0014, lat: 51.4778);

  // get world, tile and pixel coordinates for a geographic position
  print(
    quad.positionToWorld(position).toText(decimals: 6),
  ); // ~ x=127.999004 y=85.160341
  print(quad.positionToTile(position, zoom: 2)); // zoom=2 x=1 y=1
  print(quad.positionToPixel(position, zoom: 2)); // zoom=2 x=511 y=340
  print(quad.positionToPixel(position, zoom: 4)); // zoom=4 x=2047 y=1362

  // world coordinates can be instantiated as projected coordinates
  // x range: (0.0, 256.0) / y range: (0.0, 256.0)
  const world = Projected(x: 127.99900444444444, y: 85.16034098329446);

  // from world coordinates to tile and pixel coordinates
  print(quad.worldToTile(world, zoom: 2)); // zoom=2 x=1 y=1
  print(quad.worldToPixel(world, zoom: 2)); // zoom=2 x=511 y=340
  print(quad.worldToPixel(world, zoom: 4)); // zoom=4 x=2047 y=1362

  // tile and pixel coordinates with integer values can be defined too
  const tile = Scalable2i(zoom: 2, x: 1, y: 1);
  const pixel = Scalable2i(zoom: 2, x: 511, y: 340);

  // tile and pixel coordinates can be zoomed (scaled to other level of details)
  print(pixel.zoomIn()); // zoom=3 x=1022 y=680
  print(pixel.zoomOut()); // zoom=1 x=255 y=170

  // get tile bounds and pixel position (accucy lost) as geographic coordinates
  print(quad.tileToBounds(tile)); // west: -90 south: 0 east: 0 north: 66.51326
  print(quad.pixelToPosition(pixel)); // longitude: -0.17578 latitude: 51.50874

  // world coordinates returns geographic positions still accurately
  print(quad.worldToPosition(world)); // longitude: -0.00140 latitude: 51.47780

  // aligned points (world, pixel and position coordinates) inside tile or edges
  print(quad.tileToWorld(tile, align: Aligned.northWest));
  print(quad.tileToPixel(tile, align: Aligned.center));
  print(quad.tileToPosition(tile, align: Aligned.center));
  print(quad.tileToPosition(tile, align: Aligned.southEast));

  // get zoomed tile at the center of a source tile
  final centerOfTile2 = quad.tileToWorld(tile, align: Aligned.center);
  final tile7 = quad.worldToTile(centerOfTile2, zoom: 7);
  print('tile at zoom 2: $tile => center of tile: $centerOfTile2 '
      '=> tile at zoom 7: $tile7');

  // a quad key is a string identifier for tiles
  print(quad.tileToQuadKey(tile)); // "03"
  print(quad.quadKeyToTile('03')); // zoom=2 x=1 y=1
  print(quad.quadKeyToTile('0321')); // zoom=4 x=5 y=6

  // tile size and map bounds can be checked dynamically
  print(quad.tileSize); // 256
  print(quad.mapBounds()); // ~ west: -180 south: -85.05 east: 180 north: 85.05

  // matrix width and height tells number of tiles in a given zoom level
  print('${quad.matrixWidth(2)} x ${quad.matrixHeight(2)}'); // 4 x 4
  print('${quad.matrixWidth(10)} x ${quad.matrixHeight(10)}'); // 1024 x 1024

  // map width and height tells number of pixels in a given zoom level
  print('${quad.mapWidth(2)} x ${quad.mapHeight(2)}'); // 1024 x 1024
  print('${quad.mapWidth(10)} x ${quad.mapHeight(10)}'); // 262144 x 262144

  // ground resolutions and scale denominator for zoom level 10 at the Equator
  print(quad.tileGroundResolution(10)); // ~ 39135.76 (meters)
  print(quad.pixelGroundResolution(10)); // ~ 152.87 (meters)
  print(quad.scaleDenominator(10)); // ~ 545978.77

  // inverse: zoom from ground resolution and scale denominator
  print(quad.zoomFromPixelGroundResolution(152.87)); // ~ 10.0 (double value)
  print(quad.zoomFromScaleDenominator(545978.77)); // ~ 10.0 (double value)

  // ground resolutions and scale denominator for zoom level 10 at lat 51.4778
  print(quad.pixelGroundResolutionAt(latitude: 51.4778, zoom: 10)); // ~ 95.21
  print(quad.scaleDenominatorAt(latitude: 51.4778, zoom: 10)); // ~ 340045.31

  // inverse: zoom from ground resolution and scale denominator at lat 51.4778
  print(
    quad.zoomFromPixelGroundResolutionAt(
      latitude: 51.4778,
      resolution: 95.21,
    ),
  ); // ~ 10.0 (double value)
  print(
    quad.zoomFromScaleDenominatorAt(
      latitude: 51.4778,
      denominator: 340045.31,
    ),
  ); // ~ 10.0 (double value)
}

/// "Global Geodetic Quad" tile matrix set ("World CRS84 Quad" for WGS 84).
///
/// Tiles are defined in the Equirectangular Plate Carrée projection in the
/// CRS84 coordinate reference system (longitude, latitude) for the whole
/// world. At the zoom level 0 the world is covered by two tiles (tile matrix
/// width is 2 and matrix height is 1). The western tile (x=0, y=0) is for the
/// negative longitudes and the eastern tile (x=1, y=0) for the positive
/// longitudes.
///
/// Using "Global Geodetic Quad" involves following coordinates:
/// * *position*: geographic coordinates (longitude, latitude)
/// * *world*: a position scaled to the pixel space of the map at level 0
/// * *pixel*: pixel coordinates (x, y) in the pixel space of the map at zoom
/// * *tile*: tile coordinates (x, y) in the tile matrix at zoom
void _globalGeodeticQuad() {
  // "World CRS 84" tile matrix set with 256 x 256 pixel tiles and with
  // "top-left" origin for the tile matrix and map pixel space
  const quad = GlobalGeodeticQuad.worldCrs84();

  // source position as geographic coordinates
  const position = Geographic(lon: -0.0014, lat: 51.4778);

  // get world, tile and pixel coordinates for a geographic position
  print(
    quad.positionToWorld(position).toText(decimals: 6),
  ); // ~ x=255.998009 y=54.787129
  print(quad.positionToTile(position, zoom: 2)); // zoom=2 x=3 y=0
  print(quad.positionToPixel(position, zoom: 2)); // zoom=2 x=1023 y=219
  print(quad.positionToPixel(position, zoom: 4)); // zoom=4 x=4095 y=876

  // world coordinates can be instantiated as projected coordinates
  // x range: (0.0, 512.0) / y range: (0.0, 256.0)
  const world = Projected(x: 255.99800888888888, y: 54.78712888888889);

  // from world coordinates to tile and pixel coordinates
  print(quad.worldToTile(world, zoom: 2)); // zoom=2 x=3 y=0
  print(quad.worldToPixel(world, zoom: 2)); // zoom=2 x=1023 y=219
  print(quad.worldToPixel(world, zoom: 4)); //  zoom=4 x=4095 y=876

  // tile and pixel coordinates with integer values can be defined too
  const tile = Scalable2i(zoom: 2, x: 3, y: 0);
  const pixel = Scalable2i(zoom: 2, x: 1023, y: 219);

  // get tile bounds and pixel position (accucy lost) as geographic coordinates
  print(quad.tileToBounds(tile)); // west: -45 south: 45 east: 0 north: 90
  print(quad.pixelToPosition(pixel)); // longitude: -0.08789 latitude: 51.41602

  // world coordinates returns geographic positions still accurately
  print(quad.worldToPosition(world)); // longitude: -0.00140 latitude: 51.4778

  // tile size and map bounds can be checked dynamically
  print(quad.tileSize); // 256
  print(quad.mapBounds()); // west: -180 south: -90 east: 180 north: 90

  // matrix width and height tells number of tiles in a given zoom level
  print('${quad.matrixWidth(2)} x ${quad.matrixHeight(2)}'); // 8 x 4
  print('${quad.matrixWidth(10)} x ${quad.matrixHeight(10)}'); // 2048 x 1024

  // map width and height tells number of pixels in a given zoom level
  print('${quad.mapWidth(2)} x ${quad.mapHeight(2)}'); // 2048 x 1024
  print('${quad.mapWidth(10)} x ${quad.mapHeight(10)}'); // 524288 x 262144

  // arc resolutions and scale denominator for zoom level 10 at the Equator
  print(quad.tileArcResolution(10)); // ~ 0.175781 (° degrees)
  print(quad.pixelArcResolution(10)); // ~ 0.000686646 (° degrees)
  print(quad.scaleDenominator(10)); // ~ 272989.39

  // inverse: zoom from scale denominator at the Equator
  print(quad.zoomFromScaleDenominator(272989.39)); // ~ 10.0 (double value)
}
