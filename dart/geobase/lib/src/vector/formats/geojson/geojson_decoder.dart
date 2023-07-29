// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'geojson_format.dart';

const _notValidGeoJsonData = FormatException('Not valid GeoJSON data.');

class _GeoJsonGeometryTextDecoder implements ContentDecoder {
  final GeometryContent builder;
  final CoordRefSys? crs;
  final Map<String, dynamic>? options;

  _GeoJsonGeometryTextDecoder(this.builder, {this.crs, this.options});

  @override
  void decodeBytes(Uint8List source) => decodeText(utf8.decode(source));

  @override
  void decodeText(String source) => decodeData(json.decode(source));

  @override
  void decodeData(dynamic source) {
    try {
      // expect source as an object tree (JSON Object)
      final root = source as Map<String, dynamic>;

      // decode the geometry object at root
      _decodeGeometry(root, builder, crs);
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
  final CoordRefSys? crs;
  final Map<String, dynamic>? options;

  _GeoJsonFeatureTextDecoder(this.builder, {this.crs, this.options});

  @override
  void decodeBytes(Uint8List source) => decodeText(utf8.decode(source));

  @override
  void decodeText(String source) => decodeData(json.decode(source));

  @override
  void decodeData(dynamic source) {
    try {
      // expect source as an object tree (JSON Object)
      final root = source as Map<String, dynamic>;

      // check for GeoJSON types and decode as supported types found
      switch (root['type']) {
        case 'Feature':
          _decodeFeature(root, builder, crs);
          return;
        case 'FeatureCollection':
          final opt = options;
          final itemOffset = opt != null ? opt['itemOffset'] as int? : null;
          final itemLimit = opt != null ? opt['itemLimit'] as int? : null;
          _decodeFeatureCollection(
            root,
            builder,
            crs,
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
  CoordRefSys? crs,
) {
  // NOTE : coord type from conf
  // NOTE: read custom or foreign members

  // check for GeoJSON types and decode as supported types found
  switch (geometry['type']) {
    case 'Point':
      final pos = requirePositionDouble(geometry['coordinates'], crs);
      final coordType = Coords.fromDimension(pos.length);
      builder.point(pos, type: coordType);
      break;
    case 'LineString':
      final array = geometry['coordinates'] as List<dynamic>;
      final coordType = resolveCoordType(array, positionLevel: 1);
      // NOTE: validate line string (at least two points)
      builder.lineString(
        createFlatPositionArrayDouble(array, coordType, crs),
        type: coordType,
        bounds: _getBboxOpt(geometry, crs),
      );
      break;
    case 'Polygon':
      final array = geometry['coordinates'] as List<dynamic>;
      final coordType = resolveCoordType(array, positionLevel: 2);
      // NOTE: validate polygon (at least one ring)
      builder.polygon(
        createFlatPositionArrayArrayDouble(array, coordType, crs),
        type: coordType,
        bounds: _getBboxOpt(geometry, crs),
      );
      break;
    case 'MultiPoint':
      final array = requirePositionArrayDouble(geometry['coordinates'], crs);
      final coordType = resolveCoordType(array, positionLevel: 1);
      builder.multiPoint(
        array,
        type: coordType,
        bounds: _getBboxOpt(geometry, crs),
      );
      break;
    case 'MultiLineString':
      final array = geometry['coordinates'] as List<dynamic>;
      final coordType = resolveCoordType(array, positionLevel: 2);
      builder.multiLineString(
        createFlatPositionArrayArrayDouble(array, coordType, crs),
        type: coordType,
        bounds: _getBboxOpt(geometry, crs),
      );
      break;
    case 'MultiPolygon':
      final array = geometry['coordinates'] as List<dynamic>;
      final coordType = resolveCoordType(array, positionLevel: 3);
      builder.multiPolygon(
        createFlatPositionArrayArrayArrayDouble(array, coordType, crs),
        type: coordType,
        bounds: _getBboxOpt(geometry, crs),
      );
      break;
    case 'GeometryCollection':
      final geometries = geometry['geometries'] as List<dynamic>;
      builder.geometryCollection(
        (geometryBuilder) {
          for (final geometry in geometries) {
            _decodeGeometry(
              geometry as Map<String, dynamic>,
              geometryBuilder,
              crs,
            );
          }
        },
        count: geometries.length,
        bounds: _getBboxOpt(geometry, crs),
      );
      break;
    default:
      throw _notValidGeoJsonData;
  }
}

void _decodeFeature(
  Map<String, dynamic> feature,
  FeatureContent builder,
  CoordRefSys? crs,
) {
  // feature has an optional primary geometry in "geometry" field
  final geom = feature['geometry'] as Map<String, dynamic>?;

  // NOTE: check if feature has other geometry objects as childs, and hanlde em'
  // NOTE: read custom or foreign members

  // build feature
  builder.feature(
    id: _optStringOrNumber(feature['id']),
    properties: feature['properties'] as Map<String, dynamic>?,
    geometry: geom != null
        ? (geometryBuilder) => _decodeGeometry(geom, geometryBuilder, crs)
        : null,
    bounds: _getBboxOpt(feature, crs),
  );
}

void _decodeFeatureCollection(
  Map<String, dynamic> collection,
  FeatureContent builder,
  CoordRefSys? crs, {
  int? itemOffset,
  int? itemLimit,
}) {
  final features = collection['features'] as List<dynamic>;

  // NOTE: read custom or foreign members

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
          _decodeFeature(
            feature as Map<String, dynamic>,
            featureBuilder,
            crs,
          );
        }
      },
      count: count,
      bounds: _getBboxOpt(collection, crs),
    );
  } else {
    // all feature items on a collection are requested
    builder.featureCollection(
      (featureBuilder) {
        for (final feature in features) {
          _decodeFeature(
            feature as Map<String, dynamic>,
            featureBuilder,
            crs,
          );
        }
      },
      count: features.length,
      bounds: _getBboxOpt(collection, crs),
    );
  }
}

List<double>? _getBboxOpt(Map<String, dynamic> object, CoordRefSys? crs) {
  final data = object['bbox'];
  if (data == null) return null;

  // swap x and y if coordinate reference system has y-x (lat-lon) order
  final swapXY = crs?.swapXY ?? false;

  // expect source to be list
  final source = data as List<dynamic>;
  final len = source.length;

  // bbox may have 4, 6 or 8 coordinate values
  switch (len) {
    case 4:
      return [
        (source[swapXY ? 1 : 0] as num).toDouble(), // minX
        (source[swapXY ? 0 : 1] as num).toDouble(), // minY
        (source[swapXY ? 3 : 2] as num).toDouble(), // maxX
        (source[swapXY ? 2 : 3] as num).toDouble(), // maxY
      ];
    case 6:
      return [
        (source[swapXY ? 1 : 0] as num).toDouble(), // minX
        (source[swapXY ? 0 : 1] as num).toDouble(), // minY
        (source[2] as num).toDouble(), // minZ or maxM
        (source[swapXY ? 4 : 3] as num).toDouble(), // maxX
        (source[swapXY ? 3 : 4] as num).toDouble(), // maxY
        (source[5] as num).toDouble(), // maxZ or maxM
      ];
    case 8:
      return [
        (source[swapXY ? 1 : 0] as num).toDouble(), // minX
        (source[swapXY ? 0 : 1] as num).toDouble(), // minY
        (source[2] as num).toDouble(), // minZ
        (source[3] as num).toDouble(), // maxM
        (source[swapXY ? 5 : 4] as num).toDouble(), // maxX
        (source[swapXY ? 4 : 5] as num).toDouble(), // maxY
        (source[6] as num).toDouble(), // maxZ
        (source[7] as num).toDouble(), // maxM
      ];
    default:
      throw _notValidGeoJsonData;
  }
}

Object? _optStringOrNumber(dynamic data) {
  if (data == null || data is String || data is num) {
    return data;
  }
  throw _notValidGeoJsonData;
}
