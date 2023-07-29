// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/coordinates/crs/coord_ref_sys.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/coord_arrays.dart';
import '/src/utils/property_builder.dart';
import '/src/vector/content/feature_content.dart';
import '/src/vector/content/property_content.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector_data/model/geometry/geometry.dart';

import 'feature.dart';
import 'feature_builder.dart';
import 'feature_object.dart';

/// A feature collection contains an array of [Feature] items.
///
/// Some implementations may contain also [custom] data or "foreign members"
/// containing property objects.
///
/// According to the [OGC Glossary](https://www.ogc.org/ogc/glossary/f) a
/// feature collection is "a set of related features managed as a group".
///
/// Supports representing data from GeoJSON (https://geojson.org/) features.
@immutable
class FeatureCollection<E extends Feature> extends FeatureObject {
  final List<E> _features;
  final Map<String, dynamic>? _custom;

  /// A feature collection with an array of [features] and optional [bounds].
  const FeatureCollection(List<E> features, {super.bounds})
      : _features = features,
        _custom = null;

  const FeatureCollection._(this._features, this._custom, {super.bounds});

  /// Builds a feature collection from the content provided by [features].
  ///
  /// Feature items on a collection have an optional primary geometry of [T].
  ///
  /// Only [Feature] items of `Feature<T>` provided by [features] are built,
  /// any other objects are ignored.
  ///
  /// An optional expected [count], when given, specifies the number of feature
  /// objects in the content. Note that when given the count MUST be exact.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a feature
  /// collection.
  ///
  /// Use an optional [custom] parameter to set any custom or "foreign member"
  /// properties.
  ///
  /// An example to create a feature collection with feature containing point
  /// geometries, the returned type is `FeatureCollection<Feature<Point>>`:
  ///
  /// ```dart
  ///   FeatureCollection.build<Point>(
  ///       count: 2,
  ///       (features) => features
  ///           ..feature(
  ///               id: '1',
  ///               geometry: (geom) => geom.point([10.123, 20.25]),
  ///               properties: {
  ///                  'foo': 100,
  ///                  'bar': 'this is property value',
  ///                  'baz': true,
  ///               },
  ///           )
  ///           ..feature(
  ///               id: '2',
  ///               // ...
  ///           ),
  ///   );
  /// ```
  static FeatureCollection<Feature<T>> build<T extends Geometry>(
    WriteFeatures features, {
    int? count,
    Iterable<double>? bounds,
    WriteProperties? custom,
  }) {
    // NOTE: use optional count to create a list in right size at build start

    // build any feature items on a list
    final list = FeatureBuilder.buildList<Feature<T>, T>(features);

    // build any custom properties on a map
    final builtCustom =
        custom != null ? PropertyBuilder.buildMap(custom) : null;

    // create a feature collection with features and optional custom props
    return FeatureCollection<Feature<T>>._(
      list,
      builtCustom,
      bounds: buildBoxCoordsOpt(bounds),
    );
  }

  /// Parses a feature collection from [text] conforming to [format].
  ///
  /// Feature items on a collection contain a geometry of [T].
  ///
  /// When [format] is not given, then the feature format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  static FeatureCollection<Feature<T>> parse<T extends Geometry>(
    String text, {
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      FeatureBuilder.parse<FeatureCollection<Feature<T>>, T>(
        text,
        format: format,
        crs: crs,
        options: options,
      );

  /// Decodes a feature collection from [data] conforming to [format].
  ///
  /// Data should be a JSON Object as decoded by the standard `json.decode()`.
  ///
  /// Feature items on a collection contain a geometry of [T].
  ///
  /// When [format] is not given, then the feature format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  static FeatureCollection<Feature<T>> fromData<T extends Geometry>(
    Map<String, dynamic> data, {
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      FeatureBuilder.decodeData<FeatureCollection<Feature<T>>, T>(
        data,
        format: format,
        crs: crs,
        options: options,
      );

  /// All feature items in this feature collection.
  List<E> get features => _features;

  @override
  Map<String, dynamic>? get custom => _custom;

  @override
  FeatureCollection<E> project(Projection projection) => FeatureCollection<E>._(
        _features
            .map<E>((feature) => feature.project(projection) as E)
            .toList(growable: false),
        _custom,
      );

  @override
  void writeTo(FeatureContent writer) {
    final cust = custom;
    writer.featureCollection(
      (feat) {
        for (final item in features) {
          item.writeTo(feat);
        }
      },
      count: features.length,
      bounds: bounds,
      custom: cust != null
          ? (props) {
              cust.forEach((name, value) {
                props.property(name, value);
              });
            }
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FeatureCollection &&
      bounds == other.bounds &&
      features == other.features &&
      custom == other.custom;

  @override
  int get hashCode => Object.hash(bounds, features, custom);
}
