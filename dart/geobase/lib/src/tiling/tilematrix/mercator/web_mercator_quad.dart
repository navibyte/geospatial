// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/coordinates/scalable.dart';
import '/src/tiling/convert/map.dart';
import '/src/tiling/tilematrix/base.dart';
import '/src/utils/web_mercator_converter.dart';

/// "Web Mercator Quad" tile matrix set aka "Google Maps Compatible".
///
/// More information:
/// https://en.wikipedia.org/wiki/Web_Mercator_projection
/// https://developers.google.com/maps/documentation/javascript/coordinates
/// https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system
@immutable
class WebMercatorQuad extends GeoTileMatrixSet {
  /// Create "Web Mercator Quad" tile matrix set with [tileSize] and [origin].
  ///
  /// Normally use 256 or 512 pixels for [tileSize].
  ///
  /// By default [origin] for tiles and pixels is "top-left", for example
  /// a tile (0, 0) is located in the north-west corner of the world map. This
  /// is the notation used by "Google Maps Compatible" tile services. You can
  /// set [origin] to "bottom-left", the notation used by TMS (Tile Map Service)
  /// specification.
  ///
  /// This implementation is based on the WGS 84 / Web Mercator projection
  /// ("EPSG:3857") aka "Pseudo-Mercator" or "Spherical Mercator".
  WebMercatorQuad.epsg3857({
    this.maxZoom = 22,
    this.tileSize = 256,
    this.origin = TileMatrixOrigin.topLeft,
  })  : assert(maxZoom >= 0, 'Max zoom must be >= 0'),
        assert(tileSize > 0, 'Tile size must be > 0'),
        _converter = const WebMercatorConverter.epsg3857();

  final WebMercatorConverter _converter;

  @override
  MapConverter get converter => _converter;

  /// The number of tiles at [zoom] (level of detail) in one axis.
  int matrixSize(int zoom) => 1 << zoom;

  /// The number of pixels at [zoom] (level of detail) in one axis.
  int mapSize(int zoom) => tileSize << zoom;

  @override
  final int maxZoom;

  @override
  final int tileSize;

  @override
  final TileMatrixOrigin origin;

  @override
  int matrixWidth(int zoom) => matrixSize(zoom);

  @override
  int matrixHeight(int zoom) => matrixSize(zoom);

  @override
  int mapWidth(int zoom) => mapSize(zoom);

  @override
  int mapHeight(int zoom) => mapSize(zoom);

  @override
  double tileResolution(int zoom) =>
      _converter.earthCircumference / matrixSize(zoom);

  @override
  double pixelResolution(int zoom) =>
      _converter.earthCircumference / mapSize(zoom);

  @override
  double scaleDenominator(
    int zoom, {
    double screenDpi = 96,
  }) =>
      pixelResolution(zoom) * screenDpi / 0.0254;

  /// The pixel ground resolution in meters at given [latitude] and [zoom].
  double pixelResolutionAt({required double latitude, required int zoom}) =>
      _converter.pixelResolutionAt(latitude, mapSize(zoom));

  /// The map scale denominator at given [latitude], [zoom] and [screenDpi].
  double scaleDenominatorAt({
    required double latitude,
    required int zoom,
    double screenDpi = 96,
  }) =>
      pixelResolutionAt(latitude: latitude, zoom: zoom) * screenDpi / 0.0254;

  /// Returns a tile identified by [quadKey] (as specified by Microsoft).
  ///
  /// Throws `FormatException` if [quadKey] is invalid.
  ///
  /// See also:
  /// https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system
  ScalableXY quadKeyToTile(String quadKey) {
    // zoom level from the quad key length
    final zoomFromKey = quadKey.length;

    // calculate tile coordinates (with origin at top-left)
    var tx = 0;
    var ty = 0;
    for (var zoom = zoomFromKey; zoom > 0; zoom--) {
      final mask = 1 << (zoom - 1);
      switch (quadKey[zoomFromKey - zoom]) {
        case '0':
          break;
        case '1':
          tx |= mask;
          break;
        case '2':
          ty |= mask;
          break;
        case '3':
          tx |= mask;
          ty |= mask;
          break;
        default:
          throw FormatException('The quad key "$quadKey" is invalid.');
      }
    }

    // handle origin variations
    switch (origin) {
      case TileMatrixOrigin.topLeft:
        // nop
        break;
      case TileMatrixOrigin.bottomLeft:
        final size = matrixSize(zoomFromKey);
        ty = (size - 1) - ty;
        break;
    }

    // the result
    return ScalableXY(
      zoom: zoomFromKey,
      x: tx,
      y: ty,
    );
  }

  /// Returns the quad key (as specified by Microsoft) for [tile].
  ///
  /// See also:
  /// https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system
  String tileToQuadKey(ScalableXY tile) {
    // tile x and y
    final tx = tile.x;
    final int ty;

    // handle origin variations
    switch (origin) {
      case TileMatrixOrigin.topLeft:
        ty = tile.y;
        break;
      case TileMatrixOrigin.bottomLeft:
        final size = matrixSize(tile.zoom);
        ty = (size - 1) - tile.y;
        break;
    }

    // calculuate the quad key
    final str = StringBuffer();
    for (var zoom = tile.zoom; zoom > 0; zoom--) {
      var key = 0;
      final mask = 1 << (zoom - 1);
      if ((tx & mask) != 0) {
        key++;
      }
      if ((ty & mask) != 0) {
        key += 2;
      }
      // writes '0', '1', '2' or '3'
      str.writeCharCode(48 + key);
    }
    return str.toString();
  }
}
