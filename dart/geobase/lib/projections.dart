// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// WGS84 based projections; ellipsoidal (geographic, geocentric, UTM) and
/// spherical (Web Mercator).
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// See also `package:geobase/projections_proj4d.dart` that provides a
/// projection adapter using the external `proj4dart` package.
///
/// Usage: import `package:geobase/projections.dart`
library projections;

export 'src/common/reference/coord_ref_sys.dart';
export 'src/geodesy/ellipsoidal/datum.dart' show Datum;
export 'src/geodesy/ellipsoidal/utm.dart' show UtmZone;
export 'src/projections/wgs84/wgs84.dart';
