// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/utils/format_validation.dart';
import '/src/utils/num.dart';

import 'scalable.dart';

/// Scalable [x], [y] coordinates at the [zoom] level.
///
/// [zoom] must be a positive integer.
///
/// Coordinates [x], [y] and [zoom] have integer values.
///
/// Scalable coordinates are coordinates associated with some level of detail
/// (LOD) or `zoom` level. They are used for example by tiling schemes to
/// represent *pixels* and *tiles* of tile matrices.
@immutable
class Scalable2i implements Scalable {
  @override
  final int zoom;

  /// The x coordinate value at [zoom].
  final int x;

  /// The y coordinate value at [zoom].
  final int y;

  /// Create scalable [x], [y] coordinates at the [zoom] level.
  ///
  /// [zoom] must be a positive integer.
  const Scalable2i({required this.zoom, required this.x, required this.y})
      : assert(zoom >= 0, 'Zoom must be >= 0');

  /// A factory function creating scalable [x], [y] coordinates at [zoom].
  ///
  /// [zoom] must be a positive integer.
  static Scalable2i Function({required int x, required int y}) factory({
    int zoom = 0,
  }) {
    assert(zoom >= 0, 'Zoom must be >= 0');
    return ({required int x, required int y}) =>
        Scalable2i(zoom: zoom, x: x, y: y);
  }

  /// Builds scalable coordinates from [coords] given in order: zoom, x, y.
  factory Scalable2i.build(Iterable<num> coords, {int offset = 0}) {
    // resolve iterator for source coordinates
    final Iterator<num> iter;
    if (offset == 0) {
      iter = coords.iterator;
    } else if (coords.length >= offset + 2) {
      iter = coords.skip(offset).iterator;
    } else {
      throw invalidCoordinates;
    }

    // iterate at least to zoom, x and y  => then create position
    if (iter.moveNext()) {
      final zoom = iter.current;
      if (iter.moveNext()) {
        final x = iter.current;
        if (iter.moveNext()) {
          final y = iter.current;
          return Scalable2i(
            zoom: zoom.round(),
            x: x.round(),
            y: y.round(),
          );
        }
      }
    }
    throw invalidCoordinates;
  }

  /// Parses scalable coordinates from [text] given in order: zoom, x, y.
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  factory Scalable2i.parse(
    String text, {
    Pattern? delimiter = ',',
  }) {
    final coords = parseNumValues(text, delimiter: delimiter);
    return Scalable2i.build(coords);
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

  /// A coordinate value by the coordinate axis index [i].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For scalable coordinates, the coordinate ordering is: (zoom, x, y)
  int operator [](int i) {
    switch (i) {
      case 0:
        return zoom;
      case 1:
        return x;
      case 2:
        return y;
      default:
        return 0;
    }
  }

  /// Coordinate values of this position as an iterable of 3 items.
  ///
  /// For scalable coordinates, the coordinate ordering is: (zoom, x, y)
  Iterable<int> get values => [zoom, x, y];

  /// Copies the point with optional [zoom], [x] and [y] overriding values.
  ///
  /// For example: `Scalable2i(zoom: 2, x: 1, y: 1).copyWith(y: 2)` equals to
  /// `Scalable2i(zoom: 2, x: 1, y: 2)`.
  Scalable2i copyWith({int? zoom, int? x, int? y}) => Scalable2i(
        zoom: zoom ?? this.zoom,
        x: x ?? this.x,
        y: y ?? this.y,
      );

  /// A string representation of coordinate values separated by [delimiter].
  ///
  /// For scalable coordinates, the coordinate ordering is: (zoom, x, y)
  @override
  String toText({String delimiter = ','}) => '$zoom$delimiter$x$delimiter$y';

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
