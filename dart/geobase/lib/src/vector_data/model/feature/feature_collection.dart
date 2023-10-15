// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_extensions.dart';
import '/src/coordinates/base/position_scheme.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/reference/coord_ref_sys.dart';
import '/src/utils/bounded_utils.dart';
import '/src/utils/coord_type.dart';
import '/src/vector/content/feature_content.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
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
  final Coords _coordType;

  /// A feature collection with an array of [features] with optional [bounds]
  /// and [custom] properties.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a feature collection with two features
  /// FeatureCollection([
  ///   // a feature with an id and a point geometry (2D coordinates)
  ///   Feature<Point>(
  ///     id: '1',
  ///     geometry: Point([10.0, 20.0].xy),
  ///   ),
  ///
  ///   // a feature with properties and a line string geometry (3D coordinates)
  ///   Feature<LineString>(
  ///     geometry: LineString(
  ///       // three (x, y, z) positions
  ///       [10.0, 20.0, 30.0, 12.5, 22.5, 32.5, 15.0, 25.0, 35.0]
  ///           .positions(Coords.xyz),
  ///     ),
  ///     // properties for a feature containing JSON Object like data
  ///     properties: {
  ///       'textProp': 'this is property value',
  ///       'intProp': 10,
  ///       'doubleProp': 29.5,
  ///       'arrayProp': ['foo', 'bar'],
  ///     },
  ///   ),
  /// ]);
  /// ```
  FeatureCollection(List<E> features, {super.bounds, super.custom})
      : _features = features,
        _coordType = resolveCoordTypeFrom(collection: features);

  const FeatureCollection._(
    this._features,
    this._coordType, {
    super.bounds,
    super.custom,
  });

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
  /// Examples:
  ///
  /// ```dart
  /// // a feature collection with two features
  /// FeatureCollection.build(
  ///   count: 2,
  ///   (feat) => feat
  ///     // a feature with an id and a point geometry (2D coordinates)
  ///     ..feature(
  ///       id: '1',
  ///       geometry: (geom) => geom.point([10.0, 20.0].xy),
  ///     )
  ///
  ///     // a feature with properties and a line string geometry (3D)
  ///     ..feature(
  ///       geometry: (geom) => geom.lineString(
  ///         // three (x, y, z) positions
  ///         [10.0, 20.0, 30.0, 12.5, 22.5, 32.5, 15.0, 25.0, 35.0]
  ///             .positions(Coords.xyz),
  ///       ),
  ///       // properties for a feature containing JSON Object like data
  ///       properties: {
  ///         'textProp': 'this is property value',
  ///         'intProp': 10,
  ///         'doubleProp': 29.5,
  ///         'arrayProp': ['foo', 'bar'],
  ///       },
  ///     ),
  /// );
  /// ```
  static FeatureCollection<Feature<T>> build<T extends Geometry>(
    WriteFeatures features, {
    int? count,
    Box? bounds,
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
      bounds: bounds,
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a feature collection with two features
  /// FeatureCollection.parse(
  ///   format: GeoJSON.feature,
  ///   '''
  ///   {
  ///     "type": "FeatureCollection",
  ///     "features": [
  ///       {
  ///         "type": "Feature",
  ///         "id": "1",
  ///         "geometry": {
  ///           "type": "Point",
  ///           "coordinates": [10.0, 20.0]
  ///         }
  ///       },
  ///       {
  ///         "type": "Feature",
  ///         "geometry": {
  ///           "type": "LineString",
  ///           "coordinates": [
  ///             [10.0, 20.0, 30.0],
  ///             [12.5, 22.5, 32.5],
  ///             [15.0, 25.0, 35.0]
  ///           ]
  ///         },
  ///         "properties": {
  ///           "textProp": "this is property value",
  ///           "intProp": 10,
  ///           "doubleProp": 29.5,
  ///           "arrayProp": ["foo", "bar"]
  ///         }
  ///       }
  ///     ]
  ///   }
  ///   ''',
  /// );
  /// ```
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a feature collection with two features
  /// FeatureCollection.fromData(
  ///   format: GeoJSON.feature,
  ///   {
  ///     'type': 'FeatureCollection',
  ///     'features': [
  ///       // a feature with an id and a point geometry (2D coordinates)
  ///       {
  ///         'type': 'Feature',
  ///         'id': '1',
  ///         'geometry': {
  ///           'type': 'Point',
  ///           'coordinates': [10.0, 20.0]
  ///         }
  ///       },
  ///       // a feature with properties and a line string geometry (3D)
  ///       {
  ///         'type': 'Feature',
  ///         'geometry': {
  ///           'type': 'LineString',
  ///           'coordinates': [
  ///             [10.0, 20.0, 30.0],
  ///             [12.5, 22.5, 32.5],
  ///             [15.0, 25.0, 35.0]
  ///           ]
  ///         },
  ///         'properties': {
  ///           'textProp': 'this is property value',
  ///           'intProp': 10,
  ///           'doubleProp': 29.5,
  ///           'arrayProp': ['foo', 'bar']
  ///         }
  ///       }
  ///     ]
  ///   },
  /// );
  /// ```
  static FeatureCollection<Feature<T>> fromData<T extends Geometry>(
    Map<String, dynamic> data, {
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      FeatureBuilder.fromData<FeatureCollection<Feature<T>>, T>(
        data,
        format: format,
        crs: crs,
        options: options,
      );

  /// All feature items in this feature collection.
  List<E> get features => _features;

  /// Returns true if this feature collection do not contain any features.
  ///
  /// The specification from [Bounded]:
  /// "Returns true if this object is considered empty (that is it do not
  /// contain any position data directly or on child objects, or a position data
  /// object contained is empty)".
  @override
  bool get isEmptyByGeometry => features.isEmpty;

  @override
  Coords get coordType => _coordType;

  /// Copy this feature collection with optional [features] and [custom]
  /// properties.
  ///
  /// When a new list of [features] is given, then the returned collection has
  /// bounds set to null.
  FeatureCollection<E> copyWith({
    List<E>? features,
    Map<String, dynamic>? custom,
  }) {
    if (features != null) {
      final type = resolveCoordTypeFrom(collection: features);
      return FeatureCollection<E>._(
        features,
        type,
        custom: custom ?? this.custom,
      );
    } else if (custom != null) {
      return FeatureCollection<E>._(
        this.features,
        this.coordType,
        custom: custom,
        bounds: bounds,
      );
    } else {
      // ignore: avoid_returning_this
      return this;
    }
  }

  /// Returns a new feature collection with all features mapped using
  /// [toFeature].
  ///
  /// Any custom data or properties (other than geometries) are not mapped
  /// just copied (by references).
  ///
  /// If [bounds] object is available on this, then it's not recalculated and
  /// the returned object has it set null.
  FeatureCollection<E> map(E Function(E feature) toFeature) {
    final mapped = features.map<E>(toFeature).toList(growable: false);
    final type = resolveCoordTypeFrom(collection: mapped);

    return FeatureCollection<E>._(mapped, type, custom: custom);
  }

  @override
  Box? calculateBounds({PositionScheme scheme = Position.scheme}) => features
      .map((f) => f.calculateBounds(scheme: scheme))
      .merge()
      ?.copyByType(coordType);

  @override
  FeatureCollection populated({
    int traverse = 0,
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  }) {
    if (onBounds) {
      // populate features when traversing is asked
      final coll = traverse > 0 && features.isNotEmpty
          ? features
              .map<E>(
                (f) => f.populated(
                  traverse: traverse - 1,
                  onBounds: onBounds,
                  scheme: scheme,
                ) as E,
              )
              .toList(growable: false)
          : features;

      // create a new collection if features changed or bounds was unpopulated
      // or of other scheme
      final b = bounds;
      final empty = coll.isEmpty;
      if (coll != features ||
          (b == null && !empty) ||
          (b != null && !b.conformsScheme(scheme))) {
        return FeatureCollection<E>._(
          coll,
          coordType,
          bounds: empty
              ? null
              : coll
                  .map((f) => f.calculateBounds(scheme: scheme))
                  .merge()
                  ?.copyByType(coordType),
          custom: custom,
        );
      }
    }
    return this;
  }

  @override
  FeatureCollection unpopulated({
    int traverse = 0,
    bool onBounds = true,
  }) {
    if (onBounds) {
      // unpopulate features when traversing is asked
      final coll = traverse > 0 && features.isNotEmpty
          ? features
              .map<E>(
                (f) => f.unpopulated(traverse: traverse - 1, onBounds: onBounds)
                    as E,
              )
              .toList(growable: false)
          : features;

      // create a new collection if features changed or bounds was populated
      if (coll != features || bounds != null) {
        return FeatureCollection<E>._(
          coll,
          coordType,
          custom: custom,
        );
      }
    }
    return this;
  }

  @override
  FeatureCollection<E> project(Projection projection) {
    final projected = features
        .map<E>((feature) => feature.project(projection) as E)
        .toList(growable: false);

    return FeatureCollection<E>._(projected, coordType, custom: custom);
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
      bounds: bounds,
      custom: custom,
    );
  }

  @override
  bool equalsCoords(FeatureObject other) =>
      testEqualsCoords<FeatureCollection<E>>(
        this,
        other,
        (collection1, collection2) => _testFeatureCollections<E>(
          collection1,
          collection2,
          (feature1, feature2) => feature1.equalsCoords(feature2),
        ),
      );

  @override
  bool equals2D(
    FeatureObject other, {
    double toleranceHoriz = defaultEpsilon,
  }) =>
      testEquals2D<FeatureCollection<E>>(
        this,
        other,
        (collection1, collection2) => _testFeatureCollections<E>(
          collection1,
          collection2,
          (feature1, feature2) => feature1.equals2D(
            feature2,
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
      testEquals3D<FeatureCollection<E>>(
        this,
        other,
        (collection1, collection2) => _testFeatureCollections<E>(
          collection1,
          collection2,
          (feature1, feature2) => feature1.equals3D(
            feature2,
            toleranceHoriz: toleranceHoriz,
            toleranceVert: toleranceVert,
          ),
        ),
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  @override
  bool operator ==(Object other) =>
      other is FeatureCollection &&
      bounds == other.bounds &&
      features == other.features &&
      custom == other.custom;

  @override
  int get hashCode => Object.hash(bounds, features, custom);
}

bool _testFeatureCollections<E extends Feature>(
  FeatureCollection<E> collection1,
  FeatureCollection<E> collection2,
  bool Function(E, E) testFeatures,
) {
  // test features contained
  final features1 = collection1.features;
  final features2 = collection2.features;
  if (features1.length != features2.length) return false;
  for (var i = 0; i < features1.length; i++) {
    // use given function to test features by index from both collections
    if (!testFeatures(features1[i], features2[i])) {
      return false;
    }
  }

  // got here, features equals by coordinates
  return true;
}
