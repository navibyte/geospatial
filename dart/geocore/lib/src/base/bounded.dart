// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// An internal base interface for classes that know their [bounds].
///
/// This is extended by [Bounded] and an internal interface [_BatchedSeries].
abstract class _BoundedBase {
  /// Default `const` constructor to allow extending this abstract class.
  const _BoundedBase();

  /// The [bounds] geometry for this object.
  ///
  /// Please note that in some cases bounds could be pre-calculated but it's
  /// possible that accessing this property may cause extensive calculations.
  ///
  /// Bounds returned can be "empty" if this object is considered "empty". Such
  /// bounds does not intersect with any other bounds.
  Bounds get bounds;
}

/// A base interface for classes that know their [bounds].
abstract class Bounded extends _BoundedBase {
  /// Default `const` constructor to allow extending this abstract class.
  const Bounded();

  /// Returns a new object with all points transformed using [transform].
  ///
  /// The transformed bounded object must be of the same type with this object.
  Bounded transform(TransformPoint transform);

  /// Returns a new object with all points projected using [projection].
  ///
  /// When [factory] is provided, then target points of [R] are created using
  /// that as a point factory. Otherwise [projection] uses it's own factory.
  Bounded project<R extends Point>(
    ProjectPoint<R> projection, {
    PointFactory<R>? to,
  });
}
