// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enumeration of time units (representing values of time duration or
/// intervals).
///
/// The units are defined with conversion factors to seconds.
///
/// Examples:
///
/// ```dart
/// /// Convert directly from and to seconds.
/// final seconds = 3600.0;
/// final hours = TimeUnit.hour.fromSeconds(seconds); // 1.0
/// final seconds2 = TimeUnit.hour.toSeconds(hours); // 3600.0
///
/// /// You can also convert between units without using seconds.
/// final minutes = TimeUnit.hour.toUnit(hours, TimeUnit.minute); // 60.0
/// ```
///
/// See also [Unit of time](https://en.wikipedia.org/wiki/Unit_of_time) in
/// Wikipedia.
enum TimeUnit {
  /// 1 nanosecond is equal to 1e-9 seconds.
  nanosecond(1e-9, 'ns'),

  /// 1 microsecond (μs) is equal to 1e-6 seconds.
  microsecond(1e-6, 'μs'),

  /// 1 millisecond is equal to 0.001 seconds.
  millisecond(0.001, 'ms'),

  /// 1 second is the base unit for time.
  second(1.0, 's'),

  /// 1 minute is equal to 60 seconds.
  minute(60.0, 'min'),

  /// 1 hour is equal to 3600 seconds.
  hour(3600.0, 'h'),

  /// 1 day is equal to 86400 seconds.
  day(86400.0, 'd'),

  /// 1 week is equal to 604800 seconds.
  week(604800.0, 'w');

  /// The conversion factor to seconds.
  final double factorToSeconds;

  /// The unit symbol.
  final String symbol;

  const TimeUnit(this.factorToSeconds, this.symbol);

  /// Convert a value from this unit to seconds.
  double toSeconds(double value) {
    return value * factorToSeconds;
  }

  /// Convert a value from seconds to this unit.
  double fromSeconds(double value) {
    return value / factorToSeconds;
  }

  /// Convert a value from this unit to another unit.
  double toUnit(double value, TimeUnit targetUnit) {
    final valueInSeconds = toSeconds(value);
    return targetUnit.fromSeconds(valueInSeconds);
  }

  /// Convert a value from another unit to this unit.
  double fromUnit(double value, TimeUnit sourceUnit) {
    final valueInSeconds = sourceUnit.toSeconds(value);
    return fromSeconds(valueInSeconds);
  }
}
