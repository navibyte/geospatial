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
        DistanceUnit.meter.toUnit(1000, DistanceUnit.kilometer),
        equals(1),
      );
    });

    test('kilometers to meters', () {
      expect(
        DistanceUnit.kilometer.toUnit(1, DistanceUnit.meter),
        equals(1000),
      );
    });

    test('meters to miles', () {
      expect(
        DistanceUnit.meter.toUnit(1609.34, DistanceUnit.mile),
        closeTo(1, 0.0001),
      );
    });

    test('miles to meters', () {
      expect(
        DistanceUnit.mile.toUnit(1, DistanceUnit.meter),
        closeTo(1609.344, 0.0001),
      );
    });

    test('kilometers to miles', () {
      expect(
        DistanceUnit.kilometer.toUnit(1.609344, DistanceUnit.mile),
        closeTo(1, 0.0001),
      );
    });

    test('miles to kilometers', () {
      expect(
        DistanceUnit.mile.toUnit(1, DistanceUnit.kilometer),
        closeTo(1.60934, 0.0001),
      );
    });

    test('meters to feet', () {
      expect(
        DistanceUnit.meter.toUnit(0.3048, DistanceUnit.foot),
        closeTo(1, 0.0001),
      );
    });

    test('feet to meters', () {
      expect(
        DistanceUnit.foot.toUnit(1, DistanceUnit.meter),
        closeTo(0.3048, 0.0001),
      );
    });

    test('kilometers to feet', () {
      expect(
        DistanceUnit.kilometer.toUnit(0.0003048, DistanceUnit.foot),
        closeTo(1, 0.0001),
      );
    });

    test('feet to kilometers', () {
      expect(
        DistanceUnit.foot.toUnit(1, DistanceUnit.kilometer),
        closeTo(0.0003048, 0.0001),
      );
    });

    test('miles to feet', () {
      expect(
        DistanceUnit.mile.toUnit(0.000189394, DistanceUnit.foot),
        closeTo(1, 0.0001),
      );
    });

    test('feet to miles', () {
      expect(
        DistanceUnit.foot.toUnit(1, DistanceUnit.mile),
        closeTo(0.000189394, 0.0001),
      );
    });

    test('nautical miles to meters', () {
      expect(
        DistanceUnit.nauticalMile.toUnit(1, DistanceUnit.meter),
        closeTo(1852, 0.0001),
      );
    });

    test('kilometers to nautical miles', () {
      expect(
        DistanceUnit.kilometer.toUnit(1.852, DistanceUnit.nauticalMile),
        closeTo(1, 0.0001),
      );
    });

    test('nautical miles to kilometers', () {
      expect(
        DistanceUnit.nauticalMile.toUnit(1, DistanceUnit.kilometer),
        closeTo(1.852, 0.0001),
      );
    });

    test('miles to nautical miles', () {
      expect(
        DistanceUnit.mile.toUnit(1.15078, DistanceUnit.nauticalMile),
        closeTo(1, 0.0001),
      );
    });

    test('nautical miles to miles', () {
      expect(
        DistanceUnit.nauticalMile.toUnit(1, DistanceUnit.mile),
        closeTo(1.15078, 0.0001),
      );
    });
  });

  group('AngleUnit', () {
    test('degrees to radians', () {
      expect(
        AngleUnit.degree.toUnit(180, AngleUnit.radian),
        closeTo(pi, 0.00001),
      );
    });

    test('radians to degrees', () {
      expect(
        AngleUnit.radian.toUnit(pi, AngleUnit.degree),
        closeTo(180, 0.00001),
      );
    });

    test('degrees to gradians', () {
      expect(
        AngleUnit.degree.toUnit(90, AngleUnit.gradian),
        closeTo(100, 0.00001),
      );
    });

    test('gradians to degrees', () {
      expect(
        AngleUnit.gradian.toUnit(100, AngleUnit.degree),
        closeTo(90, 0.00001),
      );
    });

    test('radians to gradians', () {
      expect(
        AngleUnit.radian.toUnit(pi, AngleUnit.gradian),
        closeTo(200, 0.00001),
      );
    });

    test('gradians to radians', () {
      expect(
        AngleUnit.gradian.toUnit(200, AngleUnit.radian),
        closeTo(pi, 0.00001),
      );
    });

    test('degrees to milliradians', () {
      expect(
        AngleUnit.degree.toUnit(1, AngleUnit.milliradian),
        closeTo(17.4533, 0.0001),
      );
    });

    test('milliradians to degrees', () {
      expect(
        AngleUnit.milliradian.toUnit(17.4533, AngleUnit.degree),
        closeTo(1, 0.0001),
      );
    });

    test('degrees to arc minutes', () {
      expect(
        AngleUnit.degree.toUnit(1, AngleUnit.arcMinute),
        closeTo(60, 0.0001),
      );
    });

    test('arc minutes to degrees', () {
      expect(
        AngleUnit.arcMinute.toUnit(60, AngleUnit.degree),
        closeTo(1, 0.0001),
      );
    });

    test('degrees to arc seconds', () {
      expect(
        AngleUnit.degree.toUnit(1, AngleUnit.arcSecond),
        closeTo(3600, 0.0001),
      );
    });

    test('arc seconds to degrees', () {
      expect(
        AngleUnit.arcSecond.toUnit(3600, AngleUnit.degree),
        closeTo(1, 0.0001),
      );
    });

    test('degrees to turns', () {
      expect(
        AngleUnit.degree.toUnit(360, AngleUnit.turn),
        closeTo(1, 0.0001),
      );
    });

    test('turns to degrees', () {
      expect(
        AngleUnit.turn.toUnit(1, AngleUnit.degree),
        closeTo(360, 0.0001),
      );
    });
  });

  group('AreaUnit', () {
    test('square meters to square kilometers', () {
      expect(
        AreaUnit.squareMeter.toUnit(1000000, AreaUnit.squareKilometer),
        equals(1),
      );
    });

    test('square kilometers to square meters', () {
      expect(
        AreaUnit.squareKilometer.toUnit(1, AreaUnit.squareMeter),
        equals(1000000),
      );
    });

    test('square meters to square miles', () {
      expect(
        AreaUnit.squareMeter.toUnit(2589988.11, AreaUnit.squareMile),
        closeTo(1, 0.0001),
      );
    });

    test('square miles to square meters', () {
      expect(
        AreaUnit.squareMile.toUnit(1, AreaUnit.squareMeter),
        closeTo(2589988.11, 0.0001),
      );
    });

    test('square kilometers to square miles', () {
      expect(
        AreaUnit.squareKilometer.toUnit(2.589988, AreaUnit.squareMile),
        closeTo(1, 0.0001),
      );
    });

    test('square miles to square kilometers', () {
      expect(
        AreaUnit.squareMile.toUnit(1, AreaUnit.squareKilometer),
        closeTo(2.589988, 0.0001),
      );
    });

    test('square meters to square feet', () {
      expect(
        AreaUnit.squareMeter.toUnit(0.092903, AreaUnit.squareFoot),
        closeTo(1, 0.0001),
      );
    });

    test('square feet to square meters', () {
      expect(
        AreaUnit.squareFoot.toUnit(1, AreaUnit.squareMeter),
        closeTo(0.092903, 0.0001),
      );
    });

    test('square kilometers to square feet', () {
      expect(
        AreaUnit.squareKilometer.toUnit(0.000000092903, AreaUnit.squareFoot),
        closeTo(1, 0.0001),
      );
    });

    test('square feet to square kilometers', () {
      expect(
        AreaUnit.squareFoot.toUnit(1, AreaUnit.squareKilometer),
        closeTo(0.000000092903, 0.0001),
      );
    });

    test('square miles to square feet', () {
      expect(
        AreaUnit.squareMile.toUnit(0.00000003587, AreaUnit.squareFoot),
        closeTo(1, 0.0001),
      );
    });

    test('square feet to square miles', () {
      expect(
        AreaUnit.squareFoot.toUnit(1, AreaUnit.squareMile),
        closeTo(0.00000003587, 0.0001),
      );
    });

    test('hectares to square meters', () {
      expect(
        AreaUnit.hectare.toUnit(1, AreaUnit.squareMeter),
        equals(10000),
      );
    });

    test('square meters to hectares', () {
      expect(
        AreaUnit.squareMeter.toUnit(10000, AreaUnit.hectare),
        equals(1),
      );
    });

    test('acres to square meters', () {
      expect(
        AreaUnit.acre.toUnit(1, AreaUnit.squareMeter),
        closeTo(4046.8564224, 0.0001),
      );
    });

    test('square meters to acres', () {
      expect(
        AreaUnit.squareMeter.toUnit(4046.8564224, AreaUnit.acre),
        closeTo(1, 0.0001),
      );
    });

    test('hectares to acres', () {
      expect(
        AreaUnit.hectare.toUnit(1, AreaUnit.acre),
        closeTo(2.47105, 0.0001),
      );
    });

    test('acres to hectares', () {
      expect(
        AreaUnit.acre.toUnit(1, AreaUnit.hectare),
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
