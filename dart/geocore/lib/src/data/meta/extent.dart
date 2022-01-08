// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '/src/base/geometry.dart';
import '/src/common/temporal.dart';
import '/src/coordinates/geographic.dart';

/// Geospatial extent with at least one [allBounds] and optional [allIntervals].
@immutable
class Extent with EquatableMixin {
  /// Extent with [crs], at least one bounds and intervals (with >= 0 items).
  const Extent({
    required this.crs,
    required this.allBounds,
    required this.allIntervals,
  });

  /// Extent with [crs], exactly one [bounds] and an optional [interval].
  Extent.single({
    required String crs,
    required GeoBounds bounds,
    Interval? interval,
  }) : this(
          crs: crs,
          allBounds: [bounds],
          allIntervals: interval != null ? [interval] : const Iterable.empty(),
        );

  /// Extent with [crs], at least one bounds and optional intervals.
  const Extent.multi({
    required String crs,
    required Iterable<GeoBounds> allBounds,
    Iterable<Interval>? allIntervals,
  }) : this(
          crs: crs,
          allBounds: allBounds,
          allIntervals: allIntervals ?? const Iterable.empty(),
        );

  /// The coordinate reference system for bounds items of this extent.
  final String crs;

  /// The required default geographical bounds for this extent.
  Bounds<GeoPoint> get defaultBounds => allBounds.first;

  /// All available geographic bounds for this extent iterated.
  final Iterable<GeoBounds> allBounds;

  /// An optional default temporal interval for this extent.
  Interval? get defaultInterval =>
      allIntervals.isEmpty ? null : allIntervals.first;

  /// All available temporal intervals for this extent iterated.
  final Iterable<Interval> allIntervals;

  @override
  List<Object?> get props => [crs, allBounds, allIntervals];
}
