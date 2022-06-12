// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/canvas_origin.dart';
import '/src/constants/screen_ppi.dart';
import '/src/coordinates/scalable.dart';
import '/src/tiling/convert/scaled_converter.dart';
import '/src/tiling/tilematrix/base.dart';
import '/src/utils/web_mercator_converter.dart';

const WebMercatorConverter _converterEpsg3857 = WebMercatorConverter.epsg3857();

/// "Web Mercator Quad" tile matrix set.
///
/// More information:
/// https://en.wikipedia.org/wiki/Web_Mercator_projection
/// https://developers.google.com/maps/documentation/javascript/coordinates
/// https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system
@immutable
class WebMercatorQuad extends GeoTileMatrixSet {
  /// Create "Web Mercator Quad" tile matrix set with [tileSize] and [origin].
  ///
  /// Tiles are defined in the WGS 84 / Web Mercator projection ("EPSG:3857")
  /// aka "Pseudo-Mercator" or "Spherical Mercator" or "Google Maps Compatible".
  ///
  /// [OGC Two Dimensional Tile Matrix Set](https://docs.opengeospatial.org/is/17-083r2/17-083r2.html):
  /// "Level 0 allows representing most of the world (limited to latitudes
  /// between approximately ±85 degrees) in a single tile of 256x256 pixels
  /// (Mercator projection cannot cover the whole world because mathematically
  /// the poles are at infinity). The next level represents most of the world
  /// in 2x2 tiles of 256x256 pixels and so on in powers of 2. Mercator
  /// projection distorts the pixel size closer to the poles. The pixel sizes
  /// provided here are only valid next to the equator."
  ///
  /// Normally use 256 or 512 pixels for [tileSize].
  ///
  /// By default [origin] for tiles and pixels is "top-left", for example
  /// a tile (0, 0) is located in the north-west corner of the world map. This
  /// is the notation used by many web map tiled services. You can also set
  /// [origin] to "bottom-left", the notation used by TMS (Tile Map Service)
  /// specification.
  const WebMercatorQuad.epsg3857({
    this.maxZoom = 22,
    this.tileSize = 256,
    this.origin = CanvasOrigin.topLeft,
  })  : assert(maxZoom >= 0, 'Max zoom must be >= 0'),
        assert(tileSize > 0, 'Tile size must be > 0');

  @override
  ScaledConverter get converter => _converterEpsg3857;

  /// The number of tiles at [zoom] (level of detail) in one axis.
  int matrixSize(int zoom) => 1 << zoom;

  /// The number of pixels at [zoom] (level of detail) in one axis.
  int mapSize(int zoom) => tileSize << zoom;

  @override
  final int maxZoom;

  @override
  final int tileSize;

  @override
  final CanvasOrigin origin;

  @override
  int matrixWidth(int zoom) => matrixSize(zoom);

  @override
  int matrixHeight(int zoom) => matrixSize(zoom);

  @override
  int mapWidth(int zoom) => mapSize(zoom);

  @override
  int mapHeight(int zoom) => mapSize(zoom);

  /// The tile ground resolution in meters at [zoom].
  @override
  double tileResolution(int zoom) =>
      _converterEpsg3857.earthCircumference / matrixSize(zoom);

  /// The pixel ground resolution in meters at [zoom].
  @override
  double pixelResolution(int zoom) =>
      _converterEpsg3857.earthCircumference / mapSize(zoom);

  @override
  double scaleDenominator(
    int zoom, {
    double screenPPI = screenPPIbyOGC,
  }) =>
      pixelResolution(zoom) * screenPPI / 0.0254;

  /// The pixel ground resolution in meters at given [latitude] and [zoom].
  double pixelResolutionAt({required double latitude, required int zoom}) =>
      _converterEpsg3857.pixelResolutionAt(latitude, mapSize(zoom));

  /// The map scale denominator at given [latitude], [zoom] and [screenPPI].
  ///
  /// By default [screenPPI] of ~ 90.7 ppi is used (based on a screen pixel of
  /// 0.28 mm defined by OGC). Another common value is 96 ppi.
  double scaleDenominatorAt({
    required double latitude,
    required int zoom,
    double screenPPI = screenPPIbyOGC,
  }) =>
      pixelResolutionAt(latitude: latitude, zoom: zoom) * screenPPI / 0.0254;

  /// Returns a tile identified by [quadKey] (as specified by Microsoft).
  ///
  /// Throws `FormatException` if [quadKey] is invalid.
  ///
  /// See also:
  /// https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system
  Scalable2i quadKeyToTile(String quadKey) {
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
      case CanvasOrigin.topLeft:
        // nop
        break;
      case CanvasOrigin.bottomLeft:
        final size = matrixSize(zoomFromKey);
        ty = (size - 1) - ty;
        break;
    }

    // the result
    return Scalable2i(
      zoom: zoomFromKey,
      x: tx,
      y: ty,
    );
  }

  /// Returns the quad key (as specified by Microsoft) for [tile].
  ///
  /// See also:
  /// https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system
  String tileToQuadKey(Scalable2i tile) {
    // tile x and y
    final tx = tile.x;
    final int ty;

    // handle origin variations
    switch (origin) {
      case CanvasOrigin.topLeft:
        ty = tile.y;
        break;
      case CanvasOrigin.bottomLeft:
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
