// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math';

/// An enumeration of angular velocity units.
///
/// The units are defined with conversion factors to radians per second.
///
/// Examples:
///
/// ```dart
/// /// Convert directly from and to radians per second.
/// final radiansPerSecond = 6.28319;
/// final rpmUnit = AngularVelocityUnit.revolutionPerMinute;
/// final rpm = rpmUnit.fromRadiansPerSecond(radiansPerSecond); // ~60.0
/// final radiansPerSecond2 = rpmUnit.toRadiansPerSecond(rpm); // ~6.28319
///
/// /// You can also convert between units without using radians per second.
/// final degreesPerSecond =
///     rpmUnit.toUnit(rpm, AngularVelocityUnit.degreePerSecond); // ~360.0
/// ```
///
/// See also [Angular velocity](https://en.wikipedia.org/wiki/Angular_velocity)
/// in Wikipedia.
enum AngularVelocityUnit {
  /// 1 degree per second is equal to π / 180 radians per second.
  degreePerSecond(pi / 180, '°/s'),

  /// 1 radian per second is the base unit for angular velocity.
  radianPerSecond(1.0, 'rad/s'),

  /// 1 revolution per minute is equal to 2π / 60 radians per second.
  revolutionPerMinute(2 * pi / 60, 'rpm'),

  /// 1 revolution per second is equal to 2π radians per second.
  revolutionPerSecond(2 * pi, 'rps'),

  /// 1 milliradian per second is equal to 0.001 radians per second.
  milliradianPerSecond(0.001, 'mrad/s');

  /// The conversion factor to radians per second.
  final double factorToRadiansPerSecond;

  /// The unit symbol.
  final String symbol;

  const AngularVelocityUnit(this.factorToRadiansPerSecond, this.symbol);

  /// Convert a value from this unit to radians per second.
  double toRadiansPerSecond(double value) {
    return value * factorToRadiansPerSecond;
  }

  /// Convert a value from radians per second to this unit.
  double fromRadiansPerSecond(double value) {
    return value / factorToRadiansPerSecond;
  }

  /// Convert a value from this unit to another unit.
  double toUnit(double value, AngularVelocityUnit targetUnit) {
    final valueInRadiansPerSecond = toRadiansPerSecond(value);
    return targetUnit.fromRadiansPerSecond(valueInRadiansPerSecond);
  }

  /// Convert a value from another unit to this unit.
  double fromUnit(double value, AngularVelocityUnit sourceUnit) {
    final valueInRadiansPerSecond = sourceUnit.toRadiansPerSecond(value);
    return fromRadiansPerSecond(valueInRadiansPerSecond);
  }
}
