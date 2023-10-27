// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/reference/coord_ref_sys.dart';

import 'projection.dart';

/// A projection adapter bundles forward and inverse projections.
mixin ProjectionAdapter {
  /// The source coordinate reference system (or projection), ie.
  /// `CoordRefSys.CRS84`.
  CoordRefSys get sourceCrs;

  /// The target coordinate reference system (or projection), ie.
  /// `CoordRefSys.EPSG_3857`.
  CoordRefSys get targetCrs;

  /// Returns a projection that projects from [sourceCrs] to
  /// [targetCrs].
  Projection get forward;

  /// Returns a projection that projects from [targetCrs] to
  /// [sourceCrs].
  Projection get inverse;
}
