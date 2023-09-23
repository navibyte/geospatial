// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_literals_to_create_immutables

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
}

/// Tests position instance of the base type `Position`.
void _testPosition(Position pos) {
  _doTest(pos);
  _doTest(pos.packed());
  _doTest(pos.copyTo(Projected.create));
  _doTest(pos.copyTo(Geographic.create));
}

/// Tests position instance of the sub type `Projected`.
void _testProjected(Projected pos) {
  _doTest(pos);
  _doTest(pos.copyTo(Position.create));
  _doTest(pos.copyTo(Geographic.create));
}

/// Tests position instance of the sub type `Geographic`.
void _testGeographic(Geographic pos) {
  _doTest(pos);
  _doTest(pos.copyTo(Position.create));
  _doTest(pos.copyTo(Projected.create));
}

/// Tests the sample position (x: 10.0, y: 20.0 + optiomnally z: 30.0 m: 40.0)
void _doTest(Position pos) {
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
