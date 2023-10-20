// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: require_trailing_commas

import 'package:geobase/coordinates.dart';

import 'package:test/test.dart';

void main() {
  group('ProjBox class', () {
    test('Test factories', () {
      const box1 = ProjBox(
        minX: 1.1,
        minY: 1.2,
        maxX: 2.1,
        maxY: 2.2,
      );
      const box2 = ProjBox(
        minX: 1.1,
        minY: 1.2,
        minZ: 1.3,
        maxX: 2.1,
        maxY: 2.2,
        maxZ: 2.3,
      );
      const box3 = ProjBox(
        minX: 1.1,
        minY: 1.2,
        minM: 1.4,
        maxX: 2.1,
        maxY: 2.2,
        maxM: 2.4,
      );
      const box4 = ProjBox(
        minX: 1.1,
        minY: 1.2,
        minZ: 1.3,
        minM: 1.4,
        maxX: 2.1,
        maxY: 2.2,
        maxZ: 2.3,
        maxM: 2.4,
      );

      expect(ProjBox.build(const [1.1, 1.2, 2.1, 2.2]), box1);
      expect(ProjBox.parse('1.1,1.2,2.1,2.2'), box1);
      expect(ProjBox.parse(box1.toString()), box1);

      expect(ProjBox.build(const [1.1, 1.2, 1.3, 2.1, 2.2, 2.3]), box2);
      expect(ProjBox.parse('1.1,1.2,1.3,2.1,2.2,2.3'), box2);
      expect(ProjBox.parse(box2.toString()), box2);

      expect(ProjBox.build(const [1.1, 1.2, 1.4, 2.1, 2.2, 2.4]), isNot(box3));
      expect(
        ProjBox.parse('1.1,1.2,1.4,2.1,2.2,2.4', type: Coords.xym),
        box3,
      );
      expect(ProjBox.parse(box3.toString(), type: Coords.xym), box3);

      expect(
          ProjBox.build(const [1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4]), box4);
      expect(ProjBox.parse('1.1,1.2,1.3,1.4,2.1,2.2,2.3,2.4'), box4);
      expect(ProjBox.parse(box4.toString()), box4);

      expect(box1.copyWith(minX: 10.0),
          const ProjBox(minX: 10, minY: 1.2, maxX: 2.1, maxY: 2.2));
    });

    test('Equals with tolerance', () {
      const p1 = ProjBox(
        minX: 1.0002,
        minY: 2.0002,
        minZ: 3.002,
        maxX: 11.0002,
        maxY: 12.0002,
        maxZ: 13.002,
      );
      const p2 = ProjBox(
        minX: 1.0003,
        minY: 2.0003,
        minZ: 3.003,
        maxX: 11.0003,
        maxY: 12.0003,
        maxZ: 13.003,
      );
      expect(p1.equals2D(p2), false);
      expect(p1.equals3D(p2), false);
      expect(p1.equals2D(p2, toleranceHoriz: 0.00011), true);
      expect(p1.equals3D(p2, toleranceHoriz: 0.00011), false);
      expect(p1.equals2D(p2, toleranceHoriz: 0.00011), true);
      expect(
        p1.equals3D(p2, toleranceHoriz: 0.00011, toleranceVert: 0.0011),
        true,
      );
      expect(p1.equals2D(p2, toleranceHoriz: 0.00009), false);
      expect(
        p1.equals3D(p2, toleranceHoriz: 0.00011, toleranceVert: 0.0009),
        false,
      );
    });

    test('Corners', () {
      expect(
        const ProjBox(minX: 1, minY: 1, minZ: 1, maxX: 1, maxY: 1, maxZ: 1)
            .corners2D,
        [
          const Projected(x: 1, y: 1, z: 1),
        ],
      );
      expect(
        const ProjBox(minX: 1, minY: 1, minZ: 1, maxX: 1, maxY: 3, maxZ: 3)
            .corners2D,
        [
          const Projected(x: 1, y: 1, z: 1),
          const Projected(x: 1, y: 3, z: 3),
        ],
      );
      expect(
        const ProjBox(minX: 1, minY: 1, minZ: 1, maxX: 3, maxY: 3, maxZ: 3)
            .corners2D,
        [
          const Projected(x: 1, y: 1, z: 1),
          const Projected(x: 3, y: 1, z: 2),
          const Projected(x: 3, y: 3, z: 3),
          const Projected(x: 1, y: 3, z: 2),
        ],
      );
    });

    test('Create from positions', () {
      expect(
        ProjBox.from(const [
          Projected(x: 1, y: 1, z: 1),
        ]),
        const ProjBox(minX: 1, minY: 1, minZ: 1, maxX: 1, maxY: 1, maxZ: 1),
      );
      expect(
        ProjBox.from(const [
          Projected(x: 1, y: 1, z: 1),
          Projected(x: 1, y: 3, z: 3),
        ]),
        const ProjBox(minX: 1, minY: 1, minZ: 1, maxX: 1, maxY: 3, maxZ: 3),
      );
      expect(
        ProjBox.from(const [
          Projected(x: 1, y: 1, z: 1),
          Projected(x: 3, y: 1, z: 2),
          Projected(x: 3, y: 3, z: 3),
          Projected(x: 1, y: 3, z: 2),
        ]),
        const ProjBox(minX: 1, minY: 1, minZ: 1, maxX: 3, maxY: 3, maxZ: 3),
      );
      expect(
        ProjBox.from(const [
          Projected(x: 3, y: 134, z: 21, m: -23),
          Projected(x: -13, y: 38.48, z: 19.224, m: -10.5),
          Projected(x: 14.2, y: 94, z: 31, m: -0.4),
        ]),
        const ProjBox(
          minX: -13,
          minY: 38.48,
          minZ: 19.224,
          minM: -23,
          maxX: 14.2,
          maxY: 134,
          maxZ: 31,
          maxM: -0.4,
        ),
      );
    });

    test('Test interacts', () {
      const box1 = ProjBox(minX: 1.1, minY: 1.1, maxX: 2.2, maxY: 2.2);
      const box2 = ProjBox(minX: 2.0, minY: 1.1, maxX: 3.2, maxY: 2.2);
      const box3 = ProjBox(minX: 2.3, minY: 1.1, maxX: 3.2, maxY: 2.2);
      const box4 = ProjBox(minX: 1.2, minY: 1.2, maxX: 2.1, maxY: 2.1);

      expect(box1.intersects2D(box2), true);
      expect(box1.intersects2D(box3), false);
      expect(box2.intersects2D(box3), true);
      expect(box1.intersects2D(box4), true);
      expect(box1.intersects(box2), true);
      expect(box1.intersects(box3), false);
      expect(box2.intersects(box3), true);
      expect(box1.intersects(box4), true);

      const box1b = ProjBox(
          minX: 1.1, minY: 1.1, maxX: 2.2, maxY: 2.2, minZ: 1.1, maxZ: 2.2);

      expect(box1b.intersects2D(box2), true);
      expect(box1b.intersects2D(box3), false);
      expect(box1b.intersects2D(box4), true);
      expect(box1b.intersects(box2), false);
      expect(box1b.intersects(box3), false);
      expect(box1b.intersects(box4), false);

      const box2b = ProjBox(
          minX: 2.0, minY: 1.1, maxX: 3.2, maxY: 2.2, minZ: 0.5, maxZ: 1.0);

      expect(box1b.intersects2D(box2b), true);
      expect(box1b.intersects(box2b), false);

      const box2c = ProjBox(
          minX: 2.0, minY: 1.1, maxX: 3.2, maxY: 2.2, minZ: 0.5, maxZ: 3.5);

      expect(box1b.intersects2D(box2c), true);
      expect(box1b.intersects(box2c), true);

      const box2d = ProjBox(
          minX: 2.0,
          minY: 1.1,
          maxX: 3.2,
          maxY: 2.2,
          minZ: 0.5,
          maxZ: 3.5,
          minM: 4.0,
          maxM: 5.0);

      expect(box1b.intersects2D(box2d), true);
      expect(box1b.intersects(box2d), false);

      const box2e = ProjBox(
          minX: 2.0,
          minY: 1.1,
          maxX: 3.2,
          maxY: 2.2,
          minZ: 0.5,
          maxZ: 3.5,
          minM: 3.0,
          maxM: 4.0);

      expect(box2d.intersects2D(box2e), true);
      expect(box2d.intersects(box2e), true);

      const point1 = Projected(x: 2.05, y: 1.1);
      const point2 = Projected(x: 2.05, y: 2.2000000001);

      expect(box1.intersectsPoint(point1), true);
      expect(box1.intersectsPoint(point2), false);
      expect(box1.intersectsPoint2D(point1), true);
      expect(box1.intersectsPoint2D(point2), false);

      expect(box2e.intersectsPoint(point1), false);
      expect(box2e.intersectsPoint(point2), false);
      expect(box2e.intersectsPoint2D(point1), true);
      expect(box2e.intersectsPoint2D(point2), false);

      const point3 = Projected(x: 2.05, y: 1.1, z: 3.5, m: 3.3);

      expect(box2e.intersectsPoint(point3), true);
      expect(box2e.intersectsPoint2D(point3), true);
    });

    test('Aligned positions', () {
      const box = ProjBox(minX: 10.1, minY: 10.1, maxX: 20.1, maxY: 20.1);

      expect(
          box.aligned2D().equals2D(const Projected(x: 15.1, y: 15.1),
              toleranceHoriz: 0.00000000001),
          true);
      expect(
          box.aligned2D(Aligned.centerEast).equals2D(
              const Projected(x: 20.1, y: 15.1),
              toleranceHoriz: 0.00000000001),
          true);
      expect(
          box.aligned2D(Aligned.southWest).equals2D(
              const Projected(x: 10.1, y: 10.1),
              toleranceHoriz: 0.00000000001),
          true);
      expect(
          box.aligned2D(const Aligned(x: 1.5, y: -2.0)).equals2D(
              const Projected(x: 22.6, y: 5.1),
              toleranceHoriz: 0.00000000001),
          true);
    });

    test('Merge and boxes', () {
      const b1 = ProjBox(minX: 10.1, minY: 10.1, maxX: 20.1, maxY: 20.1);
      const b2 = ProjBox(minX: 15.1, minY: 30.1, maxX: 25.1, maxY: 40.1);
      const b3 = ProjBox(minX: 10.1, minY: 10.1, maxX: 25.1, maxY: 40.1);

      expect(b1.merge(b2), b3);
      expect(b2.merge(b1), b3);
      expect(b1.copyWith(minZ: 5.1, maxZ: 6.1).merge(b2), b3);
      expect(
        b1
            .copyWith(minZ: 5.1, maxZ: 6.1)
            .merge(b2)
            .copyWith(minZ: -5.1, maxZ: 16.1),
        b3.copyWith(minZ: -5.1, maxZ: 16.1),
      );

      expect(b1.splitUnambiguously(), [b1]);
      expect(b2.splitUnambiguously(), [b2]);
      expect(b3.splitUnambiguously(), [b3]);
    });
  });

  group('GeoBox class', () {
    test('Test factories', () {
      const box1 = GeoBox(
        west: 1.1,
        south: 1.2,
        east: 2.1,
        north: 2.2,
      );
      const box2 = GeoBox(
        west: 1.1,
        south: 1.2,
        minElev: 1.3,
        east: 2.1,
        north: 2.2,
        maxElev: 2.3,
      );
      const box3 = GeoBox(
        west: 1.1,
        south: 1.2,
        minM: 1.4,
        east: 2.1,
        north: 2.2,
        maxM: 2.4,
      );
      const box4 = GeoBox(
        west: 1.1,
        south: 1.2,
        minElev: 1.3,
        minM: 1.4,
        east: 2.1,
        north: 2.2,
        maxElev: 2.3,
        maxM: 2.4,
      );

      expect(GeoBox.build(const [1.1, 1.2, 2.1, 2.2]), box1);
      expect(GeoBox.parse('1.1,1.2,2.1,2.2'), box1);
      expect(GeoBox.parse(box1.toString()), box1);

      expect(GeoBox.build(const [1.1, 1.2, 1.3, 2.1, 2.2, 2.3]), box2);
      expect(GeoBox.parse('1.1,1.2,1.3,2.1,2.2,2.3'), box2);
      expect(GeoBox.parse(box2.toString()), box2);

      expect(GeoBox.build(const [1.1, 1.2, 1.4, 2.1, 2.2, 2.4]), isNot(box3));
      expect(
        GeoBox.parse('1.1,1.2,1.4,2.1,2.2,2.4', type: Coords.xym),
        box3,
      );
      expect(GeoBox.parse(box3.toString(), type: Coords.xym), box3);

      expect(
          GeoBox.build(const [1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4]), box4);
      expect(GeoBox.parse('1.1,1.2,1.3,1.4,2.1,2.2,2.3,2.4'), box4);
      expect(GeoBox.parse(box4.toString()), box4);

      expect(box1.copyWith(minY: 10.0),
          const GeoBox(west: 1.1, south: 10.0, east: 2.1, north: 2.2));
    });

    test('Equals with tolerance', () {
      const p1 = GeoBox(
        east: 1.0002,
        south: 2.0002,
        minElev: 3.002,
        west: 11.0002,
        north: 12.0002,
        maxElev: 13.002,
      );
      const p2 = GeoBox(
        east: 1.0003,
        south: 2.0003,
        minElev: 3.003,
        west: 11.0003,
        north: 12.0003,
        maxElev: 13.003,
      );
      expect(p1.equals2D(p2), false);
      expect(p1.equals3D(p2), false);
      expect(p1.equals2D(p2, toleranceHoriz: 0.00011), true);
      expect(p1.equals3D(p2, toleranceHoriz: 0.00011), false);
      expect(p1.equals2D(p2, toleranceHoriz: 0.00011), true);
      expect(
        p1.equals3D(p2, toleranceHoriz: 0.00011, toleranceVert: 0.0011),
        true,
      );
      expect(p1.equals2D(p2, toleranceHoriz: 0.00009), false);
      expect(
        p1.equals3D(p2, toleranceHoriz: 0.00011, toleranceVert: 0.0009),
        false,
      );
    });

    test('Corners', () {
      expect(
        const GeoBox(west: 1, south: 1, minM: 1, east: 1, north: 1, maxM: 1)
            .corners2D,
        [
          const Geographic(lon: 1, lat: 1, m: 1),
        ],
      );
      expect(
        const GeoBox(west: 1, south: 1, minM: 1, east: 3, north: 1, maxM: 3)
            .corners2D,
        [
          const Geographic(lon: 1, lat: 1, m: 1),
          const Geographic(lon: 3, lat: 1, m: 3),
        ],
      );
      expect(
        const GeoBox(west: 1, south: 1, minM: 1, east: 3, north: 3, maxM: 3)
            .corners2D,
        [
          const Geographic(lon: 1, lat: 1, m: 1),
          const Geographic(lon: 3, lat: 1, m: 2),
          const Geographic(lon: 3, lat: 3, m: 3),
          const Geographic(lon: 1, lat: 3, m: 2),
        ],
      );
    });

    test('Merge and split boxes', () {
      const b1 = GeoBox.create(minX: 10.1, minY: 10.1, maxX: 20.1, maxY: 20.1);
      const b2 = GeoBox.create(minX: 15.1, minY: 30.1, maxX: 25.1, maxY: 40.1);
      const b3 = GeoBox.create(minX: 10.1, minY: 10.1, maxX: 25.1, maxY: 40.1);
      const b4 =
          GeoBox.create(minX: 176.5, minY: 10.1, maxX: -164.5, maxY: 20.1);
      const b5 =
          GeoBox.create(minX: 170.1, minY: 30.1, maxX: 179.1, maxY: 40.1);
      const b6 =
          GeoBox.create(minX: 170.1, minY: 10.1, maxX: -164.5, maxY: 40.1);

      expect(b1.merge(b2), b3);
      expect(b2.merge(b1), b3);
      expect(b1.copyWith(minZ: 5.1, maxZ: 6.1).merge(b2), b3);
      expect(
        b1
            .copyWith(minZ: 5.1, maxZ: 6.1)
            .merge(b2)
            .copyWith(minZ: -5.1, maxZ: 16.1),
        b3.copyWith(minZ: -5.1, maxZ: 16.1),
      );
      expect(b4.merge(b5), b6);
      expect(b5.merge(b4), b6);

      expect(b1.splitUnambiguously(), [b1]);
      expect(b2.splitUnambiguously(), [b2]);
      expect(b3.splitUnambiguously(), [b3]);
      expect(b4.splitUnambiguously(), const [
        GeoBox.create(minX: 176.5, minY: 10.1, maxX: 180.0, maxY: 20.1),
        GeoBox.create(minX: -180.0, minY: 10.1, maxX: -164.5, maxY: 20.1),
      ]);
      expect(b5.splitUnambiguously(), [b5]);
      expect(b6.splitUnambiguously(), const [
        GeoBox.create(minX: 170.1, minY: 10.1, maxX: 180.0, maxY: 40.1),
        GeoBox.create(minX: -180.0, minY: 10.1, maxX: -164.5, maxY: 40.1),
      ]);
    });

    test('Dms for documentation examples', () {
      final box = GeoBox.parseDms(
          west: '20°W', south: '50°N', east: '20°E', north: '60°N');
      const dm0 = Dms(type: DmsType.degMin, decimals: 0, zeroPadMinSec: false);
      expect(
        '${box.westDms(dm0)} ${box.southDms(dm0)}'
            ' ${box.eastDms(dm0)} ${box.northDms(dm0)}',
        '20°0′W 50°0′N 20°0′E 60°0′N',
      );
    });
  });

  group('Other tests', () {
    test('Coordinate order', () {
      // XY
      _testCoordinateOrder('1.0,2.0,11.0,12.0', [1.0, 2.0, 11.0, 12.0]);
      _testCoordinateOrder(
          '1.0,2.0,11.0,12.0', [1.0, 2.0, 11.0, 12.0], Coords.xy);

      // XYZ
      _testCoordinateOrder(
          '1.0,2.0,3.0,11.0,12.0,13.0', [1.0, 2.0, 3.0, 11.0, 12.0, 13.0]);
      _testCoordinateOrder('1.0,2.0,3.0,11.0,12.0,13.0',
          [1.0, 2.0, 3.0, 11.0, 12.0, 13.0], Coords.xyz);

      // XYM
      _testCoordinateOrder('1.0,2.0,4.0,11.0,12.0,14.0',
          [1.0, 2.0, 4.0, 11.0, 12.0, 14.0], Coords.xym);

      // XYZM
      _testCoordinateOrder('1.0,2.0,3.0,4.0,11.0,12.0,13.0,14.0',
          [1.0, 2.0, 3.0, 4.0, 11.0, 12.0, 13.0, 14.0]);
      _testCoordinateOrder('1.0,2.0,3.0,4.0,11.0,12.0,13.0,14.0',
          [1.0, 2.0, 3.0, 4.0, 11.0, 12.0, 13.0, 14.0], Coords.xyzm);
    });

    test('Swapping x and y', () {
      expect(
        GeoBox.parse('1.1,1.2,2.1,2.2').toText(swapXY: true),
        '1.2,1.1,2.2,2.1',
      );
      expect(
        GeoBox.parse('1.1,1.2,1.3,2.1,2.2,2.3').toText(swapXY: true),
        '1.2,1.1,1.3,2.2,2.1,2.3',
      );
      expect(
        GeoBox.parse('1.1,1.2,1.3,1.4,2.1,2.2,2.3,2.4').toText(swapXY: true),
        '1.2,1.1,1.3,1.4,2.2,2.1,2.3,2.4',
      );
    });

    test('createFromObject', () {
      final li4 = [1, 2, 3, 4, 11, 12, 13, 14];
      const p4 = ProjBox(
        minX: 1,
        minY: 2,
        minZ: 3,
        minM: 4,
        maxX: 11,
        maxY: 12,
        maxZ: 13,
        maxM: 14,
      );

      expect(
        Box.createFromObject(p4, to: ProjBox.create),
        p4,
      );
      expect(
        Box.createFromObject(p4, to: ProjBox.create, type: Coords.xy),
        ProjBox.build(const [1, 2, 11, 12]),
      );
      expect(
        Box.createFromObject(p4, to: ProjBox.create, type: Coords.xyz),
        ProjBox.build(const [1, 2, 3, 11, 12, 13]),
      );
      expect(
        Box.createFromObject(p4, to: ProjBox.create, type: Coords.xym),
        ProjBox.build(const [1, 2, 4, 11, 12, 14], type: Coords.xym),
      );
      expect(
        Box.createFromObject(p4, to: ProjBox.create, type: Coords.xyzm),
        ProjBox.build(const [1, 2, 3, 4, 11, 12, 13, 14]),
      );

      expect(
        Box.createFromObject(li4, to: ProjBox.create),
        p4,
      );
      expect(
        Box.createFromObject(const [1, 2, 11, 12],
            to: ProjBox.create, type: Coords.xy),
        ProjBox.build(const [1, 2, 11, 12]),
      );
      expect(
        Box.createFromObject(const [1, 2, 3, 11, 12, 13],
            to: ProjBox.create, type: Coords.xyz),
        ProjBox.build(const [1, 2, 3, 11, 12, 13]),
      );
      expect(
        Box.createFromObject(const [1, 2, 4, 11, 12, 14],
            to: ProjBox.create, type: Coords.xym),
        ProjBox.build(const [1, 2, 4, 11, 12, 14], type: Coords.xym),
      );
      expect(
        Box.createFromObject(li4, to: ProjBox.create, type: Coords.xyzm),
        ProjBox.build(const [1, 2, 3, 4, 11, 12, 13, 14]),
      );
    });

    test('Length2D', () {
      expect(ProjBox.build(const [11.0, 22.0, 13.5, 27.0]).length2D(), 15.0);
      expect(GeoBox.build(const [11.0, 22.0, 13.5, 27.0]).length2D(), 15.0);
      expect(GeoBox.build(const [179.0, 22.0, -178.5, 27.0]).length2D(), 15.0);
    });
  });
}

void _testCoordinateOrder(String text, Iterable<num> coords, [Coords? type]) {
  final factories = [ProjBox.create, GeoBox.create];

  for (final factory in factories) {
    final fromCoords = Box.buildBox(coords, to: factory, type: type);
    final fromText = Box.parseBox(text, to: factory, type: type);
    expect(fromCoords, fromText);
    expect(fromCoords.toString(), text);
    /*
    expect(fromText.values, coords);
    for (var i = 0; i < coords.length; i++) {
      expect(fromText[i], coords.elementAt(i));
    }
    */

    expect(Box.createFromObject(coords, to: factory, type: type), fromCoords);
  }
}
