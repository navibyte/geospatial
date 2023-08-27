// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/reference/coord_ref_sys.dart';
import '/src/utils/bounds_builder.dart';
import '/src/utils/coord_arrays.dart';
import '/src/utils/coord_type.dart';
import '/src/utils/tolerance.dart';
import '/src/vector/content/feature_content.dart';
import '/src/vector/content/geometry_content.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector_data/model/geometry/geometry.dart';
import '/src/vector_data/model/geometry/geometry_builder.dart';

import 'feature_builder.dart';
import 'feature_object.dart';

/// A feature is a geospatial entity with [id], [properties] and [geometry].
///
/// Features are `bounded` objects with optional [bounds] defining a minimum
/// bounding box for a feature.
///
/// Some implementations may also contain "foreign members", like [custom] data
/// containing property objects.
///
/// Feature objects have an optional primary [geometry] of [T].
///
/// According to the [OGC Glossary](https://www.ogc.org/ogc/glossary/f) a
/// feature is "a digital representation of a real world entity. It has a
/// spatial domain, a temporal domain, or a spatial/temporal domain as one of
/// its attributes. Examples of features include almost anything that can be
/// placed in time and space, including desks, buildings, cities, trees, forest
/// stands, ecosystems, delivery vehicles, snow removal routes, oil wells, oil
/// pipelines, oil spill, and so on".
///
/// Supports representing data from GeoJSON (https://geojson.org/) features.
class Feature<T extends Geometry> extends FeatureObject {
  final Object? _id;
  final T? _geometry;
  final Map<String, dynamic> _properties;

  /// A feature of [id], [geometry] and [properties].
  ///
  /// An optional [id], when given, should be either a string or an integer
  /// number.
  ///
  /// An optional [geometry] of [T], when given, is the primary geometry of the
  /// feature.
  ///
  /// An optional [properties] defines feature properties as a map with data
  /// similar to a JSON Object.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a feature.
  ///
  /// Use an optional [custom] parameter to set any custom or "foreign member"
  /// properties.
  const Feature({
    Object? id,
    T? geometry,
    Map<String, dynamic>? properties,
    super.bounds,
    super.custom,
  })  : _id = id,
        _properties = properties ?? const {},
        _geometry = geometry;

  /// Builds a feature from [id], [geometry] and [properties].
  ///
  /// An optional [id], when given, should be either a string or an integer
  /// number.
  ///
  /// An optional [geometry] is a callback function providing the content of
  /// geometry objects. The geometry of [T] named "geometry" or the first
  /// geometry of [T] without name is stored as the primary geometry. Any other
  /// geometries are ignored (in this Feature implementation).
  ///
  /// An optional [properties] defines feature properties as a map with data
  /// similar to a JSON Object.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a feature.
  ///
  /// Use an optional [custom] parameter to set any custom or "foreign member"
  /// properties.
  ///
  /// An example to create a feature containing a point geometry, the returned
  /// type is `Feature<Point>`:
  ///
  /// ```dart
  ///   Feature<Point>.build(
  ///       id: '1',
  ///       geometry: (geom) => geom.point([10.123, 20.25]),
  ///       properties: {
  ///          'foo': 100,
  ///          'bar': 'this is property value',
  ///          'baz': true,
  ///       },
  ///   );
  /// ```
  factory Feature.build({
    Object? id,
    WriteGeometries? geometry,
    Map<String, dynamic>? properties,
    Iterable<double>? bounds,
    Map<String, dynamic>? custom,
  }) {
    // optional geometry to be built
    T? primaryGeometry;

    // use geometry builder to build primary geometry
    if (geometry != null) {
      // first try to get first geometry named "geometry"
      GeometryBuilder.build(
        geometry,
        to: (Geometry geometry, {String? name}) {
          if (name == 'geometry' && geometry is T) {
            // set "primary" geometry if not yet set
            primaryGeometry ??= geometry;
          }
        },
      );
      // if not found, then try to get first unnamed geometry
      if (primaryGeometry == null) {
        GeometryBuilder.build(
          geometry,
          to: (Geometry geometry, {String? name}) {
            if (name == null && geometry is T) {
              // set "primary" geometry if not yet set
              primaryGeometry ??= geometry;
            }
          },
        );
      }
    }

    // create a feature
    return Feature(
      id: id,
      geometry: primaryGeometry,
      properties: properties,
      bounds: buildBoxCoordsOpt(bounds),
      custom: custom,
    );
  }

  /// Parses a feature with the geometry of [T] from [text] conforming to
  /// [format].
  ///
  /// When [format] is not given, then the feature format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  static Feature<T> parse<T extends Geometry>(
    String text, {
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      FeatureBuilder.parse<Feature<T>, T>(
        text,
        format: format,
        crs: crs,
        options: options,
      );

  /// Decodes a feature with the geometry of [T] from [data] conforming to
  /// [format].
  ///
  /// Data should be a JSON Object as decoded by the standard `json.decode()`.
  ///
  /// When [format] is not given, then the feature format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  static Feature<T> fromData<T extends Geometry>(
    Map<String, dynamic> data, {
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      FeatureBuilder.decodeData<Feature<T>, T>(
        data,
        format: format,
        crs: crs,
        options: options,
      );

  /// An optional identifier (a string or number) for this feature.
  Object? get id => _id;

  /// An optional primary geometry of [T] for this feature.
  T? get geometry => _geometry;

  /// Required properties for this feature (allowed to be empty).
  Map<String, dynamic> get properties => _properties;

  @override
  Coords get coordType => geometry?.coordType ?? Coords.xy;

  /// Copy this feature with optional [id], [geometry], [properties] and
  /// [custom] properties.
  ///
  /// If [bounds] object is available on this, it's recalculated for a new
  /// feature when [geometry] is given.
  Feature<T> copyWith({
    Object? id,
    T? geometry,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? custom,
  }) =>
      Feature(
        id: id ?? this.id,
        geometry: geometry ?? this.geometry,
        properties: properties ?? this.properties,
        custom: custom ?? this.custom,

        // bounds calculated from new geometry if there was bounds before
        bounds: bounds != null && geometry != null
            ? _buildBoundsFrom(geometry)
            : bounds,
      );

  @override
  Box? calculateBounds() => geometry?.calculateBounds();

  @override
  Feature<T> bounded({bool recalculate = false}) {
    final currGeom = geometry;
    if (currGeom == null || currGeom.isEmpty) return this;

    // ensure geometry is processed first
    final geom = currGeom.bounded(recalculate: recalculate) as T;

    // return a new feature with processed geometry and populated bounds
    return Feature<T>(
      id: id,
      geometry: geom,
      properties: properties,
      custom: custom,
      bounds: recalculate || bounds == null ? _buildBoundsFrom(geom) : bounds,
    );
  }

  @override
  Feature<T> project(Projection projection) {
    final projectedGeom = geometry?.project(projection) as T?;

    return Feature<T>(
      id: id,
      geometry: projectedGeom,
      properties: properties,
      custom: custom,

      // bounds calculated from projected geometry if there was bounds before
      bounds: bounds != null && projectedGeom != null
          ? _buildBoundsFrom(projectedGeom)
          : null,
    );
  }

  @override
  void writeTo(FeatureContent writer) {
    final geom = geometry;
    writer.feature(
      id: id,
      geometry: geom?.writeTo,
      properties: properties,
      bounds: bounds?.valuesByType(coordType),
      custom: custom,
    );
  }

  /// Returns true if this and [other] contain exactly same coordinate values
  /// (or both are empty) in the same order and with the same coordinate type.
  bool equalsCoords(Feature other) {
    if (identical(this, other)) return true;

    if (bounds != null && other.bounds != null && !(bounds! == other.bounds!)) {
      // both feature collections has bound boxes and boxes do not equal
      return false;
    }

    // test main geometry
    final mg1 = geometry;
    final mg2 = other.geometry;
    if (mg1 != null) {
      if (mg2 == null) return false;
      if (!mg1.equalsCoords(mg2)) return false;
    } else {
      if (mg2 != null) return false;
    }

    return true;
  }

  /// True if this feature equals with [other] by testing 2D coordinates of the
  /// [geometry].
  ///
  /// Returns false if this or [other] contain a null or "empty" geometry object
  /// in `geometry`.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals2D(
    Feature other, {
    double toleranceHoriz = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);

    // test bounding boxes if both have it
    if (bounds != null &&
        other.bounds != null &&
        !bounds!.equals2D(
          other.bounds!,
          toleranceHoriz: toleranceHoriz,
        )) {
      // both features has bound boxes and boxes do not equal in 2D
      return false;
    }

    // test main geometry
    final mg1 = geometry;
    final mg2 = other.geometry;
    if (mg1 == null || mg2 == null || mg1.isEmpty || mg2.isEmpty) return false;
    if (!mg1.equals2D(
      mg2,
      toleranceHoriz: toleranceHoriz,
    )) {
      return false;
    }

    // got here, features equals in 2D
    return true;
  }

  /// True if this feature equals with [other] by testing 3D coordinates of the
  /// [geometry] object.
  ///
  /// Returns false if this or [other] contain a null, "empty" or non-3D
  /// geometry object in `geometry`.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Differences on vertical coordinate values (ie. z or elev) between
  /// this and [other] must be within [toleranceVert].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals3D(
    Feature other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    assertTolerance(toleranceVert);

    // test bounding boxes if both have it
    if (bounds != null &&
        other.bounds != null &&
        !bounds!.equals3D(
          other.bounds!,
          toleranceHoriz: toleranceHoriz,
          toleranceVert: toleranceVert,
        )) {
      // both features has bound boxes and boxes do not equal in 3D
      return false;
    }

    // test main geometry
    final mg1 = geometry;
    final mg2 = other.geometry;
    if (mg1 == null || mg2 == null || mg1.isEmpty || mg2.isEmpty) return false;
    if (!mg1.equals3D(
      mg2,
      toleranceHoriz: toleranceHoriz,
      toleranceVert: toleranceVert,
    )) {
      return false;
    }

    // got here, features equals in 3D
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is Feature &&
      id == other.id &&
      properties == other.properties &&
      bounds == other.bounds &&
      geometry == other.geometry &&
      custom == other.custom;

  @override
  int get hashCode => Object.hash(
        id,
        properties,
        bounds,
        geometry,
        custom,
      );
}

/// Returns bounds calculated from a collection of features.
Box? _buildBoundsFrom(Geometry geometry) => BoundsBuilder.calculateBounds(
      item: geometry,
      type: resolveCoordTypeFrom(item: geometry),
      recalculateChilds: false,
    );
