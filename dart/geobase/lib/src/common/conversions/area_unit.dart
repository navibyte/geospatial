// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enumeration of area units.
///
/// The units are defined with conversion factors to square meters.
///
/// Examples:
///
/// ```dart
/// // Convert directly from and to square meters.
/// final squareMeters = 10000.0;
/// final sqKmUnit = AreaUnit.squareKilometer;
/// final squareKilometers = sqKmUnit.fromSquareMeters(squareMeters); // 0.01
/// final squareMeters2 = sqKmUnit.toSquareMeters(squareKilometers); // 10000.0
///
/// // You can also convert between units without using square meters.
/// final acres = sqKmUnit.toUnit(squareKilometers, AreaUnit.acre); // ~2.4711
/// ```
///
/// See also [Area](https://en.wikipedia.org/wiki/Area) in Wikipedia.
enum AreaUnit {
  /// 1 square millimeter is equal to 1e-6 square meters.
  squareMillimeter(1e-6, 'mm²'),

  /// 1 square centimeter is equal to 1e-4 square meters.
  squareCentimeter(1e-4, 'cm²'),

  /// The SI base unit for area.
  squareMeter(1.0, 'm²'),

  /// 1 square kilometer is equal to 1e+6 square meters.
  squareKilometer(1e6, 'km²'),

  /// 1 square inch is equal to 0.00064516 square meters.
  squareInch(0.00064516, 'in²'),

  /// 1 square foot is equal to 0.09290304 square meters.
  squareFoot(0.09290304, 'ft²'),

  /// 1 square yard is equal to 0.83612736 square meters.
  squareYard(0.83612736, 'yd²'),

  /// 1 square mile is equal to 2589988.11 square meters.
  squareMile(2589988.11, 'mi²'),

  /// 1 acre is equal to 4046.8564224 square meters.
  acre(4046.8564224, 'ac'),

  /// 1 hectare is equal to 10000 square meters.
  hectare(10000.0, 'ha');

  /// The conversion factor to square meters.
  final double factorToSquareMeters;

  /// The unit symbol.
  final String symbol;

  const AreaUnit(this.factorToSquareMeters, this.symbol);

  /// Convert a value from this unit to square meters.
  double toSquareMeters(double value) {
    return value * factorToSquareMeters;
  }

  /// Convert a value from square meters to this unit.
  double fromSquareMeters(double value) {
    return value / factorToSquareMeters;
  }

  /// Convert a value from this unit to another unit.
  double toUnit(double value, AreaUnit targetUnit) {
    final valueInSquareMeters = toSquareMeters(value);
    return targetUnit.fromSquareMeters(valueInSquareMeters);
  }

  /// Convert a value from another unit to this unit.
  double fromUnit(double value, AreaUnit sourceUnit) {
    final valueInSquareMeters = sourceUnit.toSquareMeters(value);
    return fromSquareMeters(valueInSquareMeters);
  }
}
