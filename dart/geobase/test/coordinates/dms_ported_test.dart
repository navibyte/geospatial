/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Geodesy Test Harness - dms                                         (c) Chris Veness 2014-2021  */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// Source:
// https://github.com/chrisveness/geodesy/blob/master/test/dms-tests.js
//
// Test cases ported from JavaScript source to Dart code by Navibyte (2023).

// ignore_for_file: lines_longer_than_80_chars, prefer_const_constructors

import 'package:geobase/coordinates.dart';

import 'package:test/test.dart';

void main() {
  group('dms)', () {
    test('0°', () {
      const d = Dms(zeroPadDegrees: true);
      const d0 = Dms(zeroPadDegrees: true, decimals: 0);
      const dms = Dms(type: DmsType.degMinSec, zeroPadDegrees: true);
      const dms2 = Dms(
        type: DmsType.degMinSec,
        zeroPadDegrees: true,
        decimals: 2,
      );
      expect(d.parse('0.0°'), 0);
      expect(d.format(0), '000.0000°');
      expect(d0.parse('0°'), 0);
      expect(d0.format(0), '000°');
      expect(dms.parse('000 00 00 '), 0);
      expect(dms.parse('000°00′00″'), 0);
      expect(dms.format(0), '000°00′00″');

      expect(dms.parse('000°00′00.0″'), 0);
      expect(dms.format(0), '000°00′00″');
      expect(dms2.format(0), '000°00′00.00″');
    });

    test('parse variations', () {
      // including whitespace, different d/m/s symbols (ordinal, ascii/typo quotes)
      const variations = [
        '45.76260',
        '45.76260 ',
        '45.76260°',
        '45°45.756′',
        '45° 45.756′',
        '45 45.756',
        '45°45′45.36″',
        '45º45\'45.36"',
        '45°45’45.36”',
        '45 45 45.36 ',
        '45° 45′ 45.36″',
        '45º 45\' 45.36"',
        '45° 45’ 45.36”',
      ];
      const d = Dms(zeroPadDegrees: true);
      for (final v in variations) {
        expect(d.parse(v), 45.76260);
        expect(d.parse('-$v'), -45.76260);
        expect(d.parse('${v}N'), 45.76260);
        expect(d.parse('${v}S'), -45.76260);
        expect(d.parse('${v}E'), 45.76260);
        expect(d.parse('${v}W'), -45.76260);
        expect(d.parse('$v N'), 45.76260);
        expect(d.parse('$v S'), -45.76260);
        expect(d.parse('$v E'), 45.76260);
        expect(d.parse('$v W'), -45.76260);
      }
      expect(d.parse(' 45°45′45.36″ '), 45.76260);
    });

    test('parse out-of-range (should be normalised externally)', () {
      const d = Dms(zeroPadDegrees: true);
      expect(d.parse('185'), 185);
      expect(d.parse('365'), 365);
      expect(d.parse('-185'), -185);
      expect(d.parse('-365'), -365);
    });

    test('output variations', () {
      expect(
        Dms(zeroPadDegrees: true).format(9.1525),
        '009.1525°',
      );
      expect(
        Dms(type: DmsType.degMin, zeroPadDegrees: true).format(9.1525),
        '009°09.15′',
      );
      expect(
        Dms(type: DmsType.degMinSec, zeroPadDegrees: true).format(9.1525),
        '009°09′09″',
      );
      expect(
        Dms(zeroPadDegrees: true, decimals: 6).format(9.1525),
        '009.152500°',
      );
      expect(
        Dms(type: DmsType.degMin, zeroPadDegrees: true, decimals: 4)
            .format(9.1525),
        '009°09.1500′',
      );
      expect(
        Dms(type: DmsType.degMinSec, zeroPadDegrees: true, decimals: 2)
            .format(9.1525),
        '009°09′09.00″',
      );
    });

    test('compass points', () {
      const d = Dms(zeroPadDegrees: true);
      const pr1 = CardinalPrecision.cardinal;
      const pr2 = CardinalPrecision.intercardinal;

      expect(d.compassPoint(1), 'N');
      expect(d.compassPoint(0), 'N');
      expect(d.compassPoint(-1), 'N');
      expect(d.compassPoint(359), 'N');

      expect(d.compassPoint(24, precision: pr1), 'N');
      expect(d.compassPoint(24, precision: pr2), 'NE');
      expect(d.compassPoint(24), 'NNE');

      expect(d.compassPoint(226, precision: pr1), 'W');
      expect(d.compassPoint(226, precision: pr2), 'SW');
      expect(d.compassPoint(226), 'SW');

      expect(d.compassPoint(237, precision: pr1), 'W');
      expect(d.compassPoint(237, precision: pr2), 'SW');
      expect(d.compassPoint(237), 'WSW');
    });

    test('misc', () {
      const d = Dms(zeroPadDegrees: true);
      const dm = Dms(type: DmsType.degMin, zeroPadDegrees: true);
      const dms = Dms(type: DmsType.degMinSec, zeroPadDegrees: true);

      expect(dms.lat(51.2), '51°12′00″N');
      expect(dm.lat(51.19999999999999), '51°12.00′N');
      expect(dms.lat(51.19999999999999), '51°12′00″N');
      expect(dms.lon(0.33), '000°19′48″E');
      expect(d.format(51.99999999999999), '052.0000°');
      expect(dm.format(51.99999999999999), '052°00.00′');
      expect(dms.format(51.99999999999999), '052°00′00″');
      expect(d.format(51.19999999999999), '051.2000°');
      expect(dm.format(51.19999999999999), '051°12.00′');
      expect(dms.format(51.19999999999999), '051°12′00″');
      expect(d.bearing(1), '001.0000°');
    });

    test('parse failures', () {
      const inputs = ['0 0 0 0', 'xxx', ''];
      const d = Dms(zeroPadDegrees: true);
      for (final input in inputs) {
        expect(() => d.parse(input), throwsFormatException);
        expect(d.tryParse(input), isNull);
      }
    });

    test('wrap360 / wrapLongitude / wrapLatitude', () {
      // sample, sample.wrap360(), sample.wrapLongitude(), sample.wrapLatitude()
      const testCases = [
        [-450, 270, -90, -90],
        [-405, 315, -45, -45],
        [-360, 0, 0, 0],
        [-315, 45, 45, 45],
        [-270, 90, 90, 90],
        [-225, 135, 135, 45],
        [-180, 180, -180, 0],
        [-135, 225, -135, -45],
        [-90, 270, -90, -90],
        [-45, 315, -45, -45],
        [0, 0, 0, 0],
        [45, 45, 45, 45],
        [90, 90, 90, 90],
        [135, 135, 135, 45],
        [180, 180, -180, 0],
        [225, 225, -135, -45],
        [270, 270, -90, -90],
        [315, 315, -45, -45],
        [360, 0, 0, 0],
        [405, 45, 45, 45],
        [450, 90, 90, 90],
      ];
      for (final testCase in testCases) {
        final sample = testCase[0].toDouble();
        expect(sample.wrap360(), testCase[1]);
        expect(sample.wrapLongitude(), testCase[2]);
        expect(sample.wrapLatitude(), testCase[3]);
      }
    });
  });
}
