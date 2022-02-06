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
  void box(BaseBox bbox);

  /// Writes a position from [coordinates].
  void position(BasePosition coordinates);

  /// Writes a position array from [coordinates].
  ///
  /// The [coordinates] array is a 1-dimensional iterable.
  void positions1D(Iterable<BasePosition> coordinates);

  /// Writes a position array from [coordinates].
  ///
  /// The [coordinates] array is a 2-dimensional iterable.
  void positions2D(Iterable<Iterable<BasePosition>> coordinates);

  /// Writes a position array from [coordinates].
  ///
  /// The [coordinates] array is a 3-dimensional iterable.
  void positions3D(Iterable<Iterable<Iterable<BasePosition>>> coordinates);
}
