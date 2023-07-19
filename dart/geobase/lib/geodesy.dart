/// Spherical geodesy functions for *great circle* and *rhumb line* paths.
///
/// Spherical geodesy tools by Chris Veness 2002-2022 (MIT Licence) ported to
/// Dart by Navibyte.
///
/// See links for the original work:
/// * www.movable-type.co.uk/scripts/latlong.html
/// * www.movable-type.co.uk/scripts/geodesy-library.html#latlon-spherical
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/geodesy.dart`
library geodesy;

export 'src/geodesy/spherical/spherical_great_circle.dart';
export 'src/geodesy/spherical/spherical_rhumb_line.dart';
