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
  /// Parameters:
  /// * [radius]: The radius of earth (defaults to mean radius in metres).
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
  /// Parameters:
  /// * [fraction]: 0.0 = this position, 1.0 = destination
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

  /// Returns the destination point from this position having travelled the
  /// given [distance] on the given initial [bearing] (bearing normally varies
  /// around path followed).
  ///
  /// Parameters:
  /// * [distance]: Distance travelled (same units as radius, default: metres).
  /// * [bearing]: Initial bearing in degrees from north (0°..360°).
  /// * [radius]: The radius of earth (defaults to mean radius in metres).
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 51.47788, lon: -0.00147);
  ///
  ///   // destination point (lat: 51.5136°N, lon: 000.0983°W)
  ///   final p2 = p1.destinationPoint(distance: 7794.0, bearing: 300.7);
  /// ```
  Geographic destinationPoint({
    required double distance,
    required double bearing,
    double radius = 6371000.0,
  }) {
    // sinφ2 = sinφ1⋅cosδ + cosφ1⋅sinδ⋅cosθ
    // tanΔλ = sinθ⋅sinδ⋅cosφ1 / cosδ−sinφ1⋅sinφ2
    // see mathforum.org/library/drmath/view/52049.html for derivation

    final lat1 = lat.toRadians();
    final lon1 = lon.toRadians();

    final dst = distance / radius; // angular distance in radians
    final brng = bearing.toRadians();

    final sinLat2 = sin(lat1) * cos(dst) + cos(lat1) * sin(dst) * cos(brng);
    final lat2 = asin(sinLat2);
    final y = sin(brng) * sin(dst) * cos(lat1);
    final x = cos(dst) - sin(lat1) * sinLat2;
    final lon2 = lon1 + atan2(y, x);

    return Geographic(lat: lat2.toDegrees(), lon: lon2.toDegrees());
  }

  /// Returns the point of intersection of two paths both defined by a position
  /// and a bearing.
  ///
  /// The two paths are defined by:
  /// * this position and [bearing]
  /// * [other] position and [otherBearing]
  ///
  /// Both bearings are measured in degrees from north (0°..360°).
  ///
  /// The destination point is returned as a geographic position (or `null` if
  /// no unique intersection can be calculated).
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 51.8853, lon: 0.2545);
  ///   const brng1 = 108.547;
  ///   const p2 = Geographic(lat: 49.0034, lon: 2.5735);
  ///   const brng2 = 32.435;
  ///
  ///   // intersection point (lat: 50.9078°N, lon: 004.5084°E)
  ///   final pInt =
  ///       p1.intersectionWith(bearing: brng1, other: p2, otherBearing: brng2);
  /// ```
  Geographic? intersectionWith({
    required double bearing,
    required Geographic other,
    required double otherBearing,
  }) {
    if (this == other) return this;

    // see www.edwilliams.org/avform.htm#Intersection

    final lat1 = lat.toRadians();
    final lon1 = lon.toRadians();
    final lat2 = other.lat.toRadians();
    final lon2 = other.lon.toRadians();
    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;

    final brng13 = bearing.toRadians();
    final brng23 = otherBearing.toRadians();

    // angular distance p1-p2
    final dst12 = 2 *
        asin(
          sqrt(
            sin(dlat / 2.0) * sin(dlat / 2.0) +
                cos(lat1) * cos(lat2) * sin(dlon / 2.0) * sin(dlon / 2.0),
          ),
        );

    // NOTE: what is correct epsilon?
    //       (original JS code had Number.EPSILON == 2.220446049250313E-16)
    const epsilon = 2.220446049250313E-16; // or ?? 4.94065645841247E-324;
    if (dst12.abs() < epsilon) return this; // coincident points

    // initial/final bearings between points
    final cosBrngA =
        (sin(lat2) - sin(lat1) * cos(dst12)) / (sin(dst12) * cos(lat1));
    final cosBrngB =
        (sin(lat1) - sin(lat2) * cos(dst12)) / (sin(dst12) * cos(lat2));
    final brngA =
        acos(cosBrngA.clamp(-1.0, 1.0)); // protect against rounding errors
    final brngB =
        acos(cosBrngB.clamp(-1.0, 1.0)); // protect against rounding errors

    final brng12 = sin(lon2 - lon1) > 0 ? brngA : 2.0 * pi - brngA;
    final brng21 = sin(lon2 - lon1) > 0 ? 2.0 * pi - brngB : brngB;

    final ang1 = brng13 - brng12; // angle 2-1-3
    final ang2 = brng21 - brng23; // angle 1-2-3

    // check for infinite intersections
    if (sin(ang1) == 0 && sin(ang2) == 0) return null;
    // check for ambiguous intersection (antipodal/360°)
    if (sin(ang1) * sin(ang2) < 0) return null;

    final cosAng3 = -cos(ang1) * cos(ang2) + sin(ang1) * sin(ang2) * cos(dst12);

    final dst13 = atan2(
      sin(dst12) * sin(ang1) * sin(ang2),
      cos(ang2) + cos(ang1) * cosAng3,
    );

    final lat3 = asin(
      (sin(lat1) * cos(dst13) + cos(lat1) * sin(dst13) * cos(brng13))
          .clamp(-1.0, 1.0),
    );

    final dlon13 = atan2(
      sin(brng13) * sin(dst13) * cos(lat1),
      cos(dst13) - sin(lat1) * sin(lat3),
    );
    final lon3 = lon1 + dlon13;

    return Geographic(lat: lat3.toDegrees(), lon: lon3.toDegrees());
  }
}
