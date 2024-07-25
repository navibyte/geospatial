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
  /// polygon outline (not to be confused with centroid).
  /// 
  /// The algorithm is ported from the
  /// [mapbox/polylabel](https://github.com/mapbox/polylabel) package based on
  /// JavaScript and published by MapBox. See also the
  /// [blog post](https://blog.mapbox.com/a-new-algorithm-for-finding-a-visual-center-of-a-polygon-7c77e6492fbc)
  /// (Aug 2016) by Vladimir Agafonkin introducing it.
  DistancedPosition polylabel({
    double precision = 1.0,
    bool debug = false,
    PositionScheme scheme = Position.scheme,
  }) =>
      _polylabel(
        this,
        precision: precision,
        debug: debug,
        scheme: scheme,
      );
}
