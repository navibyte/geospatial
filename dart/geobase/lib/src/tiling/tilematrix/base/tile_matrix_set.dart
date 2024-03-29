// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/codes/canvas_origin.dart';
import '/src/common/constants/screen_ppi.dart';
import '/src/coordinates/base/aligned.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/projected/projected.dart';
import '/src/coordinates/scalable/scalable2i.dart';
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

  /// The groud resolution (in meters) of a tile at [zoom].
  ///
  /// Should equal to `tileSize * pixelGroundResolution(zoom)`.
  ///
  /// This is a nominal resolution that may be accurate only in some positions
  /// like along the equator or a meridian depending on a projection. And it's
  /// possible that in some tile matrix sets the "ground resolution" concept
  /// is not natural at all, then values returned should be considered only as
  /// approximations.
  double tileGroundResolution(int zoom);

  /// The groud resolution (in meters) of a pixel at [zoom].
  ///
  /// Should equal to `tileGroundResolution(zoom) / tileSize`.
  ///
  /// This is a nominal resolution that may be accurate only in some positions
  /// like along the equator or a meridian depending on a projection. And it's
  /// possible that in some tile matrix sets the "ground resolution" concept
  /// is not natural at all, then values returned should be considered only as
  /// approximations.
  double pixelGroundResolution(int zoom);

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

  /// The zoom from pixel ground [resolution] in meters.
  double zoomFromPixelGroundResolution(double resolution);

  /// The zoom from map scale [denominator] at given [screenPPI].
  ///
  /// By default [screenPPI] of ~ 90.7 ppi is used (based on a screen pixel of
  /// 0.28 mm defined by OGC). Another common value is 96 ppi.
  double zoomFromScaleDenominator(
    double denominator, {
    double screenPPI = screenPPIbyOGC,
  });

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
      x: px.clamp(0.0, width).toDouble(),
      y: py.clamp(0.0, height).toDouble(),

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
      x: x.clamp(0.0, width).toDouble(),
      y: y.clamp(0.0, height).toDouble(),
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
      x: tx.clamp(0, matrixWidth(pixel.zoom) - 1),
      y: ty.clamp(0, matrixHeight(pixel.zoom) - 1),
    );
  }

  /// Returns a bounding box with min and max positions for [tile].
  ///
  /// Coordinate value ranges:
  /// - tile x (int): `0 .. matrixWidth(zoom) - 1`
  /// - tile y (int): `0 .. matrixHeight(zoom) - 1`
  Box tileToBounds(Scalable2i tile);

  /// Transforms a fractional point defined by [align] inside [tile] to world
  /// coordinates.
  ///
  /// By default with `Aligned.center` the world coorinates at the center of a
  /// tile are returned.
  ///
  /// Coordinate value ranges:
  /// - tile x (int): `0 .. matrixWidth(zoom) - 1`
  /// - tile y (int): `0 .. matrixHeight(zoom) - 1`
  /// - world x (double): `0.0 .. mapWidth(0)`
  /// - world y (double): `0.0 .. mapHeight(0)`
  Projected tileToWorld(Scalable2i tile, {Aligned align = Aligned.center}) {
    // floating point tile coordinates in a position defined by align x / y
    final tx = tile.x + (1.0 + align.x) / 2.0;
    final double ty;
    switch (origin) {
      case CanvasOrigin.topLeft:
        ty = tile.y - (align.y - 1.0) / 2.0;
        break;
      case CanvasOrigin.bottomLeft:
        ty = tile.y + (1.0 + align.y) / 2.0;
        break;
    }

    // world coordinates size: number of pixels for x and y at the zoom level 0
    final width = mapWidth(0);
    final height = mapHeight(0);

    // map to world coordinates (double values at zoom 0)
    final x = tx / (1 << tile.zoom) * width;
    final y = ty / (1 << tile.zoom) * height;

    return Projected(
      // x and y coordinates projected to world coordinates
      x: x.clamp(0.0, width).toDouble(),
      y: y.clamp(0.0, height).toDouble(),
    );
  }

  /// Transforms a fractional point defined by [align] inside [tile] to a
  /// position.
  ///
  /// By default with `Aligned.center` the position at the center of a tile is
  /// returned.
  ///
  /// Coordinate value ranges:
  /// - tile x (int): `0 .. matrixWidth(zoom) - 1`
  /// - tile y (int): `0 .. matrixHeight(zoom) - 1`
  Position tileToPosition(Scalable2i tile, {Aligned align = Aligned.center});

  /// Transforms a fractional point defined by [align] inside [tile] to pixel
  /// coordinates.
  ///
  /// By default with `Aligned.center` the pixel at the center of a tile is
  /// returned.
  ///
  /// When [requireInside] is true, it's guaranteed that the target pixel is
  /// inside the source tile.
  ///
  /// Coordinate value ranges:
  /// - tile x (int): `0 .. matrixWidth(zoom) - 1`
  /// - tile y (int): `0 .. matrixHeight(zoom) - 1`
  /// - pixel x (int): `0 .. mapWidth(zoom) - 1`
  /// - pixel y (int): `0 .. mapHeight(zoom) - 1`
  Scalable2i tileToPixel(
    Scalable2i tile, {
    Aligned align = Aligned.center,
    bool requireInside = false,
  }) {
    // optionally clamp align values to range [-1.0, 1.0]
    final alignX = requireInside ? align.x.clamp(-1.0, 1.0) : align.x;
    final alignY = requireInside ? align.y.clamp(-1.0, 1.0) : align.y;

    // floating point tile coordinates in a position defined by align x / y
    final tx = tile.x + (1.0 + alignX) / 2.0;
    final double ty;
    switch (origin) {
      case CanvasOrigin.topLeft:
        ty = tile.y - (alignY - 1.0) / 2.0;
        break;
      case CanvasOrigin.bottomLeft:
        ty = tile.y + (1.0 + alignY) / 2.0;
        break;
    }

    // from tile to pixel coordinates
    final px = (tx * tileSize).floor();
    final py = (ty * tileSize).floor();

    if (requireInside) {
      // ensure target pixel is inside source tile
      final px0 = tile.x * tileSize;
      final py0 = tile.y * tileSize;
      return Scalable2i(
        zoom: tile.zoom,
        x: px.clamp(px0, px0 + tileSize - 1),
        y: py.clamp(py0, py0 + tileSize - 1),
      );
    } else {
      // target pixel with align value 1.0 or more could be inside "next" tiles
      // (clamp returned pixels by map size)
      return Scalable2i(
        zoom: tile.zoom,
        x: px.clamp(0, mapWidth(tile.zoom) - 1),
        y: py.clamp(0, mapHeight(tile.zoom) - 1),
      );
    }
  }

  /// Returns a bounding box with min and max positions for the whole map.
  Box mapBounds();
}
