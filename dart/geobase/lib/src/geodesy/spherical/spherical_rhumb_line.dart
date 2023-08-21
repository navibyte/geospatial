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

import '/src/coordinates/geographic/geographic.dart';
import '/src/coordinates/geographic/geographic_functions.dart';
import '/src/geodesy/base/geodetic.dart';

/// An extension for easier access to [SphericalRhumbLine].
extension SphericalRhumbLineExtension on Geographic {
  /// Create an object calculating distances, bearings, destinations, etc on
  /// (loxodromic) rhumb line paths with this position as the current
  /// position.
  SphericalRhumbLine get rhumb => SphericalRhumbLine(this);
}

/// Latitude/longitude points on a spherical model earth, and methods for
/// calculating distances, bearings, destinations, etc on (loxodromic) rhumb
/// lines.
@immutable
class SphericalRhumbLine extends Geodetic {
  /// Create an object calculating distances, bearings, destinations, etc on
  /// (loxodromic) rhumb line paths with [position] as the current position.
  const SphericalRhumbLine(super.position);

  @override
  SphericalRhumbLine copyWith({Geographic? position}) =>
      position != null ? SphericalRhumbLine(position) : this;

  /// Returns the distance from the current [position] to [destination] along a
  /// rhumb line.
  ///
  /// Parameters:
  /// * [radius]: The radius of earth (defaults to mean radius in metres).
  ///
  /// The distance between this position and the destination is measured in same
  /// units as the given radius.
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 51.127, lon: 1.338);
  ///   const p2 = Geographic(lat: 50.964, lon: 1.853);
  ///   final d = p1.rhumb.distanceTo(p2); // 40.31 km
  /// ```
  @override
  double distanceTo(
    Geographic destination, {
    double radius = 6371000.0,
  }) {
    if (position == destination) return 0.0;

    // see www.edwilliams.org/avform.htm#Rhumb

    final lat1 = position.lat.toRadians();
    final lat2 = destination.lat.toRadians();
    final dlat = lat2 - lat1;
    var dlon = (destination.lon - position.lon).toRadians();

    // if dlon over 180° take shorter rhumb line across the anti-meridian:
    if (dlon.abs() > pi) {
      dlon = dlon > 0.0 ? -(2.0 * pi - dlon) : (2.0 * pi + dlon);
    }

    // on Mercator projection, longitude distances shrink by latitude
    // q is the 'stretch factor'
    // q becomes ill-conditioned along E-W line (0/0)
    // use empirical tolerance to avoid it (note ε is too small)
    final dlatProj =
        log(tan(lat2 / 2.0 + pi / 4.0) / tan(lat1 / 2.0 + pi / 4.0));
    final q = dlatProj.abs() > 10e-12 ? dlat / dlatProj : cos(lat1);

    // distance is pythagoras on 'stretched' Mercator projection, √(Δφ² + q²·Δλ²)
    final dst =
        sqrt(dlat * dlat + q * q * dlon * dlon); // angular distance in radians
    return dst * radius;
  }

  /// Returns the bearing from the current position to [destination] along a
  /// rhumb line.
  ///
  /// The bearing is measured in degrees from north (0°..360°).
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 51.127, lon: 1.338);
  ///   const p2 = Geographic(lat: 50.964, lon: 1.853);
  ///   final b1 = p1.rhumb.initialBearingTo(p2); // 116.7°
  /// ```
  ///
  /// See also [finalBearingTo] (in rhumb line calculations initial and final
  /// bearings equals).
  @override
  double initialBearingTo(Geographic destination) {
    if (position == destination) return double.nan;

    final lat1 = position.lat.toRadians();
    final lat2 = destination.lat.toRadians();
    var dlon = (destination.lon - position.lon).toRadians();

    // if dlon over 180° take shorter rhumb line across the anti-meridian:
    if (dlon.abs() > pi) {
      dlon = dlon > 0.0 ? -(2.0 * pi - dlon) : (2.0 * pi + dlon);
    }

    final dlatProj =
        log(tan(lat2 / 2.0 + pi / 4.0) / tan(lat1 / 2.0 + pi / 4.0));

    final bearing = atan2(dlon, dlatProj).toDegrees();
    return bearing.wrap360();
  }

  /// Returns the bearing from the current position to [destination] along a
  /// rhumb line.
  ///
  /// The bearing is measured in degrees from north (0°..360°).
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 51.127, lon: 1.338);
  ///   const p2 = Geographic(lat: 50.964, lon: 1.853);
  ///   final b1 = p1.rhumb.finalBearingTo(p2); // 116.7°
  /// ```
  ///
  /// See also [initialBearingTo] (in rhumb line calculations initial and final
  /// bearings equals).
  @override
  double finalBearingTo(Geographic destination) =>
      initialBearingTo(destination);

  /// Returns the destination point having travelled along a rhumb line from the
  /// current position the given distance on the given bearing.
  ///
  /// Parameters:
  /// * [distance]: Distance travelled (same units as radius, default: metres).
  /// * [bearing]: The bearing in degrees from north (0°..360°).
  /// * [radius]: The radius of earth (defaults to mean radius in metres).
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 51.127, lon: 1.338);
  ///
  ///   // destination point (lat: 50.9642°N, lon: 001.8530°E)
  ///   final p2 = p1.rhumb.
  ///        destinationPoint(distance: 40300.0, bearing: 116.7);
  /// ```
  @override
  Geographic destinationPoint({
    required double distance,
    required double bearing,
    double radius = 6371000.0,
  }) {
    if (distance == 0.0) return position;

    final lat1 = position.lat.toRadians();
    final lon1 = position.lon.toRadians();
    final brng = bearing.toRadians();

    final dst = distance / radius; // angular distance in radians

    final dlat = dst * cos(brng);
    var lat2 = lat1 + dlat;

    // check for some daft bugger going past the pole, normalise latitude if so
    if (lat2.abs() > pi / 2.0) {
      lat2 = lat2 > 0.0 ? pi - lat2 : -pi - lat2;
    }

    final dlatProj =
        log(tan(lat2 / 2.0 + pi / 4.0) / tan(lat1 / 2.0 + pi / 4.0));
    final q = dlatProj.abs() > 10e-12 ? dlat / dlatProj : cos(lat1);

    final dlon = dst * sin(brng) / q;
    final lon2 = lon1 + dlon;

    return Geographic(lat: lat2.toDegrees(), lon: lon2.toDegrees());
  }

  /// Returns the loxodromic midpoint (along a rhumb line) between the current
  /// position and [destination].
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 51.127, lon: 1.338);
  ///   const p2 = Geographic(lat: 50.964, lon: 1.853);
  ///
  ///   // midpoint (lat: 51.0455°N, lon: 001.5957°E)
  ///   final pMid = p1.rhumb.midPointTo(p2);
  /// ```
  @override
  Geographic midPointTo(Geographic destination) {
    if (position == destination) return position;

    // see mathforum.org/kb/message.jspa?messageID=148837

    final lat1 = position.lat.toRadians();
    var lon1 = position.lon.toRadians();
    final lat2 = destination.lat.toRadians();
    final lon2 = destination.lon.toRadians();

    if ((lon2 - lon1).abs() > pi) lon1 += 2.0 * pi; // crossing anti-meridian

    final lat3 = (lat1 + lat2) / 2.0;
    final f1 = tan(pi / 4.0 + lat1 / 2.0);
    final f2 = tan(pi / 4.0 + lat2 / 2.0);
    final f3 = tan(pi / 4.0 + lat3 / 2.0);
    var lon3 = ((lon2 - lon1) * log(f3) + lon1 * log(f2) - lon2 * log(f1)) /
        log(f2 / f1);

    if (!lon3.isFinite) {
      lon3 = (lon1 + lon2) / 2.0; // parallel of latitude
    }

    return Geographic(lat: lat3.toDegrees(), lon: lon3.toDegrees());
  }
}
