/// Spherical (*great circle*, *rhumb line*) and ellipsoidal geodesy tools.
///
/// Spherical and ellipsoidal geodesy tools by Chris Veness 2002-2024 (MIT
/// Licence) ported to Dart by Navibyte.
///
/// See links for the original work:
/// * https://github.com/chrisveness/geodesy
/// * www.movable-type.co.uk/scripts/latlong.html
/// * www.movable-type.co.uk/scripts/geodesy-library.html#latlon-spherical
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/geodesy.dart`
library geodesy;

export 'src/geodesy/ellipsoidal/ellipsoidal.dart';
export 'src/geodesy/spherical/spherical_great_circle.dart';
export 'src/geodesy/spherical/spherical_rhumb_line.dart';
