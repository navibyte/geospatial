// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'position.dart';

/// A geographic position with longitude, latitude and optional elevation.
///
/// Longitude is available at [lon], latitude at [lat] and elevation at [elev].
///
/// Longitude (range `[-180.0, 180.0[`) and latitude (range `[-90.0, 90.0]`) are
/// represented as deegrees. The unit for [elev] is meters.
///
/// Extends the [Position] interface. Properties have equality (in context of
/// this library): [lon] == [x], [lat] == [y], [elev] == [z]
abstract class GeoPosition extends Position {
  /// The longitude coordinate. Equals to [x].
  double get lon;

  /// The latitude coordinate. Equals to [y].
  double get lat;

  /// The elevation (or height or altitude) coordinate in meters. Equals to [z].
  ///
  /// Returns zero (`0`) if not available.
  /// 
  /// Use [is3D] to check whether elev coordinate is available.
  double get elev;
}
