// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/coordinates/base/position.dart';

/// An object containing [position] that is within [distance] from something.
@immutable
class DistancedPosition<T extends Position> {
  /// The reference [position].
  final T position;

  /// The [distance] between the reference [position] and something.
  final double distance;

  /// An object containing [position] that is within [distance] from something.
  const DistancedPosition(this.position, this.distance);

  @override
  String toString() {
    return '$position,$distance';
  }

  @override
  bool operator ==(Object other) =>
      other is DistancedPosition &&
      position == other.position &&
      distance == other.distance;

  @override
  int get hashCode => Object.hash(position, distance);
}
