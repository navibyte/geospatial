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
  });
}
