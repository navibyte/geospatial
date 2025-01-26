// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math';

import 'package:geobase/common.dart';
import 'package:test/test.dart';

void main() {
  group('DistanceUnit', () {
    test('meters to kilometers', () {
      expect(
        DistanceUnit.meters.toUnits(1000, DistanceUnit.kilometers),
        equals(1),
      );
    });

    test('kilometers to meters', () {
      expect(
        DistanceUnit.kilometers.toUnits(1, DistanceUnit.meters),
        equals(1000),
      );
    });

    test('meters to miles', () {
      expect(
        DistanceUnit.meters.toUnits(1609.34, DistanceUnit.miles),
        closeTo(1, 0.0001),
      );
    });

    test('miles to meters', () {
      expect(
        DistanceUnit.miles.toUnits(1, DistanceUnit.meters),
        closeTo(1609.344, 0.0001),
      );
    });

    test('kilometers to miles', () {
      expect(
        DistanceUnit.kilometers.toUnits(1.609344, DistanceUnit.miles),
        closeTo(1, 0.0001),
      );
    });

    test('miles to kilometers', () {
      expect(
        DistanceUnit.miles.toUnits(1, DistanceUnit.kilometers),
        closeTo(1.60934, 0.0001),
      );
    });

    test('meters to feet', () {
      expect(
        DistanceUnit.meters.toUnits(0.3048, DistanceUnit.feet),
        closeTo(1, 0.0001),
      );
    });

    test('feet to meters', () {
      expect(
        DistanceUnit.feet.toUnits(1, DistanceUnit.meters),
        closeTo(0.3048, 0.0001),
      );
    });

    test('kilometers to feet', () {
      expect(
        DistanceUnit.kilometers.toUnits(0.0003048, DistanceUnit.feet),
        closeTo(1, 0.0001),
      );
    });

    test('feet to kilometers', () {
      expect(
        DistanceUnit.feet.toUnits(1, DistanceUnit.kilometers),
        closeTo(0.0003048, 0.0001),
      );
    });

    test('miles to feet', () {
      expect(
        DistanceUnit.miles.toUnits(0.000189394, DistanceUnit.feet),
        closeTo(1, 0.0001),
      );
    });

    test('feet to miles', () {
      expect(
        DistanceUnit.feet.toUnits(1, DistanceUnit.miles),
        closeTo(0.000189394, 0.0001),
      );
    });

    test('nautical miles to meters', () {
      expect(
        DistanceUnit.nauticalMiles.toUnits(1, DistanceUnit.meters),
        closeTo(1852, 0.0001),
      );
    });

    test('kilometers to nautical miles', () {
      expect(
        DistanceUnit.kilometers.toUnits(1.852, DistanceUnit.nauticalMiles),
        closeTo(1, 0.0001),
      );
    });

    test('nautical miles to kilometers', () {
      expect(
        DistanceUnit.nauticalMiles.toUnits(1, DistanceUnit.kilometers),
        closeTo(1.852, 0.0001),
      );
    });

    test('miles to nautical miles', () {
      expect(
        DistanceUnit.miles.toUnits(1.15078, DistanceUnit.nauticalMiles),
        closeTo(1, 0.0001),
      );
    });

    test('nautical miles to miles', () {
      expect(
        DistanceUnit.nauticalMiles.toUnits(1, DistanceUnit.miles),
        closeTo(1.15078, 0.0001),
      );
    });
  });

  group('AngleUnit', () {
    test('degrees to radians', () {
      expect(
        AngleUnit.degrees.toUnits(180, AngleUnit.radians),
        closeTo(pi, 0.00001),
      );
    });

    test('radians to degrees', () {
      expect(
        AngleUnit.radians.toUnits(pi, AngleUnit.degrees),
        closeTo(180, 0.00001),
      );
    });

    test('degrees to gradians', () {
      expect(
        AngleUnit.degrees.toUnits(90, AngleUnit.gradians),
        closeTo(100, 0.00001),
      );
    });

    test('gradians to degrees', () {
      expect(
        AngleUnit.gradians.toUnits(100, AngleUnit.degrees),
        closeTo(90, 0.00001),
      );
    });

    test('radians to gradians', () {
      expect(
        AngleUnit.radians.toUnits(pi, AngleUnit.gradians),
        closeTo(200, 0.00001),
      );
    });

    test('gradians to radians', () {
      expect(
        AngleUnit.gradians.toUnits(200, AngleUnit.radians),
        closeTo(pi, 0.00001),
      );
    });

    test('degrees to milliradians', () {
      expect(
        AngleUnit.degrees.toUnits(1, AngleUnit.milliradians),
        closeTo(17.4533, 0.0001),
      );
    });

    test('milliradians to degrees', () {
      expect(
        AngleUnit.milliradians.toUnits(17.4533, AngleUnit.degrees),
        closeTo(1, 0.0001),
      );
    });

    test('degrees to arc minutes', () {
      expect(
        AngleUnit.degrees.toUnits(1, AngleUnit.arcMinutes),
        closeTo(60, 0.0001),
      );
    });

    test('arc minutes to degrees', () {
      expect(
        AngleUnit.arcMinutes.toUnits(60, AngleUnit.degrees),
        closeTo(1, 0.0001),
      );
    });

    test('degrees to arc seconds', () {
      expect(
        AngleUnit.degrees.toUnits(1, AngleUnit.arcSeconds),
        closeTo(3600, 0.0001),
      );
    });

    test('arc seconds to degrees', () {
      expect(
        AngleUnit.arcSeconds.toUnits(3600, AngleUnit.degrees),
        closeTo(1, 0.0001),
      );
    });

    test('degrees to turns', () {
      expect(
        AngleUnit.degrees.toUnits(360, AngleUnit.turns),
        closeTo(1, 0.0001),
      );
    });

    test('turns to degrees', () {
      expect(
        AngleUnit.turns.toUnits(1, AngleUnit.degrees),
        closeTo(360, 0.0001),
      );
    });
  });
}
