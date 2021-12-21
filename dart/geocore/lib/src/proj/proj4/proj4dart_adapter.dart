// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:proj4dart/proj4dart.dart' as proj4;

import '../../base.dart';

/// Resolves a projection adapter between [fromCode] and [toCode].
///
/// As based on the Proj4dart package, it has built-in support for following
/// codes: "EPSG:4326" (with alias "WGS84"), "EPSG:4269", "EPSG:3857" (with
/// aliases "EPSG:3785", "GOOGLE", "EPSG:900913", "EPSG:102113").
///
/// For all other codes, also a projection definition must be given via
/// [fromDef] or [toDef]. Proj4 definition strings, OGC WKT definitions and
/// ESRI WKT definitions are supported. More info from the Proj4dart package.
///
/// Throws FormatException if projections could not be resolved.
Proj4Adapter proj4dart(
  String fromCode,
  String toCode, {
  String? fromDef,
  String? toDef,
}) =>
    Proj4Adapter.resolve(fromCode, toCode, fromDef: fromDef, toDef: toDef);

/// A projection adapter based on the Proj4dart package.
class Proj4Adapter with ProjectionAdapter<Point, Point> {
  /// Create an adapter with a projection [tuple] of the Proj4dart package.
  const Proj4Adapter(this.fromCode, this.toCode, this.tuple);

  /// Resolves a projection adapter between [fromCode] and [toCode].
  ///
  /// As based on the Proj4dart package, it has built-in support for following
  /// codes: "EPSG:4326" (with alias "WGS84"), "EPSG:4269", "EPSG:3857" (with
  /// aliases "EPSG:3785", "GOOGLE", "EPSG:900913", "EPSG:102113").
  ///
  /// For all other codes, also a projection definition must be given via
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
        proj4.ProjectionTuple(
          fromProj: _resolveProjection(fromCode, fromDef),
          toProj: _resolveProjection(toCode, toDef),
        ),
      );

  /// Resolves a projection adapter between [fromCode] and [toCode].
  ///
  /// As based on the Proj4dart package, it has built-in support for following
  /// codes: "EPSG:4326" (with alias "WGS84"), "EPSG:4269", "EPSG:3857" (with
  /// aliases "EPSG:3785", "GOOGLE", "EPSG:900913", "EPSG:102113").
  ///
  /// For all other codes, also a projection definition must be given via
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
  final proj4.ProjectionTuple tuple;

  @override
  final String fromCode;

  @override
  final String toCode;

  @override
  ProjectPoint<R> forward<R extends Point>(PointFactory<R> factory) =>
      (Point source, {PointFactory<R>? to}) {
        // source coordinates (as a Point instance of proj4dart)
        // (if geographical source coords: longitude is at x, latitude is at y)
        final hasZ = source.is3D;
        final point = hasZ
            ? proj4.Point.withZ(
                x: source.x.toDouble(),
                y: source.y.toDouble(),
                z: source.z.toDouble(),
              )
            : proj4.Point(
                x: source.x.toDouble(),
                y: source.y.toDouble(),
              );

        // project using forward projection of the tuple
        final proj4.Point projected;
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
            ? proj4.Point.withZ(
                x: source.x.toDouble(),
                y: source.y.toDouble(),
                z: source.z.toDouble(),
              )
            : proj4.Point(
                x: source.x.toDouble(),
                y: source.y.toDouble(),
              );

        // (un)project using inverse projection of the tuple
        final proj4.Point projected;
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

proj4.Projection _resolveProjection(String code, [String? def]) {
  proj4.Projection? proj;
  try {
    // when no definition given, first check if a projection for code exists
    if (def == null) {
      proj = proj4.Projection.get(code);
    }

    // if no projection exists and def given, then try to add one
    if (proj == null && def != null) {
      proj = proj4.Projection.add(code, def);
    }
  } catch (e) {
    throw FormatException(
      'Cannot resolve a projection for $code ($def)'
      ' with error $e',
    );
  }
  if (proj == null) {
    throw FormatException('Cannot resolve a projection for $code ($def)');
  }
  return proj;
}
