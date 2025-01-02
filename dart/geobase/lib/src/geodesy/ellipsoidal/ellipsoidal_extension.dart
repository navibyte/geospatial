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

/// An extension of the [Geographic] class providing calculations related to the
/// Earth surface modeled by ellipsoidal reference frames.
///
/// {@macro geobase.geodesy.ellipsoidal.overview}
///
/// See also the [Ellipsoidal] base class with alternative way of accessing
/// these transformations.
extension EllipsoidalExtension on Geographic {
  /// Transform this geographic position (latitude and longitude as
  /// geodetic coordinates) to geocentric cartesian coordinates (X, Y, Z) based
  /// on the given [datum] or [ellipsoid].
  ///
  /// {@macro geobase.geodesy.ellipsoidal.ecef}
  ///
  /// {@macro geobase.geodesy.ellipsoidal.datumOrEllipsoid}
  Position toGeocentricCartesian({Datum? datum, Ellipsoid? ellipsoid}) =>
      Ellipsoidal.fromGeographic(this, datum: datum, ellipsoid: ellipsoid)
          .toGeocentricCartesian();

  /// Transform the given [geocentric] cartesian coordinates (X, Y, Z) to
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
}
