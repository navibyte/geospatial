// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
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

      expect(ProjBox.fromCoords(const [1.1, 1.2, 2.1, 2.2]), box1);
      expect(ProjBox.fromText('1.1,1.2,2.1,2.2'), box1);
      expect(ProjBox.fromText(box1.toString()), box1);

      expect(ProjBox.fromCoords(const [1.1, 1.2, 1.3, 2.1, 2.2, 2.3]), box2);
      expect(ProjBox.fromText('1.1,1.2,1.3,2.1,2.2,2.3'), box2);
      expect(ProjBox.fromText(box2.toString()), box2);

      expect(ProjBox.fromCoords(const [1.1, 1.2, 1.4, 2.1, 2.2, 2.4]),
          isNot(box3));
      expect(ProjBox.fromText('1.1,1.2,,1.4,2.1,2.2,,2.4'), box3);
      expect(ProjBox.fromText(box3.toString()), box3);

      expect(ProjBox.fromCoords(const [1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4]),
          box4);
      expect(ProjBox.fromText('1.1,1.2,1.3,1.4,2.1,2.2,2.3,2.4'), box4);
      expect(ProjBox.fromText(box4.toString()), box4);
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

      expect(GeoBox.fromCoords(const [1.1, 1.2, 2.1, 2.2]), box1);
      expect(GeoBox.fromText('1.1,1.2,2.1,2.2'), box1);
      expect(GeoBox.fromText(box1.toString()), box1);

      expect(GeoBox.fromCoords(const [1.1, 1.2, 1.3, 2.1, 2.2, 2.3]), box2);
      expect(GeoBox.fromText('1.1,1.2,1.3,2.1,2.2,2.3'), box2);
      expect(GeoBox.fromText(box2.toString()), box2);

      expect(
          GeoBox.fromCoords(const [1.1, 1.2, 1.4, 2.1, 2.2, 2.4]), isNot(box3));
      expect(GeoBox.fromText('1.1,1.2,,1.4,2.1,2.2,,2.4'), box3);
      expect(GeoBox.fromText(box3.toString()), box3);

      expect(GeoBox.fromCoords(const [1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4]),
          box4);
      expect(GeoBox.fromText('1.1,1.2,1.3,1.4,2.1,2.2,2.3,2.4'), box4);
      expect(GeoBox.fromText(box4.toString()), box4);
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
  });
}
