// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:geocore/base.dart';
import 'package:meta/meta.dart';

import '/src/core/data.dart';

/// A query defining parameters for requesting features from a feature source.
@immutable
class FeatureItemsQuery with GeodataQuery, EquatableMixin {
  /// Create a new feature items query with optional query parameters.
  const FeatureItemsQuery({
    this.crs,
    this.boundsCrs,
    this.bounds,
    this.datetime,
    this.limit,
    this.extraParams,
  });

  @override
  final String? crs;

  /// An optional coordinate reference system used by [bounds].
  final String? boundsCrs;

  /// An optional [bounds] as a geospatial bounding filter (like `bbox`).
  final Bounds? bounds;

  /// An optional datetime as a temporal object (instant or interval).
  final Temporal? datetime;

  /// An optional [limit] setting maximum number of items returned.
  ///
  /// If given, must be a positive integer.
  final int? limit;

  @override
  final Map<String, String>? extraParams;

  @override
  List<Object?> get props => [crs, boundsCrs, bounds, limit, extraParams];
}
