// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/canvas_origin.dart';
import '/src/constants/screen_ppi.dart';
import '/src/coordinates/base.dart';
import '/src/coordinates/projected.dart';
import '/src/coordinates/scalable.dart';
import '/src/tiling/convert/scaled_converter.dart';

/// A tiling scheme represented as a set of tile matrices (grids).
abstract class TileMatrixSet {
  /// Default `const` constructor to allow extending this abstract class.
  const TileMatrixSet();

  /// The maximum (suggested) zoom level for this tile matrix set.
  ///
  /// Note that some methods may allow larger zoom values when zoom value is
  /// given as an argument.
  int get maxZoom;

  /// The number of pixels for one tile in one axis (normally 256 or 512).
  int get tileSize;

  /// The position of the origin in a tile matrix and map pixel "canvas".
  CanvasOrigin get origin;

  /// The number of tiles ("matrix width") at [zoom] in the X axis.
  int matrixWidth(int zoom);

  /// The number of tiles ("matrix height") at [zoom] in the Y axis.
  int matrixHeight(int zoom);

  /// The number of pixels ("map width") at [zoom] in the X axis.
  int mapWidth(int zoom);

  /// The number of pixels ("map height") at [zoom] in the Y axis.
  int mapHeight(int zoom);

  /// The tile resolution (often ground resolution in meters) at [zoom].
  ///
  /// Should equal to `tileSize * pixelResolution(zoom)`.
  ///
  /// This is a nominal resolution that may be accurate only in some positions
  /// like along the equator or a meridian depending on a projection.
  double tileResolution(int zoom);

  /// The pixel resolution (often ground resolution in meters) at [zoom].
  ///
  /// Should equal to `tileResolution(zoom) / tileSize`.
  ///
  /// This is a nominal resolution that may be accurate only in some positions
  /// like along the equator or a meridian depending on a projection.
  double pixelResolution(int zoom);

  /// The map scale denominator at [zoom] and [screenPPI].
  ///
  /// This is a nominal scale denominator that may be accurate only in some
  /// positions like along the equator or a meridian depending on a projection.
  ///
  /// By default [screenPPI] of ~ 90.7 ppi is used (based on a screen pixel of
  /// 0.28 mm defined by OGC). Another common value is 96 ppi.
  double scaleDenominator(
    int zoom, {
    double screenPPI = screenPPIbyOGC,
  });

/* 
  // analyze need...

  /// The maximum scaledown zoom with the pixel size closest to [resolution].
  int zoomForPixelResolution(double resolution) {
    for (var zoom = 0; zoom <= maxZoom; zoom++) {
      if (resolution > pixelResolution(zoom)) {
        return zoom == 0 ? 0 : zoom - 1;
      }
    }
    return maxZoom;
  }

  /// The maximum scaledown zoom with the scale closest to 1 : [denominator].
  int zoomForScaleDenominator(double denominator) {
    for (var zoom = 0; zoom <= maxZoom; zoom++) {
      if (denominator > scaleDenominator(zoom)) {
        return zoom == 0 ? 0 : zoom - 1;
      }
    }
    return maxZoom;
  }
*/

  /// A map converter between geospatial positions and map coordinates.
  ScaledConverter get converter;

  /// Transforms [position] to world coordinates.
  ///
  /// Coordinate value ranges:
  /// - world x (double): `0.0 .. mapWidth(0)`
  /// - world y (double): `0.0 .. mapHeight(0)`
  Projected positionToWorld(covariant Position position) {
    // world coordinates size: number of pixels for x and y at the zoom level 0
    final width = mapWidth(0);
    final height = mapHeight(0);

    // project (geographic or projected) position to pixel coordinates
    final px = converter.toScaledX(position.x, width: width);
    var py = converter.toScaledY(position.y, height: height);

    // handle origin variations
    switch (origin) {
      case CanvasOrigin.topLeft:
        // nop
        break;
      case CanvasOrigin.bottomLeft:
        py = height - py;
        break;
    }

    return Projected(
      // x and y coordinates projected to world coordinates
      x: px.clamp(0.0, width),
      y: py.clamp(0.0, height),

      // optional z and m are copied
      z: position.optZ,
      m: position.optM,
    );
  }

  /// Transforms [position] to pixel coordinates at [zoom].
  ///
  /// Coordinate value ranges:
  /// - pixel x (int): `0 .. mapWidth(zoom) - 1`
  /// - pixel y (int): `0 .. mapHeight(zoom) - 1`
  Scalable2i positionToPixel(covariant Position position, {int zoom = 0}) {
    // map size: number of pixels for x and y at the given zoom level
    final width = mapWidth(zoom);
    final height = mapHeight(zoom);

    // project (geographic or projected) position to pixel coordinates
    final px = converter
        .toScaledX(position.x, width: width)
        .floor()
        .clamp(0, width - 1);
    var py = converter
        .toScaledY(position.y, height: height)
        .floor()
        .clamp(0, height - 1);

    // handle origin variations
    switch (origin) {
      case CanvasOrigin.topLeft:
        // nop
        break;
      case CanvasOrigin.bottomLeft:
        py = (height - 1) - py;
        break;
    }

    return Scalable2i(
      zoom: zoom,
      x: px,
      y: py,
    );
  }

  /// Returns a tile at [zoom] covering a region in [position].
  ///
  /// Coordinate value ranges:
  /// - tile x (int): `0 .. matrixWidth(zoom) - 1`
  /// - tile y (int): `0 .. matrixHeight(zoom) - 1`
  Scalable2i positionToTile(covariant Position position, {int zoom = 0}) {
    // matrix size: number of tiles for x and y at the given zoom level
    final width = matrixWidth(zoom);
    final height = matrixHeight(zoom);

    // project (geographic or projected) position to tile coordinates
    final tx = converter
        .toScaledX(position.x, width: width)
        .floor()
        .clamp(0, width - 1);
    var ty = converter
        .toScaledY(position.y, height: height)
        .floor()
        .clamp(0, height - 1);

    // handle origin variations
    switch (origin) {
      case CanvasOrigin.topLeft:
        // nop
        break;
      case CanvasOrigin.bottomLeft:
        ty = (height - 1) - ty;
        break;
    }

    // handle origin variations and return result
    return Scalable2i(
      zoom: zoom,
      x: tx,
      y: ty,
    );
  }

  /// Transforms [world] coordinates to a position.
  ///
  /// Coordinate value ranges:
  /// - world x (double): `0.0 .. mapWidth(0)`
  /// - world y (double): `0.0 .. mapHeight(0)`
  Position worldToPosition(Projected world);

  /// Transforms [world] coordinates to pixel coordinates at [zoom].
  ///
  /// Coordinate value ranges:
  /// - world x (double): `0.0 .. mapWidth(0)`
  /// - world y (double): `0.0 .. mapHeight(0)`
  /// - pixel x (int): `0 .. mapWidth(zoom) - 1`
  /// - pixel y (int): `0 .. mapHeight(zoom) - 1`
  Scalable2i worldToPixel(Projected world, {int zoom = 0}) {
    final scale = 1 << zoom;
    return Scalable2i(
      zoom: zoom,
      x: (world.x * scale).floor().clamp(0, mapWidth(zoom) - 1),
      y: (world.y * scale).floor().clamp(0, mapHeight(zoom) - 1),
    );
  }

  /// Returns a tile at [zoom] covering a region in [world] coordinates.
  ///
  /// Coordinate value ranges:
  /// - world x (double): `0.0 .. mapWidth(0)`
  /// - world y (double): `0.0 .. mapHeight(0)`
  /// - tile x (int): `0 .. matrixWidth(zoom) - 1`
  /// - tile y (int): `0 .. matrixHeight(zoom) - 1`
  Scalable2i worldToTile(Projected world, {int zoom = 0}) {
    final scale = (1 << zoom) / tileSize;
    return Scalable2i(
      zoom: zoom,
      x: (world.x * scale).floor().clamp(0, matrixWidth(zoom) - 1),
      y: (world.y * scale).floor().clamp(0, matrixHeight(zoom) - 1),
    );
  }

  /// Transforms [pixel] coordinates to world coordinates.
  ///
  /// Coordinate value ranges:
  /// - pixel x (int): `0 .. mapWidth(zoom) - 1`
  /// - pixel y (int): `0 .. mapHeight(zoom) - 1`
  /// - world x (double): `0.0 .. mapWidth(0)`
  /// - world y (double): `0.0 .. mapHeight(0)`
  Projected pixelToWorld(Scalable2i pixel) {
    // convert pixel coordinates to world coordinates
    // - pixel range is: 0 .. size-1 (integer)
    // - this is first approximated to: 0.5 .. size-0.5
    // (where size is either map width or map height)
    // - then mapped to world coordinates (double values at zoom 0)
    final x = (pixel.x + 0.5) / (1 << pixel.zoom);
    final y = (pixel.y + 0.5) / (1 << pixel.zoom);

    // world coordinates size: number of pixels for x and y at the zoom level 0
    final width = mapWidth(0);
    final height = mapHeight(0);

    return Projected(
      // x and y coordinates projected to world coordinates
      x: x.clamp(0.0, width),
      y: y.clamp(0.0, height),
    );
  }

  /// Transforms [pixel] coordinates to a position.
  ///
  /// Coordinate value ranges:
  /// - pixel x (int): `0 .. mapWidth(zoom) - 1`
  /// - pixel y (int): `0 .. mapHeight(zoom) - 1`
  Position pixelToPosition(Scalable2i pixel);

  /// Returns a tile covering a region in [pixel] coordinates.
  ///
  /// Coordinate value ranges:
  /// - pixel x (int): `0 .. mapWidth(zoom) - 1`
  /// - pixel y (int): `0 .. mapHeight(zoom) - 1`
  /// - tile x (int): `0 .. matrixWidth(zoom) - 1`
  /// - tile y (int): `0 .. matrixHeight(zoom) - 1`
  Scalable2i pixelToTile(Scalable2i pixel) {
    // from pixel to tile coordinates
    final tx = (pixel.x / tileSize).floor();
    final ty = (pixel.y / tileSize).floor();

    // return result
    return Scalable2i(
      zoom: pixel.zoom,
      x: tx,
      y: ty,
    );
  }

  /// Returns a bounding box with min and max positions for [tile].
  ///
  /// Coordinate value ranges:
  /// - tile x (int): `0 .. matrixWidth(zoom) - 1`
  /// - tile y (int): `0 .. matrixHeight(zoom) - 1`
  Box tileToBounds(Scalable2i tile);

  /// Returns a bounding box with min and max positions for the whole map.
  Box mapBounds();
}
