// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/codes.dart';
import '/src/aspects/data.dart';

import 'base_writer.dart';
import 'bounds_writer.dart';

/// A function that is capable of writing a geometry to [writer].
typedef WriteGeometries = void Function(GeometryWriter writer);

/// An interface to write geometry objects into some content format.
mixin GeometryWriter implements BaseWriter {
  /// Writes a geometry of [type] with a position from [coordinates].
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bounds] function can be used to write geometry bounds. A
  /// writer implementation may use it or ignore it.
  void geometryWithPosition({
    required Geom type,
    required Position coordinates,
    String? name,
    Coords? coordType,
    WriteBounds? bounds,
  });

  /// Writes a geometry of [type] with a position array from [coordinates].
  ///
  /// The [coordinates] array is a 1-dimensional iterable.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bounds] function can be used to write geometry bounds. A
  /// writer implementation may use it or ignore it.
  void geometryWithPositions1D({
    required Geom type,
    required Iterable<Position> coordinates,
    String? name,
    Coords? coordType,
    WriteBounds? bounds,
  });

  /// Writes a geometry of [type] with a position array from [coordinates].
  ///
  /// The [coordinates] array is a 2-dimensional iterable.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bounds] function can be used to write geometry bounds. A
  /// writer implementation may use it or ignore it.
  void geometryWithPositions2D({
    required Geom type,
    required Iterable<Iterable<Position>> coordinates,
    String? name,
    Coords? coordType,
    WriteBounds? bounds,
  });

  /// Writes a geometry of [type] with a position array from [coordinates].
  ///
  /// The [coordinates] array is a 3-dimensional iterable.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bounds] function can be used to write geometry bounds. A
  /// writer implementation may use it or ignore it.
  void geometryWithPositions3D({
    required Geom type,
    required Iterable<Iterable<Iterable<Position>>> coordinates,
    String? name,
    Coords? coordType,
    WriteBounds? bounds,
  });

  /// Writes a geometry collection of [geometries].
  ///
  /// An optional expected [count], when given, hints the count of geometries.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bounds] function can be used to write geometry collection
  /// bounds. A writer implementation may use it or ignore it.
  void geometryCollection({
    required WriteGeometries geometries,
    int? count,
    String? name,
    WriteBounds? bounds,
  });

  /// Writes an empty geometry of [type].
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  void emptyGeometry(Geom type, {String? name});
}
