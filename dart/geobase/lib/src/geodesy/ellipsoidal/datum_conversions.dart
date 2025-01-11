// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'datum.dart';

// -----------------------------------------------------------------------------
// Internal functions to implement geocentric and geographic conversions with
// as low overhead as possible. These functions are used by projections classes.
//
// Functions are not exported, so marked as internal. In future these functions
// could be optimized further by using records or other efficient data
// structures.

void _checkConvertDatumToDatum({
  required CoordRefSysType sourceCrsType,
  required CoordRefSysType targetCrsType,
}) {
  if (!(sourceCrsType.isGeographicOrGeocentric &&
      targetCrsType.isGeographicOrGeocentric)) {
    throw ArgumentError(
      'Invalid source or target coordinate reference system type',
    );
  }
}

/// Converts the position specified by [x], [y], [z] and [m] in this datum to
/// a position of [R] in another datum specified by [targetDatum].
///
/// {@template geobase.geodesy.datum.convert_params}
///
/// If [targetDatum] is `null`, then datum transformation is not applied.
///
/// Currently only geographic and geocentric coordinate systems are supported
/// (soure and target types are defined by [sourceCrsType] and [targetCrsType]).
///
/// {@endtemplate}
///
/// The position is returned as a new instance of [R] created by [to].
@internal
R convertDatumToDatum<R extends Position>({
  required double x,
  required double y,
  double? z,
  double? m,
  required CoordRefSysType sourceCrsType,
  required CoordRefSysType targetCrsType,
  required Datum sourceDatum,
  required Datum? targetDatum,
  required CreatePosition<R> to,
}) {
  _checkConvertDatumToDatum(
    sourceCrsType: sourceCrsType,
    targetCrsType: targetCrsType,
  );

  return _convertDatumToDatum(
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

R _convertDatumToDatum<R extends Position>({
  required double x,
  required double y,
  double? z,
  double? m,
  required CoordRefSysType sourceCrsType,
  required CoordRefSysType targetCrsType,
  required Datum sourceDatum,
  required Datum? targetDatum,
  required CreatePosition<R> to,
}) {
  final is3D = z != null;

  // geocentric to geocentric conversion
  if (sourceCrsType.isGeocentric && targetCrsType.isGeocentric) {
    if (targetDatum == null) {
      // no target datum, just return the source position
      return to.call(x: x, y: y, z: z, m: m);
    } else {
      return sourceDatum._convertGeocentricCartesianInternal(
        x: x, y: y, z: z ?? 0.0, m: m, // source position is geocentric
        target: targetDatum,
        to: to,
      );
    }
  }

  // geographic to geographic conversion
  if (sourceCrsType.isGeographic && targetCrsType.isGeographic) {
    if (targetDatum == null) {
      // no target datum, just return the source position
      return to.call(x: x, y: y, z: z, m: m);
    } else {
      return sourceDatum._convertGeographicInternal(
        lon: x, // longitude = x
        lat: y, // latitude = y
        elev: z,
        m: m,
        target: targetDatum,
        to: to,
        omitElev: !is3D,
      );
    }
  }

  // source and target are not of same type of coordinates, conversion must go
  // through geocentric cartesian coordinates

  if (sourceCrsType.isGeographic) {
    // if source is geographic, then target is geocentric

    if (targetDatum != null) {
      // need sourceDatum to targetDatum conversion

      // first convert source to geocentric cartesian
      final sourceCartesian = geographicToGeocentricCartesian(
        lon: x, // longitude = x
        lat: y, // latitude = y
        elev: z,
        m: m,
        ellipsoid: sourceDatum.ellipsoid,
        to: Projected.new, // use for efficiency on temporary object
      );

      // convert to target geocentric on target datum
      return sourceDatum._convertGeocentricCartesianInternal(
        x: sourceCartesian.x,
        y: sourceCartesian.y,
        z: sourceCartesian.z,
        m: sourceCartesian.optM,
        target: targetDatum,
        to: to,
      );
    } else {
      // no target datum, just convert source geographic to geocentric
      return geographicToGeocentricCartesian(
        lon: x, // longitude = x
        lat: y, // latitude = y
        elev: z,
        m: m,
        ellipsoid: sourceDatum.ellipsoid,
        to: to,
      );
    }
  } else {
    // if source is geocentric, then target is geographic

    if (targetDatum != null) {
      // need sourceDatum to targetDatum conversion

      // first convert source to geocentric cartesian on target datum
      final targetCartesian = sourceDatum._convertGeocentricCartesianInternal(
        x: x, y: y, z: z ?? 0.0, m: m,
        target: targetDatum,
        to: Projected.new, // use for efficiency on temporary object
      );

      // then convert geocentric coordinates to geographic on target datum
      return geocentricCartesianToGeographic(
        x: targetCartesian.x,
        y: targetCartesian.y,
        z: targetCartesian.z,
        m: targetCartesian.optM,
        ellipsoid: targetDatum.ellipsoid,
        to: to,
      );
    } else {
      // no target datum, just convert source geocentric to geographic
      return geocentricCartesianToGeographic(
        x: x,
        y: y,
        z: z ?? 0.0,
        m: m,
        ellipsoid: sourceDatum.ellipsoid,
        to: to,
      );
    }
  }
}

/// Converts the positions specified by [source] in this datum to positions of
/// another datum specified by [targetDatum].
///
/// {@macro geobase.geodesy.datum.convert_params}
/// 
/// {@template geobase.geodesy.datum.iterable_coords}
///
/// The positions are given as an iterable of coordinates where each position
/// contains coordinate values as specified by [type]. The result is returned
/// in as a list of coordinates with the same structure as the source. If
/// [target] is provided, then the returned result is stored in that list.
/// 
/// {@endtemplate}
@internal
List<double> convertDatumToDatumCoords(
  Iterable<double> source, {
  List<double>? target,
  required Coords type,
  required CoordRefSysType sourceCrsType,
  required CoordRefSysType targetCrsType,
  required Datum sourceDatum,
  required Datum? targetDatum,
}) {
  _checkConvertDatumToDatum(
    sourceCrsType: sourceCrsType,
    targetCrsType: targetCrsType,
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
    final targetPosition = _convertDatumToDatum(
      x: coord0, // x
      y: coord1, // y
      z: hasZ ? coord2 : null, // z
      m: hasZ ? coord3 : coord2, // m
      sourceCrsType: sourceCrsType,
      targetCrsType: targetCrsType,
      sourceDatum: sourceDatum,
      targetDatum: targetDatum,
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
