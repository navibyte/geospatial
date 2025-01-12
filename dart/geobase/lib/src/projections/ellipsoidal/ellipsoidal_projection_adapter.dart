// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/common/codes/coord_ref_sys_type.dart';
import '/src/common/codes/coords.dart';
import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/projected/projected.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/projection/projection_adapter.dart';
import '/src/geodesy/ellipsoidal/datum.dart';

import 'base_ellipsoidal_projection.dart';

// NOTE: Currently marked as internal. This may be changed in future.

/// A projection adapter based on geodetic transformations based on ellipsoidal
/// Earth models. Source and target coordinates can geographic (longitude,
/// latitude) or geocentric cartesian (X, Y, Z) positions.
///
/// {@template geobase.projections.ellipsoidal.overview}
///
/// For the [forward] projection [sourceCrs] defines the identifier of the
/// source coordinate reference system (CRS) and [targetCrs] defines the
/// identifier of the target CRS. For the [inverse] projection the source and
/// target CRSs are swapped.
///
/// {@endtemplate}
@internal
class EllipsoidalProjectionAdapter with ProjectionAdapter {
  @override
  final CoordRefSys sourceCrs;

  @override
  final CoordRefSys targetCrs;

  final Projection _forward;
  final Projection _inverse;

  /// Create an adapter with the forward projection converting from geographic
  /// coordinates (in source datum) to geographic coordinates (in target datum),
  /// and the inverse projection converting vice versa.
  ///
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
  EllipsoidalProjectionAdapter.geographicToGeographic({
    required this.sourceCrs,
    required this.targetCrs,
    required Datum sourceDatum,
    required Datum targetDatum,
  })  : _forward = _DatumToDatumProjection(
          sourceCrsType: CoordRefSysType.geographic,
          sourceDatum: sourceDatum,
          targetCrsType: CoordRefSysType.geographic,
          targetDatum: targetDatum,
        ),
        _inverse = _DatumToDatumProjection(
          sourceCrsType: CoordRefSysType.geographic,
          sourceDatum: targetDatum,
          targetCrsType: CoordRefSysType.geographic,
          targetDatum: sourceDatum,
        );

  /// Create an adapter with the forward projection converting from geographic
  /// coordinates (in source datum) to geocentric coordinates (in target datum),
  /// and the inverse projection converting vice versa.
  ///
  /// {@macro geobase.projections.ellipsoidal.overview}
  ///
  /// {@macro geobase.projections.ellipsoidal.datums}
  EllipsoidalProjectionAdapter.geographicToGeocentric({
    this.sourceCrs = CoordRefSys.CRS84,
    this.targetCrs = CoordRefSys.EPSG_4978,
    Datum sourceDatum = Datum.WGS84,
    Datum targetDatum = Datum.WGS84,
  })  : _forward = _DatumToDatumProjection(
          sourceCrsType: CoordRefSysType.geographic,
          sourceDatum: sourceDatum,
          targetCrsType: CoordRefSysType.geocentric,
          targetDatum: targetDatum,
        ),
        _inverse = _DatumToDatumProjection(
          sourceCrsType: CoordRefSysType.geocentric,
          sourceDatum: targetDatum,
          targetCrsType: CoordRefSysType.geographic,
          targetDatum: sourceDatum,
        );

  /// Create an adapter with the forward projection converting from geocentric
  /// coordinates (in source datum) to geocentric coordinates (in target datum),
  /// and the inverse projection converting vice versa.
  ///
  /// {@macro geobase.projections.ellipsoidal.overview}
  ///
  /// {@macro geobase.projections.ellipsoidal.datums}
  EllipsoidalProjectionAdapter.geocentricToGeocentric({
    required this.sourceCrs,
    required this.targetCrs,
    required Datum sourceDatum,
    required Datum targetDatum,
  })  : _forward = _DatumToDatumProjection(
          sourceCrsType: CoordRefSysType.geocentric,
          sourceDatum: sourceDatum,
          targetCrsType: CoordRefSysType.geocentric,
          targetDatum: targetDatum,
        ),
        _inverse = _DatumToDatumProjection(
          sourceCrsType: CoordRefSysType.geocentric,
          sourceDatum: targetDatum,
          targetCrsType: CoordRefSysType.geocentric,
          targetDatum: sourceDatum,
        );

  @override
  Projection get forward => _forward;

  @override
  Projection get inverse => _inverse;
}

class _DatumToDatumProjection
    extends BaseEllipsoidalProjection<Position, Position> {
  final CoordRefSysType sourceCrsType;
  final CoordRefSysType targetCrsType;

  _DatumToDatumProjection({
    required this.sourceCrsType,
    required super.sourceDatum,
    required this.targetCrsType,
    required super.targetDatum,
  });

  @override
  Position projectXYZM(double x, double y, double? z, double? m) =>
      convertDatumToDatum(
        x: x,
        y: y,
        z: z,
        m: m,
        sourceCrsType: sourceCrsType,
        targetCrsType: targetCrsType,
        sourceDatum: sourceDatum,
        targetDatum: targetDatum,
        // Use `Projected.new` for efficiency on temporary object.
        to: Projected.new,
      );

  @override
  R project<R extends Position>(
    Position source, {
    required CreatePosition<R> to,
  }) =>
      convertDatumToDatum(
        x: source.x,
        y: source.y,
        z: source.optZ,
        m: source.optM,
        sourceCrsType: sourceCrsType,
        targetCrsType: targetCrsType,
        sourceDatum: sourceDatum,
        targetDatum: targetDatum,
        to: to,
      );

  @override
  List<double> projectCoords(
    Iterable<double> source, {
    List<double>? target,
    required Coords type,
  }) =>
      convertDatumToDatumCoords(
        source,
        target: target,
        type: type,
        sourceCrsType: sourceCrsType,
        targetCrsType: targetCrsType,
        sourceDatum: sourceDatum,
        targetDatum: targetDatum,
      );
}
