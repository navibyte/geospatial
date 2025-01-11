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
import 'package:geobase/projections.dart';

import 'package:test/test.dart';

/*
  Some tests also on `/test/geodesy/ellipsoidal_test.dart`.
*/

String _format(Position pos, int decimals) =>
    pos.toText(decimals: decimals, compactNums: false);

const _geoToUtmWGS84 = [
  // [lon, lat, zone, band, easting, northing, decGeo, decUtm]
  [2.2945, 48.8582, 31, 'N', 448251.795, 5411932.678, 2, 3],
  [151.215, -33.857, 56, 'S', 334873.199, 6252266.092, 5, 3],
];

void main() {
  group('Test UTM projection (geographic/geodetic <-> UTM)', () {
    test('WGS84 lon-lat) to WGS84 utm zone (easting, northing) - project', () {
      for (final t in _geoToUtmWGS84) {
        final geo1 = Geographic(lon: t[0] as double, lat: t[1] as double);
        final utm1 = Projected(x: t[4] as double, y: t[5] as double);
        final zone = t[2] as int;
        final hemisphere = Hemisphere.fromSymbol(t[3] as String);
        final decGeo = t[6] as int;
        final decUtm = t[7] as int;

        final adapter = WGS84.utmZone(UtmZone.from(zone, hemisphere));

        final utm1b = adapter.forward.project(geo1, to: Projected.create);
        expect(_format(utm1b, decUtm), _format(utm1, decUtm));

        final geo1b = adapter.inverse.project(utm1, to: Geographic.create);
        expect(_format(geo1b, decGeo), _format(geo1, decGeo));

        final utm1c = adapter.forward.project(geo1b, to: Projected.create);
        expect(_format(utm1c, 8), _format(utm1, 8));

        final geo1c = adapter.inverse.project(utm1b, to: Geographic.create);
        expect(_format(geo1c, 8), _format(geo1, 8));
      }
    });
  });

  test('UTM self test1', () {
    final testCases = [
      const Geographic(lat: 51.749822, lon: 5.398882, elev: 10.2234),
      const Geographic(lat: 0.0, lon: -23.484, elev: -2210.3232232),
      const Geographic(lat: minLatitudeUTM, lon: -179.2, elev: -123.552345),
      const Geographic(
          lat: maxLatitudeUTM, lon: -179.2, elev: -123.552345, m: 1.1),
      const Geographic(lat: maxLatitudeUTM, lon: -180.0, elev: 0.0),
      const Geographic(lat: minLatitudeUTM, lon: 180.0, elev: 1000.0),
      const Geographic(lat: 0.0, lon: 0.0, elev: 0.0),
    ];

    for (var i = 0; i < testCases.length; i++) {
      final geo1 = testCases[i];
      _testZone(geo1);
    }
  });

  test('UTM self test2', () {
    final rand = Random(29348843);
    for (var i = 0; i < 100; i++) {
      final geo1 = Geographic(
        lat: -80.0 + rand.nextDouble() * 160.0,
        lon: -180.0 + rand.nextDouble() * 360.0,
        elev: -5000.0 + rand.nextDouble() * 10000.0,
      );
      _testZone(geo1);
    }
  });
}

void _testZone(Geographic geo1) {
  // test in the actual zone and hemisphere for the geographic position
  final zone1 = UtmZone.fromGeographic(geo1);
  final adapter1 = WGS84.utmZone(zone1);
  final utm1 = adapter1.forward.project(geo1, to: Projected.create);
  final geo1b = adapter1.inverse.project(utm1, to: Geographic.create);
  expect(_format(geo1b, 8), _format(geo1, 8));

  // test in the zone (zone + 1)
  if (zone1.zone + 1 <= 60 && geo1.lon != 0.0) {
    final zone1p1 = UtmZone.from(zone1.zone + 1, zone1.hemisphere);
    final adapter2 = WGS84.utmZone(zone1p1);
    final utm2 = adapter2.forward.project(geo1, to: Projected.create);
    final geo2b = adapter2.inverse.project(utm2, to: Geographic.create);
    expect(_format(geo2b, 8), _format(geo1, 8));
  }

  // test zone to zone
  if (zone1.zone + 1 <= 60 && geo1.lon != 0.0) {
    final zone1p1 = UtmZone.from(zone1.zone + 1, zone1.hemisphere);
    // first to the zone `zone + 1`
    final adapter2zp1 = WGS84.utmZone(zone1p1);
    final utmZp1 = adapter2zp1.forward.project(geo1, to: Projected.create);
    // then from the zone `zone + 1` to the zone `zone`
    final adapter2ztz = WGS84.utmZoneToZone(zone1p1, zone1);
    final utmZ = adapter2ztz.forward.project(utmZp1, to: Projected.create);
    // then from the zone `zone` to the geographic position
    final adapter2z = WGS84.utmZone(zone1);
    final geo2b = adapter2z.inverse.project(utmZ, to: Geographic.create);
    expect(_format(geo2b, 8), _format(geo1, 8));
  }
}
