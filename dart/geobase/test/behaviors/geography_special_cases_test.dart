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

    // other test cases
    const round = GeoBox(west: -180.0, south: -20.0, east: 180.0, north: -16.0);
    const e20width359 =
        GeoBox(west: 20.0, south: -20.0, east: 19.0, north: -16.0);
    const e20width359WestFrom180 =
        GeoBox(west: 20.0, south: -20.0, east: 180.0, north: -16.0);
    const e20width359EastFrom180 =
        GeoBox(west: -180.0, south: -20.0, east: 19.0, north: -16.0);
    const e19width1 =
        GeoBox(west: 19.0, south: -20.0, east: 20.0, north: -16.0);
    const zeroW180 =
        GeoBox(west: -180.0, south: -20.0, east: -180.0, north: -16.0);
    const zeroE180 =
        GeoBox(west: 180.0, south: -20.0, east: 180.0, north: -16.0);
    const prime = GeoBox(west: 0.0, south: -20.0, east: 0.0, north: -16.0);

    test('GeoBox', () {
      expect(fiji.spansAntimeridian, true);
      expect(fiji.width, 5.0);
      expect(fiji.splitOnAntimeridian(), [fijiWestFrom180, fijiEastFrom180]);
      expect(fiji.complementary, outsideFiji);

      expect(outsideFiji.spansAntimeridian, false);
      expect(outsideFiji.width, 355.0);
      expect(outsideFiji.splitOnAntimeridian(), [outsideFiji]);
      expect(outsideFiji.complementary, fiji);

      expect(round.spansAntimeridian, false);
      expect(round.width, 360.0);
      expect(round.splitOnAntimeridian(), [round]);
      expect(round.complementary, zeroW180);

      expect(zeroW180.spansAntimeridian, false);
      expect(zeroW180.width, 0.0);
      expect(zeroW180.splitOnAntimeridian(), [zeroW180]);
      expect(zeroW180.complementary, round);

      expect(zeroE180.spansAntimeridian, false);
      expect(zeroE180.width, 0.0);
      expect(zeroE180.splitOnAntimeridian(), [zeroE180]);
      expect(zeroE180.complementary, round);

      expect(e20width359.spansAntimeridian, true);
      expect(e20width359.width, 359.0);
      expect(
        e20width359.splitOnAntimeridian(),
        [e20width359WestFrom180, e20width359EastFrom180],
      );
      expect(e20width359.complementary, e19width1);

      expect(e19width1.spansAntimeridian, false);
      expect(e19width1.width, 1.0);
      expect(e19width1.splitOnAntimeridian(), [e19width1]);
      expect(e19width1.complementary, e20width359);

      expect(prime.spansAntimeridian, false);
      expect(prime.width, 0.0);
      expect(prime.splitOnAntimeridian(), [prime]);
      expect(prime.complementary, round);
    });
  });
}
