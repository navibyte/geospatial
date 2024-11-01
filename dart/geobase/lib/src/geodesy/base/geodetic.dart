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
// This is an abstracted class of common methods for spherical great circle and
// rhumb line implementations.

// Adaptations on the derivative work (the Dart port):
//
// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/geographic/geographic.dart';

/// An abstract class with methods to calculate distances, bearings,
/// destinations, etc on a geographic position.
///
/// Sub classes should implement methods defined here. Sub classes may also
/// introduce other geodetic calculations.
abstract class Geodetic {
  /// The current geographic position for calculations.
  final Geographic position;

  /// Create an object calculating distances, bearings, destinations, etc on
  /// a geographic [position] as the current position.
  const Geodetic(this.position);

  /// Copy this geodetic object with an optional [position] changed.
  Geodetic copyWith({Geographic? position});

  /// Returns the distance along the surface of the earth from the current
  /// [position] to [destination].
  ///
  /// The distance between this position and the destination is measured in same
  /// units as the given radius.
  double distanceTo(Geographic destination);

  /// Returns the initial bearing from the current [position] to [destination].
  ///
  /// The initial bearing is measured in degrees from north (0°..360°).
  double initialBearingTo(Geographic destination);

  /// Returns the final bearing arriving at [destination] from the current
  /// [position].
  ///
  /// The initial bearing is measured in degrees from north (0°..360°).
  double finalBearingTo(Geographic destination);

  /// Returns the midpoint between the current [position] and [destination].
  Geographic midPointTo(Geographic destination);

  /// Returns the destination point from the current [position] having travelled
  /// the given [distance] on the given initial [bearing].
  ///
  /// Parameters:
  /// * [distance]: Distance travelled (same units as radius, default: metres).
  /// * [bearing]: Initial bearing in degrees from north (0°..360°).
  Geographic destinationPoint({
    required double distance,
    required double bearing,
  });
}
