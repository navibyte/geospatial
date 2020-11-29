// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import '../base/crs.dart';
import '../base/temporal.dart';
import '../geo/geobounds.dart';

/// Geospatial extent with at least one [bounds] and optional [intervals].
abstract class Extent {
  const Extent();

  /// Extent with [crs], exactly one [bounds] and an optional [interval].
  factory Extent.single(
          {required CRS crs, required GeoBounds bounds, Interval? interval}) =>
      Extent.multi(
          crs: crs,
          allBounds: [bounds],
          allIntervals: interval != null ? [interval] : []);

  /// Extent with [crs], at least one bounds and optional intervals.
  factory Extent.multi(
      {required CRS crs,
      required Iterable<GeoBounds> allBounds,
      Iterable<Interval> allIntervals}) = ExtentBase;

  /// The coordinate reference system for bounds items of this extent.
  CRS get crs;

  /// The required default geographical bounds for this extent.
  GeoBounds get defaultBounds;

  /// All available geographical bounds for this extent iterated.
  Iterable<GeoBounds> get allBounds;

  /// An optional default temporal interval for this extent.
  Interval? get defaultInterval;

  /// All available temporal intervals for this extent iterated.
  Iterable<Interval> get allIntervals;
}

/// A base implementation for the [Extent] interface.
@immutable
class ExtentBase extends Extent with EquatableMixin {
  /// Extent with [crs], at least one bounds and optional intervals.
  const ExtentBase(
      {required this.crs,
      required this.allBounds,
      this.allIntervals = const Iterable.empty()});

  @override
  final CRS crs;

  @override
  final Iterable<GeoBounds> allBounds;

  @override
  final Iterable<Interval> allIntervals;

  @override
  GeoBounds get defaultBounds => allBounds.first;

  @override
  Interval? get defaultInterval =>
      allIntervals.isEmpty ? null : allIntervals.first;

  @override
  List<Object?> get props => [crs, allBounds, allIntervals];
}
