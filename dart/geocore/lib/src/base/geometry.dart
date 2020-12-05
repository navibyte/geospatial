// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'common.dart';

/// A base interface for geometry classes.
abstract class Geometry {
  const Geometry();

  /// The topological dimension of this geometry.
  ///
  /// For example returns 0 for point geometries, 1 for linear geometries (like
  /// linestring or linear ring) and 2 for polygons. For geometry collections
  /// returns the largest dimension of geometries contained in a collection.
  int get dimension;

  /// True if this geometry is EMPTY as understood by WKT.
  ///
  /// https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry
  bool get isEmpty;

  /// True if this geometry is not EMPTY as understood by WKT.
  bool get isNotEmpty => !isEmpty;
}

/// A base interface for a series (list) of geometry items of type [T].
abstract class GeomSeries<T extends Geometry> extends Geometry
    implements Series<T> {
  const GeomSeries();

  /// Create an unmodifiable [GeomSeries] backed by [source].
  factory GeomSeries.view(Iterable<T> source) = GeomSeriesView<T>;

  /// Create an immutable [GeomSeries] copied from [elements].
  factory GeomSeries.from(Iterable<T> elements) =>
      GeomSeries<T>.view(List<T>.unmodifiable(elements));
}

/// An unmodifiable [GeomSeries] backed by another list.
@immutable
class GeomSeriesView<T extends Geometry> extends SeriesView<T>
    implements GeomSeries<T> {
  /// Create an unmodifiable [GeomSeriesView] backed by [source].
  GeomSeriesView(Iterable<T> source) : super(source);

  @override
  T operator [](int index) => this[index];

  @override
  int get dimension {
    // A base implementation for calculating a maximum dimension for a series by
    // looping through all items. Should be overridden to provide more efficient
    // implementation as needed.
    var dim = 0;
    forEach((element) => dim = math.max(dim, element.dimension));
    return dim;
  }
}
