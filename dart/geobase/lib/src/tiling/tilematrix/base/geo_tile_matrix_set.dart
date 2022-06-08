// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/geographic.dart';
import '/src/coordinates/projected.dart';
import '/src/coordinates/scalable.dart';

import 'tile_matrix_origin.dart';
import 'tile_matrix_set.dart';

/// A tile matrix set with conversions between tiles and geographic positions.
abstract class GeoTileMatrixSet extends TileMatrixSet {
  /// The tile (longitudal) width in degrees at [zoom].
  double tileWidthLongitudal(int zoom) => 360.0 / matrixWidth(zoom);

  /// The pixel (longitudal) width in degrees at [zoom].
  double pixelWidthLongitudal(int zoom) => 360.0 / mapWidth(zoom);

  @override
  Projected positionToWorld(Geographic position);

  @override
  Scalable2i positionToPixel(Geographic position, {int zoom = 0});

  @override
  Scalable2i positionToTile(Geographic position, {int zoom = 0});

  @override
  Geographic pixelToPosition(Scalable2i pixel) {
    // map size: number of pixels for x and y at the given zoom level
    final width = mapWidth(pixel.zoom);
    final height = mapHeight(pixel.zoom);

    // pixel coordinates
    final px = pixel.x;
    final num py;

    // handle origin variations
    switch (origin) {
      case TileMatrixOrigin.topLeft:
        py = pixel.y;
        break;
      case TileMatrixOrigin.bottomLeft:
        py = (height - 1) - pixel.y;
        break;
    }

    // unproject pixel coordinates to geographic position
    // - pixel range is: 0 .. size-1
    // - this is first approximated to: 0.5 .. size-0.5
    // (where size is either map width or map height)
    // - then unprojected to geographic coordinates
    return Geographic(
      lon: converter.fromMappedX(px + 0.5, width: width),
      lat: converter.fromMappedY(py + 0.5, height: height),
    );
  }

  @override
  GeoBox tileToBounds(Scalable2i tile) {
    // tile coordinates
    final tx = tile.x;
    final int ty;

    // handle origin variations
    switch (origin) {
      case TileMatrixOrigin.topLeft:
        ty = tile.y;
        break;
      case TileMatrixOrigin.bottomLeft:
        ty = (matrixHeight(tile.zoom) - 1) - tile.y;
        break;
    }

    // pixel coordinates
    final pxWest = tx * tileSize;
    final pyNorth = ty * tileSize;

    // map size: number of pixels for x and y at the given zoom level
    final width = mapWidth(tile.zoom);
    final height = mapHeight(tile.zoom);

    // unproject corners of box in pixel coordinates to geographic positions
    return GeoBox(
      west: converter.fromMappedX(pxWest, width: width),
      south: converter.fromMappedY(pyNorth + tileSize, height: height),
      east: converter.fromMappedX(pxWest + tileSize, width: width),
      north: converter.fromMappedY(pyNorth, height: height),
    );
  }
}
