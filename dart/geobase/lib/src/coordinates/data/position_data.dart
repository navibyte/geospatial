// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/constants/epsilon.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/positionable.dart';
import '/src/utils/tolerance.dart';

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
  bool isClosedBy([double toleranceHoriz = doublePrecisionEpsilon]) {
    final len = length;
    if (len >= 2) {
      return this[0].equals2D(this[len - 1], toleranceHoriz: toleranceHoriz);
    }
    return false;
  }

  /// True if this position data view equals with [other] by testing 2D
  /// coordinates of all positions (that must be in same order in both views).
  ///
  /// Returns false if this or [other] is empty ([isEmpty] is true).
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals2D(
    PositionData<E, C> other, {
    double toleranceHoriz = doublePrecisionEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    if (isEmpty || other.isEmpty) return false;
    if (length != other.length) return false;

    for (var i = 0; i < length; i++) {
      if ((x(i) - other.x(i)).abs() > toleranceHoriz ||
          (y(i) - other.y(i)).abs() > toleranceHoriz) {
        return false;
      }
    }
    return true;
  }

  /// True if this position data view equals with [other] by testing 3D
  /// coordinates of all positions (that must be in same order in both views).
  ///
  /// Returns false if this or [other] is empty ([isEmpty] is true).
  ///
  /// Returns false if this or [other] do not contain 3D coordinates.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Differences on vertical coordinate values (ie. z or elev) between
  /// this and [other] must be within [toleranceVert].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals3D(
    PositionData other, {
    double toleranceHoriz = doublePrecisionEpsilon,
    double toleranceVert = doublePrecisionEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    assertTolerance(toleranceVert);
    if (!is3D || !other.is3D) return false;
    if (isEmpty || other.isEmpty) return false;
    if (length != other.length) return false;

    for (var i = 0; i < length; i++) {
      if ((x(i) - other.x(i)).abs() > toleranceHoriz ||
          (y(i) - other.y(i)).abs() > toleranceHoriz ||
          (z(i) - other.z(i)).abs() > toleranceVert) {
        return false;
      }
    }
    return true;
  }

  /// Coordinate values in this view to an iterable of [E] objects.
  ///
  /// The returned iterable is lazy.
  Iterable<E> get all => Iterable.generate(length, (index) => this[index]);
}
