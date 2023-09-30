// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_series.dart';
import '/src/vector_data/model/bounded/bounded.dart';

/// A helper class to calculate bounds for a set of points and other bounds.
///
/// Use [addPoint], [addPosition], [addPositionSeries] and [addBounds] methods
/// to add geometries to be used on calculation.
///
/// Also a helper static methods [calculateBounds] helps calculating bounds for
/// different kind of position collections.
///
/// The result for calculations can be obtained from [boxCoords].
@internal
class BoundsBuilder {
  /// Creates a new builder to calculate bounds for coordinate [type].
  BoundsBuilder(this.type);

  /// Calculates bounds for [item] and/or [collection] and/or [series] and/or
  /// [seriesArray] and/or [positions] using the builder.
  static Box? calculateBounds<E extends Bounded>({
    E? item,
    Iterable<E>? collection,
    PositionSeries? series,
    Iterable<PositionSeries>? seriesArray,
    Iterable<Position>? positions,
    required Coords type,
    bool recalculateChilds = false,
  }) {
    if (item == null &&
        (collection == null || collection.isEmpty) &&
        (series == null || series.isEmpty) &&
        (seriesArray == null || seriesArray.isEmpty) &&
        (positions == null || positions.isEmpty)) return null;

    // use bounds builder to calculate bounds
    final builder = BoundsBuilder(type);

    if (item != null) {
      final bounds = recalculateChilds || item.bounds == null
          ? item.calculateBounds()
          : item.bounds;
      if (bounds != null) {
        builder.addBounds(bounds);
      }
    }

    if (collection != null) {
      for (final elem in collection) {
        final bounds = recalculateChilds || elem.bounds == null
            ? elem.calculateBounds()
            : elem.bounds;
        if (bounds != null) {
          builder.addBounds(bounds);
        }
      }
    }

    if (series != null) {
      builder.addPositionSeries(series);
    }

    if (seriesArray != null) {
      for (final s in seriesArray) {
        builder.addPositionSeries(s);
      }
    }

    if (positions != null) {
      for (final pos in positions) {
        builder.addPosition(pos);
      }
    }

    final box = builder.boxCoords;
    return box != null ? Box.view(box, type: type) : null;
  }

  /// The coordinate type for geometries.
  final Coords type;

  double _minx = double.nan;
  double _miny = double.nan;
  double _minz = double.nan;
  double _minm = double.nan;
  double _maxx = double.nan;
  double _maxy = double.nan;
  double _maxz = double.nan;
  double _maxm = double.nan;

  /// Adds point (x, y) with optional z and m to be used on bounds calculation.
  void addPoint({
    required double x,
    required double y,
    double? z,
    double? m,
  }) {
    // update min and max values
    _minx = _min(_minx, x);
    _miny = _min(_miny, y);
    _maxx = _max(_maxx, x);
    _maxy = _max(_maxy, y);
    if (type.is3D) {
      _minz = _min(_minz, z ?? 0.0);
      _maxz = _max(_maxz, z ?? 0.0);
    }
    if (type.isMeasured) {
      _minm = _min(_minm, m ?? 0.0);
      _maxm = _max(_maxm, m ?? 0.0);
    }
  }

  /// Adds a [point] to be used on bounds calculation.
  void addPosition(Position point) => addPoint(
        x: point.x,
        y: point.y,
        z: point.optZ,
        m: point.optM,
      );

  /// Adds position [series] to be used on bounds calculation.
  void addPositionSeries(PositionSeries series) {
    switch (type) {
      case Coords.xy:
        for (var i = 0; i < series.positionCount; i++) {
          addPoint(x: series.x(i), y: series.y(i));
        }
        break;
      case Coords.xyz:
        for (var i = 0; i < series.positionCount; i++) {
          addPoint(x: series.x(i), y: series.y(i), z: series.z(i));
        }
        break;
      case Coords.xym:
        for (var i = 0; i < series.positionCount; i++) {
          addPoint(x: series.x(i), y: series.y(i), m: series.m(i));
        }
        break;
      case Coords.xyzm:
        for (var i = 0; i < series.positionCount; i++) {
          addPoint(
            x: series.x(i),
            y: series.y(i),
            z: series.z(i),
            m: series.m(i),
          );
        }
        break;
    }
  }

  /// Adds a [bounds] to be used on bounds calculation.
  void addBounds(Box bounds) {
    addPoint(
      x: bounds.minX,
      y: bounds.minY,
      z: bounds.minZ,
      m: bounds.minM,
    );
    addPoint(
      x: bounds.maxX,
      y: bounds.maxY,
      z: bounds.maxZ,
      m: bounds.maxM,
    );
  }

  /// The bounds for the current set of added points and bounds.
  List<double>? get boxCoords {
    if (!_minx.isNaN && !_miny.isNaN && !_maxx.isNaN && !_maxy.isNaN) {
      if (!type.is3D) {
        return !type.isMeasured
            ? [_minx, _miny, _maxx, _maxy]
            : [_minx, _miny, _minm, _maxx, _maxy, _maxm];
      } else {
        return !type.isMeasured
            ? [_minx, _miny, _minz, _maxx, _maxy, _maxz]
            : [_minx, _miny, _minz, _minm, _maxx, _maxy, _maxz, _maxm];
      }
    }

    // couldn't calculate
    return null;
  }

  static double _min(double min, double value) {
    if (value.isNaN) return min;

    return min.isNaN ? value : math.min(min, value);
  }

  static double _max(double max, double value) {
    if (value.isNaN) return max;

    return max.isNaN ? value : math.max(max, value);
  }
}
