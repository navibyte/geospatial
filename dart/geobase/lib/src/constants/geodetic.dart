// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

/// The minimum value for geographic longitude.
const minLongitude = -180.0;

/// The maximum value for geographic longitude.
const maxLongitude = 180.0;

/// The minimum value for geographic latitude;
const minLatitude = -90.0;

/// The maximum value for geographic latitude;
const maxLatitude = 90.0;

/// The minimum value for geographic latitude inside Web Mercator coverage;
const minLatitudeWebMercator = -85.05112878;

/// The maximum value for geographic latitude inside Web Mercator coverage;
const maxLatitudeWebMercator = 85.05112878;

/// The earth equatorial radius in meters as specified by WGS 84.
const earthRadiusWgs84 = 6378137.0; 

/// The earth circumference in meters (from earth equatorial radius by WGS 84).
const earthCircumferenceWgs84 = 2 * math.pi * earthRadiusWgs84;
