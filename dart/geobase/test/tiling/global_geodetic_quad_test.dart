// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/geobase.dart';
import 'package:test/test.dart';

import '../projections/projection_sample.dart';

const _samples = [
  [
    Geographic(lon: -87.65, lat: 41.85),
    Projected(x: 131.34222222, y: 68.48), // world (x, y)
    Scalable2i(zoom: 1, x: 262, y: 136), // pixel (x, y) at zoom 1
    Scalable2i(zoom: 1, x: 1, y: 0), // tile (x, y) at zoom 1
    GeoBox(west: -90.0, south: 0.0, east: 0.0, north: 90.0), // tile bounds
  ],
  [
    Geographic(lon: 172.34, lat: -23.123),
    Projected(x: 501.1057778, y: 160.8860444), // world (x, y)
    Scalable2i(zoom: 3, x: 4008, y: 1287), // pixel (x, y) at zoom 3
    Scalable2i(zoom: 3, x: 15, y: 5), // tile (x, y) at zoom 3
    GeoBox(west: 157.5, south: -45.0, east: 180.0, north: -22.5), // tile bounds
  ],
];

const _scales256 = [
  // zoom, scale denominator, arc resolution, matrix width, matrix height
  <num>[0, 279541132.0143589, 0.703125000000000, 2, 1],
  <num>[4, 17471320.75089743, 0.0439453125000000, 32, 16],
  <num>[17, 2132.729583849784, 0.00000536441802978516, 262144, 131072],
];

void main() {
  group('Test GlobalGeodeticQuad / World CRS 84', () {
    const crs84 = GlobalGeodeticQuad.worldCrs84();
    test('Compare conversions to reference samples', () {
      for (final sample in _samples) {
        final pos = sample[0] as Geographic;
        final world = sample[1] as Projected;
        final pixel = sample[2] as Scalable2i;
        final tile = sample[3] as Scalable2i;
        final tileBounds = sample[4] as GeoBox;

        expectPosition(crs84.positionToWorld(pos), world, 0.000001);
        expect(crs84.positionToPixel(pos, zoom: pixel.zoom), pixel);
        expect(crs84.positionToTile(pos, zoom: tile.zoom), tile);
        expectPosition(crs84.worldToPosition(world), pos, 0.0000001);
        expect(crs84.worldToPixel(world, zoom: pixel.zoom), pixel);
        expect(crs84.worldToTile(world, zoom: tile.zoom), tile);
        expectPosition(crs84.pixelToPosition(pixel), pos, 0.2);
        expectPosition(crs84.pixelToWorld(pixel), world, 0.3);
        expect(crs84.tileToBounds(tile), tileBounds);
      }
    });

    test('Check sizes, scales and resolutions for 256x256 tiles', () {
      for (final level in _scales256) {
        final zoom = level[0] as int;
        final scale = level[1] as double;
        final res = level[2] as double;
        final matrixWidth = level[3] as int;
        final matrixHeight = level[4] as int;

        expect(crs84.scaleDenominator(zoom), closeTo(scale, 0.000001));
        expect(crs84.pixelArcResolution(zoom), closeTo(res, 0.000001));
        expect(
          crs84
              .zoomFromPixelGroundResolution(crs84.pixelGroundResolution(zoom)),
          closeTo(zoom, 0.000001),
        );
        expect(
          crs84.zoomFromScaleDenominator(crs84.scaleDenominator(zoom)),
          closeTo(zoom, 0.000001),
        );

        expect(crs84.matrixWidth(zoom), matrixWidth);
        expect(crs84.matrixHeight(zoom), matrixHeight);
        expect(crs84.mapWidth(zoom), matrixWidth * crs84.tileSize);
        expect(crs84.mapHeight(zoom), matrixHeight * crs84.tileSize);
      }
    });

    test('Check map bounds', () {
      const expected = GeoBox(
        west: minLongitude,
        south: minLatitude,
        east: maxLongitude,
        north: maxLatitude,
      );
      expect(
        crs84.mapBounds().equals2D(expected),
        true,
      );
    });
  });
}
