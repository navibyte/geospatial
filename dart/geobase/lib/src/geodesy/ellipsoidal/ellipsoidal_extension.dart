// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/reference/ellipsoid.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/geographic/geographic.dart';

import 'datum.dart';
import 'ellipsoidal.dart';
import 'utm.dart';
import 'utm_mgrs.dart';

/// An extension of the [Geographic] class providing calculations related to the
/// Earth surface modeled by ellipsoidal reference frames (or datums).
///
/// {@macro geobase.geodesy.ellipsoidal.overview}
///
/// See also the [Ellipsoidal] base class with alternative way of accessing
/// these transformations and [Utm] for conversions on projected UTM
/// coordinates.
extension EllipsoidalExtension on Geographic {
  /// Converts this geographic position (latitude and longitude as
  /// geodetic coordinates) to geocentric cartesian coordinates (X, Y, Z) based
  /// on the given [datum] or [ellipsoid].
  ///
  /// {@macro geobase.geodesy.ellipsoidal.ecef}
  ///
  /// {@macro geobase.geodesy.ellipsoidal.datumOrEllipsoid}
  Position toGeocentricCartesian({Datum? datum, Ellipsoid? ellipsoid}) =>
      Ellipsoidal.fromGeographic(this, datum: datum, ellipsoid: ellipsoid)
          .toGeocentricCartesian();

  /// Converts the given [geocentric] cartesian coordinates (X, Y, Z) to
  /// geographic coordinates (latitude and longitude) based on the given
  /// [datum] or [ellipsoid].
  ///
  @Deprecated('Instead create a geocentric object using '
      '`Geocentric.fromGeocentricCartesian` and then call `toGeographic`.')
  static Geographic fromGeocentricCartesian(
    Position geocentric, {
    Datum? datum,
    Ellipsoid? ellipsoid,
  }) =>
      Geocentric.fromGeocentricCartesian(
        geocentric,
        datum: datum,
        ellipsoid: ellipsoid,
      ).toGeographic();

  /// Converts this geographic position (latitude and longitude as
  /// geodetic coordinates) to projected UTM coordinates with conversions based
  /// on the [datum].
  ///
  /// {@macro geobase.geodesy.ellipsoidal.datum}
  ///
  /// {@macro geobase.geodesy.utm.fromGeographic}
  ///
  /// {@macro geobase.geodesy.utm.verifyEN}
  ///
  /// Examples:
  ///
  /// ```dart
  ///   const geographic = Geographic(lat: 48.8582, lon: 2.2945);
  ///
  ///   // UTM projected coordinates: 31 N 448252 5411933
  ///   final utmCoord = geographic.toUtm(datum: Datum.WGS84);
  /// ```
  Utm toUtm({
    UtmZone? zone,
    Datum datum = Datum.WGS84,
    bool roundResults = true,
    bool verifyEN = true,
  }) =>
      Utm.fromGeographic(
        this,
        zone: zone,
        datum: datum,
        roundResults: roundResults,
        verifyEN: verifyEN,
      );

  /// Converts this geographic position (latitude and longitude as
  /// geodetic coordinates) to projected UTM coordinates wrapped inside metadata
  /// object with conversions based on the [datum].
  ///
  /// The metadata includes UTM `convergence` and `scale` at the calculated
  /// projected position.
  ///
  /// {@macro geobase.geodesy.ellipsoidal.datum}
  ///
  /// {@macro geobase.geodesy.utm.fromGeographic}
  ///
  /// {@macro geobase.geodesy.utm.verifyEN}
  ///
  /// Examples:
  ///
  /// ```dart
  ///   const geographic = Geographic(lat: 48.8582, lon: 2.2945);
  ///
  ///   // UTM projected coordinates: 31 N 448252 5411933
  ///   final utmMeta = geographic.toUtmMeta(datum: Datum.WGS84);
  //    final utmCoord = utmMeta.position;
  ///   final convergence = utmMeta.convergence;
  ///   final scale = utmMeta.scale;
  /// ```
  UtmMeta<Utm> toUtmMeta({
    UtmZone? zone,
    Datum datum = Datum.WGS84,
    bool roundResults = true,
    bool verifyEN = true,
  }) =>
      Utm.fromGeographicMeta(
        this,
        zone: zone,
        datum: datum,
        roundResults: roundResults,
        verifyEN: verifyEN,
      );

  /// Converts this geographic position (latitude and longitude as
  /// geodetic coordinates) first to projected UTM coordinates and then from
  /// UTM coordinates to the MGRS grid reference.
  ///
  /// May throw a FormatException if conversion fails.
  ///
  /// Examples:
  ///
  /// ```dart
  ///   const geographic = Geographic(lat: 48.8582, lon: 2.2945);
  ///   final mgrsRef = geographic.toMgrs(); // 31U DQ 48251 11932
  /// ```
  Mgrs toMgrs({Datum datum = Datum.WGS84}) =>
      toUtm(datum: datum, roundResults: false).toMgrs();
}
