// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/base/coordinates.dart';

import 'projection.dart';

/// A projection adapter bundles forward and inverse projections.
mixin ProjectionAdapter {
  /// The source coordinate reference system (or projection), ie. "EPSG:4326".
  String get fromCrs;

  /// The target coordinate reference system (or projection), ie. "EPSG:3857".
  String get toCrs;

  /// Returns a projection that projects from [fromCrs] to [toCrs].
  ///
  /// By default, result positions are created using `Projected.create`. This
  /// can be overridden by giving another factory function when using a
  /// projection.
  Projection<Projected> forward();

  /// Returns a projection that projects from [fromCrs] to [toCrs].
  ///
  /// By default, result positions of [R] are created using [factory]. This can
  /// be overridden by giving another factory function when using a projection.
  Projection<R> forwardTo<R extends Position>(
    CreatePosition<R> factory,
  );

  /// Returns a projection that projects from [toCrs] to [fromCrs].
  ///
  /// By default, result positions are created using `Geographic.create`. This
  /// can be overridden by giving another factory function when using a
  /// projection.
  Projection<Geographic> inverse();

  /// Returns a projection that unprojects from [toCrs] to [fromCrs].
  ///
  /// By default, result positions of [R] are created using [factory]. This can
  /// be overridden by giving another factory function when using a projection.
  Projection<R> inverseTo<R extends Position>(
    CreatePosition<R> factory,
  );
}
