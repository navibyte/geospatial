// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '/src/core/data.dart';

/// A query for requesting features from a basic feature source.
@immutable
class BasicFeatureItemsQuery with GeodataQuery, EquatableMixin {
  /// Create a new basic feature items query with optional query parameters.
  const BasicFeatureItemsQuery({
    this.crs,
    this.limit,
    this.extraParams,
  });

  @override
  final String? crs;

  /// An optional [limit] setting maximum number of items returned.
  ///
  /// If given, must be a positive integer.
  final int? limit;

  @override
  final Map<String, String>? extraParams;

  @override
  List<Object?> get props => [crs, limit, extraParams];
}
