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

  group('AreaUnit', () {
    test('square meters to square kilometers', () {
      expect(
        AreaUnit.squareMeters.toUnits(1000000, AreaUnit.squareKilometers),
        equals(1),
      );
    });

    test('square kilometers to square meters', () {
      expect(
        AreaUnit.squareKilometers.toUnits(1, AreaUnit.squareMeters),
        equals(1000000),
      );
    });

    test('square meters to square miles', () {
      expect(
        AreaUnit.squareMeters.toUnits(2589988.11, AreaUnit.squareMiles),
        closeTo(1, 0.0001),
      );
    });

    test('square miles to square meters', () {
      expect(
        AreaUnit.squareMiles.toUnits(1, AreaUnit.squareMeters),
        closeTo(2589988.11, 0.0001),
      );
    });

    test('square kilometers to square miles', () {
      expect(
        AreaUnit.squareKilometers.toUnits(2.589988, AreaUnit.squareMiles),
        closeTo(1, 0.0001),
      );
    });

    test('square miles to square kilometers', () {
      expect(
        AreaUnit.squareMiles.toUnits(1, AreaUnit.squareKilometers),
        closeTo(2.589988, 0.0001),
      );
    });

    test('square meters to square feet', () {
      expect(
        AreaUnit.squareMeters.toUnits(0.092903, AreaUnit.squareFeet),
        closeTo(1, 0.0001),
      );
    });

    test('square feet to square meters', () {
      expect(
        AreaUnit.squareFeet.toUnits(1, AreaUnit.squareMeters),
        closeTo(0.092903, 0.0001),
      );
    });

    test('square kilometers to square feet', () {
      expect(
        AreaUnit.squareKilometers.toUnits(0.000000092903, AreaUnit.squareFeet),
        closeTo(1, 0.0001),
      );
    });

    test('square feet to square kilometers', () {
      expect(
        AreaUnit.squareFeet.toUnits(1, AreaUnit.squareKilometers),
        closeTo(0.000000092903, 0.0001),
      );
    });

    test('square miles to square feet', () {
      expect(
        AreaUnit.squareMiles.toUnits(0.00000003587, AreaUnit.squareFeet),
        closeTo(1, 0.0001),
      );
    });

    test('square feet to square miles', () {
      expect(
        AreaUnit.squareFeet.toUnits(1, AreaUnit.squareMiles),
        closeTo(0.00000003587, 0.0001),
      );
    });

    test('hectares to square meters', () {
      expect(
        AreaUnit.hectares.toUnits(1, AreaUnit.squareMeters),
        equals(10000),
      );
    });

    test('square meters to hectares', () {
      expect(
        AreaUnit.squareMeters.toUnits(10000, AreaUnit.hectares),
        equals(1),
      );
    });

    test('acres to square meters', () {
      expect(
        AreaUnit.acres.toUnits(1, AreaUnit.squareMeters),
        closeTo(4046.8564224, 0.0001),
      );
    });

    test('square meters to acres', () {
      expect(
        AreaUnit.squareMeters.toUnits(4046.8564224, AreaUnit.acres),
        closeTo(1, 0.0001),
      );
    });

    test('hectares to acres', () {
      expect(
        AreaUnit.hectares.toUnits(1, AreaUnit.acres),
        closeTo(2.47105, 0.0001),
      );
    });

    test('acres to hectares', () {
      expect(
        AreaUnit.acres.toUnits(1, AreaUnit.hectares),
        closeTo(0.404686, 0.0001),
      );
    });
  });

  group('TimeUnit', () {
    test('seconds to minutes', () {
      expect(
        TimeUnit.second.toUnit(60, TimeUnit.minute),
        equals(1),
      );
    });

    test('minutes to seconds', () {
      expect(
        TimeUnit.minute.toUnit(1, TimeUnit.second),
        equals(60),
      );
    });

    test('seconds to hours', () {
      expect(
        TimeUnit.second.toUnit(3600, TimeUnit.hour),
        equals(1),
      );
    });

    test('hours to seconds', () {
      expect(
        TimeUnit.hour.toUnit(1, TimeUnit.second),
        equals(3600),
      );
    });

    test('minutes to hours', () {
      expect(
        TimeUnit.minute.toUnit(60, TimeUnit.hour),
        equals(1),
      );
    });

    test('hours to minutes', () {
      expect(
        TimeUnit.hour.toUnit(1, TimeUnit.minute),
        equals(60),
      );
    });

    test('seconds to days', () {
      expect(
        TimeUnit.second.toUnit(86400, TimeUnit.day),
        equals(1),
      );
    });

    test('days to seconds', () {
      expect(
        TimeUnit.day.toUnit(1, TimeUnit.second),
        equals(86400),
      );
    });

    test('minutes to days', () {
      expect(
        TimeUnit.minute.toUnit(1440, TimeUnit.day),
        equals(1),
      );
    });

    test('days to minutes', () {
      expect(
        TimeUnit.day.toUnit(1, TimeUnit.minute),
        equals(1440),
      );
    });

    test('hours to days', () {
      expect(
        TimeUnit.hour.toUnit(24, TimeUnit.day),
        equals(1),
      );
    });

    test('days to hours', () {
      expect(
        TimeUnit.day.toUnit(1, TimeUnit.hour),
        equals(24),
      );
    });
  });

  group('SpeedUnit', () {
    test('meters per second to kilometers per hour', () {
      expect(
        SpeedUnit.meterPerSecond.toUnit(1, SpeedUnit.kilometerPerHour),
        closeTo(3.6, 0.0001),
      );
    });

    test('kilometers per hour to meters per second', () {
      expect(
        SpeedUnit.kilometerPerHour.toUnit(3.6, SpeedUnit.meterPerSecond),
        closeTo(1, 0.0001),
      );
    });

    test('meters per second to miles per hour', () {
      expect(
        SpeedUnit.meterPerSecond.toUnit(1, SpeedUnit.milePerHour),
        closeTo(2.23694, 0.0001),
      );
    });

    test('miles per hour to meters per second', () {
      expect(
        SpeedUnit.milePerHour.toUnit(1, SpeedUnit.meterPerSecond),
        closeTo(0.44704, 0.0001),
      );
    });

    test('kilometers per hour to miles per hour', () {
      expect(
        SpeedUnit.kilometerPerHour.toUnit(1, SpeedUnit.milePerHour),
        closeTo(0.621371, 0.0001),
      );
    });

    test('miles per hour to kilometers per hour', () {
      expect(
        SpeedUnit.milePerHour.toUnit(1, SpeedUnit.kilometerPerHour),
        closeTo(1.60934, 0.0001),
      );
    });

    test('knots to meters per second', () {
      expect(
        SpeedUnit.knot.toUnit(1, SpeedUnit.meterPerSecond),
        closeTo(0.514444, 0.0001),
      );
    });

    test('meters per second to knots', () {
      expect(
        SpeedUnit.meterPerSecond.toUnit(1, SpeedUnit.knot),
        closeTo(1.94384, 0.0001),
      );
    });

    test('knots to kilometers per hour', () {
      expect(
        SpeedUnit.knot.toUnit(1, SpeedUnit.kilometerPerHour),
        closeTo(1.852, 0.0001),
      );
    });

    test('kilometers per hour to knots', () {
      expect(
        SpeedUnit.kilometerPerHour.toUnit(1, SpeedUnit.knot),
        closeTo(0.539957, 0.0001),
      );
    });

    test('knots to miles per hour', () {
      expect(
        SpeedUnit.knot.toUnit(1, SpeedUnit.milePerHour),
        closeTo(1.15078, 0.0001),
      );
    });

    test('miles per hour to knots', () {
      expect(
        SpeedUnit.milePerHour.toUnit(1, SpeedUnit.knot),
        closeTo(0.868976, 0.0001),
      );
    });
  });

  group('AngularVelocityUnit', () {
    test('radians per second to degrees per second', () {
      expect(
        AngularVelocityUnit.radianPerSecond
            .toUnit(1, AngularVelocityUnit.degreePerSecond),
        closeTo(57.2958, 0.0001),
      );
    });

    test('degrees per second to radians per second', () {
      expect(
        AngularVelocityUnit.degreePerSecond
            .toUnit(57.2958, AngularVelocityUnit.radianPerSecond),
        closeTo(1, 0.0001),
      );
    });

    test('radians per second to revolutions per minute', () {
      expect(
        AngularVelocityUnit.radianPerSecond
            .toUnit(1, AngularVelocityUnit.revolutionPerMinute),
        closeTo(9.5493, 0.0001),
      );
    });

    test('revolutions per minute to radians per second', () {
      expect(
        AngularVelocityUnit.revolutionPerMinute
            .toUnit(9.5493, AngularVelocityUnit.radianPerSecond),
        closeTo(1, 0.0001),
      );
    });

    test('degrees per second to revolutions per minute', () {
      expect(
        AngularVelocityUnit.degreePerSecond
            .toUnit(360, AngularVelocityUnit.revolutionPerMinute),
        closeTo(60, 0.0001),
      );
    });

    test('revolutions per minute to degrees per second', () {
      expect(
        AngularVelocityUnit.revolutionPerMinute
            .toUnit(60, AngularVelocityUnit.degreePerSecond),
        closeTo(360, 0.0001),
      );
    });
  });
}
