// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, cascade_invocations, lines_longer_than_80_chars, avoid_redundant_argument_values, omit_local_variable_types, unused_local_variable

import 'package:geobase/geobase.dart';

/*
To test run this from command line: 

dart example/geobase_example.dart
*/

void main() {
  // introduction
  _intro();

  // common
  _unitConversions();

  // coordinates
  _positionData();
  _positionSeries();
  _positionManipulation();
  _positionSeriesManipulation();
  _geographicCoordinates();
  _geographicCoordinatesDMS();
  _projectedCoordinates();
  _scalableCoordinates();

  // geodesy
  _ellipsoidalGeodesy();
  _ellipsoidalGeodesyVincenty();
  _sphericalGeodesyGreatCircle();
  _sphericalGeodesyRhumbLine();
  _utmAndMgrs();

  // geometric
  _geometricCartesianPolygon();
  _geometricCartesianPolygonFromGeometry();
  _geometricCartesianPolygonFromGeometryManipulation();

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
  _geoJsonNewLineDelimited();
  _geoJsonWithAlternativeCRS();
  _wkt();
  _ewkt();
  _wkbSample1();
  _wkbSample2();
  _ewkbSample();

  // projections
  _wgs84ProjectionsOnGeometries();
  _wgs84ToWebMercatorViaPositions();
  _wgs84ToWebMercatorViaProjections();
  // see also separate file "geobase_with_proj4d_example.dart"

  // tiling schemes
  _webMercatorQuad();
  _globalGeodeticQuad();
}

void _intro() {
  // Unit conversions for length, area, speed, angle, angular velocity and time
  // units.

  // For example conversions between length units.
  const meters = 1500.0;
  meters.convertLength(to: LengthUnit.foot); // ~ 4921.26 feet
  meters.convertLength(to: LengthUnit.kilometer); // 1.5 km
  meters.convertLength(to: LengthUnit.nauticalMile); // 0.8099 nmi
  254.convertLength(from: LengthUnit.millimeter, to: LengthUnit.inch); // 10.0

  // -------

  // General purpose positions, series of positions and bounding boxes.

  // A position as a view on a coordinate array containing x and y.
  Position.view([708221.0, 5707225.0]);

  // The sample above shorted.
  [708221.0, 5707225.0].xy;

  // A bounding box.
  Box.view([70800.0, 5707200.0, 70900.0, 5707300.0]);

  // A series of positions from an array of position objects.
  PositionSeries.from(
    [
      [70800.0, 5707200.0].xy, // position 0 with (x, y) coordinate values
      [70850.0, 5707250.0].xy, // position 1 with (x, y) coordinate values
      [70900.0, 5707300.0].xy, // position 2 with (x, y) coordinate values
    ],
    type: Coords.xy,
  );

  // -------

  // *Geographic* and *projected* positions and bounding boxes.

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

  // Ellipsoidal and spherical geodesy functions to calculate distances etc.

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

  // -------

  // Universal Transverse Mercator (UTM) coordinates and Military Grid Reference
  // System (MGRS) references based on the WGS84 ellipsoid are supported.

  // sample geographic position
  final eiffel = Geographic(lat: 48.8582, lon: 2.2945);

  // UTM coordinates for the position
  final eiffelUtm = eiffel.toUtm();
  print(eiffelUtm.toText()); // "31 N 448252 5411933"

  // It's also possible to convert between UTM coordinates and MGRS references
  print(eiffelUtm.toMgrs().toText()); // "31U DQ 48251 11932"

  // UTM coordinates can be converted back to geographic coordinates;
  print(eiffelUtm.toGeographic().latLonDms()); // "48.8582°N, 2.2945°E"

  // MGRS references can be constructed from components too (4Q FJ 12345 67890)
  final honoluluMgrs = Mgrs(4, 'Q', 'F', 'J', 12345, 67890);

  // MGRS references can be printed in different precisions
  print(honoluluMgrs.toText(digits: 8)); // "4Q FJ 1234 6789" (10 m precision)
  print(honoluluMgrs.toText(digits: 4)); // "4Q FJ 12 67" (1 km precision)
  print(honoluluMgrs.gridSquare.toText()); // "4Q FJ" (100 km precision)

  // -------

  // Geometry primitive and multi geometry objects.

  // A point with a 2D position.
  Point.build([30.0, 10.0]);

  // A line string (polyline) with three 2D positions.
  LineString.build([30, 10, 10, 30, 40, 40]);

  // A polygon with an exterior ring (and without any holes).
  Polygon.build([
    [30, 10, 40, 40, 20, 40, 10, 20, 30, 10],
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
    [30, 10],
  ]);

  // A multi line string with two line strings (polylines):
  MultiLineString.build([
    [10, 10, 20, 20, 10, 40],
    [40, 40, 30, 30, 40, 20, 30, 10],
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
    ]),
  ]);

  // -------

  // To distinguish between arrays of different spatial dimensions you can use
  // `Coords` enum.
  LineString.build([30, 10, 10, 30, 40, 40]); // default type == Coords.xy
  LineString.build([30, 10, 10, 30, 40, 40], type: Coords.xy);
  LineString.build([30, 10, 5.5, 10, 30, 5.5, 40, 40, 5.5], type: Coords.xyz);

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

  // -------

  // Projections can be applied on any geometry and feature objects along with
  // positions.

  // The source point geometry with a position in WGS 84 coordinates.
  final positionWgs84 = Geographic(lon: 2.2945, lat: 48.8582);
  final point = Point(positionWgs84);

  // Project to UTM projected coordinates (in zone 31 N).
  final zone31N = UtmZone(31, 'N');
  final wgs84toUtm31N = WGS84.utmZone(zone31N).forward;
  final pointUtm31N = point.project(wgs84toUtm31N);

  // Project back to WGS 84 coordinates.
  final utm31NtoWgs84 = WGS84.utmZone(zone31N).inverse;
  final pointWgs84 = pointUtm31N.project(utm31NtoWgs84);
}

void _unitConversions() {
  // Length units (mm, cm, m, km, in, ft, yd, mi, nmi), with some examples:
  const meters = 1500.0;
  meters.convertLength(to: LengthUnit.foot); // ~ 4921.26 ft
  meters.convertLength(to: LengthUnit.kilometer); // 1.5 km
  meters.convertLength(to: LengthUnit.nauticalMile); // 0.8099 nmi
  254.convertLength(from: LengthUnit.millimeter, to: LengthUnit.inch); // 10.0

  // Area units (mm², cm², m², km², in², ft², yd², mi², ac, ha), with examples:
  const squareMeters = 10000.0;
  squareMeters.convertArea(to: AreaUnit.squareKilometer); // 0.01 km²
  squareMeters.convertArea(to: AreaUnit.acre); // ~ 2.4711 acres
  1.0.convertArea(
    from: AreaUnit.hectare,
    to: AreaUnit.squareFoot,
  ); // 107639.1042 ft²

  // Speed units (mm/s, cm/s, m/s, km/h, mph, ft/s, kn), with some examples:
  const metersPerSecond = 10.0;
  metersPerSecond.convertSpeed(to: SpeedUnit.kilometerPerHour); // 36.0 km/h
  metersPerSecond.convertSpeed(to: SpeedUnit.milePerHour); // 22.3694 mph
  10.0.convertSpeed(
    from: SpeedUnit.kilometerPerHour,
    to: SpeedUnit.knot,
  ); // ~ 5.3996 kn

  // Angle units (mrad, rad, arcsec, arcmin, deg, gon, turn), with examples:
  const degrees = 90.0;
  degrees.convertAngle(from: AngleUnit.degree); // ~1.5708 rad
  degrees.convertAngle(from: AngleUnit.degree, to: AngleUnit.gradian); // 100.0

  // Angular velocity units (mrad/s, rad/s, deg/s, rpm, rps), with examples:
  const radiansPerSecond = 1.0;
  radiansPerSecond.convertAngularVelocity(
    to: AngularVelocityUnit.degreePerSecond,
  ); // ~ 57.296 deg/s
  720.0.convertAngularVelocity(
    from: AngularVelocityUnit.degreePerSecond,
    to: AngularVelocityUnit.revolutionPerSecond,
  ); // 2.0 rps

  // Time units (ns, µs, ms, s, min, h, d, w), with some examples:
  const seconds = 3600.0;
  seconds.convertTime(to: TimeUnit.hour); // 1.0 h
  seconds.convertTime(to: TimeUnit.day); // 0.0417 d
  1.0.convertTime(from: TimeUnit.week, to: TimeUnit.day); // 7.0 d
}

void _positionData() {
  // A position as a view on a coordinate array containing x and y.
  Position.view([708221.0, 5707225.0]);

  // A position as a view on a coordinate array containing x, y and z.
  Position.view([708221.0, 5707225.0, 45.0]);

  // A position as a view on a coordinate array containing x, y, z and m.
  Position.view([708221.0, 5707225.0, 45.0, 123.0]);

  // The samples above can be shorted using extension methods on `List<double>`.
  [708221.0, 5707225.0].xy;
  [708221.0, 5707225.0, 45.0].xyz;
  [708221.0, 5707225.0, 45.0, 123.0].xyzm;

  // There are also some other factory methods.
  Position.create(x: 708221.0, y: 5707225.0, z: 45.0, m: 123.0);
  Position.parse('708221.0,5707225.0,45.0,123.0');
  Position.parse('708221.0 5707225.0 45.0 123.0', delimiter: ' ');

  // -------

  // The same bounding box (limits on x and y) created with different factories.
  Box.view([70800.0, 5707200.0, 70900.0, 5707300.0]);
  Box.create(minX: 70800.0, minY: 5707200.0, maxX: 70900.0, maxY: 5707300.0);
  Box.parse('70800.0,5707200.0,70900.0,5707300.0');
  Box.parse('70800.0 5707200.0 70900.0 5707300.0', delimiter: ' ');

  // The same box using extension methods on `List<double>`.
  [70800.0, 5707200.0, 70900.0, 5707300.0].box;
}

void _positionSeries() {
  // A position series from a flat coordinate value array.
  PositionSeries.view(
    [
      70800.0, 5707200.0, // (x, y) coordinate values for position 0
      70850.0, 5707250.0, // (x, y) coordinate values for position 1
      70900.0, 5707300.0, // (x, y) coordinate values for position 2
    ],
    type: Coords.xy,
  );

  // A position series from an array of position objects.
  PositionSeries.from(
    [
      [70800.0, 5707200.0].xy, // position 0 with (x, y) coordinate values
      [70850.0, 5707250.0].xy, // position 1 with (x, y) coordinate values
      [70900.0, 5707300.0].xy, // position 2 with (x, y) coordinate values
    ],
    type: Coords.xy,
  );

  // -------

  // A position series from a flat coordinate value array (2D positions).
  [
    70800.0, 5707200.0, // (x, y) coordinate values for position 0
    70850.0, 5707250.0, // (x, y) coordinate values for position 1
    70900.0, 5707300.0, // (x, y) coordinate values for position 2
  ].positions(Coords.xy);

  // A position series from a flat coordinate value array (3D positions).
  [
    70800.0, 5707200.0, 40.0, // (x, y, z) coordinate values for position 0
    70850.0, 5707250.0, 45.0, // (x, y, z) coordinate values for position 1
    70900.0, 5707300.0, 50.0, // (x, y, z) coordinate values for position 2
  ].positions(Coords.xyz);

  // -------

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

void _positionManipulation() {
  // a position containing x, y and z
  final pos = [708221.0, 5707225.0, 45.0].xyz;

  // multiplication operator - prints "708.221,5707.225,0.045" (values in km)
  // (the operand is a factor value applied to all coordinate values)
  print(pos * 0.001);

  // negate operator - prints "-708221.0,-5707225.0,-45.0"
  print(-pos);

  // following operators expect an operand to be another position object

  // add operator - prints "708231.0,5707245.0,50.0"
  print(pos + [10.0, 20.0, 5.0].xyz);

  // subtraction operator - prints "708211.0,5707205.0,40.0"
  print(pos - [10.0, 20.0, 5.0].xyz);

  // division operator - prints "708.221,5707.225,45.0" (x and y values in km)
  print(pos / [1000.0, 1000.0, 1.0].xyz);

  // modulo operator - prints "221.0,225.0,45.0"
  print(pos % [1000.0, 1000.0, 1000.0].xyz);

  // there is support also for basic calculations in cartesian coordinates

  // other point 1000.0 meters to the direction of 45° (north-east)
  final other = pos.destinationPoint2D(distance: 1000.0, bearing: 45.0);

  // distance between points - prints "1000.0"
  print(pos.distanceTo2D(other).toStringAsFixed(1));

  // bearing from point to another - prints "45.0"
  print(pos.bearingTo2D(other).toStringAsFixed(1));

  // midpoint between two points - prints "708574.6,5707578.6"
  print(pos.midPointTo(other).toText(decimals: 1));

  // intermediate point between two point (fraction range: 0.0 to 1.0)
  // prints "708397.8,5707401.8"
  print(pos.intermediatePointTo(other, fraction: 0.25).toText(decimals: 1));
}

void _positionSeriesManipulation() {
  // a closed linear ring with positions in the counterclockwise (CCW) order
  final polygon = [
    [1.0, 6.0].xy,
    [3.0, 1.0].xy,
    [7.0, 2.0].xy,
    [4.0, 4.0].xy,
    [8.0, 5.0].xy,
    [1.0, 6.0].xy,
  ].series();

  // the area of a polygon formed by the linear ring - prints "16.5"
  print(polygon.signedArea2D());

  // the perimeter of a polygon - prints "24.3"
  print(polygon.length2D().toStringAsFixed(1));

  // the centroid position of a polygon - prints "3.9,3.7"
  print(polygon.centroid2D()!.toText(decimals: 1));

  // point in polygon - prints "true" (in this case the centroid is also inside)
  print(polygon.isPointInPolygon2D([3.9, 3.7].xy));

  // a closed linear ring with positions in the clockwise (CW) order
  final reversed = polygon.reversed();

  // a line string omitting the last position of `reversed`
  final line = reversed.range(0, reversed.positionCount - 1);

  // the length of a line string - prints "18.9"
  print(line.length2D().toStringAsFixed(1));

  // the line string modified by replacing positions at indexes 1 ja 2
  final lineModified = line.rangeReplaced(1, 3, [
    [3.5, 1.5].xy,
    [7.5, 2.5].xy,
  ]);

  // coordinate values of a line string multiplied by 100.0
  final lineModified2 = lineModified * 100.0;

  // get position count and a position by index - prints "5" and "350.0,150.0"
  print(lineModified2.positionCount);
  print(lineModified2[1]);
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

void _ellipsoidalGeodesy() {
  // a sample geographic position with geodetic latitude and longitude
  const geographic1 = Geographic(lat: 51.4778, lon: -0.0014, elev: 45.0);

  // same as ECEF (earth-centric earth-fixed) geocentric cartesian coordinates
  final geocentric1 = geographic1.toGeocentricCartesian();

  // returned object is of type `Position` with x, y and z cartesian coordinates
  // prints (X, Y, Z): 3980609.2373, -97.2646, 4966859.7285
  print(geocentric1.toText(decimals: 4, delimiter: ', '));

  // let's try inverse, first create a geocentric cartesian position (ECEF)
  final geocentric2 =
      Position.create(x: 3980609.2373, y: -97.2646, z: 4966859.7285);

  // convert this to a geographic position with geodetic latitude and longitude
  final geographic2 =
      Geocentric.fromGeocentricCartesian(geocentric1).toGeographic();

  // returned object is of the type `Geographic`
  // prints (longitude, latitude, elevation): -0.0014, 51.4778, 45.0000
  print(geographic2.toText(decimals: 4, delimiter: ', ', compactNums: false));

  // -------

  // Samples above used the WGS84 reference ellipsoid for ellipsoidal
  // calculations. You can also use other ellipsoids on `toGeocentricCartesian`
  // and `fromGeocentricCartesian` methods.

  // create a geocentric cartesian coordinates based on the GRS80 ellipsoid from
  // the same geodetic coordinate values as specified on `geographic1`
  final geocentricGRS80 =
      geographic1.toGeocentricCartesian(ellipsoid: Ellipsoid.GRS80);

  // prints (X, Y, Z): 3980609.2373, -97.2646, 4966859.7284
  print(geocentricGRS80.toText(decimals: 4, delimiter: ', '));

  // As WGS84 and GRS80 ellipsoids are very close to each other you may notice
  // only a small difference compared to values printed from `geocentric1`.

  // If needed it's also possible to define other ellipsoid parametrs, like:
  Ellipsoid(
    id: 'airy',
    name: 'Airy 1830',
    a: 6377563.396,
    b: 6356256.909,
    f: 1.0 / 299.3249646,
  );
}

void _ellipsoidalGeodesyVincenty() {
  // Distances & bearings between points, and destination points calculated on
  // an ellipsoidal earth model, along geodesics on the surface of a reference
  // ellipsoid selected.
  //
  // Calculations are based on ‘direct and inverse solutions of geodesics on the
  // ellipsoid’ devised by Thaddeus Vincenty.
  //
  // Calculations are accurate to within 0.5mm in distances and 0.000015″ in
  // bearings.

  // sample geographic positions
  final greenwich = Geographic.parseDms(lat: '51°28′40″ N', lon: '0°00′05″ W');
  final sydney = Geographic.parseDms(lat: '33.8688° S', lon: '151.2093° E');

  // decimal degrees (DD) and degrees-minutes (DM) formats
  const dd = Dms(decimals: 2);
  const dm = Dms.narrowSpace(type: DmsType.degMin, decimals: 2);

  // the shortest arc along the geodesic on the ellipsoid surface between points
  final arc1 = greenwich.vincenty().inverse(sydney);

  // prints (distance of the geodesic): 16983.3 km
  final distanceKm = arc1.distance / 1000.0;
  print('${distanceKm.toStringAsFixed(1)} km');

  // prints (bearing varies along the geodesic): 60.59° -> 139.15°
  final initialBearing = arc1.bearing;
  final finalBearing = arc1.finalBearing;
  print('${dd.bearing(initialBearing)} -> ${dd.bearing(finalBearing)}');

  // the shortest arc along the geodesic from greenwich to the initial direction
  // defined by `bearing` and the length by `distance`
  // prints: 51° 31.28′ N, 0° 07.48′ E - bearing: 61.10°
  final arc2 = greenwich.vincenty().direct(distance: 10000, bearing: 61.0);
  final dest = arc2.destination;
  final destBrng = arc2.finalBearing;
  print('${dest.latLonDms(format: dm)} - bearing: ${dd.bearing(destBrng)}');

  // mid point, prints: 28° 52.77′ N, 104° 48.82′ E
  final midPoint = greenwich.vincenty().midPointTo(sydney);
  print(midPoint.latLonDms(format: dm));

  // intermediate points along the geodesic between Greenwich and Sydney
  // prints 10 points with bearings on intermediate geographic positions:
  // 0.0: 51° 28.67′ N, 0° 00.08′ W - bearing: 60.59°
  // 0.1: 56° 39.07′ N, 24° 34.88′ E - bearing: 80.62°
  // 0.2: 56° 03.20′ N, 52° 13.09′ E - bearing: 103.76°
  // 0.3: 49° 56.60′ N, 75° 34.27′ E - bearing: 122.53°
  // 0.4: 40° 19.81′ N, 92° 27.98′ E - bearing: 134.59°
  // 0.5: 28° 52.77′ N, 104° 48.82′ E - bearing: 141.66°
  // 0.6: 16° 30.55′ N, 114° 36.83′ E - bearing: 145.47°
  // 0.7: 3° 43.29′ N, 123° 12.60′ E - bearing: 146.99°
  // 0.8: 9° 09.07′ S, 131° 33.47′ E - bearing: 146.59°
  // 0.9: 21° 48.54′ S, 140° 31.88′ E - bearing: 144.18°
  // 1.0: 33° 52.13′ S, 151° 12.56′ E - bearing: 139.15°
  for (var fr = 0.0; fr < 1.0; fr += 0.1) {
    final ip = greenwich.vincenty().intermediatePointTo(sydney, fraction: fr);
    final point = ip.origin;
    final pointBrng = ip.bearing;
    print('${fr.toStringAsFixed(1)}: ${point.latLonDms(format: dm)}'
        ' - bearing: ${dd.bearing(pointBrng)}');
  }

  // to use alternative ellipsoids set an optional argument on `vincenty` method
  final distanceGRS80 =
      greenwich.vincenty(ellipsoid: Ellipsoid.GRS80).distanceTo(sydney);

  // custom ellipsoids can be used also
  final airy = Ellipsoid(
    id: 'airy',
    name: 'Airy 1830',
    a: 6377563.396,
    b: 6356256.909,
    f: 1.0 / 299.3249646,
  );
  final distanceAiry = greenwich.vincenty(ellipsoid: airy).distanceTo(sydney);

  // Distances printed: 16983280.66025 m, 16983280.66013 m, 16981837.55212 m
  // (Note only very small difference between WGS84 and GRS80 ellipsoids,
  //  however this level of "accuracy" is out of nominal accuracy of measured
  //  points and Vincenty calculations with 0.5 mm expected accuracy)
  print('Distance WGS84: ${(distanceKm * 1000.0).toStringAsFixed(5)} m');
  print('Distance GRS80: ${distanceGRS80.toStringAsFixed(5)} m');
  print('Distance Airy1830: ${distanceAiry.toStringAsFixed(5)} m');
}

void _sphericalGeodesyGreatCircle() {
  // Distances & bearings between points, and destination points calculated on
  // a spherical earth model, along (orthodromic) great-circle paths.
  //
  // This is faster than using ellipsoidal geodesy with Vincenty methods, but
  // not as accurate (however the accuracy may be enough for many use cases).

  // sample geographic positions
  final greenwich = Geographic.parseDms(lat: '51°28′40″ N', lon: '0°00′05″ W');
  final sydney = Geographic.parseDms(lat: '33.8688° S', lon: '151.2093° E');

  // decimal degrees (DD) and degrees-minutes (DM) formats
  const dd = Dms(decimals: 2);
  const dm = Dms.narrowSpace(type: DmsType.degMin, decimals: 2);

  // prints: 16987.9 km
  final distanceKm = greenwich.spherical.distanceTo(sydney) / 1000.0;
  print('${distanceKm.toStringAsFixed(1)} km');

  // prints (bearing varies along the great circle path): 60.94° -> 139.03°
  final initialBearing = greenwich.spherical.initialBearingTo(sydney);
  final finalBearing = greenwich.spherical.finalBearingTo(sydney);
  print('${dd.bearing(initialBearing)} -> ${dd.bearing(finalBearing)}');

  // prints: 51° 31.28′ N, 0° 07.50′ E
  final destPoint =
      greenwich.spherical.destinationPoint(distance: 10000, bearing: 61.0);
  print(destPoint.latLonDms(format: dm));

  // prints: 28° 33.97′ N, 104° 41.62′ E
  final midPoint = greenwich.spherical.midPointTo(sydney);
  print(midPoint.latLonDms(format: dm));

  // intermediate points along the great circle between Greenwich and Sydney
  // prints 10 intermediate geographic positions:
  // 0.0: 51° 28.67′ N, 0° 00.08′ W
  // 0.1: 56° 33.44′ N, 24° 42.13′ E
  // 0.2: 55° 50.76′ N, 52° 19.42′ E
  // 0.3: 49° 39.17′ N, 75° 34.08′ E
  // 0.4: 40° 00.39′ N, 92° 22.91′ E
  // 0.5: 28° 33.97′ N, 104° 41.62′ E
  // 0.6: 16° 14.46′ N, 114° 29.30′ E
  // 0.7: 3° 31.26′ N, 123° 05.85′ E
  // 0.8: 9° 16.56′ S, 131° 28.24′ E
  // 0.9: 21° 51.83′ S, 140° 28.86′ E
  // 1.0: 33° 52.13′ S, 151° 12.56′ E
  for (var fr = 0.0; fr < 1.0; fr += 0.1) {
    final ip = greenwich.spherical.intermediatePointTo(sydney, fraction: fr);
    print('${fr.toStringAsFixed(1)}: ${ip.latLonDms(format: dm)}');
  }

  // prints: 0° 00.00′ N, 125° 18.98′ E
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
  // Distances & bearings between points, and destination points calculated on
  // a spherical earth model, along (loxodromic) rhumb lines.

  // sample geographic positions
  final greenwich = Geographic.parseDms(lat: '51°28′40″ N', lon: '0°00′05″ W');
  final sydney = Geographic.parseDms(lat: '33.8688° S', lon: '151.2093° E');

  // decimal degrees (DD) and degrees-minutes (DM) formats
  const dd = Dms(decimals: 2);
  const dm = Dms.narrowSpace(type: DmsType.degMin, decimals: 2);

  // prints: 17669.8 km
  final distanceKm = greenwich.rhumb.distanceTo(sydney) / 1000.0;
  print('${distanceKm.toStringAsFixed(1)} km');

  // prints (bearing remains the same along the rhumb line): 122.49° -> 122.49°
  final initialBearing = greenwich.rhumb.initialBearingTo(sydney);
  final finalBearing = greenwich.rhumb.finalBearingTo(sydney);
  print('${dd.bearing(initialBearing)} -> ${dd.bearing(finalBearing)}');

  // prints: 51° 25.80′ N, 0° 07.26′ E
  final destPoint =
      greenwich.spherical.destinationPoint(distance: 10000, bearing: 122.0);
  print(destPoint.latLonDms(format: dm));

  // prints: 8° 48.27′ N, 80° 43.98′ E
  final midPoint = greenwich.rhumb.midPointTo(sydney);
  print(midPoint.latLonDms(format: dm));
}

void _utmAndMgrs() {
  // Universal Transverse Mercator (UTM) coordinates and Military Grid Reference
  // System (MGRS) references are based on the WGS84 ellipsoid.

  // sample geographic position
  final eiffel = Geographic(lat: 48.8582, lon: 2.2945);

  // UTM coordinates for the position
  final eiffelUtm = eiffel.toUtm();
  print(eiffelUtm.toText()); // "31 N 448252 5411933"
  print(eiffelUtm.zone.lonZone); // "31" (longitudinal zone)
  print(eiffelUtm.zone.hemisphere.symbol); // "N" (hemisphere, N or S)
  // UTM easting and northing are floating point values in meters
  print(eiffelUtm.easting.toStringAsFixed(3)); // "448251.795"
  print(eiffelUtm.northing.toStringAsFixed(3)); // "5411932.678"
  // the projected position contains x (easting) and y (northing) values, with
  // optional z (elevation) and m (measure) values
  print(eiffelUtm.projected.toText(decimals: 3)); // "448251.795,5411932.678"

  // UTM coordinates for the position with extra metadata
  final eiffelUtmMeta = eiffel.toUtmMeta();
  print(eiffelUtmMeta.position.toText()); // "31 N 448252 5411933"
  // The bearing of the grid north clockwise from the true north, in degrees.
  print(eiffelUtmMeta.convergence.toStringAsFixed(3)); // "-0.531"
  // The scale factor at the position (factor is 0.9996 at the central meridian)
  print(eiffelUtmMeta.scale.toStringAsFixed(6)); // "0.999633"

  // The UTM zone can be forced to neighbour zones too, but if the position is
  // out of the defined limits of a zone, then the convergence gets larger and
  // the scale error indicated by the scale factor increases.
  final zone30 = UtmZone(30, 'N');
  final eiffelUtmZone30Meta = eiffel.toUtmMeta(zone: zone30, verifyEN: false);
  print(eiffelUtmZone30Meta.position.toText()); // "30 N 888277 5425221"
  print(eiffelUtmZone30Meta.convergence.toStringAsFixed(3)); // "3.992"
  print(eiffelUtmZone30Meta.scale.toStringAsFixed(6)); // "1.001453"

  // UTM coordinates can be constructed from components too
  final eiffelUtm2 = Utm(31, 'N', eiffelUtm.easting, eiffelUtm.northing);
  print(eiffelUtm == eiffelUtm2); // "true"

  // MGRS grid reference for the position
  final eiffelMgrs = eiffel.toMgrs();
  print(eiffelMgrs.toText()); // "31U DQ 48251 11932"
  print(eiffelMgrs.gridSquare.lonZone); // "31" (longitudinal zone)
  print(eiffelMgrs.gridSquare.band); // "U" (latitudinal band)
  print(eiffelMgrs.gridSquare.column); // "D" (100km square column)
  print(eiffelMgrs.gridSquare.row); // "Q" (100km square row)
  // MGRS easting and northing are integer values in meters, truncated from the
  // UTM coordinates as MGRS grid references refer to squares rather than points
  // (both values has a range from 0 to 99999 within a 100 km square)
  print(eiffelMgrs.easting); // "48251"
  print(eiffelMgrs.northing); // "11932"

  // It's also possible to convert between UTM coordinates and MGRS references
  print(eiffelUtm.toMgrs().toText()); // "31U DQ 48251 11932"
  // Not the same as the original UTM coordinates because of the truncation
  print(eiffelMgrs.toUtm().toText()); // "31 N 448251 5411932"

  // UTM coordinates can be converted back to geographic coordinates;
  print(eiffelUtm.toGeographic().latLonDms()); // "48.8582°N, 2.2945°E"

  // MGRS references can be constructed from components too (4Q FJ 12345 67890)
  final honoluluMgrs = Mgrs(4, 'Q', 'F', 'J', 12345, 67890);
  final honoluluUtm = honoluluMgrs.toUtm();
  print(honoluluMgrs.toText()); // "4Q FJ 12345 67890"
  print(honoluluUtm.toText()); // "4 N 612345 2367890"

  // The `toText()` for UTM has more options for formatting, for example:
  print(eiffelUtm.toText(decimals: 3)); // "31 N 448251.795 5411932.678"
  print(honoluluUtm.toText(zeroPadZone: true)); // "04 N 612345 2367890"
  print(honoluluUtm.toText(swapXY: true)); // "4 N 2367890 612345"

  // Also the `toText()` for MGRS has more options for formatting, for example:
  print(honoluluMgrs.toText(zeroPadZone: true)); // "04Q FJ 12345 67890"
  print(honoluluMgrs.toText(militaryStyle: true)); // "4QFJ1234567890"

  // MGRS references can be printed in different precisions
  print(honoluluMgrs.toText(digits: 8)); // "4Q FJ 1234 6789" (10 m precision)
  print(honoluluMgrs.toText(digits: 4)); // "4Q FJ 12 67" (1 km precision)
  print(honoluluMgrs.gridSquare.toText()); // "4Q FJ" (100 km precision)
}

void _geometricCartesianPolygon() {
  // Polygon data (with an exterior ring and one interior ring as a hole) as an
  // `Iterable<PositionSeries>`. Each ring is represented by an instance of
  // `PositionSeries` constructed by `positions()` method.
  final polygon = [
    [35.0, 10.0, 45.0, 45.0, 15.0, 40.0, 10.0, 20.0, 35.0, 10.0].positions(),
    [20.0, 30.0, 35.0, 35.0, 30.0, 20.0, 20.0, 30.0].positions(),
  ];

  // Prints: "Centroid pos: 27.407,28.765"
  final centroid = polygon.centroid2D();
  print('Centroid pos: ${centroid?.toText(decimals: 3)}');

  // Prints: "Polylabel pos: 17.3828125,23.9453125 dist: 6.131941618102092"
  final p = polygon.polylabel2D(precision: 0.5);
  print('Polylabel pos: ${p.position} dist: ${p.distance}');

  // prints: "(20,20) => true, (10,10) => false"
  final inside = polygon.isPointInPolygon2D([20.0, 20.0].xy);
  final outside = polygon.isPointInPolygon2D([10.0, 10.0].xy);
  print('(20,20) => $inside, (10,10) => $outside');

  // prints: "(20,20) => 3.7139067635410368, (10,10) => 9.284766908852593"
  final dist1 = polygon.distanceTo2D([20.0, 20.0].xy);
  final dist2 = polygon.distanceTo2D([10.0, 10.0].xy);
  print('(20,20) => $dist1, (10,10) => $dist2');
}

void _geometricCartesianPolygonFromGeometry() {
  // A polygon geometry (with an exterior ring and one interior ring as a hole).
  final polygon = Polygon.build([
    [35.0, 10.0, 45.0, 45.0, 15.0, 40.0, 10.0, 20.0, 35.0, 10.0],
    [20.0, 30.0, 35.0, 35.0, 30.0, 20.0, 20.0, 30.0],
  ]);

  // Prints: "Bounding box: 10.0,10.0,45.0,45.0"
  // Values contained in the bbox in this case: min-x, min-y, max-x, max-y
  final bbox = polygon.calculateBounds();
  print('Bounding box: ${bbox?.toText(decimals: 1, compactNums: false)}');

  // Bbox center, prints: "Bbox center: 27.5,27.5"
  final center = bbox?.aligned2D();
  print('Bbox center: ${center?.toText(decimals: 1)}');

  // It's also possible to calculate aligned points inside a bounding box.
  // X = The horizontal distance fraction.
  //    The value -1.0 represents the west side edge of the box.
  //    The value 0.0 represents the center horizontally.
  //    The value 1.0 represents the east side edge of the box.
  // Y = The vertical distance fraction.
  //    The value -1.0 represents the south side edge of the box.
  //    The value 0.0 represents the center vertically.
  //    The value 1.0 represents the north side edge of the box.

  // Bbox aligned, prints: "Bbox aligned: 36.250,36.250"
  final aligned = bbox?.aligned2D(Aligned(x: 0.5, y: 0.5));
  print('Bbox aligned: ${aligned?.toText(decimals: 3)}');

  // Prints: "Centroid pos: 27.407,28.765"
  final centroid = polygon.centroid2D();
  print('Centroid pos: ${centroid?.toText(decimals: 3)}');

  // Prints: "Polylabel pos: 17.65625,24.21875 dist: 5.745242597140699"
  final p = polygon.polylabel2D(precision: 2.0);
  print('Polylabel pos: ${p.position} dist: ${p.distance}');

  // prints: "(20,20) => true, (10,10) => false"
  final inside = polygon.isPointInPolygon2D([20.0, 20.0].xy);
  final outside = polygon.isPointInPolygon2D([10.0, 10.0].xy);
  print('(20,20) => $inside, (10,10) => $outside');

  // prints: "(20,20) => 3.7139067635410368, (10,10) => 9.284766908852593"
  final dist1 = polygon.distanceTo2D([20.0, 20.0].xy);
  final dist2 = polygon.distanceTo2D([10.0, 10.0].xy);
  print('(20,20) => $dist1, (10,10) => $dist2');

  // Polygon outer ring length, inner ring length and total outline length.
  // "Outer 114.35571426165451 + inner 45.76491222541475 = 160.12062648706927"
  final outerLength = polygon.exterior?.length2D();
  final innerLength = polygon.interior.first.length2D();
  final totalLength = polygon.length2D();
  print('Outer $outerLength + inner $innerLength = $totalLength');

  // Polygon outer ring area, inner ring area and total outline area.
  // Prints: "Outer 775.0 - inner 100.0 = 675.0"
  final outerArea = polygon.exterior?.signedArea2D().abs();
  final innerArea = polygon.interior.first.signedArea2D().abs();
  final totalArea = polygon.area2D();
  print('Outer $outerArea - inner $innerArea = $totalArea');
}

void _geometricCartesianPolygonFromGeometryManipulation() {
  // Polygon linear rings each an `PositionSeries` instance constructed by
  // `positions()` method.
  final exteriorRing =
      [35.0, 10.0, 45.0, 45.0, 15.0, 40.0, 10.0, 20.0, 35.0, 10.0].positions();
  final interiorRing =
      [20.0, 30.0, 35.0, 35.0, 30.0, 20.0, 20.0, 30.0].positions();

  // Polygon data as `Iterable<PositionSeries>`.
  final polygonData = [exteriorRing, interiorRing];

  // A polygon geometry (with an exterior ring and one interior ring as a hole).
  final polygon = Polygon(polygonData);

  // `PositionSeries` objects can be modified and used to construct new polygons
  final exteriorRingEnlargenedBy10percent = exteriorRing * 1.1;
  final interiorRingPositionsChanged = interiorRing.rangeReplaced(1, 3, [
    [35.5, 35.5].xy,
    [30.5, 20.5].xy,
  ]);
  final modifiedPolygon = Polygon(
    [exteriorRingEnlargenedBy10percent, interiorRingPositionsChanged],
  );

  // Accessing coordinate value data in PositionSeries object.
  print('Position count: ${exteriorRing.positionCount}'); // 5
  print('Value count: ${exteriorRing.valueCount}'); // 10
  print('Is closed: ${exteriorRing.isClosed}'); // true
  print('Is 3D: ${exteriorRing.is3D}'); // false
  print('Is measured: ${exteriorRing.isMeasured}'); // false
  print('Coordinate dimension: ${exteriorRing.coordinateDimension}'); // 2
  print('Spatial dimension: ${exteriorRing.spatialDimension}'); // 2
  print('Coordinate type: ${exteriorRing.coordType}'); // Coords.xy
  print('First position: ${exteriorRing.firstOrNull}'); // 35.0,10.0
  print('Last position: ${exteriorRing.lastOrNull}'); // 35.0,10.0
  print('X coordinate at position 1: ${exteriorRing.x(1)}'); // 45.0
  print('Y coordinate at position 3: ${exteriorRing.y(3)}'); // 20.0

  // Looping positions by accessing coordinate values (best to use this option
  // when a position series is constructed from a double coordinate value array)
  for (int i = 0, len = exteriorRing.positionCount; i < len; i++) {
    print('X: ${exteriorRing.x(i)} Y: ${exteriorRing.y(i)} (at $i)');
  }

  // Looping positions by accessing `Position` objects (best to use this option
  // when a position series is constructed from `Position` instances)
  for (final pos in exteriorRing.positions) {
    print('X: ${pos.x} Y: ${pos.y}');
  }
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
    ]),
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
    [30.0, 10.0].xy, // xy => Position.view()
    [10.0, 30.0].xy,
    [40.0, 40.0].xy,
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

void _geoJsonNewLineDelimited() {
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
  // Prints: {"type":"Point","coordinates":[-0.0014,51.4778,45]}
  print(point2.toText(format: GeoJSON.geometry));

  // Writing with crs (EPSG:4326) results in latitude-longitude order.
  // Prints: {"type":"Point","coordinates":[51.4778,-0.0014,45]}
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

void _ewkt() {
  const wktPoints = [
    /// A 2D point represented as WKT text.
    'POINT(-0.0014 51.4778)',

    /// A 3D point represented as WKT text.
    'POINT Z(-0.0014 51.4778 45)',

    /// A 3D point with SRID represented as EWKT text.
    'SRID=4326;POINT(-0.0014 51.4778 45)',

    /// A measured point represented as EWKT text.
    'POINTM(-0.0014 51.4778 100.0)',
  ];

  // decode SRID, s coordType and a point geometry (with a position) from input
  for (final p in wktPoints) {
    final srid = WKT.decodeSRID(p);
    final coordType = WKT.decodeCoordType(p);
    final pos = Point.parse(p, format: WKT.geometry).position;
    print('$srid $coordType ${pos.x} ${pos.y} ${pos.optZ} ${pos.optM}');
  }

  // the previous sample prints:
  //   null Coords.xy -0.0014 51.4778 null null
  //   null Coords.xyz -0.0014 51.4778 45.0 null
  //   4326 Coords.xyz -0.0014 51.4778 45.0 null
  //   null Coords.xym -0.0014 51.4778 null 100.0
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

void _ewkbSample() {
  // References:
  // [PostGIS](https://postgis.net/docs/ST_AsEWKB.html)
  // [GEOS](https://libgeos.org/specifications/wkb/)

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

void _wgs84ProjectionsOnGeometries() {
  // Projections can be applied on any geometry and feature objects along with
  // positions.

  // The source point geometry with a position in WGS 84 coordinates.
  final positionWgs84 = Geographic(lon: 2.2945, lat: 48.8582);
  final point = Point(positionWgs84);

  // Project to UTM projected coordinates (in zone 31 N).
  final zone31N = UtmZone(31, 'N');
  final wgs84toUtm31N = WGS84.utmZone(zone31N).forward;
  final pointUtm31N = point.project(wgs84toUtm31N);

  // Project back to WGS 84 coordinates.
  final utm31NtoWgs84 = WGS84.utmZone(zone31N).inverse;
  final pointWgs84 = pointUtm31N.project(utm31NtoWgs84);

  // Print the original and projected point coordinates.
  //    {"type":"Point","coordinates":[2.2945,48.8582]} =>
  //    {"type":"Point","coordinates":[448251.80,5411932.68]} =>
  //    {"type":"Point","coordinates":[2.2945,48.8582]}"
  print('${point.toText(decimals: 4)} => ${pointUtm31N.toText(decimals: 2)}'
      ' => ${pointWgs84.toText(decimals: 4)}');

  // Project between WGS84 based UTM zones. Note that resulting coordinates may
  // have strange values if the point do not locate inside the target zone.
  final zone30N = UtmZone(30, 'N');
  final utm31NtoUtm30N = WGS84.utmZoneToZone(zone31N, zone30N).forward;
  final pointUtm30N = pointUtm31N.project(utm31NtoUtm30N);
  print(pointUtm30N.position.toText(decimals: 2)); // 888276.96,5425220.84

  // It's always possible to check the UTM zone a point is located in.
  final zone = UtmZone.fromGeographic(positionWgs84);
  print(zone); // 31 N

  // The source WGS84 geographic position to geocentric cartesian.
  final wgs84toGeocentric = WGS84.geocentric.forward;
  final pointGeocentric = point.project(wgs84toGeocentric);
  // prints "4200952.55,168323.77,4780198.41"
  print(pointGeocentric.position.toText(decimals: 2));

  // The source WGS84 geographic position to WG84 web mercator (metric).
  final wgs84toWebMercator = WGS84.webMercator.forward;
  final pointWebMercator = point.project(wgs84toWebMercator);
  print(pointWebMercator.position.toText(decimals: 2)); // 255422.57,6250835.06
}

void _wgs84ToWebMercatorViaPositions() {
  // Built-in coordinate projections (between WGS 84 and Web Mercator)

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
  // Built-in coordinate projections (between WGS 84 and Web Mercator)

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
