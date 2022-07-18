// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';

import 'measurable.dart';

/// A positionable object has (geospatial) coordinate values available.
abstract class Positionable extends Measurable {
  /// Default `const` constructor to allow extending this abstract class.
  const Positionable();

  /// The number of coordinate values (2, 3 or 4) for this position.
  ///
  /// If value is 2, the position has 2D coordinates without m coordinate.
  ///
  /// If value is 3, the position has 2D coordinates with m coordinate or
  /// 3D coordinates without m coordinate.
  ///
  /// If value is 4, the position has 3D coordinates with m coordinate.
  ///
  /// Must be >= [spatialDimension].
  int get coordinateDimension {
    if (is3D) {
      return isMeasured ? 4 : 3;
    } else {
      return isMeasured ? 3 : 2;
    }
  }

  /// The number of spatial coordinate values (2 for 2D or 3 for 3D).
  int get spatialDimension => is3D ? 3 : 2;

  /// True for 3D positions (with z or elevation coordinate).
  bool get is3D;

  /// True for geographic positions (with longitude and latitude coordinates).
  ///
  /// If false is returned, then coordinates are projected or cartesian (with
  /// x and y coordinates).
  bool get isGeographic;

  /// Returns the type for coordinates of this position.
  Coords get typeCoords => Coords.select(
        is3D: is3D,
        isMeasured: isMeasured,
      );
}
