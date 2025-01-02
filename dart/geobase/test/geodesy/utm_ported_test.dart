/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Geodesy Test Harness - utm/mgrs                                    (c) Chris Veness 2014-2021  */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// Utm/mgrs tests by Chris Veness ported to Dart by Navibyte.
//
// Source:
// https://github.com/chrisveness/geodesy/blob/master/test/utm-mgrs-tests.js

// ignore_for_file: require_trailing_commas, lines_longer_than_80_chars

import 'package:geobase/geodesy.dart';

import 'package:test/test.dart';

// useful for manual checks: www.rcn.montana.edu/resources/converter.aspx

void main() {
  group('@examples UTM', () {
    test('constructor', () {
      expect(Utm(31, 'N', 448251, 5411932).toText(), '31 N 448251 5411932');
    });

    test('parse', () {
      expect(Utm.parse('31 N 448251 5411932').toText(), '31 N 448251 5411932');
    });

    test('toString', () {
      expect(Utm(31, 'N', 448251.1, 5411932.1).toText(decimals: 4),
          '31 N 448251.1000 5411932.1000');
    });
  });

  group('UTM constructor fail', () {
    test('zone fail', () {
      expect(() => Utm(0, 'N', 0, 0), throwsFormatException);
    });

    test('zone fail', () {
      expect(() => Utm(61, 'N', 0, 0), throwsFormatException);
    });

    test('hemisphere fail', () {
      expect(() => Utm(1, 'E', 0, 0), throwsFormatException);
    });

    test('easting fail', () {
      expect(() => Utm(1, 'N', 1001e3, 0), throwsFormatException);
    });

    test('northing N fail', () {
      expect(() => Utm(1, 'N', 0, 9330e3), throwsFormatException);
    });

    test('northing S fail', () {
      expect(() => Utm(1, 'S', 0, 1116e3), throwsFormatException);
    });
  });
}
