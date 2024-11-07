// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';

import 'package:geobase/common.dart';
import 'package:meta/meta.dart';

/// A query based on the `Common Query Language` (CQL2).
///
/// References:
/// * [OGC API - Features](https://github.com/opengeospatial/ogcapi-features) -
///   [Part 3: Filtering](https://docs.ogc.org/is/19-079r2/19-079r2.html).
/// * Common Query Language,
///   [CQL2](https://docs.ogc.org/is/21-065r2/21-065r2.html).
@immutable
class CQLQuery {
  final String _filter;
  final String _filterLang;
  final CoordRefSys? _filterCrs;

  const CQLQuery._(
    String filter, {
    String filterLang = filterLangCQL2Text,
    CoordRefSys? filterCrs,
  })  : _filter = filter,
        _filterLang = filterLang,
        _filterCrs = filterCrs;

  /// Creates a query based on the the `cql2-text` encoding of the
  /// `Common Query Language` (CQL2).
  ///
  /// Parameters:
  /// * [filter]: A filter expression conforming to `cql2-text` to be applied
  ///   when retrieving resources.
  /// * [filterCrs]: An optional coordinate reference system used by the
  ///   [filter] expression. When not specified, WGS84 longitude / latitude is
  ///   assumed.
  ///
  /// NOTE: text data in [filter] is not validated by this client-side
  ///       implementation (that is, it's sent to a server as-is).
  const CQLQuery.fromText(
    String filter, {
    CoordRefSys? filterCrs,
  }) : this._(
          filter,
          filterLang: filterLangCQL2Text,
          filterCrs: filterCrs,
        );

  /// Creates a query based on the the `cql2-json` encoding of the
  /// `Common Query Language` (CQL2).
  ///
  /// Parameters:
  /// * [filter]: A filter expression as JSON Object conforming to `cql2-json`
  ///   to be applied when retrieving resources.
  /// * [filterCrs]: An optional coordinate reference system used by the
  ///   [filter] expression. When not specified, WGS84 longitude / latitude is
  ///   assumed.
  ///
  /// NOTE: JSON data in [filter] is not validated by this client-side
  ///       implementation (that is, it's sent to a server as-is).
  CQLQuery.fromJson(
    Map<String, dynamic> filter, {
    CoordRefSys? filterCrs,
  }) : this._(
          json.encode(filter),
          filterLang: filterLangCQL2Json,
          filterCrs: filterCrs,
        );

  /// The text encoding of CQL2 (Common Query Language).
  static const filterLangCQL2Text = 'cql2-text';

  /// The JSON encoding of CQL2 (Common Query Language).
  static const filterLangCQL2Json = 'cql2-json';

  /// The filter expression of [filterLang] to be applied when retrieving
  /// resources.
  String get filter => _filter;

  /// The predicate language that [filter] conforms to.
  ///
  /// For example "cql2-text" or "cql2-json".
  ///
  /// See [filterLangCQL2Text] and [filterLangCQL2Json].
  String get filterLang => _filterLang;

  /// An optional coordinate reference system used by the [filter] expression.
  ///
  /// When not specified, WGS84 longitude / latitude is assumed
  /// (CoordRefSys.CRS84] or [CoordRefSys.CRS84h]).
  CoordRefSys? get filterCrs => _filterCrs;

  @override
  String toString() =>
      '{filter: $filter, filterLang: $filterLang, filterCrs: $filterCrs}';

  @override
  bool operator ==(Object other) =>
      other is CQLQuery &&
      filter == other.filter &&
      filterLang == other.filterLang &&
      filterCrs == other.filterCrs;

  @override
  int get hashCode => Object.hash(filter, filterLang, filterCrs);
}
