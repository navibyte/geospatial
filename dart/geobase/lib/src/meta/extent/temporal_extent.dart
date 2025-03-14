// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/common/reference/temporal_ref_sys.dart';
import '/src/meta/time/interval.dart';
import '/src/utils/object_utils.dart';

/// An extent with 1 to N intervals in defined temporal coordinate reference
/// system.
@immutable
class TemporalExtent {
  final Interval _first;
  final Iterable<Interval>? _intervals;
  final TemporalRefSys _trs;

  /// A temporal extent of one [interval] (temporal coordinate reference system
  /// in [trs]).
  const TemporalExtent.single(
    Interval interval, {
    TemporalRefSys trs = TemporalRefSys.gregorian,
  })  : _first = interval,
        _intervals = null,
        _trs = trs;

  /// A temporal extent of [intervals] (temporal coordinate reference system in
  /// [trs]).
  TemporalExtent.multi(
    Iterable<Interval> intervals, {
    TemporalRefSys trs = TemporalRefSys.gregorian,
  })  : _intervals = _validate(intervals),
        _first = intervals.first,
        _trs = trs;

  static Iterable<Interval> _validate(Iterable<Interval> intervals) {
    if (intervals.isEmpty) {
      throw const FormatException('At least one interval required.');
    }
    return intervals;
  }

  /// The first interval for this extent.
  Interval get first => _first;

  /// All intervals for this extent.
  Iterable<Interval> get intervals => _intervals ?? [_first];

  /// The temporal coordinate reference system for intervals of this extent.
  TemporalRefSys get trs => _trs;

  /// Copy this temporal extent with optional [interval] and/or [trs]
  /// parameters changed.
  TemporalExtent copyWith({Interval? interval, TemporalRefSys? trs}) {
    if (interval != null) {
      return TemporalExtent.single(interval, trs: trs ?? _trs);
    } else {
      if (trs != null) {
        return _intervals != null
            ? TemporalExtent.multi(_intervals!, trs: trs)
            : TemporalExtent.single(_first, trs: trs);
      } else {
        // ignore: avoid_returning_this
        return this;
      }
    }
  }

  @override
  String toString() {
    final buf = StringBuffer()..write(trs);
    for (final item in intervals) {
      buf
        ..write(',')
        ..write(item);
    }
    return buf.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemporalExtent &&
          trs == other.trs &&
          testIterableEquality(intervals, other.intervals));

  @override
  int get hashCode => Object.hash(trs, Object.hashAll(intervals));
}
