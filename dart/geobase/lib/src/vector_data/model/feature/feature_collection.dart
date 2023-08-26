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
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector_data/array/coordinates_extensions.dart';
import '/src/vector_data/model/geometry/geometry.dart';

import 'feature.dart';
import 'feature_builder.dart';
import 'feature_object.dart';

/// A feature collection contains an array of [Feature] items.
///
/// Feature collection are `bounded` objects with optional [bounds] defining a
/// minimum bounding box for a feature collection.
///
/// Some implementations may contain also [custom] data or "foreign members"
/// containing property objects.
///
/// According to the [OGC Glossary](https://www.ogc.org/ogc/glossary/f) a
/// feature collection is "a set of related features managed as a group".
///
/// Supports representing data from GeoJSON (https://geojson.org/) features.
class FeatureCollection<E extends Feature> extends FeatureObject {
  final List<E> _features;

  /// A feature collection with an array of [features] with optional [bounds]
  /// and [custom] properties.
  const FeatureCollection(List<E> features, {super.bounds, super.custom})
      : _features = features;

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
    Map<String, dynamic>? custom,
  }) {
    // NOTE: use optional count to create a list in right size at build start

    // build any feature items on a list
    final list =
        FeatureBuilder.buildList<Feature<T>, T>(features, count: count);

    // create a feature collection with features and optional custom props
    return FeatureCollection<Feature<T>>(
      list,
      custom: custom,
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

  /// Copy this feature collection with optional [features] and [custom]
  /// properties.
  ///
  /// If [bounds] object is available on this, it's recalculated for a new
  /// feature collection when [features] is given.
  FeatureCollection<E> copyWith({
    List<E>? features,
    Map<String, dynamic>? custom,
  }) =>
      FeatureCollection<E>(
        features ?? this.features,
        custom: custom ?? this.custom,

        // bounds calculated from new features if there was bounds before
        bounds: bounds != null && features != null
            ? _buildBoundsFrom(features)
            : bounds,
      );

  /// Returns a new feature collection with all features mapped using
  /// [toFeature].
  ///
  /// Any custom data or properties (other than geometries) are not mapped
  /// just copied (by references).
  ///
  /// If [bounds] object is available on this, it's recalculated after
  /// mapping features. If [bounds] is null, then it's null after mapping too.
  FeatureCollection<E> map(E Function(E feature) toFeature) {
    final mapped = features.map<E>(toFeature).toList(growable: false);

    return FeatureCollection<E>(
      mapped,
      custom: custom,
      bounds: bounds != null ? _buildBoundsFrom(mapped) : null,
    );
  }

  @override
  Coords resolveCoordType() => resolveCoordTypeFrom(collection: features);

  @override
  Box? calculateBounds() => BoundsBuilder.calculateBounds(
        collection: features,
        type: resolveCoordType(),
        recalculateChilds: true,
      );

  @override
  FeatureCollection<E> bounded({bool recalculate = false}) {
    if (features.isEmpty) return this;

    // ensure all features contained are processed first
    final collection = features
        .map<E>(
          (feature) => feature.bounded(recalculate: recalculate) as E,
        )
        .toList(growable: false);

    // return a new collection with processed features and populated bounds
    return FeatureCollection<E>(
      collection,
      custom: custom,
      bounds:
          recalculate || bounds == null ? _buildBoundsFrom(collection) : bounds,
    );
  }

  @override
  FeatureCollection<E> project(Projection projection) {
    final projected = features
        .map<E>((feature) => feature.project(projection) as E)
        .toList(growable: false);

    return FeatureCollection<E>(
      projected,
      custom: custom,
      bounds: bounds != null ? _buildBoundsFrom(projected) : null,
    );
  }

  @override
  void writeTo(FeatureContent writer) {
    writer.featureCollection(
      (feat) {
        for (final item in features) {
          item.writeTo(feat);
        }
      },
      count: features.length,
      bounds: bounds?.coords,
      custom: custom,
    );
  }

  /// Returns true if this and [other] contain exactly same coordinate values
  /// (or both are empty) in the same order and with the same coordinate type.
  bool equalsCoords(FeatureCollection other) {
    if (identical(this, other)) return true;

    if (bounds != null && other.bounds != null && !(bounds! == other.bounds!)) {
      // both feature collections has bound boxes and boxes do not equal
      return false;
    }

    final fc1 = features;
    final fc2 = other.features;
    if (fc1.length != fc2.length) return false;
    for (var i = 0; i < fc1.length; i++) {
      if (!fc1[i].equalsCoords(fc2[i])) {
        return false;
      }
    }
    return true;
  }

  /// True if this feature collection equals with [other] by testing 2D
  /// coordinates of geometries of [features] (that must be in same order in
  /// both collections) contained.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals2D(
    FeatureCollection other, {
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
      // both feature collections has bound boxes and boxes do not equal in 2D
      return false;
    }

    // test features contained
    final fc1 = features;
    final fc2 = other.features;
    if (fc1.length != fc2.length) return false;
    for (var i = 0; i < fc1.length; i++) {
      if (!fc1[i].equals2D(
        fc2[i],
        toleranceHoriz: toleranceHoriz,
      )) {
        return false;
      }
    }

    // got here, features equals in 2D
    return true;
  }

  /// True if this feature collection equals with [other] by testing 3D
  /// coordinates of geometries of [features] (that must be in same order in
  /// both collections) contained.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Differences on vertical coordinate values (ie. z or elev) between
  /// this and [other] must be within [toleranceVert].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals3D(
    FeatureCollection other, {
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
      // both feature collections has bound boxes and boxes do not equal in 3D
      return false;
    }

    // test features contained
    final fc1 = features;
    final fc2 = other.features;
    if (fc1.length != fc2.length) return false;
    for (var i = 0; i < fc1.length; i++) {
      if (!fc1[i].equals3D(
        fc2[i],
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      )) {
        return false;
      }
    }

    // got here, features equals in 3D
    return true;
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

/// Returns bounds calculated from a collection of features.
Box? _buildBoundsFrom(Iterable<Feature> features) =>
    BoundsBuilder.calculateBounds(
      collection: features,
      type: resolveCoordTypeFrom(collection: features),
      recalculateChilds: false,
    );
