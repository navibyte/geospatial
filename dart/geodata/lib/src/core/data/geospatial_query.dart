// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:geobase/coordinates.dart';
import 'package:meta/meta.dart';

/// A base query for requesting data from a geospatial data source.
@immutable
class GeospatialQuery with EquatableMixin {
  /// A base query for requesting data from a geospatial data source.
  const GeospatialQuery({
    this.crs,
    this.parameters,
  });

  /// An optional id defining a coordinate reference system for result data.
  final CoordRefSys? crs;

  /// Optional query parameters for queries as a map of named parameters.
  ///
  /// Note that such parameters that are defined in other members of this class
  /// or it's sub type, override any parameter on [parameters], if available.
  /// Use this only for parameters that are not defined by other members.
  ///
  /// See also the [queryablesAsParameters] getter that maps all values to
  /// `String`.
  final Map<String, dynamic>? parameters;

  /// Optional query parameters for queries with values mapped to `String`.
  ///
  /// This getter maps values from [parameters] using the mapper function:
  /// `(key, value) => MapEntry(key, value.toString())`
  Map<String, String>? get queryablesAsParameters =>
      parameters?.map((key, value) => MapEntry(key, value.toString()));

  @override
  List<Object?> get props => [crs, parameters];
}
