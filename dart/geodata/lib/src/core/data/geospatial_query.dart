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
    this.extraParams,
  });

  /// An optional id defining a coordinate reference system for result data.
  final String? crs;

  /// Optional extra parameters to be appended to a query.
  ///
  /// Note that such parameters that are defined in other members of this class
  /// or it's sub type, override any parameter on [extraParams], if available.
  /// Use this only for parameters that are not defined by geospatial queries.
  final Map<String, String>? extraParams;

  @override
  List<Object?> get props => [crs, extraParams];
}
