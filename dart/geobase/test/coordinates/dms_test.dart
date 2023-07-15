// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_declarations, avoid_redundant_argument_values, lines_longer_than_80_chars, prefer_const_constructors

import 'dart:math';

import 'package:geobase/coordinates.dart';

import 'package:test/test.dart';

void main() {
  group('Dms parsing and representations (degrees / minutes / seconds)', () {
    test('Parse', () {
      expect(Dms().parse('51° 28′ 40.37″ N'), closeTo(51.4779, 0.0001));
      expect(Dms().parse('000° 00′ 05.29″ W'), closeTo(-0.0015, 0.0001));
    });
    test('Format', () {
      expect(
        Dms(format: DmsFormat.d, decimals: 4).format(51.477881),
        '051.4779°',
      );
      expect(
        Dms(format: DmsFormat.d, decimals: 2).format(51.477881),
        '051.48°',
      );
      expect(
        Dms(format: DmsFormat.dm, decimals: 2).format(51.477881),
        '051° 28.67′',
      );
      expect(
        Dms(format: DmsFormat.dm, decimals: 0).format(51.477881),
        '051° 29′',
      );
      expect(Dms(decimals: 0).format(51.477881), '051° 28′ 40″');
      expect(Dms(decimals: 2).format(51.477881), '051° 28′ 40.37″');
      expect(Dms(decimals: 0).format(-0.001469), '000° 00′ 05″');
      expect(Dms(decimals: 2).format(-0.001469), '000° 00′ 05.29″');
    });

    test('Latitude', () {
      expect(Dms().format(-3.62), '003° 37′ 12″');
      expect(Dms(separator: '').format(-3.62), '003°37′12″');
      expect(Dms().latitude(-3.62), '03° 37′ 12″ S');
      expect(Dms(separator: '').latitude(-3.62), '03°37′12″S');

      expect(Dms(format: DmsFormat.dm).format(-3.62), '003° 37.20′');
      expect(
        Dms(format: DmsFormat.dm, separator: '').format(-3.62),
        '003°37.20′',
      );
      expect(Dms(format: DmsFormat.dm).latitude(-3.62), '03° 37.20′ S');
      expect(
        Dms(format: DmsFormat.dm, separator: '').latitude(-3.62),
        '03°37.20′S',
      );

      expect(Dms(format: DmsFormat.d).format(-3.62), '003.6200°');
      expect(
        Dms(format: DmsFormat.d, separator: '').format(-3.62),
        '003.6200°',
      );
      expect(Dms(format: DmsFormat.d).latitude(-3.62), '03.6200° S');
      expect(
        Dms(format: DmsFormat.d, separator: '').latitude(-3.62),
        '03.6200°S',
      );

      // wrapped latitudes
      expect(
        Dms(format: DmsFormat.d, separator: '').latitude(176.38),
        '03.6200°N',
      );
      expect(
        Dms(format: DmsFormat.d, separator: '').latitude(183.62),
        '03.6200°S',
      );
      expect(
        Dms(format: DmsFormat.d, separator: '').latitude(-176.38),
        '03.6200°S',
      );
      expect(
        Dms(format: DmsFormat.d, separator: '').latitude(-183.62),
        '03.6200°N',
      );
    });

    test('Longitude', () {
      expect(Dms().longitude(-3.62), '003° 37′ 12″ W');
      expect(Dms(separator: '').longitude(3.62), '003°37′12″E');

      expect(Dms(format: DmsFormat.dm).longitude(3.62), '003° 37.20′ E');
      expect(
        Dms(format: DmsFormat.dm, separator: '').longitude(-3.62),
        '003°37.20′W',
      );

      expect(Dms(format: DmsFormat.d).longitude(-3.62), '003.6200° W');
      expect(
        Dms(format: DmsFormat.d, separator: '').longitude(-3.62),
        '003.6200°W',
      );

      // wrapped longitudes
      expect(
        Dms(format: DmsFormat.d, separator: '').longitude(176.38),
        '176.3800°E',
      );
      expect(
        Dms(format: DmsFormat.d, separator: '').longitude(183.62),
        '176.3800°W',
      );
      expect(
        Dms(format: DmsFormat.d, separator: '').longitude(-176.38),
        '176.3800°W',
      );
      expect(
        Dms(format: DmsFormat.d, separator: '').longitude(-183.62),
        '176.3800°E',
      );
    });

    test('Bearing', () {
      expect(Dms().bearing(-3.62), '356° 22′ 48″');
      expect(Dms(format: DmsFormat.dm).bearing(-3.62), '356° 22.80′');
      expect(Dms(format: DmsFormat.d).bearing(-3.62), '356.3800°');
      expect(Dms(separator: '').bearing(3.62), '003°37′12″');
    });

    test('Compass point', () {
      expect(Dms().compassPoint(24.0), 'NNE');
      expect(Dms().compassPoint(24.0, precision: 1), 'N');

      // precision 1: cardinal (90° each compass point)
      expect(Dms().compassPoint(-45.1, precision: 1), 'W');
      expect(Dms().compassPoint(-44.9, precision: 1), 'N');
      expect(Dms().compassPoint(44.9, precision: 1), 'N');
      expect(Dms().compassPoint(45.1, precision: 1), 'E');

      // precision 2: intercardinal (45.0° each compass point)
      expect(Dms().compassPoint(-66.4, precision: 2), 'NW');
      expect(Dms().compassPoint(-67.5, precision: 2), 'NW');
      expect(Dms().compassPoint(-67.6, precision: 2), 'W');
      expect(Dms().compassPoint(66.4, precision: 2), 'NE');
      expect(Dms().compassPoint(67.5, precision: 2), 'E');
      expect(Dms().compassPoint(67.6, precision: 2), 'E');
      expect(Dms().compassPoint(67.6 + 10 * 360.0, precision: 2), 'E');

      // precision 3: secondary-intercardinal (22.5° each compass point)
      expect(Dms().compassPoint(-191.24, precision: 3), 'S');
      expect(Dms().compassPoint(-191.26, precision: 3), 'SSE');
      expect(Dms().compassPoint(191.24, precision: 3), 'S');
      expect(Dms().compassPoint(191.26, precision: 3), 'SSW');
    });

    test('NaN values', () {
      expect(() => Dms().format(double.nan), throwsFormatException);
      expect(() => Dms().latitude(double.nan), throwsFormatException);
    });

    test('Random tests (format -> parse -> format)', () {
      final r = Random(298884);
      for (var n = 0; n < 1000; n++) {
        final deg = r.nextDouble() * 4 * 360.0 - 2 * 360; // [-720.0, 720.0]

        for (final format in DmsFormat.values) {
          final dms = Dms(format: format);
          final lat = dms.latitude(deg);
          expect(dms.latitude(dms.parse(lat)), lat);
          final lon = dms.longitude(deg);
          expect(dms.longitude(dms.parse(lon)), lon);
          final brng = dms.bearing(deg);
          expect(dms.bearing(dms.parse(brng)), brng);
        }
      }
    });

    test('ST_AsLatLonText reference tests', () {
      // samples from: https://postgis.net/docs/ST_AsLatLonText.html

      final dms = Dms(separator: '', decimals: 3);
      expect((-792.32498).wrapLatitude(), closeTo(-72.32498, 0.00001));
      expect(dms.latitude(-792.32498), '72°19′29.928″S');
      expect((-302.2342342).wrapLongitude(), closeTo(57.76576, 0.00001));
      expect(dms.longitude(-302.2342342), '057°45′56.757″E');

      expect(dms.latitude(-2.32498), '02°19′29.928″S');
      expect(dms.longitude(-3.2342342), '003°14′03.243″W');
    });
  });
}
