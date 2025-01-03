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

/// An extension of the [Geographic] class providing calculations related to the
/// Earth surface modeled by ellipsoidal reference frames (or datums).
///
/// {@macro geobase.geodesy.ellipsoidal.overview}
///
/// See also the [Ellipsoidal] base class with alternative way of accessing
/// these transformations and [Utm] for conversions on projected UTM
/// coordinates.
extension EllipsoidalExtension on Geographic {
  /// Transfors this geographic position (latitude and longitude as
  /// geodetic coordinates) to geocentric cartesian coordinates (X, Y, Z) based
  /// on the given [datum] or [ellipsoid].
  ///
  /// {@macro geobase.geodesy.ellipsoidal.ecef}
  ///
  /// {@macro geobase.geodesy.ellipsoidal.datumOrEllipsoid}
  Position toGeocentricCartesian({Datum? datum, Ellipsoid? ellipsoid}) =>
      Ellipsoidal.fromGeographic(this, datum: datum, ellipsoid: ellipsoid)
          .toGeocentricCartesian();

  /// Transforms the given [geocentric] cartesian coordinates (X, Y, Z) to
  /// geographic coordinates (latitude and longitude) based on the given
  /// [datum] or [ellipsoid].
  ///
  /// {@macro geobase.geodesy.ellipsoidal.ecef}
  ///
  /// {@macro geobase.geodesy.ellipsoidal.datumOrEllipsoid}
  static Geographic fromGeocentricCartesian(
    Position geocentric, {
    Datum? datum,
    Ellipsoid? ellipsoid,
  }) =>
      Ellipsoidal.fromGeocentricCartesian(
        geocentric,
        datum: datum,
        ellipsoid: ellipsoid,
      ).origin;

  /// Transforms this geographic position (latitude and longitude as
  /// geodetic coordinates) to projected UTM coordinates with conversions based
  /// on the [datum].
  ///
  /// {@macro geobase.geodesy.ellipsoidal.datum}
  ///
  /// {@macro geobase.geodesy.utm.fromGeographic}
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
    int? zone,
    Datum datum = Datum.WGS84,
    bool roundResults = true,
  }) =>
      Utm.fromGeographic(
        this,
        zone: zone,
        datum: datum,
        roundResults: roundResults,
      );

  /// Transforms this geographic position (latitude and longitude as
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
    int? zone,
    Datum datum = Datum.WGS84,
    bool roundResults = true,
  }) =>
      Utm.fromGeographicMeta(
        this,
        zone: zone,
        datum: datum,
        roundResults: roundResults,
      );
}
