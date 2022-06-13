// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/canvas_origin.dart';
import '/src/constants/geodetic.dart';
import '/src/constants/screen_ppi.dart';
import '/src/tiling/convert/scaled_converter.dart';
import '/src/tiling/tilematrix/base.dart';

/// "Global Geodetic Quad" tile matrix set ("World CRS84 Quad" for WGS 84).
///
/// Tiles are defined in the Equirectangular Plate Carrée projection in the
/// CRS84 coordinate reference system (longitude, latitude) for the whole
/// world. At the zoom level 0 the world is covered by two tiles (tile matrix
/// width is 2 and matrix height is 1). The western tile (x=0, y=0) is for the
/// negative longitudes and the eastern tile (x=1, y=0) for the positive
/// longitudes.
///
/// Using "Global Geodetic Quad" involves following coordinates:
/// * *position*: geographic coordinates (longitude, latitude)
/// * *world*: a position scaled to the pixel space of the map at level 0
/// * *pixel*: pixel coordinates (x, y) in the pixel space of the map at zoom
/// * *tile*: tile coordinates (x, y) in the tile matrix at zoom
///
/// Coordinate value ranges for the world covered by the tile matrix set (when
/// tile size is 256 pixels):
/// * position / longitude: (-180.0°, 180.0°)
/// * position / latitude: (-90.0°, 90.0°)
/// * world / x: (0.0, 512.0)
/// * world / y: (0.0, 256.0)
/// * pixel at level 0 / x: (0, 511)
/// * pixel at level 0 / y: (0, 255)
/// * pixel at level 2 / x: (0, 2047)
/// * pixel at level 2 / y: (0, 1023)
/// * tile at level 0 / x: (0, 1)
/// * tile at level 0 / y: (0, 0)
/// * tile at level 2 / x: (0, 7)
/// * tile at level 2 / y: (0, 3)
///
/// Tile coordinates at level 0 (two tiles covering the whole world):
///
/// -------------
/// | 0,0 | 1,0 |
/// -------------
///
/// Tile coordinates at level 1 (tile matrix width is 4 and height is 2):
///
/// -------------------------
/// | 0,0 | 1,0 | 2,0 | 3,0 |
/// -------------------------
/// | 0,1 | 1,1 | 2,1 | 3,1 |
/// -------------------------
///
/// Tile coordinates at level 2 (tile matrix width is 8 and height is 4):
///
/// -------------------------------------------------
/// | 0,0 | 1,0 | 2,0 | 3,0 | 4,0 | 5,0 | 6,0 | 7,0 |
/// -------------------------------------------------
/// | 0,1 | 1,1 | 2,1 | 3,1 | 4,1 | 5,1 | 6,1 | 7,1 |
/// -------------------------------------------------
/// | 0,2 | 1,2 | 2,2 | 3,2 | 4,2 | 5,2 | 6,2 | 7,2 |
/// -------------------------------------------------
/// | 0,3 | 1,3 | 2,3 | 3,3 | 4,3 | 5,3 | 6,3 | 7,3 |
/// -------------------------------------------------
///
/// Each tile contains 256 x 256 pixels when the tile size is 256. As for level
/// 2 there are 8 x 4 tiles, then the map canvas size is 2048 x 1024 pixels for
/// that level. If the tile size is 512, then the map canvas size is 4096 x 2048
/// pixels.
///
/// Examples above uses "top-left" origin for world, pixel and tile coordinates.
/// If "bottom-left" origin is used then y coordinates must be flipped, for
/// example zoom level 1:
///
/// -------------------------
/// | 0,1 | 1,1 | 2,1 | 3,1 |
/// -------------------------
/// | 0,0 | 1,0 | 2,0 | 3,0 |
/// -------------------------
///
/// More information:
/// https://docs.opengeospatial.org/is/17-083r2/17-083r2.html
@immutable
class GlobalGeodeticQuad extends GeoTileMatrixSet {
  /// "World CRS84 Quad" (WGS 84) tile matrix set with [tileSize] and [origin].
  ///
  /// Normally use 256 or 512 pixels for [tileSize].
  ///
  /// By default [origin] for tiles and pixels is "top-left", for example
  /// a tile (0, 0) is located in the north-west corner of the world map. This
  /// is the notation used by many web map tiled services. You can also set
  /// [origin] to "bottom-left", the notation used by TMS (Tile Map Service)
  /// specification.
  const GlobalGeodeticQuad.worldCrs84({
    this.maxZoom = 22,
    this.tileSize = 256,
    this.origin = CanvasOrigin.topLeft,
  })  : assert(maxZoom >= 0, 'Max zoom must be >= 0'),
        assert(tileSize > 0, 'Tile size must be > 0');

  @override
  ScaledConverter get converter => _converter;

  @override
  final int maxZoom;

  @override
  final int tileSize;

  @override
  final CanvasOrigin origin;

  @override
  int matrixWidth(int zoom) => 2 << zoom;

  @override
  int matrixHeight(int zoom) => 1 << zoom;

  @override
  int mapWidth(int zoom) => (2 * tileSize) << zoom;

  @override
  int mapHeight(int zoom) => tileSize << zoom;

  @override
  double tileGroundResolution(int zoom) =>
      earthCircumferenceWgs84 / matrixWidth(zoom); // approximate ground res

  @override
  double pixelGroundResolution(int zoom) =>
      earthCircumferenceWgs84 / mapWidth(zoom); // approximate ground resolution

  @override
  double scaleDenominator(
    int zoom, {
    double screenPPI = screenPPIbyOGC,
  }) {
    // calculations here aligned to get same scale denominators as specified by
    // by https://docs.opengeospatial.org/is/17-083r2/17-083r2.html
    return pixelGroundResolution(zoom) * screenPPI / 0.0254;
  }
}

const _PlateCarreeConverter _converter = _PlateCarreeConverter();

class _PlateCarreeConverter implements ScaledConverter {
  const _PlateCarreeConverter();

  /// Clamps [latitude] to allowed range, here -90 .. 90.
  num clampLatitude(num latitude) => latitude.clamp(-90, 90);

  /// Clamps [longitude] to allowed range, here -180.0 .. 180.0.
  num clampLongitude(num longitude) => longitude.clamp(-180, 180);

  /// Converts geographic [longitude] to x coordinate with range (0, [width]).
  ///
  /// X origin at the anti-meridian (lon: -180), X axis from west to east.
  @override
  double toScaledX(num longitude, {num width = 512}) {
    final lon = clampLongitude(longitude);
    return (0.5 + lon / 360.0) * width;
  }

  /// Converts geographic [latitude] to y coordinate with range (0, [height]).
  ///
  /// Y origin at the north pole (lat: 90.0), Y from north to south.
  @override
  double toScaledY(num latitude, {num height = 256}) {
    final lat = clampLatitude(latitude);
    return (0.5 - lat / 180.0) * height;
  }

  /// Converts [x] coordinate with range (0, [width]) to geographic longitude.
  ///
  /// X origin at the anti-meridian (lon: -180), X axis from west to east.
  @override
  double fromScaledX(num x, {num width = 512}) {
    final xc = x.clamp(0, width);
    return ((xc / width) - 0.5) * 360;
  }

  /// Converts [y] coordinate with range (0, [height]) to geographic latitude.
  ///
  /// Y origin at the north pole (lat: 90.0), Y from north to south.
  @override
  double fromScaledY(num y, {num height = 256}) {
    final yc = y.clamp(0, height);
    return (0.5 - (yc / height)) * 180;
  }
}
