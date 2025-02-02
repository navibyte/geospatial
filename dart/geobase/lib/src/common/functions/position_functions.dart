// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math';

const _toRad = pi / 180.0;

/// An extension on [double] with basic degrees and radians utility methods.
extension DoubleAngleExtension on double {
  /// Converts this double value in degrees to radians.
  ///
  /// See also `convertAngle()` that allows conversion between different angle
  /// units.
  double toRadians() => this * _toRad;

  /// Converts this double value in radians to degrees.
  ///
  /// See also `convertAngle()` that allows conversion between different angle
  /// units.
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
}
