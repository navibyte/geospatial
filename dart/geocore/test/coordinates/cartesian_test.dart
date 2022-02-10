// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars, prefer_const_declarations

import 'package:geocore/coordinates.dart';

import 'package:test/test.dart';

void main() {
  group('CartesianPoint classes', () {
    test('Equals and hashCode', () {
      final one = 1.0;
      final two = 2.0;
      const p1 = Point3m(x: 1.0, y: 2.0, z: 3.0, m: 4.0);
      final p2 = Point3m(x: one, y: 2.0, z: 3.0, m: 4.0);
      final p3 = Point3m(x: two, y: 2.0, z: 3.0, m: 4.0);
      expect(p1, p2);
      expect(p1, isNot(p3));
      expect(p1.hashCode, p2.hashCode);
      expect(p1.hashCode, isNot(p3.hashCode));

      final p5 = const Point3(x: 1.0, y: 2.0, z: 3.0);
      final p6 = const GeoPoint3(lon: 1.0, lat: 2.0, elev: 3.0);
      expect(p1, isNot(p5));
      expect(p1, isNot(p6));
      expect(p5, isNot(p6));
    });
  });
}
