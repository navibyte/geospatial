// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/crs/coord_ref_sys.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/bounds_builder.dart';
import '/src/utils/coord_arrays.dart';
import '/src/utils/coord_type.dart';
import '/src/utils/property_builder.dart';
import '/src/utils/tolerance.dart';
import '/src/vector/content/feature_content.dart';
import '/src/vector/content/geometry_content.dart';
import '/src/vector/content/property_content.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector_data/array/coordinates.dart';
import '/src/vector_data/model/geometry/geometry.dart';
import '/src/vector_data/model/geometry/geometry_builder.dart';

import 'feature_builder.dart';
import 'feature_object.dart';

/// A feature is a geospatial entity with [id], [properties] and [geometry].
///
/// Some implementations may also contain "foreign members", like [custom] data
/// containing property objects and [customGeometries] containing geometry
/// objects.
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

  /// A feature of optional [id], [geometry] and [properties] and optional
  /// [bounds].
  ///
  /// An optional [id], when given, should be either a string or an integer
  /// number.
  ///
  /// An optional [geometry] of [T], when given, is the primary geometry of the
  /// feature.
  ///
  /// An optional [properties] defines feature properties as a map with data
  /// similar to a JSON Object.
  const Feature({
    Object? id,
    T? geometry,
    Map<String, dynamic>? properties,
    super.bounds,
  })  : _id = id,
        _properties = properties ?? const {},
        _geometry = geometry;

  /// Builds a feature from optional [id], [geometry], [properties], [bounds]
  /// and [custom].
  ///
  /// An optional [id], when given, should be either a string or an integer
  /// number.
  ///
  /// An optional [geometry] is a callback function providing the content of
  /// geometry objects. The geometry of [T] named "geometry" or the first
  /// geometry of [T] without name is stored as the primary geometry. Any other
  /// geometries are stored as "foreign members" in `customGeometries`.
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
    WriteProperties? custom,
  }) {
    // optional data to be built as necessary
    T? primaryGeometry;
    Map<String, dynamic>? builtCustom;
    Map<String, Geometry>? builtCustomGeom;

    // use geometry builder to build any geometry (primary + foreign) objects
    if (geometry != null) {
      var index = 0;
      GeometryBuilder.build(
        geometry,
        to: (Geometry geometry, {String? name}) {
          if (name == 'geometry' && geometry is T) {
            // there was already one geometry as "primary", move it to custom
            if (primaryGeometry != null) {
              (builtCustomGeom ??= {})['#geometry$index'] = primaryGeometry!;
              index++;
            }

            // use the geometry of T named 'geometry' as the primary geometry
            primaryGeometry = geometry;
          } else if (name == null && primaryGeometry == null && geometry is T) {
            // OR the first geometry of T without name as the primary geometry
            primaryGeometry = geometry;
          } else {
            // a geometry with name, add to the custom map
            (builtCustomGeom ??= {})[name ?? '#geometry$index'] = geometry;
            index++;
          }
        },
      );
    }

    // use property builder to build any foreign property objects
    if (custom != null) {
      builtCustom ??= {};
      PropertyBuilder.buildTo(custom, to: builtCustom);
    }

    // create a custom feature with "foreign members" OR a standard feature
    return builtCustom != null || builtCustomGeom != null
        ? _CustomFeature(
            id: id,
            geometry: primaryGeometry,
            properties: properties,
            bounds: buildBoxCoordsOpt(bounds),
            custom: builtCustom,
            customGeometries: builtCustomGeom,
          )
        : Feature(
            id: id,
            geometry: primaryGeometry,
            properties: properties,
            bounds: buildBoxCoordsOpt(bounds),
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

  /// Optional custom or "foreign member" geometries as a map.
  ///
  /// The primary geometry is via [geometry]. However any custom geometry data
  /// outside the primary geometry is stored in this member.
  ///
  /// See also [custom] for non-geometry custom or "foreign member" properties.
  Map<String, Geometry>? get customGeometries => null;

  @override
  Coords resolveCoordType() => resolveCoordTypeFrom(
        item: geometry, // the main geometry of Feature
        collection: customGeometries?.values, // other geoms of CustomFeature
      );

  @override
  BoxCoords? calculateBounds() => BoundsBuilder.calculateBounds(
        item: geometry, // the main geometry of Feature
        collection: customGeometries?.values, // other geoms of CustomFeature
        type: resolveCoordType(),
        calculateChilds: true,
      );

  @override
  Feature<T> bounded({bool recalculate = false}) {
    final currGeom = _geometry;
    if (currGeom == null || currGeom.isEmpty) return this;

    // ensure geometry is processed first
    final geom = currGeom.bounded(recalculate: recalculate) as T;

    // return a new feature with processed geometry and populated bounds
    return Feature<T>(
      id: _id,
      geometry: geom,
      properties: _properties,
      bounds: recalculate || bounds == null
          ? BoundsBuilder.calculateBounds(
              item: geom,
              type: resolveCoordTypeFrom(item: geom),
              calculateChilds: false,
            )
          : bounds,
    );
  }

  @override
  Feature<T> project(Projection projection) => Feature<T>(
        id: _id,
        geometry: _geometry?.project(projection) as T?,
        properties: _properties,
      );

  @override
  void writeTo(FeatureContent writer) {
    final geom = _geometry;
    writer.feature(
      id: _id,
      geometry: geom?.writeTo,
      properties: _properties,
      bounds: bounds,
    );
  }

  /// True if this feature equals with [other] by testing 2D coordinates of the
  /// [geometry] object (and any [customGeometries] possibly contained).
  ///
  /// If [ignoreCustomGeometries] is true, then [customGeometries] are ignored
  /// in testing.
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
    bool ignoreCustomGeometries = false,
  }) {
    assertTolerance(toleranceHoriz);

    // test bounding boxes if both have it
    if (bounds != null &&
        other.bounds != null &&
        !bounds!.equals2D(
          other.bounds!,
          toleranceHoriz: toleranceHoriz,
        )) {
      // both geometries has bound boxes and boxes do not equal in 2D
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

    // test custom geometries unless they should be ignored
    if (!ignoreCustomGeometries) {
      final cg1 = customGeometries;
      final cg2 = other.customGeometries;
      if (cg1 != null) {
        if (cg2 == null || cg1.length != cg2.length) return false;
        for (final cg1entry in cg1.entries) {
          final cg2value = cg2[cg1entry.key];
          if (cg2value == null) return false;
          if (!cg1entry.value.equals2D(
            cg2value,
            toleranceHoriz: toleranceHoriz,
          )) {
            return false;
          }
        }
      } else {
        if (cg2 != null) return false;
      }
    }

    // got here, features equals in 2D
    return true;
  }

  /// True if this feature equals with [other] by testing 3D coordinates of the
  /// [geometry] object (and any [customGeometries] possibly contained).
  ///
  /// If [ignoreCustomGeometries] is true, then [customGeometries] are ignored
  /// in testing.
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
    bool ignoreCustomGeometries = false,
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
      // both geometries has bound boxes and boxes do not equal in 3D
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

    // test custom geometries unless they should be ignored
    if (!ignoreCustomGeometries) {
      final cg1 = customGeometries;
      final cg2 = other.customGeometries;
      if (cg1 != null) {
        if (cg2 == null || cg1.length != cg2.length) return false;
        for (final cg1entry in cg1.entries) {
          final cg2value = cg2[cg1entry.key];
          if (cg2value == null) return false;
          if (!cg1entry.value.equals3D(
            cg2value,
            toleranceHoriz: toleranceHoriz,
            toleranceVert: toleranceVert,
          )) {
            return false;
          }
        }
      } else {
        if (cg2 != null) return false;
      }
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
      custom == other.custom &&
      customGeometries == other.customGeometries;

  @override
  int get hashCode => Object.hash(
        id,
        properties,
        bounds,
        geometry,
        custom,
        customGeometries,
      );
}

class _CustomFeature<T extends Geometry> extends Feature<T> {
  final Map<String, dynamic>? _custom;
  final Map<String, Geometry>? _customGeometries;

  /// A feature of optional [id], [geometry], [properties], [bounds], [custom]
  /// and [customGeometries].
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
  /// Use an optional [custom] parameter to set any "foreign member" properties
  /// as a map.
  ///
  /// Use an optional [customGeometries] parameter to set any "foreign member"
  /// geometries as a map.
  const _CustomFeature({
    super.id,
    super.geometry,
    super.properties,
    super.bounds,
    Map<String, dynamic>? custom,
    Map<String, Geometry>? customGeometries,
  })  : _custom = custom,
        _customGeometries = customGeometries;

  @override
  Map<String, dynamic>? get custom => _custom;

  @override
  Map<String, Geometry>? get customGeometries => _customGeometries;

  @override
  Feature<T> bounded({bool recalculate = false}) {
    final currGeom = _geometry;
    final currCustGeoms = _customGeometries;
    if ((currGeom == null || currGeom.isEmpty) &&
        (currCustGeoms == null || currCustGeoms.isEmpty)) return this;

    // ensure main geometry is processed first
    final geom = currGeom?.bounded(recalculate: recalculate) as T?;

    // ensure also custom geometries are processed
    final custGeom = currCustGeoms?.map<String, Geometry>(
      (key, value) =>
          MapEntry(key, value.bounded(recalculate: recalculate) as Geometry),
    );

    // return a new feature with processed geometries and populated bounds
    return _CustomFeature<T>(
      id: _id,
      geometry: geom,
      properties: _properties,
      custom: _custom,
      customGeometries: custGeom,
      bounds: recalculate || bounds == null
          ? BoundsBuilder.calculateBounds(
              item: geom,
              collection: custGeom?.values,
              type: resolveCoordTypeFrom(
                item: geom,
                collection: custGeom?.values,
              ),
              calculateChilds: false,
            )
          : bounds,
    );
  }

  @override
  Feature<T> project(Projection projection) => _CustomFeature<T>(
        id: _id,
        geometry: _geometry?.project(projection) as T?,
        properties: _properties,
        custom: _custom,
        customGeometries: _customGeometries?.map<String, Geometry>(
          (key, geom) => MapEntry(key, geom.project(projection)),
        ),
      );

  @override
  void writeTo(FeatureContent writer) {
    final geom = _geometry;
    final custGeom = customGeometries;
    final cust = custom;
    writer.feature(
      id: _id,
      geometry: geom != null || custGeom != null
          ? (output) {
              if (geom != null) {
                geom.writeTo(output);
              }
              if (custGeom != null) {
                custGeom.forEach((name, value) {
                  value.writeTo(output, name: name);
                });
              }
            }
          : null,
      properties: _properties,
      custom: cust != null
          ? (props) {
              cust.forEach((name, value) {
                props.property(name, value);
              });
            }
          : null,
    );
  }
}
