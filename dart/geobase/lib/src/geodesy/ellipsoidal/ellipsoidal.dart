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
// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
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

import 'datum.dart';

/*
  NOTE: for the V2 of the geobase following changes are planned:
  * require always a full datum with ellipsoid and transformation parameters
  * WGS84 is the default datum (with WGS84 ellipsoid and "null transformation")
*/

@immutable
abstract class _EllipsoidalBase<T extends Position> {
  /// An optional datum used for calculations with a reference ellipsoid and
  /// datum transformation parameters.
  ///
  /// See also [ellipsoid].
  final Datum? datum;

  /// The reference ellipsoid used for calculations.
  ///
  /// When [datum] is provided, this [ellipsoid] property equals to the
  /// ellipsoid of the datum.
  ///
  /// See also [datum].
  final Ellipsoid ellipsoid;

  /// The origin position for calculations.
  final T origin;

  const _EllipsoidalBase(this.origin, {required this.ellipsoid}) : datum = null;

  _EllipsoidalBase._datum(this.origin, {required Datum this.datum})
      : ellipsoid = datum.ellipsoid;

  @override
  String toString() {
    return '$origin;$datum;$ellipsoid';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _EllipsoidalBase &&
          origin == other.origin &&
          datum == other.datum &&
          ellipsoid == other.ellipsoid);

  @override
  int get hashCode => Object.hash(origin, datum, ellipsoid);
}

/// The base class for calculations related to the Earth surface modeled by
/// ellipsoidal reference frames with geographic position (latitude, longitude)
/// as an origin.
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
/// See also the [Geocentric] class that has a geometric position as an origin.
class Ellipsoidal extends _EllipsoidalBase<Geographic> {
  /// Create an object for ellipsoidal calculations with [origin] as the
  /// current geographic position (latitude and longitude as geodetic
  /// coordinates) based on the given [ellipsoid].
  ///
  /// {@template geobase.geodesy.ellipsoidal.parameters}
  ///
  /// Use [ellipsoid] to set a reference ellipsoid with ellipsoidal parameters.
  ///
  /// {@endtemplate}
  const Ellipsoidal(super.origin, {super.ellipsoid = Ellipsoid.WGS84})
      : super();

  Ellipsoidal._datum(super.origin, {super.datum = Datum.WGS84})
      : super._datum();

  /// Create an object for ellipsoidal calculations with [origin] as the
  /// current geographic position (latitude and longitude as geodetic
  /// coordinates) based on the given [datum] or [ellipsoid].
  ///
  /// {@template geobase.geodesy.ellipsoidal.datumOrEllipsoid}
  ///
  /// If both [datum] and [ellipsoid] are provided, they must be compatible. If
  /// neither is provided, the default WGS84 datum / ellipsoid is used.
  ///
  /// {@endtemplate}
  factory Ellipsoidal.fromGeographic(
    Geographic origin, {
    Datum? datum,
    Ellipsoid? ellipsoid,
  }) {
    _checkDatumAndEllipsoid(datum, ellipsoid);

    if (datum != null) {
      // use the provided datum
      return Ellipsoidal._datum(origin, datum: datum);
    } else if (ellipsoid != null) {
      // use the provided ellipsoid
      return Ellipsoidal(origin, ellipsoid: ellipsoid);
    } else {
      // use the default WGS84 datum and ellipsoid
      return Ellipsoidal._datum(origin);
    }
  }

  /// Create an object for ellipsoidal calculations with a origin position
  /// transformed from geocentric [cartesian] coordinates (X, Y, Z) based on the
  /// given [datum] or [ellipsoid].
  ///
  /// {@macro geobase.geodesy.ellipsoidal.ecef}
  ///
  /// {@macro geobase.geodesy.ellipsoidal.datumOrEllipsoid}
  ///
  /// {@macro geobase.geodesy.ellipsoidal.omitElev}
  factory Ellipsoidal.fromGeocentricCartesian(
    Position cartesian, {
    Datum? datum,
    Ellipsoid? ellipsoid,
    bool omitElev = false,
  }) =>
      Geocentric.fromGeocentricCartesian(
        cartesian,
        datum: datum,
        ellipsoid: ellipsoid,
      ).toEllipsoidal(omitElev: omitElev);

  /// Transform the geographic position at [origin] (latitude and longitude as
  /// geodetic coordinates) to geocentric cartesian coordinates (X, Y, Z)
  /// represented by a [Geocentric] instance.
  ///
  ///{@macro geobase.geodesy.ellipsoidal.ecef}
  Geocentric toGeocentric() => Geocentric.fromGeocentricCartesian(
        toGeocentricCartesian(),
        datum: datum,
        ellipsoid: ellipsoid,
      );

  /// Transform the geographic position at [origin] (latitude and longitude as
  /// geodetic coordinates) to geocentric cartesian coordinates (X, Y, Z)
  /// represented by a [Position] instance.
  ///
  /// {@macro geobase.geodesy.ellipsoidal.ecef}
  Position toGeocentricCartesian() => geographicToGeocentricCartesian(
        lat: origin.lat,
        lon: origin.lon,
        elev: origin.optElev,
        m: origin.optM,
        ellipsoid: ellipsoid,
        to: Position.create,
      );

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ellipsoidal && super == other);
}

/// The base class for calculations related to the Earth surface modeled by
/// ellipsoidal reference frames with geocentric cartesian position (X, Y, Z) as
/// an origin.
///
/// {@macro geobase.geodesy.ellipsoidal.overview}
///
/// {@macro geobase.geodesy.ellipsoidal.ecef}
///
/// See also the [Ellipsoidal] class that has a geographic position as an
/// origin.
class Geocentric extends _EllipsoidalBase<Position> {
  /// Create an object for geocentric ellipsoidal calculations with [origin] as
  /// the current geocentric cartesian position (X, Y, Z) based on the given
  /// [ellipsoid].
  ///
  /// {@macro geobase.geodesy.ellipsoidal.parameters}
  ///
  /// {@macro geobase.geodesy.ellipsoidal.ecef}
  const Geocentric(super.origin, {super.ellipsoid = Ellipsoid.WGS84}) : super();

  Geocentric._datum(super.origin, {super.datum = Datum.WGS84}) : super._datum();

  /// Create an object for geocentric ellipsoidal calculations with [origin] as
  /// the current geocentric cartesian position (X, Y, Z) based on the given
  /// [datum] or [ellipsoid].
  ///
  /// {@macro geobase.geodesy.ellipsoidal.datumOrEllipsoid}
  ///
  /// {@macro geobase.geodesy.ellipsoidal.ecef}
  factory Geocentric.fromGeocentricCartesian(
    Position origin, {
    Datum? datum,
    Ellipsoid? ellipsoid,
  }) {
    _checkDatumAndEllipsoid(datum, ellipsoid);

    if (datum != null) {
      // use the provided datum
      return Geocentric._datum(origin, datum: datum);
    } else if (ellipsoid != null) {
      // use the provided ellipsoid
      return Geocentric(origin, ellipsoid: ellipsoid);
    } else {
      // use the default WGS84 datum and ellipsoid
      return Geocentric._datum(origin);
    }
  }

  /// Create an object for geocentric ellipsoidal calculations with a origin
  /// position transformed from [geographic] position (latitude and longitude as
  /// geodetic coordinates) based on the given [datum] or [ellipsoid].
  ///
  /// {@macro geobase.geodesy.ellipsoidal.datumOrEllipsoid}
  factory Geocentric.fromGeographic(
    Geographic geographic, {
    Datum? datum,
    Ellipsoid? ellipsoid,
  }) =>
      Ellipsoidal.fromGeographic(
        geographic,
        datum: datum,
        ellipsoid: ellipsoid,
      ).toGeocentric();

  /// Transform geocentric cartesian coordinates (X, Y, Z) at [origin] to a
  /// geographic position (latitude and longitude as geodetic coordinates)
  /// represented by an [Ellipsoidal] instance.
  ///
  /// {@macro geobase.geodesy.ellipsoidal.omitElev}
  Ellipsoidal toEllipsoidal({bool omitElev = false}) =>
      Ellipsoidal.fromGeographic(
        toGeographic(omitElev: omitElev),
        datum: datum,
        ellipsoid: ellipsoid,
      );

  /// Transform geocentric cartesian coordinates (X, Y, Z) at [origin] to a
  /// geographic position (latitude and longitude as geodetic coordinates)
  /// represented by a [Geographic] instance.
  ///
  /// {@template geobase.geodesy.ellipsoidal.omitElev}
  ///
  /// If [omitElev] is true, the optional elevation value is not calculated and
  /// it's set to null on the result geographic position. This can be useful if
  /// the elevation is near the ellipsoid surface and a non-zero elevation
  /// potentially resulted from the calculation is not wanted.
  ///
  /// {@endtemplate}
  Geographic toGeographic({bool omitElev = false}) =>
      geocentricCartesianToGeographic(
        x: origin.x,
        y: origin.y,
        z: origin.z,
        m: origin.optM,
        ellipsoid: ellipsoid,
        to: Geographic.create,
        omitElev: omitElev,
      );

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      identical(this, other) || (other is Geocentric && super == other);
}

void _checkDatumAndEllipsoid(Datum? datum, Ellipsoid? ellipsoid) {
  // check if datum and ellipsoid are compatible
  if (datum != null && ellipsoid != null && datum.ellipsoid != ellipsoid) {
    throw const FormatException('Datum and ellipsoid must be compatible.');
  }
}

// -----------------------------------------------------------------------------
// Internal functions to implement geocentric and geographic conversions with
// as low overhead as possible. These functions are used by ellipsoidal and
// datum classes.
//
// Functions are not exported, so marked as internal. In future these functions
// could be optimized further by using records or other efficient data
// structures.

/// Internal function to convert geographic coordinates (longitude, latitudee)
/// to geocentric cartesian coordinates (x, y, z).
///
/// Target position object is created using the [to] function.
@internal
R geographicToGeocentricCartesian<R extends Position>({
  required double lon,
  required double lat,
  double? elev,
  double? m,
  required Ellipsoid ellipsoid,
  required CreatePosition<R> to,
}) {
  // source geographic position
  final latRad = lat.toRadians();
  final lonRad = lon.toRadians();
  final h = elev ?? 0.0; // if elev is null, set it to 0.0 (ellipsoid surface)
  final sinLat = sin(latRad);
  final cosLat = cos(latRad);
  final sinLon = sin(lonRad);
  final cosLon = cos(lonRad);

  // ellipsoidal parameters
  final a = ellipsoid.a;
  final f = ellipsoid.f;

  // 1st eccentricity squared ≡ (a²-b²)/a²
  final eSq = 2.0 * f - f * f;

  // (ν = nu) radius of curvature in prime vertical
  final nu = a / sqrt(1.0 - eSq * sinLat * sinLat);

  // target geocentric cartesian position
  return to.call(
    x: (nu + h) * cosLat * cosLon,
    y: (nu + h) * cosLat * sinLon,
    z: (nu * (1.0 - eSq) + h) * sinLat,
    m: m, // do not convert optional M value
  );
}

/// Internal function to convert geocentric cartesian coordinates (x, y, z) to
/// geographic coordinates (longitude, latitude).
///
/// Target position object is created using the [to] function.
@internal
R geocentricCartesianToGeographic<R extends Position>({
  required double x,
  required double y,
  required double z,
  double? m,
  required Ellipsoid ellipsoid,
  required CreatePosition<R> to,
  bool omitElev = false,
}) {
  // ε = epsilon, β = beta, ν = nu

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

  // optional height above ellipsoid, calculated if omitElev is false
  double? optElev;
  if (omitElev) {
    optElev = null;
  } else {
    // height above ellipsoid (Bowring eqn.7)
    final sinLat = sin(lat);
    final cosLat = cos(lat);
    final nu = a /
        sqrt(
          1.0 - eSq * sinLat * sinLat,
        ); // length of the normal terminated by the minor axis
    final h = p * cosLat + z * sinLat - (a * a / nu);
    optElev = h;
  }

  // create a geographic position
  return to.call(
    x: lon.toDegrees(), // NOTE in position data structures x is longitude
    y: lat.toDegrees(), // NOTE in position data structures y is latitude
    z: optElev,
    m: m, // do not convert optional M value
  );
}
