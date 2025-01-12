// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: require_trailing_commas

import 'dart:math';

import 'package:geobase/coordinates.dart';
import 'package:geobase/geodesy.dart';
import 'package:geobase/projections.dart';

import 'package:test/test.dart';

/*
  Some tests also on `/test/geodesy/ellipsoidal_test.dart`.
*/

String _format(Position pos) => pos.toText(decimals: 7, compactNums: false);

const _geographicWGS84 = [
  Geographic(lon: 123.0, lat: 15.0, elev: 140.0),
];

const _geocentricWGS84 = [
  Projected(x: -3356242.3698167196, y: 5168160.035350793, z: 1640136.37486220),
];

void main() {
  final wgs84geoToGc = WGS84.geocentric.forward;
  final wgs84gcToGeo = WGS84.geocentric.inverse;

  group('Test ellipsoidal projection (geographic/geodetic <-> geocentric)', () {
    // here WGS84 geographic coordinates specified by CRS84

    test('WGS84 lon-lat-elev(h) to WGS84 geocentric (XYZ) - project', () {
      for (var i = 0; i < _geographicWGS84.length; i++) {
        final geo1 = _geographicWGS84[i];
        final gc1 = _geocentricWGS84[i];

        final gc1b = wgs84geoToGc.project(geo1, to: Projected.create);
        expect(_format(gc1b), _format(gc1));

        final geo1b = wgs84gcToGeo.project(gc1, to: Geographic.create);
        expect(_format(geo1b), _format(geo1));
      }
    });

    test('WGS84 lon-lat-elev(h) to WGS84 geocentric (XYZ) - projectCoords', () {
      final geoCoords = _geographicWGS84.expand((geo) => geo.values).toList();
      final gcCoords = _geocentricWGS84.expand((gc) => gc.values).toList();

      final gcCoords2 = wgs84geoToGc.projectCoords(geoCoords, type: Coords.xyz);
      expect(gcCoords2.length, gcCoords.length);
      for (var i = 0; i < gcCoords.length; i++) {
        expect(gcCoords2[i], closeTo(gcCoords[i], 0.0000001));
      }

      final geoCoords2 = wgs84gcToGeo.projectCoords(gcCoords, type: Coords.xyz);
      expect(geoCoords2.length, geoCoords.length);
      for (var i = 0; i < geoCoords.length; i++) {
        expect(geoCoords2[i], closeTo(geoCoords[i], 0.0000001));
      }
    });

    test('Geocentric - geographic self test1', () {
      final testCases = [
        const Geographic(lat: 51.749822, lon: 5.398882, elev: 10.2234),
        const Geographic(lat: 0.0, lon: -23.484, elev: -2210.3232232),
        const Geographic(lat: -89.2, lon: -179.2, elev: -123.552345),
        const Geographic(lat: -89.2, lon: -179.2, elev: -123.552345, m: 1.1),
        const Geographic(lat: 90.0, lon: -180.0, elev: 0.0),
        const Geographic(lat: -90.0, lon: 180.0, elev: 1000.0),
        const Geographic(lat: 0.0, lon: 0.0, elev: 0.0),
      ];

      for (var i = 0; i < testCases.length; i++) {
        final geo1 = testCases[i];
        final gc1 = wgs84geoToGc.project(geo1, to: Projected.create);
        final geo1b = wgs84gcToGeo.project(gc1, to: Geographic.create);

        expect(_format(geo1b), _format(geo1));
      }
    });

    test('Geocentric - geographic self test2', () {
      final rand = Random(29348843);
      for (var i = 0; i < 100; i++) {
        final geo1 = Geographic(
          lat: -90.0 + rand.nextDouble() * 180.0,
          lon: -180.0 + rand.nextDouble() * 360.0,
          elev: -5000.0 + rand.nextDouble() * 10000.0,
        );

        final gc1 = wgs84geoToGc.project(geo1, to: Projected.create);
        final geo1b = wgs84gcToGeo.project(gc1, to: Geographic.create);

        expect(_format(geo1b), _format(geo1));
      }
    });

    test('Geocentric - geographic self test2 - projectCoords', () {
      final geoCoords = List.filled(300, 0.0);
      final rand = Random(12485003);
      for (var i = 0; i < 100; i++) {
        geoCoords[i * 3] = -180.0 + rand.nextDouble() * 360.0; // lon
        geoCoords[i * 3 + 1] = -90.0 + rand.nextDouble() * 180.0; // lat
        geoCoords[i * 3 + 2] = -5000.0 + rand.nextDouble() * 10000.0; // elev
      }

      final gcCoords = wgs84geoToGc.projectCoords(geoCoords, type: Coords.xyz);
      final geoCoords2 = wgs84gcToGeo.projectCoords(gcCoords, type: Coords.xyz);

      for (var i = 0; i < 100; i++) {
        expect(geoCoords2[i * 3], closeTo(geoCoords[i * 3], 0.0000001));
        expect(geoCoords2[i * 3 + 1], closeTo(geoCoords[i * 3 + 1], 0.0000001));
        expect(geoCoords2[i * 3 + 2], closeTo(geoCoords[i * 3 + 2], 0.0000001));
      }
    });

    test('Geographic to Datum - project', () {
      const geo3 = Geographic(lat: 53.0, lon: 1.0, elev: 50.0);

      const degMinSec = Dms(type: DmsType.degMinSec, decimals: 3);

      final toOSGB36 = WGS84.geographicToDatum(
          const CoordRefSys.id('EPSG:27700'), Datum.OSGB36);
      final geo3osgb = toOSGB36.forward.project(geo3, to: Geographic.create);
      expect(geo3osgb.latLonDms(format: degMinSec),
          '52°59′58.719″N, 1°00′06.490″E, 3.99m');
    });
  });
}
