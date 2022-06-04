// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import '/src/tiling/core/map.dart';

const _minLat = -85.05112878;
const _maxLat = 85.05112878;
const _minLon = -180.0;
const _maxLon = 180.0;
const _earthRadius = 6378137.0; // in meters
const _earthCircumference = 2 * math.pi * _earthRadius; // in meters
const _originShift = _earthCircumference / 2.0; // in meters (~ 20037508.34)

/// A helper class to convert geographic coordinates to Web Mercator projection.
class WebMercatorConverter implements MapConverter {
  /// Create a converter from geographic coordinates to mercator projection.
  ///
  /// This implementation is based on the WGS 84 / Web Mercator projection
  /// ("EPSG:3857") aka "Pseudo-Mercator" or "Spherical Mercator".
  const WebMercatorConverter.epsg3857();

  /// The earth radius in meters.
  double get earthRadius => _earthRadius;

  /// The earth circumference in meters.
  double get earthCircumference => _earthCircumference;

  /// Clamps [latitude] to allowed range, here -85.05112878 .. 85.05112878.
  num clampLatitude(num latitude) => latitude.clamp(_minLat, _maxLat);

  /// Clamps [longitude] to allowed range, here -180.0 .. 180.0.
  num clampLongitude(num longitude) => longitude.clamp(_minLon, _maxLon);

  /// The pixel ground resolution in meters at given [latitude] and map [size].
  double pixelResolutionAt(double latitude, num size) {
    final lat = clampLatitude(latitude);
    return (math.cos(lat * math.pi / 180) * earthCircumference) / size;
  }

  /// Converts geographic [longitude] to projected map x coordinate (meters).
  ///
  /// X origin at the prime meridian (lon: 0), X axis from west to east.
  double toProjectedX(num longitude) {
    final lon = clampLongitude(longitude);
    return lon * _originShift / 180.0;
  }

  /// Converts geographic [latitude] to projected map y coordinate (meters).
  ///
  /// Y origin at the equator (lat: 0), Y from south to north.
  double toProjectedY(num latitude) {
    final lat = clampLatitude(latitude);
    final y0 =
        math.log(math.tan((90.0 + lat) * math.pi / 360.0)) / (math.pi / 180.0);
    return y0 * _originShift / 180.0;
  }

  /// Converts projected map [x] coordinate (meters) to geographic longitude.
  ///
  /// X origin at the prime meridian (lon: 0), X axis from west to east.
  double fromProjectedX(num x) {
    final xc = x.clamp(-_originShift, _originShift);
    return (xc / _originShift) * 180.0;
  }

  /// Converts projected map [y] coordinate (meters) to geographic latitude.
  ///
  /// Y origin at the equator (lat: 0), Y from south to north.
  double fromProjectedY(num y) {
    final yc = y.clamp(-_originShift, _originShift);
    final lat0 = (yc / _originShift) * 180.0;
    return 180.0 /
        math.pi *
        (2 * math.atan(math.exp(lat0 * math.pi / 180.0)) - math.pi / 2);
  }

  /// Converts geographic [longitude] to x coordinate with range (0, [width]).
  ///
  /// X origin at the anti-meridian (lon: -180), X axis from west to east.
  @override
  double toMappedX(num longitude, {num width = 256}) {
    final lon = clampLongitude(longitude);
    return (180.0 + lon) * width / 360.0;
  }

  /// Converts geographic [latitude] to y coordinate with range (0, [height]).
  ///
  /// Y origin near the north pole (lat: 85.05112878), Y from north to south.
  @override
  double toMappedY(num latitude, {num height = 256}) {
    final lat = clampLatitude(latitude);
    final y0 =
        math.log(math.tan((90.0 + lat) * math.pi / 360.0)) / (math.pi / 180.0);
    final sizePer2 = height / 2;
    return sizePer2 - (y0 * sizePer2 / 180.0);
  }

  /// Converts [x] coordinate with range (0, [width]) to geographic longitude.
  ///
  /// X origin at the anti-meridian (lon: -180), X axis from west to east.
  @override
  double fromMappedX(num x, {num width = 256}) {
    final xc = x.clamp(0, width);
    return (xc / width) * 360.0 - 180.0;
  }

  /// Converts [y] coordinate with range (0, [height]) to geographic latitude.
  ///
  /// Y origin near the north pole (lat: 85.05112878), Y from north to south.
  @override
  double fromMappedY(num y, {num height = 256}) {
    final yc = y.clamp(0, height);
    final sizePer2 = height / 2;
    final lat0 = ((sizePer2 - yc) / sizePer2) * 180.0;
    return 180.0 /
        math.pi *
        (2 * math.atan(math.exp(lat0 * math.pi / 180.0)) - math.pi / 2);
  }
}
