// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/geographic/geographic.dart';
import '/src/coordinates/projected/projected.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/projection/projection_adapter.dart';
import '/src/geodesy/ellipsoidal/datum.dart';
import '/src/geodesy/ellipsoidal/ellipsoidal.dart';

import 'base_ellipsoidal_projection.dart';

/// {@template geobase.projections.ellipsoidal.overview}
///
/// A projection adapter between *source* geographic (longitude, latitude) and
/// *target* geocentric cartesian (X, Y, Z) positions.
///
/// For the [forward] projection [sourceCrs] defines the identifier of the
/// source coordinate reference system (CRS) and [targetCrs] defines the
/// identifier of the target CRS. For the [inverse] projection the source and
/// target CRSs are swapped.
///
/// {@endtemplate}
class EllipsoidalProjectionAdapter with ProjectionAdapter {
  @override
  final CoordRefSys sourceCrs;

  @override
  final CoordRefSys targetCrs;

  final Datum _sourceDatum;
  final Datum _targetDatum;

  /// {@macro geobase.projections.ellipsoidal.overview}
  ///
  /// {@template geobase.projections.ellipsoidal.datums}
  ///
  /// For the [forward] projection [sourceDatum] defines the datum of the source
  /// CRS and [targetDatum] the datum of the target CRS. For the [inverse]
  /// projection the source and target datums are swapped. A datum is specified
  /// by an ellipsoid and datum transformation parameters, see [Datum].
  ///
  /// If both datums equals, then only ellipsoidal parameters are used, no datum
  /// 7-parameter transformation is applied.
  ///
  /// {@endtemplate}
  const EllipsoidalProjectionAdapter({
    this.sourceCrs = CoordRefSys.CRS84,
    this.targetCrs = CoordRefSys.EPSG_4978,
    Datum sourceDatum = Datum.WGS84,
    Datum targetDatum = Datum.WGS84,
  })  : _targetDatum = targetDatum,
        _sourceDatum = sourceDatum;

  @override
  Projection get forward => _EllipsoidalToGeocentricProjection(
        sourceDatum: _sourceDatum,
        targetDatum: _targetDatum,
      );

  @override
  Projection get inverse => _GeocentricToEllipsoidalProjection(
        sourceDatum: _targetDatum,
        targetDatum: _sourceDatum,
      );
}

class _EllipsoidalToGeocentricProjection
    extends BaseEllipsoidalProjection<Geographic, Position> {
  const _EllipsoidalToGeocentricProjection({
    required super.sourceDatum,
    required super.targetDatum,
  });

  @override
  Position projectPosition(Geographic source) {
    // source geographic coordinates in the source datum
    final ellipsoidal = Ellipsoidal.fromGeographic(
      source,
      datum: sourceDatum,
    );

    // geocentric cartesian coordinates in the source datum
    var cartesian = ellipsoidal.toGeocentricCartesian();

    if (sourceDatum != targetDatum) {
      // transform geocentric cartesian coordinates to the target datum
      cartesian =
          sourceDatum.convertGeocentricCartesian(cartesian, to: targetDatum);
    }

    return cartesian;
  }

  @override
  Position projectXYZM(double x, double y, double? z, double? m) {
    return projectPosition(Geographic.create(x: x, y: y, z: z, m: m));
  }

  @override
  R project<R extends Position>(
    Position source, {
    required CreatePosition<R> to,
  }) {
    final cartesian = projectPosition(
      source is Geographic ? source : source.copyTo(Geographic.create),
    );

    // target geocentric cartesian coordinates in the target datum
    return cartesian is R ? cartesian : cartesian.copyTo(to);
  }
}

class _GeocentricToEllipsoidalProjection
    extends BaseEllipsoidalProjection<Position, Geographic> {
  const _GeocentricToEllipsoidalProjection({
    required super.sourceDatum,
    required super.targetDatum,
  });

  @override
  Geographic projectPosition(Position source) {
    // source geocentric cartesian coordinates in the source datum
    var cartesian = source;

    if (sourceDatum != targetDatum) {
      // transform geocentric cartesian coordinates to the target datum
      cartesian =
          sourceDatum.convertGeocentricCartesian(cartesian, to: targetDatum);
    }

    // from cartesian coordinates to geographic coordinates in the target datum
    return Geocentric.fromGeocentricCartesian(cartesian, datum: targetDatum)
        .toGeographic();
  }

  @override
  Geographic projectXYZM(double x, double y, double? z, double? m) {
    // NOTE: we use `Projected.new` instead of `Position.create` because
    // it should be more efficient for temporay position objects.
    return projectPosition(Projected(x: x, y: y, z: z, m: m));
  }

  @override
  R project<R extends Position>(
    Position source, {
    required CreatePosition<R> to,
  }) {
    final geographic = projectPosition(source);

    // target geographic coordinates coordinates in the target datum
    return geographic is R ? geographic as R : geographic.copyTo(to);
  }
}
