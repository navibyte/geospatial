// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base.dart';
import '/src/coordinates/projected.dart';
import '/src/utils/num.dart';

import 'scalable.dart';

/// Scalable [x], [y] projected coordinates at the [zoom] level.
///
/// [zoom] must be a positive integer.
///
/// Coordinates [x], [y] and [zoom] have integer values.
/// 
/// Scalable coordinates are projected coordinates associated with some level of
/// detail (LOD) or `zoom` level. They are used for example by tiling schemes to
/// represent *pixels* and *tiles* of tile matrices.
@immutable
class Scalable2i implements Scalable, Projected {
  @override
  final int zoom;

  /// The x coordinate value at [zoom].
  @override
  final int x;

  /// The y coordinate value at [zoom].
  @override
  final int y;

  /// Create scalable [x], [y] projected coordinates at the [zoom] level.
  ///
  /// [zoom] must be a positive integer.
  const Scalable2i({required this.zoom, required this.x, required this.y})
      : assert(zoom >= 0, 'Zoom must be >= 0');

  /// A factory function creating scalable [x], [y] coordinates at [zoom].
  ///
  /// [zoom] must be a positive integer.
  ///
  /// The returned function is compatible with the `CreatePosition` function
  /// type.
  static CreatePosition<Scalable2i> factory({int zoom = 0}) {
    assert(zoom >= 0, 'Zoom must be >= 0');
    return ({required num x, required num y, num? z, num? m}) =>
        Scalable2i(zoom: zoom, x: x.round(), y: y.round());
  }

  /// Creates scalable coordinates from [coords] given in order: zoom, x, y.
  factory Scalable2i.fromCoords(Iterable<num> coords, {int offset = 0}) {
    final len = coords.length - offset;
    if (len < 3) {
      throw const FormatException('Coords must contain at least three items');
    }
    return Scalable2i(
      zoom: coords.elementAt(offset).round(),
      x: coords.elementAt(offset + 1).round(),
      y: coords.elementAt(offset + 2).round(),
    );
  }

  /// Creates scalable coordinates from [text] given in order: zoom, x, y.
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  factory Scalable2i.fromText(
    String text, {
    Pattern? delimiter = ',',
  }) {
    final coords = parseNumValuesFromText(text, delimiter: delimiter);
    return Scalable2i.fromCoords(coords);
  }

  @override
  Scalable2i zoomIn() => Scalable2i(
        zoom: zoom + 1,
        x: x << 1,
        y: y << 1,
      );

  @override
  Scalable2i zoomOut() => zoom == 0
      ? this
      : Scalable2i(
          zoom: zoom - 1,
          x: x >> 1,
          y: y >> 1,
        );

  @override
  Scalable2i zoomTo(int zoom) {
    assert(zoom >= 0, 'Zoom must be >= 0');
    if (this.zoom == zoom) {
      return this;
    }
    final shift = zoom - this.zoom;
    return shift > 0
        ? Scalable2i(
            zoom: zoom,
            x: x << shift,
            y: y << shift,
          )
        : Scalable2i(
            zoom: zoom,
            x: x >> shift.abs(),
            y: y >> shift.abs(),
          );
  }

  @override
  num get z => 0;

  @override
  num? get optZ => null;

  @override
  num get m => 0;

  @override
  num? get optM => null;

  /// A coordinate value by the coordinate axis index [i].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For mapped coordinates, the coordinate ordering is: (x, y)
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

  /// Coordinate values of this position as an iterable of 2 items.
  ///
  /// For scalable coordinates, the coordinate ordering is: (x, y)
  @override
  Iterable<int> get values => [x, y];

  @override
  R copyTo<R extends Position>(CreatePosition<R> factory) =>
      factory.call(x: x, y: y);

  /// Copies the point with optional [zoom], [x] and [y] overriding values.
  ///
  /// Parameters [z] and [m] are ignored as `MapPoint2i` does not support them.
  ///
  /// For example: `MapPoint2i(zoom: 2, x: 1, y: 1).copyWith(y: 2)` equals to
  /// `MapPoint2i(zoom: 2, x: 1, y: 2)`.
  @override
  Scalable2i copyWith({int? zoom, num? x, num? y, num? z, num? m}) =>
      Scalable2i(
        zoom: zoom ?? this.zoom,
        x: (x ?? this.x).round(),
        y: (y ?? this.y).round(),
      );

  @override
  Projected transform(TransformPosition transform) => transform.call(this);

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
  bool equals2D(Position other, {num? toleranceHoriz}) =>
      Position.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  @override
  bool equals3D(
    Position other, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) =>
      Position.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  @override
  String toString() {
    return '$zoom,$x,$y';
  }

  @override
  bool operator ==(Object other) =>
      other is Scalable2i && zoom == other.zoom && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(zoom, x, y);
}
