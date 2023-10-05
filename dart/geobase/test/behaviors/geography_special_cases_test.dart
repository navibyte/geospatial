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
      expect(
        fiji.aligned2D(Aligned.center),
        const Geographic(lon: 179.5, lat: -18.0),
      );
      expect(
        fiji.aligned2D(Aligned.northWest),
        const Geographic(lon: 177.0, lat: -16.0),
      );
      expect(
        fiji.aligned2D(Aligned.southEast),
        const Geographic(lon: -178.0, lat: -20.0),
      );
      expect(
        fiji.aligned2D(const Aligned(x: 0.4, y: -0.5)),
        const Geographic(lon: -179.5, lat: -19.0),
      );

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
      expect(zeroE180.width, 360.0);
      expect(zeroE180.splitOnAntimeridian(), [round]);
      expect(zeroE180.complementary, zeroW180);

      expect(e20width359.spansAntimeridian, true);
      expect(e20width359.width, 359.0);
      expect(
        e20width359.splitOnAntimeridian(),
        [e20width359WestFrom180, e20width359EastFrom180],
      );
      expect(e20width359.complementary, e19width1);
      expect(
        e20width359.aligned2D(const Aligned(x: -1.0, y: 0.5)),
        const Geographic(lon: 20.0, lat: -17.0),
      );
      expect(
        e20width359.aligned2D(const Aligned(x: 1.0, y: 0.5)),
        const Geographic(lon: 19.0, lat: -17.0),
      );
      expect(e19width1.spansAntimeridian, false);
      expect(e19width1.width, 1.0);
      expect(e19width1.splitOnAntimeridian(), [e19width1]);
      expect(e19width1.complementary, e20width359);

      expect(prime.spansAntimeridian, false);
      expect(prime.width, 0.0);
      expect(prime.splitOnAntimeridian(), [prime]);
      expect(prime.complementary, round);

      // merge tests
      expect(fijiWestFrom180.mergeGeographically(fijiEastFrom180), fiji);
      expect(fijiWestFrom180.mergeGeographically(fiji), fiji);
      expect(fijiEastFrom180.mergeGeographically(fiji), fiji);
      expect(round.mergeGeographically(fiji), round);
      expect(
        e20width359WestFrom180.mergeGeographically(e20width359EastFrom180),
        e20width359,
      );
      expect(
        e20width359WestFrom180.mergeGeographically(e20width359),
        e20width359,
      );
      expect(
        e20width359WestFrom180.mergeGeographically(e20width359),
        e20width359,
      );
      expect(b(170, 172).mergeGeographically(b(-172, -170)), b(170, -170));
      expect(b(-172, -170).mergeGeographically(b(170, 172)), b(170, -170));
      expect(b(88, 89).mergeGeographically(b(-89, -88)), b(-89, 89));
      expect(b(-89, -88).mergeGeographically(b(88, 89)), b(-89, 89));
      expect(b(-180, -180).mergeGeographically(b(179, 180)), b(179, 180));
      expect(b(-180, -179).mergeGeographically(b(179, 180)), b(179, -179));
      expect(b(-180, -179).mergeGeographically(b(-180, -180)), b(-180, -179));
      expect(b(160, -170).mergeGeographically(b(170, -160)), b(160, -160));
      expect(b(90, 100).mergeGeographically(b(170, -160)), b(90, -160));
      expect(b(-100, -90).mergeGeographically(b(170, -160)), b(170, -90));
      expect(b(-100, -91).mergeGeographically(b(89, 100)), b(89, -91));
      expect(b(-89, -88).mergeGeographically(b(88, 89)), b(-89, 89));
      expect(b(-89, -88).mergeGeographically(b(88, 98)), b(88, -88));
      expect(b(-140, -100).mergeGeographically(b(140, -160)), b(140, -100));
      expect(b(140, -160).mergeGeographically(b(-140, -100)), b(140, -100));
      expect(b(0, 1).mergeGeographically(b(179, 180)), b(0, 180));
      expect(b(-2, -1).mergeGeographically(b(179, 180)), b(179, -1));
      expect(b(-1, 0).mergeGeographically(b(179, -179)), b(179, 0));
      expect(b(0, 1).mergeGeographically(b(179, -179)), b(0, -179));

      // a sample merging two boxes on both sides on the antimeridian
      // (the result equal with p3 is then spanning the antimeridian)
      const p1 = GeoBox(west: 177.0, south: -20.0, east: 179.0, north: -16.0);
      const p2 = GeoBox(west: -179.0, south: -20.0, east: -178.0, north: -16.0);
      const p3 = GeoBox(west: 177.0, south: -20.0, east: -178.0, north: -16.0);
      expect(p1.mergeGeographically(p2) == p3, true);

      // a sample merging two boxes without need for antimeridian logic
      const p4 = GeoBox(west: 40.0, south: 10.0, east: 60.0, north: 11.0);
      const p5 = GeoBox(west: 55.0, south: 19.0, east: 70.0, north: 20.0);
      const p6 = GeoBox(west: 40.0, south: 10.0, east: 70.0, north: 20.0);
      expect(p4.mergeGeographically(p5) == p6, true);
    });
  });
}

GeoBox b(double west, double east) =>
    GeoBox(west: west, south: -20.0, east: east, north: -16.0);
