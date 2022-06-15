// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Projections provided by the external `proj4dart` package.
///
/// This package implements a projection adapter that acts as a wrapper and uses
/// internally the projection and coordinate reference system support of the
/// `proj4dart` package to which there's a dependency.
///
/// Usage: import `package:geobase/projections_proj4d.dart`
///
/// You might want to import also `package:geobase/geobase.dart` providing base
/// classes.
library projections_proj4d;

export 'src/projections_ext/proj4d.dart';
