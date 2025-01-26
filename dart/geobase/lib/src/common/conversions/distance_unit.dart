// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enumeration of distance units.
///
/// The units are defined with conversion factors to meters.
///
/// Examples:
///
/// ```dart
/// /// Convert directly from and to meters.
/// final meters = 4000.0;
/// final kmUnit = DistanceUnit.kilometers;
/// final kilometers = kmUnit.fromMeters(meters); // 4.0
/// final meters2 = kmUnit.toMeters(kilometers); // 4000.0
///
/// /// You can also convert between units wihout using meters.
/// final miles = kmUnit.toUnits(kilometers, DistanceUnit.miles); // ~ 2.485484
/// ```dart
enum DistanceUnit {
  /// 1 millimeter is equal to 0.001 meters.
  millimeters(0.001, 'mm'),

  /// 1 centimeter is equal to 0.01 meters.
  centimeters(0.01, 'cm'),

  /// The SI base unit for distance .
  meters(1.0, 'm'),

  /// 1 kilometer is equal to 1000 meters.
  kilometers(1000.0, 'km'),

  /// 1 inch is equal to 0.0254 meters.
  inches(0.0254, 'in'),

  /// 1 foot is equal to 0.3048 meters.
  feet(0.3048, 'ft'),

  /// 1 yard is equal to 0.9144 meters.
  yards(0.9144, 'yd'),

  /// 1 mile is equal to 1609.344 meters.
  miles(1609.344, 'mi'),

  /// 1 nautical mile is equal to 1852 meters.
  /// 
  /// Official unit symbols for nautical miles are "NM", "nmi" or "M" depending
  /// on the context ([Wikipedia](https://en.wikipedia.org/wiki/Nautical_mile)).
  nauticalMiles(1852.0, 'nmi');

  /// The conversion factor to meters.
  final double factorToMeters;

  /// The unit symbol.
  final String symbol;

  const DistanceUnit(this.factorToMeters, this.symbol);

  /// Convert a value from this unit to meters.
  double toMeters(double value) {
    return value * factorToMeters;
  }

  /// Convert a value from meters to this unit.
  double fromMeters(double value) {
    return value / factorToMeters;
  }

  /// Convert a value from this unit to another unit.
  double toUnits(double value, DistanceUnit targetUnit) {
    final valueInMeters = toMeters(value);
    return targetUnit.fromMeters(valueInMeters);
  }

  /// Convert a value from another unit to this unit.
  double fromUnits(double value, DistanceUnit sourceUnit) {
    final valueInMeters = sourceUnit.toMeters(value);
    return fromMeters(valueInMeters);
  }
}
