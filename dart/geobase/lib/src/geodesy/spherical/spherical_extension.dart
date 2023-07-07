/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Latitude/longitude spherical geodesy tools                         (c) Chris Veness 2002-2022  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong.html                                                    */
/* www.movable-type.co.uk/scripts/geodesy-library.html#latlon-spherical                           */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// ignore_for_file: lines_longer_than_80_chars, prefer_const_declarations

// Dart port of spherical geodesy tools by Chris Veness, see license above.
//
// Source:
// https://github.com/chrisveness/geodesy/blob/master/latlon-spherical.js
//
// Library of geodesy functions for operations on a spherical earth model.
//
// Includes distances, bearings, destinations, etc, for both great circle paths
// and rhumb lines, and other related functions.
//
// All calculations are done using simple spherical trigonometric formulae.

import 'dart:math';

import '/src/coordinates/geographic/geographic.dart';
import '/src/coordinates/geographic/geographic_functions.dart';

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
  /// The distance between this position and the destination is measured in same
  /// units as the given radius.
  ///
  /// Uses the *haversine* formula:
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
    if (this == destination) return 0.0;

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

  /// Returns the initial bearing from this position to [destination].
  ///
  /// The initial bearing is measured in degrees from north (0°..360°).
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 52.205, lon: 0.119);
  ///   const p2 = Geographic(lat: 48.857, lon: 2.351);
  ///   final b1 = p1.initialBearingTo(p2); // 156.2°
  /// ```
  double initialBearingTo(Geographic destination) {
    if (this == destination) return 0.0;

    // tanθ = sinΔλ⋅cosφ2 / cosφ1⋅sinφ2 − sinφ1⋅cosφ2⋅cosΔλ
    // see mathforum.org/library/drmath/view/55417.html for derivation

    final lat1 = lat.toRadians();
    final lat2 = destination.lat.toRadians();
    final dlon = (destination.lon - lon).toRadians();

    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dlon);
    final y = sin(dlon) * cos(lat2);
    final brng = atan2(y, x);

    return brng.toDegrees().wrap360();
  }

  /// Returns the final bearing arriving at [destination] from this position.
  ///
  /// The final bearing differs from the initial bearing by varying degrees
  /// according to distance and latitude.
  ///
  /// The initial bearing is measured in degrees from north (0°..360°).
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 52.205, lon: 0.119);
  ///   const p2 = Geographic(lat: 48.857, lon: 2.351);
  ///   final b2 = p1.finaBearingTo(p2); // 157.9°
  /// ```
  double finalBearingTo(Geographic destination) {
    if (this == destination) return 0.0;

    // get initial bearing from destination to this & reverse it by adding 180°
    final bearing = destination.initialBearingTo(this) + 180.0;
    return bearing.wrap360();
  }

  /// Returns the midpoint between this position and [destination].
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 52.205, lon: 0.119);
  ///   const p2 = Geographic(lat: 48.857, lon: 2.351);
  ///   final pMid = p1.midPointTo(p2); // lat: 50.5363°N, lon: 001.2746°E
  /// ```
  Geographic midPointTo(Geographic destination) {
    if (this == destination) return this;

    // φm = atan2( sinφ1 + sinφ2,
    //             √( (cosφ1 + cosφ2⋅cosΔλ)² + cos²φ2⋅sin²Δλ ) )
    // λm = λ1 + atan2(cosφ2⋅sinΔλ, cosφ1 + cosφ2⋅cosΔλ)
    //
    // midpoint is sum of vectors to two points:
    // mathforum.org/library/drmath/view/51822.html

    final lat1 = lat.toRadians();
    final lon1 = lon.toRadians();
    final lat2 = destination.lat.toRadians();
    final dlon = (destination.lon - lon).toRadians();

    // get cartesian coordinates for the two points
    // (place point A on prime meridian y=0)
    final ax = cos(lat1);
    final ay = 0.0;
    final az = sin(lat1);
    final bx = cos(lat2) * cos(dlon);
    final by = cos(lat2) * sin(dlon);
    final bz = sin(lat2);

    // vector to midpoint is sum of vectors to two points (no need to normalise)
    final cx = ax + bx;
    final cy = ay + by;
    final cz = az + bz;

    // midpoint
    final latm = atan2(cz, sqrt(cx * cx + cy * cy));
    final lonm = lon1 + atan2(cy, cx);

    return Geographic(lat: latm.toDegrees(), lon: lonm.toDegrees());
  }

  /// Returns the itermediate point at the given fraction between this position
  /// and [destination].
  ///
  /// [fraction]: 0.0 = this position, 1.0 = destination
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 52.205, lon: 0.119);
  ///   const p2 = Geographic(lat: 48.857, lon: 2.351);
  ///   final pInt = p1.intermediatePointTo(p2, 0.25); // 51.3721°N, 000.7073°E
  /// ```
  Geographic intermediatePointTo(
    Geographic destination, {
    required double fraction,
  }) {
    if (this == destination) return this;

    final lat1 = lat.toRadians();
    final lon1 = lon.toRadians();
    final lat2 = destination.lat.toRadians();
    final lon2 = destination.lon.toRadians();

    // distance between points
    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;
    final a = sin(dlat / 2.0) * sin(dlat / 2.0) +
        cos(lat1) * cos(lat2) * sin(dlon / 2.0) * sin(dlon / 2.0);
    final delta = 2 * atan2(sqrt(a), sqrt(1.0 - a));

    final A = sin((1.0 - fraction) * delta) / sin(delta);
    final B = sin(fraction * delta) / sin(delta);

    final x = A * cos(lat1) * cos(lon1) + B * cos(lat2) * cos(lon2);
    final y = A * cos(lat1) * sin(lon1) + B * cos(lat2) * sin(lon2);
    final z = A * sin(lat1) + B * sin(lat2);

    final lat3 = atan2(z, sqrt(x * x + y * y));
    final lon3 = atan2(y, x);

    return Geographic(lat: lat3.toDegrees(), lon: lon3.toDegrees());
  }
}
