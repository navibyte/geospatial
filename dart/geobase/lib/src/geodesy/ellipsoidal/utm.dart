/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* UTM / WGS-84 Conversion Functions                                  (c) Chris Veness 2014-2022  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong-utm-mgrs.html                                           */
/* www.movable-type.co.uk/scripts/geodesy-library.html#utm                                        */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// ignore_for_file: lines_longer_than_80_chars, avoid_multiple_declarations_per_line

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
import '/src/coordinates/base/position.dart';
import '/src/coordinates/projected/projected.dart';

import 'datum.dart';

/// {@template geobase.geodesy.utm.meta}
///
/// Metadata ([convergence] and [scale]) as a result from UTM calculations
/// related to [position].
///
/// {@endtemplate}
///
/// {@macro geobase.geodesy.utm.meta.position}
///
/// {@macro geobase.geodesy.utm.meta.convergence}
///
/// {@macro geobase.geodesy.utm.meta.scale}
///
/// {@macro geobase.geodesy.utm.wikipedia}
///
/// See also [Utm] for representing projected UTM coordinates.
@immutable
class UtmMeta<T extends Object> {
  /// {@template geobase.geodesy.utm.meta.position}
  ///
  /// The [position] represents either a geographic position or projected UTM
  /// coordinates as indicated by [T], potentially with the geodetic datum
  /// information.
  ///
  /// {@endtemplate}
  final T position;

  /// {@template geobase.geodesy.utm.meta.convergence}
  ///
  /// The meridian [convergence] specifies the bearing of the grid north
  /// clockwise from the true north, in degrees.
  ///
  /// {@endtemplate}
  final double convergence;

  /// {@template geobase.geodesy.utm.meta.scale}
  ///
  /// The [scale] represents the UTM grid scale factor at [position].
  ///
  /// According to [Wikipedia](https://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system)
  /// the scale factor at the central meridian is specified to be 0.9996 of true
  /// scale for most UTM systems in use.
  ///
  /// {@endtemplate}
  final double scale;

  /// {@macro geobase.geodesy.utm.meta}
  ///
  /// {@macro geobase.geodesy.utm.meta.position}
  ///
  /// {@macro geobase.geodesy.utm.meta.convergence}
  ///
  /// {@macro geobase.geodesy.utm.meta.scale}
  const UtmMeta(
    this.position, {
    required this.convergence,
    required this.scale,
  });

  @override
  String toString() => '$position;$convergence;$scale';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UtmMeta &&
          position == other.position &&
          convergence == other.convergence &&
          scale == other.scale);

  @override
  int get hashCode => Object.hash(position, convergence, scale);
}

/// UTM coordinates, with functions to parse them and convert them to
/// geographic points.
///
/// {@macro geobase.geodesy.utm.zone}
///
/// {@macro geobase.geodesy.utm.hemisphere}
///
/// {@macro geobase.geodesy.utm.projected}
///
/// {@template geobase.geodesy.utm.wikipedia}
///
/// See also [Universal Transverse Mercator](https://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system)
/// in Wikipedia for more information.
///
/// {@endtemplate}
///
/// See also [UtmMeta] for metadata related to UTM calculations.
@immutable
class Utm {
  /// {@template geobase.geodesy.utm.zone}
  ///
  /// The [zone] represents UTM 6° longitudinal zone (1..60 covering
  /// 180°W..180°E).
  ///
  /// {@endtemplate}
  final int zone;

  /// {@template geobase.geodesy.utm.hemisphere}
  ///
  /// The [hemisphere] of the Earth (north or south) is represented by 'N' or
  /// 'S' in UTM coordinates.
  ///
  /// {@endtemplate}
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
  /// and 3D positions as `Projected(x: easting, y: northing, z: elev)`.
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

  /// Creates UTM coordinates with [zone], [hemisphere], [easting], [northing]
  /// and an optional [elev] (elevation or altitude) based on the [datum].
  ///
  /// {@macro geobase.geodesy.utm.zone}
  ///
  /// {@macro geobase.geodesy.utm.hemisphere}
  ///
  /// {@macro geobase.geodesy.utm.projected}
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
      } else {
        // southern hemisphere
        if (!(1116914.0 < northing && northing <= 10000.0e3)) {
          throw FormatException('invalid UTM northing $northing');
        }
      }
    }

    return Utm._coordinates(
      zone,
      hemisphereValue,
      projected: Projected(x: easting, y: northing, z: elev),
      datum: datum,
    );
  }

  /// Parses projected UTM coordinates from [text], by default in the following
  /// order: zone, hemisphere, easting, northing (ie. `31 N 448251 5411932`).
  ///
  /// Coordinate values in [text] are separated by [delimiter] (default is
  /// whitespace).
  ///
  /// If [swapXY] is true, then swaps x and y for the result.
  ///
  /// Throws FormatException if coordinates are invalid.
  ///
  /// Examples:
  /// ```dart
  ///   // UTM coordinates with 2D position in zone 31N and WGS84 datum
  ///   // (easting 448251.0, northing 5411932.0).
  ///   final utmCoord = Utm.parse('31 N 448251 5411932');
  ///
  ///   // UTM coordinates with 3D position in zone 31N and WGS84 datum
  ///   // (easting 448251.0, northing 5411932.0, elevation 100.0).
  ///   final utmWithElev = Utm.parse('31 N 448251 5411932 100');
  ///
  ///   // With swapped x and y (=> easting 448251.0, northing 5411932.0).
  ///   final utmSwapped = Utm.parse('31 N 5411932 448251', swapXY: true);
  /// ```
  factory Utm.parse(
    String text, {
    Pattern? delimiter,
    bool swapXY = false,
    Datum datum = Datum.WGS84,
  }) {
    final parts = text.trim().split(delimiter ?? RegExp(r'\s+'));
    if (parts.length < 4 || parts.length > 5) {
      throw FormatException('invalid UTM coordinate ‘$text’');
    }

    final zone = int.parse(parts[0]);
    final hemisphere = parts[1];
    final easting = double.parse(parts[swapXY ? 3 : 2]);
    final northing = double.parse(parts[swapXY ? 2 : 3]);
    final elev = parts.length >= 5 ? double.parse(parts[4]) : null;

    return Utm(zone, hemisphere, easting, northing, elev: elev, datum: datum);
  }

  /// Creates UTM coordinates with [zone], [hemisphere] and the [projected]
  /// position based on [datum].
  ///
  /// A 2D position should be constructed as
  /// `Projected(x: easting, y: northing)` and a 3D position as
  /// `Projected(x: easting, y: northing, z: elev)`.
  const Utm._coordinates(
    this.zone,
    this.hemisphere, {
    required this.projected,
    required this.datum,
  });

  /// The UTM coordinate string representation with values separated by
  /// [delimiter] (default is whitespace).
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// If [compactNums] is true, any ".0" postfixes of numbers without fraction
  /// digits are stripped.
  ///
  /// Set [swapXY] to true to print y (or northing) before x (or easting).
  ///
  /// Examples:
  ///
  /// ```dart
  ///   final utmCoord = Utm(31, 'N', 448251.0, 5411932.0);
  ///   print(utmCoord.toText()); // '31 N 448251 5411932'
  /// ```
  String toText({
    String delimiter = ' ',
    int decimals = 0,
    bool compactNums = true,
    bool swapXY = false,
  }) {
    final buf = StringBuffer()
      ..write(zone)
      ..write(delimiter)
      ..write(hemisphere.symbol)
      ..write(delimiter);

    Position.writeValues(
      projected,
      buf,
      delimiter: delimiter,
      decimals: decimals,
      compactNums: compactNums,
      swapXY: swapXY,
    );

    return buf.toString();
  }

  @override
  String toString() => toText(decimals: 3);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Utm &&
          zone == other.zone &&
          hemisphere == other.hemisphere &&
          projected == other.projected &&
          datum == other.datum);

  @override
  int get hashCode => Object.hash(
        zone,
        hemisphere,
        projected,
        datum,
      );
}
