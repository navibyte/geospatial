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
      testBox(Box.view([10.0, 20.0, 15.0, 25.0]));

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      testBox(Box.view([10.0, 20.0, 30.0, 15.0, 25.0, 35.0]));

      // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
      // (need to specify the coordinate type XYM)
      testBox(
        Box.view([10.0, 20.0, 40.0, 15.0, 25.0, 45.0], type: Coords.xym),
      );

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      testBox(Box.view([10.0, 20.0, 30.0, 40.0, 15.0, 25.0, 35.0, 45.0]));
    });

    test('Box.create', () {
      // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
      testBox(Box.create(minX: 10.0, minY: 20.0, maxX: 15.0, maxY: 25.0));

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      testBox(
        Box.create(
          minX: 10.0, minY: 20.0, minZ: 30.0,
          maxX: 15.0, maxY: 25.0, maxZ: 35.0,
          //
        ),
      );

      // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
      testBox(
        Box.create(
          minX: 10.0, minY: 20.0, minM: 40.0,
          maxX: 15.0, maxY: 25.0, maxM: 45.0,
          //
        ),
      );

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      testBox(
        Box.create(
          minX: 10.0, minY: 20.0, minZ: 30.0, minM: 40.0,
          maxX: 15.0, maxY: 25.0, maxZ: 35.0, maxM: 45.0,
          //
        ),
      );
    });

    test('Box.from', () {
      // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
      testBox(
        Box.from(
          [
            Position.create(x: 10.0, y: 20.0),
            Position.create(x: 15.0, y: 25.0),
          ],
        ),
      );

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      testBox(
        Box.from(
          [
            Position.create(x: 10.0, y: 20.0, z: 30.0),
            Position.create(x: 15.0, y: 25.0, z: 35.0),
          ],
        ),
      );

      // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
      testBox(
        Box.from(
          [
            Position.create(x: 10.0, y: 20.0, m: 40.0),
            Position.create(x: 15.0, y: 25.0, m: 45.0),
          ],
        ),
      );

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      testBox(
        Box.from(
          [
            Position.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
            Position.create(x: 15.0, y: 25.0, z: 35.0, m: 45.0),
          ],
        ),
      );
    });

    test('Box.parse', () {
      // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
      testBox(Box.parse('10.0,20.0,15.0,25.0'));

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      testBox(Box.parse('10.0,20.0,30.0,15.0,25.0,35.0'));

      // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
      // (need to specify the coordinate type XYM)
      testBox(
        Box.parse('10.0,20.0,40.0,15.0,25.0,45.0', type: Coords.xym),
      );

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      testBox(Box.parse('10.0,20.0,30.0,40.0,15.0,25.0,35.0,45.0'));

      // a 2D box (x: 10.0..15.0, y: 20.0..25.0) using an alternative delimiter
      testBox(Box.parse('10.0;20.0;15.0;25.0', delimiter: ';'));

      // a 2D box (x: 10.0..15.0, y: 20.0..25.0) from an array with y before x
      testBox(Box.parse('20.0,10.0,25.0,15.0', swapXY: true));

      // a 2D box (x: 10.0..15.0, y: 20.0..25.0) with the internal storage using
      // single precision floating point numbers (`Float32List` in this case)
      testBox(Box.parse('10.0,20.0,15.0,25.0', singlePrecision: true));
    });
  });

  group('Box class from extensions', () {
    test('CoordinateArrayExtension.box', () {
      // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
      testBox([10.0, 20.0, 15.0, 25.0].box);

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      testBox([10.0, 20.0, 30.0, 15.0, 25.0, 35.0].box);

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      testBox([10.0, 20.0, 30.0, 40.0, 15.0, 25.0, 35.0, 45.0].box);
    });
  });

  group('ProjBox class', () {
    test('ProjBox.new', () {
      // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
      testProjBox(
        const ProjBox(minX: 10.0, minY: 20.0, maxX: 15.0, maxY: 25.0),
      );

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      testProjBox(
        const ProjBox(
          minX: 10.0, minY: 20.0, minZ: 30.0,
          maxX: 15.0, maxY: 25.0, maxZ: 35.0,
          //
        ),
      );

      // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
      testProjBox(
        const ProjBox(
          minX: 10.0, minY: 20.0, minM: 40.0,
          maxX: 15.0, maxY: 25.0, maxM: 45.0,
          //
        ),
      );

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      testProjBox(
        const ProjBox(
          minX: 10.0, minY: 20.0, minZ: 30.0, minM: 40.0,
          maxX: 15.0, maxY: 25.0, maxZ: 35.0, maxM: 45.0,
          //
        ),
      );
    });

    test('ProjBox.create', () {
      // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
      testProjBox(
        const ProjBox.create(minX: 10.0, minY: 20.0, maxX: 15.0, maxY: 25.0),
      );

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      testProjBox(
        const ProjBox.create(
          minX: 10.0, minY: 20.0, minZ: 30.0,
          maxX: 15.0, maxY: 25.0, maxZ: 35.0,
          //
        ),
      );

      // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
      testProjBox(
        const ProjBox.create(
          minX: 10.0, minY: 20.0, minM: 40.0,
          maxX: 15.0, maxY: 25.0, maxM: 45.0,
          //
        ),
      );

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      testProjBox(
        const ProjBox.create(
          minX: 10.0, minY: 20.0, minZ: 30.0, minM: 40.0,
          maxX: 15.0, maxY: 25.0, maxZ: 35.0, maxM: 45.0,
          //
        ),
      );
    });

    test('ProjBox.from', () {
      // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
      testProjBox(
        ProjBox.from(
          const [
            Projected(x: 10.0, y: 20.0),
            Projected(x: 15.0, y: 25.0),
          ],
        ),
      );

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      testProjBox(
        ProjBox.from(
          const [
            Projected(x: 10.0, y: 20.0, z: 30.0),
            Projected(x: 15.0, y: 25.0, z: 35.0),
          ],
        ),
      );

      // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
      testProjBox(
        ProjBox.from(
          const [
            Projected(x: 10.0, y: 20.0, m: 40.0),
            Projected(x: 15.0, y: 25.0, m: 45.0),
          ],
        ),
      );

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      testProjBox(
        ProjBox.from(
          const [
            Projected(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
            Projected(x: 15.0, y: 25.0, z: 35.0, m: 45.0),
          ],
        ),
      );
    });

    test('ProjBox.build', () {
      // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
      testProjBox(ProjBox.build([10.0, 20.0, 15.0, 25.0]));

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      testProjBox(ProjBox.build([10.0, 20.0, 30.0, 15.0, 25.0, 35.0]));

      // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
      // (need to specify the coordinate type XYM)
      testProjBox(
        ProjBox.build([10.0, 20.0, 40.0, 15.0, 25.0, 45.0], type: Coords.xym),
      );

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      testProjBox(
        ProjBox.build([10.0, 20.0, 30.0, 40.0, 15.0, 25.0, 35.0, 45.0]),
      );
    });

    test('ProjBox.parse', () {
      // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
      testProjBox(ProjBox.parse('10.0,20.0,15.0,25.0'));

      // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
      testProjBox(ProjBox.parse('10.0,20.0,30.0,15.0,25.0,35.0'));

      // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
      // (need to specify the coordinate type XYM)
      testProjBox(
        ProjBox.parse('10.0,20.0,40.0,15.0,25.0,45.0', type: Coords.xym),
      );

      // a measured 3D box
      // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
      testProjBox(ProjBox.parse('10.0,20.0,30.0,40.0,15.0,25.0,35.0,45.0'));

      // a 2D box (x: 10.0..15.0, y: 20.0..25.0) using an alternative delimiter
      testProjBox(ProjBox.parse('10.0;20.0;15.0;25.0', delimiter: ';'));

      // a 2D box (x: 10.0..15.0, y: 20.0..25.0) from an array with y before x
      testProjBox(ProjBox.parse('20.0,10.0,25.0,15.0', swapXY: true));
    });
  });

  group('GeoBox class', () {
    test('GeoBox.new', () {
      // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0)
      testGeoBox(
        const GeoBox(west: 10.0, south: 20.0, east: 15.0, north: 25.0),
      );

      // a 3D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0, elev: 30.0 .. 35.0)
      testGeoBox(
        const GeoBox(
          west: 10.0, south: 20.0, minElev: 30.0,
          east: 15.0, north: 25.0, maxElev: 35.0,
          //
        ),
      );

      // a measured 2D box (lon: 10.0..15.0, lat: 20.0..25.0, m: 40.0..45.0)
      testGeoBox(
        const GeoBox(
          west: 10.0, south: 20.0, minM: 40.0,
          east: 15.0, north: 25.0, maxM: 45.0,
          //
        ),
      );

      // a measured 3D box
      // (lon: 10.0..15.0, lat: 20.0..25.0, elev: 30.0..35.0, m: 40.0..45.0)
      testGeoBox(
        const GeoBox(
          west: 10.0, south: 20.0, minElev: 30.0, minM: 40.0,
          east: 15.0, north: 25.0, maxElev: 35.0, maxM: 45.0,
          //
        ),
      );
    });

    test('GeoBox.create', () {
      // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0)
      testGeoBox(
        const GeoBox.create(minX: 10.0, minY: 20.0, maxX: 15.0, maxY: 25.0),
      );

      // a 3D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0, elev: 30.0 .. 35.0)
      testGeoBox(
        const GeoBox.create(
          minX: 10.0, minY: 20.0, minZ: 30.0,
          maxX: 15.0, maxY: 25.0, maxZ: 35.0,
          //
        ),
      );

      // a measured 2D box (lon: 10.0..15.0, lat: 20.0..25.0, m: 40.0..45.0)
      testGeoBox(
        const GeoBox.create(
          minX: 10.0, minY: 20.0, minM: 40.0,
          maxX: 15.0, maxY: 25.0, maxM: 45.0,
          //
        ),
      );

      // a measured 3D box
      // (lon: 10.0..15.0, lat: 20.0..25.0, elev: 30.0..35.0, m: 40.0..45.0)
      testGeoBox(
        const GeoBox.create(
          minX: 10.0, minY: 20.0, minZ: 30.0, minM: 40.0,
          maxX: 15.0, maxY: 25.0, maxZ: 35.0, maxM: 45.0,
          //
        ),
      );
    });

    test('GeoBox.from', () {
      // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0)
      testGeoBox(
        GeoBox.from(
          const [
            Geographic(lon: 10.0, lat: 20.0),
            Geographic(lon: 15.0, lat: 25.0),
          ],
        ),
      );

      // a 3D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0, elev: 30.0 .. 35.0)
      testGeoBox(
        GeoBox.from(
          const [
            Geographic(lon: 10.0, lat: 20.0, elev: 30.0),
            Geographic(lon: 15.0, lat: 25.0, elev: 35.0),
          ],
        ),
      );

      // a measured 2D box (lon: 10.0..15.0, lat: 20.0..25.0, m: 40.0..45.0)
      testGeoBox(
        GeoBox.from(
          const [
            Geographic(lon: 10.0, lat: 20.0, m: 40.0),
            Geographic(lon: 15.0, lat: 25.0, m: 45.0),
          ],
        ),
      );

      // a measured 3D box
      // (lon: 10.0..15.0, lat: 20.0..25.0, elev: 30.0..35.0, m: 40.0..45.0)
      testGeoBox(
        GeoBox.from(
          const [
            Geographic(lon: 10.0, lat: 20.0, elev: 30.0, m: 40.0),
            Geographic(lon: 15.0, lat: 25.0, elev: 35.0, m: 45.0),
          ],
        ),
      );
    });

    test('GeoBox.build', () {
      // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0)
      testGeoBox(GeoBox.build([10.0, 20.0, 15.0, 25.0]));

      // a 3D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0, elev: 30.0 .. 35.0)
      testGeoBox(GeoBox.build([10.0, 20.0, 30.0, 15.0, 25.0, 35.0]));

      // a measured 2D box (lon: 10.0..15.0, lat: 20.0..25.0, m: 40.0..45.0)
      // (need to specify the coordinate type XYM)
      testGeoBox(
        GeoBox.build([10.0, 20.0, 40.0, 15.0, 25.0, 45.0], type: Coords.xym),
      );

      // a measured 3D box
      // (lon: 10.0..15.0, lat: 20.0..25.0, elev: 30.0..35.0, m: 40.0..45.0)
      testGeoBox(
        GeoBox.build([10.0, 20.0, 30.0, 40.0, 15.0, 25.0, 35.0, 45.0]),
      );
    });

    test('GeoBox.parse', () {
      // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0)
      testGeoBox(GeoBox.parse('10.0,20.0,15.0,25.0'));

      // a 3D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0, elev: 30.0 .. 35.0)
      testGeoBox(GeoBox.parse('10.0,20.0,30.0,15.0,25.0,35.0'));

      // a measured 2D box (lon: 10.0..15.0, lat: 20.0..25.0, m: 40.0..45.0)
      // (need to specify the coordinate type XYM)
      testGeoBox(
        GeoBox.parse('10.0,20.0,40.0,15.0,25.0,45.0', type: Coords.xym),
      );

      // a measured 3D box
      // (lon: 10.0..15.0, lat: 20.0..25.0, elev: 30.0..35.0, m: 40.0..45.0)
      testGeoBox(GeoBox.parse('10.0,20.0,30.0,40.0,15.0,25.0,35.0,45.0'));

      // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0) using an alternative
      // delimiter
      testGeoBox(GeoBox.parse('10.0;20.0;15.0;25.0', delimiter: ';'));

      // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0) from an array with y
      // (lat) before x (lon)
      testGeoBox(GeoBox.parse('20.0,10.0,25.0,15.0', swapXY: true));
    });
  });
}

/// Tests box instance of the base type `Box`.
void testBox(Box box) {
  _doTest(box);
  _doTest(box.copyTo(ProjBox.create));
  _doTest(box.copyTo(GeoBox.create));
}

/// Tests box instance of the sub type `ProjBox`.
void testProjBox(ProjBox box) {
  _doTest(box);
  _doTest(box.copyTo(Box.create));
  _doTest(box.copyTo(GeoBox.create));
}

/// Tests box instance of the sub type `GeoBox`.
void testGeoBox(GeoBox box) {
  _doTest(box);
  _doTest(box.copyTo(Box.create));
  _doTest(box.copyTo(ProjBox.create));
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
      expect(
        box.toText(compactNums: false),
        '10.0,20.0,30.0,40.0,15.0,25.0,35.0,45.0',
      );
      expect(
        box.toText(delimiter: ' '),
        '10 20 30 40 15 25 35 45',
      );
      expect(
        box.toText(swapXY: true),
        '20,10,30,40,25,15,35,45',
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
      expect(
        box.toText(decimals: 2, compactNums: false),
        '10.00,20.00,30.00,15.00,25.00,35.00',
      );
      expect(
        box.toText(delimiter: ' '),
        '10 20 30 15 25 35',
      );
      expect(
        box.toText(swapXY: true),
        '20,10,30,25,15,35',
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
      expect(box.toText(), '10,20,40,15,25,45');
      expect(
        box.toText(delimiter: ' '),
        '10 20 40 15 25 45',
      );
      expect(
        box.toText(swapXY: true),
        '20,10,40,25,15,45',
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
      expect(box.toText(), '10,20,15,25');
      expect(box.toText(delimiter: ' '), '10 20 15 25');
      expect(box.toText(swapXY: true), '20,10,25,15');
      expect(box.toText(decimals: 0), '10,20,15,25');
    }
    expect(box.equals3D(other), false);
    expect(box.equals3D(other, toleranceHoriz: 0.1), false);
    expect(box.equals3D(other, toleranceHoriz: 0.1, toleranceVert: 0.1), false);
  }
}
