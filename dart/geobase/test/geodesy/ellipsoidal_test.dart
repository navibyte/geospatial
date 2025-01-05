// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: require_trailing_commas

import 'dart:math';

import 'package:geobase/common.dart';
import 'package:geobase/coordinates.dart';
import 'package:geobase/geodesy.dart';

import 'package:test/test.dart';

void main() {
  group('Ellipsoidal calculations', () {
    test('Geocentric - geographic self test1', () {
      final testCases = [
        const Geographic(lat: 51.749822, lon: 5.398882, elev: 10.2234),
        const Geographic(lat: 0.0, lon: -23.484, elev: -2210.3232232),
        const Geographic(lat: -89.2, lon: -179.2, elev: -123.552345),
        const Geographic(lat: 90.0, lon: -180.0, elev: 0.0),
        const Geographic(lat: -90.0, lon: 180.0, elev: 1000.0),
        const Geographic(lat: 0.0, lon: 0.0, elev: 0.0),
      ];

      for (final geo1 in testCases) {
        final latLon1 = Ellipsoidal(geo1);

        expect(
          Ellipsoidal.fromGeocentricCartesian(latLon1.toGeocentricCartesian())
              .origin
              .toText(decimals: 8, compactNums: false),
          geo1.toText(decimals: 8, compactNums: false),
        );
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
        final ellisoid1 = i.isEven ? Ellipsoid.WGS84 : Ellipsoid.GRS80;
        final latLon1 = Ellipsoidal(geo1, ellipsoid: ellisoid1);
        expect(
          Ellipsoidal.fromGeocentricCartesian(latLon1.toGeocentricCartesian(),
                  ellipsoid: ellisoid1)
              .origin
              .toText(decimals: 7, compactNums: false),
          geo1.toText(decimals: 7, compactNums: false),
        );
      }
    });

    test('Geocentric - geographic test1', () {
      final testCases = [
        [
          // test values from
          // https://github.com/chrisveness/geodesy/blob/master/test/latlon-ellipsoidal-tests.js
          const Geographic(lat: 45.0, lon: 45.0, elev: -0.0),
          Position.create(x: 3194419.0, y: 3194419.0, z: 4487348.0),
          Ellipsoid.WGS84,
          0,
        ],
        [
          // test values from
          // https://proj.org/en/9.5/operations/conversions/cart.html
          const Geographic(
              lon: 17.7562015132, lat: 45.3935192042, elev: 133.12),
          Position.create(x: 4272922.1553, y: 1368283.0597, z: 4518261.3501),
          Ellipsoid.GRS80,
          4,
        ],
        [
          // test values generated using
          // https://www.oc.nps.edu/oc2902w/coord/llhxyz.htm
          const Geographic(lat: 51.4778, lon: -0.0014, elev: 45.0),
          Position.create(x: 3980609.0, y: -97.0, z: 4966860.0),
          Ellipsoid.WGS84,
          0,
        ],
      ];

      for (final t in testCases) {
        final geo1 = t[0] as Geographic;
        final ellipsoid1 = t[2] as Ellipsoid;
        final gc1 = t[1] as Position;
        final decimals = t[3] as int;

        expect(
          geo1
              .toGeocentricCartesian(ellipsoid: ellipsoid1)
              .toText(decimals: decimals),
          gc1.toText(decimals: decimals),
        );

        expect(
          Geocentric.fromGeocentricCartesian(gc1, ellipsoid: ellipsoid1)
              .toGeographic()
              .toText(decimals: decimals, compactNums: false),
          geo1.toText(decimals: decimals, compactNums: false),
        );
      }
    });

    test('Geocentric - geographic test2', () {
      // test values
      // https://github.com/chrisveness/geodesy/blob/master/latlon-ellipsoidal.js

      final gc1 =
          Position.create(x: 4027893.924, y: 307041.993, z: 4919474.294);

      final geo1 = Geocentric.fromGeocentricCartesian(gc1).toGeographic();
      expect(geo1.lat, closeTo(50.7978, 0.0001));
      expect(geo1.lon, closeTo(4.3592, 0.0001));
    });
  });

  group('Ellipsoidal calculations on datums', () {
    test('Datum conversions using Datum class and geocentric coordinates', () {
      // test values
      // https://github.com/chrisveness/geodesy/blob/master/test/latlon-ellipsoidal-datum-tests.js

      const dms6 = Dms(decimals: 6);

      const geo1 = Geographic(lat: 51.47788, lon: -0.00147);
      final gc1 = geo1.toGeocentricCartesian();
      final gc1conv =
          Datum.WGS84.convertGeocentricCartesian(gc1, to: Datum.OSGB36);
      final geo1conv =
          Geocentric.fromGeocentricCartesian(gc1conv, datum: Datum.OSGB36)
              .toEllipsoidal()
              .origin;
      expect(geo1conv.latDms(dms6), '51.477364°N');
      expect(geo1conv.lonDms(dms6), '0.000150°E');

      final gc2 = Position.create(
        x: 4027893.924,
        y: 307041.993,
        z: 4919474.294,
      );
      final gc2conv =
          Datum.WGS84.convertGeocentricCartesian(gc2, to: Datum.OSGB36);
      final geo2conv =
          Ellipsoidal.fromGeocentricCartesian(gc2conv, datum: Datum.OSGB36)
              .origin;
      expect(geo2conv.latDms(), '50.7971°N');
      expect(geo2conv.lonDms(), '4.3612°E');
    });

    test('Datum conversions using Datum class and geographic coordinates', () {
      // test values
      // https://github.com/chrisveness/geodesy/blob/master/test/latlon-ellipsoidal-datum-tests.js

      const dms5 = Dms(decimals: 5);
      const dms6 = Dms(decimals: 6);
      const degMinSec = Dms(type: DmsType.degMinSec, decimals: 3);

      const geo1 = Geographic(lat: 51.47788, lon: -0.00147);
      final geo1conv = Datum.WGS84.convertGeographic(geo1, to: Datum.OSGB36);
      expect(geo1conv.latDms(dms6), '51.477364°N');
      expect(geo1conv.lonDms(dms6), '0.000150°E');
      final geo1b = Datum.OSGB36.convertGeographic(geo1conv, to: Datum.WGS84);
      expect(geo1b.latDms(dms5), '51.47788°N');
      expect(geo1b.lonDms(dms5), '0.00147°W');

      final gc2 = Position.create(
        x: 4027893.924,
        y: 307041.993,
        z: 4919474.294,
      );
      final geo2 = Geocentric.fromGeocentricCartesian(gc2).toGeographic();
      final geo2conv = Datum.WGS84.convertGeographic(geo2, to: Datum.OSGB36);
      expect(geo2conv.latDms(), '50.7971°N');
      expect(geo2conv.lonDms(), '4.3612°E');
      final geo2b = Datum.OSGB36.convertGeographic(geo2conv, to: Datum.WGS84);
      final gc2b = geo2b.toGeocentricCartesian();
      expect(gc2b.toText(decimals: 1), gc2.toText(decimals: 1));

      const geo3 = Geographic(lat: 53.0, lon: 1.0, elev: 50.0);
      final geo3osgb = Datum.WGS84.convertGeographic(geo3, to: Datum.OSGB36);
      expect(geo3osgb.latLonDms(format: degMinSec),
          '52°59′58.719″N, 1°00′06.490″E, 3.99m');

      final geo3ed = Datum.WGS84.convertGeographic(geo3, to: Datum.ED50);
      expect(geo3ed.latLonDms(format: degMinSec),
          '53°00′02.887″N, 1°00′05.101″E, 2.72m');

      final geo3ed2 = Datum.OSGB36.convertGeographic(geo3osgb, to: Datum.ED50);
      final geo3wgs2 = Datum.ED50.convertGeographic(geo3ed2, to: Datum.WGS84);
      expect(geo3wgs2.latLonDms(elevDecimals: 1), '53.0000°N, 1.0000°E, 50.0m');
    });
  });
}
