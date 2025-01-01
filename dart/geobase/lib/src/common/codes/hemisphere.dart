// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enum representing the hemispheres of the Earth.
enum Hemisphere {
  /// The northern hemisphere with the [symbol] representing 'N'.
  north('N'),

  /// The southern hemisphere with the [symbol] representing 'S'.
  south('S');

  /// The symbol of the hemisphere ('N' or 'S').
  final String symbol;

  const Hemisphere(this.symbol);
}
