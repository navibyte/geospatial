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
  final GeoJsonConf? conf;

  _GeoJsonGeometryTextDecoder(
    this.builder, {
    this.crs,
    this.options,
    this.conf,
  });

  @override
  void decodeBytes(Uint8List source) => decodeText(utf8.decode(source));

  @override
  void decodeText(String source) => decodeData(json.decode(source));

  @override
  void decodeData(dynamic source) {
    try {
      // expect source as an object tree (JSON Object)
      final root = source as Map<String, dynamic>;

      // swap x and y if CRS has y-x (lat-lon) order (and logic is auth based)
      final swapXY = crs?.swapXY(logic: conf?.crsLogic) ?? false;

      // if true coordinate values parsed are stored in Float32, not Float64
      final singlePrecision = conf?.singlePrecision ?? false;

      // decode the geometry object at root (without name geometry name)
      _decodeGeometry(
        root,
        builder,
        swapXY: swapXY,
        singlePrecision: singlePrecision,
      );
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
  // NOTE: there is also an adapted version called _GeoJsonSeqFeatureTextDecoder
  //       located in geojson_seq_format.dart - both have some common code that
  //       should be kept in sync when changing code

  final FeatureContent builder;
  final CoordRefSys? crs;
  final Map<String, dynamic>? options;
  final GeoJsonConf? conf;

  _GeoJsonFeatureTextDecoder(
    this.builder, {
    this.crs,
    this.options,
    this.conf,
  });

  @override
  void decodeBytes(Uint8List source) => decodeText(utf8.decode(source));

  @override
  void decodeText(String source) => decodeData(json.decode(source));

  @override
  void decodeData(dynamic source) {
    try {
      // expect source as an object tree (JSON Object)
      final root = source as Map<String, dynamic>;

      // swap x and y if CRS has y-x (lat-lon) order (and logic is auth based)
      final swapXY = crs?.swapXY(logic: conf?.crsLogic) ?? false;

      // if true coordinate values parsed are stored in Float32, not Float64
      final singlePrecision = conf?.singlePrecision ?? false;

      // whether to ignore custom (or foreign) members on Features or
      // FeatureCollections
      final ignoreCustom = conf?.ignoreForeignMembers ?? false;

      // check for GeoJSON types and decode as supported types found
      switch (root['type']) {
        case 'Feature':
          _decodeFeature(
            root,
            builder,
            swapXY: swapXY,
            singlePrecision: singlePrecision,
            ignoreCustom: ignoreCustom,
          );
          return;
        case 'FeatureCollection':
          final opt = options;
          final itemOffset = opt != null ? opt['itemOffset'] as int? : null;
          final itemLimit = opt != null ? opt['itemLimit'] as int? : null;
          _decodeFeatureCollection(
            root,
            builder,
            swapXY: swapXY,
            singlePrecision: singlePrecision,
            ignoreCustom: ignoreCustom,
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
  GeometryContent builder, {
  required bool swapXY,
  required bool singlePrecision,
  String? name,
}) {
  // NOTE : coord type from conf
  // NOTE: read custom or foreign members

  // check for GeoJSON types and decode as supported types found
  switch (geometry['type']) {
    case 'Point':
      final array = geometry['coordinates'] as List<dynamic>;
      if (array.isEmpty) {
        builder.emptyGeometry(Geom.point, name: name);
      } else {
        final pos = createPosition(
          array,
          swapXY: swapXY,
          singlePrecision: singlePrecision,
        );
        builder.point(pos, name: name);
      }
      break;
    case 'LineString':
      final array = geometry['coordinates'] as List<dynamic>;
      if (array.isEmpty) {
        builder.emptyGeometry(Geom.lineString, name: name);
      } else {
        final chain = createPositionSeries(
          array,
          swapXY: swapXY,
          singlePrecision: singlePrecision,
        );
        final coordType = chain.coordType;
        // NOTE: validate line string (at least two points)
        builder.lineString(
          chain,
          bounds: _buildBboxOpt(geometry, swapXY, coordType),
          name: name,
        );
      }
      break;
    case 'Polygon':
      final array = geometry['coordinates'] as List<dynamic>;
      if (array.isEmpty) {
        builder.emptyGeometry(Geom.polygon, name: name);
      } else {
        final rings = createPositionSeriesArray(
          array,
          swapXY: swapXY,
          singlePrecision: singlePrecision,
        );
        final coordType = positionSeriesArrayType(rings);
        // NOTE: validate polygon (at least one ring)
        builder.polygon(
          rings,
          bounds: _buildBboxOpt(geometry, swapXY, coordType),
          name: name,
        );
      }
      break;
    case 'MultiPoint':
      final array = geometry['coordinates'] as List<dynamic>;
      if (array.isEmpty) {
        builder.emptyGeometry(Geom.multiPoint, name: name);
      } else {
        final points = createPositionArray(
          array,
          swapXY: swapXY,
          singlePrecision: singlePrecision,
        );
        final coordType = positionArrayType(points);
        builder.multiPoint(
          points,
          bounds: _buildBboxOpt(geometry, swapXY, coordType),
          name: name,
        );
      }
      break;
    case 'MultiLineString':
      final array = geometry['coordinates'] as List<dynamic>;
      if (array.isEmpty) {
        builder.emptyGeometry(Geom.multiLineString, name: name);
      } else {
        final chains = createPositionSeriesArray(
          array,
          swapXY: swapXY,
          singlePrecision: singlePrecision,
        );
        final coordType = positionSeriesArrayType(chains);
        builder.multiLineString(
          chains,
          bounds: _buildBboxOpt(geometry, swapXY, coordType),
          name: name,
        );
      }
      break;
    case 'MultiPolygon':
      final array = geometry['coordinates'] as List<dynamic>;
      if (array.isEmpty) {
        builder.emptyGeometry(Geom.multiPolygon, name: name);
      } else {
        final ringsArray = createPositionSeriesArrayArray(
          array,
          swapXY: swapXY,
          singlePrecision: singlePrecision,
        );
        final coordType = positionSeriesArrayArrayType(ringsArray);
        builder.multiPolygon(
          ringsArray,
          bounds: _buildBboxOpt(geometry, swapXY, coordType),
          name: name,
        );
      }
      break;
    case 'GeometryCollection':
      final geometries = geometry['geometries'] as List<dynamic>;
      if (geometries.isEmpty) {
        builder.emptyGeometry(Geom.geometryCollection, name: name);
      } else {
        builder.geometryCollection(
          (geometryBuilder) {
            for (final geometry in geometries) {
              _decodeGeometry(
                geometry as Map<String, dynamic>,
                geometryBuilder,
                swapXY: swapXY,
                singlePrecision: singlePrecision,
              );
            }
          },
          count: geometries.length,
          bounds: _buildBboxOpt(geometry, swapXY),
          name: name,
        );
      }
      break;
    default:
      throw _notValidGeoJsonData;
  }
}

void _decodeFeature(
  Map<String, dynamic> feature,
  FeatureContent builder, {
  required bool swapXY,
  required bool singlePrecision,
  required bool ignoreCustom,
}) {
  // feature has an optional primary geometry in "geometry" field
  final geom = feature['geometry'] as Map<String, dynamic>?;

  // read custom or foreign members (other fields than "type", "id", "bbox",
  // "geometry" or "properties")
  Map<String, dynamic>? custom;
  if (!ignoreCustom) {
    for (final entry in feature.entries) {
      final key = entry.key;
      if (key != 'type' &&
          key != 'id' &&
          key != 'bbox' &&
          key != 'geometry' &&
          key != 'properties') {
        custom ??= {};
        custom[entry.key] = entry.value;
      }
    }
  }

  // build feature
  builder.feature(
    id: _optStringOrNumber(feature['id']),
    properties: feature['properties'] as Map<String, dynamic>?,
    geometry: geom != null
        ? (geometryBuilder) => _decodeGeometry(
              geom,
              geometryBuilder,
              swapXY: swapXY,
              singlePrecision: singlePrecision,

              // GeoJSON => a primary geometry of a Feature is named "geometry"
              name: 'geometry',
            )
        : null,
    bounds: _buildBboxOpt(feature, swapXY),
    custom: custom,
  );
}

void _decodeFeatureCollection(
  Map<String, dynamic> collection,
  FeatureContent builder, {
  required bool swapXY,
  required bool singlePrecision,
  required bool ignoreCustom,
  int? itemOffset,
  int? itemLimit,
}) {
  final features = collection['features'] as List<dynamic>;

  // read custom or foreign members (other fields than "type", "bbox" or
  // "features")
  Map<String, dynamic>? custom;
  if (!ignoreCustom) {
    for (final entry in collection.entries) {
      final key = entry.key;
      if (key != 'type' && key != 'bbox' && key != 'features') {
        custom ??= {};
        custom[entry.key] = entry.value;
      }
    }
  }

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
            swapXY: swapXY,
            singlePrecision: singlePrecision,
            ignoreCustom: ignoreCustom,
          );
        }
      },
      count: count,
      bounds: _buildBboxOpt(collection, swapXY),
      custom: custom,
    );
  } else {
    // all feature items on a collection are requested
    builder.featureCollection(
      (featureBuilder) {
        for (final feature in features) {
          _decodeFeature(
            feature as Map<String, dynamic>,
            featureBuilder,
            swapXY: swapXY,
            singlePrecision: singlePrecision,
            ignoreCustom: ignoreCustom,
          );
        }
      },
      count: features.length,
      bounds: _buildBboxOpt(collection, swapXY),
      custom: custom,
    );
  }
}

Box? _buildBboxOpt(Map<String, dynamic> object, bool swapXY, [Coords? type]) {
  final data = object['bbox'];
  if (data == null) return null;

  return createBox(data, type: type, swapXY: swapXY);
}

Object? _optStringOrNumber(dynamic data) {
  if (data == null || data is String || data is num) {
    return data;
  }
  throw _notValidGeoJsonData;
}
