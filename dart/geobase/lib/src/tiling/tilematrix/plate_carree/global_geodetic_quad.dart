// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/constants/geodetic.dart';
import '/src/constants/screen_ppi.dart';
import '/src/tiling/convert/scaled_converter.dart';
import '/src/tiling/tilematrix/base.dart';

/// "Global Geodetic Quad" tile matrix set ("World CRS84 Quad" for WGS 84).
///
/// More information:
/// https://docs.opengeospatial.org/is/17-083r2/17-083r2.html
@immutable
class GlobalGeodeticQuad extends GeoTileMatrixSet {
  /// "World CRS84 Quad" (WGS 84) tile matrix set with [tileSize] and [origin].
  ///
  /// Tiles are defined in the Equirectangular Plate Carrée projection in the
  /// CRS84 coordinate reference system (longitude, latitude) for the whole
  /// world. At the zoom level 0 the world is covered by two tiles (tile matrix
  /// width is 2 and matrix height is 1). The western tile (x=0, y=0) is for the
  /// negative longitudes and the eastern tile (x=1, y=0) for the positive
  /// longitudes.
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
    this.origin = TileMatrixOrigin.topLeft,
  })  : assert(maxZoom >= 0, 'Max zoom must be >= 0'),
        assert(tileSize > 0, 'Tile size must be > 0');

  @override
  ScaledConverter get converter => _converter;

  @override
  final int maxZoom;

  @override
  final int tileSize;

  @override
  final TileMatrixOrigin origin;

  @override
  int matrixWidth(int zoom) => 2 << zoom;

  @override
  int matrixHeight(int zoom) => 1 << zoom;

  @override
  int mapWidth(int zoom) => (2 * tileSize) << zoom;

  @override
  int mapHeight(int zoom) => tileSize << zoom;

  /// The tile arc resolution in degrees at [zoom].
  @override
  double tileResolution(int zoom) => 360 / matrixWidth(zoom);

  /// The pixel arc resolution in degrees at [zoom].
  @override
  double pixelResolution(int zoom) => 360 / mapWidth(zoom);

  @override
  double scaleDenominator(
    int zoom, {
    double screenPPI = screenPPIbyOGC,
  }) {
    // calculations here aligned to get same scale denominators as specified by
    // by https://docs.opengeospatial.org/is/17-083r2/17-083r2.html
    return earthCircumferenceWgs84 / mapWidth(zoom) * screenPPI / 0.0254;
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
