// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A measurable object may have measure values available.
abstract class Measurable {
  /// Default `const` constructor to allow extending this abstract class.
  const Measurable();

  /// True if a measure value is available (or the m coordinate for a position).
  bool get isMeasured;
}
