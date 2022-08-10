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
  factory Geometry.empty(Geom type) = _EmptyGeometry;

  /// The type of this geometry.
  Geom get typeGeom;

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

  /// Returns one of points contained by this geometry if it's not empty.
  ///
  /// An immutable instance of the geometry class should always return the same
  /// point instance. For example a line string could return the first point of
  /// a chain.
  Point? get onePoint;

  /// Returns a new geometry with all points transformed using [transform].
  ///
  /// The transformed geometry object must be of the same geometry type with
  /// this object.
  @override
  Geometry transform(TransformPosition transform);

  /// Returns a new geometry with all points projected using [projection].
  ///
  /// When [to] is provided, then target points of [R] are created using
  /// that as a point factory. Otherwise [projection] uses it's own factory.
  @override
  Geometry project<R extends Point>(
    Projection<R> projection, {
    CreatePosition<R>? to,
  });

  /// Writes this geometry object to [writer].
  void writeTo(GeometryContent writer);

  /// A string representation of this geometry, with [format] applied.
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  String toStringAs({
    TextWriterFormat<GeometryContent> format = DefaultFormat.geometry,
    int? decimals,
  }) {
    final encoder = format.encoder(decimals: decimals);
    writeTo(encoder.writer);
    return encoder.toText();
  }
}

/// An empty (non-existent) geometry as an private implementation.
/// The implementation may change in future.
@immutable
class _EmptyGeometry extends Geometry {
  const _EmptyGeometry(this.typeGeom);

  @override
  final Geom typeGeom;

  @override
  int get dimension => 0;

  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;

  @override
  Bounds? get bounds => null;

  @override
  Bounds? get boundsExplicit => null;

  @override
  Point? get onePoint => null;

  @override
  void writeTo(SimpleGeometryContent output) => output.emptyGeometry(typeGeom);

  @override
  Geometry transform(TransformPosition transform) => this;

  @override
  Geometry project<R extends Point>(
    Projection<R> projection, {
    CreatePosition<R>? to,
  }) =>
      throw const FormatException('Cannot project empty geometry.');

  @override
  bool operator ==(Object other) =>
      other is _EmptyGeometry && typeGeom == other.typeGeom;

  @override
  int get hashCode => typeGeom.hashCode;

  @override
  String toString() => toStringAs();
}
