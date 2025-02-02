// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Common codes, constants, functions, presentation helpers and reference
/// systems related to geospatial applications.
///
/// Features:
/// * Enums (codes): geospatial coordinate, geometry types, dimensionality,
///   canvas origin, cardinal direction, DMS type, geo representation, axis
///   order, hemisphere, coordinate reference system types.
/// * Constants: epsilon, geodetic and screen related constants.
/// * Conversions: angle, angular velocity, area, distance, speed and time.
/// * Functions: conversions between radians and degrees, geographic coordinate
///   helpers.
/// * Presentation: DMS (degree-minutes-seconds geographic representations).
/// * Reference: Coordinate and temporal reference systems. Reference
///   ellipsoids.
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/common.dart`
library common;

// codes
export 'src/common/codes/axis_order.dart';
export 'src/common/codes/canvas_origin.dart';
export 'src/common/codes/cardinal_precision.dart';
export 'src/common/codes/coord_ref_sys_type.dart';
export 'src/common/codes/coords.dart';
export 'src/common/codes/dimensionality.dart';
export 'src/common/codes/dms_type.dart';
export 'src/common/codes/geo_representation.dart';
export 'src/common/codes/geom.dart';
export 'src/common/codes/hemisphere.dart';

// constants
export 'src/common/constants/epsilon.dart';
export 'src/common/constants/geodetic.dart';
export 'src/common/constants/screen_ppi.dart';

// conversions
export 'src/common/conversions/angle_unit.dart';
export 'src/common/conversions/angular_velocity_unit.dart';
export 'src/common/conversions/area_unit.dart';
export 'src/common/conversions/length_unit.dart';
export 'src/common/conversions/speed_unit.dart';
export 'src/common/conversions/time_unit.dart';

// functions
export 'src/common/functions/geographic_functions.dart';
export 'src/common/functions/position_functions.dart';

// presentation
export 'src/common/presentation/dms.dart';

// reference
export 'src/common/reference/coord_ref_sys.dart';
export 'src/common/reference/coord_ref_sys_resolver.dart';
export 'src/common/reference/ellipsoid.dart';
export 'src/common/reference/temporal_ref_sys.dart';
export 'src/common/reference/temporal_ref_sys_resolver.dart';
