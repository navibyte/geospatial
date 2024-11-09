// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/common.dart';
import 'package:meta/meta.dart';

import '/src/utils/object_utils.dart';

/// A base query for requesting data from a geospatial data source.
@immutable
class GeospatialQuery {
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
  String toString() {
    return '$crs;$mapToString(parameters)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeospatialQuery &&
          crs == other.crs &&
          testMapEquality(parameters, other.parameters));

  @override
  int get hashCode => Object.hash(crs, mapHashCode(parameters));
}
