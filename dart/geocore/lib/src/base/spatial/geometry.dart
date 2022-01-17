// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'spatial.dart';

/// A base interface for geometry classes.
abstract class Geometry extends Bounded {
  /// Default `const` constructor to allow extending this abstract class.
  const Geometry();

  /// Creates an empty (non-existent) geometry.
  factory Geometry.empty() = _EmptyGeometry;

  /// The topological dimension of this geometry.
  ///
  /// For example returns 0 for point geometries, 1 for linear geometries (like
  /// linestring or linear ring) and 2 for polygons or surfaces. For geometry
  /// collections this returns the largest dimension of geometries contained in
  /// a collection.
  ///
  /// Please note that this is different from spatial and coordinate dimensions
  /// that are available on [Point] geometries.
  int get dimension;

  /// True if this geometry is considered empty without data or coordinates.
  ///
  /// Emptiness is a concept of geospatial data. A geometry object is non-null
  /// but without data or coordinates set to meaningful values. In practice try
  /// to avoid having empty geometry primitives (like point, linestring,
  /// polygon), but if a data source contains them you can use geometries with
  /// isEmpty flag set to true for such objects. For series of geometries
  /// emptiness means that a series contains zero items.
  ///
  /// See also [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
  /// for description of EMPTY geometries.
  bool get isEmpty;

  /// True if this geometry is NOT considered empty without data or coordinates.
  bool get isNotEmpty => !isEmpty;

  /// Returns a new geometry with all points transformed using [transform].
  ///
  /// The transformed geometry object must be of the same geometry type with
  /// this object.
  @override
  Geometry transform(TransformPoint transform);

  /// Returns a new geometry with all points projected using [projection].
  ///
  /// When [to] is provided, then target points of [R] are created using
  /// that as a point factory. Otherwise [projection] uses it's own factory.
  @override
  Geometry project<R extends Point>(
    Projection<R> projection, {
    PointFactory<R>? to,
  });

  /// Writes coordinates to [buffer] as defined by [format].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  void writeString(
    StringSink buffer, {
    CoordinatesFormat format = defaultFormat,
    int? decimals,
  }) {
    // todo : not implemented yet on all sub classes!!
  }

  /// A string representation of coordinates as defined by [format].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  String toStringAs({
    CoordinatesFormat format = defaultFormat,
    int? decimals,
  }) {
    final buf = StringBuffer();
    writeString(buf, format: format, decimals: decimals);
    return buf.toString();
  }

  /// A string representation of coordinates as defined by [wktFormat].
  ///
  /// Use [decimals] to set a number of decimals to nums with decimals.
  String toStringWkt({int? decimals}) {
    final buf = StringBuffer();
    writeString(buf, format: wktFormat, decimals: decimals);
    return buf.toString();
  }

  /// A string representation of coordinates as defined by [defaultFormat].
  @override
  String toString() {
    final buf = StringBuffer();
    writeString(buf);
    return buf.toString();
  }

  // note : toString() implementation may need reimplementation on sub classes
  //        if Geometry is implemented or some mixin hides this toString impl
  //        (it might be efficient to provide a specific toString on sub class)
}

/// An empty (non-existent) geometry as an private implementation.
/// The implementation may change in future.
@immutable
class _EmptyGeometry extends Geometry with EquatableMixin {
  const _EmptyGeometry();

  @override
  int get dimension => 0;

  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;

  @override
  Bounds get bounds => Bounds.empty();

  @override
  Geometry transform(TransformPoint transform) => this;

  @override
  Geometry project<R extends Point>(
    Projection<R> projection, {
    PointFactory<R>? to,
  }) =>
      throw const FormatException('Cannot project empty geometry.');

  @override
  List<Object?> get props => [];
}
