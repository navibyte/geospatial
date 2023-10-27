// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: cascade_invocations

import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/base/box.dart';
import '/src/vector/content/feature_content.dart';
import '/src/vector/content/geometry_content.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector_data/model/geometry/geometry.dart';

import 'feature.dart';
import 'feature_collection.dart';
import 'feature_object.dart';

/// A builder to create geospatial feature objects of [T] from [FeatureContent].
///
/// This builder supports creating [Feature] and [FeatureCollection] objects.
///
/// Features or feature items on a collection contain a geometry of [E].
///
/// See [FeatureContent] for more information about these objects.
class FeatureBuilder<T extends FeatureObject, E extends Geometry>
    with FeatureContent {
  final void Function(T object) _addObject;

  FeatureBuilder._(this._addObject);

  void _add(FeatureObject object) {
    if (object is T) {
      _addObject.call(object);
    }
  }

  /// Builds geospatial feature objects from the content provided by [features].
  ///
  /// Built feature object are sent into [to] callback function.
  ///
  /// Only feature objects of [T] are built, any other objects are ignored. [T]
  /// should be [FeatureObject] (building both features and feature
  /// collections), [Feature] or [FeatureCollection].
  ///
  /// Features or feature items on a collection contain a geometry of [E].
  static void build<T extends FeatureObject, E extends Geometry>(
    WriteFeatures features, {
    required void Function(T feature) to,
  }) {
    final builder = FeatureBuilder<T, E>._(to);
    features.call(builder);
  }

  /// Builds a list of geospatial feature objects from the content provided by
  /// [features].
  ///
  /// Only feature objects of [T] are built, any other objects are ignored. [T]
  /// should be [FeatureObject] (building both features and feature
  /// collections), [Feature] or [FeatureCollection].
  ///
  /// Features or feature items on a collection contain a geometry of [E].
  ///
  /// An optional expected [count], when given, specifies the number of feature
  /// objects in the content. Note that when given the count MUST be exact.
  static List<T> buildList<T extends FeatureObject, E extends Geometry>(
    WriteFeatures features, {
    int? count,
  }) {
    final list = <T>[];
    final builder = FeatureBuilder<T, E>._(list.add);
    features.call(builder);
    return list;
  }

  /// Parses a feature object of [R] from [text] conforming to [format].
  ///
  /// When [format] is not given, then the feature format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  static R parse<R extends FeatureObject, E extends Geometry>(
    String text, {
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) {
    R? result;

    // get feature builder to build a feature object of R
    final builder = FeatureBuilder<R, E>._((object, {name}) {
      if (result != null) {
        throw const FormatException('Already decoded one');
      }
      result = object;
    });

    // get decoder with the content decoded sent to builder
    final decoder = format.decoder(
      builder,
      crs: crs,
      options: options,
    );

    // decode and return result if succesful
    decoder.decodeText(text);
    if (result != null) {
      return result!;
    } else {
      throw const FormatException('Could not decode text');
    }
  }

  /// Decode a feature object of [R] from [data] conforming to [format].
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
  static R fromData<R extends FeatureObject, E extends Geometry>(
    Map<String, dynamic> data, {
    TextReaderFormat<FeatureContent> format = GeoJSON.feature,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) {
    R? result;

    // get feature builder to build a feature object of R
    final builder = FeatureBuilder<R, E>._((object, {name}) {
      if (result != null) {
        throw const FormatException('Already decoded one');
      }
      result = object;
    });

    // get decoder with the content decoded sent to builder
    final decoder = format.decoder(
      builder,
      crs: crs,
      options: options,
    );

    // decode and return result if succesful
    decoder.decodeData(data);
    if (result != null) {
      return result!;
    } else {
      throw const FormatException('Could not decode text');
    }
  }

  @override
  void feature({
    Object? id,
    WriteGeometries? geometry,
    Map<String, dynamic>? properties,
    Box? bounds,
    Map<String, dynamic>? custom,
  }) {
    _add(
      Feature<E>.build(
        id: id,
        geometry: geometry,
        properties: properties,
        bounds: bounds,
        custom: custom,
      ),
    );
  }

  @override
  void featureCollection(
    WriteFeatures features, {
    int? count,
    Box? bounds,
    Map<String, dynamic>? custom,
  }) {
    _add(
      FeatureCollection.build<E>(
        features,
        count: count,
        bounds: bounds,
        custom: custom,
      ),
    );
  }
}
