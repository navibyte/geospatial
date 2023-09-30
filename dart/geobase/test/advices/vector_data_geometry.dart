// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_literals_to_create_immutables
// ignore_for_file: avoid_redundant_argument_values, no_adjacent_strings_in_list

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';

import 'package:test/test.dart';

import 'coordinates_position.dart';

void main() {
  group('Point class', () {
    test('Point.new', () {
      // a point with a 2D position (x: 10.0, y: 20.0)
      testPoint(Point([10.0, 20.0].xy));

      // a point with a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testPoint(Point([10.0, 20.0, 30.0].xyz));

      // a point with a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      testPoint(Point([10.0, 20.0, 40.0].xym));

      // a point with a measured 3D position
      // (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testPoint(Point([10.0, 20.0, 30.0, 40.0].xyzm));
    });

    test('Point.build', () {
      // a point with a 2D position (x: 10.0, y: 20.0)
      testPoint(Point.build([10.0, 20.0]));

      // a point with a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testPoint(Point.build([10.0, 20.0, 30.0]));

      // a point with a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      testPoint(Point.build([10.0, 20.0, 40.0], type: Coords.xym));

      // a point with a measured 3D position
      // (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testPoint(Point.build([10.0, 20.0, 30.0, 40.0]));
    });

    test('Point.parse', () {
      // a point with a 2D position (x: 10.0, y: 20.0)
      testPoint(
        Point.parse(
          format: GeoJSON.geometry,
          '{"type": "Point", "coordinates": [10.0, 20.0]}',
        ),
      );
      testPoint(
        Point.parse(
          format: WKT.geometry,
          'POINT (10.0 20.0)',
        ),
      );

      // a point with a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testPoint(
        Point.parse(
          format: GeoJSON.geometry,
          '{"type": "Point", "coordinates": [10.0, 20.0, 30.0]}',
        ),
      );
      testPoint(
        Point.parse(
          format: WKT.geometry,
          'POINT Z (10.0 20.0 30.0)',
        ),
      );

      // a point with a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      testPoint(
        Point.parse(
          format: WKT.geometry,
          'POINT M (10.0 20.0 40.0)',
        ),
      );

      // a point with a measured 3D position
      // (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testPoint(
        Point.parse(
          format: GeoJSON.geometry,
          '{"type": "Point", "coordinates": [10.0, 20.0, 30.0, 40]}',
        ),
      );
      testPoint(
        Point.parse(
          format: WKT.geometry,
          'POINT ZM (10.0 20.0 30.0 40.0)',
        ),
      );
    });

    test('Point.parse', () {
      // a point with a 2D position (x: 10.0, y: 20.0)
      testPoint(Point.parseCoords('10.0,20.0'));

      // a point with a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testPoint(Point.parseCoords('10.0,20.0,30.0'));

      // a point with a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      testPoint(Point.parseCoords('10.0,20.0,40.0', type: Coords.xym));

      // a point with a measured 3D position
      // (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testPoint(Point.parseCoords('10.0,20.0,30.0,40.0'));

      // a point with a 2D position (x: 10.0, y: 20.0) using an alternative
      // delimiter
      testPoint(Point.parseCoords('10.0;20.0', delimiter: ';'));

      // a point with a 2D position (x: 10.0, y: 20.0) from an array with y
      // before x
      testPoint(Point.parseCoords('20.0,10.0', swapXY: true));

      // a point with a 2D position (x: 10.0, y: 20.0) with the internal storage
      // using single precision floating point numbers (`Float32List` in this
      // case)
      testPoint(Point.parseCoords('10.0,20.0', singlePrecision: true));
    });
  });

  group('LineString class', () {
    test('LineString.new', () {
      // a line string from 2D positions
      testLineString(
        LineString(
          [
            10.0, 20.0, // (x, y) for position 0
            12.5, 22.5, // (x, y) for position 1
            15.0, 25.0, // (x, y) for position 2
          ].positions(Coords.xy),
        ),
      );

      // a line string from 3D positions
      testLineString(
        LineString(
          [
            10.0, 20.0, 30.0, // (x, y, z) for position 0
            12.5, 22.5, 32.5, // (x, y, z) for position 1
            15.0, 25.0, 35.0, // (x, y, z) for position 2
          ].positions(Coords.xyz),
        ),
      );

      // a line string from measured 2D positions
      testLineString(
        LineString(
          [
            10.0, 20.0, 40.0, // (x, y, m) for position 0
            12.5, 22.5, 42.5, // (x, y, m) for position 1
            15.0, 25.0, 45.0, // (x, y, m) for position 2
          ].positions(Coords.xym),
        ),
      );

      // a line string from measured 3D positions
      testLineString(
        LineString(
          [
            10.0, 20.0, 30.0, 40.0, // (x, y, z, m) for position 0
            12.5, 22.5, 32.5, 42.5, // (x, y, z, m) for position 1
            15.0, 25.0, 35.0, 45.0, // (x, y, z, m) for position 2
          ].positions(Coords.xyzm),
        ),
      );
    });

    test('LineString.from', () {
      // a line string from 2D positions
      testLineString(
        LineString.from([
          [10.0, 20.0].xy,
          [12.5, 22.5].xy,
          [15.0, 25.0].xy,
        ]),
      );

      // a line string from 3D positions
      testLineString(
        LineString.from([
          [10.0, 20.0, 30.0].xyz,
          [12.5, 22.5, 32.5].xyz,
          [15.0, 25.0, 35.0].xyz,
        ]),
      );

      // a line string from measured 2D positions
      testLineString(
        LineString.from([
          [10.0, 20.0, 40.0].xym,
          [12.5, 22.5, 42.5].xym,
          [15.0, 25.0, 45.0].xym,
        ]),
      );

      // a line string from measured 3D positions
      testLineString(
        LineString.from(
          [
            [10.0, 20.0, 30.0, 40.0].xyzm,
            [12.5, 22.5, 32.5, 42.5].xyzm,
            [15.0, 25.0, 35.0, 45.0].xyzm,
          ],
        ),
      );
    });

    test('LineString.build', () {
      // a line string from 2D positions
      testLineString(
        LineString.build(
          [
            10.0, 20.0, // (x, y) for position 0
            12.5, 22.5, // (x, y) for position 1
            15.0, 25.0, // (x, y) for position 2
          ],
          type: Coords.xy,
        ),
      );

      // a line string from 3D positions
      testLineString(
        LineString.build(
          [
            10.0, 20.0, 30.0, // (x, y, z) for position 0
            12.5, 22.5, 32.5, // (x, y, z) for position 1
            15.0, 25.0, 35.0, // (x, y, z) for position 2
          ],
          type: Coords.xyz,
        ),
      );

      // a line string from measured 2D positions
      testLineString(
        LineString.build(
          [
            10.0, 20.0, 40.0, // (x, y, m) for position 0
            12.5, 22.5, 42.5, // (x, y, m) for position 1
            15.0, 25.0, 45.0, // (x, y, m) for position 2
          ],
          type: Coords.xym,
        ),
      );

      // a line string from measured 3D positions
      testLineString(
        LineString.build(
          [
            10.0, 20.0, 30.0, 40.0, // (x, y, z, m) for position 0
            12.5, 22.5, 32.5, 42.5, // (x, y, z, m) for position 1
            15.0, 25.0, 35.0, 45.0, // (x, y, z, m) for position 2
          ],
          type: Coords.xyzm,
        ),
      );
    });

    test('LineString.parse', () {
      // a line string from 2D positions
      testLineString(
        LineString.parse(
          format: GeoJSON.geometry,
          '''
          { 
            "type": "LineString", 
            "coordinates": [
              [10.0,20.0],
              [12.5,22.5],
              [15.0,25.0]
            ]
          }
          ''',
        ),
      );
      testLineString(
        LineString.parse(
          format: WKT.geometry,
          'LINESTRING (10.0 20.0,12.5 22.5,15.0 25.0)',
        ),
      );

      // a line string from 3D positions
      testLineString(
        LineString.parse(
          format: GeoJSON.geometry,
          '''
          { 
            "type": "LineString", 
            "coordinates": [
              [10.0,20.0,30.0],
              [12.5,22.5,32.5],
              [15.0,25.0,35.0]
            ]
          }
          ''',
        ),
      );
      testLineString(
        LineString.parse(
          format: WKT.geometry,
          'LINESTRING Z (10.0 20.0 30.0,12.5 22.5 32.5,15.0 25.0 35.0)',
        ),
      );

      // a line string from measured 2D positions
      testLineString(
        LineString.parse(
          format: WKT.geometry,
          'LINESTRING M (10.0 20.0 40.0,12.5 22.5 42.5,15.0 25.0 45.0)',
        ),
      );

      // a line string from measured 3D positions
      testLineString(
        LineString.parse(
          format: GeoJSON.geometry,
          '''
          { 
            "type": "LineString", 
            "coordinates": [
              [10.0,20.0,30.0,40.0],
              [12.5,22.5,32.5,42.5],
              [15.0,25.0,35.0,45.0]
            ]
          }
          ''',
        ),
      );
      testLineString(
        LineString.parse(
          format: WKT.geometry,
          '''
          LINESTRING ZM (
            10.0 20.0 30.0 40.0,
            12.5 22.5 32.5 42.5,
            15.0 25.0 35.0 45.0
          )
          ''',
        ),
      );
    });

    test('LineString.parseCoords', () {
      // a line string from 2D positions
      testLineString(
        LineString.parseCoords(
          // values for three (x, y) positions
          '10.0,20.0,12.5,22.5,15.0,25.0',
          type: Coords.xy,
        ),
      );

      // a line string from 3D positions
      testLineString(
        LineString.parseCoords(
          // values for three (x, y, z) positions
          '10.0,20.0,30.0,12.5,22.5,32.5,15.0,25.0,35.0',
          type: Coords.xyz,
        ),
      );

      // a line string from measured 2D positions
      testLineString(
        LineString.parseCoords(
          // values for three (x, y, m) positions
          '10.0,20.0,40.0,12.5,22.5,42.5,15.0,25.0,45.0',
          type: Coords.xym,
        ),
      );

      // a line string from measured 3D positions
      testLineString(
        LineString.parseCoords(
          // values for three (x, y, z, m) positions
          '10.0,20.0,30.0,40.0,12.5,22.5,32.5,42.5,15.0,25.0,35.0,45.0',
          type: Coords.xyzm,
        ),
      );

      // a line string from 2D positions using an alternative delimiter
      testLineString(
        LineString.parseCoords(
          // values for three (x, y) positions
          '10.0;20.0;12.5;22.5;15.0;25.0',
          type: Coords.xy,
          delimiter: ';',
        ),
      );

      // a line string from 2D positions with x before y
      testLineString(
        LineString.parseCoords(
          // values for three (x, y) positions
          '20.0,10.0,22.5,12.5,25.0,15.0',
          type: Coords.xy,
          swapXY: true,
        ),
      );

      // a line string from 2D positions with the internal storage using single
      // precision floating point numbers (`Float32List` in this case)
      testLineString(
        LineString.parseCoords(
          // values for three (x, y) positions
          '10.0,20.0,12.5,22.5,15.0,25.0',
          type: Coords.xy,
          singlePrecision: true,
        ),
      );
    });
  });

  group('Polygon class', () {
    test('Polygon.new', () {
      // a polygon (with an exterior ring only) from 2D positions
      testPolygon(
        Polygon(
          [
            // an exterior ring with values of five (x, y) positions
            [
              10.0, 20.0,
              12.5, 22.5,
              15.0, 25.0,
              11.5, 27.5,
              10.0, 20.0,
              //
            ].positions(Coords.xy),
          ],
        ),
      );

      // a polygon (with an exterior and one interior ring) from 2D positions
      testPolygon(
        ringCount: 2,
        Polygon(
          [
            // an exterior ring with values of five (x, y) positions
            [
              10.0, 20.0,
              12.5, 22.5,
              15.0, 25.0,
              11.5, 27.5,
              10.0, 20.0,
              //
            ].positions(Coords.xy),
            // an interior ring with values of four (x, y) positions
            [
              12.5, 23.0,
              11.5, 24.0,
              12.5, 24.0,
              12.5, 23.0,
              //
            ].positions(Coords.xy),
          ],
        ),
      );

      // a polygon (with an exterior ring only) from 3D positions
      testPolygon(
        Polygon(
          [
            // an exterior ring with values of five (x, y, z) positions
            [
              10.0, 20.0, 30.0,
              12.5, 22.5, 32.5,
              15.0, 25.0, 35.0,
              11.5, 27.5, 37.5,
              10.0, 20.0, 30.0,
              //
            ].positions(Coords.xyz),
          ],
        ),
      );

      // a polygon (with an exterior ring only) from measured 2D positions
      testPolygon(
        Polygon(
          [
            // an exterior ring with values of five (x, y, m) positions
            [
              10.0, 20.0, 40.0,
              12.5, 22.5, 42.5,
              15.0, 25.0, 45.0,
              11.5, 27.5, 47.5,
              10.0, 20.0, 40.0,
              //
            ].positions(Coords.xym),
          ],
        ),
      );

      // a polygon (with an exterior ring only) from measured 3D positions
      testPolygon(
        Polygon(
          [
            // an exterior ring with values of five (x, y, z, m) positions
            [
              10.0, 20.0, 30.0, 40.0,
              12.5, 22.5, 32.5, 42.5,
              15.0, 25.0, 35.0, 45.0,
              11.5, 27.5, 37.5, 47.5,
              10.0, 20.0, 30.0, 40.0,
              //
            ].positions(Coords.xyzm),
          ],
        ),
      );
    });

    test('Polygon.from', () {
      // a polygon (with an exterior ring only) from 2D positions
      testPolygon(
        Polygon.from(
          [
            // an exterior ring with five (x, y) positions
            [
              [10.0, 20.0].xy,
              [12.5, 22.5].xy,
              [15.0, 25.0].xy,
              [11.5, 27.5].xy,
              [10.0, 20.0].xy,
            ],
          ],
        ),
      );

      // a polygon (with an exterior and one interior ring) from 2D positions
      testPolygon(
        ringCount: 2,
        Polygon.from(
          [
            // an exterior ring with five (x, y) positions
            [
              [10.0, 20.0].xy,
              [12.5, 22.5].xy,
              [15.0, 25.0].xy,
              [11.5, 27.5].xy,
              [10.0, 20.0].xy,
              //
            ],
            // an interior ring with four (x, y) positions
            [
              [12.5, 23.0].xy,
              [11.5, 24.0].xy,
              [12.5, 24.0].xy,
              [12.5, 23.0].xy,
              //
            ],
          ],
        ),
      );

      // a polygon (with an exterior ring only) from 3D positions
      testPolygon(
        Polygon.from(
          [
            // an exterior ring with five (x, y, z) positions
            [
              [10.0, 20.0, 30.0].xyz,
              [12.5, 22.5, 32.5].xyz,
              [15.0, 25.0, 35.0].xyz,
              [11.5, 27.5, 37.5].xyz,
              [10.0, 20.0, 30.0].xyz,
              //
            ],
          ],
        ),
      );

      // a polygon (with an exterior ring only) from measured 2D positions
      testPolygon(
        Polygon.from(
          [
            // an exterior ring with five (x, y, m) positions
            [
              [10.0, 20.0, 40.0].xym,
              [12.5, 22.5, 42.5].xym,
              [15.0, 25.0, 45.0].xym,
              [11.5, 27.5, 47.5].xym,
              [10.0, 20.0, 40.0].xym,
              //
            ],
          ],
        ),
      );

      // a polygon (with an exterior ring only) from measured 3D positions
      testPolygon(
        Polygon.from(
          [
            // an exterior ring with five (x, y, z, m) positions
            [
              [10.0, 20.0, 30.0, 40.0].xyzm,
              [12.5, 22.5, 32.5, 42.5].xyzm,
              [15.0, 25.0, 35.0, 45.0].xyzm,
              [11.5, 27.5, 37.5, 47.5].xyzm,
              [10.0, 20.0, 30.0, 40.0].xyzm,
              //
            ],
          ],
        ),
      );
    });

    test('Polygon.build', () {
      // a polygon (with an exterior ring only) from 2D positions
      testPolygon(
        Polygon.build(
          [
            // an exterior ring with values of five (x, y) positions
            [
              10.0, 20.0,
              12.5, 22.5,
              15.0, 25.0,
              11.5, 27.5,
              10.0, 20.0,
              //
            ],
          ],
          type: Coords.xy,
        ),
      );

      // a polygon (with an exterior and one interior ring) from 2D positions
      testPolygon(
        ringCount: 2,
        Polygon.build(
          [
            // an exterior ring with values of five (x, y) positions
            [
              10.0, 20.0,
              12.5, 22.5,
              15.0, 25.0,
              11.5, 27.5,
              10.0, 20.0,
              //
            ],
            // an interior ring with values of four (x, y) positions
            [
              12.5, 23.0,
              11.5, 24.0,
              12.5, 24.0,
              12.5, 23.0,
              //
            ],
          ],
          type: Coords.xy,
        ),
      );

      // a polygon (with an exterior ring only) from 3D positions
      testPolygon(
        Polygon.build(
          [
            // an exterior ring with values of five (x, y, z) positions
            [
              10.0, 20.0, 30.0,
              12.5, 22.5, 32.5,
              15.0, 25.0, 35.0,
              11.5, 27.5, 37.5,
              10.0, 20.0, 30.0,
              //
            ],
          ],
          type: Coords.xyz,
        ),
      );

      // a polygon (with an exterior ring only) from measured 2D positions
      testPolygon(
        Polygon.build(
          [
            // an exterior ring with values of five (x, y, m) positions
            [
              10.0, 20.0, 40.0,
              12.5, 22.5, 42.5,
              15.0, 25.0, 45.0,
              11.5, 27.5, 47.5,
              10.0, 20.0, 40.0,
              //
            ],
          ],
          type: Coords.xym,
        ),
      );

      // a polygon (with an exterior ring only) from measured 3D positions
      testPolygon(
        Polygon.build(
          [
            // an exterior ring with values of five (x, y, z, m) positions
            [
              10.0, 20.0, 30.0, 40.0,
              12.5, 22.5, 32.5, 42.5,
              15.0, 25.0, 35.0, 45.0,
              11.5, 27.5, 37.5, 47.5,
              10.0, 20.0, 30.0, 40.0,
              //
            ],
          ],
          type: Coords.xyzm,
        ),
      );
    });

    test('Polygon.parse', () {
      // a polygon (with an exterior ring only) from 2D positions
      testPolygon(
        Polygon.parse(
          format: GeoJSON.geometry,
          '''
          {
            "type": "Polygon",
            "coordinates": [
              [
                [10.0,20.0],
                [12.5,22.5],
                [15.0,25.0],
                [11.5,27.5],
                [10.0,20.0]
              ]
            ]
          }
          ''',
        ),
      );
      testPolygon(
        Polygon.parse(
          format: WKT.geometry,
          'POLYGON ((10.0 20.0,12.5 22.5,15.0 25.0,11.5 27.5,10.0 20.0))',
        ),
      );

      // a polygon (with an exterior ring only) from 3D positions
      testPolygon(
        Polygon.parse(
          format: GeoJSON.geometry,
          '''
          {
            "type": "Polygon",
            "coordinates": [
              [
                [10.0,20.0,30.0],
                [12.5,22.5,32.5],
                [15.0,25.0,35.0],
                [11.5,27.5,37.5],
                [10.0,20.0,30.0]
              ]
            ]
          }
          ''',
        ),
      );
      testPolygon(
        Polygon.parse(
          format: WKT.geometry,
          '''
          POLYGON Z (
            (
              10.0 20.0 30.0,
              12.5 22.5 32.5,
              15.0 25.0 35.0,
              11.5 27.5 37.5,
              10.0 20.0 30.0
            )
          )
          ''',
        ),
      );

      // a polygon (with an exterior ring only) from measured 2D positions
      testPolygon(
        Polygon.parse(
          format: WKT.geometry,
          '''
          POLYGON M (
            (
              10.0 20.0 40.0,
              12.5 22.5 42.5,
              15.0 25.0 45.0,
              11.5 27.5 47.5,
              10.0 20.0 40.0
            )
          )
          ''',
        ),
      );

      // a polygon (with an exterior ring only) from measured 3D positions
      testPolygon(
        Polygon.parse(
          format: GeoJSON.geometry,
          '''
          {
            "type": "Polygon",
            "coordinates": [
              [
                [10.0,20.0,30.0,40.0],
                [12.5,22.5,32.5,42.5],
                [15.0,25.0,35.0,45.0],
                [11.5,27.5,37.5,47.5],
                [10.0,20.0,30.0,40.0]
              ]
            ]
          }
          ''',
        ),
      );
      testPolygon(
        Polygon.parse(
          format: WKT.geometry,
          '''
          POLYGON ZM (
            (
              10.0 20.0 30.0 40.0,
              12.5 22.5 32.5 42.5,
              15.0 25.0 35.0 45.0,
              11.5 27.5 37.5 47.5,
              10.0 20.0 30.0 40.0
            )
          )
          ''',
        ),
      );
    });

    test('Polygon.parseCoords', () {
      // a polygon (with an exterior ring only) from 2D positions
      testPolygon(
        Polygon.parseCoords(
          [
            // an exterior ring with values of five (x, y) positions
            '10.0,20.0,'
                '12.5,22.5,'
                '15.0,25.0,'
                '11.5,27.5,'
                '10.0,20.0'
          ],
          type: Coords.xy,
        ),
      );

      // a polygon (with an exterior and one interior ring) from 2D positions
      testPolygon(
        ringCount: 2,
        Polygon.parseCoords(
          [
            // an exterior ring with values of five (x, y) positions
            '10.0,20.0,'
                '12.5,22.5,'
                '15.0,25.0,'
                '11.5,27.5,'
                '10.0,20.0',

            // an interior ring with values of four (x, y) positions
            '12.5,23.0,'
                '11.5,24.0,'
                '12.5,24.0,'
                '12.5,23.0'
          ],
          type: Coords.xy,
        ),
      );

      // a polygon (with an exterior ring only) from 3D positions
      testPolygon(
        Polygon.parseCoords(
          [
            // an exterior ring with values of five (x, y, z) positions
            '10.0,20.0,30.0,'
                '12.5,22.5,32.5,'
                '15.0,25.0,35.0,'
                '11.5,27.5,37.5,'
                '10.0,20.0,30.0'
          ],
          type: Coords.xyz,
        ),
      );

      // a polygon (with an exterior ring only) from measured 2D positions
      testPolygon(
        Polygon.parseCoords(
          [
            // an exterior ring with values of five (x, y, m) positions
            '10.0,20.0,40.0,'
                '12.5,22.5,42.5,'
                '15.0,25.0,45.0,'
                '11.5,27.5,47.5,'
                '10.0,20.0,40.0'
          ],
          type: Coords.xym,
        ),
      );

      // a polygon (with an exterior ring only) from measured 3D positions
      testPolygon(
        Polygon.parseCoords(
          [
            // an exterior ring with values of five (x, y, z, m) positions
            '10.0,20.0,30.0,40.0,'
                '12.5,22.5,32.5,42.5,'
                '15.0,25.0,35.0,45.0,'
                '11.5,27.5,37.5,47.5,'
                '10.0,20.0,30.0,40.0'
          ],
          type: Coords.xyzm,
        ),
      );

      // a polygon (with an exterior ring only) from 2D positions using an
      // alternative delimiter
      testPolygon(
        Polygon.parseCoords(
          [
            // an exterior ring with values of five (x, y) positions
            '10.0;20.0;'
                '12.5;22.5;'
                '15.0;25.0;'
                '11.5;27.5;'
                '10.0;20.0'
          ],
          type: Coords.xy,
          delimiter: ';',
        ),
      );

      // a polygon (with an exterior ring only) from 2D positions with x before
      // y
      testPolygon(
        Polygon.parseCoords(
          [
            // an exterior ring with values of five (x, y) positions
            '20.0,10.0,'
                '22.5,12.5,'
                '25.0,15.0,'
                '27.5,11.5,'
                '20.0,10.0'
          ],
          type: Coords.xy,
          swapXY: true,
        ),
      );

      // a polygon (with an exterior ring only) from 2D positions with the
      // internal storage using single precision floating point numbers
      // (`Float32List` in this case)
      testPolygon(
        Polygon.parseCoords(
          [
            // an exterior ring with values of five (x, y) positions
            '10.0,20.0,'
                '12.5,22.5,'
                '15.0,25.0,'
                '11.5,27.5,'
                '10.0,20.0'
          ],
          type: Coords.xy,
          singlePrecision: true,
        ),
      );
    });
  });

  group('MultiPoint class', () {
    test('MultiPoint.new', () {
      // a multi point with three 2D positions
      testMultiPoint(
        MultiPoint([
          [10.0, 20.0].xy,
          [12.5, 22.5].xy,
          [15.0, 25.0].xy,
        ]),
      );

      // a multi point with three 3D positions
      testMultiPoint(
        MultiPoint([
          [10.0, 20.0, 30.0].xyz,
          [12.5, 22.5, 32.5].xyz,
          [15.0, 25.0, 35.0].xyz,
        ]),
      );
    });

    test('MultiPoint.from', () {
      // a multi point with three 2D positions
      testMultiPoint(
        MultiPoint.from([
          [10.0, 20.0].xy,
          [12.5, 22.5].xy,
          [15.0, 25.0].xy,
        ]),
      );

      // a multi point with three 3D positions
      testMultiPoint(
        MultiPoint.from([
          [10.0, 20.0, 30.0].xyz,
          [12.5, 22.5, 32.5].xyz,
          [15.0, 25.0, 35.0].xyz,
        ]),
      );
    });

    test('MultiPoint.build', () {
      // a multi point with three 2D positions
      testMultiPoint(
        MultiPoint.build(
          [
            [10.0, 20.0],
            [12.5, 22.5],
            [15.0, 25.0],
          ],
          type: Coords.xy,
        ),
      );

      // a multi point with three 3D positions
      testMultiPoint(
        MultiPoint.build(
          [
            [10.0, 20.0, 30.0],
            [12.5, 22.5, 32.5],
            [15.0, 25.0, 35.0],
          ],
          type: Coords.xyz,
        ),
      );
    });

    test('MultiPoint.parse', () {
      // a multi point from three 2D positions
      testMultiPoint(
        MultiPoint.parse(
          format: GeoJSON.geometry,
          '''
          {
            "type": "MultiPoint",
            "coordinates": [[10.0,20.0],[12.5,22.5],[15.0,25.0]]
          }
          ''',
        ),
      );
      testMultiPoint(
        MultiPoint.parse(
          format: WKT.geometry,
          'MULTIPOINT ((10.0 20.0),(12.5 22.5),(15.0 25.0))',
        ),
      );

      // a multi point from three 3D positions
      testMultiPoint(
        MultiPoint.parse(
          format: GeoJSON.geometry,
          '''
          {
            "type": "MultiPoint",
            "coordinates": [[10.0,20.0,30.0],[12.5,22.5,32.5],[15.0,25.0,35.0]]
          }
          ''',
        ),
      );
      testMultiPoint(
        MultiPoint.parse(
          format: WKT.geometry,
          'MULTIPOINT Z ((10.0 20.0 30.0),(12.5 22.5 32.5),(15.0 25.0 35.0))',
        ),
      );
    });

    test('MultiPoint.parseCoords', () {
      // a multi point from three 2D positions
      testMultiPoint(
        MultiPoint.parseCoords([
          '10.0,20.0',
          '12.5,22.5',
          '15.0,25.0',
        ]),
      );

      // a multi point from three 3D positions
      testMultiPoint(
        MultiPoint.parseCoords([
          '10.0,20.0,30.0',
          '12.5,22.5,32.5',
          '15.0,25.0,35.0',
        ]),
      );

      // a multi point from three 2D positions using an alternative delimiter
      testMultiPoint(
        MultiPoint.parseCoords(
          [
            '10.0;20.0',
            '12.5;22.5',
            '15.0;25.0',
          ],
          delimiter: ';',
        ),
      );

      // a multi point from three 2D positions with x before y
      testMultiPoint(
        MultiPoint.parseCoords(
          [
            '20.0,10.0',
            '22.5,12.5',
            '25.0,15.0',
          ],
          swapXY: true,
        ),
      );

      // a multi point from three 2D positions with the internal storage using
      // single precision floating point numbers (`Float32List` in this case)
      testMultiPoint(
        MultiPoint.parseCoords(
          [
            '10.0,20.0',
            '12.5,22.5',
            '15.0,25.0',
          ],
          singlePrecision: true,
        ),
      );
    });
  });

  group('MultiLineString class', () {
    test('MultiLineString.new', () {
      // a multi line string with two line strings both with three 2D positions
      testMultiLineString(
        MultiLineString([
          [10.0, 20.0, 12.5, 22.5, 15.0, 25.0].positions(Coords.xy),
          [12.5, 23.0, 11.5, 24.0, 12.5, 24.0].positions(Coords.xy),
        ]),
      );

      // a multi line string with two line strings both with three 3D positions
      testMultiLineString(
        MultiLineString([
          [10.0, 20.0, 30.0, 12.5, 22.5, 32.5, 15.0, 25.0, 35.0]
              .positions(Coords.xyz),
          [12.5, 23.0, 32.5, 11.5, 24.0, 31.5, 12.5, 24.0, 32.5]
              .positions(Coords.xyz),
        ]),
      );
    });

    test('MultiLineString.from', () {
      // a multi line string with two line strings both with three 2D positions
      testMultiLineString(
        MultiLineString.from([
          [
            [10.0, 20.0].xy,
            [12.5, 22.5].xy,
            [15.0, 25.0].xy,
          ],
          [
            [12.5, 23.0].xy,
            [11.5, 24.0].xy,
            [12.5, 24.0].xy,
          ],
        ]),
      );

      // a multi line string with two line strings both with three 3D positions
      testMultiLineString(
        MultiLineString.from([
          [
            [10.0, 20.0, 30.0].xyz,
            [12.5, 22.5, 32.5].xyz,
            [15.0, 25.0, 35.0].xyz,
          ],
          [
            [12.5, 23.0, 32.5].xyz,
            [11.5, 24.0, 31.5].xyz,
            [12.5, 24.0, 32.5].xyz,
          ],
        ]),
      );
    });

    test('MultiLineString.build', () {
      // a multi line string with two line strings both with three 2D positions
      testMultiLineString(
        MultiLineString.build(
          [
            [10.0, 20.0, 12.5, 22.5, 15.0, 25.0],
            [12.5, 23.0, 11.5, 24.0, 12.5, 24.0],
          ],
          type: Coords.xy,
        ),
      );

      // a multi line string with two line strings both with three 3D positions
      testMultiLineString(
        MultiLineString.build(
          [
            [10.0, 20.0, 30.0, 12.5, 22.5, 32.5, 15.0, 25.0, 35.0],
            [12.5, 23.0, 32.5, 11.5, 24.0, 31.5, 12.5, 24.0, 32.5],
          ],
          type: Coords.xyz,
        ),
      );
    });

    test('MultiLineString.parse', () {
      // a multi line string with two line strings both with three 2D positions
      testMultiLineString(
        MultiLineString.parse(
          format: GeoJSON.geometry,
          '''
          {
            "type": "MultiLineString",
            "coordinates": [
              [[10.0,20.0], [12.5,22.5], [15.0,25.0]],
              [[12.5,23.0], [11.5,24.0], [12.5,24.0]]
            ]
          }
          ''',
        ),
      );
      testMultiLineString(
        MultiLineString.parse(
          format: WKT.geometry,
          '''
          MULTILINESTRING (
            (10.0 20.0,12.5 22.5,15.0 25.0),
            (12.5 23.0,11.5 24.0,12.5 24.0)
          )
          ''',
        ),
      );

      // a multi line string with two line strings both with three 3D positions
      testMultiLineString(
        MultiLineString.parse(
          format: GeoJSON.geometry,
          '''
          {
            "type": "MultiLineString",
            "coordinates": [
              [[10.0,20.0,30.0], [12.5,22.5,32.5], [15.0,25.0,35.0]],
              [[12.5,23.0,32.5], [11.5,24.0,31.5], [12.5,24.0,32.5]]
            ]
          }
          ''',
        ),
      );
      testMultiLineString(
        MultiLineString.parse(
          format: WKT.geometry,
          '''
          MULTILINESTRING Z (
            (10.0 20.0 30.0,12.5 22.5 32.5,15.0 25.0 35.0),
            (12.5 23.0 32.5,11.5 24.0 31.5,12.5 24.0 32.5)
          )
          ''',
        ),
      );
    });

    test('MultiLineString.parseCoords', () {
      // a multi line string with two line strings both with three 2D positions
      testMultiLineString(
        MultiLineString.parseCoords(
          [
            '10.0,20.0,12.5,22.5,15.0,25.0',
            '12.5,23.0,11.5,24.0,12.5,24.0',
          ],
          type: Coords.xy,
        ),
      );

      // a multi line string with two line strings both with three 3D positions
      testMultiLineString(
        MultiLineString.parseCoords(
          [
            '10.0,20.0,30.0,12.5,22.5,32.5,15.0,25.0,35.0',
            '12.5,23.0,32.5,11.5,24.0,31.5,12.5,24.0,32.5',
          ],
          type: Coords.xyz,
        ),
      );

      // a multi line string with two line strings both with three 2D positions
      // using an alternative delimiter
      testMultiLineString(
        MultiLineString.parseCoords(
          [
            '10.0;20.0;12.5;22.5;15.0;25.0',
            '12.5;23.0;11.5;24.0;12.5;24.0',
          ],
          type: Coords.xy,
          delimiter: ';',
        ),
      );

      // a multi line string with two line strings both with three 2D positions
      // with x before y
      testMultiLineString(
        MultiLineString.parseCoords(
          [
            '20.0,10.0,22.5,12.5,25.0,15.0',
            '23.0,12.5,24.0,11.5,24.0,12.5',
          ],
          type: Coords.xy,
          swapXY: true,
        ),
      );

      // a multi line string with two line strings both with three 2D positions
      // with the internal storage using single precision floating point numbers
      // (`Float32List` in this case)
      testMultiLineString(
        MultiLineString.parseCoords(
          [
            '10.0,20.0,12.5,22.5,15.0,25.0',
            '12.5,23.0,11.5,24.0,12.5,24.0',
          ],
          type: Coords.xy,
          singlePrecision: true,
        ),
      );
    });
  });

  group('MultiPolygon class', () {
    test('MultiPolygon.new', () {
      // a multi polygon with one polygon from 2D positions
      testMultiPolygon(
        MultiPolygon(
          [
            // polygon
            [
              // an exterior ring with values of five (x, y) positions
              [
                10.0, 20.0,
                12.5, 22.5,
                15.0, 25.0,
                11.5, 27.5,
                10.0, 20.0,
                //
              ].positions(Coords.xy),
            ],
          ],
        ),
      );

      // a multi polygon with one polygon from 3D positions
      testMultiPolygon(
        MultiPolygon(
          [
            // polygon
            [
              // an exterior ring with values of five (x, y, z) positions
              [
                10.0, 20.0, 30.0,
                12.5, 22.5, 32.5,
                15.0, 25.0, 35.0,
                11.5, 27.5, 37.5,
                10.0, 20.0, 30.0,
                //
              ].positions(Coords.xyz),
            ],
          ],
        ),
      );
    });

    test('MultiPolygon.from', () {
      // a multi polygon with one polygon from 2D positions
      testMultiPolygon(
        MultiPolygon.from(
          [
            // polygon
            [
              // an exterior ring with five (x, y) positions
              [
                [10.0, 20.0].xy,
                [12.5, 22.5].xy,
                [15.0, 25.0].xy,
                [11.5, 27.5].xy,
                [10.0, 20.0].xy,
              ],
            ],
          ],
        ),
      );

      // a multi polygon with one polygon from 3D positions
      testMultiPolygon(
        MultiPolygon.from(
          [
            // polygon
            [
              // an exterior ring with five (x, y, z) positions
              [
                [10.0, 20.0, 30.0].xyz,
                [12.5, 22.5, 32.5].xyz,
                [15.0, 25.0, 35.0].xyz,
                [11.5, 27.5, 37.5].xyz,
                [10.0, 20.0, 30.0].xyz,
                //
              ],
            ],
          ],
        ),
      );
    });

    test('MultiPolygon.build', () {
      // a multi polygon with one polygon from 2D positions
      testMultiPolygon(
        MultiPolygon.build(
          [
            // polygon
            [
              // an exterior ring with values of five (x, y) positions
              [
                10.0, 20.0,
                12.5, 22.5,
                15.0, 25.0,
                11.5, 27.5,
                10.0, 20.0,
                //
              ],
            ],
          ],
          type: Coords.xy,
        ),
      );

      // a multi polygon with one polygon from 3D positions
      testMultiPolygon(
        MultiPolygon.build(
          [
            // polygon
            [
              // an exterior ring with values of five (x, y, z) positions
              [
                10.0, 20.0, 30.0,
                12.5, 22.5, 32.5,
                15.0, 25.0, 35.0,
                11.5, 27.5, 37.5,
                10.0, 20.0, 30.0,
                //
              ],
            ],
          ],
          type: Coords.xyz,
        ),
      );
    });

    test('MultiPolygon.parse', () {
      // a multi polygon with one polygon from 2D positions
      testMultiPolygon(
        MultiPolygon.parse(
          format: GeoJSON.geometry,
          '''
          {
            "type": "MultiPolygon",
            "coordinates": [
              [
                [
                  [10.0,20.0],
                  [12.5,22.5],
                  [15.0,25.0],
                  [11.5,27.5],
                  [10.0,20.0]
                ]
              ]
            ]
          }
          ''',
        ),
      );
      testMultiPolygon(
        MultiPolygon.parse(
          format: WKT.geometry,
          '''
          MULTIPOLYGON (
            (
              ( 
                10.0 20.0,
                12.5 22.5,
                15.0 25.0,
                11.5 27.5,
                10.0 20.0
              )
            )
          )
          ''',
        ),
      );

      // a multi polygon with one polygon from 3D positions
      testMultiPolygon(
        MultiPolygon.parse(
          format: GeoJSON.geometry,
          '''
          {
            "type": "MultiPolygon",
            "coordinates": [
              [
                [
                  [10.0,20.0,30.0],
                  [12.5,22.5,32.5],
                  [15.0,25.0,35.0],
                  [11.5,27.5,37.5],
                  [10.0,20.0,30.0]
                ]
              ]
            ]
          }
          ''',
        ),
      );
      testMultiPolygon(
        MultiPolygon.parse(
          format: WKT.geometry,
          '''
          MULTIPOLYGON Z (
            (
              ( 
                10.0 20.0 30.0,
                12.5 22.5 32.5,
                15.0 25.0 35.0,
                11.5 27.5 37.5,
                10.0 20.0 30.0
              )
            )
          )
          ''',
        ),
      );
    });

    test('MultiPolygon.parseCoords', () {
      // a multi polygon with one polygon from 2D positions
      testMultiPolygon(
        MultiPolygon.parseCoords(
          [
            // polygon
            [
              // an exterior ring with values of five (x, y) positions
              '10.0,20.0,'
                  '12.5,22.5,'
                  '15.0,25.0,'
                  '11.5,27.5,'
                  '10.0,20.0'
            ],
          ],
          type: Coords.xy,
        ),
      );

      // a multi polygon with one polygon from 3D positions
      testMultiPolygon(
        MultiPolygon.parseCoords(
          [
            // polygon
            [
              // an exterior ring with values of five (x, y, z) positions
              '10.0,20.0,30.0,'
                  '12.5,22.5,32.5,'
                  '15.0,25.0,35.0,'
                  '11.5,27.5,37.5,'
                  '10.0,20.0,30.0'
            ],
          ],
          type: Coords.xyz,
        ),
      );
      // a multi polygon with one polygon from 2D positions using an
      // alternative delimiter
      testMultiPolygon(
        MultiPolygon.parseCoords(
          [
            // polygon
            [
              // an exterior ring with values of five (x, y) positions
              '10.0;20.0;'
                  '12.5;22.5;'
                  '15.0;25.0;'
                  '11.5;27.5;'
                  '10.0;20.0'
            ],
          ],
          type: Coords.xy,
          delimiter: ';',
        ),
      );

      // a multi polygon with one polygon from 2D positions with x before y
      testMultiPolygon(
        MultiPolygon.parseCoords(
          [
            // polygon
            [
              // an exterior ring with values of five (x, y) positions
              '20.0,10.0,'
                  '22.5,12.5,'
                  '25.0,15.0,'
                  '27.5,11.5,'
                  '20.0,10.0'
            ],
          ],
          type: Coords.xy,
          swapXY: true,
        ),
      );

      // a multi polygon with one polygon from 2D positions with the
      // internal storage using single precision floating point numbers
      // (`Float32List` in this case)
      testMultiPolygon(
        MultiPolygon.parseCoords(
          [
            // polygon
            [
              // an exterior ring with values of five (x, y) positions
              '10.0,20.0,'
                  '12.5,22.5,'
                  '15.0,25.0,'
                  '11.5,27.5,'
                  '10.0,20.0'
            ],
          ],
          type: Coords.xy,
          singlePrecision: true,
        ),
      );
    });
  });

  group('GeometryCollection class', () {
    test('GeometryCollection.new', () {
      testGeometryCollection(
        GeometryCollection([
          // a point with a 2D position
          Point([10.0, 20.0].xy),

          // a point with a 3D position
          Point([10.0, 20.0, 30.0].xyz),

          // a line string from three 3D positions
          LineString.from([
            [10.0, 20.0, 30.0].xyz,
            [12.5, 22.5, 32.5].xyz,
            [15.0, 25.0, 35.0].xyz,
          ])
        ]),
      );
    });

    test('GeometryCollection.build', () {
      testGeometryCollection(
        GeometryCollection.build(
          count: 3,
          (GeometryContent geom) {
            geom
              // a point with a 2D position
              ..point([10.0, 20.0].xy)

              // a point with a 3D position
              ..point([10.0, 20.0, 30.0].xyz)

              // a line string from three 3D positions
              ..lineString(
                [
                  10.0, 20.0, 30.0,
                  12.5, 22.5, 32.5,
                  15.0, 25.0, 35.0,
                  //
                ].positions(Coords.xyz),
              );
          },
        ),
      );
    });

    test('GeometryCollection.parse', () {
      testGeometryCollection(
        GeometryCollection.parse(
          format: GeoJSON.geometry,
          '''
          {
            "type": "GeometryCollection",
            "geometries": [
              {"type": "Point", "coordinates": [10.0, 20.0]},
              {"type": "Point", "coordinates": [10.0, 20.0, 30.0]},
              {"type": "LineString",
                "coordinates": [
                  [10.0, 20.0, 30.0],
                  [12.5, 22.5, 32.5],
                  [15.0, 25.0, 35.0]
                ]
              }
            ]
          }
          ''',
        ),
      );
      testGeometryCollection(
        GeometryCollection.parse(
          format: WKT.geometry,
          '''
          GEOMETRYCOLLECTION (
            POINT (10.0 20.0),
            POINT Z (10.0 20.0 30.0),
            LINESTRING Z (
              (10.0 20.0 30.0),
              (12.5 22.5 32.5),
              (15.0 25.0 35.0)
            )
          )
          ''',
        ),
      );
    });
  });
}

/// Tests `Point` geometry.
void testPoint(Point point) {
  testPosition(point.position);
}

/// Tests `LineString` geometry.
void testLineString(LineString lineString) {
  testPositionSeries(lineString.chain);
}

/// Tests `Polygon` geometry.
void testPolygon(Polygon polygon, {int ringCount = 1}) {
  if (ringCount >= 1) {
    testPositionSeries(
      PositionSeries.from(polygon.exterior!.positions.take(3)),
    );
  }

  _doTestPolygon(polygon, ringCount: ringCount);
}

/// Tests `MultiPoint` geometry.
void testMultiPoint(MultiPoint multiPoint) {
  testPositionSeries(PositionSeries.from(multiPoint.positions));
}

/// Tests `MultiLineString` geometry.
void testMultiLineString(MultiLineString multiLineString) {
  testPositionSeries(multiLineString.chains.first);
}

/// Tests `MultiPolygon` geometry.
void testMultiPolygon(MultiPolygon multiPolygon) {
  testPolygon(multiPolygon.polygons.first);
  testPositionSeries(
    PositionSeries.from(multiPolygon.ringArrays.first.first.positions.take(3)),
  );
}

/// Tests `MultiGeometryCollection` geometry.
void testGeometryCollection(GeometryCollection collection) {
  testPoint(collection.geometries[0] as Point);
  testPoint(collection.geometries[1] as Point);
  testLineString(collection.geometries[2] as LineString);
}

void _doTestPolygon(Polygon polygon, {int ringCount = 1}) {
  expect(polygon.rings.length, ringCount);
  if (ringCount >= 1) {
    final exterior = polygon.exterior!;
    expect(exterior.positionCount, 5);
    expect(
      exterior.valuesByType(Coords.xy),
      [
        10.0, 20.0,
        12.5, 22.5,
        15.0, 25.0,
        11.5, 27.5,
        10.0, 20.0,
        //
      ],
    );

    if (ringCount >= 2) {
      final interior = polygon.interior.first;
      expect(interior.positionCount, 4);
      expect(interior.valuesByType(Coords.xy), [
        12.5, 23.0,
        11.5, 24.0,
        12.5, 24.0,
        12.5, 23.0,
        //
      ]);
    }
  }
}
