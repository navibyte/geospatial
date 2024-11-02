/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Vincenty Direct and Inverse Solution of Geodesics on the Ellipsoid (c) Chris Veness 2002-2022  */
/*                                                                                   MIT Licence  */
/* www.ngs.noaa.gov/PUBS_LIB/inverse.pdf                                                          */
/* www.movable-type.co.uk/scripts/latlong-vincenty.html                                           */
/* www.movable-type.co.uk/scripts/geodesy-library.html#latlon-ellipsoidal-vincenty                */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// ignore_for_file: lines_longer_than_80_chars, prefer_const_declarations

// Vincenty Direct and Inverse Solution of Geodesics on the Ellipsoid (see
// license above) by Chris Veness ported to Dart by Navibyte.
//
// Source:
// https://github.com/chrisveness/geodesy/blob/master/latlon-ellipsoidal-vincenty.js

// Adaptations on the derivative work (the Dart port):
//
// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math';

import 'package:meta/meta.dart';

import '/src/common/constants/epsilon.dart';
import '/src/common/functions/position_functions.dart';
import '/src/common/reference/ellipsoid.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/geographic/geographic.dart';
import '/src/geodesy/base/geodetic.dart';

import 'ellipsoidal.dart';

/// An extension for easier access to [EllipsoidalVincenty].
extension EllipsoidalVincentyExtension on Geographic {
  /// {@template geobase.geodesy.ellipsoidal.create}
  ///
  /// Create an object calculating distances, bearings, destinations, etc on
  /// the ellipsoidal earth model devised by Thaddeus Vincenty.
  ///
  /// Calculations are accurate to within 0.5mm in distances and 0.000015″ in
  /// bearings.
  ///
  /// {@endtemplate}
  ///
  /// This position is used as the current position.
  ///
  /// {@macro geobase.geodesy.ellipsoidal.parameters}
  EllipsoidalVincenty vincenty({Ellipsoid ellipsoid = Ellipsoid.WGS84}) =>
      EllipsoidalVincenty(this, ellipsoid: ellipsoid);
}

/// Distances & bearings between points, and destination points given start
/// points & initial bearings, calculated on an ellipsoidal earth model using
/// ‘direct and inverse solutions of geodesics on the ellipsoid’ devised by
/// Thaddeus Vincenty.
///
/// Calculations are accurate to within 0.5mm in distances and 0.000015″ in
/// bearings.
///
/// From: T Vincenty, "Direct and Inverse Solutions of Geodesics on the
/// Ellipsoid with application of nested equations", Survey Review, vol XXIII
/// no 176, 1975. www.ngs.noaa.gov/PUBS_LIB/inverse.pdf.
@immutable
class EllipsoidalVincenty extends Ellipsoidal implements Geodetic {
  /// {@macro geobase.geodesy.ellipsoidal.create}
  ///
  /// The given [position] is used as the current position.
  ///
  /// {@macro geobase.geodesy.ellipsoidal.parameters}
  const EllipsoidalVincenty(super.position, {super.ellipsoid});

  /// {@macro geobase.geodesy.ellipsoidal.create}
  ///
  /// The current position is transformed from the given [geocentric] cartesian
  /// coordinates (X, Y, Z).
  ///
  /// {@macro geobase.geodesy.ellipsoidal.ecef}
  ///
  /// {@macro geobase.geodesy.ellipsoidal.parameters}
  factory EllipsoidalVincenty.fromGeocentricCartesian(
    Position geocentric, {
    Ellipsoid ellipsoid = Ellipsoid.WGS84,
  }) {
    // an instance with target geographic position
    return EllipsoidalVincenty(
      EllipsoidalExtension.fromGeocentricCartesian(
        geocentric,
        ellipsoid: ellipsoid,
      ),
      ellipsoid: ellipsoid,
    );
  }

  @override
  EllipsoidalVincenty copyWith({Geographic? position}) =>
      position != null ? EllipsoidalVincenty(position) : this;

  /// Returns the distance from the current [position] to [destination] along a
  /// geodesic on the surface of the ellipsoid, using Vincenty inverse solution.
  ///
  /// The distance between this position and the destination is measured in
  /// meters. NaN is returned if failed to converge.
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 50.06632, lon: -5.71475);
  ///   const p2 = Geographic(lat: 58.64402, lon: -3.07009);
  ///   final d = p1.vincenty().distanceTo(p2); // 969954.166 m
  /// ```
  @override
  double distanceTo(Geographic destination) {
    if (position == destination) return 0.0;
    try {
      return _inverse(destination).distance;
    } catch (_) {
      return double.nan;
    }
  }

  /// Returns the bearing from the current position to [destination] along a
  /// geodesic on the surface of the ellipsoid, using Vincenty inverse solution.
  ///
  /// The bearing is measured in degrees from north (0°..360°). NaN is returned
  /// if failed to converge.
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 50.06632, lon: -5.71475);
  ///   const p2 = Geographic(lat: 58.64402, lon: -3.07009);
  ///   final b1 = p1.vincenty().initialBearingTo(p2); // 9.1419°
  /// ```
  @override
  double initialBearingTo(Geographic destination) {
    if (position == destination) return double.nan;
    try {
      return _inverse(destination).initialBearing;
    } catch (_) {
      return double.nan;
    }
  }

  /// Returns the bearing from the current position to [destination] along a
  /// geodesic on the surface of the ellipsoid, using Vincenty inverse solution.
  ///
  /// The bearing is measured in degrees from north (0°..360°). NaN is returned
  /// if failed to converge.
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 50.06632, lon: -5.71475);
  ///   const p2 = Geographic(lat: 58.64402, lon: -3.07009);
  ///   final b1 = p1.vincenty().finalBearingTo(p2); // 11.2972°
  /// ```
  @override
  double finalBearingTo(Geographic destination) {
    if (position == destination) return double.nan;
    try {
      return _inverse(destination).finalBearing;
    } catch (_) {
      return double.nan;
    }
  }

  /// Returns the final bearing having travelled along a geodesic on the
  /// surface of the ellipsoid from the current position the given distance on
  /// the given bearing.
  ///
  /// Parameters:
  /// * [distance]: Distance travelled along the geodesic in metres.
  /// * [bearing]: The initial bearing in degrees from north (0°..360°).
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: -37.95103, lon: 144.42487);
  ///
  ///   // final bearing (307.1736°)
  ///   final b2 = p1.vincenty().
  ///        finalBearingOn(distance: 54972.271, bearing: 306.86816);
  /// ```
  double finalBearingOn({
    required double distance,
    required double bearing,
  }) {
    if (distance == 0.0) return bearing;
    return _direct(distance, bearing).finalBearing;
  }

  /// Returns the destination point having travelled along a geodesic on the
  /// surface of the ellipsoid from the current position the given distance on
  /// the given bearing.
  ///
  /// Parameters:
  /// * [distance]: Distance travelled along the geodesic in metres.
  /// * [bearing]: The initial bearing in degrees from north (0°..360°).
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: -37.95103, lon: 144.42487);
  ///
  ///   // destination point (lat: 37.6528°S, lon: 143.9265°E)
  ///   final p2 = p1.vincenty().
  ///        destinationPoint(distance: 54972.271, bearing: 306.86816);
  /// ```
  @override
  Geographic destinationPoint({
    required double distance,
    required double bearing,
  }) {
    if (distance == 0.0) return position;
    return _direct(distance, bearing).point;
  }

  /// Returns the midpoint (along a geodesic on the surface of the ellipsoid)
  /// between the current position and [destination].
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 50.06632, lon: -5.71475);
  ///   const p2 = Geographic(lat: 58.64402, lon: -3.07009);
  ///
  ///   // midpoint (lat: 54.3639°N, lon: 004.5304°W)
  ///   final pMid = p1.vincenty().midPointTo(p2);
  /// ```
  @override
  Geographic midPointTo(Geographic destination) {
    if (position == destination) return position;
    return intermediatePointTo(destination, fraction: 0.5);
  }

  /// Returns the point at given fraction between the current position and
  /// [destination] (along a geodesic on the surface of the ellipsoid).
  ///
  /// Parameters:
  /// * [fraction]: 0.0 = this position, 1.0 = destination
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 50.06632, lon: -5.71475);
  ///   const p2 = Geographic(lat: 58.64402, lon: -3.07009);
  ///
  ///   // intermediate point (lat: 54.3639°N, lon: 004.5304°W)
  ///   final pMid = p1.vincenty().intermediatePointTo(p2, fraction: 0.5);
  /// ```
  Geographic intermediatePointTo(
    Geographic destination, {
    required double fraction,
  }) {
    if (fraction == 0.0) return position;
    if (fraction == 1.0) return destination;
    if (position == destination) return position;

    final inverse = _inverse(destination);
    final dist = inverse.distance;
    final brng = inverse.initialBearing;
    return brng.isNaN
        ? position
        : destinationPoint(distance: dist * fraction, bearing: brng);
  }

  /// Vincenty direct calculation.
  _DirectResult _direct(double distance, double initialBearing) {
    if (distance.isNaN) {
      throw throw FormatException('invalid distance $distance');
    }
    if (distance == 0) {
      return _DirectResult(
        point: position,
        finalBearing: double.nan,
        iterations: 0,
      );
    }
    if (initialBearing.isNaN) {
      throw throw FormatException('invalid bearing $initialBearing');
    }

    // symbols: α = alfa, σ = sigma, Δ = delta

    final lat1 = position.lat.toRadians();
    final lon1 = position.lon.toRadians();
    final alfa1 = initialBearing.toRadians();
    final s = distance;

    // ellipsoidal parameters
    final a = ellipsoid.a;
    final b = ellipsoid.b;
    final f = ellipsoid.f;

    final sinAlfa1 = sin(alfa1);
    final cosAlfa1 = cos(alfa1);

    final tanU1 = (1.0 - f) * tan(lat1);
    final cosU1 = 1.0 / sqrt(1.0 + tanU1 * tanU1);
    final sinU1 = tanU1 * cosU1;
    // σ1 = angular distance on the sphere from the equator to P1
    final sigma1 = atan2(tanU1, cosAlfa1);
    // α = azimuth of the geodesic at the equator
    final sinAlfa = cosU1 * sinAlfa1;
    final cosSqAlfa = 1.0 - sinAlfa * sinAlfa;
    final uSq = cosSqAlfa * (a * a - b * b) / (b * b);
    final A = 1.0 +
        uSq / 16384.0 * (4096.0 + uSq * (-768.0 + uSq * (320.0 - 175.0 * uSq)));
    final B =
        uSq / 1024.0 * (256.0 + uSq * (-128.0 + uSq * (74.0 - 47.0 * uSq)));

    // σ = angular distance P₁ P₂ on the sphere
    var sigma = s / (b * A);
    double? sinSigma;
    double? cosSigma;
    // σₘ = angular distance on the sphere from the equator to the midpoint of the line
    double? cos2SigmaM;

    double? sigmaI;
    var iterations = 0;
    do {
      cos2SigmaM = cos(2 * sigma1 + sigma);
      sinSigma = sin(sigma);
      cosSigma = cos(sigma);
      final deltaSigma = B *
          sinSigma *
          (cos2SigmaM +
              B /
                  4.0 *
                  (cosSigma * (-1.0 + 2.0 * cos2SigmaM * cos2SigmaM) -
                      B /
                          6.0 *
                          cos2SigmaM *
                          (-3.0 + 4.0 * sinSigma * sinSigma) *
                          (-3.0 + 4.0 * cos2SigmaM * cos2SigmaM)));
      sigmaI = sigma;
      sigma = s / (b * A) + deltaSigma;

      // TV: 'iterate until negligible change in λ' (≈0.006mm)
    } while ((sigma - sigmaI).abs() > 1e-12 && ++iterations < 100);
    if (iterations >= 100) {
      // not possible?
      throw const FormatException('Vincenty formula failed to converge');
    }

    final x = sinU1 * sinSigma - cosU1 * cosSigma * cosAlfa1;
    final lat2 = atan2(
      sinU1 * cosSigma + cosU1 * sinSigma * cosAlfa1,
      (1.0 - f) * sqrt(sinAlfa * sinAlfa + x * x),
    );
    final lon = atan2(
      sinSigma * sinAlfa1,
      cosU1 * cosSigma - sinU1 * sinSigma * cosAlfa1,
    );
    final C = f / 16.0 * cosSqAlfa * (4.0 + f * (4.0 - 3.0 * cosSqAlfa));
    final L = lon -
        (1.0 - C) *
            f *
            sinAlfa *
            (sigma +
                C *
                    sinSigma *
                    (cos2SigmaM +
                        C * cosSigma * (-1.0 + 2.0 * cos2SigmaM * cos2SigmaM)));
    final lon2 = lon1 + L;

    final alfa2 = atan2(sinAlfa, -x);

    return _DirectResult(
      point: Geographic(lat: lat2.toDegrees(), lon: lon2.toDegrees()),
      finalBearing: alfa2.toDegrees().wrap360(),
      iterations: iterations,
    );
  }

  /// Vincenty inverse calculation.
  _InverseResult _inverse(Geographic destination) {
    final lat1 = position.lat.toRadians();
    final lon1 = position.lon.toRadians();
    final lat2 = destination.lat.toRadians();
    final lon2 = destination.lon.toRadians();

    // symbols: α = alfa, σ = sigma, Δ = delta

    // ellipsoidal parameters
    final a = ellipsoid.a;
    final b = ellipsoid.b;
    final f = ellipsoid.f;

    // L = difference in longitude, U = reduced latitude, defined by tan U = (1-f)·tanφ.
    final L = lon2 - lon1;
    final tanU1 = (1.0 - f) * tan(lat1);
    final cosU1 = 1.0 / sqrt(1.0 + tanU1 * tanU1);
    final sinU1 = tanU1 * cosU1;
    final tanU2 = (1.0 - f) * tan(lat2);
    final cosU2 = 1.0 / sqrt(1.0 + tanU2 * tanU2);
    final sinU2 = tanU2 * cosU2;

    final antipodal = L.abs() > pi / 2.0 || (lat2 - lat1).abs() > pi / 2.0;

    // λ = difference in longitude on an auxiliary sphere
    var lon = L;
    double? sinLon;
    double? cosLon;
    // σ = angular distance P₁ P₂ on the sphere
    var sigma = antipodal ? pi : 0.0;
    var sinSigma = 0.0;
    var cosSigma = antipodal ? -1.0 : 1.0;
    double? sinSqSigma;
    // σₘ = angular distance on the sphere from the equator to the midpoint of the line
    var cos2SigmaM = 1.0;
    // α = azimuth of the geodesic at the equator
    var cosSqAlfa = 1.0;

    double? lonI;
    var iterations = 0;
    do {
      sinLon = sin(lon);
      cosLon = cos(lon);
      sinSqSigma = (cosU2 * sinLon) * (cosU2 * sinLon) +
          (cosU1 * sinU2 - sinU1 * cosU2 * cosLon) *
              (cosU1 * sinU2 - sinU1 * cosU2 * cosLon);
      if (sinSqSigma.abs() < 1e-24) {
        // co-incident/antipodal points (σ < ≈0.006mm)
        break;
      }
      sinSigma = sqrt(sinSqSigma);
      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLon;
      sigma = atan2(sinSigma, cosSigma);
      final sinAlfa = cosU1 * cosU2 * sinLon / sinSigma;
      cosSqAlfa = 1.0 - sinAlfa * sinAlfa;
      // on equatorial line cos²α = 0 (§6)
      cos2SigmaM = (cosSqAlfa != 0.0)
          ? (cosSigma - 2.0 * sinU1 * sinU2 / cosSqAlfa)
          : 0.0;
      final C = f / 16.0 * cosSqAlfa * (4.0 + f * (4.0 - 3.0 * cosSqAlfa));
      lonI = lon;
      lon = L +
          (1.0 - C) *
              f *
              sinAlfa *
              (sigma +
                  C *
                      sinSigma *
                      (cos2SigmaM +
                          C *
                              cosSigma *
                              (-1.0 + 2.0 * cos2SigmaM * cos2SigmaM)));
      final iterationCheck = antipodal ? lon.abs() - pi : lon.abs();
      if (iterationCheck > pi) {
        throw const FormatException('λ > π');
      }

      // TV: 'iterate until negligible change in λ' (≈0.006mm)
    } while ((lon - lonI).abs() > 1e-12 && ++iterations < 1000);
    if (iterations >= 1000) {
      throw const FormatException('Vincenty formula failed to converge');
    }

    final uSq = cosSqAlfa * (a * a - b * b) / (b * b);
    final A = 1.0 +
        uSq / 16384.0 * (4096.0 + uSq * (-768.0 + uSq * (320.0 - 175.0 * uSq)));
    final B =
        uSq / 1024.0 * (256.0 + uSq * (-128.0 + uSq * (74.0 - 47.0 * uSq)));
    final deltaSigma = B *
        sinSigma *
        (cos2SigmaM +
            B /
                4.0 *
                (cosSigma * (-1.0 + 2.0 * cos2SigmaM * cos2SigmaM) -
                    B /
                        6.0 *
                        cos2SigmaM *
                        (-3.0 + 4.0 * sinSigma * sinSigma) *
                        (-3.0 + 4.0 * cos2SigmaM * cos2SigmaM)));

    // s = length of the geodesic
    final s = b * A * (sigma - deltaSigma);

    // note special handling of exactly antipodal points where sin²σ = 0 (due to
    // discontinuity)
    //
    // atan2(0, 0) = 0 but atan2(ε, 0) = π/2 / 90°) - in which case bearing is
    // always meridional, due north (or due south!)
    // α = azimuths of the geodesic; α2 the direction P₁ P₂ produced
    final epsilon = doublePrecisionEpsilon;
    final alfa1 = sinSqSigma.abs() < epsilon
        ? 0.0
        : atan2(cosU2 * sinLon, cosU1 * sinU2 - sinU1 * cosU2 * cosLon);
    final alfa2 = sinSqSigma.abs() < epsilon
        ? pi
        : atan2(cosU1 * sinLon, -sinU1 * cosU2 + cosU1 * sinU2 * cosLon);

    return _InverseResult(
      distance: s,
      initialBearing:
          s.abs() < epsilon ? double.nan : alfa1.toDegrees().wrap360(),
      finalBearing:
          s.abs() < epsilon ? double.nan : alfa2.toDegrees().wrap360(),
      iterations: iterations,
    );
  }
}

class _DirectResult {
  final Geographic point;
  final double finalBearing;
  final int iterations;
  _DirectResult({
    required this.point,
    required this.finalBearing,
    required this.iterations,
  });
}

class _InverseResult {
  final double distance;
  final double initialBearing;
  final double finalBearing;
  final int iterations;
  _InverseResult({
    required this.distance,
    required this.initialBearing,
    required this.finalBearing,
    required this.iterations,
  });
}
