// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A positionable object has (geospatial) coordinate values available.
///
/// This interface is extended at least by `Position` (representing a single
/// position), `PositionSeries` (representing a series of positions) and `Box`
/// (representing a single bounding box with minimum and maximum coordinates).
abstract class Positionable {
  /// Default `const` constructor to allow extending this abstract class.
  const Positionable();
}
