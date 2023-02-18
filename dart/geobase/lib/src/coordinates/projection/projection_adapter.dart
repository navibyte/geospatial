// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'projection.dart';

/// A projection adapter bundles forward and inverse projections.
mixin ProjectionAdapter {
  /// The source coordinate reference system (or projection), ie. "EPSG:4326".
  String get fromCrs;

  /// The target coordinate reference system (or projection), ie. "EPSG:3857".
  String get toCrs;

  /// Returns a projection that projects from [fromCrs] to [toCrs].
  Projection get forward;

  /// Returns a projection that projects from [toCrs] to [fromCrs].
  Projection get inverse;
}
