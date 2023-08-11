// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/canvas_origin.dart';
import '/src/coordinates/base/aligned.dart';
import '/src/coordinates/geographic/geobox.dart';
import '/src/coordinates/geographic/geographic.dart';
import '/src/coordinates/projected/projected.dart';
import '/src/coordinates/scalable/scalable2i.dart';

import 'tile_matrix_set.dart';

/// A tile matrix set with conversions between tiles and geographic positions.
abstract class GeoTileMatrixSet extends TileMatrixSet {
  /// Default `const` constructor to allow extending this abstract class.
  const GeoTileMatrixSet();

  /// The arc resolution (longitudal) of a tile in degrees at [zoom].
  ///
  /// Should equal to `pixelArcResolution(zoom) * tileSize`.
  ///
  /// This is a nominal resolution that may be accurate only in some positions
  /// like along the equator or a meridian depending on a projection.
  double tileArcResolution(int zoom) => 360.0 / matrixWidth(zoom);

  /// The arc resolution (longitudal) of a pixel in degrees at [zoom].
  ///
  /// Should equal to `tileArcResolution(zoom) / tileSize`.
  ///
  /// This is a nominal resolution that may be accurate only in some positions
  /// like along the equator or a meridian depending on a projection.
  double pixelArcResolution(int zoom) => 360.0 / mapWidth(zoom);

  @override
  Projected positionToWorld(Geographic position);

  @override
  Scalable2i positionToPixel(Geographic position, {int zoom = 0});

  @override
  Scalable2i positionToTile(Geographic position, {int zoom = 0});

  @override
  Geographic worldToPosition(Projected world) {
    // world coordinates size: number of pixels for x and y at the zoom level 0
    final width = mapWidth(0);
    final height = mapHeight(0);

    // world coordinates
    final px = world.x;
    final num py;

    // handle origin variations
    switch (origin) {
      case CanvasOrigin.topLeft:
        py = world.y;
        break;
      case CanvasOrigin.bottomLeft:
        py = height - world.y;
        break;
    }

    // unproject world coordinates to geographic position
    return Geographic(
      lon: converter.fromScaledX(px, width: width),
      lat: converter.fromScaledY(py, height: height),

      // optional z and m are copied
      elev: world.optZ,
      m: world.optM,
    );
  }

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
      case CanvasOrigin.topLeft:
        py = pixel.y;
        break;
      case CanvasOrigin.bottomLeft:
        py = (height - 1) - pixel.y;
        break;
    }

    // unproject pixel coordinates to geographic position
    // - pixel range is: 0 .. size-1
    // - this is first approximated to: 0.5 .. size-0.5
    // (where size is either map width or map height)
    // - then unprojected to geographic coordinates
    return Geographic(
      lon: converter.fromScaledX(px + 0.5, width: width),
      lat: converter.fromScaledY(py + 0.5, height: height),
    );
  }

  @override
  GeoBox tileToBounds(Scalable2i tile) {
    // tile coordinates
    final tx = tile.x;
    final int ty;

    // handle origin variations
    switch (origin) {
      case CanvasOrigin.topLeft:
        ty = tile.y;
        break;
      case CanvasOrigin.bottomLeft:
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
      west: converter.fromScaledX(pxWest, width: width),
      south: converter.fromScaledY(pyNorth + tileSize, height: height),
      east: converter.fromScaledX(pxWest + tileSize, width: width),
      north: converter.fromScaledY(pyNorth, height: height),
    );
  }

  @override
  Geographic tileToPosition(Scalable2i tile, {Aligned align = Aligned.center}) {
    final world = tileToWorld(tile, align: align);
    return worldToPosition(world);
  }

  @override
  GeoBox mapBounds() {
    // map size: number of pixels for x and y at the zoom 0
    final width = mapWidth(0);
    final height = mapHeight(0);

    // unproject corners of box in pixel coordinates to geographic positions
    return GeoBox(
      west: converter.fromScaledX(0.0, width: width),
      south: converter.fromScaledY(height, height: height),
      east: converter.fromScaledX(width, width: width),
      north: converter.fromScaledY(0.0, height: height),
    );
  }
}
