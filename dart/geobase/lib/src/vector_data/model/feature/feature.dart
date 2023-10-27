// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/codes/coords.dart';
import '/src/common/constants/epsilon.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_scheme.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/reference/coord_ref_sys.dart';
import '/src/utils/bounded_utils.dart';
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a feature with an id and a point geometry (2D coordinates)
  /// Feature(
  ///   id: '1',
  ///   geometry: Point([10.0, 20.0].xy),
  /// );
  ///
  /// // a feature with properties and a line string geometry (3D coordinates)
  /// Feature(
  ///   geometry: LineString(
  ///     // three (x, y, z) positions
  ///     [10.0, 20.0, 30.0, 12.5, 22.5, 32.5, 15.0, 25.0, 35.0]
  ///         .positions(Coords.xyz),
  ///   ),
  ///   // properties for a feature containing JSON Object like data
  ///   properties: {
  ///     'textProp': 'this is property value',
  ///     'intProp': 10,
  ///     'doubleProp': 29.5,
  ///     'arrayProp': ['foo', 'bar'],
  ///   },
  /// );
  /// ```
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
  /// Examples:
  ///
  /// ```dart
  /// // a feature with an id and a point geometry (2D coordinates)
  /// Feature.build(
  ///   id: '1',
  ///   geometry: (geom) => geom.point([10.0, 20.0].xy),
  /// );
  ///
  /// // a feature with properties and a line string geometry (3D coordinates)
  /// Feature.build(
  ///   geometry: (geom) => geom.lineString(
  ///     // three (x, y, z) positions
  ///     [10.0, 20.0, 30.0, 12.5, 22.5, 32.5, 15.0, 25.0, 35.0]
  ///         .positions(Coords.xyz),
  ///   ),
  ///   // properties for a feature containing JSON Object like data
  ///   properties: {
  ///     'textProp': 'this is property value',
  ///     'intProp': 10,
  ///     'doubleProp': 29.5,
  ///     'arrayProp': ['foo', 'bar'],
  ///   },
  /// );
  /// ```
  factory Feature.build({
    Object? id,
    WriteGeometries? geometry,
    Map<String, dynamic>? properties,
    Box? bounds,
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
      bounds: bounds,
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a feature with an id and a point geometry (2D coordinates)
  /// Feature.parse(
  ///   format: GeoJSON.feature,
  ///   '''
  ///   {
  ///     "type": "Feature",
  ///     "id": "1",
  ///     "geometry": {
  ///       "type": "Point",
  ///       "coordinates": [10.0, 20.0]
  ///     }
  ///   }
  ///   ''',
  /// );
  ///
  /// // a feature with properties and a line string geometry (3D coordinates)
  /// Feature.parse(
  ///   format: GeoJSON.feature,
  ///   '''
  ///   {
  ///     "type": "Feature",
  ///     "geometry": {
  ///       "type": "LineString",
  ///       "coordinates": [
  ///         [10.0, 20.0, 30.0],
  ///         [12.5, 22.5, 32.5],
  ///         [15.0, 25.0, 35.0]
  ///       ]
  ///     },
  ///     "properties": {
  ///       "textProp": "this is property value",
  ///       "intProp": 10,
  ///       "doubleProp": 29.5,
  ///       "arrayProp": ["foo", "bar"]
  ///     }
  ///   }
  ///   ''',
  /// );
  /// ```
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a feature with an id and a point geometry (2D coordinates)
  /// Feature.fromData(
  ///   format: GeoJSON.feature,
  ///   {
  ///     'type': 'Feature',
  ///     'id': '1',
  ///     'geometry': {
  ///       'type': 'Point',
  ///       'coordinates': [10.0, 20.0]
  ///     }
  ///   },
  /// );
  ///
  /// // a feature with properties and a line string geometry (3D coordinates)
  /// Feature.fromData(
  ///   format: GeoJSON.feature,
  ///   {
  ///     'type': 'Feature',
  ///     'geometry': {
  ///       'type': 'LineString',
  ///       'coordinates': [
  ///         [10.0, 20.0, 30.0],
  ///         [12.5, 22.5, 32.5],
  ///         [15.0, 25.0, 35.0]
  ///       ]
  ///     },
  ///     'properties': {
  ///       'textProp': 'this is property value',
  ///       'intProp': 10,
  ///       'doubleProp': 29.5,
  ///       'arrayProp': ['foo', 'bar']
  ///     }
  ///   },
  /// );
  /// ```
  static Feature<T> fromData<T extends Geometry>(
    Map<String, dynamic> data, {
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      FeatureBuilder.fromData<Feature<T>, T>(
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

  /// Returns true if this feature do not contain any geometry or geometry is
  /// empty.
  ///
  /// Note that if geometry is null but the feature contains properties, this is
  /// still considered empty according to specification from [Bounded]:
  /// "Returns true if this bounded object is considered empty (that is it do
  /// not contain any geometry directly or on child objects, or geometry
  /// contained is empty)".
  @override
  bool get isEmptyByGeometry => geometry == null || geometry!.isEmptyByGeometry;

  @override
  Coords get coordType => geometry?.coordType ?? Coords.xy;

  /// Copy this feature with optional [id], [geometry], [properties] and
  /// [custom] properties.
  ///
  /// When a new [geometry] is given, then the returned collection has bounds
  /// set to null.
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

        // bounds set to null if new geometry set
        bounds: geometry != null ? null : bounds,
      );

  @override
  Box? calculateBounds({PositionScheme scheme = Position.scheme}) =>
      geometry?.calculateBounds(scheme: scheme);

  @override
  Feature populated({
    int traverse = 0,
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  }) {
    if (onBounds) {
      // populate a geometry when traversing is asked
      final geom = traverse > 0
          ? geometry?.populated(
              traverse: traverse - 1,
              onBounds: onBounds,
              scheme: scheme,
            )
          : geometry;

      // create a new feature if geometry changed or bounds was unpopulated
      // or of other scheme
      final b = bounds;
      if (geom != geometry ||
          (b == null && geom != null) ||
          (b != null && !b.conforming.conformsWith(scheme))) {
        return Feature(
          id: id,
          geometry: geom,
          properties: properties,
          bounds: geom?.getBounds(scheme: scheme),
          custom: custom,
        );
      }
    }
    return this;
  }

  @override
  Feature unpopulated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // unpopulate a geometry when traversing is asked
      final geom = traverse > 0
          ? geometry?.unpopulated(traverse: traverse - 1, onBounds: onBounds)
          : geometry;

      // create a new feature if geometry changed or bounds was populated
      if (geom != geometry || bounds != null) {
        return Feature(
          id: id,
          geometry: geom,
          properties: properties,
          custom: custom,
        );
      }
    }
    return this;
  }

  @override
  Feature<T> project(Projection projection) {
    final projectedGeom = geometry?.project(projection) as T?;

    return Feature<T>(
      id: id,
      geometry: projectedGeom,
      properties: properties,
      custom: custom,
    );
  }

  @override
  void writeTo(FeatureContent writer) {
    final geom = geometry;
    writer.feature(
      id: id,
      geometry: geom?.writeTo,
      properties: properties,
      bounds: bounds,
      custom: custom,
    );
  }

  @override
  bool equalsCoords(FeatureObject other) => testEqualsCoords<Feature<T>>(
        this,
        other,
        (feature1, feature2) => _testFeatures<T>(
          feature1,
          feature2,
          (geometry1, geometry2) => geometry1.equalsCoords(geometry2),
        ),
      );

  @override
  bool equals2D(
    FeatureObject other, {
    double toleranceHoriz = defaultEpsilon,
  }) =>
      testEquals2D<Feature<T>>(
        this,
        other,
        (feature1, feature2) => _testFeatures<T>(
          feature1,
          feature2,
          (geometry1, geometry2) => geometry1.equals2D(
            geometry2,
            toleranceHoriz: toleranceHoriz,
          ),
        ),
        toleranceHoriz: toleranceHoriz,
      );

  @override
  bool equals3D(
    FeatureObject other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) =>
      testEquals3D<Feature<T>>(
        this,
        other,
        (feature1, feature2) => _testFeatures<T>(
          feature1,
          feature2,
          (geometry1, geometry2) => geometry1.equals3D(
            geometry2,
            toleranceHoriz: toleranceHoriz,
            toleranceVert: toleranceVert,
          ),
        ),
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

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

bool _testFeatures<T extends Geometry>(
  Feature<T> feature1,
  Feature<T> feature2,
  bool Function(T, T) testGeometries,
) {
  // test geometries contained
  final geom1 = feature1.geometry;
  final geom2 = feature2.geometry;

  if (geom1 != null) {
    if (geom2 == null) return false;
    if (!testGeometries(geom1, geom2)) return false;
  } else {
    if (geom2 != null) return false;
  }
  return true;
}
