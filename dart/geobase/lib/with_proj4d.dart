// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Projections provided by the external `proj4dart` package.
///
/// The `geobase` package implements a projection adapter that acts as a wrapper
/// and uses internally the projection and coordinate reference system support
/// of the `proj4dart` package to which there's a dependency.
///
/// This library exports also all classes of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/with_proj4d.dart`
library with_proj4d;

export 'geobase.dart';

export 'src/projections/proj4d.dart';
