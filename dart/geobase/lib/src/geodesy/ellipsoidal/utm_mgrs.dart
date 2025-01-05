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

import 'dart:math';

import 'package:meta/meta.dart';

import '/src/coordinates/geographic/geographic.dart';

import 'datum.dart';
import 'utm.dart';

/// Latitude bands C..X 8° each, covering 80°S to 84°N
const _latBands = 'CDEFGHJKLMNPQRSTUVWXX'; // X is repeated for 80-84°N

/// 100km grid square column (‘e’) letters repeat every third zone
const _columnLetters = ['ABCDEFGH', 'JKLMNPQR', 'STUVWXYZ'];

/// 100km grid square row (‘n’) letters repeat every other zone
const _rowLetters = ['ABCDEFGHJKLMNPQRSTUV', 'FGHJKLMNPQRSTUVABCDE'];

/// A grid zone as a polygon of 6° × 8° in MGRS/NATO grid references.
///
/// Grid zones are identified by grid zone designator (GZD) like `31U` with
/// 6° longitudinal [zone] and 8° latitudinal [band].
///
/// According to
/// [Wikipedia](https://en.wikipedia.org/wiki/Military_Grid_Reference_System)
/// the intersection of a UTM zone and a latitude band is (normally) a 6° × 8°
/// polygon called a *grid zone*.
///
/// See [Mgrs] for more information and representing MGRS grid references.
@immutable
class MgrsGridZone {
  /// {@macro geobase.geodesy.utm.zone}
  final int zone;

  /// {@template geobase.geodesy.mgrs.band}
  ///
  /// The [band] represents 8° latitudinal band (C..X covering 80°S..84°N).
  ///
  /// {@endtemplate}
  final String band;

  /// Creates a MGRS grid zone with [zone] and [band].
  ///
  /// {@macro geobase.geodesy.utm.zone}
  ///
  /// {@macro geobase.geodesy.mgrs.band}
  ///
  /// Throws a [FormatException] if MGRS zone or band is invalid.
  ///
  /// Examples:
  ///
  /// ```dart
  ///   // MGRS grid zone with zone 31 and band U.
  ///   final mgrsGridZone = MgrsGridZone(31, 'U');
  /// ```
  factory MgrsGridZone(int zone, String band) {
    // validate zone
    if (!(1 <= zone && zone <= 60)) {
      throw FormatException('invalid MGRS zone $zone');
    }

    // validate band
    if (band.length != 1 || !_latBands.contains(band)) {
      throw FormatException('invalid MGRS band `$band`');
    }

    return MgrsGridZone._coordinates(
      zone,
      band,
    );
  }

  const MgrsGridZone._coordinates(
    this.zone,
    this.band,
  );

  /// The MGRS grid zone string representation.
  ///
  /// {@macro geobase.geodesy.mgrs.distinquishFromUTM}
  ///
  /// {@macro geobase.geodesy.mgrs.zoneLeadingZero}
  ///
  /// Examples:
  ///
  /// ```dart
  ///   // a sample MGRS grid zone `31U`
  ///   final mgrsGridZone = MgrsGridZone(31, 'U');
  ///
  ///   // the default format
  ///   print(mgrsGridZone.toText()); // '31U'
  ///
  ///   // another sample `4Q`
  ///   final mgrsGridZone2 = MgrsGridZone(4, 'Q');
  ///
  ///   // zone without a leading zero
  ///   print(mgrsGridZone2.toText()); // '4Q'
  ///
  ///   // zone with a leading zero
  ///   print(mgrsGridZone2.toText(zeroPadZone: true)); // '04Q'
  /// ```
  String toText({bool zeroPadZone = false}) {
    // ensure leading zeros on zone if `zeroPadZone` is set true
    final zPadded =
        zeroPadZone ? zone.toString().padLeft(2, '0') : zone.toString();

    return '$zPadded$band';
  }

  @override
  String toString() => toText();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MgrsGridZone && zone == other.zone && band == other.band);

  @override
  int get hashCode => Object.hash(zone, band);
}

/// The 100km grid square (or the 100,000-meter square identifier) as a part of
/// the grid zone in MGRS/NATO grid references.
///
/// Grid squares are identified by grid zone designators (GZD) like `31U`, see
/// [MgrsGridZone], and 100 km Grid Square IDs like `DQ`.
///
/// According to
/// [Wikipedia](https://en.wikipedia.org/wiki/Military_Grid_Reference_System)
/// each UTM zone is divided into 100,000 meter squares, so that their corners
/// have UTM-coordinates that are multiples of 100,000 meters.
///
/// See [Mgrs] for more information and representing MGRS grid references.
class MgrsGridSquare extends MgrsGridZone {
  /// {@template geobase.geodesy.mgrs.column}
  ///
  /// The [column] (or "e100k") represents the first letter (E) of a 100km grid
  /// square. Allowed letter characters are A..Z, omitting I and O.
  ///
  /// {@endtemplate}
  final String column;

  /// {@template geobase.geodesy.mgrs.row}
  ///
  /// The [row] (or "n100k") represents the second letter (N) of a 100km grid
  /// square. Allowed letter characters are A..V, omitting I and O.
  ///
  /// {@endtemplate}
  final String row;

  /// Creates a MGRS 100km grid square with [zone], [band], [column] and [row].
  ///
  /// {@macro geobase.geodesy.utm.zone}
  ///
  /// {@macro geobase.geodesy.mgrs.band}
  ///
  /// {@macro geobase.geodesy.mgrs.column}
  ///
  /// {@macro geobase.geodesy.mgrs.row}
  ///
  /// Throws a [FormatException] if MGRS zone, band, column or row is invalid.
  ///
  /// Examples:
  ///
  /// ```dart
  ///   // MGRS grid square with zone 31, band U, 100 km grid DQ.
  ///   final mgrsGridSquare = MgrsGridSquare(31, 'U', 'D', 'Q');
  /// ```
  factory MgrsGridSquare(
    int zone,
    String band,
    String column,
    String row,
  ) {
    // validate zone
    if (!(1 <= zone && zone <= 60)) {
      throw FormatException('invalid MGRS zone $zone');
    }

    // validate band and 100km grid square letters
    final errors = <String>[];
    if (band.length != 1 || !_latBands.contains(band)) {
      errors.add('invalid MGRS band `$band`');
    }
    if (column.length != 1 ||
        !_columnLetters[(zone - 1) % 3].contains(column)) {
      errors.add(
        'invalid MGRS 100km grid square column `$column` for zone $zone',
      );
    }
    if (row.length != 1 || !_rowLetters[0].contains(row)) {
      errors.add('invalid MGRS 100km grid square row `$row`');
    }
    if (errors.isNotEmpty) {
      throw FormatException(errors.join(', '));
    }

    return MgrsGridSquare._coordinates(
      zone,
      band,
      column,
      row,
    );
  }

  const MgrsGridSquare._coordinates(
    super.zone,
    super.band,
    this.column,
    this.row,
  ) : super._coordinates();

  /// The MGRS grid square string representation with components separated by
  /// whitespace by default.
  ///
  /// {@macro geobase.geodesy.mgrs.distinquishFromUTM}
  ///
  /// {@macro geobase.geodesy.mgrs.militaryStyle}
  ///
  /// {@macro geobase.geodesy.mgrs.zoneLeadingZero}
  ///
  /// Examples:
  ///
  /// ```dart
  ///   // a sample MGRS grid square `31U DQ`
  ///   final mgrsGridSquare = MgrsGridSquare(31, 'U', 'D', 'Q');
  ///
  ///   // the default format
  ///   print(mgrsGridSquare.toText()); // '31U DQ'
  ///
  ///   // the military style
  ///   print(mgrsGridSquare.toText(militaryStyle: true)); // '31UDQ'
  ///
  ///   // another sample `4Q FJ`
  ///   final mgrsGridSquare2 = MgrsGridSquare(4, 'Q', 'F', 'J');
  ///
  ///   // zone without a leading zero
  ///   print(mgrsGridSquare2.toText()); // '4Q FJ'
  ///
  ///   // zone with a leading zero
  ///   print(mgrsGridSquare2.toText(zeroPadZone: true)); // '04Q FJ'
  /// ```
  @override
  String toText({
    bool militaryStyle = false,
    bool zeroPadZone = false,
  }) {
    // ensure leading zeros on zone if `zeroPadZone` is set true
    final zPadded =
        zeroPadZone ? zone.toString().padLeft(2, '0') : zone.toString();

    return militaryStyle
        ? '$zPadded$band$column$row'
        : '$zPadded$band $column$row';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MgrsGridSquare &&
          zone == other.zone &&
          band == other.band &&
          column == other.column &&
          row == other.row);

  @override
  int get hashCode => Object.hash(zone, band, column, row);
}

/// {@template geobase.geodesy.mgrs.about}
///
/// Military Grid Reference System (MGRS/NATO) grid references, with methods to
/// parse references, and to convert between MGRS references and UTM
/// coordinates.
///
/// MGRS grid references provide geocoordinate references covering the entire
/// globe, based on the UTM projection.
///
/// MGRS grid references comprise a grid zone designator (GZD) like `31U` (see
/// [MgrsGridZone]), a 100km square identification like `DQ` (see
/// [MgrsGridSquare]), and an easting and northing (in metres); e.g.
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
  /// The 100km grid square identified by a grid zone designator (GZD) and a
  /// 100km square identification.
  final MgrsGridSquare gridSquare;

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

  /// Creates a MGRS grid reference with [zone], [band], [column], [row],
  /// [easting], [northing] based on the [datum] (used in the UTM projection).
  ///
  /// {@macro geobase.geodesy.utm.zone}
  ///
  /// {@macro geobase.geodesy.mgrs.band}
  ///
  /// {@macro geobase.geodesy.mgrs.column}
  ///
  /// {@macro geobase.geodesy.mgrs.row}
  ///
  /// {@macro geobase.geodesy.mgrs.easting}
  ///
  /// {@macro geobase.geodesy.mgrs.northing}
  ///
  /// {@macro geobase.geodesy.utm.datum}
  ///
  /// Throws a [FormatException] if MGRS zone, band, column, row, easting or
  /// northing is invalid.
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
    String column,
    String row,
    int easting,
    int northing, {
    Datum datum = Datum.WGS84,
  }) {
    // create 100 km grid square, validating zone, band and 100km grid square
    // letters (column + row)
    final gridSquare = MgrsGridSquare(
      zone,
      band,
      column, // e100k
      row, // n100k
    );

    // validate easting and northing
    final errors = <String>[];
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
      gridSquare,
      easting,
      northing,
      datum: datum,
    );
  }

  const Mgrs._coordinates(
    this.gridSquare,
    this.easting,
    this.northing, {
    required this.datum,
  });

  /// Parses a MGRS grid reference from a text string like '31U DQ 48251 11932'.
  ///
  /// The input text should contains following elements:
  /// * grid zone designator (GZD), e.g. ‘31U’, where zone is 1-60 and band is
  ///   C..X covering 80°S..84°N
  /// * 100km grid square letter-pair, e.g. ‘DQ’, where each letter represents
  ///   100km grid square column (‘e’) and row (‘n’) respectively
  /// * easting, e.g. ‘48251’ (metres)
  /// * northing, e.g. ‘11932’ (metres)
  ///
  /// {@macro geobase.geodesy.utm.datum}
  ///
  /// Throws FormatException if coordinates are invalid.
  ///
  /// Examples:
  /// ```dart
  ///   // The MGRS grid reference parsed from text (same as using the default
  ///   // constructor `Mgrs(31, 'U', 'D', 'Q', 48251, 11932)`).
  ///   final mgrsRef = Mgrs.parse('31U DQ 48251 11932');
  ///
  ///   // Military style without separators.
  ///   final mgrsRefMil = Mgrs.parse('31UDQ4825111932');
  /// ```
  factory Mgrs.parse(
    String text, {
    Datum datum = Datum.WGS84,
  }) {
    // this shall contain: [ gzd, en100k, easting, northing ]
    List<String>? ref;

    // check for military-style grid reference with no separators
    final trimmed = text.trim();
    if (trimmed.length >= 6 && RegExp(r'\s+').allMatches(trimmed).isEmpty) {
      // no whitespace found and at least 6 characters, should contain also
      //easting and northing

      // convert mgrsGridRef to standard space-separated format
      final exp =
          RegExp(r'(\d\d?[A-Z])([A-Z]{2})([0-9]{2,10})', caseSensitive: false)
              .allMatches(text)
              .map((m) => m.groups([1, 2, 3]));
      if (exp.isEmpty) {
        throw FormatException('invalid MGRS grid reference `$text`');
      }
      final parsed = exp.first;

      final gzd = parsed[0]!;
      final en100k = parsed[1]!;
      final en = parsed[2]!;
      final easting = en.substring(0, en.length ~/ 2);
      final northing = en.substring(en.length ~/ 2);

      ref = [gzd, en100k, easting, northing];
    }

    // if ref still null then match separate elements (separated by whitespace)
    // the result should contain: [ gzd, en100k, easting, northing ]
    ref ??= trimmed.split(RegExp(r'\s+'));

    // check for 4 elements in MGRS grid reference
    if (ref.length != 4) {
      throw FormatException('invalid MGRS grid reference `$text`');
    }

    // split grid ref into gzd, en100k, e, n
    final gzd = ref[0];
    final en100k = ref[1];
    final e = ref[2];
    final n = ref[3];
    if (!(gzd.length == 2 || gzd.length == 3) || en100k.length != 2) {
      throw FormatException('invalid MGRS grid reference `$text`');
    }

    // split gzd into zone (one or two digits), band (one letter)
    final gzdLen = gzd.length;
    final zone = int.parse(gzd.substring(0, gzdLen - 1));
    final band = gzd.substring(gzdLen - 1, gzdLen);

    // split 100km letter-pair into column and row letters
    final column = en100k[0];
    final row = en100k[1];

    final easting = _parseCoordinate(e);
    final northing = _parseCoordinate(n);

    // use the default constructor as it also validates the coordinates (and
    // constructs also a MgrsGridSquare object)
    return Mgrs(
      zone,
      band,
      column,
      row,
      easting,
      northing,
      datum: datum,
    );
  }

  /// Creates a MGRS grid reference from projected UTM coordinates.
  ///
  /// May throw a FormatException if conversion fails.
  ///
  /// Examples:
  ///
  /// ```dart
  ///   final utmCoord = Utm(31, 'N', 448251, 5411932);
  ///   final mgrsRef = Mgrs.fromUtm(utmCoord); // 31U DQ 48251 11932
  /// ```
  factory Mgrs.fromUtm(Utm utm) {
    // MGRS zone is same as UTM zone
    final zone = utm.zone;

    // convert UTM to lat/long to get latitude to determine band
    final latlong = utm.toGeographic();
    // grid zones are 8° tall, 0°N is 10th band
    final band = _latBands[(latlong.lat / 8 + 10)
        .floor()
        .clamp(0, _latBands.length - 1)]; // latitude band

    // columns in zone 1 are A-H, zone 2 J-R, zone 3 S-Z, then repeating every
    // 3rd zone
    final col = (utm.easting / 100000).floor();
    // (note -1 because eastings start at 166e3 due to 500km false origin)
    final e100k = _columnLetters[(zone - 1) % 3][col - 1];

    // rows in even zones are A-V, in odd zones are F-E
    final row = (utm.northing / 100000).floor() % 20;
    final n100k = _rowLetters[(zone - 1) % 2][row];

    // truncate easting/northing to within 100km grid square & round to 1-metre
    // precision
    final easting = (utm.easting % 100000).floor();
    final northing = (utm.northing % 100000).floor();

    return Mgrs(
      zone,
      band,
      e100k,
      n100k,
      easting,
      northing,
      datum: utm.datum,
    );
  }

  /// Converts this MGRS grid reference to the UTM projected coordinates.
  ///
  /// Grid references refer to squares rather than points (with the size of the
  /// square indicated by the precision of the reference); this conversion will
  /// return the UTM coordinate of the SW corner of the grid reference square.
  ///
  /// Returns the UTM coordinate of the SW corner of this MGRS grid reference.
  ///
  /// Examples:
  ///
  /// ```dart
  ///   final mgrsRef = Mgrs.parse('31U DQ 48251 11932');
  ///   final utmCoord = mgrsRef.toUtm(); // 31 N 448251 5411932
  /// ```
  Utm toUtm() {
    final zone = gridSquare.zone;
    final isNorth =
        _latBands.indexOf(gridSquare.band) >= _latBands.indexOf('N');
    final hemisphere = isNorth ? 'N' : 'S';

    // get easting specified by e100k (note +1 because eastings start at 166e3
    // due to 500km false origin)
    final col = _columnLetters[(zone - 1) % 3].indexOf(gridSquare.column) + 1;
    final e100kNum = col * 100000; // e100k in metres

    // get northing specified by n100k
    final row = _rowLetters[(zone - 1) % 2].indexOf(gridSquare.row);
    final n100kNum = row * 100000; // n100k in metres

    // latitude of (bottom of) band, 10 bands above the equator, 8°latitude each
    final latBand = (_latBands.indexOf(gridSquare.band) - 10) * 8;

    // get southern-most northing of bottom of band, using floor() to extend to
    // include entirety of bottom-most 100km square - note in northern
    // hemisphere, centre of zone will be furthest south; in southern hemisphere
    // extremity of zone will be furthest south, so use 3°E / 0°E
    final position = Utm.fromGeographic(
      Geographic(
        lat: latBand.toDouble(),
        lon: isNorth ? 3.0 : 0.0,
      ),
      datum: datum,
      roundResults: false,
    );
    final nBand = (position.northing / 100000.0).floor() * 100000;

    // 100km grid square row letters repeat every 2,000km north; add enough
    // 2,000km blocks to get into required band
    var n2M = 0; // northing of 2,000km block
    while (n2M + n100kNum + northing < nBand) {
      n2M += 2000000;
    }

    return Utm(
      gridSquare.zone,
      hemisphere,
      (e100kNum + easting).toDouble(),
      (n2M + n100kNum + northing).toDouble(),
      datum: datum,
    );
  }

  /// The MGRS grid reference string representation with components separated by
  /// whitespace by default.
  ///
  /// {@template geobase.geodesy.mgrs.distinquishFromUTM}
  ///
  /// To distinguish from civilian UTM coordinate representations, no space is
  /// included within the zone/band grid zone designator.
  ///
  /// {@endtemplate}
  ///
  /// {@template geobase.geodesy.mgrs.militaryStyle}
  ///
  /// Components are separated by spaces by default. For a military-style
  /// unseparated string set [militaryStyle] to true.
  ///
  /// {@endtemplate}
  ///
  /// {@template geobase.geodesy.mgrs.zoneLeadingZero}
  ///
  /// If [zeroPadZone] is true, then all zone numbers (1..60) are formatted with
  /// two digits, e.g. `31` or `04`. By default only significant digits are
  /// formatted, e.g. `31` or `4`.
  ///
  /// {@endtemplate}
  ///
  /// Note that MGRS grid references get truncated, not rounded (unlike UTM
  /// coordinates); grid references indicate a bounding square, rather than a
  /// point, with the size of the square indicated by the precision - a
  /// precision of 10 indicates a 1-metre square, a precision of 4 indicates
  /// a 1,000-metre square (hence 31U DQ 48 11 indicates a 1km square with SW
  /// corner at 31 N 448000 5411000, which would include the 1m square
  /// 31U DQ 48251 11932).
  ///
  /// Examples:
  ///
  /// ```dart
  ///   // a sample MGRS reference `31U DQ 48251 11932`
  ///   final mgrsRef = Mgrs(31, 'U', 'D', 'Q', 48251, 11932);
  ///
  ///   // 10 digits, the precision level 1 m
  ///   print(mgrsRef.toText()); // '31U DQ 48251 11932'
  ///
  ///   // 8 digits, the precision level 10 m
  ///   print(mgrsRef.toText(digits: 8)); // '31U DQ 4825 1193'
  ///
  ///   // 4 digits, the precision level 1 km
  ///   print(mgrsRef.toText(digits: 4)); // '31U DQ 48 11'
  ///
  ///   // 4 digits, the precision level 1 km, military style
  ///   print(mgrsRef.toText(digits: 4, militaryStyle: true)); // '31UDQ4811'
  ///
  ///   // another sample `4Q FJ 02345 07890`
  ///   final mgrsRef2 = Mgrs.parse('4Q FJ 02345 07890');
  ///
  ///   // zone without a leading zero, 10 digits
  ///   print(mgrsRef2.toText()); // '4Q FJ 02345 07890'
  ///
  ///   // zone with a leading zero, 10 digits
  ///   print(mgrsRef2.toText(zeroPadZone: true)); // '04Q FJ 02345 07890'
  /// ```
  String toText({
    int digits = 10,
    bool militaryStyle = false,
    bool zeroPadZone = false,
  }) {
    if (!(digits == 2 ||
        digits == 4 ||
        digits == 6 ||
        digits == 8 ||
        digits == 10)) {
      throw FormatException('invalid precision `$digits`');
    }

    final zone = gridSquare.zone;
    final band = gridSquare.band;
    final column = gridSquare.column;
    final row = gridSquare.row;

    // truncate to required precision
    final digitsPer2 = digits ~/ 2;
    final eRounded =
        digitsPer2 == 5 ? easting : (easting / pow(10, 5 - digitsPer2)).floor();
    final nRounded = digitsPer2 == 5
        ? northing
        : (northing / pow(10, 5 - digitsPer2)).floor();

    // ensure leading zeros on zone if `zeroPadZone` is set true
    final zPadded =
        zeroPadZone ? zone.toString().padLeft(2, '0') : zone.toString();

    // ensure leading zeros on easting and northing when needed
    final ePadded = eRounded.toString().padLeft(digitsPer2, '0');
    final nPadded = nRounded.toString().padLeft(digitsPer2, '0');

    return militaryStyle
        ? '$zPadded$band$column$row$ePadded$nPadded'
        : '$zPadded$band $column$row $ePadded $nPadded';
  }

  @override
  String toString() => toText();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mgrs &&
          gridSquare == other.gridSquare &&
          easting == other.easting &&
          northing == other.northing &&
          datum == other.datum);

  @override
  int get hashCode => Object.hash(gridSquare, easting, northing, datum);
}

int _parseCoordinate(String text) {
  // decimal point allowed only if at least 5 digits before it
  final index = text.indexOf('.');
  if ((index != -1 && index < 5) || text.startsWith('-')) {
    throw FormatException('invalid MGRS coordinate `$text`');
  }

  // standardise to 10-digit refs - ie metres) (but only if < 10-digit refs,
  // to allow decimals)
  final padded = text.length >= 5 ? text : text.padRight(5, '0');

  // parse and truncate to integer
  final coord = int.tryParse(padded) ?? double.tryParse(padded)?.floor();
  if (coord == null || coord < 0 || coord > 99999) {
    throw FormatException('invalid MGRS coordinate `$text`');
  }
  return coord;
}
