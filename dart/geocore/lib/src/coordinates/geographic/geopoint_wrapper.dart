// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/base/spatial.dart';

import 'geopoint.dart';

/// A geographic position with wrapping a [GeoPoint] instance.
///
/// This class is surely immutable, but the aggregated [point] object may
/// or may not to be immutable.
class GeoPointWrapper<T extends GeoPoint> extends PointWrapper<T, double>
    implements GeoPoint {
  /// Creates a geographic position by wrapping [point].
  const GeoPointWrapper(super.point);

  @override
  double get lon => point.lon;

  @override
  double get lat => point.lat;

  @override
  double get elev => point.elev;

  @override
  double? get optElev => point.optElev;

  @override
  double distanceTo(GeoPoint other) => point.distanceTo(other);
}
