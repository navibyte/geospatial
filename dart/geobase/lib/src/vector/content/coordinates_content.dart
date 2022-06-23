// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/base.dart';
import '/src/coordinates/geographic.dart';
import '/src/coordinates/projected.dart';

/// An interface to write coordinate data to a geospatial content receiver.
/// 
/// A receiver could be a geospatial data format writer or an object factory.
mixin CoordinateContent {
  /// Writes a bounding box represented by [bbox].
  ///
  /// Known [Box] sub classes are [ProjBox] (projected or cartesian coordinates)
  /// and [GeoBox] (geographic coordinates).
  void box(Box bbox);

  /// Writes a position represented by [coordinates].
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates).
  void position(Position coordinates);

  /// Writes a position array represented by [coordinates].
  ///
  /// The [coordinates] array is a 1-dimensional iterable.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates).
  void positions1D(Iterable<Position> coordinates);

  /// Writes a position array represented by [coordinates].
  ///
  /// The [coordinates] array is a 2-dimensional iterable.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates).
  void positions2D(Iterable<Iterable<Position>> coordinates);

  /// Writes a position array represented by [coordinates].
  ///
  /// The [coordinates] array is a 3-dimensional iterable.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates).
  void positions3D(Iterable<Iterable<Iterable<Position>>> coordinates);
}
