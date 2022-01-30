// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A function that is capable of writing bounds to [writer] for some object.
typedef WriteBounds = void Function(BoundsWriter writer);

/// An interface to write bounds objects into some content format.
abstract class BoundsWriter {
  /// Writes given bounds coordinates.
  void coordBounds({
    required num minX,
    required num minY,
    num? minZ,
    num? minM,
    required num maxX,
    required num maxY,
    num? maxZ,
    num? maxM,
  });

  /// A string representation of content already written to this (text) writer.
  ///
  /// Must return a valid string representation when this writer is writing to
  /// a text output. If an output does not support a string representation then
  /// returned representation is undefined.
  @override
  String toString();
}
