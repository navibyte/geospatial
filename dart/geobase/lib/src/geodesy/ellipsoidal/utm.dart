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

import 'dart:math';

import 'package:meta/meta.dart';

import '/src/common/codes/coords.dart';
import '/src/common/codes/hemisphere.dart';
import '/src/common/constants/geodetic.dart';
import '/src/common/functions/position_functions.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/geographic/geographic.dart';
import '/src/coordinates/projected/projected.dart';
import '/src/utils/math_utils.dart';

import 'datum.dart';
import 'ellipsoidal.dart';
import 'utm_mgrs.dart';

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
  /// Easting is in metres from the false easting (-500km from the central
  /// meridian).
  ///
  /// Northing is in metres from the equator (N) or from the false northing
  /// -10,000km (S).
  ///
  /// 2D positions are constructed as `Projected(x: easting, y: northing)`
  /// and 3D positions as `Projected(x: easting, y: northing, z: elev)`.
  ///
  /// The [datum] indicates the geodetic reference (ie. ellipsoid and other
  /// parameters) used when projecting geographic coordinates to projected
  /// coordinates.
  ///
  /// {@endtemplate}
  ///
  /// See also [easting] and [northing] for direct access to the coordinates.
  final Projected projected;

  /// The easting (x) in metres from the false easting (-500km from the central
  /// meridian).
  ///
  /// The normal value range is roughly 0..1000000m. The value can be
  /// outside of this range if alternative zones are used and `verifyEN` is set
  /// false when creating the UTM coordinates.
  ///
  /// See also [projected] for the full UTM projected position.
  double get easting => projected.x;

  /// The northing (y) in metres from the equator (N) or from the false northing
  /// -10,000km (S).
  ///
  /// The normal value range is roughly 0..9329006m in the northern hemisphere
  /// and 1116914..10000000m in the southern hemisphere. The value can be
  /// outside of this range if alternative zones are used and `verifyEN` is set
  /// false when creating the UTM coordinates.
  ///
  /// See also [projected] for the full UTM projected position.
  double get northing => projected.y;

  /// The datum used for calculations with a reference ellipsoid and datum
  /// transformation parameters.
  ///
  /// See also [projected].
  final Datum datum;

  /// Creates UTM coordinates with [zone], [hemisphere], [easting], [northing]
  /// based on the [datum].
  ///
  /// You can also provide optional [elev] (elevation) and [m] (measure value).
  ///
  /// {@macro geobase.geodesy.utm.zone}
  ///
  /// {@macro geobase.geodesy.utm.hemisphere}
  ///
  /// {@macro geobase.geodesy.utm.projected}
  ///
  /// {@macro geobase.geodesy.utm.datum}
  ///
  /// {@template geobase.geodesy.utm.verifyEN}
  ///
  /// If [verifyEN] is true it's validated that easting/northing is within
  /// 'normal' values (may be suppressed for extended coherent coordinates or
  /// alternative datums e.g. ED50, see epsg.io/23029). The 'normal' values are
  /// roughly 0..1000000m for easting, and 0..9329006m for northing in the
  /// northern hemisphere and 1116914..10000000m in the southern hemisphere.
  ///
  /// {@endtemplate}
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
    double? m,
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
      projected: Projected(x: easting, y: northing, z: elev, m: m),
      datum: datum,
    );
  }

  /// Parses projected UTM coordinates from [text], by default in the following
  /// order: zone, hemisphere, easting, northing (ie. `31 N 448251 5411932`).
  ///
  /// Coordinate values in [text] are separated by [delimiter] (default is
  /// whitespace).
  ///
  /// If [swapXY] is true, then swaps x and y parsed from the text.
  ///
  /// {@template geobase.geodesy.utm.datum}
  ///
  /// Use [datum] to set the datum for calculations with a reference ellipsoid
  /// and datum transformation parameters.
  ///
  /// {@endtemplate}
  ///
  /// {@macro geobase.geodesy.utm.verifyEN}
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
  ///   // UTM coordinates with 3D position and measure.
  ///   final utmWithElevM = Utm.parse('31 N 448251 5411932 100 5.0');
  ///
  ///   // With swapped x and y (=> easting 448251.0, northing 5411932.0).
  ///   final utmSwapped = Utm.parse('31 N 5411932 448251', swapXY: true);
  /// ```
  factory Utm.parse(
    String text, {
    Pattern? delimiter,
    bool swapXY = false,
    Datum datum = Datum.WGS84,
    bool verifyEN = true,
  }) {
    final parts = text.trim().split(delimiter ?? RegExp(r'\s+'));
    if (parts.length < 4 || parts.length > 6) {
      throw FormatException('invalid UTM coordinate ‘$text’');
    }

    final zone = int.parse(parts[0]);
    final hemisphere = parts[1];
    final easting = double.parse(parts[swapXY ? 3 : 2]);
    final northing = double.parse(parts[swapXY ? 2 : 3]);
    final elev = parts.length >= 5 ? double.parse(parts[4]) : null;
    final m = parts.length >= 6 ? double.parse(parts[5]) : null;

    return Utm(
      zone,
      hemisphere,
      easting,
      northing,
      elev: elev,
      m: m,
      datum: datum,
      verifyEN: verifyEN,
    );
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

  /*
  // NOTE: commented out to keep the Utm class more focused

  /// Creates projected UTM coordinates by converting it from an [ellipsoidal]
  /// position that contains the geographic `origin` position and an optional
  /// `datum`.
  ///
  /// If `datum` in [ellipsoidal] is not specified, then the WGS84 datum is
  /// used unless the `ellipsoid` is something other than `Ellipsoid.WGS84`,
  /// in which case a `FormatException` is thrown.
  ///
  /// {@macro geobase.geodesy.utm.fromGeographic}
  ///
  /// Examples:
  ///
  /// ```dart
  ///   const geographic = Geographic(lat: 48.8582, lon: 2.2945);
  ///   final ellipsoidal =
  ///       Ellipsoidal.fromGeographic(geographic, datum: Datum.WGS84);
  ///
  ///   // UTM projected coordinates: 31 N 448252 5411933
  ///   final utmCoord = Utm.fromEllipsoidal(ellipsoidal);
  /// ```
  factory Utm.fromEllipsoidal(
    Ellipsoidal ellipsoidal, {
    int? zone,
    bool roundResults = true,
  }) {
    var datum = ellipsoidal.datum;
    if (datum == null) {
      if (ellipsoidal.ellipsoid != Ellipsoid.WGS84) {
        throw const FormatException(
          'datum must be specified if ellipsoid is not WGS84',
        );
      }
      datum = Datum.WGS84;
    }
    return Utm.fromGeographicMeta(
      ellipsoidal.origin,
      zone: zone,
      datum: datum,
      roundResults: roundResults,
    ).position;
  }
  */

  /// Creates projected UTM coordinates by converting it from a [geographic]
  /// position based on the [datum].
  ///
  /// {@macro geobase.geodesy.utm.fromGeographic}
  ///
  /// {@macro geobase.geodesy.utm.datum}
  ///
  /// {@macro geobase.geodesy.utm.verifyEN}
  ///
  /// Examples:
  ///
  /// ```dart
  ///   const geographic = Geographic(lat: 48.8582, lon: 2.2945);
  ///
  ///   // UTM projected coordinates: 31 N 448252 5411933
  ///   final utmCoord = Utm.fromGeographic(geographic, datum: Datum.WGS84);
  /// ```
  factory Utm.fromGeographic(
    Geographic geographic, {
    int? zone,
    Datum datum = Datum.WGS84,
    bool roundResults = true,
    bool verifyEN = true,
  }) {
    return Utm.fromGeographicMeta(
      geographic,
      zone: zone,
      datum: datum,
      roundResults: roundResults,
      verifyEN: verifyEN,
    ).position;
  }

  // symbols: η = eta, ξ = xi, β = beta, τ = tau, δ = delta, σ = sigma
  //          φ = phi, λ = lambda, γ = gamma, α = alpha
  //          ʹ = P (prime)
  //          ʺ = PP (double prime)

  /// Creates projected UTM coordinates wrapped inside metadata object by
  /// converting it from a [geographic] position based on the [datum].
  ///
  /// The metadata includes UTM `convergence` and `scale` at the calculated
  /// projected position.
  ///
  /// {@template geobase.geodesy.utm.fromGeographic}
  ///
  /// Set [zone] to specify a zone explicitely rather than using the
  /// zone within which the geographic position lies. Note that overriding the
  /// UTM zone has the potential to result in negative eastings, and strange
  /// results within Norway/Svalbard exceptions (you may need to set [verifyEN]
  /// to false when overriding the zone).
  ///
  /// If [roundResults] is true (default), then the results are rounded to the
  /// reasonable precision, that is nm precision (1nm = 10^-14°).
  ///
  /// Throws FormatException if coordinates are invalid (eg. latitude outside
  /// UTM limits).
  ///
  /// {@endtemplate}
  ///
  /// {@macro geobase.geodesy.utm.datum}
  ///
  /// {@macro geobase.geodesy.utm.verifyEN}
  ///
  /// Examples:
  ///
  /// ```dart
  ///   const geographic = Geographic(lat: 48.8582, lon: 2.2945);
  ///
  ///   // UTM projected coordinates: 31 N 448252 5411933
  ///   final utmMeta = Utm.fromGeographicMeta(geographic, datum: Datum.WGS84);
  //    final utmCoord = utmMeta.position;
  ///   final convergence = utmMeta.convergence;
  ///   final scale = utmMeta.scale;
  /// ```
  static UtmMeta<Utm> fromGeographicMeta(
    Geographic geographic, {
    int? zone,
    Datum datum = Datum.WGS84,
    bool roundResults = true,
    bool verifyEN = true,
  }) {
    final lat = geographic.lat;
    final lon = geographic.lon;

    if (!(minLatitudeUTM <= lat && lat <= maxLatitudeUTM)) {
      throw FormatException('latitude ‘${geographic.lat}’ outside UTM limits');
    }

    const falseEasting = 500.0e3;
    const falseNorthing = 10000.0e3;

    // longitudinal zone
    var utmZone = zone ?? ((lon + 180.0) / 6.0).floor() + 1;
    if (!(1 <= utmZone && utmZone <= 60)) {
      throw FormatException('invalid UTM zone $utmZone');
    }

    // longitude of central meridian
    var lambda0 = ((utmZone - 1) * 6.0 - 180.0 + 3.0).toRadians();

    // handle Norway/Svalbard exceptions
    // grid zones are 8° tall; 0°N is offset 10 into latitude bands array
    final sixDegreesRad = 6.0.toRadians();
    const mgrsLatBands = 'CDEFGHJKLMNPQRSTUVWXX'; // X is repeated for 80-84°N
    final latBand =
        mgrsLatBands[(lat / 8 + 10).floor().clamp(0, mgrsLatBands.length - 1)];
    // adjust zone & central meridian for Norway
    if (utmZone == 31 && latBand == 'V' && lon >= 3) {
      utmZone++;
      lambda0 += sixDegreesRad;
    }
    // adjust zone & central meridian for Svalbard
    if (utmZone == 32 && latBand == 'X' && lon < 9) {
      utmZone--;
      lambda0 -= sixDegreesRad;
    }
    if (utmZone == 32 && latBand == 'X' && lon >= 9) {
      utmZone++;
      lambda0 += sixDegreesRad;
    }
    if (utmZone == 34 && latBand == 'X' && lon < 21) {
      utmZone--;
      lambda0 -= sixDegreesRad;
    }
    if (utmZone == 34 && latBand == 'X' && lon >= 21) {
      utmZone++;
      lambda0 += sixDegreesRad;
    }
    if (utmZone == 36 && latBand == 'X' && lon < 33) {
      utmZone--;
      lambda0 -= sixDegreesRad;
    }
    if (utmZone == 36 && latBand == 'X' && lon >= 33) {
      utmZone++;
      lambda0 += sixDegreesRad;
    }

    final phi = lat.toRadians(); // latitude ± from equator
    final lambda =
        lon.toRadians() - lambda0; // longitude ± from central meridian

    // Ellipsoidal params (ie. WGS-84: a = 6378137, f = 1/298.257223563)
    final a = datum.ellipsoid.a;
    final f = datum.ellipsoid.f;

    // UTM scale on the central meridian
    const k0 = 0.9996;

    // ---- easting, northing: Karney 2011 Eq 7-14, 29, 35:

    final e = sqrt(f * (2 - f)); // eccentricity
    final n = f / (2 - f); // 3rd flattening
    final n2 = n * n, n3 = n * n2, n4 = n * n3, n5 = n * n4, n6 = n * n5;

    final cosLambda = cos(lambda);
    final sinLambda = sin(lambda);
    final tanLambda = tan(lambda);

    // τ ≡ tanφ, τʹ ≡ tanφʹ; prime (ʹ) indicates angles on the conformal sphere
    final tau = tan(phi);
    final sigma = sinh(e * atanh(e * tau / sqrt(1 + tau * tau)));

    final tauPrime =
        tau * sqrt(1 + sigma * sigma) - sigma * sqrt(1 + tau * tau);

    final xiPrime = atan2(tauPrime, cosLambda);
    final etaPrime =
        asinh(sinLambda / sqrt(tauPrime * tauPrime + cosLambda * cosLambda));

    // 2πA is the circumference of a meridian
    final A = a / (1 + n) * (1 + 1 / 4 * n2 + 1 / 64 * n4 + 1 / 256 * n6);

    // note α is one-based array (6th order Krüger expressions)
    final alpha = [
      null,
      1 / 2 * n -
          2 / 3 * n2 +
          5 / 16 * n3 +
          41 / 180 * n4 -
          127 / 288 * n5 +
          7891 / 37800 * n6,
      13 / 48 * n2 -
          3 / 5 * n3 +
          557 / 1440 * n4 +
          281 / 630 * n5 -
          1983433 / 1935360 * n6,
      61 / 240 * n3 -
          103 / 140 * n4 +
          15061 / 26880 * n5 +
          167603 / 181440 * n6,
      49561 / 161280 * n4 - 179 / 168 * n5 + 6601661 / 7257600 * n6,
      34729 / 80640 * n5 - 3418889 / 1995840 * n6,
      212378941 / 319334400 * n6,
    ];

    var xi = xiPrime;
    for (var j = 1; j <= 6; j++) {
      xi += (alpha[j] ?? 0.0) * sin(2 * j * xiPrime) * cosh(2 * j * etaPrime);
    }

    var eta = etaPrime;
    for (var j = 1; j <= 6; j++) {
      eta += (alpha[j] ?? 0.0) * cos(2 * j * xiPrime) * sinh(2 * j * etaPrime);
    }

    var easting = k0 * A * eta; // easting == x
    var northing = k0 * A * xi; // northing == y

    // ---- convergence: Karney 2011 Eq 23, 24

    var pPrime = 1.0;
    for (var j = 1; j <= 6; j++) {
      pPrime += 2 *
          j *
          (alpha[j] ?? 0.0) *
          cos(2 * j * xiPrime) *
          cosh(2 * j * etaPrime);
    }
    var qPrime = 0.0;
    for (var j = 1; j <= 6; j++) {
      qPrime += 2 *
          j *
          (alpha[j] ?? 0.0) *
          sin(2 * j * xiPrime) *
          sinh(2 * j * etaPrime);
    }

    final gammaPrime =
        atan(tauPrime / sqrt(1 + tauPrime * tauPrime) * tanLambda);
    final gammaDoublePrime = atan2(qPrime, pPrime);

    final gamma = gammaPrime + gammaDoublePrime;

    // ---- scale: Karney 2011 Eq 25

    final sinPhi = sin(phi);
    final kPrime = sqrt(1 - e * e * sinPhi * sinPhi) *
        sqrt(1 + tau * tau) /
        sqrt(tauPrime * tauPrime + cosLambda * cosLambda);
    final kDoublePrime = A / a * sqrt(pPrime * pPrime + qPrime * qPrime);

    final k = k0 * kPrime * kDoublePrime;

    // shift x/y to false origins
    easting = easting + falseEasting; // make x relative to false easting
    if (northing < 0) {
      // make y in southern hemisphere relative to false northing
      northing = northing + falseNorthing;
    }

    // round to reasonable precision when requested (roundResults is true)
    easting = roundResults
        ? double.parse(easting.toStringAsFixed(9)) // nm precision
        : easting;
    northing = roundResults
        ? double.parse(northing.toStringAsFixed(9)) // nm precision
        : northing;
    final convergence = roundResults
        ? double.parse(gamma.toDegrees().toStringAsFixed(9))
        : gamma.toDegrees();
    final scale = roundResults ? double.parse(k.toStringAsFixed(12)) : k;

    // hemisphere
    final h = lat >= 0 ? 'N' : 'S';

    return UtmMeta(
      Utm(
        utmZone,
        h,
        easting,
        northing,
        elev: geographic.optElev, // do not convert optional elevation (meters)
        m: geographic.optM, // do not convert optional M value
        datum: datum,
        verifyEN: verifyEN,
      ),
      convergence: convergence,
      scale: scale,
    );
  }

  /// {@template geobase.geodesy.utm.unproject}
  ///
  /// Converts UTM coordinates of this and represented by [zone], [hemisphere]
  /// and [projected] based on the [datum] to a geographic position.
  ///
  /// Implements Karney’s method, using Krüger series to order n⁶, giving
  /// results accurate to 5nm for distances up to 3900km from the central
  /// meridian.
  ///
  /// If [roundResults] is true (default), then the results are rounded to the
  /// reasonable precision, that is nm precision (1nm = 10^-14°).
  ///
  /// {@endtemplate}
  ///
  /// This method returns a [Geographic] position object.
  ///
  /// Examples:
  ///
  /// ```dart
  ///   final utm = Utm(31, 'N', 448251.795, 5411932.678);
  ///
  ///   final geographic = utm.toGeographic(); // 48°51′29.52″N, 002°17′40.20″E
  /// ```
  ///
  /// See also [toGeographicMeta] and [_toEllipsoidalMeta] for methods returning
  /// a geographic position with metadata.
  Geographic toGeographic({bool roundResults = true}) =>
      _toEllipsoidalMeta(roundResults: roundResults).position.origin;

  /// {@macro geobase.geodesy.utm.unproject}
  ///
  /// This method returns a geographic position wrapped into an [UtmMeta]
  /// object. The metadata includes UTM `convergence` and `scale` at the
  /// calculated geographic position.
  ///
  /// Examples:
  ///
  /// ```dart
  ///  final utm = Utm(31, 'N', 448251.795, 5411932.678);
  ///
  ///  final meta = utm.toGeographicMeta();
  ///  final geographic = meta.position; // 48°51′29.52″N, 002°17′40.20″E
  ///  final convergence = meta.convergence;
  ///  final scale = meta.scale;
  /// ```
  ///
  /// See also [toGeographic] for a method returning a geographic position only.
  UtmMeta<Geographic> toGeographicMeta({bool roundResults = true}) {
    final meta = _toEllipsoidalMeta(roundResults: roundResults);
    return UtmMeta(
      meta.position.origin,
      convergence: meta.convergence,
      scale: meta.scale,
    );
  }

  /// {@macro geobase.geodesy.utm.unproject}
  ///
  /// This method returns a geographic position with the ellipsoidal datum
  /// wrapped into an [UtmMeta] object. The metadata includes UTM `convergence`
  /// and `scale` at the calculated geographic position.
  ///
  /// Examples:
  ///
  /// ```dart
  ///  final utm = Utm(31, 'N', 448251.795, 5411932.678);
  ///
  ///  final meta = utm.toEllipsoidalMeta();
  ///  final geographic = meta.position.origin; // 48°51′29.52″N, 002°17′40.20″E
  ///  final datum = meta.position.datum;
  ///  final convergence = meta.convergence;
  ///  final scale = meta.scale;
  /// ```
  ///
  /// See also [toGeographic] for a method returning a geographic position only.
  UtmMeta<Ellipsoidal> _toEllipsoidalMeta({bool roundResults = true}) {
    const falseEasting = 500.0e3;
    const falseNorthing = 10000.0e3;

    // Ellipsoidal params (ie. WGS-84: a = 6378137, f = 1/298.257223563)
    final a = datum.ellipsoid.a;
    final f = datum.ellipsoid.f;

    // UTM scale on the central meridian
    const k0 = 0.9996;

    // make x ± relative to central meridian
    final x = easting - falseEasting;
    // make y ± relative to equator
    final y =
        hemisphere == Hemisphere.south ? northing - falseNorthing : northing;

    // ---- from Karney 2011 Eq 15-22, 36:

    final e = sqrt(f * (2 - f)); // eccentricity
    final n = f / (2 - f); // 3rd flattening
    final n2 = n * n, n3 = n * n2, n4 = n * n3, n5 = n * n4, n6 = n * n5;

    // 2πA is the circumference of a meridian
    final A = a / (1 + n) * (1 + 1 / 4 * n2 + 1 / 64 * n4 + 1 / 256 * n6);

    final eta = x / (k0 * A);
    final xi = y / (k0 * A);

    // note beta is one-based array (6th order Krüger expressions)
    final beta = [
      null,
      1 / 2 * n -
          2 / 3 * n2 +
          37 / 96 * n3 -
          1 / 360 * n4 -
          81 / 512 * n5 +
          96199 / 604800 * n6,
      1 / 48 * n2 +
          1 / 15 * n3 -
          437 / 1440 * n4 +
          46 / 105 * n5 -
          1118711 / 3870720 * n6,
      17 / 480 * n3 - 37 / 840 * n4 - 209 / 4480 * n5 + 5569 / 90720 * n6,
      4397 / 161280 * n4 - 11 / 504 * n5 - 830251 / 7257600 * n6,
      4583 / 161280 * n5 - 108847 / 3991680 * n6,
      20648693 / 638668800 * n6,
    ];

    var xiPrime = xi;
    for (var j = 1; j <= 6; j++) {
      xiPrime -= (beta[j] ?? 0.0) * sin(2 * j * xi) * cosh(2 * j * eta);
    }

    var etaPrime = eta;
    for (var j = 1; j <= 6; j++) {
      etaPrime -= (beta[j] ?? 0.0) * cos(2 * j * xi) * sinh(2 * j * eta);
    }

    final sinhEtaPrime = sinh(etaPrime);
    final sinXiPrime = sin(xiPrime), cosXiP = cos(xiPrime);

    final tauPrime =
        sinXiPrime / sqrt(sinhEtaPrime * sinhEtaPrime + cosXiP * cosXiP);

    double? deltaTaui;
    var taui = tauPrime;
    do {
      final sigmai = sinh(e * atanh(e * taui / sqrt(1 + taui * taui)));
      final tauiPrime =
          taui * sqrt(1 + sigmai * sigmai) - sigmai * sqrt(1 + taui * taui);
      deltaTaui = (tauPrime - tauiPrime) /
          sqrt(1 + tauiPrime * tauiPrime) *
          (1 + (1 - e * e) * taui * taui) /
          ((1 - e * e) * sqrt(1 + taui * taui));
      taui += deltaTaui;
    } while (deltaTaui.abs() >
        1.0e-12); // using IEEE 754 δτi -> 0 after 2-3 iterations
    // note relatively large convergence test as δτi toggles on ±1.12e-16 for eg
    // 31 N 400000 5000000

    final tau = taui;

    final phi = atan(tau);

    var lambda = atan2(sinhEtaPrime, cosXiP);

    // ---- convergence: Karney 2011 Eq 26, 27

    var p = 1.0;
    for (var j = 1; j <= 6; j++) {
      p -= 2 * j * (beta[j] ?? 0.0) * cos(2 * j * xi) * cosh(2 * j * eta);
    }
    var q = 0.0;
    for (var j = 1; j <= 6; j++) {
      q += 2 * j * (beta[j] ?? 0.0) * sin(2 * j * xi) * sinh(2 * j * eta);
    }

    final gammaPrime = atan(tan(xiPrime) * tanh(etaPrime));
    final gammaDoublePrime = atan2(q, p);

    final gamma = gammaPrime + gammaDoublePrime;

    // ---- scale: Karney 2011 Eq 28

    final sinPhi = sin(phi);
    final kPrime = sqrt(1 - e * e * sinPhi * sinPhi) *
        sqrt(1 + tau * tau) *
        sqrt(sinhEtaPrime * sinhEtaPrime + cosXiP * cosXiP);
    final kDoublePrime = A / a / sqrt(p * p + q * q);

    final k = k0 * kPrime * kDoublePrime;

    // longitude of central meridian
    final lambda0 = ((zone - 1) * 6.0 - 180.0 + 3.0).toRadians();
    // move λ from zonal to global coordinates
    lambda += lambda0;

    // round to reasonable precision when requested (roundResults is true)
    // nm precision (1nm = 10^-14°)
    final lat = (roundResults
            ? double.parse(phi.toDegrees().toStringAsFixed(14))
            : phi.toDegrees())
        .clamp(minLatitudeUTM, maxLatitudeUTM);
    // (strictly lat rounding should be φ⋅cosφ!)
    final lon = roundResults
        ? double.parse(lambda.toDegrees().toStringAsFixed(14))
        : lambda.toDegrees();
    final convergence = roundResults
        ? double.parse(gamma.toDegrees().toStringAsFixed(9))
        : gamma.toDegrees();
    final scale = roundResults ? double.parse(k.toStringAsFixed(12)) : k;

    // unprojected geographic position
    final geographic = Geographic(
      lat: lat,
      lon: lon,
      elev: projected.optZ, // do not convert optional elevation (in meters)
      m: projected.optM, // do not convert optional M value
    );

    return UtmMeta(
      Ellipsoidal.fromGeographic(geographic, datum: datum),
      convergence: convergence,
      scale: scale,
    );
  }

  /// Converts UTM coordinates of this to the MGRS grid reference.
  ///
  /// May throw a FormatException if conversion fails.
  ///
  /// Examples:
  ///
  /// ```dart
  ///   final utmCoord = Utm(31, 'N', 448251, 5411932);
  ///   final mgrsRef = utmCoord.toMgrs(); // 31U DQ 48251 11932
  /// ```
  ///
  /// See [Mgrs.fromUtm] for more details.
  Mgrs toMgrs() => Mgrs.fromUtm(this);

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
  /// Set [formatAlsoElevM] to true if any elevation or m coordinate values
  /// optionally present in the [projected] position should be written on the
  /// text output (`z` is elevation, `m` is optional M value).
  ///
  /// {@macro geobase.geodesy.mgrs.zoneLeadingZero}
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
    bool formatAlsoElevM = false,
    bool zeroPadZone = false,
  }) {
    // ensure leading zeros on zone if `zeroPadZone` is set true
    final zPadded =
        zeroPadZone ? zone.toString().padLeft(2, '0') : zone.toString();

    final buf = StringBuffer()
      ..write(zPadded)
      ..write(delimiter)
      ..write(hemisphere.symbol)
      ..write(delimiter);

    var pos = projected;
    if (!formatAlsoElevM && (pos.is3D || pos.isMeasured)) {
      pos = pos.copyByType(Coords.xy);
    }

    Position.writeValues(
      pos,
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
