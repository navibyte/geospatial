// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import 'package:collection/collection.dart';

import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_scheme.dart';
import '/src/coordinates/base/position_series.dart';
import '/src/geometric/base/distanced_position.dart';
import '/src/utils/geometry_calculations_cartesian.dart';

part 'polylabel.dart';

/// An extension of cartesian functions for areal geometries represented by an
/// iterable of position series objects each representing a linear ring in a
/// polygon geometry).
extension CartesianArealExtension on Iterable<PositionSeries> {
  /// Calculates the centroid for a polygon represented by this (an iterable of
  /// position series objects each representing a linear ring in a polygon
  /// geometry).
  ///
  /// The *centroid* is - as by definition - *a geometric center of mass of a
  /// geometry*. For *areal* geometries it's weighted by the area of areal
  /// geometries like polygons.
  ///
  /// Note that a centroid do not always locate inside a geometry.
  ///
  /// Returns null if a centroid position could not be calculated.
  ///
  /// Use [scheme] to set the position scheme:
  /// * `Position.scheme` for generic position data (geographic, projected or
  ///    any other), this is also the default
  /// * `Projected.scheme` for projected position data
  /// * `Geographic.scheme` for geographic position data
  ///
  /// More info about [Centroid](https://en.wikipedia.org/wiki/Centroid) can be
  /// read in Wikipedia.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // A polygon (with an exterior ring and one interior ring as a hole) as an
  /// // `Iterable<PositionSeries>` that is each ring is represented by an instance
  /// // of `PositionSeries`.
  /// final polygon = [
  ///  [35.0, 10.0, 45.0, 45.0, 15.0, 40.0, 10.0, 20.0, 35.0, 10.0].positions(),
  ///  [20.0, 30.0, 35.0, 35.0, 30.0, 20.0, 20.0, 30.0].positions(),
  /// ];
  ///
  /// // Prints: "Centroid pos: 27.407,28.765"
  /// final centroid = polygon.centroid2D();
  /// print('Centroid pos: ${centroid?.toText(decimals: 3)}');
  /// ```
  Position? centroid2D({PositionScheme scheme = Position.scheme}) {
    // the exterior linear ring
    final ext = firstOrNull;

    if (ext != null) {
      // optional interior linear rings
      final interior = skip(1);

      final cext = ext.centroid2D(scheme: scheme);
      if (cext != null) {
        final aext = ext.signedArea2D().abs();
        if (aext > 0.0) {
          final calculator = CompositeCentroid()
            // "positive" weighted centroid for an exterior ring
            ..addCentroid2D(cext, area: aext);

          // "negative" weighted centroids for interior rings
          // (only holes with area are used)
          for (final hole in interior) {
            final chole = hole.centroid2D(scheme: scheme);
            if (chole != null) {
              final ahole = hole.signedArea2D().abs();
              if (ahole > 0.0) {
                calculator.addCentroid2D(chole, area: -ahole);
              }
            }
          }

          // return composite if non-null, otherwise just centroid for exterior
          final composite = calculator.centroid2D(scheme: scheme);
          return composite ?? cext;
        } else {
          // no area, return linear or punctual centroid for exterior
          return cext;
        }
      }
    }

    return null;
  }

  /// Calculates `polylabel` for a polygon represented by this (an iterable of
  /// position series objects each representing a linear ring in a polygon
  /// geometry).
  ///
  /// The `polylabel` is a fast algorithm for finding polygon
  /// *pole of inaccessibility*, the most distant internal point from the
  /// polygon exterior ring (not to be confused with centroid).
  ///
  /// Use [precision] to set the precision for calculations (by default `1.0`).
  ///
  /// Use [scheme] to set the position scheme:
  /// * `Position.scheme` for generic position data (geographic, projected or
  ///    any other), this is also the default
  /// * `Projected.scheme` for projected position data
  /// * `Geographic.scheme` for geographic position data
  ///
  /// The algorithm is ported from the
  /// [mapbox/polylabel](https://github.com/mapbox/polylabel) package based on
  /// JavaScript and published by MapBox. See also the
  /// [blog post](https://blog.mapbox.com/a-new-algorithm-for-finding-a-visual-center-of-a-polygon-7c77e6492fbc)
  /// (Aug 2016) by Vladimir Agafonkin introducing it.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // A polygon (with an exterior ring and one interior ring as a hole) as an
  /// // `Iterable<PositionSeries>` that is each ring is represented by an instance
  /// // of `PositionSeries`.
  /// final polygon = [
  ///  [35.0, 10.0, 45.0, 45.0, 15.0, 40.0, 10.0, 20.0, 35.0, 10.0].positions(),
  ///  [20.0, 30.0, 35.0, 35.0, 30.0, 20.0, 20.0, 30.0].positions(),
  /// ];
  ///
  /// // Prints: "Polylabel pos: 17.3828125,23.9453125 dist: 6.131941618102092"
  /// final p = polygon.polylabel2D(precision: 0.5);
  /// print('Polylabel pos: ${p.position} dist: ${p.distance}');
  /// ```
  DistancedPosition polylabel2D({
    double precision = 1.0,
    bool debug = false,
    PositionScheme scheme = Position.scheme,
  }) =>
      _polylabel2D(
        this,
        precision: precision,
        debug: debug,
        scheme: scheme,
      );

  /// Returns true if [point] is inside a valid polygon represented by this
  /// iterable of position series objects calculated in a cartesian 2D plane.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // A polygon (with an exterior ring and one interior ring as a hole) as an
  /// // `Iterable<PositionSeries>` that is each ring is represented by an instance
  /// // of `PositionSeries`.
  /// final polygon = [
  ///  [35.0, 10.0, 45.0, 45.0, 15.0, 40.0, 10.0, 20.0, 35.0, 10.0].positions(),
  ///  [20.0, 30.0, 35.0, 35.0, 30.0, 20.0, 20.0, 30.0].positions(),
  /// ];
  ///
  /// // prints: (20,20) => true, (10,10) => false
  /// final inside = polygon.isPointInPolygon2D([20.0, 20.0].xy);
  /// final outside = polygon.isPointInPolygon2D([10.0, 10.0].xy);
  /// print('(20,20) => $inside, (10,10) => $outside');
  /// ```
  bool isPointInPolygon2D(Position point) {
    // the exterior linear ring
    final ext = firstOrNull;

    // point must be inside the exterior linear ring ...
    if (ext != null && ext.isPointInPolygon2D(point)) {
      // ... but it must be outside of any optional interior linear rings
      final interior = skip(1);
      for (final hole in interior) {
        if (hole.isPointInPolygon2D(point)) {
          return false;
        }
      }
      return true;
    }

    return false;
  }
}
