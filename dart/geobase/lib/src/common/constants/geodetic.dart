// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

/// The minimum value for the geographic longitude.
///
/// The value is `-180.0`.
const minLongitude = -180.0;

/// The maximum value for the geographic longitude.
///
/// The value is `180.0`.
const maxLongitude = 180.0;

/// The minimum value for the geographic latitude.
///
/// The value is `-90.0`.
const minLatitude = -90.0;

/// The maximum value for the geographic latitude.
///
/// The value is `90.0`.
const maxLatitude = 90.0;

/// The minimum value for the geographic latitude inside the Web Mercator
/// projection coverage.
///
/// The value is `-85.05112878`.
const minLatitudeWebMercator = -85.05112878;

/// The maximum value for the geographic latitude inside the Web Mercator
/// projection coverage.
///
/// The value is `85.05112878`.
const maxLatitudeWebMercator = 85.05112878;

/// The minimum value for the geographic latitude inside the Universal
/// Transverse Mercator (UTM) projection coverage.
///
/// The value is `-80.0`.
const minLatitudeUTM = -80.0;

/// The maximum value for the geographic latitude inside the Universal
/// Transverse Mercator (UTM) projection coverage.
///
/// The value is `84.0`.
const maxLatitudeUTM = 84.0;

/// The earth equatorial radius in meters as specified by WGS 84.
///
/// The value is `6378137.0`.
const earthRadiusWgs84 = 6378137.0;

/// The earth circumference in meters (from earth equatorial radius by WGS 84).
const earthCircumferenceWgs84 = 2 * math.pi * earthRadiusWgs84;
