// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A mixin defining parameters for requesting geospatial data.
mixin GeodataQuery {
  /// An optional coordinate reference system used by result geometries.
  String? get crs;

  /// Optional extra parameters to be appended to a query.
  ///
  /// Note that such parameters that are defined in other members of this class
  /// or it's sub type, override any parameter on [extraParams], if available.
  /// So use this only for parameters that are not defined by geodata queries.
  Map<String, String>? get extraParams;
}
