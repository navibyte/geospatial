// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:proj4dart/proj4dart.dart' as p4d;

import '/src/codes/coords.dart';
import '/src/coordinates/base.dart';
import '/src/coordinates/projection.dart';
import '/src/utils/format_validation.dart';

/// A projection adapter based on the Proj4dart package.
class Proj4d with ProjectionAdapter {
  /// Create an adapter with a projection [tuple] of the Proj4dart package.
  const Proj4d(this.fromCrs, this.toCrs, this.tuple);

  /// Resolves a projection adapter between [fromCode] and [toCode].
  ///
  /// As based on the Proj4dart package, it has built-in support for following
  /// crs codes: "EPSG:4326" (with alias "WGS84"), "EPSG:4269", "EPSG:3857"
  /// (with aliases "EPSG:3785", "GOOGLE", "EPSG:900913", "EPSG:102113").
  ///
  /// For all other crs codes, also a projection definition must be given via
  /// [fromDef] or [toDef]. Proj4 definition strings, OGC WKT definitions and
  /// ESRI WKT definitions are supported. More info from the Proj4dart package.
  ///
  /// Throws FormatException if projections could not be resolved.
  factory Proj4d.resolve(
    String fromCode,
    String toCode, {
    String? fromDef,
    String? toDef,
  }) =>
      Proj4d(
        fromCode,
        toCode,
        p4d.ProjectionTuple(
          fromProj: _resolveProj4dProjection(fromCode, fromDef),
          toProj: _resolveProj4dProjection(toCode, toDef),
        ),
      );

  /// Resolves a projection adapter between [fromCode] and [toCode].
  ///
  /// As based on the Proj4dart package, it has built-in support for following
  /// crs codes: "EPSG:4326" (with alias "WGS84"), "EPSG:4269", "EPSG:3857"
  /// (with aliases "EPSG:3785", "GOOGLE", "EPSG:900913", "EPSG:102113").
  ///
  /// For all other crs codes, also a projection definition must be given via
  /// [fromDef] or [toDef]. Proj4 definition strings, OGC WKT definitions and
  /// ESRI WKT definitions are supported. More info from the Proj4dart package.
  ///
  /// Returns null if projections could not be resolved.
  static Proj4d? tryResolve(
    String fromCode,
    String toCode, {
    String? fromDef,
    String? toDef,
  }) {
    try {
      return Proj4d.resolve(
        fromCode,
        toCode,
        fromDef: fromDef,
        toDef: toDef,
      );
    } on Exception {
      return null;
    }
  }

  /// A projection tuple contains source and target projections.
  final p4d.ProjectionTuple tuple;

  @override
  final String fromCrs;

  @override
  final String toCrs;

  @override
  Projection get forward => _ProjectionProxy(
        tuple: tuple,
        inverse: false,
      );

  @override
  Projection get inverse => _ProjectionProxy(
        tuple: tuple,
        inverse: true,
      );
}

class _ProjectionProxy with Projection {
  const _ProjectionProxy({
    required this.tuple,
    required this.inverse,
  });

  final p4d.ProjectionTuple tuple;
  final bool inverse;

  @override
  R project<R extends Position>(
    Position source, {
    required CreatePosition<R> to,
  }) {
    // source coordinates (as a Point instance of proj4dart)
    // (if geographical source coords: longitude is at x, latitude is at y)
    final hasZ = source.is3D;
    final point = hasZ
        ? p4d.Point.withZ(
            x: source.x.toDouble(),
            y: source.y.toDouble(),
            z: source.z.toDouble(),
          )
        : p4d.Point(
            x: source.x.toDouble(),
            y: source.y.toDouble(),
          );

    // project using forward or inverse projection of the tuple
    final p4d.Point projected;
    try {
      projected = inverse ? tuple.inverse(point) : tuple.forward(point);
    } catch (e) {
      throw FormatException(
        inverse ? 'Error (un)projecting a point' : 'Error projecting a point',
        e,
      );
    }

    // return a projected (or unprojected) point with m coordinate unchanged
    return to.call(
      x: projected.x,
      y: projected.y,
      z: projected.z,
      m: source.optM,
    );
  }

  @override
  List<double> projectCoords({
    required Iterable<double> source,
    List<double>? target,
    required Coords type,
  }) {
    final dim = type.coordinateDimension;
    final result = target ?? List<double>.filled(source.length, 0.0);

    var offset = 0;
    final iter = source.iterator;
    while (iter.moveNext()) {
      // source coordinates (as a Point instance of proj4dart)
      // (if geographical source coords: longitude is at x, latitude is at y)
      final x = iter.current;
      final y = iter.moveNext() ? iter.current : throw invalidCoordinates;
      final hasZ = type.is3D;
      final z = hasZ
          ? (iter.moveNext() ? iter.current : throw invalidCoordinates)
          : null;
      final hasM = type.isMeasured;
      final m = hasM
          ? (iter.moveNext() ? iter.current : throw invalidCoordinates)
          : null;
      final point =
          hasZ ? p4d.Point.withZ(x: x, y: y, z: z) : p4d.Point(x: x, y: y);

      // project using forward or inverse projection of the tuple
      final p4d.Point projected;
      try {
        projected = inverse ? tuple.inverse(point) : tuple.forward(point);
      } catch (e) {
        throw FormatException(
          inverse ? 'Error (un)projecting a point' : 'Error projecting a point',
          e,
        );
      }

      // save a projected (or unprojected) point (with m coordinate unchanged)
      // to the result coordinate value array
      result[offset] = projected.x;
      result[offset + 1] = projected.y;
      if (hasZ) {
        result[offset + 2] = projected.z ?? z ?? 0.0;
      }
      if (hasM) {
        result[offset + (hasZ ? 3 : 2)] = m ?? 0.0;
      }

      offset += dim;
    }

    return result;
  }
}

p4d.Projection _resolveProj4dProjection(String crs, [String? def]) {
  p4d.Projection? proj;
  try {
    // when no definition given, first check if a projection for code exists
    if (def == null) {
      proj = p4d.Projection.get(crs);
    }

    // if no projection exists and def given, then try to add one
    if (proj == null && def != null) {
      proj = p4d.Projection.add(crs, def);
    }
  } catch (e) {
    throw FormatException(
      'Cannot resolve a projection for $crs ($def)'
      ' with error $e',
    );
  }
  if (proj == null) {
    throw FormatException('Cannot resolve a projection for $crs ($def)');
  }
  return proj;
}
