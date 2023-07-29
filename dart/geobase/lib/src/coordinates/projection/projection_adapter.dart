// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/crs/coord_ref_sys.dart';

import 'projection.dart';

/// A projection adapter bundles forward and inverse projections.
mixin ProjectionAdapter {
  /// The source coordinate reference system (or projection), ie.
  /// `CoordRefSys.CRS84`.
  CoordRefSys get sourceCrs;

  /// The EPSG code or other identifier of the source coordinate reference
  /// system (or projection), ie. "EPSG:4326" or
  /// "http://www.opengis.net/def/crs/OGC/1.3/CRS84".
  ///
  @Deprecated('Use sourceCrs.epsg or sourceCrs.id instead')
  String get fromCrs => sourceCrs.epsg ?? sourceCrs.id;

  /// The target coordinate reference system (or projection), ie.
  /// `CoordRefSys.EPSG_3857`.
  CoordRefSys get targetCrs;

  /// The EPSG code or other identifier of the target coordinate reference
  /// system (or projection), ie. "EPSG:3857".
  @Deprecated('Use targetCrs.epsg or targetCrs.id instead')
  String get toCrs => targetCrs.epsg ?? targetCrs.id;

  /// Returns a projection that projects from [sourceCrs] to
  /// [targetCrs].
  Projection get forward;

  /// Returns a projection that projects from [targetCrs] to
  /// [sourceCrs].
  Projection get inverse;
}
