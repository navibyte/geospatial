// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/base/codes.dart';

import 'base_box.dart';
import 'position.dart';

/// A bounding box with [minX], [minY], [maxX] and [maxY] coordinates.
///
/// Optional [minZ] and [maxZ] for 3D boxes, and [minM] and [maxM] for
/// measured boxes can be provided too.
class Box extends BaseBox {
  /// A bounding box with [minX], [minY], [maxX] and [maxY] coordinates.
  ///
  /// Optional [minZ] and [maxZ] for 3D boxes, and [minM] and [maxM] for
  /// measured boxes can be provided too.
  const Box({
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

  final num _minX;
  final num _minY;
  final num? _minZ;
  final num? _minM;
  final num _maxX;
  final num _maxY;
  final num? _maxZ;
  final num? _maxM;

  /// The minimum x (or west) coordinate.
  num get minX => _minX;

  /// The minimum y (or south) coordinate.
  num get minY => _minY;

  /// The minimum z coordinate optionally. Returns null if not available.
  ///
  /// You can also use [is3D] to check whether z coordinate available.
  num? get minZ => _minZ;

  /// The minimum m coordinate optionally. Returns null if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available.
  @override
  num? get minM => _minM;

  /// The maximum x (or east) coordinate.
  num get maxX => _maxX;

  /// The maximum y (or north) coordinate.
  num get maxY => _maxY;

  /// The maximum z coordinate optionally. Returns null if not available.
  ///
  /// You can also use [is3D] to check whether z coordinate available.
  num? get maxZ => _maxZ;

  /// The maximum m coordinate optionally. Returns null if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available.
  @override
  num? get maxM => _maxM;

  /// The minimum position (or west-south) of this bounding box.
  @override
  Position get min => Position(
        x: _minX,
        y: _minY,
        z: _minZ,
        m: _minM,
      );

  /// The maximum position (or east-north) of this bounding box.
  @override
  Position get max => Position(
        x: _maxX,
        y: _maxY,
        z: _maxZ,
        m: _maxM,
      );

  @override
  Box get asBox => this;

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
}
