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

part 'polylabel.dart';

/// An extension of cartesian functions for areal geometries represented by an
/// iterable of position series objects each representing a linear ring in a
/// polygon geometry).
extension CartesianArealExtension on Iterable<PositionSeries> {
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
}
