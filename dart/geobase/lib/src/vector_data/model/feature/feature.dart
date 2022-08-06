// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/utils/property_builder.dart';
import '/src/vector/content.dart';
import '/src/vector_data/model/bounded.dart';
import '/src/vector_data/model/geometry.dart';

/// A feature is a geospatial entity with [id], [properties] and [geometry].
///
/// Some implementations may contain also [custom] data or "foreign members"
/// containing property and geometry objects.
///
/// Feature objects have an optional primary [geometry] of [T].
///
/// Supports representing data from GeoJSON (https://geojson.org/) features.
class Feature<T extends Geometry> extends Bounded {
  final Object? _id;
  final T? _geometry;
  final Map<String, Object?> _properties;

  /// A feature of optional [id], [geometry] and [properties].
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
    Map<String, Object?>? properties,
  })  : _id = id,
        _properties = properties ?? const {},
        _geometry = geometry;

  /// A feature from optional [id], [geometry], [properties] and [custom] data.
  ///
  /// An optional [id], when given, should be either a string or an integer
  /// number.
  ///
  /// An optional [geometry] is a callback function providing the content of
  /// geometry objects. The geometry of [T] named "geometry" or the first
  /// geometry of [T] without name is stored as the primary geometry. Any other
  /// geometries are stored as custom or "foreign members".
  ///
  /// An optional [properties] defines feature properties as a map with data
  /// similar to a JSON Object.
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
    Map<String, Object?>? properties,
    WriteProperties? custom,
  }) {
    // optional data to be built as necessary
    T? primaryGeometry;
    Map<String, Object?>? builtCustom;

    // use geometry builder to build any geometry (primary + foreign) objects
    if (geometry != null) {
      var index = 0;
      GeometryBuilder.build(
        geometry,
        to: (Geometry geometry, {String? name}) {
          if (name == 'geometry' && geometry is T) {
            // there was already one geometry as "primary", move it to custom
            if (primaryGeometry != null) {
              (builtCustom ??= {})['#geometry$index'] = primaryGeometry;
              index++;
            }

            // use the geometry of T named 'geometry' as the primary geometry
            primaryGeometry = geometry;
          } else if (name == null && primaryGeometry == null && geometry is T) {
            // OR the first geometry of T without name as the primary geometry
            primaryGeometry = geometry;
          } else {
            // a geometry with name, add to the custom map
            (builtCustom ??= {})[name ?? '#geometry$index'] = geometry;
            index++;
          }
        },
      );
    }

    // use property builder to build any foreign property objects
    if (custom != null) {
      builtCustom ??= {};
      PropertyBuilder.buildTo(custom, to: builtCustom!);
    }

    // create a custom feature with "foreign members" OR a standard feature
    return builtCustom != null
        ? _CustomFeature(
            id: id,
            geometry: primaryGeometry,
            properties: properties,
            custom: builtCustom!,
          )
        : Feature(
            id: id,
            geometry: primaryGeometry,
            properties: properties,
          );
  }

  /// An optional identifier (a string or number) for this feature.
  Object? get id => _id;

  /// An optional primary geometry of [T] for this feature.
  T? get geometry => _geometry;

  /// Required properties for this feature (allowed to be empty).
  Map<String, Object?> get properties => _properties;

  /// Optional custom or "foreign member" properties and geometries as a map.
  ///
  /// The primary geometry and properties data (like `geometry` and `properties`
  /// objects in GeoJSON features) are accessed via [geometry] and [properties].
  /// However any custom property and geometry data outside those members is
  /// stored in this member.
  Map<String, Object?>? get custom => null;

  // todo: ==, hashCode, toString
}

class _CustomFeature<T extends Geometry> extends Feature<T> {
  final Map<String, Object?> _custom;

  /// A feature of optional [id], [geometry], [properties] and [custom] data.
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
  /// and geometries as a map.
  const _CustomFeature({
    super.id,
    super.geometry,
    super.properties,
    required Map<String, Object?> custom,
  }) : _custom = custom;

  @override
  Map<String, Object?> get custom => _custom;
}
