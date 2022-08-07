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
  void decodeBytes(ByteBuffer source) =>
      decodeText(utf8.decode(source.asUint8List()));

  @override
  void decodeText(String source) {
    // decode JSON text as an object tree with root expected to be JSON Object
    final root = _requireJsonObject(json.decode(source));

    // decode the geometry object at root
    _decodeGeometry(root, builder);
  }
}

class _GeoJsonFeatureTextDecoder implements ContentDecoder {
  final FeatureContent builder;

  _GeoJsonFeatureTextDecoder(this.builder);

  @override
  void decodeBytes(ByteBuffer source) =>
      decodeText(utf8.decode(source.asUint8List()));

  @override
  void decodeText(String source) {
    // decode JSON text as an object tree with root expected to be JSON Object
    final root = _requireJsonObject(json.decode(source));

    // check for GeoJSON types and decode as supported types found
    switch (root['type']) {
      case 'Feature':
        _decodeFeature(root, builder);
        break;
      case 'FeatureCollection':
        _decodeFeatureCollection(root, builder);
        break;
      default:
        throw _notValidGeoJsonData;
    }
  }
}

void _decodeGeometry(
  Map<String, Object?> geometry,
  SimpleGeometryContent builder,
) {
  // todo : coord type from conf

  // check for GeoJSON types and decode as supported types found
  switch (geometry['type']) {
    case 'Point':
      final pos = _requirePositionDouble(geometry['coordinates']);
      final coordType = Coords.fromDimension(pos.length);
      builder.point(pos, type: coordType);
      break;
    case 'LineString':
      final array = _requirePositionArrayNum(geometry['coordinates']);
      final coordType = array.isNotEmpty
          ? Coords.fromDimension(array.first.length)
          : Coords.xy;
      // todo: validate line string (at least two points)
      builder.lineString(
        _createFlatPositionArrayDouble(array, coordType),
        type: coordType,
      );
      break;
    case 'Polygon':
      final array = _requirePositionArrayArrayNum(geometry['coordinates']);
      final coordType = array.isNotEmpty && array.first.isNotEmpty
          ? Coords.fromDimension(array.first.first.length)
          : Coords.xy;
      // todo: validate polygon (at least one ring)
      builder.polygon(
        _createFlatPositionArrayArrayDouble(array, coordType),
        type: coordType,
      );
      break;
    case 'MultiPoint':
      final array = _requirePositionArrayDouble(geometry['coordinates']);
      final coordType = array.isNotEmpty
          ? Coords.fromDimension(array.first.length)
          : Coords.xy;
      builder.multiPoint(array, type: coordType);
      break;
    case 'MultiLineString':
      final array = _requirePositionArrayArrayNum(geometry['coordinates']);
      final coordType = array.isNotEmpty && array.first.isNotEmpty
          ? Coords.fromDimension(array.first.first.length)
          : Coords.xy;
      builder.multiLineString(
        _createFlatPositionArrayArrayDouble(array, coordType),
        type: coordType,
      );
      break;
    case 'MultiPolygon':
      final array = _requirePositionArrayArrayArrayNum(geometry['coordinates']);
      final coordType = array.isNotEmpty &&
              array.first.isNotEmpty &&
              array.first.first.isNotEmpty
          ? Coords.fromDimension(array.first.first.first.length)
          : Coords.xy;
      builder.multiPolygon(
        _createFlatPositionArrayArrayArrayDouble(array, coordType),
        type: coordType,
      );
      break;
    case 'GeometryCollection':
      final geometries = _requireJsonArray(geometry['geometries']);
      builder.geometryCollection(
        (geometryBuilder) {
          for (final geometry in geometries) {
            _decodeGeometry(_requireJsonObject(geometry), geometryBuilder);
          }
        },
        count: geometries.length,
      );
      break;
    default:
      throw _notValidGeoJsonData;
  }
}

void _decodeFeature(Map<String, Object?> feature, FeatureContent builder) {
  // feature has an optional primary geometry in "geometry" field
  final geom = _optJsonObject(feature['geometry']);

  // todo: check if feature has other geometry objects as childs, and hanlde em'
  // todo: read bounding box
  // todo: read custom or foreign members

  // build feature
  builder.feature(
    id: _optStringOrNumber(feature['id']),
    properties: _optJsonObject(feature['properties']),
    geometry: geom != null
        ? (geometryBuilder) => _decodeGeometry(geom, geometryBuilder)
        : null,
  );
}

void _decodeFeatureCollection(
  Map<String, Object?> collection,
  FeatureContent builder,
) {
  final features = _requireJsonArray(collection['features']);
  builder.featureCollection(
    (featureBuilder) {
      for (final feature in features) {
        _decodeFeature(_requireJsonObject(feature), featureBuilder);
      }
    },
    count: features.length,
  );
}

Map<String, Object?> _requireJsonObject(Object? data) {
  if (data is Map<String, Object?>) {
    return data;
  }
  throw _notValidGeoJsonData;
}

List<Object?> _requireJsonArray(Object? data) {
  if (data is List<Object?>) {
    return data;
  }
  throw _notValidGeoJsonData;
}

Map<String, Object?>? _optJsonObject(Object? data) {
  if (data is Map<String, Object?>?) {
    return data;
  }
  throw _notValidGeoJsonData;
}

Object? _optStringOrNumber(Object? data) {
  if (data == null || data is String || data is num) {
    return data;
  }
  throw _notValidGeoJsonData;
}

List<double> _requirePositionDouble(Object? data) {
  if (data is List<double>) {
    return data;
  } else if (data is List<int>) {
    return data.map((e) => e.toDouble()).toList(growable: false);
  }
  throw _notValidGeoJsonData;
}

List<List<double>> _requirePositionArrayDouble(Object? data) {
  if (data is List<List<double>>) {
    return data;
  } else if (data is List<List<int>>) {
    data
        .map<List<double>>(
          (pos) => pos.map((e) => e.toDouble()).toList(growable: false),
        )
        .toList(growable: false);
  }
  throw _notValidGeoJsonData;
}

List<List<num>> _requirePositionArrayNum(Object? data) {
  if (data is List<List<num>>) {
    return data;
  }
  throw _notValidGeoJsonData;
}

List<List<List<num>>> _requirePositionArrayArrayNum(Object? data) {
  if (data is List<List<List<num>>>) {
    return data;
  }
  throw _notValidGeoJsonData;
}

List<List<List<List<num>>>> _requirePositionArrayArrayArrayNum(Object? data) {
  if (data is List<List<List<List<num>>>>) {
    return data;
  }
  throw _notValidGeoJsonData;
}

List<double> _createFlatPositionArrayDouble(
  List<List<num>> source,
  Coords coordType,
) {
  final dim = coordType.coordinateDimension;
  final positionCount = source.length;
  final valueCount = dim * positionCount;

  final array = List<double>.filled(valueCount, 0.0);
  for (var i = 0; i < positionCount; i++) {
    final pos = source[i];
    if(pos.length < 2) {
      throw _notValidGeoJsonData;
    }
    final offset = i * dim;
    array[offset] = pos[0].toDouble();
    array[offset + 1] = pos[1].toDouble();
    if (dim >= 3 && pos.length >= 3) {
      array[offset + 2] = pos[2].toDouble();
    }
    if (dim >= 4 && pos.length >= 4) {
      array[offset + 3] = pos[3].toDouble();
    }
  }

  return array;
}

List<List<double>> _createFlatPositionArrayArrayDouble(
  List<List<List<num>>> source,
  Coords coordType,
) =>
    source
        .map<List<double>>((e) => _createFlatPositionArrayDouble(e, coordType))
        .toList(growable: false);

List<List<List<double>>> _createFlatPositionArrayArrayArrayDouble(
  List<List<List<List<num>>>> source,
  Coords coordType,
) =>
    source
        .map<List<List<double>>>(
          (e) => _createFlatPositionArrayArrayDouble(e, coordType),
        )
        .toList(growable: false);
