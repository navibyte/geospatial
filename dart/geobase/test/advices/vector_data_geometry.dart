// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_literals_to_create_immutables
// ignore_for_file: avoid_redundant_argument_values

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
          '{"type": "LineString", "coordinates": [[10.0,20.0], '
          '[12.5,22.5], [15.0,25.0]]}',
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
          '{"type": "LineString", "coordinates": [[10.0,20.0,30.0], '
          '[12.5,22.5,32.5], [15.0,25.0,35.0]]}',
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
          '{"type": "LineString", "coordinates": [[10.0,20.0,30.0,40.0], '
          '[12.5,22.5,32.5,42.5], [15.0,25.0,35.0,45.0]]}',
        ),
      );
      testLineString(
        LineString.parse(
          format: WKT.geometry,
          'LINESTRING ZM '
          '(10.0 20.0 30.0 40.0,12.5 22.5 32.5 42.5,15.0 25.0 35.0 45.0)',
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

      // a line string from2D positions with x before y
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
}

/// Tests `Point` geometry.
void testPoint(Point point) {
  testPosition(point.position);
}

/// Tests `LineString` geometry.
void testLineString(LineString lineString) {
  testPositionSeries(lineString.chain);
}
