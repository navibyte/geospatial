// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'spatial.dart';

/// An internal base interface for classes that know their [bounds].
///
/// This is extended by [Bounded] and an internal interface [_BatchedSeries].
abstract class _BoundedBase {
  /// Default `const` constructor to allow extending this abstract class.
  const _BoundedBase();

  /// The [bounds] for this object (could be calculated if not explicitely set).
  ///
  /// Please note that in some cases bounds could be pre-calculated but it's
  /// possible that accessing this property may cause extensive calculations.
  ///
  /// For some bounded objects (like an empty collections) bounds cannot be
  /// resolved at all. In such case, the null value is returned.
  Bounds? get bounds;

  /// The explicit [bounds] for this object when available.
  ///
  /// Accessing this should never trigger extensive calculations. That is, if
  /// bounds is not known, then returns the null value.
  Bounds? get boundsExplicit;
}

/// A base interface for classes that know their [bounds].
abstract class Bounded extends _BoundedBase {
  /// Default `const` constructor to allow extending this abstract class.
  const Bounded();

  /// Returns a new object with all points transformed using [transform].
  ///
  /// The transformed bounded object must be of the same type with this object.
  Bounded transform(TransformPosition transform);

  /// Returns a new object with all points projected using [projection].
  ///
  /// When [factory] is provided, then target points of [R] are created using
  /// that as a point factory. Otherwise [projection] uses it's own factory.
  Bounded project<R extends Point>(
    Projection<R> projection, {
    CreatePosition<R>? to,
  });
}
