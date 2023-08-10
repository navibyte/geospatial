// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:geobase/geobase.dart';
import 'package:test/test.dart';

import 'projection_sample.dart';

void main() {
  group('Test projections between WGS84 and Web Mercator', () {
    final toWebMercator = WGS84.webMercator.forward;
    final toWgs84 = WGS84.webMercator.inverse;

    test('webMercatorToWgs84(Projected to Geographic)', () {
      for (final coords in wgs84ToWebMercatorData) {
        final point2 = Projected(x: coords[2], y: coords[3]);
        final geoPoint2 = Geographic(lon: coords[0], lat: coords[1]);
        expectPosition(
          point2.project(toWgs84),
          geoPoint2,
        );
        expectPosition(
          toWgs84.project(point2, to: Geographic.create),
          Geographic(lon: coords[0], lat: coords[1]),
        );
        expectPosition(
          toWgs84.project(
            Projected(x: coords[2], y: coords[3], z: 30.0),
            to: Geographic.create,
          ),
          Geographic(lon: coords[0], lat: coords[1], elev: 30.0),
        );
      }
    });

    test('wgs84ToWebMercator(Geographic to Projected)', () {
      for (final coords in wgs84ToWebMercatorData) {
        final geoPoint3 = Geographic(lon: coords[0], lat: coords[1]);
        final point3 = Projected(x: coords[2], y: coords[3]);
        expectPosition(
          geoPoint3.project(toWebMercator),
          point3,
          0.01,
        );
        expectPosition(
          toWebMercator.project(geoPoint3, to: Projected.create),
          point3,
          0.01,
        );
      }
    });

    test('project bbox between GeoBox and ProjBox', () {
      const gb = GeoBox(
        west: 10.19238847,
        south: -11.349348834,
        east: 15.23095884,
        north: 21.094852974,
      );
      final wm = gb.project(toWebMercator);
      final gb2 = wm.project(toWgs84);
      expect(gb.toText(decimals: 8), gb2.toText(decimals: 8));
      expect(gb.equals2D(gb2), true);
    });
  });

  group('Test flat coordinate arrays', () {
    test('Wgs84 <-> WebMercator', () {
      const adapter = WGS84.webMercator;
      final forward = adapter.forward;
      final inverse = adapter.inverse;

      for (var dim = 2; dim <= 4; dim++) {
        final pointCount = wgs84ToWebMercatorData.length;
        final source = List.filled(dim * pointCount, 10.0);
        final target = List.filled(dim * pointCount, 10.0);
        for (var i = 0; i < pointCount; i++) {
          final sample = wgs84ToWebMercatorData[i];
          source[i * dim] = sample[0];
          source[i * dim + 1] = sample[1];
          target[i * dim] = sample[2];
          target[i * dim + 1] = sample[3];
        }
        expectCoords(
          forward.projectCoords(source, type: Coords.fromDimension(dim)),
          target,
          0.01,
        );
        expectCoords(
          inverse.projectCoords(target, type: Coords.fromDimension(dim)),
          source,
          0.01,
        );
      }
    });
  });
}
