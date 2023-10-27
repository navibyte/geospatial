// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// The precision for cardinal directions (compass point).
enum CardinalPrecision {
  /// Supported directions: N, E, S, W.
  cardinal(1),

  /// Supported directions: N, NE, E, SE, S, SW, W, NW.
  intercardinal(2),

  /// Supported directions: N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW,
  /// W, WNW, NW, NNW.
  secondaryIntercardinal(3);

  /// A numeric value (1, 2 or 3) descibing the precision.
  final int value;

  const CardinalPrecision(this.value);
}
