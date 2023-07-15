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
      expect(Dms().parseDeg('51° 28′ 40.37″ N'), closeTo(51.4779, 0.0001));
      expect(Dms().parseDeg('000° 00′ 05.29″ W'), closeTo(-0.0015, 0.0001));
    });
    test('Format', () {
      expect(
        Dms(type: DmsType.d, decimals: 4).formatDms(51.477881),
        '051.4779°',
      );
      expect(
        Dms(type: DmsType.d, decimals: 2).formatDms(51.477881),
        '051.48°',
      );
      expect(
        Dms(type: DmsType.dm, decimals: 2).formatDms(51.477881),
        '051° 28.67′',
      );
      expect(
        Dms(type: DmsType.dm, decimals: 0).formatDms(51.477881),
        '051° 29′',
      );
      expect(Dms(decimals: 0).formatDms(51.477881), '051° 28′ 40″');
      expect(Dms(decimals: 2).formatDms(51.477881), '051° 28′ 40.37″');
      expect(Dms(decimals: 0).formatDms(-0.001469), '000° 00′ 05″');
      expect(Dms(decimals: 2).formatDms(-0.001469), '000° 00′ 05.29″');
    });

    test('Latitude', () {
      expect(Dms().formatDms(-3.62), '003° 37′ 12″');
      expect(Dms(separator: '').formatDms(-3.62), '003°37′12″');
      expect(Dms().lat(-3.62), '03° 37′ 12″ S');
      expect(Dms(separator: '').lat(-3.62), '03°37′12″S');

      expect(Dms(type: DmsType.dm).formatDms(-3.62), '003° 37.20′');
      expect(
        Dms(type: DmsType.dm, separator: '').formatDms(-3.62),
        '003°37.20′',
      );
      expect(Dms(type: DmsType.dm).lat(-3.62), '03° 37.20′ S');
      expect(
        Dms(type: DmsType.dm, separator: '').lat(-3.62),
        '03°37.20′S',
      );

      expect(Dms(type: DmsType.d).formatDms(-3.62), '003.6200°');
      expect(
        Dms(type: DmsType.d, separator: '').formatDms(-3.62),
        '003.6200°',
      );
      expect(Dms(type: DmsType.d).lat(-3.62), '03.6200° S');
      expect(
        Dms(type: DmsType.d, separator: '').lat(-3.62),
        '03.6200°S',
      );

      // wrapped latitudes
      expect(
        Dms(type: DmsType.d, separator: '').lat(176.38),
        '03.6200°N',
      );
      expect(
        Dms(type: DmsType.d, separator: '').lat(183.62),
        '03.6200°S',
      );
      expect(
        Dms(type: DmsType.d, separator: '').lat(-176.38),
        '03.6200°S',
      );
      expect(
        Dms(type: DmsType.d, separator: '').lat(-183.62),
        '03.6200°N',
      );
    });

    test('Longitude', () {
      expect(Dms().lon(-3.62), '003° 37′ 12″ W');
      expect(Dms(separator: '').lon(3.62), '003°37′12″E');

      expect(Dms(type: DmsType.dm).lon(3.62), '003° 37.20′ E');
      expect(
        Dms(type: DmsType.dm, separator: '').lon(-3.62),
        '003°37.20′W',
      );

      expect(Dms(type: DmsType.d).lon(-3.62), '003.6200° W');
      expect(
        Dms(type: DmsType.d, separator: '').lon(-3.62),
        '003.6200°W',
      );

      // wrapped longitudes
      expect(
        Dms(type: DmsType.d, separator: '').lon(176.38),
        '176.3800°E',
      );
      expect(
        Dms(type: DmsType.d, separator: '').lon(183.62),
        '176.3800°W',
      );
      expect(
        Dms(type: DmsType.d, separator: '').lon(-176.38),
        '176.3800°W',
      );
      expect(
        Dms(type: DmsType.d, separator: '').lon(-183.62),
        '176.3800°E',
      );
    });

    test('Bearing', () {
      expect(Dms().bearing(-3.62), '356° 22′ 48″');
      expect(Dms(type: DmsType.dm).bearing(-3.62), '356° 22.80′');
      expect(Dms(type: DmsType.d).bearing(-3.62), '356.3800°');
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
      expect(() => Dms().formatDms(double.nan), throwsFormatException);
      expect(() => Dms().lat(double.nan), throwsFormatException);
    });

    test('Random tests (format -> parse -> format)', () {
      final r = Random(298884);
      for (var n = 0; n < 1000; n++) {
        final deg = r.nextDouble() * 4 * 360.0 - 2 * 360; // [-720.0, 720.0]

        for (final type in DmsType.values) {
          final dms = Dms(type: type);
          final lat = dms.lat(deg);
          expect(dms.lat(dms.parseDeg(lat)), lat);
          final lon = dms.lon(deg);
          expect(dms.lon(dms.parseDeg(lon)), lon);
          final brng = dms.bearing(deg);
          expect(dms.bearing(dms.parseDeg(brng)), brng);
        }
      }
    });

    test('ST_AsLatLonText reference tests', () {
      // samples from: https://postgis.net/docs/ST_AsLatLonText.html

      final dms = Dms(separator: '', decimals: 3);
      expect((-792.32498).wrapLatitude(), closeTo(-72.32498, 0.00001));
      expect(dms.lat(-792.32498), '72°19′29.928″S');
      expect((-302.2342342).wrapLongitude(), closeTo(57.76576, 0.00001));
      expect(dms.lon(-302.2342342), '057°45′56.757″E');

      expect(dms.lat(-2.32498), '02°19′29.928″S');
      expect(dms.lon(-3.2342342), '003°14′03.243″W');
    });
  });
}
