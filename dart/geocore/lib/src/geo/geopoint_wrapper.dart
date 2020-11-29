// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'dart:math';

import '../base/point.dart';
import '../base/point_wrapper.dart';
import '../utils/geography/geoutils.dart';

import 'geopoint.dart';

/// A geographic point with getters to access the wrapped [point].
///
/// This class is surely immutable, but the aggregated [point] object may
/// or may not to be immutable.
class GeoPointWrapper<T extends Point> extends PointWrapper<T>
    implements GeoPoint {
  const GeoPointWrapper(T point) : super(point);

  @override
  double get lon => point.x;

  @override
  double get lat => point.y;

  @override
  double get elev => point.z;

  @override
  double distanceTo(GeoPoint other) =>
      distanceHaversine(lon, lat, other.lon, other.lat);
}
