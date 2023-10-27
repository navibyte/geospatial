// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Common codes and contants related to geospatial applications.
///
/// Enums (codes): geospatial coordinate, geometry types, dimensionality,
/// canvas origin, cardinal direction, DMS type, geo representation, axis order.
///
/// Constants: epsilon, geodetic and screen related constants.
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/common.dart`
library common;

// codes
export 'src/common/codes/axis_order.dart';
export 'src/common/codes/canvas_origin.dart';
export 'src/common/codes/cardinal_precision.dart';
export 'src/common/codes/coords.dart';
export 'src/common/codes/dimensionality.dart';
export 'src/common/codes/dms_type.dart';
export 'src/common/codes/geo_representation.dart';
export 'src/common/codes/geom.dart';

// constants
export 'src/common/constants/epsilon.dart';
export 'src/common/constants/geodetic.dart';
export 'src/common/constants/screen_ppi.dart';
