// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: require_trailing_commas, lines_longer_than_80_chars, avoid_redundant_argument_values

import 'package:geobase/geodesy.dart';

import 'package:test/test.dart';

// see also `utm_ported_test.dart` for more tests on UTM/MGRS

void main() {
  group('MGRS parse and text formats', () {
    test('Wikipedia variations 4Q FJ 1 6', () {
      final refs = [
        '4Q FJ 1 6',
        '4QFJ16',
        '04Q FJ 1000 6000',
        '04QFJ10006000',
      ];
      for (final ref in refs) {
        final m = Mgrs.parse(ref);
        expect(m.toText(digits: 2), '4Q FJ 1 6');
        expect(m.toText(digits: 2, zeroPadZone: true), '04Q FJ 1 6');
        expect(m.toText(digits: 4), '4Q FJ 10 60');
        expect(m.toText(digits: 4, zeroPadZone: true), '04Q FJ 10 60');
        expect(m.toText(digits: 6), '4Q FJ 100 600');
        expect(m.toText(digits: 6, zeroPadZone: true), '04Q FJ 100 600');
        expect(m.toText(digits: 8), '4Q FJ 1000 6000');
        expect(m.toText(digits: 8, zeroPadZone: true), '04Q FJ 1000 6000');
        expect(m.toText(digits: 10), '4Q FJ 10000 60000');
        expect(m.toText(digits: 10, zeroPadZone: true), '04Q FJ 10000 60000');
        final gs = m.gridSquare;
        expect(gs.zone, 4);
        expect(gs.band, 'Q');
        expect(gs.column, 'F');
        expect(gs.row, 'J');
        expect(gs.toText(), '4Q FJ');
        expect(gs.toText(zeroPadZone: true), '04Q FJ');
      }
    });

    test('Wikipedia variations 4Q FJ 12345 67890', () {
      final refs = [
        '4Q FJ 12345 67890',
        '4QFJ1234567890',
        '04Q FJ 12345.0 67890.0',
        '04Q FJ 12345.124 67890.236',
      ];
      for (final ref in refs) {
        final m = Mgrs.parse(ref);
        expect(m.toText(digits: 2), '4Q FJ 1 6');
        expect(m.toText(digits: 2, zeroPadZone: true), '04Q FJ 1 6');
        expect(m.toText(digits: 2, militaryStyle: true), '4QFJ16');
        expect(m.toText(digits: 4), '4Q FJ 12 67');
        expect(m.toText(digits: 4, zeroPadZone: true), '04Q FJ 12 67');
        expect(m.toText(digits: 4, militaryStyle: true), '4QFJ1267');
        expect(m.toText(digits: 6), '4Q FJ 123 678');
        expect(m.toText(digits: 6, zeroPadZone: true), '04Q FJ 123 678');
        expect(m.toText(digits: 6, militaryStyle: true), '4QFJ123678');
        expect(m.toText(digits: 8), '4Q FJ 1234 6789');
        expect(m.toText(digits: 8, zeroPadZone: true), '04Q FJ 1234 6789');
        expect(m.toText(digits: 8, militaryStyle: true), '4QFJ12346789');
        expect(m.toText(digits: 10), '4Q FJ 12345 67890');
        expect(m.toText(digits: 10, zeroPadZone: true), '04Q FJ 12345 67890');
        expect(m.toText(digits: 10, militaryStyle: true), '4QFJ1234567890');
        final gs = m.gridSquare;
        expect(gs.toText(), '4Q FJ');
        expect(gs.toText(zeroPadZone: true), '04Q FJ');
        expect(gs.toText(zeroPadZone: true, militaryStyle: true), '04QFJ');
      }
    });

    test('4Q FJ without all coordinate values, should fail to parse', () {
      final refs = [
        '', '4',
        '4Q', '4Q FJ', '4QFJ', '4Q FJ 0', '4QFJ0',
        '04Q', '04Q FJ', '04QFJ', '04Q FJ 0', '04QFJ0', //
      ];
      for (final ref in refs) {
        expect(() => Mgrs.parse(ref), throwsFormatException);
      }
    });

    test('4Q FJ 12345 67890 with too many digits, should fail to parse', () {
      final refs = [
        '4Q FJ 123451 67890', '4Q FJ 12345 678902', '4Q FJ 123451 678902' //
      ];
      for (final ref in refs) {
        expect(() => Mgrs.parse(ref), throwsFormatException);
      }
    });

    test('4Q FJ 12345 67890 with invalid characters, should fail to parse', () {
      final refs = [
        '4O FJ 12345 67890', '4Q SI 12345 67890', '4O FJK 12345 67890', //
        'HQ FJ 12345 67890', '4Q FJ .12345 67890', '4Q FJ 1234.5 67890',
        '4Q FJ 12345 678.0', '4Q FJ 12345 6789H'
      ];
      for (final ref in refs) {
        expect(() => Mgrs.parse(ref), throwsFormatException);
      }
    });

    test('MgrsGridZone examples', () {
      final mgrsGridZone = MgrsGridZone(31, 'U');
      expect(mgrsGridZone.toText(), '31U');
      final mgrsGridZone2 = MgrsGridZone(4, 'Q');
      expect(mgrsGridZone2.toText(), '4Q');
      expect(mgrsGridZone2.toText(zeroPadZone: true), '04Q');
    });

    test('MgrsGridSquare examples', () {
      final mgrsGridSquare = MgrsGridSquare(31, 'U', 'D', 'Q');
      expect(mgrsGridSquare.toText(), '31U DQ');
      expect(mgrsGridSquare.toText(militaryStyle: true), '31UDQ');
      final mgrsGridSquare2 = MgrsGridSquare(4, 'Q', 'F', 'J');
      expect(mgrsGridSquare2.toText(), '4Q FJ');
      expect(mgrsGridSquare2.toText(zeroPadZone: true), '04Q FJ');
    });

    test('Mgrs.parse examples', () {
      final mgrsRef = Mgrs.parse('31U DQ 48251 11932');
      expect(mgrsRef.toText(), '31U DQ 48251 11932');
      final mgrsRefMil = Mgrs.parse('31UDQ4825111932');
      expect(mgrsRefMil.toText(), '31U DQ 48251 11932');
    });

    test('Mgrs.toText examples', () {
      final mgrsRef = Mgrs(31, 'U', 'D', 'Q', 48251, 11932);
      expect(mgrsRef.toText(), '31U DQ 48251 11932');
      expect(mgrsRef.toText(digits: 8), '31U DQ 4825 1193');
      expect(mgrsRef.toText(digits: 4), '31U DQ 48 11');
      expect(mgrsRef.toText(digits: 4, militaryStyle: true), '31UDQ4811');
      final mgrsRef2 = Mgrs.parse('4Q FJ 02345 07890');
      expect(mgrsRef2.toText(), '4Q FJ 02345 07890');
      expect(mgrsRef2.toText(zeroPadZone: true), '04Q FJ 02345 07890');
    });
  });
}
