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
import '/src/geodesy/ellipsoidal/utm.dart';

import 'base_ellipsoidal_projection.dart';

/// A projection adapter based on the Universal Transverse Mercator (UTM)
/// projection. Source and target coordinates can geographic (longitude,
/// latitude) or projected UTM (easting, northing) positions.
///
/// {@macro geobase.projections.ellipsoidal.overview}
@internal
class UtmProjectionAdapter with ProjectionAdapter {
  @override
  final CoordRefSys sourceCrs;

  @override
  final CoordRefSys targetCrs;

  final Projection _forward;
  final Projection _inverse;

  /// Create an adapter with the [forward] projection converting from geographic
  /// coordinates (in source datum) to projected UTM coordinates (in target
  /// datum).
  ///
  /// The [inverse] projection converts vice versa.
  ///
  /// {@macro geobase.projections.ellipsoidal.overview}
  ///
  /// {@macro geobase.projections.ellipsoidal.datums}
  UtmProjectionAdapter.geographicToProjected({
    this.sourceCrs = CoordRefSys.CRS84,
    required this.targetCrs,
    required UtmZone targetZone,
    Datum sourceDatum = Datum.WGS84,
    Datum targetDatum = Datum.WGS84,
  })  : _forward = _UtmProjection(
          sourceCrsType: CoordRefSysType.geographic,
          sourceDatum: sourceDatum,
          sourceZone: null,
          targetCrsType: CoordRefSysType.projected,
          targetDatum: targetDatum,
          targetZone: targetZone,
        ),
        _inverse = _UtmProjection(
          sourceCrsType: CoordRefSysType.projected,
          sourceDatum: targetDatum,
          sourceZone: targetZone,
          targetCrsType: CoordRefSysType.geographic,
          targetDatum: sourceDatum,
          targetZone: null,
        );

  /// Create an adapter with the [forward] projection converting from projected
  /// UTM coordinates (in [sourceZone] and source datum) to UTM coordinates (in
  /// [targetZone] and target datum).
  ///
  /// The [inverse] projection converts vice versa.
  ///
  /// {@macro geobase.projections.ellipsoidal.overview}
  ///
  /// {@macro geobase.projections.ellipsoidal.datums}
  UtmProjectionAdapter.projectedToProjected({
    required this.sourceCrs,
    required this.targetCrs,
    required UtmZone sourceZone,
    required UtmZone targetZone,
    required Datum sourceDatum,
    required Datum targetDatum,
  })  : _forward = _UtmProjection(
          sourceCrsType: CoordRefSysType.projected,
          sourceDatum: sourceDatum,
          sourceZone: sourceZone,
          targetCrsType: CoordRefSysType.projected,
          targetDatum: targetDatum,
          targetZone: targetZone,
        ),
        _inverse = _UtmProjection(
          sourceCrsType: CoordRefSysType.projected,
          sourceDatum: targetDatum,
          sourceZone: targetZone,
          targetCrsType: CoordRefSysType.projected,
          targetDatum: sourceDatum,
          targetZone: sourceZone,
        );

  @override
  Projection get forward => _forward;

  @override
  Projection get inverse => _inverse;
}

class _UtmProjection extends BaseEllipsoidalProjection<Position, Position> {
  final CoordRefSysType sourceCrsType;
  final CoordRefSysType targetCrsType;
  final UtmZone? sourceZone;
  final UtmZone? targetZone;

  _UtmProjection({
    required this.sourceCrsType,
    required this.targetCrsType,
    required super.sourceDatum,
    required super.targetDatum,
    required this.sourceZone,
    required this.targetZone,
  });

  @override
  Position projectXYZM(double x, double y, double? z, double? m) => convertUtm(
        x: x,
        y: y,
        z: z,
        m: m,
        sourceCrsType: sourceCrsType,
        targetCrsType: targetCrsType,
        sourceDatum: sourceDatum,
        targetDatum: targetDatum,
        sourceZone: sourceZone,
        targetZone: targetZone,
        // Use `Projected.new` for efficiency on temporary object.
        to: Projected.new,
      );

  @override
  R project<R extends Position>(
    Position source, {
    required CreatePosition<R> to,
  }) =>
      convertUtm(
        x: source.x,
        y: source.y,
        z: source.optZ,
        m: source.optM,
        sourceCrsType: sourceCrsType,
        targetCrsType: targetCrsType,
        sourceDatum: sourceDatum,
        targetDatum: targetDatum,
        sourceZone: sourceZone,
        targetZone: targetZone,
        to: to,
      );

  @override
  List<double> projectCoords(
    Iterable<double> source, {
    List<double>? target,
    required Coords type,
  }) =>
      convertUtmCoords(
        source,
        target: target,
        type: type,
        sourceCrsType: sourceCrsType,
        targetCrsType: targetCrsType,
        sourceDatum: sourceDatum,
        targetDatum: targetDatum,
        sourceZone: sourceZone,
        targetZone: targetZone,
      );
}
