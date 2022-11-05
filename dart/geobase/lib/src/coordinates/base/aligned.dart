// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

/// An aligned point within a rectangle or a box.
///
/// Inspired by the
/// [Alignment](https://api.flutter.dev/flutter/painting/Alignment-class.html)
/// class defined by the Flutter SDK. The defintions of [x] and [y] are the
/// same, but this class (`Aligned`) can be used on pure Dart apps too without
/// the dependency on Flutter.
/// 
/// This class is named `Aligned` to avoid name collisions with `Alignment` and
/// `Align` classes defined by the Flutter SDK.
@immutable
class Aligned {
  /// The horizontal distance fraction.
  ///
  /// The value `-1.0` represents the left edge of the rectangle.
  ///
  /// The value `0.0` represents the center horizontally.
  ///
  /// The value `1.0` represents the right edge of the rectangle.
  final double x;

  /// The vertical distance fraction.
  ///
  /// The value `-1.0` represents the top edge of the rectangle.
  ///
  /// The value `0.0` represents the center vertically.
  ///
  /// The value `1.0` represents the bottom edge of the rectangle.
  final double y;

  /// An aligned point within a rectangle or a box.
  const Aligned({required this.x, required this.y});

  /// The top left corner, with `x: -1.0, y: -1.0`.
  static const topLeft = Aligned(x: -1.0, y: -1.0);

  /// The center point along the top edge, with `x: 0.0, y: -1.0`.
  static const topCenter = Aligned(x: 0.0, y: -1.0);

  /// The top right corner, with `x: 1.0, y: -1.0`.
  static const topRight = Aligned(x: 1.0, y: -1.0);

  /// The center point along the left edge, with `x: -1.0, y: 0.0`.
  static const centerLeft = Aligned(x: -1.0, y: 0.0);

  /// The center point, with `x: 0.0, y: 0.0`.
  static const center = Aligned(x: 0.0, y: 0.0);

  /// The center point along the right edge, with `x: 1.0, y: 0.0`.
  static const centerRight = Aligned(x: 1.0, y: 0.0);

  /// The bottom left corner, with `x: -1.0, y: 1.0`.
  static const bottomLeft = Aligned(x: -1.0, y: 1.0);

  /// The center point along the bottom edge, with `x: 0.0, y: 1.0`.
  static const bottomCenter = Aligned(x: 0.0, y: 1.0);

  /// The bottom right corner, with `x: 1.0, y: 1.0`.
  static const bottomRight = Aligned(x: 1.0, y: 1.0);

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
