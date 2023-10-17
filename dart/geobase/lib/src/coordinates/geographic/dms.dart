/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Geodesy representation conversion functions                        (c) Chris Veness 2002-2020  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong.html                                                    */
/* www.movable-type.co.uk/scripts/js/geodesy/geodesy-library.html#dms                             */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// ignore_for_file: lines_longer_than_80_chars, prefer_const_declarations

// Spherical geodesy tools (see license above) by Chris Veness ported to Dart
// by Navibyte.
//
// Source:
// https://github.com/chrisveness/geodesy/blob/master/dms.js
//
// Latitude/longitude points may be represented as decimal degrees, or
// subdivided into sexagesimal minutes and seconds. This module provides methods
// for parsing and representing degrees / minutes / seconds.

// Adaptations on the derivative work (the Dart port):
//
// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// Standard representation of geographic point location by coordinates:
// * [ISO 6709](https://en.wikipedia.org/wiki/ISO_6709) on Wikipedia
// * [ISO 6709:2022](https://www.iso.org/standard/75147.html)

import 'dart:math';

import '/src/codes/cardinal_precision.dart';
import '/src/codes/dms_type.dart';
import '/src/coordinates/base/position_functions.dart';

import 'geographic_functions.dart';

/// A base class for formatters with methods for parsing and formatting
/// degrees/minutes/seconds on latitude, longitude and bearing values.
///
/// Sub classes must implement [parse], [write], [writeLat], [writeLon],
/// and [writeBearing]. Such classes could configure parsing and formatting
/// parameters as they like.
///
/// This base class provides default implementations for [tryParse],
/// [format], [lat], [lon], [bearing], and [compassPoint].
abstract class DmsFormat {
  /// Default `const` constructor to allow extending this abstract class.
  const DmsFormat();

  /// Parses a string [dms] representing degrees/minutes/seconds into a numeric
  /// degree value (ie. latitude, longitude or bearing).
  ///
  /// Throws [FormatException] if numeric degrees cannot be parsed.
  double parse(String dms);

  /// Parses a string [dms] representing degrees/minutes/seconds into a numeric
  /// degree value (ie. latitude, longitude or bearing).
  ///
  /// Returns null if numeric degrees cannot be parsed.
  double? tryParse(String dms) {
    try {
      return parse(dms);
    } catch (_) {
      return null;
    }
  }

  /// Converts the degree value [deg] to a String representation (deg/min/sec).
  ///
  /// Parameters:
  /// * [deg]: The degree value (ie. latitude, longitude or bearing) to be formatted as specified.
  /// * [twoDigitDeg]: If true degrees are considered to have two digits (like in normalized latitude) otherwise three digits is considered.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  String format(double deg, {bool twoDigitDeg = false}) {
    final buf = StringBuffer();
    write(buf, deg, twoDigitDeg: twoDigitDeg);
    return buf.toString();
  }

  /// Writes the degree value [deg] as a String representation (deg/min/sec) to
  /// [buf].
  ///
  /// Parameters:
  /// * [deg]: The degree value (ie. latitude, longitude or bearing) to be formatted as specified.
  /// * [twoDigitDeg]: If true degrees are considered to have two digits (like in normalized latitude) otherwise three digits is considered.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  ///
  /// See also [format] for documentation.
  void write(StringSink buf, double deg, {bool twoDigitDeg = false});

  /// Converts a degree value [deg] to a String representation (deg/min/sec) of
  /// the latitude.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  String lat(double deg) {
    final buf = StringBuffer();
    writeLat(buf, deg);
    return buf.toString();
  }

  /// Writes a degree value [deg] as a String representation (deg/min/sec) of
  /// the latitude to [buf].
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  ///
  /// See also [lat] for documentation.
  void writeLat(StringSink buf, double deg);

  /// Converts a degree value [deg] to a String representation (deg/min/sec) of
  /// the longitude.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  String lon(double deg) {
    final buf = StringBuffer();
    writeLon(buf, deg);
    return buf.toString();
  }

  /// Writes a degree value [deg] as a String representation (deg/min/sec) of
  /// the longitude to [buf].
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  ///
  /// See also [lon] for documentation.
  void writeLon(StringSink buf, double deg);

  /// Converts a degree value [deg] to a String representation (deg/min/sec) of
  /// the bearing.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  String bearing(double deg) {
    final buf = StringBuffer();
    writeBearing(buf, deg);
    return buf.toString();
  }

  /// Writes a degree value [deg] as a String representation (deg/min/sec) of
  /// the bearing to [buf].
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  ///
  /// See also [bearing] for documentation.
  void writeBearing(StringSink buf, double deg);

  /// Returns the compass point for [bearing] on the given [precision].
  ///
  /// Parameters:
  /// * [bearing]: The bearing in degrees from north (0°..360°).
  /// * [precision]: The precision with three allowed values (1: cardinal, 2: intercardinal, 3: secondary-intercardinal).
  ///
  /// Examples:
  /// ```dart
  ///   compassPoint(24.0);                                        // 'NNE'
  ///   compassPoint(24.0, precision: CardinalPrecision.cardinal); // 'N'
  /// ```
  String compassPoint(
    double bearing, {
    CardinalPrecision precision = CardinalPrecision.secondaryIntercardinal,
  }) {
    // NOTE: precision could be extended to 4 for quarter-winds (eg NbNW).
    // (but they are little used)

    // normalize to range 0..360°
    final normalized = bearing.wrap360();

    // number of compass points at requested precision (1 => 4, 2 => 8, 3 => 16)
    final n = 4 * pow(2, precision.value - 1);

    // get compass point
    const cardinals = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW',
      'W', 'WNW', 'NW', 'NNW',
      //
    ];
    return cardinals[(normalized * n / 360.0).round() % n * 16 ~/ n];
  }
}

final _regExpMinus = RegExp('^-');
final _regExpNSEW = RegExp(r'[NSEW]$', caseSensitive: false);
final _regExpSplitter = RegExp('[^0-9.,]+');
final _regExpMinusOrSW = RegExp(r'^-|[WS]$', caseSensitive: false);

/// A default implementation for [DmsFormat] abstract base class, that defines
/// methods for parsing and formatting degrees/minutes/seconds on latitude,
/// longitude and bearing values.
class Dms extends DmsFormat {
  final DmsType _type;
  final String _separator;
  final int? _decimals;
  final bool _signedDegrees;
  final bool _zeroPadDegrees;
  final bool _zeroPadMinSec;
  final String _degree;
  final String _prime;
  final String _doublePrime;

  /// Creates a new formatter for parsing and formatting degrees/minutes/seconds
  /// on latitude, longitude and bearing values.
  ///
  /// Parameters:
  /// * [type]: Specifies how return values are formatted (`deg`, `degMin` or `degMinSec`).
  /// * [separator]: The separator character to be used to separate degrees, minutes, seconds, and cardinal directions. By default there is no separator (see also the [Dms.narrowSpace] constructor).
  /// * [decimals]: Number of decimal places to use (default 4 for `deg`, 2 for `degMin`, 0 for `degMinSec`).
  /// * [signedDegrees]: If true then degree values are formatted with - symbol for negative values instead of W or S cardinal direction symbols.
  /// * [zeroPadDegrees]: If true then degree values are (left) zero-padded to 2 or 3 digits (before optional decimal part).
  /// * [zeroPadMinSec]: If true then min and sec values are (left) zero-padded to 2 digits (before optional decimal part).
  /// * [degree]: A degree symbol (or other text) to be formatted just after degrees.
  /// * [prime]: A prime symbol (or other text) to be formatted just after minutes.
  /// * [doublePrime]: A double prime symbol (or other text) to be formatted just after seconds.
  const Dms({
    DmsType type = DmsType.deg,
    String separator = '', // by default no separator
    int? decimals,
    bool signedDegrees = false,
    bool zeroPadDegrees = false,
    bool zeroPadMinSec = true,
    String degree = '°', // Unicode Degree = U+00B0
    String prime = '′', // Unicode Prime = U+2032,
    String doublePrime = '″', //  Unicode Double prime = U+2033
  })  : _type = type,
        _separator = separator,
        _decimals = decimals,
        _signedDegrees = signedDegrees,
        _zeroPadDegrees = zeroPadDegrees,
        _zeroPadMinSec = zeroPadMinSec,
        _degree = degree,
        _prime = prime,
        _doublePrime = doublePrime;

  /// Creates a new formatter for parsing and formatting degrees/minutes/seconds
  /// on latitude, longitude and bearing.
  ///
  /// Uses Unicode U+202F ‘narrow no-break space’ as `separator` that is used to
  /// separate degrees, minutes, seconds, and cardinal directions.
  ///
  /// This constructor is logically the same as the default constructor `Dms()`
  /// but this has different default value for separating components.
  ///
  /// See documentation for parameters from the default constructor.
  const Dms.narrowSpace({
    DmsType type = DmsType.deg,
    int? decimals,
    bool signedDegrees = false,
    bool zeroPadDegrees = false,
    bool zeroPadMinSec = true,
    String degree = '°', // Unicode Degree = U+00B0
    String prime = '′', // Unicode Prime = U+2032,
    String doublePrime = '″', //  Unicode Double prime = U+2033
  })  : _type = type,
        _separator = '\u202f', // Unicode U+202F ‘narrow no-break space’.
        _decimals = decimals,
        _signedDegrees = signedDegrees,
        _zeroPadDegrees = zeroPadDegrees,
        _zeroPadMinSec = zeroPadMinSec,
        _degree = degree,
        _prime = prime,
        _doublePrime = doublePrime;

  /// Creates a new formatter for parsing and formatting degrees/minutes/seconds
  /// on latitude, longitude and bearing.
  ///
  /// See documentation for parameters from the default constructor.
  ///
  /// This constructor differs from the default constructor as:
  /// * The default [separator] (between degrees, minutes, and seconds) is Unicode U+202F ‘narrow no-break space’.
  /// * Symbols for `deegree`, `prime` and `doublePrime` are set empty.
  /// * Formatted numbers are always signed, no cardinal direction symbols are shown.
  const Dms.numeric({
    DmsType type = DmsType.deg,
    String separator = '\u202f', // Unicode U+202F ‘narrow no-break space’.
    int? decimals,
    bool zeroPadDegrees = false,
    bool zeroPadMinSec = true,
  })  : _type = type,
        _separator = separator,
        _decimals = decimals,
        _signedDegrees = true,
        _zeroPadDegrees = zeroPadDegrees,
        _zeroPadMinSec = zeroPadMinSec,
        _degree = '',
        _prime = '',
        _doublePrime = '';

  /// Copy a new formatter from this with given attributes changed.
  ///
  /// See documentation for parameters from the default constructor.
  Dms copyWith({
    DmsType? type,
    String? separator,
    int? decimals,
    bool? signedDegrees,
    bool? zeroPadDegrees,
    bool? zeroPadMinSec,
    String? degree,
    String? prime,
    String? doublePrime,
  }) =>
      Dms(
        type: type ?? _type,
        separator: separator ?? _separator,
        decimals: decimals ?? _decimals,
        signedDegrees: signedDegrees ?? _signedDegrees,
        zeroPadDegrees: zeroPadDegrees ?? _zeroPadDegrees,
        zeroPadMinSec: zeroPadMinSec ?? _zeroPadMinSec,
        degree: degree ?? _degree,
        prime: prime ?? _prime,
        doublePrime: doublePrime ?? _doublePrime,
      );

  /// Parses a string [dms] representing degrees/minutes/seconds into a numeric
  /// degree value (ie. latitude, longitude or bearing).
  ///
  /// This is very flexible on formats, allowing signed decimal degrees, or
  /// deg-min-sec optionally suffixed by compass direction (NSEW); a variety of
  /// separators are accepted.
  ///
  /// Examples '-3.62', '3 37 12W', '3°37′12″W'.
  ///
  /// Throws [FormatException] if numeric degrees cannot be parsed.
  ///
  /// Examples:
  /// ```dart
  ///   // 51.4779°N, 0.0015°W
  ///   final p1 = Geographic(lat: Dms().parse('51° 28′ 40.37″ N'),
  ///                         lon: Dms().parse('000° 00′ 05.29″ W'));
  /// ```
  @override
  double parse(String dms) {
    final dmsTrimmed = dms.trim();

    // check for signed decimal degrees without NSEW, if so return it directly
    var deg = double.tryParse(dmsTrimmed);
    if (deg != null) {
      return deg;
    }

    // strip off any sign or compass dir'n & split out separate d/m/s
    var dmsParts = dmsTrimmed
        .replaceAll(_regExpMinus, '')
        .replaceAll(_regExpNSEW, '')
        .split(_regExpSplitter);
    if (dmsParts[dmsParts.length - 1] == '') {
      dmsParts = dmsParts.sublist(0, dmsParts.length - 1); // before trailing
    }

    if (dmsParts.isEmpty) throw const FormatException('No dms parts.');

    // and convert to decimal degrees...
    deg = null;
    switch (dmsParts.length) {
      case 3: // interpret 3-part result as d/m/s
        deg = double.parse(dmsParts[0]) +
            double.parse(dmsParts[1]) / 60.0 +
            double.parse(dmsParts[2]) / 3600.0;
        break;
      case 2: // interpret 2-part result as d/m
        deg = double.parse(dmsParts[0]) + double.parse(dmsParts[1]) / 60.0;
        break;
      case 1: // just d (possibly decimal) (or non-separated dddmmss ??)
        deg = double.parse(dmsParts[0]);

        // check for fixed-width unseparated format eg 0033709W
        //if (/[NS]/i.test(dmsParts)) deg = '0' + deg;  // - normalise N/S to 3-digit degrees
        //if (/[0-9]{7}/.test(deg)) deg = deg.slice(0,3)/1 + deg.slice(3,5)/60 + deg.slice(5)/3600;
        break;
      default:
        throw const FormatException('Could not parse');
    }

    if (_regExpMinusOrSW.hasMatch(dmsTrimmed)) {
      // take '-', west and south as -ve
      deg = -deg;
    }

    return deg;
  }

  /// Converts the degree value [deg] to a String representation (deg/min/sec)
  /// according to the specified `type`.
  ///
  /// For returned values:
  /// * Degree, prime, double-prime symbols are added (see also parameters `degree`, `prime` and `doublePrime`).
  /// * The sign symbol is discarded (if `signedDegrees` is false).
  /// * No compass direction is added.
  /// * Degree values are zero-padded to 2 or 3 digits (if `zeroPadDegrees` is true).
  ///
  /// Parameters:
  /// * [deg]: The degree value (ie. latitude, longitude or bearing) to be formatted as specified.
  /// * [twoDigitDeg]: If true degrees are considered to have two digits (like in normalized latitude) otherwise three digits is considered.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  ///
  /// Examples:
  /// ```dart
  ///   // 3° 37′ 12″
  ///   final dms = Dms.narrowSpace(type: DmsType.degMinSec);
  ///   final narrow = dms.format(-3.62);
  ///
  ///   // -3°37.20′
  ///   final dm = Dms(type: DmsType.degMin, signedDegrees: true);
  ///   final signed = dm.format(-3.62);
  ///
  ///   // 3.6200°
  ///   final decimal = Dms().formatDms(-3.62);
  /// ```
  @override
  String format(double deg, {bool twoDigitDeg = false});

  @override
  void write(StringSink buf, double deg, {bool twoDigitDeg = false}) {
    if (deg.isNaN || deg.isInfinite) {
      throw const FormatException('Invalid value');
    }

    // decimal points
    final int dp;
    if (_decimals != null) {
      dp = _decimals!;
    } else {
      switch (_type) {
        case DmsType.deg:
          dp = 4;
          break;
        case DmsType.degMin:
          dp = 2;
          break;
        case DmsType.degMinSec:
          dp = 0;
          break;
      }
    }

    // (unsigned result ready for appending compass dir'n)
    final degAbs = deg.abs();

    // write sign if needed
    if (_signedDegrees && deg < 0.0) {
      buf.write('-');
    }

    switch (_type) {
      case DmsType.deg:
        final ds = degAbs.toStringAsFixed(dp);
        if (_zeroPadDegrees) {
          if (degAbs < 10.0 && !ds.startsWith('10')) {
            buf.write(twoDigitDeg ? '0' : '00');
          } else if (!twoDigitDeg && degAbs < 100.0 && !ds.startsWith('100')) {
            buf.write('0');
          }
        }
        buf
          ..write(ds)
          ..write(_degree);
        break;
      case DmsType.degMin:
        // get component deg
        var d = degAbs.floor();
        // get component min & round/right-pad
        var m = (degAbs * 60.0) % 60;
        var ms = m.toStringAsFixed(dp);
        // check for rounding up
        if (ms.startsWith('60')) {
          m = 0.0;
          ms = m.toStringAsFixed(dp);
          d++;
        }
        // (optionally) left-pad with leading zeros
        final ds = _zeroPadDegrees
            ? d.toString().padLeft(twoDigitDeg ? 2 : 3, '0')
            : d.toString();
        // write degrees
        buf
          ..write(ds)
          ..write(_degree)
          ..write(_separator);
        // (optionally) left-pad with leading zeros (note may include decimals)
        if (_zeroPadMinSec && m < 10 && !ms.startsWith('10')) {
          buf.write('0');
        }
        // write minutes
        buf
          ..write(ms)
          ..write(_prime);
        break;
      case DmsType.degMinSec:
        // get component deg
        var d = degAbs.floor();
        // get component min
        var m = ((degAbs * 3600.0) / 60.0).floor() % 60;
        // get component sec & round/right-pad
        var s = degAbs * 3600.0 % 60;
        var ss = s.toStringAsFixed(dp);
        // check for rounding up
        if (ss.startsWith('60')) {
          s = 0.0;
          ss = s.toStringAsFixed(dp);
          m++;
        }
        if (m == 60) {
          m = 0;
          d++;
        }
        // (optionally) left-pad with leading zeros
        final ds = _zeroPadDegrees
            ? d.toString().padLeft(twoDigitDeg ? 2 : 3, '0')
            : d.toString();
        final ms = _zeroPadMinSec ? m.toString().padLeft(2, '0') : m.toString();
        // write degrees and minutes
        buf
          ..write(ds)
          ..write(_degree)
          ..write(_separator)
          ..write(ms)
          ..write(_prime)
          ..write(_separator);
        // (optionally) left-pad with leading zeros (note may include decimals)
        if (_zeroPadMinSec && s < 10.0 && !ss.startsWith('10')) {
          buf.write('0');
        }
        // write seconds
        buf
          ..write(ss)
          ..write(_doublePrime);
        break;
    }
  }

  /// Converts a degree value [deg] to a String representation (deg/min/sec) of
  /// the latitude (2-digit degrees, suffixed with N/S) according to the
  /// specified `type`.
  ///
  /// For returned values:
  /// * The latitude value is normalized to the range [90° S .. 90° N]
  /// * Degree, prime, double-prime symbols are added (see also parameters `degree`, `prime` and `doublePrime`).
  /// * Compass direction is added (if `signedDegrees` is false).
  /// * Degree values are zero-padded to 2 digits (if `zeroPadDegrees` is true).
  ///
  /// Parameters:
  /// * [deg]: The degree value of latitude to be formatted as specified.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  ///
  /// Examples:
  /// ```dart
  ///   // 3° 37′ 12″ S
  ///   final latDms = Dms.narrowSpace(type: DmsType.degMinSec).lat(-3.62);
  ///
  ///   // 3°37.20′S
  ///   final latDm = Dms(type: DmsType.degMin).lat(-3.62);
  ///
  ///   // 3.6200°S
  ///   final latD = Dms().lat(-3.62);
  /// ```
  @override
  String lat(double deg);

  @override
  void writeLat(StringSink buf, double deg) {
    final normalized = deg.wrapLatitude();
    write(buf, normalized, twoDigitDeg: true);
    if (!_signedDegrees) {
      buf
        ..write(_separator)
        ..write(normalized < 0.0 ? 'S' : 'N');
    }
  }

  /// Converts a degree value [deg] to a String representation (deg/min/sec) of
  /// the longitude (3-digit degrees, suffixed with E/W) according to the
  /// specified `type`.
  ///
  /// For returned values:
  /// * The longitude value is normalized to the range [180° W .. 180° E[
  /// * Degree, prime, double-prime symbols are added (see also parameters `degree`, `prime` and `doublePrime`).
  /// * Compass direction is added (if `signedDegrees` is false).
  /// * Degree values are zero-padded to 3 digits (if `zeroPadDegrees` is true).
  ///
  /// Parameters:
  /// * [deg]: The degree value of longitude to be formatted as specified.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  ///
  /// Examples:
  /// ```dart
  ///   // 3° 37′ 12″ W
  ///   final lonDms = Dms.narrowSpace(type: DmsType.degMinSec).lon(-3.62);
  ///
  ///   // 3°37.20′W
  ///   final lonDm = Dms(type: DmsType.degMin).lon(-3.62);
  ///
  ///   // 3.6200°W
  ///   final lonD = Dms().lon(-3.62);
  /// ```
  @override
  String lon(double deg);

  @override
  void writeLon(StringSink buf, double deg) {
    final normalized = deg.wrapLongitude();
    write(buf, normalized);
    if (!_signedDegrees) {
      buf
        ..write(_separator)
        ..write(normalized < 0.0 ? 'W' : 'E');
    }
  }

  /// Converts a degree value [deg] to a String representation (deg/min/sec) of
  /// the bearing (3-digit degrees, 0°..360°) according to the specified `type`.
  ///
  /// For returned values:
  /// * The bearing value is normalized to the range [0°..360°[
  /// * Degree, prime, double-prime symbols are added (see also parameters `degree`, `prime` and `doublePrime`).
  /// * Degree values are zero-padded to 3 digits (if `zeroPadDegrees` is true).
  ///
  /// Parameters:
  /// * [deg]: The degree value of bearing to be formatted as specified.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  ///
  /// Examples:
  /// ```dart
  ///   // 356° 22′ 48″
  ///   final brngDms = Dms.narrowSpace(type: DmsType.degMinSec).bearing(-3.62);
  ///
  ///   // 356°22.80′
  ///   final brngDm = Dms(type: DmsType.degMin).bearing(-3.62);
  ///
  ///   // 356.3800°
  ///   final brngD = Dms().bearing(-3.62);
  /// ```
  @override
  String bearing(double deg);

  @override
  void writeBearing(StringSink buf, double deg) {
    final normalized = deg.wrap360();
    final brng = format(normalized);
    if (brng.startsWith('360')) {
      // just in case rounding took us up to 360°!
      if (_zeroPadDegrees) {
        buf.write(brng.replaceRange(0, 3, '000'));
      } else {
        buf
          ..write('0')
          ..write(brng.substring(3));
      }
    } else {
      buf.write(brng);
    }
  }
}
