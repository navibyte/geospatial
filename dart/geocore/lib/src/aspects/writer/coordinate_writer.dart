// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/schema.dart';

/// An interface to write objects with coordinate data into some content format.
abstract class CoordinateWriter {

  /// Starts a section for a geometry array of [type] (like "multi point").
  void geometryArray(Geom type);

  /// Ends a section for a geometry array.
  void geometryArrayEnd();

  /// Starts a section for a geometry of [type].
  void geometry(Geom type);

  /// Ends a section for a geometry.
  void geometryEnd();

  /// Starts a section for an array of an array for point coordinates.
  void pointArrayArray({int? expectedCount});

  /// Ends a section for an array of an array for point coordinates.
  void pointArrayArrayEnd();

  /// Starts a section for an array for point coordinates.
  void pointArray({int? expectedCount});

  /// Ends a section for an array for point coordinates.
  void pointArrayEnd();
  
  /// Writes given point coordinates.
  void point({
    required num x,
    required num y,
    num? z,
    num? m,
  });

  /// Writes given bounds coordinates.
  void bounds({
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
