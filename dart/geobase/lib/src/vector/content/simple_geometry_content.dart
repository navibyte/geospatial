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

/// A function to write simple geometry data to [output].
typedef WriteSimpleGeometries = void Function(SimpleGeometryContent output);

/// An interface to write simple geometry data to format encoders and object
/// builders.
///
/// This interface supports following "simple" geometry types introduced in the
/// [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
/// standard by [The Open Geospatial Consortium](https://www.ogc.org/): `point`,
/// `lineString`, `polygon`, `multiPoint`, `multiLineString`, `multiPolygon`,
/// `geometryCollection`.
///
/// Coordinate positions are represented either as [Position] or
/// `Iterable<num>`. Bounding boxes are represented either as [Box] or
/// `Iterable<num>`.
abstract class SimpleGeometryContent {
  /// Writes a point geometry with a position from [coordinates].
  ///
  /// The [coordinates] represents a single position of [Position] or
  /// `Iterable<num>`.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Other sub classes
  /// are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  void point(
    Object coordinates, {
    String? name,
    Coords? coordType,
  });

  /// Writes a line string geometry with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array containing `Object` items
  /// representing positions of points in a line string. Supported sub classes
  /// for items are [Position] and `Iterable<num>`.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bbox] of [Box] or `Iterable<num>` can used set a minimum
  /// bounding box for a geometry written. A writer implementation may use it or
  /// ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates). Other sub classes are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  void lineString(
    Iterable<Object> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  });

  /// Writes a polygon geometry with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array of arrays containing `Object` items
  /// representing positions of points in linear rings (outer and inner) of a
  /// polygon. Supported sub classes for items are [Position] and
  /// `Iterable<num>`.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bbox] of [Box] or `Iterable<num>` can used set a minimum
  /// bounding box for a geometry written. A writer implementation may use it or
  /// ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates). Other sub classes are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  void polygon(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  });

  /// Writes a multi point geometry with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array containing `Object` items
  /// representing positions of points in a multi point collection. Supported
  /// sub classes for items are [Position] and `Iterable<num>`.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bbox] of [Box] or `Iterable<num>` can used set a minimum
  /// bounding box for a geometry written. A writer implementation may use it or
  /// ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates). Other sub classes are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  void multiPoint(
    Iterable<Object> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  });

  /// Writes a multi line string with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array of arrays containing `Object` items
  /// representing positions of points in line strings of a multi line string
  /// collection. Supported sub classes for items are [Position] and
  /// `Iterable<num>`.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bbox] of [Box] or `Iterable<num>` can used set a minimum
  /// bounding box for a geometry written. A writer implementation may use it or
  /// ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates). Other sub classes are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  void multiLineString(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  });

  /// Writes a multi polygon geometry with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array of arrays of arrays containing
  /// `Object` items representing positions of points in linear rings (outer and
  /// inner) of polygons in a multi polygon collection. Supported sub classes
  /// for items are [Position] and `Iterable<num>`.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// Use [coordType] to define the type of coordinates.
  ///
  /// An optional [bbox] of [Box] or `Iterable<num>` can used set a minimum
  /// bounding box for a geometry written. A writer implementation may use it or
  /// ignore it.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Known [Box] sub
  /// classes are [ProjBox] (projected or cartesian coordinates) and [GeoBox]
  /// (geographic coordinates). Other sub classes are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  void multiPolygon(
    Iterable<Iterable<Iterable<Object>>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  });

  /// Writes a geometry collection of [geometries].
  ///
  /// An optional expected [count], when given, hints the count of geometries.
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  ///
  /// An optional [bbox] of [Box] or `Iterable<num>` can used set a minimum
  /// bounding box for a geometry written. A writer implementation may use it or
  /// ignore it.
  ///
  /// Known [Box] sub classes are [ProjBox] (projected or cartesian coordinates)
  /// and [GeoBox] (geographic coordinates). Other sub classes are supported
  /// too.
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  void geometryCollection({
    required WriteSimpleGeometries geometries,
    int? count,
    String? name,
    Object? bbox,
  });

  /// Writes an empty geometry of [type].
  ///
  /// Use [name] to specify a name for a geometry (when applicable).
  /// 
  /// Note: normally it might be a good idea to avoid "empty geometries" as
  /// those are encoded and decoded with different ways in different formats.
  void emptyGeometry(Geom type, {String? name});
}
