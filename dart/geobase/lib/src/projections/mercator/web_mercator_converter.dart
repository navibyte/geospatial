// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

const _earthRadius = 6378137.0; // in meters
const _earthCircumference = 2 * math.pi * _earthRadius; // in meters
const _originShift = _earthCircumference / 2.0; // in meters (~ 20037508.34)

/// A helper class to convert geographic coordinates to Web Mercator projection.
/// 
/// The default implementation is based on the WGS 84 / Web Mercator 
/// projection ("EPSG:3857") aka "Pseudo-Mercator" or "Spherical Mercator". 
class WebMercatorConverter {
  /// Create a convertter from geographic coordinates to mercator projection.
  const WebMercatorConverter();

  /// The earth radius in meters.
  double get earthRadius => _earthRadius;

  /// The earth circumference in meters.
  double get earthCircumference => _earthCircumference;
  
  /// The origin shift in meters.
  double get originShift => _originShift;

  /// Converts geographic [longitude] to projected world x coordinate (meters).
  double toProjectedX(num longitude) {
    return longitude * _originShift / 180.0;
  }

  /// Converts geographic [latitude] to projected world y coordinate (meters).
  double toProjectedY(num latitude) {
    final y0 = math.log(math.tan((90.0 + latitude) * math.pi / 360.0)) /
        (math.pi / 180.0);
    return y0 * _originShift / 180;
  }

  /// Converts projected world [x] coordinate (meters) to geographic longitude.
  double toLongitude(num x) {
    return (x / _originShift) * 180.0;
  }

  /// Converts projected world [y] coordinate (meters) to geographic latitude.
  double toLatitude(num y) {
    final lat0 = (y / _originShift) * 180.0;
    return 180.0 /
        math.pi *
        (2 * math.atan(math.exp(lat0 * math.pi / 180.0)) - math.pi / 2);
  }
}
