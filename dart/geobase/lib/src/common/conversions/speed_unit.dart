// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enumeration of speed units.
///
/// The units are defined with conversion factors to meters per second.
///
/// Examples:
///
/// ```dart
/// // Convert directly from and to meters per second.
/// final metersPerSecond = 3.6;
/// final kilometersPerHour =
///   SpeedUnit.kilometerPerHour.fromMetersPerSecond(metersPerSecond); // 12.96
/// final metersPerSecond2 =
///   SpeedUnit.kilometerPerHour.toMetersPerSecond(kilometersPerHour); // 3.6
///
/// // You can also convert between units without using meters per second.
/// final milesPerHour =
///   SpeedUnit.kilometerPerHour.toUnit(kilometersPerHour,
///        SpeedUnit.milePerHour); // 8.04672
/// ```
///
/// See also [Speed](https://en.wikipedia.org/wiki/Speed) in Wikipedia.
enum SpeedUnit {
  /// 1 millimeter per second is equal to 0.001 meters per second.
  millimeterPerSecond(0.001, 'mm/s'),

  /// 1 centimeter per second is equal to 0.01 meters per second.
  centimeterPerSecond(0.01, 'cm/s'),

  /// 1 meter per second is the base unit for speed.
  meterPerSecond(1.0, 'm/s'),

  /// 1 kilometer per hour is equal to ~ 0.2777777778 meters per second.
  kilometerPerHour(0.2777777778, 'km/h'),

  /// 1 mile per hour is equal to 0.44704 meters per second.
  milePerHour(0.44704, 'mph'),

  /// 1 foot per second is equal to 0.3048 meters per second.
  footPerSecond(0.3048, 'ft/s'),

  /// 1 knot is equal to ~ 0.514444 meters per second.
  knot(0.5144444444, 'kn');

  /// The conversion factor to meters per second.
  final double factorToMetersPerSecond;

  /// The unit symbol.
  final String symbol;

  const SpeedUnit(this.factorToMetersPerSecond, this.symbol);

  /// Convert a value from this unit to meters per second.
  double toMetersPerSecond(double value) {
    return value * factorToMetersPerSecond;
  }

  /// Convert a value from meters per second to this unit.
  double fromMetersPerSecond(double value) {
    return value / factorToMetersPerSecond;
  }

  /// Convert a value from this unit to another unit.
  double toUnit(double value, SpeedUnit targetUnit) {
    final valueInMetersPerSecond = toMetersPerSecond(value);
    return targetUnit.fromMetersPerSecond(valueInMetersPerSecond);
  }

  /// Convert a value from another unit to this unit.
  double fromUnit(double value, SpeedUnit sourceUnit) {
    final valueInMetersPerSecond = sourceUnit.toMetersPerSecond(value);
    return fromMetersPerSecond(valueInMetersPerSecond);
  }
}
