// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/geobase.dart';

import 'package:test/test.dart';

void main() {
  group('ProjBox class', () {
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
  });

  group('GeoBox class', () {
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
