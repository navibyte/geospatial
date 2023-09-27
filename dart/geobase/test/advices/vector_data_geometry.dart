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
}

/// Tests `Point` geometry.
void testPoint(Point point) {
  testPosition(point.position);
}
