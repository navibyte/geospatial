// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/base/coordinates.dart';
import '/src/encode/base.dart';

/// An interface to write objects with coordinate data into some content format.
mixin CoordinateWriter implements BaseWriter {
  /// Writes a bounding box from [bbox].
  ///
  /// Known [BaseBox] sub classes are [Box] (projected or cartesian coordinates)
  /// and [GeoBox] (geographic coordinates).
  void box(BaseBox bbox);

  /// Writes a position from [coordinates].
  ///
  /// Known [BasePosition] sub classes are [Position] (projected or cartesian
  /// coordinates) and [GeoPosition] (geographic coordinates).
  void position(BasePosition coordinates);

  /// Writes a position array from [coordinates].
  ///
  /// The [coordinates] array is a 1-dimensional iterable.
  ///
  /// Known [BasePosition] sub classes are [Position] (projected or cartesian
  /// coordinates) and [GeoPosition] (geographic coordinates).
  void positions1D(Iterable<BasePosition> coordinates);

  /// Writes a position array from [coordinates].
  ///
  /// The [coordinates] array is a 2-dimensional iterable.
  ///
  /// Known [BasePosition] sub classes are [Position] (projected or cartesian
  /// coordinates) and [GeoPosition] (geographic coordinates).
  void positions2D(Iterable<Iterable<BasePosition>> coordinates);

  /// Writes a position array from [coordinates].
  ///
  /// The [coordinates] array is a 3-dimensional iterable.
  ///
  /// Known [BasePosition] sub classes are [Position] (projected or cartesian
  /// coordinates) and [GeoPosition] (geographic coordinates).
  void positions3D(Iterable<Iterable<Iterable<BasePosition>>> coordinates);
}
