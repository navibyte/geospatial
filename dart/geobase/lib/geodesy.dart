// ignore_for_file: lines_longer_than_80_chars

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Latitude/longitude spherical geodesy tools                         (c) Chris Veness 2002-2022  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong.html                                                    */
/* www.movable-type.co.uk/scripts/geodesy-library.html#latlon-spherical                           */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

/// Latitude/longitude spherical geodesy tools.
///
/// A Dart port for JavaScript tools originally created by Chris Veness
/// 2002-2021 (MIT Licence).
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
