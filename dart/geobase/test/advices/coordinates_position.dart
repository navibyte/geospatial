// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
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
      _testPosition(Position.view([10.0, 20.0]));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      _testPosition(Position.view([10.0, 20.0, 30.0]));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      _testPosition(Position.view([10.0, 20.0, 40.0], type: Coords.xym));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      _testPosition(Position.view([10.0, 20.0, 30.0, 40.0]));
    });

    test('Position.subview', () {
      // coordinate data with values: x0, y0, z0, m0, x1, y1, z1, m1
      final data = [-10.0, -20.0, -30.0, -40.0, 10.0, 20.0, 30.0, 40.0];

      // create a 2D position (x: 10.0, y: 20.0)
      // (the coordinate type is XY by default when using subview)
      _testPosition(Position.subview(data, start: 4));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      _testPosition(Position.subview(data, start: 4, type: Coords.xyz));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      _testPosition(Position.subview(data, start: 4, type: Coords.xyzm));
    });

    test('Position.create', () {
      // create a 2D position (x: 10.0, y: 20.0)
      _testPosition(Position.create(x: 10.0, y: 20.0));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      _testPosition(Position.create(x: 10.0, y: 20.0, z: 30.0));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      _testPosition(Position.create(x: 10.0, y: 20.0, m: 40.0));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      _testPosition(Position.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0));
    });

    test('Position.parse', () {
      // create a 2D position (x: 10.0, y: 20.0)
      _testPosition(Position.parse('10.0,20.0'));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      _testPosition(Position.parse('10.0,20.0,30.0'));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      _testPosition(Position.parse('10.0,20.0,40.0', type: Coords.xym));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      _testPosition(Position.parse('10.0,20.0,30.0,40.0'));

      // create a 2D position (x: 10.0, y: 20.0) using an alternative delimiter
      _testPosition(Position.parse('10.0;20.0', delimiter: ';'));

      // create a 2D position (x: 10.0, y: 20.0) from an array with y before x
      _testPosition(Position.parse('20.0,10.0', swapXY: true));

      // create a 2D position (x: 10.0, y: 20.0) with the internal storage using
      // single precision floating point numbers (`Float32List` in this case)
      _testPosition(Position.parse('10.0,20.0', singlePrecision: true));
    });
  });

  group('Position class from extensions', () {
    test('CoordinateArrayExtension.position', () {
      // a 2D position (x: 10.0, y: 20.0)
      _testPosition([10.0, 20.0].position);

      // a 3D position (x: 10.0, y: 20.0, z: 30.0)
      _testPosition([10.0, 20.0, 30.0].position);

      // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      _testPosition([10.0, 20.0, 30.0, 40.0].position);
    });

    test('CoordinateArrayExtension.xy', () {
      // a 2D position (x: 10.0, y: 20.0)
      _testPosition([10.0, 20.0].xy);
    });

    test('CoordinateArrayExtension.xyz', () {
      // a 3D position (x: 10.0, y: 20.0, z: 30.0)
      _testPosition([10.0, 20.0, 30.0].xyz);
    });

    test('CoordinateArrayExtension.xym', () {
      // a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      _testPosition([10.0, 20.0, 40.0].xym);
    });

    test('CoordinateArrayExtension.xyzm', () {
      // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      _testPosition([10.0, 20.0, 30.0, 40.0].xyzm);
    });
  });

  group('Projected class', () {
    test('Projected.new', () {
      // create a 2D position (x: 10.0, y: 20.0)
      _testProjected(const Projected(x: 10.0, y: 20.0));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      _testProjected(const Projected(x: 10.0, y: 20.0, z: 30.0));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      _testProjected(const Projected(x: 10.0, y: 20.0, m: 40.0));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      _testProjected(
        const Projected(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
      );
    });

    test('Projected.create', () {
      // create a 2D position (x: 10.0, y: 20.0)
      _testProjected(const Projected.create(x: 10.0, y: 20.0));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      _testProjected(const Projected.create(x: 10.0, y: 20.0, z: 30.0));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      _testProjected(const Projected.create(x: 10.0, y: 20.0, m: 40.0));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      _testProjected(
        const Projected.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
      );
    });

    test('Projected.build', () {
      // create a 2D position (x: 10.0, y: 20.0)
      _testPosition(Projected.build([10.0, 20.0]));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      _testPosition(Projected.build([10.0, 20.0, 30.0]));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      _testPosition(
        Projected.build([10.0, 20.0, 40.0], type: Coords.xym),
      );

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      _testPosition(Projected.build([10.0, 20.0, 30.0, 40.0]));
    });

    test('Projected.parse', () {
      // create a 2D position (x: 10.0, y: 20.0)
      _testProjected(Projected.parse('10.0,20.0'));

      // create a 3D position (x: 10.0, y: 20.0, z: 30.0)
      _testProjected(Projected.parse('10.0,20.0,30.0'));

      // create a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      _testProjected(Projected.parse('10.0,20.0,40.0', type: Coords.xym));

      // create a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
      _testProjected(Projected.parse('10.0,20.0,30.0,40.0'));

      // create a 2D position (x: 10.0, y: 20.0) using an alternative delimiter
      _testProjected(Projected.parse('10.0;20.0', delimiter: ';'));

      // create a 2D position (x: 10.0, y: 20.0) from an array with y before x
      _testProjected(Projected.parse('20.0,10.0', swapXY: true));
    });
  });

  group('Geographic class', () {
    test('Geographic.new', () {
      // create a 2D position (lon: 10.0, lat: 20.0)
      _testGeographic(const Geographic(lon: 10.0, lat: 20.0));

      // create a 3D position (lon: 10.0, lat: 20.0, elev: 30.0)
      _testGeographic(const Geographic(lon: 10.0, lat: 20.0, elev: 30.0));

      // create a measured 2D position (lon: 10.0, lat: 20.0, m: 40.0)
      _testGeographic(const Geographic(lon: 10.0, lat: 20.0, m: 40.0));

      // create a measured 3D position
      // (lon: 10.0, lat: 20.0, elev: 30.0, m: 40.0)
      _testGeographic(
        const Geographic(lon: 10.0, lat: 20.0, elev: 30.0, m: 40.0),
      );
    });

    test('Geographic.create', () {
      // create a 2D position (lon: 10.0, lat: 20.0)
      _testGeographic(const Geographic.create(x: 10.0, y: 20.0));

      // create a 3D position (lon: 10.0, lat: 20.0, elev: 30.0)
      _testGeographic(const Geographic.create(x: 10.0, y: 20.0, z: 30.0));

      // create a measured 2D position (lon: 10.0, lat: 20.0, m: 40.0)
      _testGeographic(const Geographic.create(x: 10.0, y: 20.0, m: 40.0));

      // create a measured 3D position
      // (lon: 10.0, lat: 20.0, elev: 30.0, m: 40.0)
      _testGeographic(
        const Geographic.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
      );
    });

    test('Geographic.build', () {
      // create a 2D position (lon: 10.0, lat: 20.0)
      _testGeographic(Geographic.build([10.0, 20.0]));

      // create a 3D position (lon: 10.0, lat: 20.0, elev: 30.0)
      _testGeographic(Geographic.build([10.0, 20.0, 30.0]));

      // create a measured 2D position (lon: 10.0, lat: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      _testGeographic(
        Geographic.build([10.0, 20.0, 40.0], type: Coords.xym),
      );

      // create a measured 3D position
      // (lon: 10.0, lat: 20.0, elev: 30.0, m: 40.0)
      _testGeographic(Geographic.build([10.0, 20.0, 30.0, 40.0]));
    });

    test('Geographic.parse', () {
      // create a 2D position (lon: 10.0, lat: 20.0)
      _testGeographic(Geographic.parse('10.0,20.0'));

      // create a 3D position (lon: 10.0, lat: 20.0, elev: 30.0)
      _testGeographic(Geographic.parse('10.0,20.0,30.0'));

      // create a measured 2D position (lon: 10.0, lat: 20.0, m: 40.0)
      // (need to specify the coordinate type XYM)
      _testGeographic(Geographic.parse('10.0,20.0,40.0', type: Coords.xym));

      // create a measured 3D position
      // (lon: 10.0, lat: 20.0, elev: 30.0, m: 40.0)
      _testGeographic(Geographic.parse('10.0,20.0,30.0,40.0'));

      // create a 2D position (lon: 10.0, lat: 20.0) using an alternative
      // delimiter
      _testGeographic(Geographic.parse('10.0;20.0', delimiter: ';'));

      // create a 2D position (lon: 10.0, lat: 20.0) from an array with y (lat)
      // before x (lon)
      _testGeographic(Geographic.parse('20.0,10.0', swapXY: true));
    });
  });

  group('PositionSeries class', () {
    test('PositionSeries.view', () {
      // a series of 2D positions (with values of the `Coords.xy` type)
      _testPositionSeries(
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
      _testPositionSeries(
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
      _testPositionSeries(
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
      _testPositionSeries(
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
      // a series of 2D positions (with values of the `Coords.xy` type)
      _testPositionSeries(
        PositionSeries.from(
          [
            Position.create(x: 10.0, y: 20.0),
            Position.create(x: 12.5, y: 22.5),
            Position.create(x: 15.0, y: 25.0),
          ],
          type: Coords.xy,
        ),
      );

      // a series of 3D positions (with values of the `Coords.xyz` type)
      _testPositionSeries(
        PositionSeries.from(
          [
            Position.create(x: 10.0, y: 20.0, z: 30.0),
            Position.create(x: 12.5, y: 22.5, z: 32.5),
            Position.create(x: 15.0, y: 25.0, z: 35.0),
          ],
          type: Coords.xyz,
        ),
      );

      // a series of measured 2D positions (values of the `Coords.xym` type)
      _testPositionSeries(
        PositionSeries.from(
          [
            Position.create(x: 10.0, y: 20.0, m: 40.0),
            Position.create(x: 12.5, y: 22.5, m: 42.5),
            Position.create(x: 15.0, y: 25.0, m: 45.0),
          ],
          type: Coords.xym,
        ),
      );

      // a series of measured 3D positions (values of the `Coords.xyzm` type)
      _testPositionSeries(
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
      _testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y) positions
          '10.0,20.0,12.5,22.5,15.0,25.0',
          type: Coords.xy,
        ),
      );

      // a series of 3D positions (with values of the `Coords.xyz` type)
      _testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y, z) positions
          '10.0,20.0,30.0,12.5,22.5,32.5,15.0,25.0,35.0',
          type: Coords.xyz,
        ),
      );

      // a series of measured 2D positions (values of the `Coords.xym` type)
      _testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y, m) positions
          '10.0,20.0,40.0,12.5,22.5,42.5,15.0,25.0,45.0',
          type: Coords.xym,
        ),
      );

      // a series of measured 3D positions (values of the `Coords.xyzm` type)
      _testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y, z, m) positions
          '10.0,20.0,30.0,40.0,12.5,22.5,32.5,42.5,15.0,25.0,35.0,45.0',
          type: Coords.xyzm,
        ),
      );

      // a series of 2D positions (with values of the `Coords.xy` type) using
      // an alternative delimiter
      _testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y) positions
          '10.0;20.0;12.5;22.5;15.0;25.0',
          type: Coords.xy,
          delimiter: ';',
        ),
      );

      // a series of 2D positions (with values of the `Coords.xy` type) with x
      // before y
      _testPositionSeries(
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
      _testPositionSeries(
        PositionSeries.parse(
          // values for three (x, y) positions
          '10.0,20.0,12.5,22.5,15.0,25.0',
          type: Coords.xy,
          singlePrecision: true,
        ),
      );
    });
  });
}

/// Tests position instance of the base type `Position`.
void _testPosition(Position pos) {
  _doTestPosition(pos);
  _doTestPosition(pos.packed());
  _doTestPosition(pos.copyTo(Projected.create));
  _doTestPosition(pos.copyTo(Geographic.create));
}

/// Tests position instance of the sub type `Projected`.
void _testProjected(Projected pos) {
  _doTestPosition(pos);
  _doTestPosition(pos.copyTo(Position.create));
  _doTestPosition(pos.copyTo(Geographic.create));
}

/// Tests position instance of the sub type `Geographic`.
void _testGeographic(Geographic pos) {
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
      expect(pos.toText(), '10.0,20.0,30.0,40.0');
      expect(pos.toText(delimiter: ' '), '10.0 20.0 30.0 40.0');
      expect(pos.toText(swapXY: true), '20.0,10.0,30.0,40.0');
      expect(pos.toText(decimals: 0), '10,20,30,40');
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
      expect(pos.toText(), '10.0,20.0,30.0');
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
      expect(pos.toText(), '10.0,20.0,40.0');
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
      expect(pos.toText(), '10.0,20.0');
    }
    expect(pos.equals3D(other), false);
    expect(pos.equals3D(other, toleranceHoriz: 0.1), false);
    expect(pos.equals3D(other, toleranceHoriz: 0.1, toleranceVert: 0.1), false);
  }
}

/// Tests position series instance of the base type `PositionSeries`.
void _testPositionSeries(PositionSeries series) {
  // first position is sample of position test
  _testPosition(series[0]);

  // tests for series
  _doTestPositionSeries(series);
}

/// Tests the sample position series.
void _doTestPositionSeries(PositionSeries series) {
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
  expect(series.length, 3);
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
  if (series.is3D) {
    if (series.isMeasured) {
      expectedPositions = [
        [10.0, 20.0, 30.0, 40.0].xyzm,
        [12.5, 22.5, 32.5, 42.5].xyzm,
        [15.0, 25.0, 35.0, 45.0].xyzm,
      ];
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
        '10.0,20.0,30.0,40.0,12.5,22.5,32.5,42.5,15.0,25.0,35.0,45.0',
      );
      expect(
        series.toText(delimiter: ';'),
        '10.0;20.0;30.0;40.0;12.5;22.5;32.5;42.5;15.0;25.0;35.0;45.0',
      );
      expect(
        series.toText(delimiter: ' ', positionDelimiter: ','),
        '10.0 20.0 30.0 40.0,12.5 22.5 32.5 42.5,15.0 25.0 35.0 45.0',
      );
      expect(
        series.toText(swapXY: true),
        '20.0,10.0,30.0,40.0,22.5,12.5,32.5,42.5,25.0,15.0,35.0,45.0',
      );
    } else {
      expectedPositions = [
        [10.0, 20.0, 30.0].xyz,
        [12.5, 22.5, 32.5].xyz,
        [15.0, 25.0, 35.0].xyz,
      ];
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
        '10.0,20.0,30.0,12.5,22.5,32.5,15.0,25.0,35.0',
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
        '10.0,20.0,40.0,12.5,22.5,42.5,15.0,25.0,45.0',
      );
    } else {
      expectedPositions = [
        [10.0, 20.0].xy,
        [12.5, 22.5].xy,
        [15.0, 25.0].xy,
      ];
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
        '10.0,20.0,12.5,22.5,15.0,25.0',
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
}
