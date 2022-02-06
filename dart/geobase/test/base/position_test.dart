// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

import 'package:geobase/geobase.dart';

import 'package:test/test.dart';

void main() {
  group('Position classes', () {
    test('GeoPosition coordinates, clamping longitude and latitude', () {
      expect(const GeoPosition(lon: 34.0, lat: 18.2).lon, 34.0);
      expect(const GeoPosition(lon: -326.0, lat: 18.2).lon, 34.0);
      expect(const GeoPosition(lon: 394.0, lat: 18.2).lon, 34.0);
      expect(const GeoPosition(lon: -180.0, lat: 18.2).lon, -180.0);
      expect(const GeoPosition(lon: -181.0, lat: 18.2).lon, 179.0);
      expect(const GeoPosition(lon: -541.0, lat: 18.2).lon, 179.0);
      expect(const GeoPosition(lon: 180.0, lat: 18.2).lon, -180.0);
      expect(const GeoPosition(lon: 181.0, lat: 18.2).lon, -179.0);
      expect(const GeoPosition(lon: 541.0, lat: 18.2).lon, -179.0);
      expect(const GeoPosition(lon: 34.2, lat: -90.0).lat, -90.0);
      expect(const GeoPosition(lon: 34.2, lat: -91.0).lat, -90.0);
      expect(const GeoPosition(lon: 34.2, lat: 90.0).lat, 90.0);
      expect(const GeoPosition(lon: 34.2, lat: 91.0).lat, 90.0);
    });
  });
}
