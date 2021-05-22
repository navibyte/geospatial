// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print, avoid_redundant_argument_values
// ignore_for_file: cascade_invocations

import 'package:equatable/equatable.dart';

import 'package:geocore/geocore.dart';

/*
To test run this from command line: 

dart example/geocore_example.dart
*/

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // call simple demos
  _parseGeoJSON();
  _readmeIntro();
}

void _parseGeoJSON() {
  print('Parse GeoJSON sample data.');

  // sample GeoJSON data
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
            "place": "Greenwich",
            "city": "London",
            "isMuseum": true,
            "code": "000",
            "founded": 1675,
            "prime": "1884-10-22", 
            "measure": 5.79
          }
        }  
      ]
    }
  ''';

  // parse FeatureCollection using the default GeoJSON factory
  final fc = geoJSON.featureCollection(sample);

  // loop through features and print id, geometry and properties for each
  for (final f in fc.features) {
    print('Feature with id: ${f.id}');
    print('  geometry: ${f.geometry}');
    print('  properties:');
    for (final key in f.properties.keys) {
      print('    $key: ${f.properties[key]}');
    }
  }
}

void _readmeIntro() {
  // Some samples for README
  //    (https://github.com/navibyte/geospatial/tree/main/dart/geocore).
  // Note that following samples are just created, not used, even printed.

  // -----------

  // Projected point with X, Y and Z coordinates in two ways.
  Point3(x: 708221.0, y: 5707225.0, z: 45.0);
  Point3.xyz(708221.0, 5707225.0, 45.0);

  // The same point created from `Iterable<num>`.
  Point3.from([708221.0, 5707225.0, 45.0]);

  // The same point parsed from WKT compatible text.
  // Actually WKT representation would be : "POINT (708221.0 5707225.0 45.0)",
  // but this parser takes only coordinate data between paranthesis.
  Point3.parse('708221.0 5707225.0 45.0');

  // The `parse` method throws when text is invalid, but `tryParse` returns null
  // in such case. This can be utilized for fallbacks.
  Point3.tryParse('nop') ?? Point3.parse('708221.0 5707225.0 45.0');

  // The same point parsed using the WKT parser for projected geometries.
  // Here `wktProjected` is a global constant for a WKT factory implementation.
  wktProjected.parse('POINT Z (708221.0 5707225.0 45.0)');

  // -----------

  // Geographic point with longitude, latitude, elevation and measure.
  GeoPoint3m(lon: -0.0014, lat: 51.4778, elev: 45.0, m: 123.0);
  GeoPoint3m.lonLatElevM(-0.0014, 51.4778, 45.0, 123.0);

  // Someone might want to represent latitude before longitude, it's fine too.
  GeoPoint3m.latLonElevM(51.4778, -0.0014, 45.0, 123.0);

  // When creating from value array, the order is: lon, lat, elev, m.
  GeoPoint3m.from([-0.0014, 51.4778, 45.0, 123.0]);

  // Also here it's possible to parse from WKT compatible text.
  GeoPoint3m.parse('-0.0014 51.4778 45.0 123.0');

  // The WKT parser for geographic coordinates parses full representations.
  wktGeographic.parse('POINT ZM (-0.0014 51.4778 45.0 123.0)');

  // -----------

  // A point series of `Point2` composed of list of points that are of `Point2`
  // or it's sub classes.
  PointSeries<Point2>.from([
    Point2(x: 10.0, y: 10.0),
    Point2(x: 20.0, y: 20.0),
    Point2m(x: 30.0, y: 30.0, m: 5.0),
    Point3(x: 40.0, y: 40.0, z: 40.0),
    Point3m(x: 50.0, y: 50.0, z: 50.0, m: 5.0),
  ]);

  // Making a point series of `Point3` from a list of a list of nums.
  PointSeries.make(
    // three points each with x, y and z coordinates
    [
      [10.0, 11.0, 12.0],
      [20.0, 21.0, 22.0],
      [30.0, 31.0, 32.0],
    ],
    // This is `PointFactory` that converts `Iterable<num>` to a point instance,
    // in this example using a factory creating `Point3` instances.
    Point3.geometry,
  );

  // Parsing a point series of `GeoPoint` from WKT compatible text with
  // `GeoPoint3` as a concrete point class.
  PointSeries<GeoPoint>.parse(
      '10.0 11.0 12.0, 20.0 21.0 22.0, 30.0 31.0 32.0', GeoPoint3.geometry);

  // -----------

  // This makes a a line string of `Point3m` from a list of points.
  LineString.make(
    [
      [10.0, 11.0, 12.0, 5.1],
      [20.0, 21.0, 22.0, 5.2],
      [30.0, 31.0, 32.0, 5.3],
    ],
    Point3m.geometry,
  );

  // Parsing using the WKT factory produces the result as the previous sample.
  wktProjected.parse<Point3m>('LINESTRING ZM (10.0 11.0 12.0 5.1, '
      '20.0 21.0 22.0 5.2, 30.0 31.0 32.0 5.3)');

  // -----------

  // Making a polygon of `GeoPoint2` from a list of a list of a list of nums:
  Polygon.make(
    [
      // this is an exterior boundary or an outer ring
      [
        [35, 10],
        [45, 45],
        [15, 40],
        [10, 20],
        [35, 10]
      ],
      // this is an interior boundary or an inner ring representing a hole
      [
        [20, 30],
        [35, 35],
        [30, 20],
        [20, 30]
      ],
    ],
    GeoPoint2.geometry,
  );

  // The same polygon geometry as above, but parsed from a WKT compatible text.
  Polygon.parse(
      '(35 10, 45 45, 15 40, '
      '10 20, 35 10) (20 30, 35 35, 30 20, 20 30)',
      GeoPoint2.geometry);

  // -----------

  // A multi point of `GeoPoint2` with four lon-lat points.
  MultiPoint.parse('10 40, 40 30, 20 20, 30 10', GeoPoint2.geometry);

  // A multi line string of `Point2` with two line strings.
  MultiLineString.parse(
      '(10 10, 20 20, 10 40), (40 40, 30 30, 40 20, 30 10)', Point2.geometry);

  // A multi polygon of `GeoPoint2` with two polygon (both with exterior
  // boundary without holes).
  MultiPolygon.parse(
      '((30 20, 45 40, 10 40, 30 20)), ((15 5, 40 10, 10 20, 5 10, 15 5))',
      GeoPoint2.geometry);

  // A geometry collection can contain any other geometry types. Items for such
  // a collection can be constructed using different ways.
  GeometryCollection.from(<Geometry>[
    // A point with integer values using a constructor with named parameters.
    Point2i(x: 40, y: 10),
    // A line string made from a list of points (each a list of nums).
    LineString.make([
      [10, 10],
      [20, 20],
      [10, 40]
    ], Point2i.geometry),
    // A polygon parsed from WKT compatible text.
    Polygon.parse('(40 40, 20 45, 45 30, 40 40)', Point2i.geometry)
  ]);

  GeometryCollection.from(<Geometry>[
    Point2i(x: 40, y: 10),
    LineString.make([
      [10, 10],
      [20, 20],
      [10, 40]
    ], Point2i.geometry),
    Polygon.parse('(40 40, 20 45, 45 30, 40 40)', Point2i.geometry)
  ]);

  // -----------

  // Bounds (2D) or bounding box from minimum and maximum 2D projected points.
  Bounds.of(min: Point2(x: 10.0, y: 10.0), max: Point2(x: 20.0, y: 20.0));

  // Bounds (3D) made from a list of list of nums.
  Bounds.make([
    [10.0, 10.0, 10.0],
    [20.0, 20.0, 20.0]
  ], Point3.geometry);

  // Bounds (3D with measure) parsed from WKT compatible text.
  Bounds.parse('10.0 10.0 10.0 5.0, 20.0 20.0 20.0 5.0', Point3m.geometry);

  // -----------

  // Geographical bounds (-20.0 .. 20.0 in longitude, 50.0 .. 60.0 in latitude).
  GeoBounds.bboxLonLat(-20.0, 50.0, 20.0, 60.0);

  // The same bounds created of 2D geographic point instances.
  GeoBounds.of(
      min: GeoPoint2(lon: -20.0, lat: 50.0),
      max: GeoPoint2(lon: 20.0, lat: 60.0));

  // -----------

  // Temporal instants can be created from `DateTime` or parsed from text.
  Instant(DateTime.utc(2020, 10, 31, 09, 30));
  Instant.parse('2020-10-31 09:30Z');

  // -----------

  // Temporal intervals (open-started, open-ended, closed).
  Interval.openStart(DateTime.utc(2020, 10, 31));
  Interval.openEnd(DateTime.utc(2020, 10, 01));
  Interval.closed(DateTime.utc(2020, 10, 01), DateTime.utc(2020, 10, 31));

  // Same intervals parsed (by the "start/end" format, ".." for open limits).
  Interval.parse('../2020-10-31');
  Interval.parse('2020-10-01/..');
  Interval.parse('2020-10-01/2020-10-31');

  // -----------

  // An extent with spatial (WGS 84 longitude-latitude) and temporal parts.
  Extent.single(
    crs: CRS84,
    bounds: GeoBounds.bboxLonLat(-20.0, 50.0, 20.0, 60.0),
    interval: Interval.parse('../2020-10-31'),
  );

  // An extent with multiple spatial bounds and temporal interval segments.
  Extent.multi(crs: CRS84, allBounds: [
    GeoBounds.bboxLonLat(-20.0, 50.0, 20.0, 60.0),
    GeoBounds.bboxLonLat(40.0, 50.0, 60.0, 60.0),
  ], allIntervals: [
    Interval.parse('2020-10-01/2020-10-05'),
    Interval.parse('2020-10-27/2020-10-31'),
  ]);

  // -----------

  // Geospatial feature with an identification, a point geometry and properties.
  Feature.view(
    id: 'ROG',
    geometry: GeoPoint3(lon: -0.0014, lat: 51.4778, elev: 45.0),
    properties: <String, dynamic>{
      'title': 'Royal Observatory',
      'place': 'Greenwich',
      'city': 'London',
      'isMuseum': true,
      'code': '000',
      'founded': 1675,
      'prime': DateTime.utc(1884, 10, 22),
      'measure': 5.79,
    },
  );

  // -----------

  // Parse projected points from WKT (result is different concrete classes).
  wktProjected.parse('POINT (100.0 200.0)'); // => Point2
  wktProjected.parse('POINT M (100.0 200.0 5.0)'); // => Point2m
  wktProjected.parse('POINT (100.0 200.0 300.0)'); // => Point3
  wktProjected.parse('POINT Z (100.0 200.0 300.0)'); // => Point3
  wktProjected.parse('POINT ZM (100.0 200.0 300.0 5.0)'); // => Point3m

  // Parse geographical line string, from (10.0 50.0) to (11.0 51.0).
  wktGeographic.parse('LINESTRING (10.0 50.0, 11.0 51.0)');

  // Parse geographical polygon with a hole.
  wktGeographic.parse('POLYGON ((40 15, 50 50, 15 45, 10 15, 40 15),'
      ' (25 25, 25 40, 35 30, 25 25))');
}
