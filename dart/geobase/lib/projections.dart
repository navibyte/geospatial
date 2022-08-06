// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Geospatial projections (currently only between WGS84 and Web Mercator).
///
/// See also `package:geobase/projections_proj4d.dart` that provides a
/// projection adapter using the external `proj4dart` package.
///
/// Usage: import `package:geobase/projections.dart`
library projections;

export 'src/projections/mercator.dart';
