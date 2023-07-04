// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Tiling schemes and tile matrix sets (web mercator, global geodetic).
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/tiling.dart`
library tiling;

export 'src/codes/canvas_origin.dart';
export 'src/constants/geodetic.dart';
export 'src/constants/screen_ppi.dart';
export 'src/tiling/convert/scaled_converter.dart';
export 'src/tiling/tilematrix/base/geo_tile_matrix_set.dart';
export 'src/tiling/tilematrix/base/tile_matrix_set.dart';
export 'src/tiling/tilematrix/mercator/web_mercator_quad.dart';
export 'src/tiling/tilematrix/plate_carree/global_geodetic_quad.dart';
