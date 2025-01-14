// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'utm.dart';

// -----------------------------------------------------------------------------
// Internal functions to implement UTM projected and geographic conversions with
// as low overhead as possible. These functions are used by projections classes.
//
// Functions are not exported, so marked as internal. In future these functions
// could be optimized further by using records or other efficient data
// structures.

void _checkConvertUtm({
  required CoordRefSysType sourceCrsType,
  required CoordRefSysType targetCrsType,
  UtmZone? sourceZone,
  UtmZone? targetZone,
}) {
  if (!(sourceCrsType.isGeographicOrProjected &&
      targetCrsType.isGeographicOrProjected)) {
    throw ArgumentError(
      'Invalid source or target coordinate reference system type',
    );
  }

  if (sourceCrsType.isProjected && sourceZone == null) {
    throw ArgumentError('Invalid source zone');
  }

  // target zone and hemisphere are needed only when target is UTM projected and
  // zone should be forced to the target zone, so no need to check them here
}

/// Converts the position specified by [x], [y], [z] and [m] in this datum to
/// a position of [R] in another datum specified by [targetDatum].
///
/// {@template geobase.geodesy.utm.convert_params}
///
/// If [targetDatum] is `null`, then datum transformation is not applied.
///
/// Currently only geographic and UTM projected coordinate systems are supported
/// (soure and target types are defined by [sourceCrsType] and [targetCrsType]).
///
/// The [sourceZone] is needed only when source is UTM projected. The
/// [targetZone] is needed only when target is UTM projected and the zone should
/// be forced to the target zone.
///
/// {@endtemplate}
///
/// The position is returned as a new instance of [R] created by [to].
@internal
R convertUtm<R extends Position>({
  required double x,
  required double y,
  double? z,
  double? m,
  required CoordRefSysType sourceCrsType,
  required CoordRefSysType targetCrsType,
  required Datum sourceDatum,
  required Datum? targetDatum,
  UtmZone? sourceZone,
  UtmZone? targetZone,
  required CreatePosition<R> to,
}) {
  // geographic to geographic conversion
  if (sourceCrsType.isGeographic && targetCrsType.isGeographic) {
    // use datum conversions
    return convertDatumToDatum(
      x: x,
      y: y,
      z: z,
      m: m,
      sourceCrsType: sourceCrsType,
      targetCrsType: targetCrsType,
      sourceDatum: sourceDatum,
      targetDatum: targetDatum,
      to: to,
    );
  }

  // assume utm conversions, check parameters
  _checkConvertUtm(
    sourceCrsType: sourceCrsType,
    targetCrsType: targetCrsType,
    sourceZone: sourceZone,
    targetZone: targetZone,
  );

  // between geographic and UTM (or UTM to UTM) conversions
  return _convertUtm(
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
    to: to,
  );
}

R _convertUtm<R extends Position>({
  required double x,
  required double y,
  double? z,
  double? m,
  required CoordRefSysType sourceCrsType,
  required CoordRefSysType targetCrsType,
  required Datum sourceDatum,
  required Datum? targetDatum,
  UtmZone? sourceZone,
  UtmZone? targetZone,
  required CreatePosition<R> to,
}) {
  // first convert to geographic coordinates in the source datum
  final Geographic sourceGeo;
  if (sourceCrsType.isGeographic) {
    // source is already geographic
    sourceGeo = Geographic(lon: x, lat: y, elev: z, m: m);
  } else {
    // source is UTM projected, convert to geographic
    final sourceUtm = utmToGeographic(
      zone: sourceZone!,
      easting: x,
      northing: y,
      elev: z,
      m: m,
      datum: sourceDatum,
      roundResults: false,
      to: Geographic.create,
    );
    sourceGeo = sourceUtm.position;
  }

  if (targetCrsType.isGeographic) {
    // target is geographic

    // if target datum is specified, convert to target datum
    if (targetDatum != null) {
      return convertGeographicInternal(
        lon: sourceGeo.lon,
        lat: sourceGeo.lat,
        elev: sourceGeo.optElev,
        m: sourceGeo.optM,
        source: sourceDatum,
        target: targetDatum,
        to: to,
        omitElev: !sourceGeo.is3D,
      );
    } else {
      return sourceGeo.copyTo(to);
    }
  } else {
    // target is UTM projected

    // if target datum is specified, convert to target datum
    final targetGeo = targetDatum != null
        ? sourceDatum.convertGeographic(sourceGeo, target: targetDatum)
        : sourceGeo;

    // then convert to UTM in the target datum (or if null then in source datum)
    final targetUtm2 = geographicToUtm(
      lon: targetGeo.lon,
      lat: targetGeo.lat,
      elev: targetGeo.optElev,
      m: targetGeo.optM,
      zone: targetZone,
      datum: targetDatum ?? sourceDatum,
      to: to,
    );
    return targetUtm2.position;
  }
}

/// Converts the positions specified by [source] in this datum to positions of
/// another datum specified by [targetDatum].
///
/// {@macro geobase.geodesy.utm.convert_params}
///
/// {@macro geobase.geodesy.datum.iterable_coords}
@internal
List<double> convertUtmCoords(
  Iterable<double> source, {
  List<double>? target,
  required Coords type,
  required CoordRefSysType sourceCrsType,
  required CoordRefSysType targetCrsType,
  required Datum sourceDatum,
  required Datum? targetDatum,
  UtmZone? sourceZone,
  UtmZone? targetZone,
}) {
  // geographic to geographic conversion
  if (sourceCrsType.isGeographic && targetCrsType.isGeographic) {
    // use datum conversions
    return convertDatumToDatumCoords(
      source,
      target: target,
      type: type,
      sourceCrsType: sourceCrsType,
      targetCrsType: targetCrsType,
      sourceDatum: sourceDatum,
      targetDatum: targetDatum,
    );
  }

  // assume utm conversions, check parameters
  _checkConvertUtm(
    sourceCrsType: sourceCrsType,
    targetCrsType: targetCrsType,
    sourceZone: sourceZone,
    targetZone: targetZone,
  );

  final dim = type.coordinateDimension;
  final hasZ = type.is3D;
  final hasM = type.isMeasured;
  final result = target ?? Float64List(source.length);

  var offset = 0;
  final iter = source.iterator;
  while (iter.moveNext()) {
    // get source coordinates from the coordinate value iterator
    final coord0 = iter.current;
    final coord1 = iter.moveNext() ? iter.current : throw invalidCoordinates;
    final coord2 = dim >= 3
        ? (iter.moveNext() ? iter.current : throw invalidCoordinates)
        : null;
    final coord3 = dim >= 4
        ? (iter.moveNext() ? iter.current : throw invalidCoordinates)
        : null;

    // convert source to target position coordinates
    final targetPosition = _convertUtm(
      x: coord0, // x
      y: coord1, // y
      z: hasZ ? coord2 : null, // z
      m: hasZ ? coord3 : coord2, // m
      sourceCrsType: sourceCrsType,
      targetCrsType: targetCrsType,
      sourceDatum: sourceDatum,
      targetDatum: targetDatum,
      sourceZone: sourceZone,
      targetZone: targetZone,
      // Use `Projected.new` for efficiency on temporary object.
      to: Projected.new,
    );

    // set target coordinates to the result array
    result[offset] = targetPosition.x;
    result[offset + 1] = targetPosition.y;
    if (hasZ) {
      result[offset + 2] = targetPosition.z;
      if (hasM) {
        result[offset + 3] = targetPosition.m;
      }
    } else if (hasM) {
      result[offset + 2] = targetPosition.m;
    }

    offset += dim;
  }

  return result;
}
