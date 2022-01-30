// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import '/src/base/spatial.dart';

/// A helper class to calculate [bounds] for a set of points and other bounds.
///
/// Use [addPoint] and [addBounds] methods to add geometries to be used on
/// calculation. A value for calculations can be obtained from [bounds].
class BoundsBuilder {
  /// Creates a new builder to calculate [bounds].
  BoundsBuilder();

  int _spatialDims = 0;
  bool _hasM = false;
  Point? _firstOfType;

  num _minx = double.nan;
  num _miny = double.nan;
  num _minz = double.nan;
  num _minm = double.nan;
  num _maxx = double.nan;
  num _maxy = double.nan;
  num _maxz = double.nan;
  num _maxm = double.nan;

  /// Adds a [point] to be used on bounds calculation.
  void addPoint(Point point) {
    var sdims = _spatialDims;
    if (point.spatialDimension > sdims) {
      // latest point has more spatial dims than previous ones, so update
      sdims = _spatialDims = point.spatialDimension;
      _firstOfType = point;
      _hasM = point.hasM;
    } else if (point.spatialDimension == sdims && (!_hasM && point.hasM)) {
      // or it has same amount of spatial dims but has also M coordinate
      _hasM = true;
      _firstOfType = point;
    }

    // update min and max values
    _minx = _min(_minx, point.x);
    _miny = _min(_miny, point.y);
    _maxx = _max(_maxx, point.x);
    _maxy = _max(_maxy, point.y);
    if (sdims >= 3) {
      _minz = _min(_minz, point.z);
      _maxz = _max(_maxz, point.z);
    }
    if (_hasM) {
      _minm = _min(_minm, point.m);
      _maxm = _max(_maxm, point.m);
    }
  }

  static num _min(num min, num value) =>
      min.isNaN ? value : math.min(min, value);

  static num _max(num max, num value) =>
      max.isNaN ? value : math.max(max, value);

  /// Adds a [bounds] to be used on bounds calculation.
  void addBounds(Bounds bounds) {
    addPoint(bounds.min);
    addPoint(bounds.max);
  }

  /// The bounds for the current set of added points and bounds.
  Bounds get bounds {
    final p = _firstOfType;
    if (p != null) {
      if (_spatialDims == 2) {
        return !_hasM
            ? Bounds.of(
                min: p.newWith(x: _minx, y: _miny),
                max: p.newWith(x: _maxx, y: _maxy),
              )
            : Bounds.of(
                min: p.newWith(x: _minx, y: _miny, m: _minm),
                max: p.newWith(x: _maxx, y: _maxy, m: _maxm),
              );
      } else if (_spatialDims >= 3) {
        return !_hasM
            ? Bounds.of(
                min: p.newWith(x: _minx, y: _miny, z: _minz),
                max: p.newWith(x: _maxx, y: _maxy, z: _maxz),
              )
            : Bounds.of(
                min: p.newWith(x: _minx, y: _miny, z: _minz, m: _minm),
                max: p.newWith(x: _maxx, y: _maxy, z: _maxz, m: _maxm),
              );
      }
    }
    // couldn't calculate
    throw const FormatException('Could not calculate bounds.');
  }
}
