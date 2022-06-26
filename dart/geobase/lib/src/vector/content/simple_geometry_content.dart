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

/// A function that is capable of writing a simple geometry to [output].
typedef WriteSimpleGeometries = void Function(SimpleGeometryContent output);

/// An interface to write simple geometries to a geospatial content receiver.
///
/// This interface supports following "simple" geometry types introduced in the
/// [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
/// standard by [The Open Geospatial Consortium](https://www.ogc.org/): `point`,
/// `lineString`, `polygon`, `multiPoint`, `multiLineString`, `multiPolygon`,
/// `geometryCollection`.
///
/// A receiver could be a geospatial data format writer or an object factory.
abstract class SimpleGeometryContent {
  /// Writes a point geometry with a position from [coordinates].
  ///
  /// The [coordinates] represents a single position.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates).
  void point(
    Position coordinates, {
    String? name,
    Coords? coordType,
  });

  /// Writes a line string geometry with a position array from [coordinates].
  ///
  /// The [coordinates] array is a 1-dimensional iterable representing positions
  /// of points in a line string.
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
  void lineString(
    Iterable<Position> coordinates, {
    String? name,
    Coords? coordType,
    Box? bbox,
  });

  /// Writes a polygon geometry with a position array from [coordinates].
  ///
  /// The [coordinates] array is a 2-dimensional iterable representing positions
  /// of points in linear rings (outer and inner) of a polygon.
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
  void polygon(
    Iterable<Iterable<Position>> coordinates, {
    String? name,
    Coords? coordType,
    Box? bbox,
  });

  /// Writes a multi point geometry with a position array from [coordinates].
  ///
  /// The [coordinates] array is a 1-dimensional iterable representing positions
  /// of points in a multi point collection.
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
  void multiPoint(
    Iterable<Position> coordinates, {
    String? name,
    Coords? coordType,
    Box? bbox,
  });

  /// Writes a multi line string with a position array from [coordinates].
  ///
  /// The [coordinates] array is a 2-dimensional iterable representing positions
  /// of points in line strings of a multi line string collection.
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
  void multiLineString(
    Iterable<Iterable<Position>> coordinates, {
    String? name,
    Coords? coordType,
    Box? bbox,
  });

  /// Writes a multi polygon geometry with a position array from [coordinates].
  ///
  /// The [coordinates] array is a 3-dimensional iterable representing positions
  /// of points in linear rings (outer and inner) of polygons in a multi polygon
  /// collection.
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
  void multiPolygon(
    Iterable<Iterable<Iterable<Position>>> coordinates, {
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
    required WriteSimpleGeometries geometries,
    int? count,
    String? name,
    Box? bbox,
  });

  /// Writes an empty geometry of [type].
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  void emptyGeometry(Geom type, {String? name});
}
