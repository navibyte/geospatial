/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* UTM / WGS-84 Conversion Functions                                  (c) Chris Veness 2014-2022  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong-utm-mgrs.html                                           */
/* www.movable-type.co.uk/scripts/geodesy-library.html#utm                                        */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// ignore_for_file: lines_longer_than_80_chars

// UTM / WGS-84 Conversion Functions (see license above) by Chris Veness ported
// to Dart by Navibyte.
//
// Source:
// https://github.com/chrisveness/geodesy/blob/master/utm.js

// Adaptations on the derivative work (the Dart port):
//
// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/common/codes/hemisphere.dart';
import '/src/coordinates/projected/projected.dart';

import 'datum.dart';

/// UTM coordinates, with functions to parse them and convert them to
/// geographic points.
@immutable
class Utm {
  /// UTM 6° longitudinal zone (1..60 covering 180°W..180°E).
  final int zone;

  /// The hemisphere of the Earth (north or south), represented as 'N' or 'S'
  /// in UTM coordinates.
  final Hemisphere hemisphere;

  /// The [projected] position as UTM coordinates (x=easting, y=northing,
  /// z=elev) in the specified [zone] and [hemisphere].
  ///
  /// {@template geobase.geodesy.utm.projected}
  ///
  /// Easting is in metres from false easting (-500km from central meridian).
  ///
  /// Northing is in metres from equator (N) or from false northing -10,000km
  /// (S).
  ///
  /// 2D positions are constructed as `Projected(x: easting, y: northing)`
  /// and 3D positions as `Projected(x: easting, y: northing, z: elev)`..
  /// 
  /// The [datum] indicates the geodetic reference (ie. ellipsoid and other
  /// parameters) used when projecting geographic coordinates to projected
  /// coordinates.
  /// 
  /// {@endtemplate}
  final Projected projected;

  /// The datum used for calculations with a reference ellipsoid and datum
  /// transformation parameters.
  /// 
  /// See also [projected].
  final Datum datum;

  /// Meridian convergence (bearing of grid north clockwise from true north),
  /// in degrees.
  final double? convergence;

  /// Grid scale factor.
  final double? scale;

  /// Creates UTM coordinates with [zone], [hemisphere], [easting], [northing]
  /// and an optional [elev] (elevation or altitude) based on the [datum].
  /// 
  /// {@macro geobase.geodesy.utm.projected}
  ///
  /// Set [convergence] for meridian convergence (bearing of grid north
  /// clockwise from true north), in degrees.
  ///
  /// Set [scale] for grid scale factor.
  ///
  /// If [verifyEN] is true it's validated that easting/northing is within
  /// 'normal' values (may be suppressed for extended coherent coordinates or
  /// alternative datums e.g. ED50, see epsg.io/23029).
  ///
  /// May throw a [FormatException] if the UTM zone, hemisphere, easting or
  /// northing are invalid.
  ///
  /// Examples:
  ///
  /// ```dart
  ///   // UTM coordinates with 2D position in zone 31N and WGS84 datum
  ///   // (easting 448251.0, northing 5411932.0).
  ///   final utmCoord = Utm(31, 'N', 448251.0, 5411932.0);
  /// ```
  factory Utm(
    int zone,
    String hemisphere,
    double easting,
    double northing, {
    double? elev,
    Datum datum = Datum.WGS84,
    double? convergence,
    double? scale,
    bool verifyEN = true,
  }) {
    // validate zone and hemisphere
    if (!(1 <= zone && zone <= 60)) {
      throw FormatException('invalid UTM zone $zone');
    }
    final hemisphereValue = Hemisphere.fromSymbol(hemisphere);

    if (verifyEN) {
      // (rough) range-check of E/N values
      if (!(0.0 <= easting && easting <= 1000.0e3)) {
        throw FormatException('invalid UTM easting $easting');
      }
      if (hemisphereValue == Hemisphere.north) {
        if (!(0.0 <= northing && northing < 9329006.0)) {
          throw FormatException('invalid UTM northing $northing');
        }
      } else { // southern hemisphere
        if (!(1116914.0 < northing && northing <= 10000.0e3)) {
          throw FormatException('invalid UTM northing $northing');
        }
      }
    }

    return Utm._position(
      zone,
      hemisphereValue,
      projected: Projected(x: easting, y: northing, z: elev),
      datum: datum,
      convergence: convergence,
      scale: scale,
    );
  }

  /// Creates an UTM coordinate with [zone], [hemisphere] and the [projected]
  /// position based on [datum].
  ///
  /// A 2D position should be constructed as
  /// `Projected(x: easting, y: northing)` and a 3D position as
  /// `Projected(x: easting, y: northing, z: elev)`.
  const Utm._position(
    this.zone,
    this.hemisphere, {
    required this.projected,
    required this.datum,
    this.convergence,
    this.scale,
  });

  @override
  String toString() {
    return '$zone;$hemisphere;$projected;$datum;$convergence;$scale';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Utm &&
          zone == other.zone &&
          hemisphere == other.hemisphere &&
          projected == other.projected &&
          datum == other.datum &&
          convergence == other.convergence &&
          scale == other.scale);

  @override
  int get hashCode => Object.hash(
        zone,
        hemisphere,
        projected,
        datum,
        convergence,
        scale,
      );
}
