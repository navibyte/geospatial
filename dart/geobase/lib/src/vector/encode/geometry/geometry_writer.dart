// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/coordinates/base.dart';
import '/src/coordinates/geographic.dart';
import '/src/coordinates/projected.dart';
import '/src/vector/encode/base.dart';

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
  /// An optional [bbox] can used set a minimum bounding box for a geometry
  /// written. A writer implementation may use it or ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates).
  void geometryWithPosition({
    required Geom type,
    required Position coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  });

  /// Writes a geometry of [type] with a position array from [coordinates].
  ///
  /// The [coordinates] array is a 1-dimensional iterable.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bbox] can used set a minimum bounding box for a geometry
  /// written. A writer implementation may use it or ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates).
  void geometryWithPositions1D({
    required Geom type,
    required Iterable<Position> coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  });

  /// Writes a geometry of [type] with a position array from [coordinates].
  ///
  /// The [coordinates] array is a 2-dimensional iterable.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bbox] can used set a minimum bounding box for a geometry
  /// written. A writer implementation may use it or ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates).
  void geometryWithPositions2D({
    required Geom type,
    required Iterable<Iterable<Position>> coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  });

  /// Writes a geometry of [type] with a position array from [coordinates].
  ///
  /// The [coordinates] array is a 3-dimensional iterable.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bbox] can used set a minimum bounding box for a geometry
  /// written. A writer implementation may use it or ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates).
  void geometryWithPositions3D({
    required Geom type,
    required Iterable<Iterable<Iterable<Position>>> coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  });

  /// Writes a geometry collection of [geometries].
  ///
  /// An optional expected [count], when given, hints the count of geometries.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bbox] can used set a minimum bounding box for a geometry
  /// written. A writer implementation may use it or ignore it.
  ///
  /// Known [Box] sub classes are [ProjBox] (projected or cartesian coordinates)
  /// and [GeoBox] (geographic coordinates).
  void geometryCollection({
    required WriteGeometries geometries,
    int? count,
    String? name,
    Box? bbox,
  });

  /// Writes an empty geometry of [type].
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  void emptyGeometry(Geom type, {String? name});
}
