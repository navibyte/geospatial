// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/conversions/angle_unit.dart';
import '/src/common/conversions/angular_velocity_unit.dart';
import '/src/common/conversions/area_unit.dart';
import '/src/common/conversions/length_unit.dart';
import '/src/common/conversions/speed_unit.dart';
import '/src/common/conversions/time_unit.dart';

/// An extension on [double] with conversion methods for angle, angular
/// velocity, area, length, speed and time units.
extension UnitConversionExtension on double {
  /// Converts this double value from one angle unit to another.
  ///
  /// Set the source unit using [from] and the target unit using [to]. The
  /// default unit is [AngleUnit.radian] for both of them.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // from degrees to radians
  /// 90.0.convertAngle(from: AngleUnit.degree); // ~1.5708
  ///
  /// // from radians to degrees
  /// 1.5708.convertAngle(to: AngleUnit.degree); // ~90.0
  /// ```
  ///
  /// See also [AngleUnit] for unit types and conversion implementations.
  double convertAngle({
    AngleUnit from = AngleUnit.radian,
    AngleUnit to = AngleUnit.radian,
  }) =>
      from.toUnit(this, to);

  /// Converts this double value from one angular velocity unit to another.
  ///
  /// Set the source unit using [from] and the target unit using [to]. The
  /// default unit is [AngularVelocityUnit.radianPerSecond] for both of them.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // from radians per second to degrees per second
  /// 1.0.convertAngularVelocity(
  ///     to: AngularVelocityUnit.degreePerSecond); // ~57.296
  ///
  /// // from degrees per second to radians per second
  /// 57.296.convertAngularVelocity(
  ///     from: AngularVelocityUnit.degreePerSecond); // ~1.0
  /// ```
  ///
  /// See also [AngularVelocityUnit] for unit types and conversion
  /// implementations.
  double convertAngularVelocity({
    AngularVelocityUnit from = AngularVelocityUnit.radianPerSecond,
    AngularVelocityUnit to = AngularVelocityUnit.radianPerSecond,
  }) =>
      from.toUnit(this, to);

  /// Converts this double value from one area unit to another.
  ///
  /// Set the source unit using [from] and the target unit using [to]. The
  /// default unit is [AreaUnit.squareMeter] for both of them.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // from square meters to square kilometers
  /// 1000000.0.convertArea(to: AreaUnit.squareKilometer); // ~1.0
  ///
  /// // from square kilometers to square meters
  /// 1.0.convertArea(from: AreaUnit.squareKilometer); // ~1000000.0
  /// ```
  ///
  /// See also [AreaUnit] for unit types and conversion implementations.
  double convertArea({
    AreaUnit from = AreaUnit.squareMeter,
    AreaUnit to = AreaUnit.squareMeter,
  }) =>
      from.toUnit(this, to);

  /// Converts this double value from one length unit to another.
  ///
  /// Set the source unit using [from] and the target unit using [to]. The
  /// default unit is [LengthUnit.meter] for both of them.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // from meters to kilometers
  /// 1000.0.convertLength(to: LengthUnit.kilometer); // ~1.0
  ///
  /// // from kilometers to meters
  /// 1.0.convertLength(from: LengthUnit.kilometer); // ~1000.0
  /// ```
  ///
  /// See also [LengthUnit] for unit types and conversion implementations.
  double convertLength({
    LengthUnit from = LengthUnit.meter,
    LengthUnit to = LengthUnit.meter,
  }) =>
      from.toUnit(this, to);

  /// Converts this double value from one speed unit to another.
  ///
  /// Set the source unit using [from] and the target unit using [to]. The
  /// default unit is [SpeedUnit.meterPerSecond] for both of them.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // from meters per second to kilometers per hour
  /// 1.0.convertSpeed(to: SpeedUnit.kilometerPerHour); // ~3.6
  ///
  /// // from kilometers per hour to meters per second
  /// 3.6.convertSpeed(from: SpeedUnit.kilometerPerHour); // ~1.0
  /// ```
  ///
  /// See also [SpeedUnit] for unit types and conversion implementations.
  double convertSpeed({
    SpeedUnit from = SpeedUnit.meterPerSecond,
    SpeedUnit to = SpeedUnit.meterPerSecond,
  }) =>
      from.toUnit(this, to);

  /// Converts this double value from one time unit to another.
  ///
  /// Set the source unit using [from] and the target unit using [to]. The
  /// default unit is [TimeUnit.second] for both of them.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // from seconds to minutes
  /// 60.0.convertTime(to: TimeUnit.minute); // ~1.0
  ///
  /// // from minutes to seconds
  /// 1.0.convertTime(from: TimeUnit.minute); // ~60.0
  /// ```
  ///
  /// See also [TimeUnit] for unit types and conversion implementations.
  double convertTime({
    TimeUnit from = TimeUnit.second,
    TimeUnit to = TimeUnit.second,
  }) =>
      from.toUnit(this, to);
}
