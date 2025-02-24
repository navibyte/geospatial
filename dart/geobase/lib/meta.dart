// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Temporal data structures (instant, interval) and spatial extents.
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/meta.dart`
library meta;

export 'src/common/reference/coord_ref_sys.dart';
export 'src/common/reference/temporal_ref_sys.dart';
export 'src/meta/extent/geo_extent.dart';
export 'src/meta/extent/spatial_extent.dart';
export 'src/meta/extent/temporal_extent.dart';
export 'src/meta/time/instant.dart';
export 'src/meta/time/interval.dart';
export 'src/meta/time/temporal.dart';
