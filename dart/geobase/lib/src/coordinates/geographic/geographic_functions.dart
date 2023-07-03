// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/constants/geodetic.dart';

/// Returns a normalized longitude in the range `[-180.0, 180.0[` by using the
/// formula `(lon + 180.0) % 360.0 - 180.0` (if outside the range).
///
/// As a special case if [lon] is `double.nan` then `double.nan` is returned.
///
/// See also [clipLongitude] and the default constructor of `Geographic`.
double normalizeLongitude(double lon) =>
    lon >= -180.0 && lon < 180.0 ? lon : (lon + 180.0) % 360.0 - 180.0;

/// Returns a clipped longitude in the range `[-180.0 .. 180.0]`.
///
/// As a special case if [lon] is `double.nan` then `double.nan` is returned.
///
/// See also [normalizeLongitude].
num clipLongitude(double lon) => lon < minLongitude
    ? minLongitude
    : (lon > maxLongitude ? maxLongitude : lon);

/// Returns a clipped latitude in the range `[-90.0, 90.0]`.
///
/// As a special case if [lat] is `double.nan` then `double.nan` is returned.
///
/// See also [clipLatitudeWebMercator] and the default constructor of
/// `Geographic`.
double clipLatitude(double lat) =>
    lat < minLatitude ? minLatitude : (lat > maxLatitude ? maxLatitude : lat);

/// Returns a clipped latitude in the range `[-85.05112878, 85.05112878]`
/// inside the Web Mercator projection coverage.
///
/// As a special case if [lat] is `double.nan` then `double.nan` is returned.
///
/// See also [clipLatitude].
double clipLatitudeWebMercator(double lat) => lat < minLatitudeWebMercator
    ? minLatitudeWebMercator
    : (lat > maxLatitudeWebMercator ? maxLatitudeWebMercator : lat);
