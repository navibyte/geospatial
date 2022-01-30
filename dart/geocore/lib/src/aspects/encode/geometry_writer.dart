// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/codes.dart';

import 'base_writer.dart';
import 'bounds_writer.dart';
import 'coordinate_writer.dart';

/// A function that is capable of writing a geometry to [writer].
typedef WriteGeometry = void Function(GeometryWriter writer);

/// An interface to write geometry objects into some content format.
abstract class GeometryWriter extends BaseWriter { 
  /// Writes a geometry of [type] with [coordinates].
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bounds] function can be used to write geometry bounds. A
  /// writer implementation may use it or ignore it.
  void geometry({
    required Geom type,
    required WriteCoordinates coordinates,
    Coords? coordType,
    WriteBounds? bounds,
  });

  /// Writes a geometry collection of [geometries].
  ///
  /// An optional [expectedCount], when given, hints the count of geometries.
  ///
  /// An optional [bounds] function can be used to write geometry collection
  /// bounds. A writer implementation may use it or ignore it.
  void geometryCollection(
    Iterable<WriteGeometry> geometries, {
    int? expectedCount,
    WriteBounds? bounds,
  });

  /// Writes an empty geometry of [type].
  void emptyGeometry(Geom type);
}
