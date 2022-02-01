// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'base_writer.dart';

/// A function that is capable of writing coordinates to [writer].
typedef WriteCoordinates = void Function(CoordinateWriter writer);

/// An interface to write objects with coordinate data into some content format.
abstract class CoordinateWriter extends BaseWriter {
  /// Starts a section for an array of point coordinates.
  /// 
  /// An optional expected [count], when given, hints the count of items.
  ///
   /// An example of one dimensional coordinate array:
  /// ```dart
  ///   writer..coordArray(count: 2)
  ///         ..coordPoint(x: 1, y: 1)
  ///         ..coordPoint(x: 2, y: 2)
  ///         ..coordArrayEnd();
  /// ```
  /// 
  /// Coordinate arrays can be also multi-dimensional, for example:
  /// ```dart
  ///   writer..coordArray(count: 2)
  ///         ..coordArray(count: 2)
  ///         ..coordPoint(x: 1, y: 1)
  ///         ..coordPoint(x: 2, y: 2)
  ///         ..coordArrayEnd()
  ///         ..coordArray()
  ///         ..coordPoint(x: 11, y: 11)
  ///         ..coordPoint(x: 12, y: 12)
  ///         ..coordArrayEnd()
  ///         ..coordArrayEnd();
  /// ```
  void coordArray({int? count});

  /// Ends a section for an array of point coordinates.
  void coordArrayEnd();

  /// Writes given point coordinates.
  void coordPoint({
    required num x,
    required num y,
    num? z,
    num? m,
  });
}
