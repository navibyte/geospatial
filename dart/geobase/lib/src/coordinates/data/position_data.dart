// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/base.dart';

/// A fixed-length and random-access view to positions with coordinate values.
///
/// See [Position] for description about supported coordinate values.
mixin PositionData<E extends Position, C extends num> implements Positionable {
  /// The number of positions in this view.
  int get length;

  /// Returns true if this view has no positions.
  bool get isEmpty => length == 0;

  /// Returns true if this view has at least one position.
  bool get isNotEmpty => length > 0;

  /// The object at the given index as [E].
  ///
  /// The index must be a valid index in this view; `0 <= index < length`.
  E operator [](int index);

  /// The position at the given index as an object of [E] using [to] factory.
  ///
  /// The index must be a valid index in this view; `0 <= index < length`.
  R get<R extends Position>(int index, {required CreatePosition<R> to});

  /// The first position as an object of [E] or null (if empty collection).
  E? get firstOrNull => length > 0 ? this[0] : null;

  /// The last position as an object of [E] or null (if empty collection).
  E? get lastOrNull {
    final len = length;
    return len > 0 ? this[len - 1] : null;
  }

  /// The `x` coordinate of the position at the given index.
  ///
  /// For geographic coordinates x represents *longitude*.
  ///
  /// The index must be a valid index in this view; `0 <= index < length`.
  C x(int index);

  /// The `y` coordinate of the position at the given index.
  ///
  /// For geographic coordinates y represents *latitude*.
  ///
  /// The index must be a valid index in this view; `0 <= index < length`.
  C y(int index);

  /// The `z` coordinate of the position at the given index.
  ///
  /// Returns zero if z is not available for a valid index. You can also use
  /// [optZ] that returns z coordinate as a nullable value.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  ///
  /// The index must be a valid index in this view; `0 <= index < length`.
  C z(int index);

  /// The `z` coordinate of the position at the given index.
  ///
  /// Returns null if z is not available for a valid index.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  ///
  /// The index must be a valid index in this view; `0 <= index < length`.
  C? optZ(int index);

  /// The `m` coordinate of the position at the given index.
  ///
  /// Returns zero if m is not available for a valid index. You can also use
  /// [optM] that returns m coordinate as a nullable value.
  ///
  /// `m` represents a measurement or a value on a linear referencing system
  /// (like time).
  ///
  /// The index must be a valid index in this view; `0 <= index < length`.
  C m(int index);

  /// The `m` coordinate of the position at the given index.
  ///
  /// Returns null if m is not available for a valid index.
  ///
  /// `m` represents a measurement or a value on a linear referencing system
  /// (like time).
  ///
  /// The index must be a valid index in this view; `0 <= index < length`.
  C? optM(int index);

  /// True if the first and last position equals in 2D.
  bool get isClosed {
    final len = length;
    if (len >= 2) {
      return this[0].equals2D(this[len - 1]);
    }
    return false;
  }

  /// True if the first and last position equals in 2D within [toleranceHoriz].
  bool isClosedBy(num toleranceHoriz) {
    final len = length;
    if (len >= 2) {
      return this[0].equals2D(this[len - 1], toleranceHoriz: toleranceHoriz);
    }
    return false;
  }

  /// Coordinate values in this view to an iterable of [E] objects.
  ///
  /// The returned iterable is lazy.
  Iterable<E> get all => Iterable.generate(length, (index) => this[index]);
}
