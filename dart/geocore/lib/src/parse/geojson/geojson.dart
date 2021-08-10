// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:math' as math;

import 'package:attributes/entity.dart';

import '../../base.dart';
import '../../feature.dart';
import '../../geo.dart';
import '../factory.dart';

/// The default GeoJSON factory instace assuming geographic CRS80 coordinates.
///
/// Result type candidates for point objects: [GeoPoint2], [GeoPoint3].
const geoJSON = GeoJsonFactory<GeoPoint>(
  pointFactory: geoPointFactory,
  boundsFactory: geoBoundsFactory,
);

/// The default GeoJSON factory instace assuming projected coordinates.
///
/// Result type candidates for point objects: [Point2], [Point3].
const geoJSONProjected = GeoJsonFactory<Point>(
  pointFactory: projectedPointFactory,
  boundsFactory: anyBoundsFactory,
);

/// The default [CreateFeature] forwarding directly to Feature.view() factory.
///
/// This factory omits [jsonObject] parameter.
Feature<T> _defaultFeatureFactory<T extends Geometry>(
        {Object? id,
        required Map<String, Object?> properties,
        T? geometry,
        Bounds? bounds,
        Map<String, Object?>? jsonObject}) =>
    Feature<T>.view(
        id: id, properties: properties, geometry: geometry, bounds: bounds);

/// A geospatial object factory capable of parsing GeoJSON data from json.
///
/// The implementation expects JSON objects to be compatible with objects
/// generated by the standard `json.decode()`.
///
/// Methods geometry(), feature(), featureSeries() and featureCollections()
/// accepts data object to be either a String (containing valid GeoJSON) or
/// object tree generated by the standard `json.decode()`.
///
/// See [The GeoJSON Format - RFC 7946](https://tools.ietf.org/html/rfc7946).
class GeoJsonFactory<PointType extends Point>
    extends GeoFactoryBase<PointType> {
  const GeoJsonFactory(
      {required PointFactory<PointType> pointFactory,
      required CreateBounds<PointType> boundsFactory,
      CreateFeature featureFactory = _defaultFeatureFactory})
      : super(
          pointFactory: pointFactory,
          boundsFactory: boundsFactory,
          featureFactory: featureFactory,
        );

  Map<String, dynamic> _ensureDecodedMap(dynamic data) {
    final dynamic decoded;
    if (data is String) {
      try {
        decoded = json.decode(data);
      } on Exception catch (e) {
        throw FormatException('Unknown encoding for GeoJSON ($e).');
      }
    } else {
      decoded = data;
    }
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw FormatException('Unknown encoding for GeoJSON.');
  }

  Iterable<dynamic> _ensureDecodedIterable(dynamic data) {
    final dynamic decoded;
    if (data is String) {
      try {
        decoded = json.decode(data);
      } on Exception catch (e) {
        throw FormatException('Unknown encoding for GeoJSON ($e).');
      }
    } else {
      decoded = data;
    }
    if (decoded is Iterable) {
      return decoded;
    }
    throw FormatException('Unknown encoding for GeoJSON.');
  }

  @override
  T geometry<T extends Geometry>(dynamic data) {
    // expects data of Map<String, dynamic> as returned by json.decode()
    final json = _ensureDecodedMap(data);
    dynamic geom;
    switch (json['type']) {
      case 'Point':
        // expected 'coordinates' data like : [100.0, 100.0, 10.0]
        geom = point(json['coordinates'] as Iterable);
        break;
      case 'LineString':
        // expected 'coordinates' data like :
        // [
        //   [100.0, 100.0, 10.0],
        //   [200.0, 200.0, 20.0]
        // ]
        geom = lineString(json['coordinates'] as Iterable);
        break;
      case 'Polygon':
        // expected 'coordinates' data like :
        // [
        //   [
        //     [100.0, 100.0, 10.0],
        //     [200.0, 200.0, 20.0]
        //     [100.0, 200.0, 20.0]
        //     [100.0, 100.0, 10.0],
        //   ]
        // ]
        geom = polygon(json['coordinates'] as Iterable);
        break;
      case 'MultiPoint':
        // expected 'coordinates' data like :
        // [
        //   [100.0, 100.0, 10.0],
        //   [200.0, 200.0, 20.0]
        // ]
        geom = multiPoint(json['coordinates'] as Iterable);
        break;
      case 'MultiLineString':
        // expected 'coordinates' data like :
        // [
        //   [
        //     [100.0, 100.0, 10.0],
        //     [200.0, 200.0, 20.0]
        //   ],
        //   [
        //     [300.0, 300.0, 30.0],
        //     [400.0, 400.0, 40.0]
        //   ]
        // ]
        geom = multiLineString(json['coordinates'] as Iterable);
        break;
      case 'MultiPolygon':
        // expected 'coordinates' data like :
        // [
        //   [
        //     [
        //       [100.0, 100.0, 10.0],
        //       [200.0, 200.0, 20.0]
        //       [100.0, 200.0, 20.0]
        //       [100.0, 100.0, 10.0],
        //     ]
        //   ]
        // ]
        geom = multiPolygon(json['coordinates'] as Iterable);
        break;
      case 'GeometryCollection':
        geom = geometryCollection(json['geometries'] as Iterable);
        break;
    }
    if (geom is T) {
      return geom;
    }
    throw FormatException('Not valid GeoJSON geometry.');
  }

  @override
  Feature<T> feature<T extends Geometry>(dynamic data) {
    // expects data of Map<String, dynamic> as returned by json.decode()
    final json = _ensureDecodedMap(data);
    if (json['type'] != 'Feature') {
      throw FormatException('Not valid GeoJSON Feature.');
    }

    // parse id as FeatureId or null
    // - id read from GeoJSON is null : null as id
    // - id read from GeoJSON is int : wrap on Identifier
    // - otherwise : convert read value to String and wrap on Identifier
    // (GeoJSON allows num and String types for ids)
    final dynamic idJson = json['id'];
    final id = idJson != null
        ? Identifier.from(idJson is int ? idJson : idJson.toString())
        : null;

    // parse optional geometry for this feature
    final dynamic geomJson = json['geometry'];
    final geom = geomJson != null ? geometry<T>(geomJson) : null;

    // parse optional bbox
    // (bbox is not required on GeoJSON and not on Feature either)
    final bboxJson = json['bbox'] as Iterable?;
    final bbox = bboxJson != null ? bounds(bboxJson) : null;

    // create a feature using the factory function
    return featureFactory<T>(
      // nullable id
      id: id,

      // map of properties may be missing on GeoJSON, but for a feature
      // non-null map (even empty) is required
      properties: json['properties'] as Map<String, Object?>? ?? {},

      // nullable geometry object
      geometry: geom,

      // nullable bounds object
      bounds: bbox,

      // the JSON Object from source data provided as-is
      // (this lets custom feature factories to parse properties not known by
      //  the JSON specification)
      jsonObject: json,
    );
  }

  @override
  BoundedSeries<Feature<T>> featureSeries<T extends Geometry>(dynamic data,
      {Range? range}) {
    // expects data of List as returned by json.decode()
    final json = _ensureDecodedIterable(data);

    // figure out what range (or all) of features should be returned on a series
    final features = _listByRange(json, range: range);

    // create series of features from the range selected above and map
    // JSON object of each feature to Feature instance
    return BoundedSeries<Feature<T>>.from(
        features.map<Feature<T>>((dynamic f) => feature<T>(f)));
  }

  @override
  FeatureCollection<Feature<T>> featureCollection<T extends Geometry>(
      dynamic data,
      {Range? range}) {
    // expects data of Map<String, dynamic> as returned by json.decode()
    final json = _ensureDecodedMap(data);

    if (json['type'] == 'Feature') {
      // just single feature, not collection, but return as a collection anyway
      return FeatureCollection<Feature<T>>.of(
        features: featureSeries<T>([json], range: range),
      );
    } else {
      // excepting a collection
      if (json['type'] != 'FeatureCollection') {
        throw FormatException('Not valid GeoJSON FeatureCollection.');
      }

      // parse optional bbox
      // (bbox is not required on GeoJSON and not on FeatureCollection either)
      final bboxJson = json['bbox'] as Iterable?;
      final bbox = bboxJson != null ? bounds(bboxJson) : null;

      // create a feature collection
      return FeatureCollection<Feature<T>>.of(
        // required series of features (allowed to be empty)
        features: featureSeries<T>(json['features'], range: range),

        // nullable bounds object
        bounds: bbox,
      );
    }
  }

  @override
  int featureCount(dynamic data, {Range? range}) {
    final json = _ensureDecodedMap(data);
    final List<dynamic> list;
    if (json['type'] == 'Feature') {
      list = <dynamic>[json];
    } else {
      if (json['type'] != 'FeatureCollection') {
        throw FormatException('Not valid GeoJSON FeatureCollection.');
      }
      list = json['features'] as List;
    }
    return _listByRange(list).length;
  }

  Iterable<dynamic> _listByRange(Iterable<dynamic> json, {Range? range}) {
    final Iterable<dynamic> items;
    if (range != null) {
      final count = json.length;
      if (range.start >= count) {
        // range is out of bounds, do not throw, just return empty set
        items = Iterable<dynamic>.empty();
      } else {
        final limit = range.limit;
        if (limit != null && limit >= 0) {
          // range by "start" (first index) and "limit" (max number of items)
          final end = math.min(range.start + limit, count);
          if (json is List) {
            items = json.getRange(range.start, end);
          } else {
            items = json.skip(range.start).take(end - range.start);
          }
        } else {
          // range by "start" (first index) only, open ended
          items = json.skip(range.start);
        }
      }
    } else {
      // no range set, so simple take all items json content has
      items = json;
    }
    return items;
  }
}

/*

import 'dart:convert';
import 'dart:math' as math;

import 'package:attributes/entity.dart';

import '../../base.dart';
import '../../feature.dart';
import '../../geo.dart';
import '../factory.dart';

/// The default GeoJSON factory instace assuming geographic CRS80 coordinates.
///
/// Result type candidates for point objects: [GeoPoint2], [GeoPoint3].
const geoJSON = GeoJsonFactory<GeoPoint>(
  pointFactory: geoPointFactory,
  boundsFactory: geoBoundsFactory,
);

/// The default GeoJSON factory instace assuming projected coordinates.
///
/// Result type candidates for point objects: [Point2], [Point3].
const geoJSONProjected = GeoJsonFactory<Point>(
  pointFactory: projectedPointFactory,
  boundsFactory: anyBoundsFactory,
);

/// The default [CreateFeature] forwarding directly to Feature.view() factory.
///
/// This factory omits [jsonObject] parameter.
Feature<T> _defaultFeatureFactory<T extends Geometry>(
        {Object? id,
        required Map<String, Object?> properties,
        T? geometry,
        Bounds? bounds,
        Map<String, Object?>? jsonObject}) =>
    Feature<T>.view(
        id: id, properties: properties, geometry: geometry, bounds: bounds);

/// A geospatial object factory capable of parsing GeoJSON data from json.
///
/// The implementation expects JSON objects to be compatible with objects
/// generated by the standard `json.decode()`.
///
/// Methods geometry(), feature(), featureSeries() and featureCollections()
/// accepts data object to be either a String (containing valid GeoJSON) or
/// object tree generated by the standard `json.decode()`.
///
/// See [The GeoJSON Format - RFC 7946](https://tools.ietf.org/html/rfc7946).
class GeoJsonFactory<PointType extends Point>
    extends GeoFactoryBase<PointType> {
  const GeoJsonFactory(
      {required PointFactory<PointType> pointFactory,
      required CreateBounds<PointType> boundsFactory,
      CreateFeature featureFactory = _defaultFeatureFactory})
      : super(
          pointFactory: pointFactory,
          boundsFactory: boundsFactory,
          featureFactory: featureFactory,
        );

  Map<String, Object?> _ensureDecodedMap(Object data) {
    final Object? decoded;
    if (data is String) {
      try {
        decoded = json.decode(data);
      } on Exception catch (e) {
        throw FormatException('Unknown encoding for GeoJSON ($e).');
      }
    } else {
      decoded = data;
    }
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw FormatException('Unknown encoding for GeoJSON.');
  }

  Iterable<Object> _ensureDecodedIterable(Object data) {
    final Object? decoded;
    if (data is String) {
      try {
        decoded = json.decode(data);
      } on Exception catch (e) {
        throw FormatException('Unknown encoding for GeoJSON ($e).');
      }
    } else {
      decoded = data;
    }
    if (decoded is Iterable<Object>) {
      return decoded;
    } else if (decoded is Iterable<Object?>) {
      return decoded.whereType<Object>();
    }
    throw FormatException('Unknown encoding for GeoJSON.');
  }

  Iterable<T> _ensureIterable<T extends Object>(Object? data) {
    if (data is Iterable<T>) {
      return data;
    } else if (data is Iterable<T?>) {
      return data.whereType<T>();
    }
    throw FormatException('Unknown encoding for GeoJSON.');
  }

  @override
  T geometry<T extends Geometry>(Object data) {
    // expects data of Map<String, Object?> as returned by json.decode()
    final json = _ensureDecodedMap(data);
    Object? geom;

    switch (json['type']) {
      case 'Point':
        // expected 'coordinates' data like : [100.0, 100.0, 10.0]
        geom = point(_ensureIterable(json['coordinates']));
        break;
      case 'LineString':
        // expected 'coordinates' data like :
        // [
        //   [100.0, 100.0, 10.0],
        //   [200.0, 200.0, 20.0]
        // ]
        geom = lineString(_ensureIterable(json['coordinates']));
        break;
      case 'Polygon':
        // expected 'coordinates' data like :
        // [
        //   [
        //     [100.0, 100.0, 10.0],
        //     [200.0, 200.0, 20.0]
        //     [100.0, 200.0, 20.0]
        //     [100.0, 100.0, 10.0],
        //   ]
        // ]
        geom = polygon(_ensureIterable(json['coordinates']));
        break;
      case 'MultiPoint':
        // expected 'coordinates' data like :
        // [
        //   [100.0, 100.0, 10.0],
        //   [200.0, 200.0, 20.0]
        // ]
        geom = multiPoint(_ensureIterable(json['coordinates']));
        break;
      case 'MultiLineString':
        // expected 'coordinates' data like :
        // [
        //   [
        //     [100.0, 100.0, 10.0],
        //     [200.0, 200.0, 20.0]
        //   ],
        //   [
        //     [300.0, 300.0, 30.0],
        //     [400.0, 400.0, 40.0]
        //   ]
        // ]
        geom = multiLineString(_ensureIterable(json['coordinates']));
        break;
      case 'MultiPolygon':
        // expected 'coordinates' data like :
        // [
        //   [
        //     [
        //       [100.0, 100.0, 10.0],
        //       [200.0, 200.0, 20.0]
        //       [100.0, 200.0, 20.0]
        //       [100.0, 100.0, 10.0],
        //     ]
        //   ]
        // ]
        geom = multiPolygon(_ensureIterable(json['coordinates']));
        break;
      case 'GeometryCollection':
        geom = geometryCollection(_ensureIterable(json['geometries']));
        break;
    }
    if (geom is T) {
      return geom;
    }
    throw FormatException('Not valid GeoJSON geometry.');
  }

  @override
  Feature<T> feature<T extends Geometry>(Object data) {
    // expects data of Map<String, dynamic> as returned by json.decode()
    final json = _ensureDecodedMap(data);
    if (json['type'] != 'Feature') {
      throw FormatException('Not valid GeoJSON Feature.');
    }

    // parse id as FeatureId or null
    // - id read from GeoJSON is null : null as id
    // - id read from GeoJSON is int : wrap on Identifier
    // - otherwise : convert read value to String and wrap on Identifier
    // (GeoJSON allows num and String types for ids)
    final idJson = json['id'];
    final id = idJson != null
        ? Identifier.from(idJson is int ? idJson : idJson.toString())
        : null;

    // parse optional geometry for this feature
    final geomJson = json['geometry'];
    final geom = geomJson != null ? geometry<T>(geomJson) : null;

    // parse optional bbox
    // (bbox is not required on GeoJSON and not on Feature either)
    final bboxJson = json['bbox'];
    final bbox = bboxJson != null ? bounds(_ensureIterable(bboxJson)) : null;

    // create a feature using the factory function
    return featureFactory<T>(
      // nullable id
      id: id,

      // map of properties may be missing on GeoJSON, but for a feature
      // non-null map (even empty) is required
      properties: json['properties'] as Map<String, Object?>? ?? {},

      // nullable geometry object
      geometry: geom,

      // nullable bounds object
      bounds: bbox,

      // the JSON Object from source data provided as-is
      // (this lets custom feature factories to parse properties not known by
      //  the JSON specification)
      jsonObject: json,
    );
  }

  @override
  BoundedSeries<Feature<T>> featureSeries<T extends Geometry>(Object data,
      {Range? range}) {
    // expects data of List as returned by json.decode()
    final json = _ensureDecodedIterable(data);

    // figure out what range (or all) of features should be returned on a series
    final features = _listByRange(json, range: range);

    // create series of features from the range selected above and map
    // JSON object of each feature to Feature instance
    return BoundedSeries<Feature<T>>.from(
        features.map<Feature<T>>((f) => feature<T>(f)));
  }

  @override
  FeatureCollection<Feature<T>> featureCollection<T extends Geometry>(
      Object data,
      {Range? range}) {
    // expects data of Map<String, dynamic> as returned by json.decode()
    final json = _ensureDecodedMap(data);

    if (json['type'] == 'Feature') {
      // just single feature, not collection, but return as a collection anyway
      return FeatureCollection<Feature<T>>.of(
        features: featureSeries<T>(_ensureIterable([json]), range: range),
      );
    } else {
      // excepting a collection
      final features = json['features'];
      if (json['type'] != 'FeatureCollection' || features == null) {
        throw FormatException('Not valid GeoJSON FeatureCollection.');
      }

      // parse optional bbox
      // (bbox is not required on GeoJSON and not on FeatureCollection either)
      final bboxJson = json['bbox'] as Iterable<Object>?;
      final bbox = bboxJson != null ? bounds(bboxJson) : null;

      // create a feature collection
      return FeatureCollection<Feature<T>>.of(
        // required series of features (allowed to be empty)
        features: featureSeries<T>(_ensureIterable(features), range: range),

        // nullable bounds object
        bounds: bbox,
      );
    }
  }

  @override
  int featureCount(Object data, {Range? range}) {
    final json = _ensureDecodedMap(data);
    final Iterable<Object> list;
    if (json['type'] == 'Feature') {
      list = [json];
    } else {
      final features = json['features'];
      if (json['type'] != 'FeatureCollection' || features == null) {
        throw FormatException('Not valid GeoJSON FeatureCollection.');
      }
      list = features as Iterable<Object>;
    }
    return _listByRange(list).length;
  }

  Iterable<Object> _listByRange(Iterable<Object> json, {Range? range}) {
    final Iterable<Object> items;
    if (range != null) {
      final count = json.length;
      if (range.start >= count) {
        // range is out of bounds, do not throw, just return empty set
        items = Iterable.empty();
      } else {
        final limit = range.limit;
        if (limit != null && limit >= 0) {
          // range by "start" (first index) and "limit" (max number of items)
          final end = math.min(range.start + limit, count);
          if (json is List<Object>) {
            items = json.getRange(range.start, end);
          } else {
            items = json.skip(range.start).take(end - range.start);
          }
        } else {
          // range by "start" (first index) only, open ended
          items = json.skip(range.start);
        }
      }
    } else {
      // no range set, so simple take all items json content has
      items = json;
    }
    return items;
  }
}

*/
