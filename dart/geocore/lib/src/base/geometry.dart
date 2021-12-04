// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

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

  /// Returns a new geometry with all points projected using [transform].
  /// 
  /// The projected geometry object must be of the same geometry type with this 
  /// object.
  @override
  Geometry project(TransformPoint transform);
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
  Geometry project(TransformPoint transform) => this;

  @override
  List<Object?> get props => [];
}
