// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/base/coordinates.dart';

import 'projection.dart';

/// A projection adapter bundles forward and inverse projections.
///
/// Using [FromPosition] and [ToPosition] it's possible to specify more accurate
/// class types (extending [BasePosition]) be used on an adapter implementation.
///
/// The [FromPosition] type specifies a type for source positions of `forward`
/// and target positions of `inverse` projections.
///
/// The [ToPosition] type specifies a type for target positions of `forward` and
/// source positions of `inverse` projections.
mixin ProjectionAdapter<FromPosition extends BasePosition,
    ToPosition extends BasePosition> {
  /// The source coordinate reference system (or projection), ie. "EPSG:4326".
  String get fromCrs;

  /// The target coordinate reference system (or projection), ie. "EPSG:3857".
  String get toCrs;

  /// Returns a projection that projects from [fromCrs] to [toCrs].
  ///
  /// By default, result positions of [R] are created using [factory]. This can
  /// be overridden by giving another factory function when using a projection.
  Projection<R> forward<R extends ToPosition>(
    CreatePosition<R> factory,
  );

  /// Returns a projection that unprojects from [toCrs] to [fromCrs].
  ///
  /// By default, result positions of [R] are created using [factory]. This can
  /// be overridden by giving another factory function when using a projection.
  Projection<R> inverse<R extends FromPosition>(
    CreatePosition<R> factory,
  );
}
