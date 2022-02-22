// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import 'package:meta/meta.dart';

import '/src/base/codes.dart';

import 'box.dart';
import 'position.dart';
import 'projected.dart';

/// A bounding box with [minX], [minY], [maxX] and [maxY] coordinates.
///
/// Optional [minZ] and [maxZ] for 3D boxes, and [minM] and [maxM] for
/// measured boxes can be provided too.
@immutable
class ProjBox extends Box {
  final num _minX;
  final num _minY;
  final num? _minZ;
  final num? _minM;
  final num _maxX;
  final num _maxY;
  final num? _maxZ;
  final num? _maxM;

  /// A bounding box with [minX], [minY], [maxX] and [maxY] coordinates.
  ///
  /// Optional [minZ] and [maxZ] for 3D boxes, and [minM] and [maxM] for
  /// measured boxes can be provided too.
  const ProjBox({
    required num minX,
    required num minY,
    num? minZ,
    num? minM,
    required num maxX,
    required num maxY,
    num? maxZ,
    num? maxM,
  })  : _minX = minX,
        _minY = minY,
        _minZ = minZ,
        _minM = minM,
        _maxX = maxX,
        _maxY = maxY,
        _maxZ = maxZ,
        _maxM = maxM;

  /// A minimum bounding box calculated from [positions].
  factory ProjBox.from(Iterable<Position> positions) {
    // calculate mininum and maximum coordinates
    num? minX, minY, minZ, minM;
    num? maxX, maxY, maxZ, maxM;
    var isFirst = true;
    for (final cp in positions) {
      if (isFirst) {
        minX = cp.x;
        minY = cp.y;
        minZ = cp.optZ;
        minM = cp.optM;
        maxX = cp.x;
        maxY = cp.y;
        maxZ = cp.optZ;
        maxM = cp.optM;
      } else {
        minX = math.min(minX!, cp.x);
        minY = math.min(minY!, cp.y);
        minZ = cp.is3D && minZ != null ? math.min(minZ, cp.z) : null;
        minM = cp.isMeasured && minM != null ? math.min(minM, cp.m) : null;
        maxX = math.max(maxX!, cp.x);
        maxY = math.max(maxY!, cp.y);
        maxZ = cp.is3D && maxZ != null ? math.max(maxZ, cp.z) : null;
        maxM = cp.isMeasured && maxM != null ? math.max(maxM, cp.m) : null;
      }
      isFirst = false;
    }

    // create a new bounding box
    return ProjBox(
      minX: minX!,
      minY: minY!,
      minZ: minZ,
      minM: minM,
      maxX: maxX!,
      maxY: maxY!,
      maxZ: maxZ,
      maxM: maxM,
    );
  }

  @override
  num get minX => _minX;

  @override
  num get minY => _minY;

  @override
  num? get minZ => _minZ;

  @override
  num? get minM => _minM;

  @override
  num get maxX => _maxX;

  @override
  num get maxY => _maxY;

  @override
  num? get maxZ => _maxZ;

  @override
  num? get maxM => _maxM;

  /// The minimum position (or west-south) of this bounding box.
  @override
  Projected get min => Projected(
        x: _minX,
        y: _minY,
        z: _minZ,
        m: _minM,
      );

  /// The maximum position (or east-north) of this bounding box.
  @override
  Projected get max => Projected(
        x: _maxX,
        y: _maxY,
        z: _maxZ,
        m: _maxM,
      );

  @override
  Iterable<Projected> get corners2D =>
      Box.createCorners2D(this, Projected.create);

  @override
  int get spatialDimension => typeCoords.spatialDimension;

  @override
  int get coordinateDimension => typeCoords.coordinateDimension;

  @override
  bool get isGeographic => false;

  @override
  bool get is3D => _minZ != null;

  @override
  bool get isMeasured => _minM != null;

  @override
  Coords get typeCoords => CoordsExtension.select(
        isGeographic: isGeographic,
        is3D: is3D,
        isMeasured: isMeasured,
      );

  @override
  String toString() {
    switch (typeCoords) {
      case Coords.xy:
        return '$_minX,$_minY,$_maxX,$_maxY';
      case Coords.xyz:
        return '$_minX,$_minY,$_minZ,$_maxX,$_maxY,$_maxZ';
      case Coords.xym:
        return '$_minX,$_minY,$_minM,$_maxX,$_maxY,$_maxM';
      case Coords.xyzm:
        return '$_minX,$_minY,$_minZ,$_minM,$_maxX,$_maxY,$_maxZ,$_maxM';
      case Coords.lonLat:
      case Coords.lonLatElev:
      case Coords.lonLatM:
      case Coords.lonLatElevM:
        return '<not geographic>';
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ProjBox && Box.testEquals(this, other);

  @override
  int get hashCode => Box.hash(this);
}
