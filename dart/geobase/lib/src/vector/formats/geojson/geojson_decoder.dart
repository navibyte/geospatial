// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'geojson_format.dart';

const _notValidGeoJsonData = FormatException('Not valid GeoJSON data.');

class _GeoJsonGeometryTextDecoder implements ContentDecoder {
  final GeometryContent builder;

  _GeoJsonGeometryTextDecoder(this.builder);

  @override
  void decodeBytes(Uint8List source, {Map<String, dynamic>? options}) =>
      decodeText(utf8.decode(source), options: options);

  @override
  void decodeText(String source, {Map<String, dynamic>? options}) =>
      decodeData(json.decode(source), options: options);

  @override
  void decodeData(dynamic source, {Map<String, dynamic>? options}) {
    try {
      // expect source as an object tree (JSON Object)
      final root = source as Map<String, dynamic>;

      // decode the geometry object at root
      _decodeGeometry(root, builder);
    } on FormatException {
      rethrow;
    } catch (err) {
      // Errors might occur when casting data from external sources to
      // List<double>. We want to throw FormatException to clients however.
      throw FormatException('Not valid GeoJSON data (error: $err)');
    }
  }
}

class _GeoJsonFeatureTextDecoder implements ContentDecoder {
  final FeatureContent builder;

  _GeoJsonFeatureTextDecoder(this.builder);

  @override
  void decodeBytes(Uint8List source, {Map<String, dynamic>? options}) =>
      decodeText(utf8.decode(source), options: options);

  @override
  void decodeText(String source, {Map<String, dynamic>? options}) =>
      decodeData(json.decode(source), options: options);

  @override
  void decodeData(dynamic source, {Map<String, dynamic>? options}) {
    try {
      // expect source as an object tree (JSON Object)
      final root = source as Map<String, dynamic>;

      // check for GeoJSON types and decode as supported types found
      switch (root['type']) {
        case 'Feature':
          _decodeFeature(root, builder);
          return;
        case 'FeatureCollection':
          final itemOffset =
              options != null ? options['itemOffset'] as int? : null;
          final itemLimit =
              options != null ? options['itemLimit'] as int? : null;
          _decodeFeatureCollection(
            root,
            builder,
            itemOffset: itemOffset,
            itemLimit: itemLimit,
          );
          return;
      }
    } on FormatException {
      rethrow;
    } catch (err) {
      // Errors might occur when casting invalid data from external sources.
      // We want to throw FormatException to clients however.
      throw FormatException('Not valid GeoJSON data (error: $err)');
    }

    throw _notValidGeoJsonData;
  }
}

void _decodeGeometry(
  Map<String, dynamic> geometry,
  GeometryContent builder,
) {
  // todo : coord type from conf
  // todo: read custom or foreign members

  // check for GeoJSON types and decode as supported types found
  switch (geometry['type']) {
    case 'Point':
      final pos = requirePositionDouble(geometry['coordinates']);
      final coordType = Coords.fromDimension(pos.length);
      builder.point(pos, type: coordType);
      break;
    case 'LineString':
      final array = geometry['coordinates'] as List<dynamic>;
      final coordType = resolveCoordType(array, positionLevel: 1);
      // todo: validate line string (at least two points)
      builder.lineString(
        createFlatPositionArrayDouble(array, coordType),
        type: coordType,
        bounds: _getBboxOpt(geometry),
      );
      break;
    case 'Polygon':
      final array = geometry['coordinates'] as List<dynamic>;
      final coordType = resolveCoordType(array, positionLevel: 2);
      // todo: validate polygon (at least one ring)
      builder.polygon(
        createFlatPositionArrayArrayDouble(array, coordType),
        type: coordType,
        bounds: _getBboxOpt(geometry),
      );
      break;
    case 'MultiPoint':
      final array = requirePositionArrayDouble(geometry['coordinates']);
      final coordType = resolveCoordType(array, positionLevel: 1);
      builder.multiPoint(
        array,
        type: coordType,
        bounds: _getBboxOpt(geometry),
      );
      break;
    case 'MultiLineString':
      final array = geometry['coordinates'] as List<dynamic>;
      final coordType = resolveCoordType(array, positionLevel: 2);
      builder.multiLineString(
        createFlatPositionArrayArrayDouble(array, coordType),
        type: coordType,
        bounds: _getBboxOpt(geometry),
      );
      break;
    case 'MultiPolygon':
      final array = geometry['coordinates'] as List<dynamic>;
      final coordType = resolveCoordType(array, positionLevel: 3);
      builder.multiPolygon(
        createFlatPositionArrayArrayArrayDouble(array, coordType),
        type: coordType,
        bounds: _getBboxOpt(geometry),
      );
      break;
    case 'GeometryCollection':
      final geometries = geometry['geometries'] as List<dynamic>;
      builder.geometryCollection(
        (geometryBuilder) {
          for (final geometry in geometries) {
            _decodeGeometry(geometry as Map<String, dynamic>, geometryBuilder);
          }
        },
        count: geometries.length,
        bounds: _getBboxOpt(geometry),
      );
      break;
    default:
      throw _notValidGeoJsonData;
  }
}

void _decodeFeature(Map<String, dynamic> feature, FeatureContent builder) {
  // feature has an optional primary geometry in "geometry" field
  final geom = feature['geometry'] as Map<String, dynamic>?;

  // todo: check if feature has other geometry objects as childs, and hanlde em'
  // todo: read custom or foreign members

  // build feature
  builder.feature(
    id: _optStringOrNumber(feature['id']),
    properties: feature['properties'] as Map<String, dynamic>?,
    geometry: geom != null
        ? (geometryBuilder) => _decodeGeometry(geom, geometryBuilder)
        : null,
    bounds: _getBboxOpt(feature),
  );
}

void _decodeFeatureCollection(
  Map<String, dynamic> collection,
  FeatureContent builder, {
  int? itemOffset,
  int? itemLimit,
}) {
  final features = collection['features'] as List<dynamic>;

  // todo: read custom or foreign members

  if (itemOffset != null || itemLimit != null) {
    // a range of feature items on a collection is requested
    final Iterable<dynamic> range;
    final int count;
    final len = features.length;
    final start = itemOffset ?? 0;
    if (start < len) {
      final end = itemLimit != null ? math.min(start + itemLimit, len) : len;
      count = end - start;
      range = features.getRange(start, end);
    } else {
      count = 0;
      range = const Iterable<dynamic>.empty();
    }
    builder.featureCollection(
      (featureBuilder) {
        for (final feature in range) {
          _decodeFeature(feature as Map<String, dynamic>, featureBuilder);
        }
      },
      count: count,
      bounds: _getBboxOpt(collection),
    );
  } else {
    // all feature items on a collection are requested
    builder.featureCollection(
      (featureBuilder) {
        for (final feature in features) {
          _decodeFeature(feature as Map<String, dynamic>, featureBuilder);
        }
      },
      count: features.length,
      bounds: _getBboxOpt(collection),
    );
  }
}

List<double>? _getBboxOpt(Map<String, dynamic> object) {
  final data = object['bbox'];
  return data != null
      ? (data as List<dynamic>)
          .cast<num>()
          .map<double>((e) => e.toDouble())
          .toList(growable: false)
      : null;
}

Object? _optStringOrNumber(dynamic data) {
  if (data == null || data is String || data is num) {
    return data;
  }
  throw _notValidGeoJsonData;
}
