/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Geodesy tools for an ellipsoidal earth model                       (c) Chris Veness 2005-2024  */
/*                                                                                   MIT Licence  */
/* Core class for latlon-ellipsoidal-datum & latlon-ellipsoidal-referenceframe.                   */
/*                                                                                                */
/* www.movable-type.co.uk/scripts/latlong-convert-coords.html                                     */
/* www.movable-type.co.uk/scripts/geodesy-library.html#latlon-ellipsoidal                         */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// ignore_for_file: lines_longer_than_80_chars

// Geodesy tools for an ellipsoidal earth model (see license above) by Chris
// Veness ported to Dart by Navibyte.
//
// Source:
// https://github.com/chrisveness/geodesy/blob/master/latlon-ellipsoidal.js

// Adaptations on the derivative work (the Dart port):
//
// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// See also
// https://en.wikipedia.org/wiki/Earth-centered,_Earth-fixed_coordinate_system
// https://en.wikipedia.org/wiki/Geographic_coordinate_conversion

import 'dart:math';

import 'package:meta/meta.dart';

import '/src/common/functions/position_functions.dart';
import '/src/common/reference/ellipsoid.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/geographic/geographic.dart';

/// The base class for calculations related to the Earth surface modeled by
/// ellipsoidal reference frames.
///
/// {@template geobase.geodesy.ellipsoidal.overview}
///
/// Provides tranformations between geocentric cartesian coordinates
/// represented by ECEF (earth-centric earth-fixed) positions and geographic
/// positions (latitude and longitude as geodetic coordinates).
///
/// {@endtemplate}
///
/// {@template geobase.geodesy.ellipsoidal.ecef}
///
/// Geocentric cartesian coordinates represents an ECEF (earth-centric
/// earth-fixed) position with following coordinates:
/// * X coordinate in metres (the axis pointing to 0°N, 0°E).
/// * Y coordinate in metres (the axis pointing to 0°N, 90°E).
/// * Z coordinate in metres (the axis pointing to 90°N).
///
/// {@endtemplate}
///
/// See also the [EllipsoidalExtension] extension with alternative way of
/// accessing these transformations.
@immutable
class Ellipsoidal {
  /// The reference ellipsoid used for calculations.
  final Ellipsoid ellipsoid;

  /// The origin geographic position for calculations.
  final Geographic origin;

  /// Create an object for ellipsoidal calculations with [origin] as the
  /// current geographic position (latitude and longitude as geodetic
  /// coordinates).
  ///
  /// {@template geobase.geodesy.ellipsoidal.parameters}
  ///
  /// Parameters:
  /// * [ellipsoid]: A reference ellipsoid with ellipsoidal parameters.
  ///
  /// {@endtemplate}
  const Ellipsoidal(this.origin, {this.ellipsoid = Ellipsoid.WGS84});

  /// Create an object for ellipsoidal calculations with a origin position
  /// transformed from [geocentric] cartesian coordinates (X, Y, Z).
  ///
  /// {@macro geobase.geodesy.ellipsoidal.ecef}
  ///
  /// {@macro geobase.geodesy.ellipsoidal.parameters}
  factory Ellipsoidal.fromGeocentricCartesian(
    Position geocentric, {
    Ellipsoid ellipsoid = Ellipsoid.WGS84,
  }) {
    // an instance with target geographic position
    return Ellipsoidal(
      EllipsoidalExtension.fromGeocentricCartesian(
        geocentric,
        ellipsoid: ellipsoid,
      ),
      ellipsoid: ellipsoid,
    );
  }

  /// Transform the geographic position at [origin] (latitude and longitude as
  /// geodetic coordinates) to geocentric cartesian coordinates (X, Y, Z).
  ///
  ///{@macro geobase.geodesy.ellipsoidal.ecef}
  Position toGeocentricCartesian() {
    // source geographic position
    final lat = origin.lat.toRadians();
    final lon = origin.lon.toRadians();
    final h = origin.elev;
    final sinLat = sin(lat);
    final cosLat = cos(lat);
    final sinLon = sin(lon);
    final cosLon = cos(lon);

    // ellipsoidal parameters
    final a = ellipsoid.a;
    final f = ellipsoid.f;

    // 1st eccentricity squared ≡ (a²-b²)/a²
    final eSq = 2.0 * f - f * f;

    // (ν = nu) radius of curvature in prime vertical
    final nu = a / sqrt(1.0 - eSq * sinLat * sinLat);

    // target geocentric cartesian position
    return Position.create(
      x: (nu + h) * cosLat * cosLon,
      y: (nu + h) * cosLat * sinLon,
      z: (nu * (1.0 - eSq) + h) * sinLat,
    );
  }

  @override
  String toString() {
    return '$origin;$ellipsoid';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ellipsoidal &&
          ellipsoid == other.ellipsoid &&
          origin == other.origin);

  @override
  int get hashCode => Object.hash(ellipsoid, origin);
}

/// An extension of the [Geographic] class providing calculations related to the
/// Earth surface modeled by ellipsoidal reference frames.
///
/// {@macro geobase.geodesy.ellipsoidal.overview}
///
/// See also the [Ellipsoidal] base class with alternative way of accessing
/// these transformations.
extension EllipsoidalExtension on Geographic {
  /// Transform this geographic position (latitude and longitude as
  /// geodetic coordinates) to geocentric cartesian coordinates (X, Y, Z).
  ///
  /// {@macro geobase.geodesy.ellipsoidal.ecef}
  ///
  /// {@macro geobase.geodesy.ellipsoidal.parameters}
  Position toGeocentricCartesian({Ellipsoid ellipsoid = Ellipsoid.WGS84}) =>
      Ellipsoidal(this, ellipsoid: ellipsoid).toGeocentricCartesian();

  /// Transform the given [geocentric] cartesian coordinates (X, Y, Z) to
  /// geographic coordinates (latitude and longitude).
  ///
  /// {@macro geobase.geodesy.ellipsoidal.ecef}
  ///
  /// Parameters:
  /// * [ellipsoid]: A reference ellipsoid with ellipsoidal parameters.
  static Geographic fromGeocentricCartesian(
    Position geocentric, {
    Ellipsoid ellipsoid = Ellipsoid.WGS84,
  }) {
    // ε = epsilon, β = beta, ν = nu

    // source geocentric cartesian position
    final x = geocentric.x;
    final y = geocentric.y;
    final z = geocentric.z;

    // ellipsoidal parameters
    final a = ellipsoid.a;
    final b = ellipsoid.b;
    final f = ellipsoid.f;

    final eSq = 2.0 * f - f * f; // 1st eccentricity squared ≡ (a²−b²)/a²
    final epsilon2 = eSq / (1.0 - eSq); // 2nd eccentricity squared ≡ (a²−b²)/b²
    final p = sqrt(x * x + y * y); // distance from minor axis
    final R = sqrt(p * p + z * z); // polar radius

    // parametric latitude (Bowring eqn.17, replacing tanβ = z·a / p·b)
    final tanBeta = (b * z) / (a * p) * (1.0 + epsilon2 * b / R);
    final sinBeta = tanBeta / sqrt(1.0 + tanBeta * tanBeta);
    final cosBeta = sinBeta / tanBeta;

    // geodetic latitude (Bowring eqn.18: tanφ = z+ε²⋅b⋅sin³β / p−e²⋅cos³β)
    final lat = cosBeta.isNaN
        ? 0.0
        : atan2(
            z + epsilon2 * b * sinBeta * sinBeta * sinBeta,
            p - eSq * a * cosBeta * cosBeta * cosBeta,
          );

    // geodetic longitude
    final lon = atan2(y, x);

    // height above ellipsoid (Bowring eqn.7)
    final sinLat = sin(lat);
    final cosLat = cos(lat);
    final nu = a /
        sqrt(
          1.0 - eSq * sinLat * sinLat,
        ); // length of the normal terminated by the minor axis
    final h = p * cosLat + z * sinLat - (a * a / nu);

    // create a geographic position
    return Geographic(
      lat: lat.toDegrees(),
      lon: lon.toDegrees(),
      elev: h,
    );
  }
}
