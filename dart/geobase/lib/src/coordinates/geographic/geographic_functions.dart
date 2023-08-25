// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math';

import '/src/constants/geodetic.dart';

const _toRad = pi / 180.0;

/// An extension on [double] with basic degrees and radians utility methods.
extension DoubleAngleExtension on double {
  /// Converts this double value in degrees to radians.
  double toRadians() => this * _toRad;

  /// Converts this double value in radians to degrees.
  double toDegrees() => this / _toRad;

  /// Normalizes this double value in degrees to the range `[0.0, 360.0[`.
  ///
  /// Examples:
  /// * `5.0` => `5.0`
  /// * `-5.0` => `355.0`
  /// * `362.0` => `2.0`
  ///
  /// As a special case if this is `double.nan` then `double.nan` is returned.
  double wrap360() {
    if (this >= 0.0 && this < 360.0) {
      return this;
    }
    return this % 360.0;
  }

  /// Converts this double value in degrees to a normalized longitude in the
  /// range `[-180.0, 180.0[`.
  ///
  /// Examples:
  /// * `-179.0` => `-179.0`
  /// * `-182.0` => `178.0`
  /// * `179.0` => `179.0`
  /// * `182.0` => `-178.0`
  ///
  /// Uses the formula `(this + 180.0) % 360.0 - 180.0` (if outside the range).
  ///
  /// As a special case if this is `double.nan` then `double.nan` is returned.
  ///
  /// See also [clipLongitude] and the default constructor of `Geographic`.
  double wrapLongitude() =>
      this >= -180.0 && this < 180.0 ? this : (this + 180.0) % 360.0 - 180.0;

  /// Converts this double value in degrees to a clipped longitude in the range
  /// `[-180.0 .. 180.0]`.
  ///
  /// As a special case if this is `double.nan` then `double.nan` is returned.
  ///
  /// See also [wrapLongitude].
  double clipLongitude() => this < minLongitude
      ? minLongitude
      : (this > maxLongitude ? maxLongitude : this);

  /// Converts this double value in degrees to a normalized latitude in the
  /// range `[-90.0, 90.0]`.
  ///
  /// Examples:
  /// * `-89.0` => `-89.0`
  /// * `-92.0` => `-88.0`
  /// * `89.0` => `89.0`
  /// * `92.0` => `88.0`
  ///
  /// As a special case if this is `double.nan` then `double.nan` is returned.
  ///
  /// See also [clipLatitude].
  double wrapLatitude() {
    if (this >= -90.0 && this <= 90.0) {
      // already normalized
      return this;
    } else {
      if (this > 90.0) {
        // north pole as reference
        final x = (this - 90.0) % 360.0;
        if (x <= 180.0) {
          return 90.0 - x;
        } else {
          return -90.0 + (x - 180.0);
        }
      } else {
        // south pole as reference
        final x = (this + 90.0).abs() % 360.0;
        if (x <= 180.0) {
          return -90.0 + x;
        } else {
          return 90.0 - (x - 180.0);
        }
      }
    }
  }

  /// Converts this double value in degrees to a clipped latitude in the range
  /// `[-90.0, 90.0]`.
  ///
  /// As a special case if this is `double.nan` then `double.nan` is returned.
  ///
  /// See also the default constructor of `Geographic`.
  double clipLatitude() => this < minLatitude
      ? minLatitude
      : (this > maxLatitude ? maxLatitude : this);

  /// Converts this double value in degrees to a clipped latitude in the range
  /// `[-85.05112878, 85.05112878]` inside the Web Mercator projection coverage.
  ///
  /// As a special case if this is `double.nan` then `double.nan` is returned.
  ///
  /// See also [clipLatitude].
  double clipLatitudeWebMercator() => this < minLatitudeWebMercator
      ? minLatitudeWebMercator
      : (this > maxLatitudeWebMercator ? maxLatitudeWebMercator : this);
}
