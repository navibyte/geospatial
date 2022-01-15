// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A base query for requesting data from a geospatial data source.
@immutable
class GeospatialQuery with EquatableMixin {
  /// A base query for requesting data from a geospatial data source.
  const GeospatialQuery({
    this.crs,
    this.extra,
  });

  /// An optional id defining a coordinate reference system for result data.
  final String? crs;

  /// Optional extra parameters for queries as a data record.
  ///
  /// Note that such parameters that are defined in other members of this class
  /// or it's sub type, override any parameter on [extra], if available. Use
  /// this only for parameters that are not defined by geospatial queries.
  final Map<String, Object?>? extra;

  /// Optional extra parameters for queries with values mapped to `String`.
  ///
  /// This getter maps values from [extra] using the mapper function:
  /// `(key, value) => MapEntry(key, value.toString())`
  Map<String, String>? get extraParams =>
      extra?.map((key, value) => MapEntry(key, value.toString()));

  @override
  List<Object?> get props => [crs, extra];
}
