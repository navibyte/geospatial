/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Geodesy representation conversion functions                        (c) Chris Veness 2002-2020  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong.html                                                    */
/* www.movable-type.co.uk/scripts/js/geodesy/geodesy-library.html#dms                             */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// ignore_for_file: lines_longer_than_80_chars, prefer_const_declarations

// Dart port of spherical geodesy tools by Chris Veness, see license above.
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

import 'dart:math';

import '/src/codes/cardinal_precision.dart';

import 'geographic_functions.dart';

final _regExpMinus = RegExp('^-');
final _regExpNSEW = RegExp(r'[NSEW]$', caseSensitive: false);
final _regExpSplitter = RegExp('[^0-9.,]+');
final _regExpMinusOrSW = RegExp(r'^-|[WS]$', caseSensitive: false);

/// A base class for formatters with methods for parsing and formatting
/// degrees/minutes/seconds on latitude, longitude and bearing values.
///
/// Sub classes must implement [parseDeg], [lat], [lon] and [bearing].
/// Such classes could configure parsing and formatting parameters as they like.
///
/// This base class provides a default implementation for [compassPoint] and
/// [tryParseDeg].
abstract class DmsFormat {
  /// Default `const` constructor to allow extending this abstract class.
  const DmsFormat();

  /// Parses a string [dms] representing degrees/minutes/seconds into a numeric
  /// degree value (ie. latitude, longitude or bearing).
  ///
  /// Throws [FormatException] if numeric degrees cannot be parsed.
  double parseDeg(String dms);

  /// Parses a string [dms] representing degrees/minutes/seconds into a numeric
  /// degree value (ie. latitude, longitude or bearing).
  ///
  /// Returns null if numeric degrees cannot be parsed.
  double? tryParseDeg(String dms) {
    try {
      return parseDeg(dms);
    } catch (_) {
      return null;
    }
  }

  /// Converts a degree value [deg] to a String representation (deg/min/sec) of
  /// the latitude.
  String lat(double deg);

  /// Converts a degree value [deg] to a String representation (deg/min/sec) of
  /// the longitude.
  String lon(double deg);

  /// Converts a degree value [deg] to a String representation (deg/min/sec) of
  /// the bearing.
  String bearing(double deg);

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

/// An enum for degrees/minutes/seconds formatting types used by [Dms]
/// implementation of [DmsFormat].
enum DmsType {
  /// Format a degree value as decimal degrees, ie. '003.6200° W'.
  d,

  /// Format a degree value using the "degrees/minutes" pattern, ie.
  /// '003° 37.20′ W'.
  dm,

  /// Format a degree value using the "degrees/minutes/seconds" pattern, ie.
  /// '003° 37′ 12″ W'.
  dms
}

/// A default implementation for [DmsFormat] abstract base class, that defines
/// methods for parsing and formatting degrees/minutes/seconds on latitude,
/// longitude and bearing values.
class Dms extends DmsFormat {
  final DmsType _type;
  final String _separator;
  final int? _decimals;
  final bool _zeroPadDegrees;
  final bool _zeroPadMinSec;

  /// Creates a new formatter for parsing and formatting degrees/minutes/seconds
  /// on latitude, longitude and bearing values.
  ///
  /// Parameters:
  /// * [type]: Specifies how return values are formatted (`d`, `dm` or `dms`).
  /// * [separator]: The separator character to be used to separate degrees, minutes, seconds, and cardinal directions. The default separator is U+202F ‘narrow no-break space’.
  /// * [decimals]: Number of decimal places to use (default 4 for `d`, 2 for `dm`, 0 for `dms`).
  /// * [zeroPadDegrees]: If true then degree values are (left) zero-padded to 2 or 3 digits (before optional decimal part).
  /// * [zeroPadMinSec]: If true then min and sec values are (left) zero-padded to 2 digits (before optional decimal part).
  const Dms({
    DmsType type = DmsType.dms,
    String separator = '\u202f',
    int? decimals,
    bool zeroPadDegrees = false,
    bool zeroPadMinSec = true,
  })  : _type = type,
        _separator = separator,
        _decimals = decimals,
        _zeroPadDegrees = zeroPadDegrees,
        _zeroPadMinSec = zeroPadMinSec;

  // note: Unicode Degree = U+00B0. Prime = U+2032, Double prime = U+2033

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
  ///   final p1 = Geographic(lat: Dms().parseDeg('51° 28′ 40.37″ N'),
  ///                         lon: Dms().parseDeg('000° 00′ 05.29″ W'));
  /// ```
  @override
  double parseDeg(String dms) {
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

  /// Converts the degree value of [deg] to a String representation
  /// (deg/min/sec) according to the specified [_type].
  ///
  /// For returned values:
  /// * Degree, prime, double-prime symbols are added.
  /// * The sign symbol is discarded.
  /// * No compass direction is added.
  /// * Degree values are zero-padded to 3 digits (if `zeroPadDegrees` is true).
  ///
  /// Parameters:
  /// * [deg]: The degree value (ie. latitude, longitude or bearing) to be formatted as specified.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  ///
  /// Examples:
  /// ```dart
  ///   final formatted = Dms().formatDms(-3.62); // 3° 37′ 12″
  /// ```
  String formatDms(double deg) {
    if (deg.isNaN || deg.isInfinite) {
      throw const FormatException('Invalid value');
    }

    // decimal points
    final int dp;
    if (_decimals != null) {
      dp = _decimals!;
    } else {
      switch (_type) {
        case DmsType.d:
          dp = 4;
          break;
        case DmsType.dm:
          dp = 2;
          break;
        case DmsType.dms:
          dp = 0;
          break;
      }
    }

    // (unsigned result ready for appending compass dir'n)
    final degAbs = deg.abs();

    switch (_type) {
      case DmsType.d:
        final ds = degAbs.toStringAsFixed(dp);
        if (_zeroPadDegrees) {
          if (degAbs < 10.0 && !ds.startsWith('10')) {
            return '00$ds°';
          } else if (degAbs < 100.0 && !ds.startsWith('100')) {
            return '0$ds°';
          }
        }
        return '$ds°';
      case DmsType.dm:
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
        final ds =
            _zeroPadDegrees ? d.toString().padLeft(3, '0') : d.toString();
        // (optionally) left-pad with leading zeros (note may include decimals) & result
        if (_zeroPadMinSec && m < 10 && !ms.startsWith('10')) {
          return '$ds°${_separator}0$ms′';
        } else {
          return '$ds°$_separator$ms′';
        }
      case DmsType.dms:
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
        final ds =
            _zeroPadDegrees ? d.toString().padLeft(3, '0') : d.toString();
        final ms = _zeroPadMinSec ? m.toString().padLeft(2, '0') : m.toString();
        // (optionally) left-pad with leading zeros (note may include decimals) & result
        if (_zeroPadMinSec && s < 10.0 && !ss.startsWith('10')) {
          return '$ds°$_separator$ms′${_separator}0$ss″';
        } else {
          return '$ds°$_separator$ms′$_separator$ss″';
        }
    }
  }

  /// Converts a degree value [deg] to a String representation (deg/min/sec) of
  /// the latitude (2-digit degrees, suffixed with N/S) according to the
  /// specified [_type].
  ///
  /// For returned values:
  /// * The latitude value is normalized to the range [90° S .. 90° N]
  /// * Degree, prime, double-prime symbols are added.
  /// * Compass direction is added.
  /// * Degree values are zero-padded to 2 digits (if `zeroPadDegrees` is true).
  ///
  /// Parameters:
  /// * [deg]: The degree value of latitude to be formatted as specified.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  ///
  /// Examples:
  /// ```dart
  ///   final latDms = Dms().latitude(-3.62); // 3° 37′ 12″ S
  ///   final latDm = Dms(type: DmsType.dm).latitude(-3.62); // 3° 37.20′ S
  ///   final latD = Dms(type: DmsType.d)).latitude(-3.62); // 3.6200° S
  /// ```
  @override
  String lat(double deg) {
    final normalized = deg.wrapLatitude();
    final lat = formatDms(normalized);

    if (_zeroPadDegrees) {
      // knock off initial '0' for latitude and return the formatted result
      return lat.substring(1) + _separator + (normalized < 0.0 ? 'S' : 'N');
    } else {
      return lat + _separator + (normalized < 0.0 ? 'S' : 'N');
    }
  }

  /// Converts a degree value [deg] to a String representation (deg/min/sec) of
  /// the longitude (3-digit degrees, suffixed with E/W) according to the
  /// specified [_type].
  ///
  /// For returned values:
  /// * The longitude value is normalized to the range [180° W .. 180° E[
  /// * Degree, prime, double-prime symbols are added.
  /// * Compass direction is added.
  /// * Degree values are zero-padded to 3 digits (if `zeroPadDegrees` is true).
  ///
  /// Parameters:
  /// * [deg]: The degree value of longitude to be formatted as specified.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  ///
  /// Examples:
  /// ```dart
  ///   final lonDms = Dms().longitude(-3.62); // 3° 37′ 12″ W
  ///   final lonDm = Dms(type: DmsType.dm).longitude(-3.62); // 3° 37.20′ W
  ///   final lonD = Dms(type: DmsType.d).longitude(-3.62); // 3.6200° W
  /// ```
  @override
  String lon(double deg) {
    final normalized = deg.wrapLongitude();
    final lon = formatDms(normalized);
    return lon + _separator + (normalized < 0.0 ? 'W' : 'E');
  }

  /// Converts a degree value [deg] to a String representation (deg/min/sec) of
  /// the bearing (3-digit degrees, 0°..360°) according to the specified [_type].
  ///
  /// For returned values:
  /// * The bearing value is normalized to the range [0°..360°[
  /// * Degree, prime, double-prime symbols are added.
  /// * Degree values are zero-padded to 3 digits (if `zeroPadDegrees` is true).
  ///
  /// Parameters:
  /// * [deg]: The degree value of bearing to be formatted as specified.
  ///
  /// Throws [FormatException] if a string representation cannot be formatted.
  ///
  /// Examples:
  /// ```dart
  ///   final brngDms = Dms().bearing(-3.62); // 356° 22′ 48″
  ///   final brngDm = Dms(type: DmsType.dm).bearing(-3.62); // 356° 22.80′
  ///   final brngD = Dms(type: DmsType.d).bearing(-3.62); // 356.3800°
  /// ```
  @override
  String bearing(double deg) {
    final normalized = deg.wrap360();
    final brng = formatDms(normalized);
    if (brng.startsWith('360')) {
      // just in case rounding took us up to 360°!
      if (_zeroPadDegrees) {
        return brng.replaceRange(0, 3, '000');
      } else {
        return '0${brng.substring(3)}';
      }
    } else {
      return brng;
    }
  }
}
