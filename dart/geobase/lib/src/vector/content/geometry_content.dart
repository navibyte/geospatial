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

import 'simple_geometry_content.dart';

/// A function that is capable of writing a geometry to [output].
typedef WriteGeometries = void Function(GeometryContent output);

/// An interface to write geometry objects to a geospatial content receiver.
///
/// A receiver could be a geospatial data format writer or an object factory.
///
/// This mixin supports specific simple geometry types defined by
/// [SimpleGeometryContent] and also other (non-specific) geometry types
/// supported by implementers of the mixin.
///
/// Coordinate positions are represented either as [Position] or
/// `Iterable<num>`. Bounding boxes are represented either as [Box] or
/// `Iterable<num>`.
mixin GeometryContent implements SimpleGeometryContent {
  /// Writes a geometry of [type] with a position represented by [coordinates].
  ///
  /// The [coordinates] represents a single position of [Position] or
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
  void geometryWithPosition({
    required Geom type,
    required Object coordinates,
    String? name,
    Coords? coordType,
    Object? bbox,
  });

  /// Writes a geometry of [type] with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array containing `Object` items
  /// representing positions of points. Supported sub classes for items are
  /// [Position] and `Iterable<num>`.
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
  void geometryWithPositions1D({
    required Geom type,
    required Iterable<Object> coordinates,
    String? name,
    Coords? coordType,
    Object? bbox,
  });

  /// Writes a geometry of [type] with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array of arrays containing `Object` items
  /// representing positions of points. Supported sub classes for items are
  /// [Position] and `Iterable<num>`.
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
  void geometryWithPositions2D({
    required Geom type,
    required Iterable<Iterable<Object>> coordinates,
    String? name,
    Coords? coordType,
    Object? bbox,
  });

  /// Writes a geometry of [type] with a position array from [coordinates].
  ///
  /// The [coordinates] iterable is an array of arrays of arrays containing
  /// `Object` items representing positions of points. Supported sub classes for
  /// items are [Position] and `Iterable<num>`.
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
  void geometryWithPositions3D({
    required Geom type,
    required Iterable<Iterable<Iterable<Object>>> coordinates,
    String? name,
    Coords? coordType,
    Object? bbox,
  });

  @override
  void point(
    Object coordinates, {
    String? name,
    Coords? coordType,
  }) =>
      geometryWithPosition(
        type: Geom.point,
        coordinates: coordinates,
        name: name,
        coordType: coordType,
      );

  @override
  void lineString(
    Iterable<Object> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) =>
      geometryWithPositions1D(
        type: Geom.lineString,
        coordinates: coordinates,
        name: name,
        coordType: coordType,
        bbox: bbox,
      );

  @override
  void polygon(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) =>
      geometryWithPositions2D(
        type: Geom.polygon,
        coordinates: coordinates,
        name: name,
        coordType: coordType,
        bbox: bbox,
      );

  @override
  void multiPoint(
    Iterable<Object> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) =>
      geometryWithPositions1D(
        type: Geom.multiPoint,
        coordinates: coordinates,
        name: name,
        coordType: coordType,
        bbox: bbox,
      );

  @override
  void multiLineString(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) =>
      geometryWithPositions2D(
        type: Geom.multiLineString,
        coordinates: coordinates,
        name: name,
        coordType: coordType,
        bbox: bbox,
      );

  @override
  void multiPolygon(
    Iterable<Iterable<Iterable<Object>>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) =>
      geometryWithPositions3D(
        type: Geom.multiPolygon,
        coordinates: coordinates,
        name: name,
        coordType: coordType,
        bbox: bbox,
      );
}
