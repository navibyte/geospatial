// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

/// A base interface for geometry classes.
abstract class Geometry {
  const Geometry();

  /// The topological dimension of this geometry.
  /// 
  /// For example returns 0 for point geometries, 1 for linear geometries (like
  /// linestring or polyline) and 2 for polygons. For geometry collections 
  /// returns the largest dimension of geometries contained in a collection.
  int get dimension;

  /// The number of coordinate values (2, 3 or 4) for this geometry.
  /// 
  /// If value is 2, the geometry has 2D coordinates without m coordinate.
  /// 
  /// If value is 3, the geometry has 2D coordinates with m coordinate or it
  /// has 3D coordinates without m coordinate.
  /// 
  /// If value is 4, the geometry has 3D coordinates with m coordinate.
  ///
  /// Must be >= [spatialDimension].
  int get coordinateDimension;

  /// The number of spatial coordinate values (2 for 2D or 3 for 3D).
  int get spatialDimension;

}



