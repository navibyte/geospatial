// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
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
    test('webMercatorToWgs84(Projected to Geographic)', () {
      final toWgs84 = wgs84ToWebMercator.inverse();
      for (final coords in wgs84ToWebMercatorData) {
        final point2 = Projected(x: coords[2], y: coords[3]);
        final geoPoint2 = Geographic(lon: coords[0], lat: coords[1]);
        expectPosition(toWgs84.project(point2), geoPoint2);
        expectPosition(
          toWgs84.project(point2),
          Geographic(lon: coords[0], lat: coords[1]),
        );
        expectPosition(
          toWgs84.project(Projected(x: coords[2], y: coords[3], z: 30.0)),
          Geographic(lon: coords[0], lat: coords[1], elev: 30.0),
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
      final toWebMercator = wgs84ToWebMercator.forward();
      for (final coords in wgs84ToWebMercatorData) {
        final geoPoint3 = Geographic(lon: coords[0], lat: coords[1]);
        final point3 = Projected(x: coords[2], y: coords[3]);
        expectPosition(toWebMercator.project(geoPoint3), point3, 0.01);
      }
    });
  });
}
