// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

/// An aligned point within a geospatial box or tile.
///
/// Inspired by the
/// [Alignment](https://api.flutter.dev/flutter/painting/Alignment-class.html)
/// and `AlignmentDirectional` classes defined by the Flutter SDK.
///
/// This class is named `Aligned` to avoid name collisions with `Alignment` and
/// `Align` classes defined by the Flutter SDK.
@immutable
class Aligned {
  /// The horizontal distance fraction.
  ///
  /// The value `-1.0` represents the west side edge of the box.
  ///
  /// The value `0.0` represents the center horizontally.
  ///
  /// The value `1.0` represents the east side edge of the box.
  final double x;

  /// The vertical distance fraction.
  ///
  /// The value `-1.0` represents the south side edge of the box.
  ///
  /// The value `0.0` represents the center vertically.
  ///
  /// The value `1.0` represents the north side edge of the box.
  final double y;

  /// An aligned point within a geospatial box or tile.
  const Aligned({required this.x, required this.y});

  /// The south west corner, with `x: -1.0, y: -1.0`.
  static const southWest = Aligned(x: -1.0, y: -1.0);

  /// The center point along the south side edge, with `x: 0.0, y: -1.0`.
  static const southCenter = Aligned(x: 0.0, y: -1.0);

  /// The south east corner, with `x: 1.0, y: -1.0`.
  static const southEast = Aligned(x: 1.0, y: -1.0);

  /// The center point along the west side edge, with `x: -1.0, y: 0.0`.
  static const centerWest = Aligned(x: -1.0, y: 0.0);

  /// The center point, with `x: 0.0, y: 0.0`.
  static const center = Aligned(x: 0.0, y: 0.0);

  /// The center point along the east side edge, with `x: 1.0, y: 0.0`.
  static const centerEast = Aligned(x: 1.0, y: 0.0);

  /// The north west corner, with `x: -1.0, y: 1.0`.
  static const northWest = Aligned(x: -1.0, y: 1.0);

  /// The center point along the north side edge, with `x: 0.0, y: 1.0`.
  static const northCenter = Aligned(x: 0.0, y: 1.0);

  /// The north east corner, with `x: 1.0, y: 1.0`.
  static const northEast = Aligned(x: 1.0, y: 1.0);

  @override
  String toString() {
    return '$x,$y';
  }

  @override
  bool operator ==(Object other) =>
      other is Aligned && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}
