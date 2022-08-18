// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Returns a normalized longitude in the range `[-180.0, 180.0[` by using the
/// formula `(lon + 180.0) % 360.0 - 180.0` (if outside the range).
double normalizeLongitude(double lon) =>
    lon >= -180.0 && lon < 180.0 ? lon : (lon + 180.0) % 360.0 - 180.0;

/// Returns a clamped latitude in the range `[-90.0, 90.0]`.
double clampLatitude(double lat) =>
    lat < -90.0 ? -90.0 : (lat > 90.0 ? 90.0 : lat);
