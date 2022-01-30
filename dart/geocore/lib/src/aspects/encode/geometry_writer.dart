// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/codes.dart';

import 'bounds_writer.dart';
import 'coordinate_writer.dart';

/// An interface to write geometry objects into some content format.
abstract class GeometryWriter implements CoordinateWriter, BoundsWriter {
  /// Starts a section for a geometry of [type].
  ///
  /// Use [expectedType] to define the type of coordinates.
  ///
  /// An optional [bounds] function can be used to write geometry bounds. A
  /// writer implementation may use it or ignore it.
  void geometry(Geom type, {Coords? expectedType, WriteBounds? bounds});

  /// Ends a section for a geometry.
  void geometryEnd();

  /// Writes an empty geometry of [type].
  void emptyGeometry(Geom type);

  /// Starts a section for an array of bounded objects.
  void boundedArray({int? expectedCount});

  /// Ends a section for an array of bounded objects.
  void boundedArrayEnd();

  /// A string representation of content already written to this (text) writer.
  ///
  /// Must return a valid string representation when this writer is writing to
  /// a text output. If an output does not support a string representation then
  /// returned representation is undefined.
  @override
  String toString();
}
