// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math';

/// An enumeration of angle units.
///
/// The units are defined with conversion factors to radians.
///
/// Examples:
///
/// ```dart
/// // Convert directly from and to radians.
/// final radians = 3.14159; // ~pi
/// final degrees = AngleUnit.degree.fromRadians(radians); // ~180.0
/// final radians2 = AngleUnit.degree.toRadians(degrees); // ~3.14159
///
/// // You can also convert between units without using radians.
/// final gradians =
///     AngleUnit.degree.toUnit(degrees, AngleUnit.gradian); // ~200.0
/// ```
///
/// See also [Angle](https://en.wikipedia.org/wiki/Angle) in Wikipedia.
enum AngleUnit {
  /// 1 milliradian is equal to 0.001 radians.
  milliradian(0.001, 'mrad'),

  /// The SI base unit for angles.
  ///
  /// 1 radian is approximately 57.296 degrees.
  radian(1.0, 'rad'),

  /// 1 arc second is equal to π / (180 * 60 * 60) radians.
  ///
  /// 1 degree contains 60 * 60 = 3600 arc seconds.
  arcSecond(pi / (180 * 60 * 60), 'arcsec'),

  /// 1 arc minute is equal to π / (180 * 60) radians.
  ///
  /// 1 degree contains 60 arc minutes.
  arcMinute(pi / (180 * 60), 'arcmin'),

  /// 1 degree is equal to π / 180 radians.
  ///
  /// 1 degree is 1/360 of a full circle.
  degree(pi / 180, 'deg'),

  /// 1 gradian is equal to π / 200 radians.
  ///
  /// 1 gradian is 1/400 of a full circle.
  gradian(pi / 200, 'gon'),

  /// 1 turn is equal to 2π radians.
  ///
  /// 1 turn is a full circle.
  turn(2 * pi, 'turn');

  /// The conversion factor to radians.
  final double factorToRadians;

  /// The unit symbol.
  final String symbol;

  const AngleUnit(this.factorToRadians, this.symbol);

  /// Convert a value from this unit to radians.
  double toRadians(double value) {
    return value * factorToRadians;
  }

  /// Convert a value from radians to this unit.
  double fromRadians(double value) {
    return value / factorToRadians;
  }

  /// Convert a value from this unit to another unit.
  double toUnit(double value, AngleUnit targetUnit) {
    final valueInRadians = toRadians(value);
    return targetUnit.fromRadians(valueInRadians);
  }

  /// Convert a value from another unit to this unit.
  double fromUnit(double value, AngleUnit sourceUnit) {
    final valueInRadians = sourceUnit.toRadians(value);
    return fromRadians(valueInRadians);
  }
}
