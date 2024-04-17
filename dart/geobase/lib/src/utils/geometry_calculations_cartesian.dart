// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/coordinates/base/position.dart';

/// A helper class to calculate areal, linear or punctual centroids for
/// composite geometries.
@internal
class CompositeCentroid {
  // See https://en.wikipedia.org/wiki/Centroid / "By geometric decomposition"

  // state for calculating a centroid for areal geometries
  var _areaSum = 0.0;
  var _arealX = 0.0;
  var _arealY = 0.0;

  // state for calculating a centroid for linear geometries
  var _lengthSum = 0.0;
  var _linearX = 0.0;
  var _linearY = 0.0;

  // state for calculating a centroid for punctual geometries
  var _numPoints = 0;
  var _punctualX = 0.0;
  var _punctualY = 0.0;

  void addCentroid2D(Position? pos, {double? area, double? length}) {
    if (pos != null) {
      addCentroidXY(
        x: pos.x,
        y: pos.y,
        area: area ?? 0.0,
        length: length ?? 0.0,
      );
    }
  }

  void addCentroidXY({
    required double x,
    required double y,
    double area = 0.0,
    double length = 0.0,
  }) {
    if (area != 0.0) {
      // positive or negative area
      _areaSum += area;
      _arealX += area * x;
      _arealY += area * y;
    } else if (length > 0.0) {
      // positive length
      _lengthSum += length;
      _linearX += length * x;
      _linearY += length * y;
    } else {
      _numPoints++;
      _punctualX += x;
      _punctualY += y;
    }
  }

  Position? centroid() {
    if (_areaSum > 0.0) {
      return Position.create(
        x: _arealX / _areaSum,
        y: _arealY / _areaSum,
      );
    } else if (_lengthSum > 0.0) {
      return Position.create(
        x: _linearX / _lengthSum,
        y: _linearY / _lengthSum,
      );
    } else if (_numPoints > 0) {
      return Position.create(
        x: _punctualX / _numPoints,
        y: _punctualY / _numPoints,
      );
    }

    return null;
  }
}
