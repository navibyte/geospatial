// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:geobase/coordinates.dart';

import 'package:test/test.dart';

void main() {
  group('Box class', () {
    test('Box.view', () {
      // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
      _testBox(Box.view([10.0, 20.0, 15.0, 25.0]));

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      _testBox(Box.view([10.0, 20.0, 30.0, 15.0, 25.0, 35.0]));

      // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
      // (need to specify the coordinate type XYM)
      _testBox(
        Box.view([10.0, 20.0, 40.0, 15.0, 25.0, 45.0], type: Coords.xym),
      );

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      _testBox(Box.view([10.0, 20.0, 30.0, 40.0, 15.0, 25.0, 35.0, 45.0]));
    });

    test('Box.create', () {
      // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
      _testBox(Box.create(minX: 10.0, minY: 20.0, maxX: 15.0, maxY: 25.0));

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      _testBox(
        Box.create(
          minX: 10.0, minY: 20.0, minZ: 30.0,
          maxX: 15.0, maxY: 25.0, maxZ: 35.0,
          //
        ),
      );

      // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
      _testBox(
        Box.create(
          minX: 10.0, minY: 20.0, minM: 40.0,
          maxX: 15.0, maxY: 25.0, maxM: 45.0,
          //
        ),
      );

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      _testBox(
        Box.create(
          minX: 10.0, minY: 20.0, minZ: 30.0, minM: 40.0,
          maxX: 15.0, maxY: 25.0, maxZ: 35.0, maxM: 45.0,
          //
        ),
      );
    });

    test('Box.parse', () {
      // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
      _testBox(Box.parse('10.0,20.0,15.0,25.0'));

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      _testBox(Box.parse('10.0,20.0,30.0,15.0,25.0,35.0'));

      // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
      // (need to specify the coordinate type XYM)
      _testBox(
        Box.parse('10.0,20.0,40.0,15.0,25.0,45.0', type: Coords.xym),
      );

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      _testBox(Box.parse('10.0,20.0,30.0,40.0,15.0,25.0,35.0,45.0'));

      // a 2D box (x: 10.0..15.0, y: 20.0..25.0) using an alternative delimiter
      _testBox(Box.parse('10.0;20.0;15.0;25.0', delimiter: ';'));

      // a 2D box (x: 10.0..15.0, y: 20.0..25.0) from an array with y before x
      _testBox(Box.parse('20.0,10.0,25.0,15.0', swapXY: true));

      // a 2D box (x: 10.0..15.0, y: 20.0..25.0) with the internal storage using
      // single precision floating point numbers (`Float32List` in this case)
      _testBox(Box.parse('10.0,20.0,15.0,25.0', singlePrecision: true));
    });
  });
}

/// Tests box instance of the base type `Box`.
void _testBox(Box box) {
  _doTest(box);
  _doTest(box.copyTo(ProjBox.create));
  _doTest(box.copyTo(GeoBox.create));
}

/// Tests the sample box
void _doTest(Box box) {
  expect(box.minX, 10.0);
  expect(box.minY, 20.0);
  expect(box.minZ, box.is3D ? 30.0 : isNull);
  expect(box.minM, box.isMeasured ? 40.0 : isNull);
  expect(box.maxX, 15.0);
  expect(box.maxY, 25.0);
  expect(box.maxZ, box.is3D ? 35.0 : isNull);
  expect(box.maxM, box.isMeasured ? 45.0 : isNull);

  final other = Box.create(
    minX: 10.09, minY: 20.09, minZ: 30.09,
    maxX: 15.09, maxY: 25.09, maxZ: 35.09,
    //
  );
  expect(box.equals2D(other), false);
  expect(box.equals2D(other, toleranceHoriz: 0.1), true);

  if (box.is3D) {
    if (box.isMeasured) {
      expect(box.values, [10.0, 20.0, 30.0, 40.0, 15.0, 25.0, 35.0, 45.0]);
      expect(box.valuesByType(Coords.xy), [10.0, 20.0, 15.0, 25.0]);
      expect(
        box.valuesByType(Coords.xyz),
        [10.0, 20.0, 30.0, 15.0, 25.0, 35.0],
      );
      expect(
        box.valuesByType(Coords.xym),
        [10.0, 20.0, 40.0, 15.0, 25.0, 45.0],
      );
      expect(
        box.valuesByType(Coords.xyzm),
        [10.0, 20.0, 30.0, 40.0, 15.0, 25.0, 35.0, 45.0],
      );
      expect(box.copyByType(Coords.xy).values, [10.0, 20.0, 15.0, 25.0]);
      expect(
        box.copyByType(Coords.xyz).values,
        [10.0, 20.0, 30.0, 15.0, 25.0, 35.0],
      );
      expect(
        box.copyByType(Coords.xym).values,
        [10.0, 20.0, 40.0, 15.0, 25.0, 45.0],
      );
      expect(
        box.copyByType(Coords.xyzm).values,
        [10.0, 20.0, 30.0, 40.0, 15.0, 25.0, 35.0, 45.0],
      );
      expect(
        box.copyWith(minX: 11.0, maxX: 16.0).values,
        [11.0, 20.0, 30.0, 40.0, 16.0, 25.0, 35.0, 45.0],
      );
      expect(
        box.copyWith(minY: 21.0, maxY: 26.0).values,
        [10.0, 21.0, 30.0, 40.0, 15.0, 26.0, 35.0, 45.0],
      );
      expect(
        box.copyWith(minZ: 31.0, maxZ: 36.0).values,
        [10.0, 20.0, 31.0, 40.0, 15.0, 25.0, 36.0, 45.0],
      );
      expect(
        box.copyWith(minM: 41.0, maxM: 46.0).values,
        [10.0, 20.0, 30.0, 41.0, 15.0, 25.0, 35.0, 46.0],
      );
      expect(box.toText(), '10.0,20.0,30.0,40.0,15.0,25.0,35.0,45.0');
      expect(
        box.toText(delimiter: ' '),
        '10.0 20.0 30.0 40.0 15.0 25.0 35.0 45.0',
      );
      expect(
        box.toText(swapXY: true),
        '20.0,10.0,30.0,40.0,25.0,15.0,35.0,45.0',
      );
      expect(box.toText(decimals: 0), '10,20,30,40,15,25,35,45');
    } else {
      expect(box.values, [10.0, 20.0, 30.0, 15.0, 25.0, 35.0]);
      expect(box.valuesByType(Coords.xy), [10.0, 20.0, 15.0, 25.0]);
      expect(
        box.valuesByType(Coords.xyz),
        [10.0, 20.0, 30.0, 15.0, 25.0, 35.0],
      );
      expect(
        box.valuesByType(Coords.xym),
        [10.0, 20.0, 0.0, 15.0, 25.0, 0.0],
      );
      expect(
        box.valuesByType(Coords.xyzm),
        [10.0, 20.0, 30.0, 0.0, 15.0, 25.0, 35.0, 0.0],
      );
      expect(box.copyByType(Coords.xy).values, [10.0, 20.0, 15.0, 25.0]);
      expect(
        box.copyByType(Coords.xyz).values,
        [10.0, 20.0, 30.0, 15.0, 25.0, 35.0],
      );
      expect(
        box.copyByType(Coords.xym).values,
        [10.0, 20.0, 0.0, 15.0, 25.0, 0.0],
      );
      expect(
        box.copyByType(Coords.xyzm).values,
        [10.0, 20.0, 30.0, 0.0, 15.0, 25.0, 35.0, 0.0],
      );
      expect(
        box.copyWith(minX: 11.0, maxX: 16.0).values,
        [11.0, 20.0, 30.0, 16.0, 25.0, 35.0],
      );
      expect(
        box.copyWith(minY: 21.0, maxY: 26.0).values,
        [10.0, 21.0, 30.0, 15.0, 26.0, 35.0],
      );
      expect(
        box.copyWith(minZ: 31.0, maxZ: 36.0).values,
        [10.0, 20.0, 31.0, 15.0, 25.0, 36.0],
      );
      expect(
        box.copyWith(minM: 41.0, maxM: 46.0).values,
        [10.0, 20.0, 30.0, 41.0, 15.0, 25.0, 35.0, 46.0],
      );
      expect(box.toText(), '10.0,20.0,30.0,15.0,25.0,35.0');
      expect(
        box.toText(delimiter: ' '),
        '10.0 20.0 30.0 15.0 25.0 35.0',
      );
      expect(
        box.toText(swapXY: true),
        '20.0,10.0,30.0,25.0,15.0,35.0',
      );
      expect(box.toText(decimals: 0), '10,20,30,15,25,35');
    }
    expect(box.equals3D(other), false);
    expect(box.equals3D(other, toleranceHoriz: 0.1), false);
    expect(box.equals3D(other, toleranceHoriz: 0.1, toleranceVert: 0.1), true);
  } else {
    if (box.isMeasured) {
      expect(box.values, [10.0, 20.0, 40.0, 15.0, 25.0, 45.0]);
      expect(box.valuesByType(Coords.xy), [10.0, 20.0, 15.0, 25.0]);
      expect(
        box.valuesByType(Coords.xyz),
        [10.0, 20.0, 0.0, 15.0, 25.0, 0.0],
      );
      expect(
        box.valuesByType(Coords.xym),
        [10.0, 20.0, 40.0, 15.0, 25.0, 45.0],
      );
      expect(
        box.valuesByType(Coords.xyzm),
        [10.0, 20.0, 0.0, 40.0, 15.0, 25.0, 0.0, 45.0],
      );
      expect(box.copyByType(Coords.xy).values, [10.0, 20.0, 15.0, 25.0]);
      expect(
        box.copyByType(Coords.xyz).values,
        [10.0, 20.0, 0.0, 15.0, 25.0, 0.0],
      );
      expect(
        box.copyByType(Coords.xym).values,
        [10.0, 20.0, 40.0, 15.0, 25.0, 45.0],
      );
      expect(
        box.copyByType(Coords.xyzm).values,
        [10.0, 20.0, 0.0, 40.0, 15.0, 25.0, 0.0, 45.0],
      );
      expect(
        box.copyWith(minX: 11.0, maxX: 16.0).values,
        [11.0, 20.0, 40.0, 16.0, 25.0, 45.0],
      );
      expect(
        box.copyWith(minY: 21.0, maxY: 26.0).values,
        [10.0, 21.0, 40.0, 15.0, 26.0, 45.0],
      );
      expect(
        box.copyWith(minZ: 31.0, maxZ: 36.0).values,
        [10.0, 20.0, 31.0, 40.0, 15.0, 25.0, 36.0, 45.0],
      );
      expect(
        box.copyWith(minM: 41.0, maxM: 46.0).values,
        [10.0, 20.0, 41.0, 15.0, 25.0, 46.0],
      );
      expect(box.toText(), '10.0,20.0,40.0,15.0,25.0,45.0');
      expect(
        box.toText(delimiter: ' '),
        '10.0 20.0 40.0 15.0 25.0 45.0',
      );
      expect(
        box.toText(swapXY: true),
        '20.0,10.0,40.0,25.0,15.0,45.0',
      );
      expect(box.toText(decimals: 0), '10,20,40,15,25,45');
    } else {
      expect(box.values, [10.0, 20.0, 15.0, 25.0]);
      expect(box.valuesByType(Coords.xy), [10.0, 20.0, 15.0, 25.0]);
      expect(
        box.valuesByType(Coords.xyz),
        [10.0, 20.0, 0.0, 15.0, 25.0, 0.0],
      );
      expect(
        box.valuesByType(Coords.xym),
        [10.0, 20.0, 0.0, 15.0, 25.0, 0.0],
      );
      expect(
        box.valuesByType(Coords.xyzm),
        [10.0, 20.0, 0.0, 0.0, 15.0, 25.0, 0.0, 0.0],
      );
      expect(box.copyByType(Coords.xy).values, [10.0, 20.0, 15.0, 25.0]);
      expect(
        box.copyByType(Coords.xyz).values,
        [10.0, 20.0, 0.0, 15.0, 25.0, 0.0],
      );
      expect(
        box.copyByType(Coords.xym).values,
        [10.0, 20.0, 0.0, 15.0, 25.0, 0.0],
      );
      expect(
        box.copyByType(Coords.xyzm).values,
        [10.0, 20.0, 0.0, 0.0, 15.0, 25.0, 0.0, 0.0],
      );
      expect(
        box.copyWith(minX: 11.0, maxX: 16.0).values,
        [11.0, 20.0, 16.0, 25.0],
      );
      expect(
        box.copyWith(minY: 21.0, maxY: 26.0).values,
        [10.0, 21.0, 15.0, 26.0],
      );
      expect(
        box.copyWith(minZ: 31.0, maxZ: 36.0).values,
        [10.0, 20.0, 31.0, 15.0, 25.0, 36.0],
      );
      expect(
        box.copyWith(minM: 41.0, maxM: 46.0).values,
        [10.0, 20.0, 41.0, 15.0, 25.0, 46.0],
      );
      expect(box.toText(), '10.0,20.0,15.0,25.0');
      expect(box.toText(delimiter: ' '), '10.0 20.0 15.0 25.0');
      expect(box.toText(swapXY: true), '20.0,10.0,25.0,15.0');
      expect(box.toText(decimals: 0), '10,20,15,25');
    }
    expect(box.equals3D(other), false);
    expect(box.equals3D(other, toleranceHoriz: 0.1), false);
    expect(box.equals3D(other, toleranceHoriz: 0.1, toleranceVert: 0.1), false);
  }
}
