// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An interface to write objects with coordinate data into some content format.
abstract class CoordinateWriter {
  /// Starts a section for an array of point coordinates.
  ///
  /// Coordinate arrays can be multi-dimensional, for example:
  /// ```dart
  ///   writer..coordArray()
  ///         ..coordArray()
  ///         ..coordPoint(x: 1, y: 1)
  ///         ..coordPoint(x: 2, y: 2)
  ///         ..coordArrayEnd()
  ///         ..coordArray()
  ///         ..coordPoint(x: 11, y: 11)
  ///         ..coordPoint(x: 12, y: 12)
  ///         ..coordArrayEnd()
  ///         ..coordArrayEnd()
  /// ```
  void coordArray({int? expectedCount});

  /// Ends a section for an array of point coordinates.
  void coordArrayEnd();

  /// Writes given point coordinates.
  void coordPoint({
    required num x,
    required num y,
    num? z,
    num? m,
  });

  /// A string representation of content already written to this (text) writer.
  ///
  /// Must return a valid string representation when this writer is writing to
  /// a text output. If an output does not support a string representation then
  /// returned representation is undefined.
  @override
  String toString();
}
