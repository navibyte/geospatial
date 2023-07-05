/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Latitude/longitude spherical geodesy tools                         (c) Chris Veness 2002-2021  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong.html                                                    */
/* www.movable-type.co.uk/scripts/geodesy-library.html#latlon-spherical                           */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// ignore_for_file: lines_longer_than_80_chars

// Dart port of spherical geodesy tools by Chris Veness, see license above.
//
// Library of geodesy functions for operations on a spherical earth model.
//
// Includes distances, bearings, destinations, etc, for both great circle paths
// and rhumb lines, and other related functions.
//
// All calculations are done using simple spherical trigonometric formulae.

import 'dart:math';

import '/src/coordinates/geographic/geographic.dart';

const _toRad = pi / 180.0;

/// A private extension on double values.
extension on double {
  /// Converts a double value in degrees to radians.
  double toRadians() => this * _toRad;
}

/// Latitude/longitude points on a spherical model earth, and methods for
/// calculating distances, bearings, destinations, etc on (orthodromic)
/// great-circle paths and (loxodromic) rhumb lines.
extension SphericalExtension on Geographic {
  /// Returns the distance along the surface of the earth from this position to
  /// [destination].
  ///
  /// An optional [radius] is radius of earth (defaults to mean radius in
  /// metres).
  ///
  /// Returns the distance between this position and destination, in same units
  /// as radius.
  ///
  /// Uses haversine formula:
  /// ```
  /// a = sin²(Δφ/2) + cosφ1·cosφ2 · sin²(Δλ/2)
  /// d = 2 · atan2(√a, √(a-1))
  /// ```
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 52.205, lon: 0.119);
  ///   const p2 = Geographic(lat: 48.857, lon: 2.351);
  ///   final d = p1.distanceTo(p2);       // 404.3×10³ m
  ///   final m = p1.distanceTo(p2, 3959); // 251.2 miles
  /// ```
  double distanceTo(
    Geographic destination, {
    double radius = 6371000.0,
  }) {
    // a = sin²(Δφ/2) + cos(φ1)⋅cos(φ2)⋅sin²(Δλ/2)
    // δ = 2·atan2(√(a), √(1−a))
    // see mathforum.org/library/drmath/view/51879.html for derivation

    final lat1 = lat.toRadians();
    final lon1 = lon.toRadians();
    final lat2 = destination.lat.toRadians();
    final lon2 = destination.lon.toRadians();
    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;

    final a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radius * c;
  }
}
