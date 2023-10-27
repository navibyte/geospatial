// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enum for common representation of geographic positions by coordinates
/// (using degrees, minutes and seconds as components).
enum DmsType {
  /// Format degree values as decimal degrees, ie. '23.6200°W'.
  deg,

  /// Format degree values using the "degrees/minutes" pattern, ie.
  /// '23°37.20′W'.
  degMin,

  /// Format degree values using the "degrees/minutes/seconds" pattern, ie.
  /// '23°37′12″W'.
  degMinSec
}
