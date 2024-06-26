// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_literals_to_create_immutables
// ignore_for_file: avoid_redundant_argument_values

import 'package:geobase/coordinates.dart';

import 'package:test/test.dart';

import 'basic_impls.dart';

void main() {
  group('Position class', () {
    test('Position.view', () {
      // create a 2D position (x: 10.0, y: 20.0)
      testPosition(Position.view([10.0, 20.0]));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testPosition(Position.view([10.0, 20.0, 30.0]));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      testPosition(Position.view([10.0, 20.0, 40.0], type: Coords.xym));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testPosition(Position.view([10.0, 20.0, 30.0, 40.0]));
    });

    test('Position.subview', () {
      // coordinate data with values: x0, y0, z0, m0, x1, y1, z1, m1
      final data = [-10.0, -20.0, -30.0, -40.0, 10.0, 20.0, 30.0, 40.0];

      // create a 2D position (x: 10.0, y: 20.0)
      // (the coordinate type is XY by default when using subview)
      testPosition(Position.subview(data, start: 4));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testPosition(Position.subview(data, start: 4, type: Coords.xyz));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testPosition(Position.subview(data, start: 4, type: Coords.xyzm));
    });

    test('Position.create', () {
      // create a 2D position (x: 10.0, y: 20.0)
      testPosition(Position.create(x: 10.0, y: 20.0));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testPosition(Position.create(x: 10.0, y: 20.0, z: 30.0));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      testPosition(Position.create(x: 10.0, y: 20.0, m: 40.0));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testPosition(Position.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0));
    });

    test('Position.parse', () {
      // create a 2D position (x: 10.0, y: 20.0)
      testPosition(Position.parse('10.0,20.0'));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testPosition(Position.parse('10.0,20.0,30.0'));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      testPosition(Position.parse('10.0,20.0,40.0', type: Coords.xym));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testPosition(Position.parse('10.0,20.0,30.0,40.0'));

      // create a 2D position (x: 10.0, y: 20.0) using an alternative delimiter
      testPosition(Position.parse('10.0;20.0', delimiter: ';'));

      // create a 2D position (x: 10.0, y: 20.0) from an array with y before x
      testPosition(Position.parse('20.0,10.0', swapXY: true));

      // create a 2D position (x: 10.0, y: 20.0) with the internal storage using
      // single precision floating point numbers (`Float32List` in this case)
      testPosition(Position.parse('10.0,20.0', singlePrecision: true));
    });
  });

  group('Position class from extensions', () {
    test('CoordinateArrayExtension.position', () {
      // a 2D position (x: 10.0, y: 20.0)
      testPosition([10.0, 20.0].position);

      // a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testPosition([10.0, 20.0, 30.0].position);

      // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testPosition([10.0, 20.0, 30.0, 40.0].position);
    });

    test('CoordinateArrayExtension.xy', () {
      // a 2D position (x: 10.0, y: 20.0)
      testPosition([10.0, 20.0].xy);
    });

    test('CoordinateArrayExtension.xyz', () {
      // a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testPosition([10.0, 20.0, 30.0].xyz);
    });

    test('CoordinateArrayExtension.xym', () {
      // a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      testPosition([10.0, 20.0, 40.0].xym);
    });

    test('CoordinateArrayExtension.xyzm', () {
      // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testPosition([10.0, 20.0, 30.0, 40.0].xyzm);
    });
  });

  group('Projected class', () {
    test('Projected.new', () {
      // create a 2D position (x: 10.0, y: 20.0)
      testProjected(const Projected(x: 10.0, y: 20.0));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testProjected(const Projected(x: 10.0, y: 20.0, z: 30.0));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      testProjected(const Projected(x: 10.0, y: 20.0, m: 40.0));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testProjected(
        const Projected(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
      );
    });

    test('Projected.create', () {
      // create a 2D position (x: 10.0, y: 20.0)
      testProjected(const Projected.create(x: 10.0, y: 20.0));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testProjected(const Projected.create(x: 10.0, y: 20.0, z: 30.0));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      testProjected(const Projected.create(x: 10.0, y: 20.0, m: 40.0));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testProjected(
        const Projected.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
      );
    });

    test('Projected.build', () {
      // create a 2D position (x: 10.0, y: 20.0)
      testPosition(Projected.build([10.0, 20.0]));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testPosition(Projected.build([10.0, 20.0, 30.0]));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      testPosition(
        Projected.build([10.0, 20.0, 40.0], type: Coords.xym),
      );

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testPosition(Projected.build([10.0, 20.0, 30.0, 40.0]));
    });

    test('Projected.parse', () {
      // create a 2D position (x: 10.0, y: 20.0)
      testProjected(Projected.parse('10.0,20.0'));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      testProjected(Projected.parse('10.0,20.0,30.0'));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      testProjected(Projected.parse('10.0,20.0,40.0', type: Coords.xym));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      testProjected(Projected.parse('10.0,20.0,30.0,40.0'));

      // create a 2D position (x: 10.0, y: 20.0) using an alternative delimiter
      testProjected(Projected.parse('10.0;20.0', delimiter: ';'));

      // create a 2D position (x: 10.0, y: 20.0) from an array with y before x
      testProjected(Projected.parse('20.0,10.0', swapXY: true));
    });
  });

  group('Geographic class', () {
    test('Geographic.new', () {
      // create a 2D position (lon: 10.0, lat: 20.0)
      testGeographic(const Geographic(lon: 10.0, lat: 20.0));

      // create a 3D position (lon: 10.0, lat: 20.0, elev: 30.0)
      testGeographic(const Geographic(lon: 10.0, lat: 20.0, elev: 30.0));

      // create a measured 2D position (lon: 10.0, lat: 20.0, m: 40.0)
      testGeographic(const Geographic(lon: 10.0, lat: 20.0, m: 40.0));

      // create a measured 3D position
      // (lon: 10.0, lat: 20.0, elev: 30.0, m: 40.0)
      testGeographic(
        const Geographic(lon: 10.0, lat: 20.0, elev: 30.0, m: 40.0),
      );
    });

    test('Geographic.create', () {
      // create a 2D position (lon: 10.0, lat: 20.0)
      testGeographic(const Geographic.create(x: 10.0, y: 20.0));

      // create a 3D position (lon: 10.0, lat: 20.0, elev: 30.0)
      testGeographic(const Geographic.create(x: 10.0, y: 20.0, z: 30.0));

      // create a measured 2D position (lon: 10.0, lat: 20.0, m: 40.0)
      testGeographic(const Geographic.create(x: 10.0, y: 20.0, m: 40.0));

      // create a measured 3D position
      // (lon: 10.0, lat: 20.0, elev: 30.0, m: 40.0)
      testGeographic(
        const Geographic.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
      );
    });

    test('Geographic.build', () {
      // create a 2D position (lon: 10.0, lat: 20.0)
      testGeographic(Geographic.build([10.0, 20.0]));

      // create a 3D position (lon: 10.0, lat: 20.0, elev: 30.0)
      testGeographic(Geographic.build([10.0, 20.0, 30.0]));

      // create a measured 2D position (lon: 10.0, lat: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      testGeographic(
        Geographic.build([10.0, 20.0, 40.0], type: Coords.xym),
      );

      // create a measured 3D position
      // (lon: 10.0, lat: 20.0, elev: 30.0, m: 40.0)
      testGeographic(Geographic.build([10.0, 20.0, 30.0, 40.0]));
    });

    test('Geographic.parse', () {
      // create a 2D position (lon: 10.0, lat: 20.0)
      testGeographic(Geographic.parse('10.0,20.0'));

      // create a 3D position (lon: 10.0, lat: 20.0, elev: 30.0)
      testGeographic(Geographic.parse('10.0,20.0,30.0'));

      // create a measured 2D position (lon: 10.0, lat: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      testGeographic(Geographic.parse('10.0,20.0,40.0', type: Coords.xym));

      // create a measured 3D position
      // (lon: 10.0, lat: 20.0, elev: 30.0, m: 40.0)
      testGeographic(Geographic.parse('10.0,20.0,30.0,40.0'));

      // create a 2D position (lon: 10.0, lat: 20.0) using an alternative
      // delimiter
      testGeographic(Geographic.parse('10.0;20.0', delimiter: ';'));

      // create a 2D position (lon: 10.0, lat: 20.0) from an array with y (lat)
      // before x (lon)
      testGeographic(Geographic.parse('20.0,10.0', swapXY: true));
    });
  });

  group('PositionSeries class', () {
    test('PositionSeries.view', () {
      // a series of 2D positions (with values of the `Coords.xy` type)
      testPositionSeries(
        PositionSeries.view(
          [
            10.0, 20.0, // (x, y) for position 0
            12.5, 22.5, // (x, y) for position 1
            15.0, 25.0, // (x, y) for position 2
          ],
          type: Coords.xy,
        ),
      );

      // a series of 3D positions (with values of the `Coords.xyz` type)
      testPositionSeries(
        PositionSeries.view(
          [
            10.0, 20.0, 30.0, // (x, y, z) for position 0
            12.5, 22.5, 32.5, // (x, y, z) for position 1
            15.0, 25.0, 35.0, // (x, y, z) for position 2
          ],
          type: Coords.xyz,
        ),
      );

      // a series of measured 2D positions (values of the `Coords.xym` type)
      testPositionSeries(
        PositionSeries.view(
          [
            10.0, 20.0, 40.0, // (x, y, m) for position 0
            12.5, 22.5, 42.5, // (x, y, m) for position 1
            15.0, 25.0, 45.0, // (x, y, m) for position 2
          ],
          type: Coords.xym,
        ),
      );

      // a series of measured 3D positions (values of the `Coords.xyzm` type)
      testPositionSeries(
        PositionSeries.view(
          [
            10.0, 20.0, 30.0, 40.0, // (x, y, z, m) for position 0
            12.5, 22.5, 32.5, 42.5, // (x, y, z, m) for position 1
            15.0, 25.0, 35.0, 45.0, // (x, y, z, m) for position 2
          ],
          type: Coords.xyzm,
        ),
      );
    });

    test('PositionSeries.from', () {
      // a series of 2D positions
      testPositionSeries(
        PositionSeries.from(
          [
            Position.create(x: 10.0, y: 20.0),
            Position.create(x: 12.5, y: 22.5),
            Position.create(x: 15.0, y: 25.0),
          ],
          type: Coords.xy,
        ),
      );

      // a series of 3D positions
      testPositionSeries(
        PositionSeries.from(
          [
            Position.create(x: 10.0, y: 20.0, z: 30.0),
            Position.create(x: 12.5, y: 22.5, z: 32.5),
            Position.create(x: 15.0, y: 25.0, z: 35.0),
          ],
          type: Coords.xyz,
        ),
      );

      // a series of measured 2D positions
      testPositionSeries(
        PositionSeries.from(
          [
            Position.create(x: 10.0, y: 20.0, m: 40.0),
            Position.create(x: 12.5, y: 22.5, m: 42.5),
            Position.create(x: 15.0, y: 25.0, m: 45.0),
          ],
          type: Coords.xym,
        ),
      );

      // a series of measured 3D positions
      testPositionSeries(
        PositionSeries.from(
          [
            Position.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
            Position.create(x: 12.5, y: 22.5, z: 32.5, m: 42.5),
            Position.create(x: 15.0, y: 25.0, z: 35.0, m: 45.0),
          ],
          type: Coords.xyzm,
        ),
      );
    });

    test('PositionSeries.parse', () {
      // a series of 2D positions (with values of the `Coords.xy` type)
      testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y) positions
          '10.0,20.0,12.5,22.5,15.0,25.0',
          type: Coords.xy,
        ),
      );

      // a series of 3D positions (with values of the `Coords.xyz` type)
      testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y, z) positions
          '10.0,20.0,30.0,12.5,22.5,32.5,15.0,25.0,35.0',
          type: Coords.xyz,
        ),
      );

      // a series of measured 2D positions (values of the `Coords.xym` type)
      testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y, m) positions
          '10.0,20.0,40.0,12.5,22.5,42.5,15.0,25.0,45.0',
          type: Coords.xym,
        ),
      );

      // a series of measured 3D positions (values of the `Coords.xyzm` type)
      testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y, z, m) positions
          '10.0,20.0,30.0,40.0,12.5,22.5,32.5,42.5,15.0,25.0,35.0,45.0',
          type: Coords.xyzm,
        ),
      );

      // a series of 2D positions (with values of the `Coords.xy` type) using
      // an alternative delimiter
      testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y) positions
          '10.0;20.0;12.5;22.5;15.0;25.0',
          type: Coords.xy,
          delimiter: ';',
        ),
      );

      // a series of 2D positions (with values of the `Coords.xy` type) with x
      // before y
      testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y) positions
          '20.0,10.0,22.5,12.5,25.0,15.0',
          type: Coords.xy,
          swapXY: true,
        ),
      );

      // a series of 2D positions (with values of the `Coords.xy` type) with the
      // internal storage using single precision floating point numbers
      // (`Float32List` in this case)
      testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y) positions
          '10.0,20.0,12.5,22.5,15.0,25.0',
          type: Coords.xy,
          singlePrecision: true,
        ),
      );
    });
  });

  group('PositionSeries class from extensions', () {
    test('CoordinateArrayExtension.positions', () {
      // a series of 2D positions (with values of the `Coords.xy` type)
      testPositionSeries(
        [
          10.0, 20.0, // (x, y) for position 0
          12.5, 22.5, // (x, y) for position 1
          15.0, 25.0, // (x, y) for position 2
        ].positions(Coords.xy),
      );

      // a series of 3D positions (with values of the `Coords.xyz` type)
      testPositionSeries(
        [
          10.0, 20.0, 30.0, // (x, y, z) for position 0
          12.5, 22.5, 32.5, // (x, y, z) for position 1
          15.0, 25.0, 35.0, // (x, y, z) for position 2
        ].positions(Coords.xyz),
      );

      // a series of measured 2D positions (values of the `Coords.xym` type)
      testPositionSeries(
        [
          10.0, 20.0, 40.0, // (x, y, m) for position 0
          12.5, 22.5, 42.5, // (x, y, m) for position 1
          15.0, 25.0, 45.0, // (x, y, m) for position 2
        ].positions(Coords.xym),
      );

      // a series of measured 3D positions (values of the `Coords.xyzm` type)
      testPositionSeries(
        [
          10.0, 20.0, 30.0, 40.0, // (x, y, z, m) for position 0
          12.5, 22.5, 32.5, 42.5, // (x, y, z, m) for position 1
          15.0, 25.0, 35.0, 45.0, // (x, y, z, m) for position 2
        ].positions(Coords.xyzm),
      );
    });

    test('PositionArrayExtension.series', () {
      // a series of 2D positions
      testPositionSeries(
        [
          Position.create(x: 10.0, y: 20.0),
          Position.create(x: 12.5, y: 22.5),
          Position.create(x: 15.0, y: 25.0),
        ].series(),
      );

      // a series of 3D positions
      testPositionSeries(
        [
          Position.create(x: 10.0, y: 20.0, z: 30.0),
          Position.create(x: 12.5, y: 22.5, z: 32.5),
          Position.create(x: 15.0, y: 25.0, z: 35.0),
        ].series(),
      );

      // a series of measured 2D positions
      testPositionSeries(
        [
          Position.create(x: 10.0, y: 20.0, m: 40.0),
          Position.create(x: 12.5, y: 22.5, m: 42.5),
          Position.create(x: 15.0, y: 25.0, m: 45.0),
        ].series(),
      );

      // a series of measured 3D positions
      testPositionSeries(
        [
          Position.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
          Position.create(x: 12.5, y: 22.5, z: 32.5, m: 42.5),
          Position.create(x: 15.0, y: 25.0, z: 35.0, m: 45.0),
        ].series(),
      );
    });
  });
}

/// Tests position instance of the base type `Position`.
void testPosition(Position pos) {
  _doTestPosition(pos);
  _doTestPosition(pos.packed());
  _doTestPosition(pos.copyTo(Projected.create));
  _doTestPosition(pos.copyTo(Geographic.create));
}

/// Tests position instance of the sub type `Projected`.
void testProjected(Projected pos) {
  _doTestPosition(pos);
  _doTestPosition(pos.copyTo(Position.create));
  _doTestPosition(pos.copyTo(Geographic.create));
}

/// Tests position instance of the sub type `Geographic`.
void testGeographic(Geographic pos) {
  _doTestPosition(pos);
  _doTestPosition(pos.copyTo(Position.create));
  _doTestPosition(pos.copyTo(Projected.create));
}

/// Tests the sample position (x: 10.0, y: 20.0 + optiomnally z: 30.0 m: 40.0)
void _doTestPosition(Position pos) {
  expect(pos.x, 10.0);
  expect(pos.y, 20.0);
  expect(pos.z, pos.is3D ? 30.0 : 0.0);
  expect(pos.optZ, pos.is3D ? 30.0 : isNull);
  expect(pos.m, pos.isMeasured ? 40.0 : 0.0);
  expect(pos.optM, pos.isMeasured ? 40.0 : isNull);
  expect(pos[0], 10.0);
  expect(pos[1], 20.0);
  expect(pos.valuesByType(Coords.xy), [10.0, 20.0]);
  expect(pos.copyByType(Coords.xy).values, [10.0, 20.0]);
  expect(pos.copyWith(x: 11.0).x, 11.0);
  expect(pos.copyWith(y: 21.0).y, 21.0);
  expect(
    pos.project(AddOneOnXYProjection()).valuesByType(Coords.xy),
    [11.0, 21.0],
  );
  expect(
    pos.transform(addOneOnXYTransform).valuesByType(Coords.xy),
    [11.0, 21.0],
  );
  final other = Position.create(x: 10.09, y: 20.09, z: 30.09);
  expect(pos.equals2D(other), false);
  expect(pos.equals2D(other, toleranceHoriz: 0.1), true);
  if (pos.is3D) {
    if (pos.isMeasured) {
      expect(pos[2], 30.0);
      expect(pos[3], 40.0);
      expect(pos.values, [10.0, 20.0, 30.0, 40.0]);
      expect(pos.valuesByType(Coords.xyz), [10.0, 20.0, 30.0]);
      expect(pos.valuesByType(Coords.xym), [10.0, 20.0, 40.0]);
      expect(pos.valuesByType(Coords.xyzm), [10.0, 20.0, 30.0, 40.0]);
      expect(pos.copyByType(Coords.xyz).values, [10.0, 20.0, 30.0]);
      expect(pos.copyByType(Coords.xym).values, [10.0, 20.0, 40.0]);
      expect(pos.copyByType(Coords.xyzm).values, [10.0, 20.0, 30.0, 40.0]);
      expect(pos.copyWith(x: 11.0).values, [11.0, 20.0, 30.0, 40.0]);
      expect(pos.copyWith(y: 21.0).values, [10.0, 21.0, 30.0, 40.0]);
      expect(pos.copyWith(z: 31.0).values, [10.0, 20.0, 31.0, 40.0]);
      expect(pos.copyWith(m: 41.0).values, [10.0, 20.0, 30.0, 41.0]);
      expect(pos.toText(compactNums: false), '10.0,20.0,30.0,40.0');
      expect(pos.toText(delimiter: ' '), '10 20 30 40');
      expect(pos.toText(swapXY: true), '20,10,30,40');
      expect(pos.toText(decimals: 0), '10,20,30,40');
      expect(pos.toText(decimals: 0, compactNums: false), '10,20,30,40');
      expect(
        pos.toText(decimals: 2, compactNums: false),
        '10.00,20.00,30.00,40.00',
      );
      expect(pos.toText(decimals: 2), '10,20,30,40');
    } else {
      expect(pos[2], 30.0);
      expect(pos[3], 0.0);
      expect(pos.values, [10.0, 20.0, 30.0]);
      expect(pos.valuesByType(Coords.xyz), [10.0, 20.0, 30.0]);
      expect(pos.valuesByType(Coords.xym), [10.0, 20.0, 0.0]);
      expect(pos.valuesByType(Coords.xyzm), [10.0, 20.0, 30.0, 0.0]);
      expect(pos.copyByType(Coords.xyz).values, [10.0, 20.0, 30.0]);
      expect(pos.copyByType(Coords.xym).values, [10.0, 20.0, 0.0]);
      expect(pos.copyByType(Coords.xyzm).values, [10.0, 20.0, 30.0, 0.0]);
      expect(pos.copyWith(x: 11.0).values, [11.0, 20.0, 30.0]);
      expect(pos.copyWith(y: 21.0).values, [10.0, 21.0, 30.0]);
      expect(pos.copyWith(z: 31.0).values, [10.0, 20.0, 31.0]);
      expect(pos.copyWith(m: 41.0).values, [10.0, 20.0, 30.0, 41.0]);
      expect(pos.toText(), '10,20,30');
    }
    expect(pos.equals3D(other), false);
    expect(pos.equals3D(other, toleranceHoriz: 0.1), false);
    expect(pos.equals3D(other, toleranceHoriz: 0.1, toleranceVert: 0.1), true);
  } else {
    if (pos.isMeasured) {
      expect(pos[2], 40.0);
      expect(pos[3], 0.0);
      expect(pos.values, [10.0, 20.0, 40.0]);
      expect(pos.valuesByType(Coords.xyz), [10.0, 20.0, 0.0]);
      expect(pos.valuesByType(Coords.xym), [10.0, 20.0, 40.0]);
      expect(pos.valuesByType(Coords.xyzm), [10.0, 20.0, 0.0, 40.0]);
      expect(pos.copyByType(Coords.xyz).values, [10.0, 20.0, 0.0]);
      expect(pos.copyByType(Coords.xym).values, [10.0, 20.0, 40.0]);
      expect(pos.copyByType(Coords.xyzm).values, [10.0, 20.0, 0.0, 40.0]);
      expect(pos.copyWith(x: 11.0).values, [11.0, 20.0, 40.0]);
      expect(pos.copyWith(y: 21.0).values, [10.0, 21.0, 40.0]);
      expect(pos.copyWith(z: 31.0).values, [10.0, 20.0, 31.0, 40.0]);
      expect(pos.copyWith(m: 41.0).values, [10.0, 20.0, 41.0]);
      expect(pos.toText(), '10,20,40');
    } else {
      expect(pos[2], 0.0);
      expect(pos[3], 0.0);
      expect(pos.values, [10.0, 20.0]);
      expect(pos.valuesByType(Coords.xyz), [10.0, 20.0, 0.0]);
      expect(pos.valuesByType(Coords.xym), [10.0, 20.0, 0.0]);
      expect(pos.valuesByType(Coords.xyzm), [10.0, 20.0, 0.0, 0.0]);
      expect(pos.copyByType(Coords.xyz).values, [10.0, 20.0, 0.0]);
      expect(pos.copyByType(Coords.xym).values, [10.0, 20.0, 0.0]);
      expect(pos.copyByType(Coords.xyzm).values, [10.0, 20.0, 0.0, 0.0]);
      expect(pos.copyWith(x: 11.0).values, [11.0, 20.0]);
      expect(pos.copyWith(y: 21.0).values, [10.0, 21.0]);
      expect(pos.copyWith(z: 31.0).values, [10.0, 20.0, 31.0]);
      expect(pos.copyWith(m: 41.0).values, [10.0, 20.0, 41.0]);
      expect(pos.toText(), '10,20');
    }
    expect(pos.equals3D(other), false);
    expect(pos.equals3D(other, toleranceHoriz: 0.1), false);
    expect(pos.equals3D(other, toleranceHoriz: 0.1, toleranceVert: 0.1), false);
  }
}

/// Tests position series instance of the base type `PositionSeries`.
void testPositionSeries(PositionSeries series) {
  // first position is sample of position test
  testPosition(series[0]);

  // tests for series
  _doTestPositionSeries(series, series.coordType);
  _doTestPositionSeries(series.packed(), series.coordType);
  _doTestPositionSeries(series.packed(type: Coords.xy), Coords.xy);
  _doTestPositionSeries(series.packed(singlePrecision: true), series.coordType);
}

/// Tests the sample position series.
void _doTestPositionSeries(PositionSeries series, Coords type) {
  expect(series.coordType, type);
  final positions = series.positions.toList(growable: false);
  final projPositions =
      series.positionsAs(to: Projected.create).toList(growable: false);
  final geomPositions =
      series.positionsAs(to: Geographic.create).toList(growable: false);
  final arrays = [
    positions,
    projPositions,
    geomPositions,
  ];
  expect(series.positionCount, 3);
  final other = PositionSeries.view(
    [
      10.09, 20.09, 30.09,
      12.59, 22.59, 32.59,
      15.09, 25.09, 35.09,
      //
    ],
    type: Coords.xyz,
  );
  expect(series.equals2D(other), false);
  expect(series.equals2D(other, toleranceHoriz: 0.1), true);
  final List<Position> expectedPositions;
  final Box expectedBox;
  if (series.is3D) {
    if (series.isMeasured) {
      expectedPositions = [
        [10.0, 20.0, 30.0, 40.0].xyzm,
        [12.5, 22.5, 32.5, 42.5].xyzm,
        [15.0, 25.0, 35.0, 45.0].xyzm,
      ];
      expectedBox = [10.0, 20.0, 30.0, 40.0, 15.0, 25.0, 35.0, 45.0].box;
      expect(
        series.equalsCoords(
          [
            10.0, 20.0, 30.0, 40.0,
            12.5, 22.5, 32.5, 42.5,
            15.0, 25.0, 35.0, 45.0,
            //
          ].positions(Coords.xyzm),
        ),
        true,
      );
      expect(series.values, [
        10.0, 20.0, 30.0, 40.0,
        12.5, 22.5, 32.5, 42.5,
        15.0, 25.0, 35.0, 45.0,
        //
      ]);
      expect(series.reversed().values, [
        15.0, 25.0, 35.0, 45.0,
        12.5, 22.5, 32.5, 42.5,
        10.0, 20.0, 30.0, 40.0,
        //
      ]);
      expect(series.range(0, 0).values, const <double>[]);
      expect(series.range(3, 5).values, const <double>[]);
      expect(series.range(0, 1).values, [
        10.0, 20.0, 30.0, 40.0,
        //
      ]);
      expect(series.range(1, 2).values, [
        12.5, 22.5, 32.5, 42.5,
        //
      ]);
      expect(series.range(1, 10).values, [
        12.5, 22.5, 32.5, 42.5,
        15.0, 25.0, 35.0, 45.0,
        //
      ]);
      expect(series.range(2).values, [
        15.0, 25.0, 35.0, 45.0,
        //
      ]);
      expect(series.reversed().range(2).values, [
        10.0, 20.0, 30.0, 40.0,
        //
      ]);
      expect(series.project(AddOneOnXYProjection()).values, [
        11.0, 21.0, 30.0, 40.0,
        13.5, 23.5, 32.5, 42.5,
        16.0, 26.0, 35.0, 45.0,
        //
      ]);
      expect(series.transform(addOneOnXYTransform).values, [
        11.0, 21.0, 30.0, 40.0,
        13.5, 23.5, 32.5, 42.5,
        16.0, 26.0, 35.0, 45.0,
        //
      ]);
      expect(series.valuesByType(Coords.xy), [
        10.0, 20.0,
        12.5, 22.5,
        15.0, 25.0,
        //
      ]);
      expect(series.valuesByType(Coords.xyz), [
        10.0, 20.0, 30.0,
        12.5, 22.5, 32.5,
        15.0, 25.0, 35.0,
        //
      ]);
      expect(series.valuesByType(Coords.xym), [
        10.0, 20.0, 40.0,
        12.5, 22.5, 42.5,
        15.0, 25.0, 45.0,
        //
      ]);
      expect(series.valuesByType(Coords.xyzm), [
        10.0, 20.0, 30.0, 40.0,
        12.5, 22.5, 32.5, 42.5,
        15.0, 25.0, 35.0, 45.0,
        //
      ]);
      expect(series.copyByType(Coords.xy).values, [
        10.0, 20.0,
        12.5, 22.5,
        15.0, 25.0,
        //
      ]);
      expect(series.copyByType(Coords.xyz).values, [
        10.0, 20.0, 30.0,
        12.5, 22.5, 32.5,
        15.0, 25.0, 35.0,
        //
      ]);
      expect(series.copyByType(Coords.xym).values, [
        10.0, 20.0, 40.0,
        12.5, 22.5, 42.5,
        15.0, 25.0, 45.0,
        //
      ]);
      expect(series.copyByType(Coords.xyzm).values, [
        10.0, 20.0, 30.0, 40.0,
        12.5, 22.5, 32.5, 42.5,
        15.0, 25.0, 35.0, 45.0,
        //
      ]);
      expect(
        series.toText(),
        '10,20,30,40,12.5,22.5,32.5,42.5,15,25,35,45',
      );
      expect(
        series.toText(delimiter: ';'),
        '10;20;30;40;12.5;22.5;32.5;42.5;15;25;35;45',
      );
      expect(
        series.toText(delimiter: ' ', positionDelimiter: ','),
        '10 20 30 40,12.5 22.5 32.5 42.5,15 25 35 45',
      );
      expect(
        series.toText(swapXY: true),
        '20,10,30,40,22.5,12.5,32.5,42.5,25,15,35,45',
      );
    } else {
      expectedPositions = [
        [10.0, 20.0, 30.0].xyz,
        [12.5, 22.5, 32.5].xyz,
        [15.0, 25.0, 35.0].xyz,
      ];
      expectedBox = [10.0, 20.0, 30.0, 15.0, 25.0, 35.0].box;
      expect(
        series.equalsCoords(
          [
            10.0, 20.0, 30.0,
            12.5, 22.5, 32.5,
            15.0, 25.0, 35.0,
            //
          ].positions(Coords.xyz),
        ),
        true,
      );

      expect(series.values, [
        10.0, 20.0, 30.0,
        12.5, 22.5, 32.5,
        15.0, 25.0, 35.0,
        //
      ]);
      expect(series.reversed().values, [
        15.0, 25.0, 35.0,
        12.5, 22.5, 32.5,
        10.0, 20.0, 30.0,
        //
      ]);
      expect(series.range(1, 2).values, [
        12.5, 22.5, 32.5,
        //
      ]);
      expect(series.project(AddOneOnXYProjection()).values, [
        11.0, 21.0, 30.0,
        13.5, 23.5, 32.5,
        16.0, 26.0, 35.0,
        //
      ]);
      expect(series.transform(addOneOnXYTransform).values, [
        11.0, 21.0, 30.0,
        13.5, 23.5, 32.5,
        16.0, 26.0, 35.0,
        //
      ]);
      expect(series.valuesByType(Coords.xy), [
        10.0, 20.0,
        12.5, 22.5,
        15.0, 25.0,
        //
      ]);
      expect(series.valuesByType(Coords.xyz), [
        10.0, 20.0, 30.0,
        12.5, 22.5, 32.5,
        15.0, 25.0, 35.0,
        //
      ]);
      expect(series.valuesByType(Coords.xym), [
        10.0, 20.0, 0.0,
        12.5, 22.5, 0.0,
        15.0, 25.0, 0.0,
        //
      ]);
      expect(series.valuesByType(Coords.xyzm), [
        10.0, 20.0, 30.0, 0.0,
        12.5, 22.5, 32.5, 0.0,
        15.0, 25.0, 35.0, 0.0,
        //
      ]);
      expect(series.copyByType(Coords.xy).values, [
        10.0, 20.0,
        12.5, 22.5,
        15.0, 25.0,
        //
      ]);
      expect(series.copyByType(Coords.xyz).values, [
        10.0, 20.0, 30.0,
        12.5, 22.5, 32.5,
        15.0, 25.0, 35.0,
        //
      ]);
      expect(series.copyByType(Coords.xym).values, [
        10.0, 20.0, 0.0,
        12.5, 22.5, 0.0,
        15.0, 25.0, 0.0,
        //
      ]);
      expect(series.copyByType(Coords.xyzm).values, [
        10.0, 20.0, 30.0, 0.0,
        12.5, 22.5, 32.5, 0.0,
        15.0, 25.0, 35.0, 0.0,
        //
      ]);
      expect(
        series.toText(),
        '10,20,30,12.5,22.5,32.5,15,25,35',
      );
    }
    expect(series.equals3D(other), false);
    expect(series.equals3D(other, toleranceHoriz: 0.1), false);
    expect(
      series.equals3D(other, toleranceHoriz: 0.1, toleranceVert: 0.1),
      true,
    );
  } else {
    if (series.isMeasured) {
      expectedPositions = [
        [10.0, 20.0, 40.0].xym,
        [12.5, 22.5, 42.5].xym,
        [15.0, 25.0, 45.0].xym,
      ];
      expectedBox =
          Box.view([10.0, 20.0, 40.0, 15.0, 25.0, 45.0], type: Coords.xym);
      expect(
        series.equalsCoords(
          [
            10.0, 20.0, 40.0,
            12.5, 22.5, 42.5,
            15.0, 25.0, 45.0,
            //
          ].positions(Coords.xym),
        ),
        true,
      );

      expect(series.values, [
        10.0, 20.0, 40.0,
        12.5, 22.5, 42.5,
        15.0, 25.0, 45.0,
        //
      ]);
      expect(series.reversed().values, [
        15.0, 25.0, 45.0,
        12.5, 22.5, 42.5,
        10.0, 20.0, 40.0,
        //
      ]);
      expect(series.range(1, 2).values, [
        12.5, 22.5, 42.5,
        //
      ]);
      expect(series.project(AddOneOnXYProjection()).values, [
        11.0, 21.0, 40.0,
        13.5, 23.5, 42.5,
        16.0, 26.0, 45.0,
        //
      ]);
      expect(series.transform(addOneOnXYTransform).values, [
        11.0, 21.0, 40.0,
        13.5, 23.5, 42.5,
        16.0, 26.0, 45.0,
        //
      ]);
      expect(series.valuesByType(Coords.xy), [
        10.0, 20.0,
        12.5, 22.5,
        15.0, 25.0,
        //
      ]);
      expect(series.valuesByType(Coords.xyz), [
        10.0, 20.0, 0.0,
        12.5, 22.5, 0.0,
        15.0, 25.0, 0.0,
        //
      ]);
      expect(series.valuesByType(Coords.xym), [
        10.0, 20.0, 40.0,
        12.5, 22.5, 42.5,
        15.0, 25.0, 45.0,
        //
      ]);
      expect(series.valuesByType(Coords.xyzm), [
        10.0, 20.0, 0.0, 40.0,
        12.5, 22.5, 0.0, 42.5,
        15.0, 25.0, 0.0, 45.0,
        //
      ]);
      expect(series.copyByType(Coords.xy).values, [
        10.0, 20.0,
        12.5, 22.5,
        15.0, 25.0,
        //
      ]);
      expect(series.copyByType(Coords.xyz).values, [
        10.0, 20.0, 0.0,
        12.5, 22.5, 0.0,
        15.0, 25.0, 0.0,
        //
      ]);
      expect(series.copyByType(Coords.xym).values, [
        10.0, 20.0, 40.0,
        12.5, 22.5, 42.5,
        15.0, 25.0, 45.0,
        //
      ]);
      expect(series.copyByType(Coords.xyzm).values, [
        10.0, 20.0, 0.0, 40.0,
        12.5, 22.5, 0.0, 42.5,
        15.0, 25.0, 0.0, 45.0,
        //
      ]);
      expect(
        series.toText(),
        '10,20,40,12.5,22.5,42.5,15,25,45',
      );
    } else {
      expectedPositions = [
        [10.0, 20.0].xy,
        [12.5, 22.5].xy,
        [15.0, 25.0].xy,
      ];
      expectedBox = [10.0, 20.0, 15.0, 25.0].box;
      expect(
        series.equalsCoords(
          [
            10.0, 20.0,
            12.5, 22.5,
            15.0, 25.0,
            //
          ].positions(Coords.xy),
        ),
        true,
      );
      expect(series.values, [
        10.0, 20.0,
        12.5, 22.5,
        15.0, 25.0,
        //
      ]);
      expect(series.reversed().values, [
        15.0, 25.0,
        12.5, 22.5,
        10.0, 20.0,
        //
      ]);
      expect(series.range(1, 2).values, [
        12.5, 22.5,
        //
      ]);
      expect(series.project(AddOneOnXYProjection()).values, [
        11.0, 21.0,
        13.5, 23.5,
        16.0, 26.0,
        //
      ]);
      expect(series.transform(addOneOnXYTransform).values, [
        11.0, 21.0,
        13.5, 23.5,
        16.0, 26.0,
        //
      ]);
      expect(series.valuesByType(Coords.xy), [
        10.0, 20.0,
        12.5, 22.5,
        15.0, 25.0,
        //
      ]);
      expect(series.valuesByType(Coords.xyz), [
        10.0, 20.0, 0.0,
        12.5, 22.5, 0.0,
        15.0, 25.0, 0.0,
        //
      ]);
      expect(series.valuesByType(Coords.xym), [
        10.0, 20.0, 0.0,
        12.5, 22.5, 0.0,
        15.0, 25.0, 0.0,
        //
      ]);
      expect(series.valuesByType(Coords.xyzm), [
        10.0, 20.0, 0.0, 0.0,
        12.5, 22.5, 0.0, 0.0,
        15.0, 25.0, 0.0, 0.0,
        //
      ]);
      expect(series.copyByType(Coords.xy).values, [
        10.0, 20.0,
        12.5, 22.5,
        15.0, 25.0,
        //
      ]);
      expect(series.copyByType(Coords.xyz).values, [
        10.0, 20.0, 0.0,
        12.5, 22.5, 0.0,
        15.0, 25.0, 0.0,
        //
      ]);
      expect(series.copyByType(Coords.xym).values, [
        10.0, 20.0, 0.0,
        12.5, 22.5, 0.0,
        15.0, 25.0, 0.0,
        //
      ]);
      expect(series.copyByType(Coords.xyzm).values, [
        10.0, 20.0, 0.0, 0.0,
        12.5, 22.5, 0.0, 0.0,
        15.0, 25.0, 0.0, 0.0,
        //
      ]);
      expect(
        series.toText(),
        '10,20,12.5,22.5,15,25',
      );
    }
    expect(series.equals3D(other), false);
    expect(series.equals3D(other, toleranceHoriz: 0.1), false);
    expect(
      series.equals3D(other, toleranceHoriz: 0.1, toleranceVert: 0.1),
      false,
    );
  }
  expect(series.firstOrNull, expectedPositions.first);
  expect(series.lastOrNull, expectedPositions.last);
  for (var i = 0; i < expectedPositions.length; i++) {
    final pos = expectedPositions[i];
    expect(series.x(i), pos.x);
    expect(series.y(i), pos.y);
    expect(series.z(i), pos.z);
    expect(series.optZ(i), pos.optZ);
    expect(series.m(i), pos.m);
    expect(series.optM(i), pos.optM);
    expect(series[i], pos);
    expect(series.get(i, to: Projected.create), pos);
    expect(series.get(i, to: Geographic.create), pos);
    for (var j = 0; j < arrays.length; j++) {
      expect(arrays[j][i], pos);
    }
  }

  for (final bb in [
    series.calculateBounds(scheme: Position.scheme),
    series.populated(scheme: Position.scheme).bounds,
    series
        .populated(scheme: Projected.scheme)
        .populated(scheme: Position.scheme)
        .bounds,
  ]) {
    expect(bb, expectedBox);
    expect(bb is Box, true);
    expect(bb.runtimeType.toString(), '_BoxCoords');
  }
  for (final bb in [
    series.calculateBounds(scheme: Projected.scheme),
    series.populated(scheme: Projected.scheme).bounds,
    series
        .populated(scheme: Geographic.scheme)
        .populated(scheme: Projected.scheme)
        .bounds,
  ]) {
    expect(bb, expectedBox);
    expect(bb is ProjBox, true);
    expect(bb.runtimeType.toString(), 'ProjBox');
  }
  for (final bb in [
    series.calculateBounds(scheme: Geographic.scheme),
    series.populated(scheme: Geographic.scheme).bounds,
    series
        .populated(scheme: Projected.scheme)
        .populated(scheme: Geographic.scheme)
        .bounds,
  ]) {
    expect(bb, expectedBox);
    expect(bb is GeoBox, true);
    expect(bb.runtimeType.toString(), 'GeoBox');
  }
  expect(series.populated(scheme: Position.scheme).unpopulated().bounds, null);
  expect(series.populated(scheme: Projected.scheme).unpopulated().bounds, null);
  expect(
    series.populated(scheme: Geographic.scheme).unpopulated().bounds,
    null,
  );
}
