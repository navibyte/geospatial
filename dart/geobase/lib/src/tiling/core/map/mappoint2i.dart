// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base.dart';

import 'mapped.dart';

/// Mapped coordinates with the ([x], [y]) point at the [zoom] level.
///
/// [x], [y] and [zoom] have integer values.
@immutable
class MapPoint2i implements Mapped<Position2>, Position2 {
  @override
  final int zoom;

  /// The x coordinate value at [zoom].
  @override
  final int x;

  /// The y coordinate value at [zoom].
  @override
  final int y;

  /// Create mapped coordinates with the ([x], [y]) point at the [zoom] level.
  const MapPoint2i({required this.zoom, required this.x, required this.y});

  @override
  Position2 get point => this;

  @override
  int operator [](int i) {
    switch (i) {
      case 0:
        return x;
      case 1:
        return y;
      default:
        return 0;
    }
  }

  @override
  Iterable<int> get values => [x, y];

  @override
  int get spatialDimension => 2;

  @override
  int get coordinateDimension => 2;

  @override
  bool get isGeographic => false;

  @override
  bool get is3D => false;

  @override
  bool get isMeasured => false;

  @override
  Coords get typeCoords => Coords.xy; // Note: "zoom" is not coordinate but LOD

  @override
  bool equals2D(Position2 other, {num? toleranceHoriz}) {
    // here we check only x, y regardless of zoom
    return toleranceHoriz != null
        ? (x - other.x).abs() <= toleranceHoriz &&
            (y - other.y).abs() <= toleranceHoriz
        : x == other.x && y == other.y;
  }

  @override
  String toString() {
    return '$zoom,$x,$y';
  }

  @override
  bool operator ==(Object other) =>
      other is MapPoint2i && zoom == other.zoom && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(zoom, x, y);
}
