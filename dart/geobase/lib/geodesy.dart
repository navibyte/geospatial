/// Ellipsoidal (*vincenty*) and spherical (*great circle*, *rhumb line*)
/// geodesy tools, with UTM and MGRS coordinate conversions.
///
/// Geodesy tools by Chris Veness 2002-2024 (MIT Licence) ported to Dart by
/// Navibyte.
///
/// See links for the original work:
/// * https://github.com/chrisveness/geodesy
/// * https://www.movable-type.co.uk/scripts/latlong.html
/// * https://www.movable-type.co.uk/scripts/geodesy-library.html#latlon-spherical
/// * https://www.movable-type.co.uk/scripts/latlong-vincenty.html
/// * https://www.movable-type.co.uk/scripts/latlong-utm-mgrs.html
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/geodesy.dart`
library geodesy;

export 'src/geodesy/base/geodetic_arc_segment.dart';
export 'src/geodesy/ellipsoidal/datum.dart'
    hide convertDatumToDatum, convertDatumToDatumCoords;
export 'src/geodesy/ellipsoidal/ellipsoidal.dart'
    hide geocentricCartesianToGeographic, geographicToGeocentricCartesian;
export 'src/geodesy/ellipsoidal/ellipsoidal_extension.dart';
export 'src/geodesy/ellipsoidal/ellipsoidal_vincenty.dart';
export 'src/geodesy/ellipsoidal/utm.dart' hide convertUtm, convertUtmCoords;
export 'src/geodesy/ellipsoidal/utm_mgrs.dart';
export 'src/geodesy/spherical/spherical_great_circle.dart';
export 'src/geodesy/spherical/spherical_rhumb_line.dart';
