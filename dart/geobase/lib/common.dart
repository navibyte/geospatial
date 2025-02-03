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
/// * Functions: conversions between units, geographic coordinate helpers.
/// * Presentation: DMS (degree-minutes-seconds geographic representations).
/// * Reference: Coordinate and temporal reference systems. Reference
///   ellipsoids.
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/common.dart`
///
/// Examples on unit conversions:
///
/// ```dart
///   // Length units (mm, cm, m, km, in, ft, yd, mi, nmi), with some examples:
///   const meters = 1500.0;
///   meters.convertLength(to: LengthUnit.foot); // ~ 4921.26 ft
///   meters.convertLength(to: LengthUnit.kilometer); // 1.5 km
///   meters.convertLength(to: LengthUnit.nauticalMile); // 0.8099 nmi
///   254.convertLength(from: LengthUnit.millimeter, to: LengthUnit.inch); // 10.0
///
///   // Area units (mm², cm², m², km², in², ft², yd², mi², ac, ha), with examples:
///   const squareMeters = 10000.0;
///   squareMeters.convertArea(to: AreaUnit.squareKilometer); // 0.01 km²
///   squareMeters.convertArea(to: AreaUnit.acre); // ~ 2.4711 acres
///   1.0.convertArea(
///     from: AreaUnit.hectare,
///     to: AreaUnit.squareFoot,
///   ); // 107639.1042 ft²
///
///   // Speed units (mm/s, cm/s, m/s, km/h, mph, ft/s, kn), with some examples:
///   const metersPerSecond = 10.0;
///   metersPerSecond.convertSpeed(to: SpeedUnit.kilometerPerHour); // 36.0 km/h
///   metersPerSecond.convertSpeed(to: SpeedUnit.milePerHour); // 22.3694 mph
///   10.0.convertSpeed(
///     from: SpeedUnit.kilometerPerHour,
///     to: SpeedUnit.knot,
///   ); // ~ 5.3996 kn
///
///   // Angle units (mrad, rad, arcsec, arcmin, deg, gon, turn), with examples:
///   const degrees = 90.0;
///   degrees.convertAngle(from: AngleUnit.degree); // ~1.5708 rad
///   degrees.convertAngle(from: AngleUnit.degree, to: AngleUnit.gradian); // 100.0
///
///   // Angular velocity units (mrad/s, rad/s, deg/s, rpm, rps), with examples:
///   const radiansPerSecond = 1.0;
///   radiansPerSecond.convertAngularVelocity(
///     to: AngularVelocityUnit.degreePerSecond,
///   ); // ~ 57.296 deg/s
///   720.0.convertAngularVelocity(
///     from: AngularVelocityUnit.degreePerSecond,
///     to: AngularVelocityUnit.revolutionPerSecond,
///   ); // 2.0 rps
///
///   // Time units (ns, µs, ms, s, min, h, d, w), with some examples:
///   const seconds = 3600.0;
///   seconds.convertTime(to: TimeUnit.hour); // 1.0 h
///   seconds.convertTime(to: TimeUnit.day); // 0.0417 d
///   1.0.convertTime(from: TimeUnit.week, to: TimeUnit.day); // 7.0 d
/// ```
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
export 'src/common/functions/unit_conversion_extension.dart';

// presentation
export 'src/common/presentation/dms.dart';

// reference
export 'src/common/reference/coord_ref_sys.dart';
export 'src/common/reference/coord_ref_sys_resolver.dart';
export 'src/common/reference/ellipsoid.dart';
export 'src/common/reference/temporal_ref_sys.dart';
export 'src/common/reference/temporal_ref_sys_resolver.dart';
