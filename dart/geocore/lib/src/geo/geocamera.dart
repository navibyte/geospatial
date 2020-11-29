// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'dart:math';

import '../base/point.dart';
import 'geopoint.dart';
import 'geopoint_wrapper.dart';

/// A geospatial camera view.
class GeoCamera extends GeoPointWrapper<Point> {
  /// A camera view with [lon], [lat], [elev], [zoom], [bearing] and [tilt].
  GeoCamera(
      {required double lon,
      required double lat,
      double elev = 0.0,
      required this.zoom,
      this.bearing = 0.0,
      this.tilt = 0.0})
      : super(GeoPoint3(lon: lon, lat: lat, elev: elev));

  /// A camera view with geographical [target], [zoom], [bearing] and [tilt].
  const GeoCamera.target(Point target,
      {required this.zoom, this.bearing = 0.0, this.tilt = 0.0})
      : super(target);

  @override
  List<Object?> get props => [point, zoom, bearing, tilt];

  final double zoom, bearing, tilt;
}
