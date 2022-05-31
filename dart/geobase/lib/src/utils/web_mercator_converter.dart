// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

const _minLat = -85.05112878;
const _maxLat = 85.05112878;
const _minLon = -180.0;
const _maxLon = 180.0;
const _earthRadius = 6378137.0; // in meters
const _earthCircumference = 2 * math.pi * _earthRadius; // in meters
const _originShift = _earthCircumference / 2.0; // in meters (~ 20037508.34)

/// A helper class to convert geographic coordinates to Web Mercator projection.
class WebMercatorConverter {
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

  /// Converts geographic [longitude] to projected map x coordinate (meters).
  double toProjectedX(num longitude) {
    final lon = clampLongitude(longitude);
    return lon * _originShift / 180.0;
  }

  /// Converts geographic [latitude] to projected map y coordinate (meters).
  double toProjectedY(num latitude) {
    final lat = clampLatitude(latitude);
    final y0 =
        math.log(math.tan((90.0 + lat) * math.pi / 360.0)) / (math.pi / 180.0);
    return y0 * _originShift / 180.0;
  }

  /// Converts geographic [longitude] to x coordinate with range (0, size).
  double toMapX(num longitude, num size) {
    final lon = clampLongitude(longitude);
    return (180.0 + lon) * size / 360.0;
  }

  /// Converts geographic [latitude] to y coordinate with range (0, size).
  double toMapY(num latitude, num size) {
    final lat = clampLatitude(latitude);
    final y0 =
        math.log(math.tan((90.0 + lat) * math.pi / 360.0)) / (math.pi / 180.0);
    final sizePer2 = size / 2;
    return sizePer2 + (y0 * sizePer2 / 180.0);
  }

  /// Converts projected map [x] coordinate (meters) to geographic longitude.
  double toLongitude(num x) {
    final xc = x.clamp(-_originShift, _originShift);
    return (xc / _originShift) * 180.0;
  }

  /// Converts projected map [y] coordinate (meters) to geographic latitude.
  double toLatitude(num y) {
    final yc = y.clamp(-_originShift, _originShift);
    final lat0 = (yc / _originShift) * 180.0;
    return 180.0 /
        math.pi *
        (2 * math.atan(math.exp(lat0 * math.pi / 180.0)) - math.pi / 2);
  }

  /// Converts [x] coordinate with range (0, size) to geographic longitude.
  double mapXToLongitude(num x, num size) {
    final xc = x.clamp(0, size);
    return (xc / size) * 360.0 - 180.0;
  }

  /// Converts [y] coordinate with range (0, size) to geographic latitude.
  double mapYToLatitude(num y, num size) {
    final yc = y.clamp(0, size);
    final sizePer2 = size / 2;
    final lat0 = ((yc - sizePer2) / sizePer2) * 180.0;
    return 180.0 /
        math.pi *
        (2 * math.atan(math.exp(lat0 * math.pi / 180.0)) - math.pi / 2);
  }
}
