// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import '/src/codes/coords.dart';
import '/src/codes/geo_representation.dart';
import '/src/codes/geom.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/reference/coord_ref_sys.dart';
import '/src/utils/bounds_builder.dart';
import '/src/utils/coord_arrays.dart';
import '/src/utils/coord_arrays_from_json.dart';
import '/src/utils/tolerance.dart';
import '/src/vector/array/coordinates.dart';
import '/src/vector/array/coordinates_extensions.dart';
import '/src/vector/content/simple_geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/default_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector/formats/wkb/wkb_format.dart';

import 'geometry.dart';
import 'geometry_builder.dart';

/// A line string geometry with a chain of positions.
class LineString extends SimpleGeometry {
  final PositionArray _chain;

  /// A line string geometry with a [chain] of positions and optional [bounds].
  ///
  /// The [chain] array must contain at least two positions (or be empty).
  const LineString(PositionArray chain, {super.bounds})
      : _chain = chain,
        assert(
          chain.length == 0 || chain.length >= 2,
          'Chain must contain at least two positions (or be empty)',
        );

  /// A line string geometry from a [chain] of positions and optional [bounds].
  ///
  /// The [chain] iterable must contain at least two positions (or be empty).
  ///
  /// The coordinate type of all positions in a chain should be the same.
  factory LineString.from(Iterable<Position> chain, {Box? bounds}) =>
      LineString(chain.array(), bounds: bounds);

  /// Builds a line string geometry from a [chain] of positions.
  ///
  /// Use [type] to specify the type of coordinates, by default `Coords.xy` is
  /// expected.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a geometry.
  ///
  /// The [chain] array must contain at least two positions (or be empty). It
  /// contains coordinate values of chain positions as a flat structure. For
  /// example for `Coords.xyz` the first three coordinate values are x, y and z
  /// of the first position, the next three coordinate values are x, y and z of
  /// the second position, and so on.
  ///
  /// An example to build a line string with 3 points:
  /// ```dart
  ///   LineString.build(
  ///       // points as a flat structure with three (x, y) points
  ///       [
  ///            -1.1, -1.1,
  ///            2.1, -2.5,
  ///            3.5, -3.49,
  ///       ],
  ///       type: Coords.xy,
  ///   );
  /// ```
  factory LineString.build(
    Iterable<double> chain, {
    Coords type = Coords.xy,
    Box? bounds,
  }) =>
      LineString(
        buildPositionArray(chain, type: type),
        bounds: bounds,
      );

  /// Parses a line string geometry from [text] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory LineString.parse(
    String text, {
    TextReaderFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.parse<LineString>(
        text,
        format: format,
        crs: crs,
        options: options,
      );

  /// Parses a line string geometry from [coordinates] conforming to
  /// [DefaultFormat].
  ///
  /// Use [crs] and [crsLogic] to give hints (like axis order, and whether x
  /// and y must be swapped when read in) about coordinate reference system in
  /// text input.
  factory LineString.parseCoords(
    String coordinates, {
    CoordRefSys? crs,
    GeoRepresentation? crsLogic,
  }) {
    final array = json.decode('[$coordinates]') as List<dynamic>;
    if (array.isEmpty) {
      return LineString.build(const []);
    }
    final coordType = resolveCoordType(array, positionLevel: 1);
    // NOTE: validate line string (at least two points)
    return LineString.build(
      createFlatPositionArrayDouble(
        array,
        coordType,
        swapXY: crs?.swapXY(logic: crsLogic) ?? false,
      ),
      type: coordType,
    );
  }

  /// Decodes a line string geometry from [bytes] conforming to [format].
  ///
  /// When [format] is not given, then the geometry format of [WKB] is used as
  /// a default.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  factory LineString.decode(
    Uint8List bytes, {
    BinaryFormat<SimpleGeometryContent> format = WKB.geometry,
    Map<String, dynamic>? options,
  }) =>
      GeometryBuilder.decode<LineString>(
        bytes,
        format: format,
        options: options,
      );

  @override
  Geom get geomType => Geom.lineString;

  @override
  Coords get coordType => _chain.type;

  @override
  bool get isEmptyByGeometry => _chain.isEmpty;

  /// The chain of positions in this line string geometry.
  PositionArray get chain => _chain;

  @override
  Box? calculateBounds() => BoundsBuilder.calculateBounds(
        array: _chain,
        type: coordType,
      );

  @override
  @Deprecated('Use populated or unpopulated instead.')
  LineString bounded({bool recalculate = false}) {
    if (isEmptyByGeometry) return this;

    if (recalculate || bounds == null) {
      // return a new linestring (chain kept intact) with populated bounds
      return LineString(
        chain,
        bounds: BoundsBuilder.calculateBounds(
          array: chain,
          type: coordType,
        ),
      );
    } else {
      // bounds was already populated and not asked to recalculate
      return this;
    }
  }

  @override
  LineString populated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was unpopulated and geometry not empty
      if (bounds == null && !isEmptyByGeometry) {
        return LineString(
          chain,
          bounds: BoundsBuilder.calculateBounds(
            array: chain,
            type: coordType,
          ),
        );
      }
    }
    return this;
  }

  @override
  LineString unpopulated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // create a new geometry if bounds was populated
      if (bounds != null) {
        return LineString(chain);
      }
    }
    return this;
  }

  @override
  LineString project(Projection projection) {
    final projected = _chain.project(projection);

    return LineString(
      projected,

      // bounds calculated from projected chain if there was bounds before
      bounds: bounds != null
          ? BoundsBuilder.calculateBounds(
              array: projected,
              type: coordType,
            )
          : null,
    );
  }

  @override
  void writeTo(SimpleGeometryContent writer, {String? name}) =>
      isEmptyByGeometry
          ? writer.emptyGeometry(Geom.lineString, name: name)
          : writer.lineString(
              _chain,
              type: coordType,
              name: name,
              bounds: bounds,
            );

  // NOTE: coordinates as raw data

  @override
  bool equalsCoords(Geometry other) {
    if (other is! LineString) return false;
    if (identical(this, other)) return true;
    if (bounds != null && other.bounds != null && !(bounds! == other.bounds!)) {
      // both geometries has bound boxes and boxes do not equal
      return false;
    }

    return chain.equalsCoords(other.chain);
  }

  @override
  bool equals2D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    if (other is! LineString) return false;
    if (isEmptyByGeometry || other.isEmptyByGeometry) return false;
    if (bounds != null &&
        other.bounds != null &&
        !bounds!.equals2D(
          other.bounds!,
          toleranceHoriz: toleranceHoriz,
        )) {
      // both geometries has bound boxes and boxes do not equal in 2D
      return false;
    }
    // test 2D coordinates using PositionData of chains
    return chain.data.equals2D(
      other.chain.data,
      toleranceHoriz: toleranceHoriz,
    );
  }

  @override
  bool equals3D(
    Geometry other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    assertTolerance(toleranceVert);
    if (other is! LineString) return false;
    if (isEmptyByGeometry || other.isEmptyByGeometry) return false;
    if (!coordType.is3D || !other.coordType.is3D) return false;
    if (bounds != null &&
        other.bounds != null &&
        !bounds!.equals3D(
          other.bounds!,
          toleranceHoriz: toleranceHoriz,
          toleranceVert: toleranceVert,
        )) {
      // both geometries has bound boxes and boxes do not equal in 3D
      return false;
    }
    // test 3D coordinates using PositionData of chains
    return chain.data.equals3D(
      other.chain.data,
      toleranceHoriz: toleranceHoriz,
      toleranceVert: toleranceVert,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LineString && bounds == other.bounds && chain == other.chain;

  @override
  int get hashCode => Object.hash(bounds, chain);
}
