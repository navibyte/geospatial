// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A polygon with an exterior and optional interior boundaries.
@immutable
class Polygon<T extends Point> extends Geometry with EquatableMixin {
  /// Create a polygon from [rings] with at least exterior boundary at index 0.
  ///
  /// Contains also interior boundaries if length is >= 2.
  ///
  /// A polygon is considered empty if the exterior is empty.
  Polygon(BoundedSeries<LineString<T>> rings) : rings = validate(rings);

  /// Validate [rings] to have at least one exterior and all must be rings.
  static BoundedSeries<LineString<T>> validate<T extends Point>(
      BoundedSeries<LineString<T>> rings) {
    if (rings.isEmpty) {
      throw ArgumentError('Polygon must have exterior ring.');
    }
    rings.forEach((ring) {
      if (ring.type != LineStringType.ring) {
        throw ArgumentError('Not a linear ring.');
      }
    });
    return rings;
  }

  /// Linear rings with at least exterior boundary at index 0.
  ///
  /// Contains also interior boundaries if length is >= 2.
  final BoundedSeries<LineString<T>> rings;

  @override
  List<Object?> get props => [rings];

  @override
  int get dimension => 2;

  @override
  bool get isEmpty => exterior.isEmpty;

  @override
  Bounds get bounds => exterior.bounds;

  /// A linear ring forming an [exterior] boundary for this polygon.
  LineString<T> get exterior => rings.first;

  /// A series of interior rings (holes for this polygon) with 0 to N elements.
  BoundedSeries<LineString<T>> get interior =>
      BoundedSeries<LineString<T>>.view(rings.skip(1));
}
