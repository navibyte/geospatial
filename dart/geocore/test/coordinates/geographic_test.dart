// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars, prefer_const_declarations

import 'package:geocore/coordinates.dart';

import 'package:test/test.dart';

void main() {
  group('GeoPoint classes', () {
    test('Equals and hashCode', () {
      final one = 1.0;
      final two = 2.0;
      const p1 = GeoPoint3m(lon: 1.0, lat: 2.0, elev: 3.0, m: 4.0);
      final p2 = GeoPoint3m(lon: one, lat: 2.0, elev: 3.0, m: 4.0);
      final p3 = GeoPoint3m(lon: two, lat: 2.0, elev: 3.0, m: 4.0);
      expect(p1, p2);
      expect(p1, isNot(p3));
      expect(p1.hashCode, p2.hashCode);
      expect(p1.hashCode, isNot(p3.hashCode));
    });

    test('Clamping longitude and latitude in constructor', () {
      expect(const GeoPoint3m(lon: 34.0, lat: 18.2).lon, 34.0);
      expect(const GeoPoint3m(lon: -326.0, lat: 18.2).lon, 34.0);
      expect(const GeoPoint3m(lon: 394.0, lat: 18.2).lon, 34.0);
      expect(const GeoPoint3m(lon: -180.0, lat: 18.2).lon, -180.0);
      expect(const GeoPoint3m(lon: -181.0, lat: 18.2).lon, 179.0);
      expect(const GeoPoint3m(lon: -541.0, lat: 18.2).lon, 179.0);
      expect(const GeoPoint3m(lon: 180.0, lat: 18.2).lon, -180.0);
      expect(const GeoPoint3m(lon: 181.0, lat: 18.2).lon, -179.0);
      expect(const GeoPoint3m(lon: 541.0, lat: 18.2).lon, -179.0);
      expect(const GeoPoint3m(lon: 34.2, lat: -90.0).lat, -90.0);
      expect(const GeoPoint3m(lon: 34.2, lat: -91.0).lat, -90.0);
      expect(const GeoPoint3m(lon: 34.2, lat: 90.0).lat, 90.0);
      expect(const GeoPoint3m(lon: 34.2, lat: 91.0).lat, 90.0);
    });
  });
}
