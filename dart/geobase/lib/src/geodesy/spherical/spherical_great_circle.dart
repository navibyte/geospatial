/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Latitude/longitude spherical geodesy tools                         (c) Chris Veness 2002-2022  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong.html                                                    */
/* www.movable-type.co.uk/scripts/geodesy-library.html#latlon-spherical                           */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// ignore_for_file: lines_longer_than_80_chars, prefer_const_declarations

// Spherical geodesy tools (see license above) by Chris Veness ported to Dart
// by Navibyte.
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

// Adaptations on the derivative work (the Dart port):
//
// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math';

import 'package:meta/meta.dart';

import '/src/constants/epsilon.dart';
import '/src/coordinates/geographic/geographic.dart';
import '/src/coordinates/geographic/geographic_functions.dart';
import '/src/geodesy/base/geodetic.dart';

/// An extension for easier access to [SphericalGreatCircle].
extension SphericalGreatCircleExtension on Geographic {
  /// Create an object calculating distances, bearings, destinations, etc on
  /// (orthodromic) great-circle paths with this position as the current
  /// position.
  SphericalGreatCircle get spherical => SphericalGreatCircle(this);
}

/// An extension for easier access to [SphericalGreatCircleLineString].
extension SphericalGreatCircleIterableExtension on Iterable<Geographic> {
  /// Create an object providing calculations for line strings (as an iterable
  /// of geographic positions) on a spherical model earth (great-circle paths).
  SphericalGreatCircleLineString get spherical =>
      SphericalGreatCircleLineString(this);
}

/// Latitude/longitude points on a spherical model earth, and methods for
/// calculating distances, bearings, destinations, etc on (orthodromic)
/// great-circle paths.
@immutable
class SphericalGreatCircle extends Geodetic {
  /// Create an object calculating distances, bearings, destinations, etc on
  /// (orthodromic) great-circle paths with [position] as the current position.
  const SphericalGreatCircle(super.position);

  /// Returns the distance along the surface of the earth from the current
  /// [position] to [destination].
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
  ///   final d = p1.spherical.distanceTo(p2);       // 404.3×10³ m
  ///   final m = p1.spherical.distanceTo(p2, 3959); // 251.2 miles
  /// ```
  @override
  double distanceTo(
    Geographic destination, {
    double radius = 6371000.0,
  }) {
    if (position == destination) return 0.0;

    // a = sin²(Δφ/2) + cos(φ1)⋅cos(φ2)⋅sin²(Δλ/2)
    // δ = 2·atan2(√(a), √(1−a))
    // see mathforum.org/library/drmath/view/51879.html for derivation

    final lat1 = position.lat.toRadians();
    final lon1 = position.lon.toRadians();
    final lat2 = destination.lat.toRadians();
    final lon2 = destination.lon.toRadians();
    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;

    final a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radius * c;
  }

  /// Returns the initial bearing from the current [position] to [destination].
  ///
  /// The initial bearing is measured in degrees from north (0°..360°).
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 52.205, lon: 0.119);
  ///   const p2 = Geographic(lat: 48.857, lon: 2.351);
  ///   final b1 = p1.spherical.initialBearingTo(p2); // 156.2°
  /// ```
  @override
  double initialBearingTo(Geographic destination) {
    if (position == destination) return double.nan;

    // tanθ = sinΔλ⋅cosφ2 / cosφ1⋅sinφ2 − sinφ1⋅cosφ2⋅cosΔλ
    // see mathforum.org/library/drmath/view/55417.html for derivation

    final lat1 = position.lat.toRadians();
    final lat2 = destination.lat.toRadians();
    final dlon = (destination.lon - position.lon).toRadians();

    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dlon);
    final y = sin(dlon) * cos(lat2);
    final brng = atan2(y, x);

    return brng.toDegrees().wrap360();
  }

  /// Returns the final bearing arriving at [destination] from the current
  /// [position].
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
  ///   final b2 = p1.spherical.finaBearingTo(p2); // 157.9°
  /// ```
  @override
  double finalBearingTo(Geographic destination) {
    if (position == destination) return double.nan;

    // get initial bearing from destination to this & reverse it by adding 180°
    final bearing = destination.spherical.initialBearingTo(position) + 180.0;
    return bearing.wrap360();
  }

  /// Returns the midpoint between the current [position] and [destination].
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 52.205, lon: 0.119);
  ///   const p2 = Geographic(lat: 48.857, lon: 2.351);
  ///
  ///   // midpoint (lat: 50.5363°N, lon: 001.2746°E)
  ///   final pMid = p1.spherical.midPointTo(p2);
  /// ```
  @override
  Geographic midPointTo(Geographic destination) {
    if (position == destination) return position;

    // φm = atan2( sinφ1 + sinφ2,
    //             √( (cosφ1 + cosφ2⋅cosΔλ)² + cos²φ2⋅sin²Δλ ) )
    // λm = λ1 + atan2(cosφ2⋅sinΔλ, cosφ1 + cosφ2⋅cosΔλ)
    //
    // midpoint is sum of vectors to two points:
    // mathforum.org/library/drmath/view/51822.html

    final lat1 = position.lat.toRadians();
    final lon1 = position.lon.toRadians();
    final lat2 = destination.lat.toRadians();
    final dlon = (destination.lon - position.lon).toRadians();

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

  /// Returns the itermediate point at the given fraction between the current
  /// [position] and [destination].
  ///
  /// Parameters:
  /// * [fraction]: 0.0 = this position, 1.0 = destination
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 52.205, lon: 0.119);
  ///   const p2 = Geographic(lat: 48.857, lon: 2.351);
  ///
  ///   // intermediate point (lat: 51.3721°N, lon: 000.7073°E)
  ///   final pInt = p1.spherical.intermediatePointTo(p2, 0.25);
  /// ```
  Geographic intermediatePointTo(
    Geographic destination, {
    required double fraction,
  }) {
    if (position == destination) return position;

    final lat1 = position.lat.toRadians();
    final lon1 = position.lon.toRadians();
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

  /// Returns the destination point from the current [position] having travelled
  /// the given [distance] on the given initial [bearing] (bearing normally
  /// varies around path followed).
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
  ///   final p2 = p1.spherical.
  ///        destinationPoint(distance: 7794.0, bearing: 300.7);
  /// ```
  @override
  Geographic destinationPoint({
    required double distance,
    required double bearing,
    double radius = 6371000.0,
  }) {
    if (distance == 0.0) return position;

    // sinφ2 = sinφ1⋅cosδ + cosφ1⋅sinδ⋅cosθ
    // tanΔλ = sinθ⋅sinδ⋅cosφ1 / cosδ−sinφ1⋅sinφ2
    // see mathforum.org/library/drmath/view/52049.html for derivation

    final lat1 = position.lat.toRadians();
    final lon1 = position.lon.toRadians();

    // angular distance in radians
    final dst = distance / radius;

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
  /// * the current [position] and the [bearing] parameter
  /// * [other] position and [otherBearing] both as parameters
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
  ///   final pInt = p1.spherical.intersectionWith(bearing: brng1, other: p2,
  ///       otherBearing: brng2);
  /// ```
  Geographic? intersectionWith({
    required double bearing,
    required Geographic other,
    required double otherBearing,
  }) {
    if (position == other) return position;

    // see www.edwilliams.org/avform.htm#Intersection

    final lat1 = position.lat.toRadians();
    final lon1 = position.lon.toRadians();
    final lat2 = other.lat.toRadians();
    final lon2 = other.lon.toRadians();
    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;

    final brng13 = bearing.toRadians();
    final brng23 = otherBearing.toRadians();

    // angular distance p1-p2
    final dst12 = 2.0 *
        asin(
          sqrt(
            sin(dlat / 2.0) * sin(dlat / 2.0) +
                cos(lat1) * cos(lat2) * sin(dlon / 2.0) * sin(dlon / 2.0),
          ),
        );

    // check for coincident points
    if (dst12.abs() < doublePrecisionEpsilon) return position;

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

  /*
NOTE: original source code for intersection:

static intersection(p1, brng1, p2, brng2) {
        if (!(p1 instanceof LatLonSpherical)) p1 = LatLonSpherical.parse(p1); // allow literal forms
        if (!(p2 instanceof LatLonSpherical)) p2 = LatLonSpherical.parse(p2); // allow literal forms
        if (isNaN(brng1)) throw new TypeError(`invalid brng1 ‘${brng1}’`);
        if (isNaN(brng2)) throw new TypeError(`invalid brng2 ‘${brng2}’`);

        // see www.edwilliams.org/avform.htm#Intersection

        const φ1 = p1.lat.toRadians(), λ1 = p1.lon.toRadians();
        const φ2 = p2.lat.toRadians(), λ2 = p2.lon.toRadians();
        const θ13 = Number(brng1).toRadians(), θ23 = Number(brng2).toRadians();
        const Δφ = φ2 - φ1, Δλ = λ2 - λ1;

        // angular distance p1-p2
        const δ12 = 2 * Math.asin(Math.sqrt(Math.sin(Δφ/2) * Math.sin(Δφ/2)
            + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ/2) * Math.sin(Δλ/2)));
        if (Math.abs(δ12) < Number.EPSILON) return new LatLonSpherical(p1.lat, p1.lon); // coincident points

        // initial/final bearings between points
        const cosθa = (Math.sin(φ2) - Math.sin(φ1)*Math.cos(δ12)) / (Math.sin(δ12)*Math.cos(φ1));
        const cosθb = (Math.sin(φ1) - Math.sin(φ2)*Math.cos(δ12)) / (Math.sin(δ12)*Math.cos(φ2));
        const θa = Math.acos(Math.min(Math.max(cosθa, -1), 1)); // protect against rounding errors
        const θb = Math.acos(Math.min(Math.max(cosθb, -1), 1)); // protect against rounding errors

        const θ12 = Math.sin(λ2-λ1)>0 ? θa : 2*π-θa;
        const θ21 = Math.sin(λ2-λ1)>0 ? 2*π-θb : θb;

        const α1 = θ13 - θ12; // angle 2-1-3
        const α2 = θ21 - θ23; // angle 1-2-3

        if (Math.sin(α1) == 0 && Math.sin(α2) == 0) return null; // infinite intersections
        if (Math.sin(α1) * Math.sin(α2) < 0) return null;        // ambiguous intersection (antipodal/360°)

        const cosα3 = -Math.cos(α1)*Math.cos(α2) + Math.sin(α1)*Math.sin(α2)*Math.cos(δ12);

        const δ13 = Math.atan2(Math.sin(δ12)*Math.sin(α1)*Math.sin(α2), Math.cos(α2) + Math.cos(α1)*cosα3);

        const φ3 = Math.asin(Math.min(Math.max(Math.sin(φ1)*Math.cos(δ13) + Math.cos(φ1)*Math.sin(δ13)*Math.cos(θ13), -1), 1));

        const Δλ13 = Math.atan2(Math.sin(θ13)*Math.sin(δ13)*Math.cos(φ1), Math.cos(δ13) - Math.sin(φ1)*Math.sin(φ3));
        const λ3 = λ1 + Δλ13;

        const lat = φ3.toDegrees();
        const lon = λ3.toDegrees();

        return new LatLonSpherical(lat, lon);
    }
  */

  /// Returns (signed) distance from the current [position] to great circle
  /// defined by [start] and [end] points.
  ///
  /// Parameters:
  /// * [start]: The start point on a great circle path.
  /// * [end]: The end point on a great circle path.
  /// * [radius]: The radius of earth (defaults to mean radius in metres).
  ///
  /// The returned value is a distance to a great circle (-ve if to left, +ve
  /// if to right of path).
  ///
  /// Examples:
  /// ```dart
  ///   const pCurrent = Geographic(lat: 53.2611, lon: -0.7972);
  ///   const p1 =  Geographic(lat: 53.3206, lon: -1.7297);
  ///   const p2 =  Geographic(lat: 53.1887, lon: 0.1334);
  ///
  ///   // cross track distance: -307.5 m
  ///   final d = pCurrent.spherical.crossTrackDistanceTo(start: p1, end: p2);
  /// ```
  double crossTrackDistanceTo({
    required Geographic start,
    required Geographic end,
    double radius = 6371000.0,
  }) {
    if (position == start) return 0;

    final spherical = start.spherical;
    final dst13 = spherical.distanceTo(position, radius: radius) / radius;
    final brng13 = spherical.initialBearingTo(position).toRadians();
    final brng12 = spherical.initialBearingTo(end).toRadians();

    final dstxt = asin(sin(dst13) * sin(brng13 - brng12));

    return dstxt * radius;
  }

  /// Returns how far the current [position] is along a path from the [start]
  /// point, heading towards the [end] point.
  ///
  /// That is, if a perpendicular is drawn from the current position to the
  /// (great circle) path, the along-track distance is the distance from the
  /// start point to where the perpendicular crosses the path.
  ///
  /// Parameters:
  /// * [start]: The start point on a great circle path.
  /// * [end]: The end point on a great circle path.
  /// * [radius]: The radius of earth (defaults to mean radius in metres).
  ///
  /// The returned value a distance along great circle to point nearest this
  /// position.
  ///
  /// Examples:
  /// ```dart
  ///   const pCurrent = Geographic(lat: 53.2611, lon: -0.7972);
  ///   const p1 =  Geographic(lat: 53.3206, lon: -1.7297);
  ///   const p2 =  Geographic(lat: 53.1887, lon: 0.1334);
  ///
  ///   // along track distance: 62.331km
  ///   final d = pCurrent.spherical.alongTrackDistanceTo(start: p1, end: p2);
  /// ```
  double alongTrackDistanceTo({
    required Geographic start,
    required Geographic end,
    double radius = 6371000.0,
  }) {
    if (position == start) return 0;

    final spherical = start.spherical;
    final dst13 = spherical.distanceTo(position, radius: radius) / radius;
    final brng13 = spherical.initialBearingTo(position).toRadians();
    final brng12 = spherical.initialBearingTo(end).toRadians();

    final dstxt = asin(sin(dst13) * sin(brng13 - brng12));

    final dstat = acos(cos(dst13) / (cos(dstxt).abs()));
    final sign = cos(brng12 - brng13).sign;
    return dstat * sign * radius;
  }

  /// Returns the maximum latitude reached when travelling on a great circle on
  /// the given [bearing] from the current [position].
  ///
  /// Based on the *Clairaut’s formula*. Negate the result for the minimum
  /// latitude (in the southern hemisphere). The maximum latitude is independent
  /// of longitude; it will be the same for all points on a given latitude.
  ///
  /// Parameters:
  /// * [bearing]: The initial bearing.
  double maxLatitude({
    required double bearing,
  }) {
    final brng = bearing.toRadians();
    final lat1 = position.lat.toRadians();

    final latMax = acos((sin(brng) * cos(lat1)).abs());
    return latMax.toDegrees();
  }

  /// Returns the pair of meridians at which a great circle defined by two
  /// points (the current [position] and [other] position) crosses the given
  /// [latitude].
  ///
  /// If the great circle doesn't reach the given latitude, null is returned.
  ///
  /// Parameters:
  /// * [latitude]: The latitude crossings are to be determined for.
  List<double>? crossingParallels({
    required Geographic other,
    required double latitude,
  }) {
    // NOTE: return value could be changed to record notation on Dart 3

    // coincident points
    if (position == other) return null;

    final lat = latitude.toRadians();

    final lat1 = position.lat.toRadians();
    final lon1 = position.lon.toRadians();
    final lat2 = other.lat.toRadians();
    final lon2 = other.lon.toRadians();
    final dlon = lon2 - lon1;

    final x = sin(lat1) * cos(lat2) * cos(lat) * sin(dlon);
    final y = sin(lat1) * cos(lat2) * cos(lat) * cos(dlon) -
        cos(lat1) * sin(lat2) * cos(lat);
    final z = cos(lat1) * cos(lat2) * sin(lat) * sin(dlon);

    if (z * z > x * x + y * y) {
      // great circle doesn't reach latitude
      return null;
    }

    // longitude at max latitude
    final lonm = atan2(-y, x);

    // Δλ from λm to intersection points
    final dloni = acos(z / sqrt(x * x + y * y));

    final loni1 = lon1 + lonm - dloni;
    final loni2 = lon1 + lonm + dloni;

    return [
      loni1.toDegrees().wrapLongitude(),
      loni2.toDegrees().wrapLongitude(),
    ];
  }
}

/// Calculations for line strings (as an iterable of geographic positions) on a
/// spherical model earth (great-circle paths).
@immutable
class SphericalGreatCircleLineString {
  /// The current line string with geographic positions for calculations.
  final Iterable<Geographic> lineString;

  /// Creates and object with calculations for line strings (as an iterable of
  /// geographic positions) on a spherical model earth (great-circle paths).
  const SphericalGreatCircleLineString(this.lineString);

  /// Calculates the area of a spherical polygon where the sides of the polygon
  /// are great circle arcs joining the vertices.
  ///
  /// The current line string is considered as a polygon that must contain at
  /// least 4 points and it should be a closed linear ring (first and last
  /// points must equal).
  ///
  /// Parameters:
  /// * [radius]: The radius of earth (defaults to mean radius in metres).
  ///
  /// Example:
  /// ```dart
  ///   // a polygon as a closed linear ring (`Iterable<Geographic>`)
  ///   const polygon = [
  ///     Geographic(lat: 0.0, lon: 0.0),
  ///     Geographic(lat: 1.0, lon: 0.0),
  ///     Geographic(lat: 0.0, lon: 1.0),
  ///     Geographic(lat: 0.0, lon: 0.0),
  ///   ];
  ///   final area = polygon.spherical.polygonArea(); // 6.18e9 m²
  /// ```
  double polygonArea({double radius = 6371000.0}) {
    // uses method due to Karney:
    //  osgeo-org.1560.x6.nabble.com/Area-of-a-spherical-polygon-td3841625.html
    //
    // for each edge of the polygon:
    //  tan(E/2) = tan(Δλ/2)·(tan(φ₁/2)+tan(φ₂/2)) / (1+tan(φ₁/2)·tan(φ₂/2))
    //
    // Where E is the spherical excess of the trapezium obtained by extending
    // the edge to the equator (Karney's method is probably more efficient than
    // the more widely known L’Huilier’s Theorem).

    // consider the current line string as a polygon (a closed linear ring)
    final polygon = lineString;
    if (polygon.length < 4) {
      throw const FormatException('Polygon must contain at least 4 points.');
    }
    final first = polygon.first;
    final last = polygon.last;
    if (first != last) {
      throw const FormatException('Polygon must be a closed linear ring.');
    }

    // spherical excess in steradians
    var S = 0.0;

    var isFirst = true;
    late Geographic p1;
    for (final p2 in polygon) {
      if (isFirst) {
        p1 = p2;
        isFirst = false;
      } else {
        final lat1 = p1.lat.toRadians();
        final lat2 = p2.lat.toRadians();
        final dlon = (p2.lon - p1.lon).toRadians();
        final E = 2.0 *
            atan2(
              tan(dlon / 2.0) * (tan(lat1 / 2.0) + tan(lat2 / 2.0)),
              1.0 + tan(lat1 / 2.0) * tan(lat2 / 2.0),
            );
        S += E;

        p1 = p2;
      }
    }

    if (_isPoleEnclosedBy(polygon)) {
      S = S.abs() - 2.0 * pi;
    }

    return (S * radius * radius).abs(); // area in units of radius
  }

  // Returns whether a polygon encloses pole (sum of course deltas around pole
  // is 0° rather than normal ±360°).
  //
  // See:
  // blog.element84.com/determining-if-a-spherical-polygon-contains-a-pole.html
  static bool _isPoleEnclosedBy(
    Iterable<Geographic> polygon,
  ) {
    // NOTE: any better test than this?

    var sumDelta = 0.0;
    final first = polygon.elementAt(0);
    final firstSpherical = first.spherical;
    final second = polygon.elementAt(1);
    var prevBrng = firstSpherical.initialBearingTo(second);

    var isFirst = true;
    late SphericalGreatCircle p1Spherical;
    for (final p2 in polygon) {
      if (isFirst) {
        p1Spherical = p2.spherical;
        isFirst = false;
      } else {
        final initialBrng = p1Spherical.initialBearingTo(p2);
        final finalBrng = p1Spherical.finalBearingTo(p2);
        sumDelta += (initialBrng - prevBrng + 540.0) % 360.0 - 180.0;
        sumDelta += (finalBrng - initialBrng + 540.0) % 360.0 - 180.0;
        prevBrng = finalBrng;
        p1Spherical = p2.spherical;
      }
    }

    final initialBrng = firstSpherical.initialBearingTo(second);
    sumDelta += (initialBrng - prevBrng + 540) % 360 - 180;

    // NOTE: fix (intermittant) edge crossing pole - eg (85,90), (85,0), (85,-90)

    final enclosed = sumDelta.abs() < 90.0; // 0°-ish
    return enclosed;
  }
}
