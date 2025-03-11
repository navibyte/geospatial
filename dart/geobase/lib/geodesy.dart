/// Ellipsoidal (*vincenty*) and spherical (*great circle*, *rhumb line*)
/// geodesy tools, with ellipsoidal datum, UTM, MGRS and ECEF support.
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/geodesy.dart`
library geodesy;

export 'src/common/codes/coord_ref_sys_type.dart';
export 'src/common/codes/coords.dart';
export 'src/common/codes/hemisphere.dart';
export 'src/common/constants/geodetic.dart';
export 'src/common/functions/geographic_functions.dart';
export 'src/common/functions/position_functions.dart';
export 'src/common/reference/ellipsoid.dart';
export 'src/geodesy/base/geodetic_arc_segment.dart';
export 'src/geodesy/ellipsoidal/datum.dart'
    hide
        convertDatumToDatum,
        convertDatumToDatumCoords,
        convertGeocentricCartesianInternal,
        convertGeographicInternal;
export 'src/geodesy/ellipsoidal/ellipsoidal.dart'
    hide geocentricCartesianToGeographic, geographicToGeocentricCartesian;
export 'src/geodesy/ellipsoidal/ellipsoidal_extension.dart';
export 'src/geodesy/ellipsoidal/ellipsoidal_vincenty.dart';
export 'src/geodesy/ellipsoidal/utm.dart'
    hide convertUtm, convertUtmCoords, geographicToUtm, utmToGeographic;
export 'src/geodesy/ellipsoidal/utm_mgrs.dart';
export 'src/geodesy/spherical/spherical_great_circle.dart';
export 'src/geodesy/spherical/spherical_rhumb_line.dart';
