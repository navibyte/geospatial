// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_redundant_argument_values, avoid_print

import 'dart:math' as math;

import 'package:geobase/geobase.dart';
import 'package:test/test.dart';

import '../projections/projection_sample.dart';

import 'tiling_samples.dart';

const _samples = [
  Geographic(lon: 0.0, lat: 0.0),
  Geographic(lon: -87.65, lat: 41.85),
  Geographic(lon: -180.0, lat: -85.05112878),
  Geographic(lon: -180.0, lat: 85.05112878),
  Geographic(lon: 179.9999999, lat: -85.05112878),
  Geographic(lon: 179.9999999, lat: 85.05112878),
  Geographic(lon: 180.0, lat: 83.42),
  Geographic(lon: 185.0, lat: -51.764223),
  Geographic(lon: -185.0, lat: 23.458),
];

const _scales256 = [
  // see https://docs.opengeospatial.org/is/17-083r2/17-083r2.html

  // zoom, matrix size, map size, resolution, scale denominator, tile lon width
  <num>[1, 2, 512, 78271.51696402048, 279541132.014358, 180.0],
  <num>[2, 4, 1024, 39135.75848201023, 139770566.007179, 90.0],
  <num>[6, 64, 16384, 2445.984905125640, 8735660.37544871, 5.625],
  <num>[10, 1024, 262144, 152.8740565703525, 545978.773465544, 0.3515625],
  <num>[15, 32768, 8388608, 4.777314267823516, 17061.8366707982, 0.01098632813],
  <num>[19, 524288, 134217728, 0.29858214117, 1066.36479192489, 45 / 65536],
  <num>[23, 8388608, 2147483648, 0.01866138386, 66.6477994953056, 45 / 1048576],
];

const _scales512 = [
  // zoom, matrix size, map size, res (lat 0), res (20), res (40), res (60)
  <num>[1, 2, 1024, 39135.742, 36775.568, 29979.718, 19567.871],
  <num>[6, 64, 32768, 1222.992, 1149.237, 936.866, 611.496],
];

const _bounds = [
  // zoom, tile x, tile y, tms y, west, south, east, north
  <num>[1, 0, 1, 0, -179.999997, -85.051129, 0.0, 0.0],
  <num>[4, 8, 5, 10, 0.0, 40.979897, 22.500004, 55.776575],
  <num>[7, 90, 64, 63, 73.125002, -2.811371, 75.937502, 0.0],
  <num>[8, 186, 146, 109, 81.562500, -25.799894, 82.968750, -24.527138],
  <num>[
    18,
    161172,
    142416,
    119727,
    41.337433,
    -15.391458,
    41.338807,
    -15.390133,
  ]
];

const _quadkeys = [
  // zoom, tile x, tile y, quad key
  [0, 0, 0, ''],
  [1, 0, 0, '0'],
  [1, 1, 0, '1'],
  [1, 0, 1, '2'],
  [1, 1, 1, '3'],
  [3, 0, 7, '222'],
  [3, 3, 4, '211'],
  [3, 5, 1, '103'],
];

/*

*/

void main() {
  group('Basic tiling scheme tests', () {
    test('Test Scalable2i coordinates', () {
      const ref = Scalable2i(zoom: 9, x: 23, y: 11);
      expect(Scalable2i.fromCoords(const [9, 23, 11]), ref);
      expect(Scalable2i.fromText('9;23;11', delimiter: ';'), ref);
      expect(Scalable2i.factory(zoom: 9).call(x: 23, y: 11), ref);
    });
  });

  group('Test WebMercatorQuad', () {
    const webMercator = WebMercatorQuad.epsg3857();
    const tmsMercator = WebMercatorQuad.epsg3857(
      origin: CanvasOrigin.bottomLeft,
    );
    const tile512Mercator = WebMercatorQuad.epsg3857(
      tileSize: 512,
    );
    test('Compare conversions to reference sample tests', () {
      for (final pos in _samples) {
        final world = webMercator.positionToWorld(pos);
        expectPosition(
          world,
          _refToWorld(pos, 0),
          0.0, // as tolerance
        );
        for (var zoom = 0; zoom <= 25; zoom++) {
          // geographic position to pixel
          final pixel = webMercator.positionToPixel(pos, zoom: zoom);
          final pixelRef = _refToPixel(pos, zoom);
          expectScaled2i(
            pixel,
            pixelRef,
          );

          // calculated pixel back to geographic position (not accurate anymore)
          final unprojectedPos = webMercator.pixelToPosition(pixel);
          expectPosition(
            unprojectedPos,
            pos,
            webMercator.pixelWidthLongitudal(zoom), // as tolerance
          );

          // and again to pixel
          final pixel2 =
              webMercator.positionToPixel(unprojectedPos, zoom: zoom);
          expectScaled2i(pixel2, pixelRef);

          // geographic position to tile
          final tile = webMercator.positionToTile(pos, zoom: zoom);
          final tileRef = _refToTile(pos, zoom);
          expectScaled2i(tile, tileRef);

          // pixel to tile
          expectScaled2i(webMercator.pixelToTile(pixel), tileRef);

          // world to pixel
          final pixel3 = webMercator.worldToPixel(world, zoom: zoom);
          expectScaled2i(
            pixel3,
            pixelRef,
          );

          // pixel to world
          expectPosition(webMercator.pixelToWorld(pixel), world, 0.5);
          expectPosition(webMercator.pixelToWorld(pixel2), world, 0.5);
          expectPosition(webMercator.pixelToWorld(pixel3), world, 0.5);

          // world to tile
          expectScaled2i(webMercator.worldToTile(world, zoom: zoom), tileRef);
        }
      }
    });

    test('Check sizes, scales and resolutions for 256x256 tiles', () {
      for (final level in _scales256) {
        final zoom = level[0] as int;
        final matrixSize = level[1] as int;
        final mapSize = level[2] as int;
        final res = level[3] as double;
        final scale = level[4] as double;
        final tileLon = level[5] as double;

        expect(webMercator.matrixSize(zoom), matrixSize);
        expect(webMercator.mapSize(zoom), mapSize);
        expect(webMercator.pixelResolution(zoom), closeTo(res, 0.000001));
        expect(webMercator.scaleDenominator(zoom), closeTo(scale, 0.000001));
        if (!tileLon.isNaN) {
          expect(
            webMercator.tileWidthLongitudal(zoom),
            closeTo(tileLon, 0.000001),
          );
        }
      }
    });

    test('Check sizes, scales and resolutions for 512x512 tiles', () {
      for (final level in _scales512) {
        final zoom = level[0] as int;
        final matrixSize = level[1] as int;
        final mapSize = level[2] as int;
        final res0 = level[3] as double;
        final res20 = level[4] as double;
        final res40 = level[5] as double;
        final res60 = level[6] as double;

        expect(tile512Mercator.matrixSize(zoom), matrixSize);
        expect(tile512Mercator.mapSize(zoom), mapSize);
        expect(tile512Mercator.pixelResolution(zoom), closeTo(res0, 0.02));
        expect(
          tile512Mercator.pixelResolutionAt(latitude: 20, zoom: zoom),
          closeTo(res20, 0.02),
        );
        expect(
          tile512Mercator.pixelResolutionAt(latitude: -40, zoom: zoom),
          closeTo(res40, 0.02),
        );
        expect(
          tile512Mercator.pixelResolutionAt(latitude: 60, zoom: zoom),
          closeTo(res60, 0.02),
        );
      }
    });

    test('Test tile bounds', () {
      for (final tileTest in _bounds) {
        final zoom = tileTest[0] as int;
        final tileX = tileTest[1] as int;
        final tileY = tileTest[2] as int;
        final tmsY = tileTest[3] as int;
        final west = tileTest[4] as double;
        final south = tileTest[5] as double;
        final east = tileTest[6] as double;
        final north = tileTest[7] as double;

        // expected bounds
        final bounds =
            GeoBox(west: west, south: south, east: east, north: north);
        //print(bounds);

        // calculate tile bounds (top-left tile matrix)
        final tile1 = Scalable2i(zoom: zoom, x: tileX, y: tileY);
        final tileBounds1 = webMercator.tileToBounds(tile1);
        //print(tileBounds1);
        expect(tileBounds1.equals2D(bounds, toleranceHoriz: 0.002), true);

        // calculate tile bounds (bottom-left tile matrix)
        final tile2 = Scalable2i(zoom: zoom, x: tileX, y: tmsY);
        final tileBounds2 = tmsMercator.tileToBounds(tile2);
        //print(tileBounds2);
        expect(tileBounds2.equals2D(bounds, toleranceHoriz: 0.002), true);
      }
    });

    test('Check map bounds', () {
      const expected = GeoBox(
        west: minLongitude,
        south: minLatitudeWebMercator,
        east: maxLongitude,
        north: maxLatitudeWebMercator,
      );
      expect(
        webMercator.mapBounds().equals2D(expected, toleranceHoriz: 0.000000001),
        true,
      );
      expect(
        tmsMercator.mapBounds().equals2D(expected, toleranceHoriz: 0.000000001),
        true,
      );
      expect(
        tile512Mercator
            .mapBounds()
            .equals2D(expected, toleranceHoriz: 0.000000001),
        true,
      );
    });

    test('Test quad key', () {
      for (final quadTest in _quadkeys) {
        final zoom = quadTest[0] as int;
        final tileX = quadTest[1] as int;
        final tileY = quadTest[2] as int;
        final quadKey = quadTest[3] as String;

        final tile = Scalable2i(zoom: zoom, x: tileX, y: tileY);
        expect(webMercator.tileToQuadKey(tile), quadKey);

        final tileFromQuadkey = webMercator.quadKeyToTile(quadKey);
        expect(tile, tileFromQuadkey);
      }
    });
  });

  /*
  group('Measure WebMercatorQuad', () {
    final webMercator = WebMercatorQuad.epsg3857();
    test('Compare geographic to world', () {
      for (final pos in _samples) {
        final world1 = webMercator.positionToWorld(pos);
        final world2 = _refToWorld(pos, 0);
        final xdiff = (world1.x - world2.x).abs();
        final ydiff = (world1.y - world2.y).abs();
        print('$xdiff $ydiff ($pos $world1)');
      }
    });
  });
  */
}

// -----------------------------------------------------------------------------
// A reference test sample from
// https://developers.google.com/maps/documentation/javascript/examples/map-coordinates

Projected _refToWorld(Geographic position, int zoom) {
  final world = _refProject(position);
  return Projected(x: world[0], y: world[1]);
}

Scalable2i _refToPixel(Geographic position, int zoom) {
  final world = _refProject(position);
  final scale = 1 << zoom;
  return Scalable2i(
    zoom: zoom,
    x: (world[0] * scale).floor().clamp(0, 256 * scale - 1),
    y: (world[1] * scale).floor().clamp(0, 256 * scale - 1),
  );
}

Scalable2i _refToTile(Geographic position, int zoom) {
  final world = _refProject(position);
  final scale = 1 << zoom;
  return Scalable2i(
    zoom: zoom,
    x: (world[0] * scale / 256).floor().clamp(0, scale - 1),
    y: (world[1] * scale / 256).floor().clamp(0, scale - 1),
  );
}

List<double> _refProject(Geographic position) {
  var siny = math.sin((position.lat * math.pi) / 180);
  siny = math.min(math.max(siny, -0.9999), 0.9999);

  return [
    (256 * (0.5 + position.lon / 360)).clamp(0.0, 256.0),
    (256 * (0.5 - math.log((1 + siny) / (1 - siny)) / (4 * math.pi)))
        .clamp(0.0, 256.0),
  ];
}
