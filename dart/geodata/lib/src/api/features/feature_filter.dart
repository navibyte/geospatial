// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:attributes/values.dart';
import 'package:geocore/base.dart';
import 'package:geocore/crs.dart';

import '../base.dart';

/// A feature filter used for geospatial feature queries.
class FeatureFilter extends Filter {
  /// A new feature filter.
  const FeatureFilter({
    Identifier? id,
    int? limit,
    this.crs,
    this.boundsCrs,
    this.bounds,
  }) : super(id: id, limit: limit);

  /// An optional coordinate reference system used by result geometries.
  final CRS? crs;

  /// An optional coordinate reference system used by [bounds].
  final CRS? boundsCrs;

  /// An optional [bounds] as a geospatial bounding filter.
  final Bounds? bounds;

  @override
  List<Object?> get props => [id, limit, crs, boundsCrs, bounds];
}
