// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'temporal_ref_sys_resolver.dart';

/// Metadata about a temporal coordinate reference system (TRS) identified and
/// specified by [id].
@immutable
class TemporalRefSys {
  /// Metadata about a temporal coordinate reference system (TRS) identified and
  /// specified by [id].
  ///
  /// No normalization of identifiers is done.
  ///
  /// See also [TemporalRefSys.normalized].
  const TemporalRefSys.id(this.id);

  /// Metadata about a temporal coordinate reference system (TRS) identified and
  /// specified by the normalized identifier of [id].
  ///
  /// Normalization: `TemporalRefSysResolver.registry.normalizeId(id)`.
  ///
  /// The default implementation returns [id] unmodified (however when necessary
  /// a custom logic can be registered for [TemporalRefSysResolver]).
  TemporalRefSys.normalized(String id)
      : id = TemporalRefSysResolver.registry.normalizeId(id);

  /// The temporal coordinate reference system (TRS) identifier.
  ///
  /// The identifier is authorative, it identifies a well known or referenced
  /// specification that defines properties for a temporal coordinate reference
  /// system.
  ///
  /// Examples:
  /// * `http://www.opengis.net/def/uom/ISO-8601/0/Gregorian`: dates or
  ///    timestamps are in the Gregorian calendar and conform to
  ///    [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339.html).
  final String id;

  /// The temporal coordinate reference system resolved in this order:
  /// 1. [temporalRefSys] if it's non-null
  /// 2. otherwise `TemporalRefSys.normalized(trs)` if [trs] is non-null
  /// 3. otherwise `TemporalRefSys.gregorian`
  factory TemporalRefSys.from({
    TemporalRefSys? temporalRefSys,
    String? trs,
  }) =>
      temporalRefSys ??
      (trs != null ? TemporalRefSys.normalized(trs) : gregorian);

  /// The temporal coordinate reference system identified by
  /// 'http://www.opengis.net/def/uom/ISO-8601/0/Gregorian'.
  ///
  /// References temporal coordinates, dates or timestamps, that are in the
  /// Gregorian calendar and conform to
  /// [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339.html).
  static const TemporalRefSys gregorian =
      TemporalRefSys.id('http://www.opengis.net/def/uom/ISO-8601/0/Gregorian');

  @override
  String toString() => id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is TemporalRefSys && id == other.id);

  @override
  int get hashCode => id.hashCode;
}
