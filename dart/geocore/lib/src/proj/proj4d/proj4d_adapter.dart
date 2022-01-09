// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:proj4dart/proj4dart.dart' as p4d;

import '/src/base/spatial.dart';

/// Resolves a projection adapter between [fromCrs] and [toCrs].
///
/// As based on the Proj4dart package, it has built-in support for following crs
/// codes: "EPSG:4326" (with alias "WGS84"), "EPSG:4269", "EPSG:3857" (with
/// aliases "EPSG:3785", "GOOGLE", "EPSG:900913", "EPSG:102113").
///
/// For all other crs codes, also a projection definition must be given via
/// [fromDef] or [toDef]. Proj4 definition strings, OGC WKT definitions and
/// ESRI WKT definitions are supported. More info from the Proj4dart package.
///
/// Throws FormatException if projections could not be resolved.
Proj4Adapter proj4dart(
  String fromCrs,
  String toCrs, {
  String? fromDef,
  String? toDef,
}) =>
    Proj4Adapter.resolve(fromCrs, toCrs, fromDef: fromDef, toDef: toDef);

/// A projection adapter based on the Proj4dart package.
class Proj4Adapter with ProjectionAdapter<Point, Point> {
  /// Create an adapter with a projection [tuple] of the Proj4dart package.
  const Proj4Adapter(this.fromCrs, this.toCrs, this.tuple);

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
  static Proj4Adapter resolve(
    String fromCode,
    String toCode, {
    String? fromDef,
    String? toDef,
  }) =>
      Proj4Adapter(
        fromCode,
        toCode,
        p4d.ProjectionTuple(
          fromProj: _resolveProjection(fromCode, fromDef),
          toProj: _resolveProjection(toCode, toDef),
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
  static Proj4Adapter? tryResolve(
    String fromCode,
    String toCode, {
    String? fromDef,
    String? toDef,
  }) {
    try {
      return Proj4Adapter.resolve(
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
  ProjectPoint<R> forward<R extends Point>(PointFactory<R> factory) =>
      (Point source, {PointFactory<R>? to}) {
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

        // project using forward projection of the tuple
        final p4d.Point projected;
        try {
          projected = tuple.forward(point);
        } catch (e) {
          throw FormatException('Error projecting a point', e);
        }

        // return a projected point with m coordinate unchanged
        return (to ?? factory).newWith(
          x: projected.x,
          y: projected.y,
          z: projected.z,
          m: source.m,
        );
      };

  @override
  ProjectPoint<R> inverse<R extends Point>(PointFactory<R> factory) =>
      (Point source, {PointFactory<R>? to}) {
        // source coordinates (as a Point instance of proj4dart)
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

        // (un)project using inverse projection of the tuple
        final p4d.Point projected;
        try {
          projected = tuple.inverse(point);
        } catch (e) {
          throw FormatException('Error (un)projecting a point', e);
        }

        // return an (un)projected point with optional m coordinate unchanged
        return (to ?? factory).newWith(
          x: projected.x,
          y: projected.y,
          z: projected.z,
          m: source.m,
        );
      };
}

p4d.Projection _resolveProjection(String crs, [String? def]) {
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
