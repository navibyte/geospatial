// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import 'geometry.dart';
import 'linestring.dart';
import 'point.dart';

/// A polygon with an exterior and optional interior boundaries.
@immutable
class Polygon<T extends Point> extends Geometry with EquatableMixin {
  /// Creates a polygon from [rings] with at least exterior boundary at index 0.
  ///
  /// Contains also interior boundaries if length is >= 2.
  ///
  /// A polygon is considered empty if the exterior is empty.
  Polygon(this.rings) {
    validate();
  }

  @protected
  void validate() {
    if (rings.isEmpty) {
      throw ArgumentError('Polygon must have exterior ring.');
    }
    rings.forEach((ring) {
      if (ring.type != LineStringType.ring) {
        throw ArgumentError('Not a linear ring.');
      }
    });
  }

  /// Linear rings with at least exterior boundary at index 0.
  ///
  /// Contains also interior boundaries if length is >= 2.
  final LineStringSeries<T> rings;

  @override
  List<Object?> get props => [rings];

  @override
  int get dimension => 2;

  @override
  bool get isEmpty => exterior.isEmpty;

  /// A linear ring forming an [exterior] boundary for this polygon.
  LineString<T> get exterior => rings.first;

  /// A series of interior rings (holes for this polygon) with 0 to N elements.
  LineStringSeries<T> get interior => LineStringSeries.view(rings.skip(1));
}

/// A series of polygons.
abstract class PolygonSeries<T extends Point> extends GeomSeries<Polygon<T>> {
  const PolygonSeries();

  /// Create an unmodifiable [PolygonSeries] backed by [source].
  factory PolygonSeries.view(Iterable<Polygon<T>> source) =
      PolygonSeriesView<T>;

  /// Create an immutable [PolygonSeries] copied from [elements].
  factory PolygonSeries.from(Iterable<Polygon<T>> elements) =>
      PolygonSeries<T>.view(List<Polygon<T>>.unmodifiable(elements));
}

/// A partial implementation of [PolygonSeries] as a mixin.
mixin PolygonSeriesMixin<T extends Point> implements PolygonSeries<T> {
  @override
  int get dimension => 1;
}

/// An unmodifiable [PolygonSeries] backed by another list.
@immutable
class PolygonSeriesView<T extends Point> extends GeomSeriesView<Polygon<T>>
    with PolygonSeriesMixin<T>
    implements PolygonSeries<T> {
  /// Create an unmodifiable [PolygonSeries] backed by [source].
  PolygonSeriesView(Iterable<Polygon<T>> source) : super(source);
}
