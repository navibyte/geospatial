// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// An private interface with methods prodiving information about coordinates.
///
/// Known sub classes: [Point], [Bounds].
abstract class _Coordinates {
  const _Coordinates();

  /// The number of coordinate values (2, 3 or 4).
  ///
  /// If value is 2, points have 2D coordinates without m coordinate.
  ///
  /// If value is 3, points have 2D coordinates with m coordinate or
  /// 3D coordinates without m coordinate.
  ///
  /// If value is 4, points have 3D coordinates with m coordinate.
  ///
  /// Must be >= [spatialDimension].
  int get coordinateDimension;

  /// The number of spatial coordinate values (2 for 2D or 3 for 3D).
  int get spatialDimension;

  /// True for 3D points (that is having Z coordinate).
  bool get is3D;

  /// True for points containing M coordinate.
  bool get hasM;
}
