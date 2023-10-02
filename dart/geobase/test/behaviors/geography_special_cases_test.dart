// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_literals_to_create_immutables
// ignore_for_file: avoid_redundant_argument_values

import 'package:geobase/coordinates.dart';

import 'package:test/test.dart';

void main() {
  group('Bounding boxes spanning antimeridian', () {
    // see => https://datatracker.ietf.org/doc/html/rfc7946#section-5.2
    const fiji = GeoBox(west: 177.0, south: -20.0, east: -178.0, north: -16.0);
    const fijiWestFrom180 =
        GeoBox(west: 177.0, south: -20.0, east: 180.0, north: -16.0);
    const fijiEastFrom180 =
        GeoBox(west: -180.0, south: -20.0, east: -178.0, north: -16.0);
    const outsideFiji =
        GeoBox(west: -178.0, south: -20.0, east: 177.0, north: -16.0);

    test('GeoBox', () {
      expect(fiji.spansAntimeridian, true);
      expect(fiji.width, 5.0);
      expect(fiji.splitOnAntimeridian(), [fijiWestFrom180, fijiEastFrom180]);
      expect(outsideFiji.spansAntimeridian, false);
      expect(outsideFiji.width, 355.0);
    });
  });
}
