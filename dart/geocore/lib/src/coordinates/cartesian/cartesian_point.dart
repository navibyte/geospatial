// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/base.dart';

/// A read-only cartesian (or projected) point with [x], [y], [z] and [m].
///
/// Coordinate values of type [C] are either `num` (allowing `double` or `int`),
/// `double` or `int`.
abstract class CartesianPoint<C extends num> extends Point<C> {
  /// Default `const` constructor to allow extending this abstract class.
  const CartesianPoint();

  @override
  CartesianPoint copyWith({num? x, num? y, num? z, num? m});

  @override
  CartesianPoint newWith({num x = 0.0, num y = 0.0, num? z, num? m});

  @override
  CartesianPoint newFrom(Iterable<num> coords, {int? offset, int? length});

  @override
  CartesianPoint transform(TransformPoint transform);
}
