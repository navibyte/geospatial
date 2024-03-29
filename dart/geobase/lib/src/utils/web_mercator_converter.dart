// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import 'package:meta/meta.dart';

import '/src/common/constants/geodetic.dart';
import '/src/common/functions/geographic_functions.dart';
import '/src/tiling/convert/scaled_converter.dart';

// const _originShift = earthCircumferenceWgs84 / 2.0; // meters (~ 20037508.34)

/// Returns a clipped latitude in the range `[-89.999999, 89.999999]`.
///
/// As a special case if [lat] is `double.nan` then `double.nan` is returned.
double _clipLatitudeWithEpsilon(double lat) =>
    lat < -89.999999 ? -89.999999 : (lat > 89.999999 ? 89.999999 : lat);

/// A helper class to convert geographic coordinates to Web Mercator projection.
@internal
class WebMercatorConverter implements ScaledConverter {
  /// Create a converter from geographic coordinates to mercator projection.
  ///
  /// This implementation is based on the WGS 84 / Web Mercator projection
  /// ("EPSG:3857") aka "Pseudo-Mercator" or "Spherical Mercator".
  const WebMercatorConverter.epsg3857();

  /// The earth radius in meters.
  double get earthRadius => earthRadiusWgs84;

  /// The earth circumference in meters.
  double get earthCircumference => earthCircumferenceWgs84;

  /// The pixel ground resolution in meters at given [latitude] and map [size].
  double pixelResolutionAt(double latitude, num size) {
    final lat = latitude.clipLatitudeWebMercator();
    return (math.cos(lat * math.pi / 180.0) * earthCircumference) / size;
  }

  /// The map size from pixel ground [resolution] in meters at given [latitude].
  double sizeFromPixelResolutionAt(double latitude, double resolution) {
    final lat = latitude.clipLatitudeWebMercator();
    return (math.cos(lat * math.pi / 180.0) * earthCircumference) / resolution;
  }

  /// Converts geographic [longitude] to projected map x coordinate (metric).
  ///
  /// X origin at the prime meridian (lon: 0), X axis from west to east.
  double toProjectedX(double longitude) {
    final lon = longitude.wrapLongitude();
    return lon * earthCircumference / 360.0;
  }

  /// Converts geographic [latitude] to projected map y coordinate (metric).
  ///
  /// Y origin at the equator (lat: 0), Y from south to north.
  double toProjectedY(double latitude) {
    // clip latitude to range `[-89.999999, 89.999999]` to ensure no infinity
    final lat = _clipLatitudeWithEpsilon(latitude);

    final sinLat = math.sin(lat * math.pi / 180.0);
    final y = math.log((1.0 + sinLat) / (1.0 - sinLat)) / (4.0 * math.pi);
    return y * earthCircumference;
  }

  /// Converts projected map [x] coordinate (metric) to geographic longitude.
  ///
  /// X origin at the prime meridian (lon: 0), X axis from west to east.
  double fromProjectedX(double x) {
    return ((x / earthCircumference) * 360.0).wrapLongitude();
  }

  /// Converts projected map [y] coordinate (metric) to geographic latitude.
  ///
  /// Y origin at the equator (lat: 0), Y from south to north.
  double fromProjectedY(double y) {
    final y0 = y / earthCircumference;
    return (90.0 - 360.0 * math.atan(math.exp(-y0 * 2.0 * math.pi)) / math.pi)
        .clipLatitude();
  }

  /// Converts geographic [longitude] to x coordinate with range (0, [width]).
  ///
  /// X origin at the anti-meridian (lon: -180), X axis from west to east.
  @override
  double toScaledX(num longitude, {num width = 256}) {
    final lon = longitude.toDouble().wrapLongitude();
    return (0.5 + lon / 360.0) * width;
  }

  /// Converts geographic [latitude] to y coordinate with range (0, [height]).
  ///
  /// Y origin near the north pole (lat: 85.05112878), Y from north to south.
  @override
  double toScaledY(num latitude, {num height = 256}) {
    final lat = latitude.toDouble().clipLatitudeWebMercator();
    final sinLat = math.sin(lat * math.pi / 180.0);
    final y = 0.5 - math.log((1.0 + sinLat) / (1.0 - sinLat)) / (4.0 * math.pi);
    return y * height;
  }

  /// Converts [x] coordinate with range (0, [width]) to geographic longitude.
  ///
  /// X origin at the anti-meridian (lon: -180), X axis from west to east.
  @override
  double fromScaledX(num x, {num width = 256}) {
    final xc = x.clamp(0, width);
    return ((xc / width) - 0.5) * 360.0;
  }

  /// Converts [y] coordinate with range (0, [height]) to geographic latitude.
  ///
  /// Y origin near the north pole (lat: 85.05112878), Y from north to south.
  @override
  double fromScaledY(num y, {num height = 256}) {
    final yc = y.clamp(0, height);
    final y0 = 0.5 - yc / height;
    return 90.0 - 360.0 * math.atan(math.exp(-y0 * 2.0 * math.pi)) / math.pi;
  }
}
