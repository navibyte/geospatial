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
mixin GeometryContent implements SimpleGeometryContent {
  ///
  /// The [coordinates] represents a single position.
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

  @override
  void point(
    Position coordinates, {
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
    Iterable<Position> coordinates, {
    String? name,
    Coords? coordType,
    Box? bbox,
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
    Iterable<Iterable<Position>> coordinates, {
    String? name,
    Coords? coordType,
    Box? bbox,
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
    Iterable<Position> coordinates, {
    String? name,
    Coords? coordType,
    Box? bbox,
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
    Iterable<Iterable<Position>> coordinates, {
    String? name,
    Coords? coordType,
    Box? bbox,
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
    Iterable<Iterable<Iterable<Position>>> coordinates, {
    String? name,
    Coords? coordType,
    Box? bbox,
  }) =>
      geometryWithPositions3D(
        type: Geom.multiPolygon,
        coordinates: coordinates,
        name: name,
        coordType: coordType,
        bbox: bbox,
      );
}
