// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/coordinates/projection/projection.dart';
import '/src/utils/coord_arrays.dart';
import '/src/utils/property_builder.dart';
import '/src/vector/content/feature_content.dart';
import '/src/vector/content/geometry_content.dart';
import '/src/vector/content/property_content.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
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
@immutable
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
  /// Format or decoder implementation specific options can be set by [options].
  static Feature<T> parse<T extends Geometry>(
    String text, {
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
    Map<String, dynamic>? options,
  }) =>
      FeatureBuilder.parse<Feature<T>, T>(
        text,
        format: format,
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
  /// Format or decoder implementation specific options can be set by [options].
  static Feature<T> fromData<T extends Geometry>(
    Map<String, dynamic> data, {
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
    Map<String, dynamic>? options,
  }) =>
      FeatureBuilder.decodeData<Feature<T>, T>(
        data,
        format: format,
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
