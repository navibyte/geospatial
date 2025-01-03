/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* MGRS / UTM Conversion Functions                                    (c) Chris Veness 2014-2022  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong-utm-mgrs.html                                           */
/* www.movable-type.co.uk/scripts/geodesy-library.html#mgrs                                       */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// MGRS / UTM Conversion Functions Conversion Functions (see license above) by
// Chris Veness ported to Dart by Navibyte.
//
// Source:
// https://github.com/chrisveness/geodesy/blob/master/mgrs.js

// Adaptations on the derivative work (the Dart port):
//
// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

import 'package:meta/meta.dart';

import 'datum.dart';

/// Latitude bands C..X 8° each, covering 80°S to 84°N
const _latBands = 'CDEFGHJKLMNPQRSTUVWXX'; // X is repeated for 80-84°N

/// 100km grid square column (‘e’) letters repeat every third zone
const _e100kLetters = ['ABCDEFGH', 'JKLMNPQR', 'STUVWXYZ'];

/// 100km grid square row (‘n’) letters repeat every other zone
const _n100kLetters = ['ABCDEFGHJKLMNPQRSTUV', 'FGHJKLMNPQRSTUVABCDE'];

/// {@template geobase.geodesy.mgrs.about}
///
/// Military Grid Reference System (MGRS/NATO) grid references, with methods to
/// parse references, and to convert between MGRS references and UTM
/// coordinates.
///
/// Military Grid Reference System (MGRS/NATO) grid references provides
/// geocoordinate references covering the entire globe, based on the UTM
/// projection.
///
/// MGRS references comprise a grid zone designator, a 100km square
/// identification, and an easting and northing (in metres); e.g.
/// ‘31U DQ 48251 11932’.
///
/// Depending on requirements, some parts of the reference may be omitted
/// (implied), and eastings/northings may be given to varying resolution.
///
/// See also [Military Grid Reference System](https://en.wikipedia.org/wiki/Military_Grid_Reference_System)
/// in Wikipedia for more information.
///
/// Other refererences:
/// * [US National Grid](www.fgdc.gov/standards/projects/FGDC-standards-projects/usng/fgdc_std_011_2001_usng.pdf)
///
/// {@endtemplate}
@immutable
class Mgrs {
  /// {@macro geobase.geodesy.utm.zone}
  final int zone;

  /// {@template geobase.geodesy.mgrs.band}
  ///
  /// The [band] represents 8° latitudinal band (C..X covering 80°S..84°N).
  ///
  /// {@endtemplate}
  final String band;

  /// {@template geobase.geodesy.mgrs.e100k}
  ///
  /// The [e100k] represents the first letter (E) of a 100km grid square.
  ///
  /// {@endtemplate}
  final String e100k;

  /// {@template geobase.geodesy.mgrs.e100k}
  ///
  /// The [n100k] represents the second letter (N) of a 100km grid square.
  ///
  /// {@endtemplate}
  final String n100k;

  /// {@template geobase.geodesy.mgrs.easting}
  ///
  /// The easting (x) in metres within a 100km grid square.
  ///
  /// {@endtemplate}
  final int easting;

  /// {@template geobase.geodesy.mgrs.northing}
  ///
  /// The northing (y) in metres within a 100km grid square.
  ///
  /// {@endtemplate}
  final int northing;

  /// The datum used for calculations with a reference ellipsoid and datum
  /// transformation parameters.
  final Datum datum;

  /// Creates a MGRS grid reference with [zone], [band], [e100k], [n100k],
  /// [easting], [northing] based on the [datum] (used in the UTM projection).
  ///
  /// {@macro geobase.geodesy.utm.zone}
  ///
  /// {@macro geobase.geodesy.mgrs.band}
  ///
  /// {@macro geobase.geodesy.mgrs.e100k}
  ///
  /// {@macro geobase.geodesy.mgrs.n100k}
  ///
  /// {@macro geobase.geodesy.mgrs.easting}
  ///
  /// {@macro geobase.geodesy.mgrs.northing}
  ///
  /// {@macro geobase.geodesy.utm.datum}
  ///
  /// May throw a [FormatException] if MGRS zone, band, e100k, n100k, easting,
  /// northing or other attributes are invalid.
  ///
  /// Examples:
  ///
  /// ```dart
  ///   // MGRS grid reference with zone 31, band U, 100 km grid DQ and WGS84
  ///   // datum (easting 48251, northing 11932 within the grid cell).
  ///   //
  ///   // This equals to the MGRS grid reference '31U DQ 48251 11932'.
  ///   final mgrsRef = Mgrs(31, 'U', 'D', 'Q', 48251, 11932);
  /// ```
  factory Mgrs(
    int zone,
    String band,
    String e100k,
    String n100k,
    int easting,
    int northing, {
    Datum datum = Datum.WGS84,
  }) {
    // validate zone
    if (!(1 <= zone && zone <= 60)) {
      throw FormatException('invalid MGRS zone $zone');
    }

    // validate band, 100km grid square letters, easting and northing
    final errors = <String>[];
    if (band.length != 1 || !_latBands.contains(band)) {
      errors.add('invalid MGRS band `$band`');
    }
    if (e100k.length != 1 || !_e100kLetters[(zone - 1) % 3].contains(e100k)) {
      errors.add('invalid MGRS 100km grid square column `$e100k` for zone $zone');
    }
    if (n100k.length != 1 || !_n100kLetters[0].contains(n100k)) {
      errors.add('invalid MGRS 100km grid square row `$n100k`');
    }
    if (easting < 0 || easting > 99999) {
      errors.add('invalid MGRS easting `$easting`');
    }
    if (northing < 0 || northing > 99999) {
      errors.add('invalid MGRS northing `$northing`');
    }
    if (errors.isNotEmpty) {
      throw FormatException(errors.join(', '));
    }

    return Mgrs._coordinates(
      zone,
      band,
      e100k,
      n100k,
      easting,
      northing,
      datum: datum,
    );
  }

  const Mgrs._coordinates(
    this.zone,
    this.band,
    this.e100k,
    this.n100k,
    this.easting,
    this.northing, {
    required this.datum,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mgrs &&
          zone == other.zone &&
          band == other.band &&
          e100k == other.e100k &&
          n100k == other.n100k &&
          easting == other.easting &&
          northing == other.northing &&
          datum == other.datum);

  @override
  int get hashCode =>
      Object.hash(zone, band, e100k, n100k, easting, northing, datum);
}
