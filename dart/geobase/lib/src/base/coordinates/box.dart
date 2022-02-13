// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/base/codes.dart';
import '/src/utils/tolerance.dart';

import 'base_box.dart';
import 'position.dart';

/// A bounding box with [minX], [minY], [maxX] and [maxY] coordinates.
///
/// Optional [minZ] and [maxZ] for 3D boxes, and [minM] and [maxM] for
/// measured boxes can be provided too.
@immutable
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

  @override
  bool operator ==(Object other) => other is Box && Box.testEquals(this, other);

  @override
  int get hashCode => Box.hash(this);

  @override
  bool equals2D(BaseBox other, {num? toleranceHoriz}) =>
      other is Box &&
      Box.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  @override
  bool equals3D(
    BaseBox other, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) =>
      other is Box &&
      Box.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  // ---------------------------------------------------------------------------
  // Static methods with default logic, used by Box itself too.

  /// True if [box1] and [box2] equals by testing all coordinate values.
  static bool testEquals(Box box1, Box box2) =>
      box1.minX == box2.minX &&
      box1.minY == box2.minY &&
      box1.minZ == box2.minZ &&
      box1.minM == box2.minM &&
      box1.maxX == box2.maxX &&
      box1.maxY == box2.maxY &&
      box1.maxZ == box2.maxZ &&
      box1.maxM == box2.maxM;

  /// The hash code for [box].
  static int hash(Box box) => Object.hash(
        box.minX,
        box.minY,
        box.minZ,
        box.minM,
        box.maxX,
        box.maxY,
        box.maxZ,
        box.maxM,
      );

  /// True if positions [box1] and [box2] equals by testing 2D coordinates only.
  static bool testEquals2D(
    Box box1,
    Box box2, {
    num? toleranceHoriz,
  }) {
    assertTolerance(toleranceHoriz);
    return toleranceHoriz != null
        ? (box1.minX - box2.minX).abs() <= toleranceHoriz &&
            (box1.minY - box2.minY).abs() <= toleranceHoriz &&
            (box1.maxX - box2.maxX).abs() <= toleranceHoriz &&
            (box1.maxY - box2.maxY).abs() <= toleranceHoriz
        : box1.minX == box2.minX &&
            box1.minY == box2.minY &&
            box1.maxX == box2.maxX &&
            box1.maxY == box2.maxY;
  }

  /// True if positions [box1] and [box2] equals by testing 3D coordinates only.
  static bool testEquals3D(
    Box box1,
    Box box2, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) {
    assertTolerance(toleranceVert);
    if (!Box.testEquals2D(box1, box2, toleranceHoriz: toleranceHoriz)) {
      return false;
    }
    if (!box1.is3D || !box1.is3D) {
      return false;
    }
    if (toleranceVert != null) {
      final minZ1 = box1.minZ;
      final maxZ1 = box1.maxZ;
      final minZ2 = box2.minZ;
      final maxZ2 = box2.maxZ;
      return minZ1 != null &&
          maxZ1 != null &&
          minZ2 != null &&
          maxZ2 != null &&
          (minZ1 - minZ2).abs() <= toleranceVert &&
          (maxZ1 - maxZ2).abs() <= toleranceVert;
    } else {
      return box1.minZ == box2.minZ && box1.maxZ == box2.maxZ;
    }
  }
}
