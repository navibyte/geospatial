// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_declarations, avoid_redundant_argument_values, lines_longer_than_80_chars

import 'dart:math';

import 'package:geobase/coordinates.dart';

import 'package:test/test.dart';

void main() {
  group('Dms parsing and representations (degrees / minutes / seconds)', () {
    test('Parse', () {
      expect(Dms.parse('51° 28′ 40.37″ N'), closeTo(51.4779, 0.0001));
      expect(Dms.parse('000° 00′ 05.29″ W'), closeTo(-0.0015, 0.0001));
    });
    test('Format', () {
      expect(Dms.formatDms(51.477881, format: Dms.d, decimals: 4), '051.4779°');
      expect(Dms.formatDms(51.477881, format: Dms.d, decimals: 2), '051.48°');
      expect(Dms.formatDms(51.477881, format: Dms.dm, decimals: 2), '051° 28.67′');
      expect(Dms.formatDms(51.477881, format: Dms.dm, decimals: 0), '051° 29′');
      expect(Dms.formatDms(51.477881, decimals: 0), '051° 28′ 40″');
      expect(Dms.formatDms(51.477881, decimals: 2), '051° 28′ 40.37″');
      expect(Dms.formatDms(-0.001469, decimals: 0), '000° 00′ 05″');
      expect(Dms.formatDms(-0.001469, decimals: 2), '000° 00′ 05.29″');
    });

    test('Latitude', () {
      expect(Dms.formatDms(-3.62), '003° 37′ 12″');
      expect(Dms.formatDms(-3.62, separator: ''), '003°37′12″');
      expect(Dms.latitude(-3.62), '03° 37′ 12″ S');
      expect(Dms.latitude(-3.62, separator: ''), '03°37′12″S');

      expect(Dms.formatDms(-3.62, format: Dms.dm), '003° 37.20′');
      expect(Dms.formatDms(-3.62, format: Dms.dm, separator: ''), '003°37.20′');
      expect(Dms.latitude(-3.62, format: Dms.dm), '03° 37.20′ S');
      expect(Dms.latitude(-3.62, format: Dms.dm, separator: ''), '03°37.20′S');

      expect(Dms.formatDms(-3.62, format: Dms.d), '003.6200°');
      expect(Dms.formatDms(-3.62, format: Dms.d, separator: ''), '003.6200°');
      expect(Dms.latitude(-3.62, format: Dms.d), '03.6200° S');
      expect(Dms.latitude(-3.62, format: Dms.d, separator: ''), '03.6200°S');

      // wrapped latitudes
      expect(Dms.latitude(176.38, format: Dms.d, separator: ''), '03.6200°N');
      expect(Dms.latitude(183.62, format: Dms.d, separator: ''), '03.6200°S');
      expect(Dms.latitude(-176.38, format: Dms.d, separator: ''), '03.6200°S');
      expect(Dms.latitude(-183.62, format: Dms.d, separator: ''), '03.6200°N');
    });

    test('Longitude', () {
      expect(Dms.longitude(-3.62), '003° 37′ 12″ W');
      expect(Dms.longitude(3.62, separator: ''), '003°37′12″E');

      expect(Dms.longitude(3.62, format: Dms.dm), '003° 37.20′ E');
      expect(Dms.longitude(-3.62, format: Dms.dm, separator: ''), '003°37.20′W');

      expect(Dms.longitude(-3.62, format: Dms.d), '003.6200° W');
      expect(Dms.longitude(-3.62, format: Dms.d, separator: ''), '003.6200°W');

      // wrapped longitudes
      expect(Dms.longitude(176.38, format: Dms.d, separator: ''), '176.3800°E');
      expect(Dms.longitude(183.62, format: Dms.d, separator: ''), '176.3800°W');
      expect(Dms.longitude(-176.38, format: Dms.d, separator: ''), '176.3800°W');
      expect(Dms.longitude(-183.62, format: Dms.d, separator: ''), '176.3800°E');
    });

    test('Bearing', () {
      expect(Dms.bearing(-3.62), '356° 22′ 48″');
      expect(Dms.bearing(-3.62, format: Dms.dm), '356° 22.80′');
      expect(Dms.bearing(-3.62, format: Dms.d), '356.3800°');
      expect(Dms.bearing(3.62, separator: ''), '003°37′12″');
    });

    test('Compass point', () {
      expect(Dms.compassPoint(24.0), 'NNE');
      expect(Dms.compassPoint(24.0, precision: 1), 'N');

      // precision 1: cardinal (90° each compass point)
      expect(Dms.compassPoint(-45.1, precision: 1), 'W');
      expect(Dms.compassPoint(-44.9, precision: 1), 'N');
      expect(Dms.compassPoint(44.9, precision: 1), 'N');
      expect(Dms.compassPoint(45.1, precision: 1), 'E');

      // precision 2: intercardinal (45.0° each compass point)
      expect(Dms.compassPoint(-66.4, precision: 2), 'NW');
      expect(Dms.compassPoint(-67.5, precision: 2), 'NW');
      expect(Dms.compassPoint(-67.6, precision: 2), 'W');
      expect(Dms.compassPoint(66.4, precision: 2), 'NE');
      expect(Dms.compassPoint(67.5, precision: 2), 'E');
      expect(Dms.compassPoint(67.6, precision: 2), 'E');
      expect(Dms.compassPoint(67.6 + 10 * 360.0, precision: 2), 'E');

      // precision 3: secondary-intercardinal (22.5° each compass point)
      expect(Dms.compassPoint(-191.24, precision: 3), 'S');
      expect(Dms.compassPoint(-191.26, precision: 3), 'SSE');
      expect(Dms.compassPoint(191.24, precision: 3), 'S');
      expect(Dms.compassPoint(191.26, precision: 3), 'SSW');
    });

    test('NaN values', () {
      expect(() => Dms.formatDms(double.nan), throwsFormatException);
      expect(() => Dms.latitude(double.nan), throwsFormatException);
    });

    test('Random tests (format -> parse -> format)', () {
      final r = Random(298884);
      for (var n = 0; n < 1000; n++) {
        final deg = r.nextDouble() * 4 * 360.0 - 2 * 360; // [-720.0, 720.0]

        for (final dms in Dms.values) {
          final lat = Dms.latitude(deg, format: dms);
          expect(Dms.latitude(Dms.parse(lat), format: dms), lat);
          final lon = Dms.longitude(deg, format: dms);
          expect(Dms.longitude(Dms.parse(lon), format: dms), lon);
          final brng = Dms.bearing(deg, format: dms);
          expect(Dms.bearing(Dms.parse(brng), format: dms), brng);
        }
      }
    });
  });
}
