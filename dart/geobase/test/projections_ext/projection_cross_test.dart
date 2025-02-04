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
import 'package:geobase/projections_proj4d.dart';

import 'package:test/test.dart';

String _format(Position pos, int decimals) =>
    pos.toText(decimals: decimals, compactNums: false);

void main() {
  group('Test UTM projection (geographic <-> UTM) on zone 31N', () {
    // WGS84 to UTM zone 31N (EPSG:32631) projection using geobase
    final adapterGeobase = WGS84.utmZone(UtmZone.from(31, Hemisphere.north));

    // WGS84 to UTM zone 31N (EPSG:32631) projection using Proj4dart library
    const def = '+proj=utm +zone=31 +datum=WGS84 +units=m +no_defs +type=crs';
    final adapterProj4d = Proj4d.tryInit(
      CoordRefSys.EPSG_4326,
      CoordRefSys.normalized('EPSG:32631'),
      targetDef: def,
    )!;

    void testZone(Geographic geo) {
      // project using proj4dart
      final utm1 = adapterProj4d.forward.project(geo, to: Projected.create);
      final geo1b = adapterProj4d.inverse.project(utm1, to: Geographic.create);
      expect(_format(geo1b, 11), _format(geo, 11));

      // project using geobase
      final utm2 = adapterGeobase.forward.project(geo, to: Projected.create);
      final geo2b = adapterGeobase.inverse.project(utm2, to: Geographic.create);
      expect(_format(geo2b, 11), _format(geo, 11));

      // cross check
      expect(_format(utm1, 6), _format(utm2, 6)); // 6 decimals ~ 0.001 mm
      expect(_format(geo1b, 11), _format(geo2b, 11));
    }

    test('UTM cross test2', () {
      final rand = Random(159883);
      for (var i = 0; i < 100; i++) {
        final geo1 = Geographic(
          lat: 0.0 + rand.nextDouble() * 84.0,
          lon: 0.0 + rand.nextDouble() * 6.0,
          elev: -5000.0 + rand.nextDouble() * 10000.0,
        );
        testZone(geo1);
      }
    });
  });

  group('Test UTM projection (geographic <-> UTM) on all zones', () {
    for (var zone = 1; zone <= 60; zone++) {
      for (final hemi in [Hemisphere.north, Hemisphere.south]) {
        final latOrigin = hemi == Hemisphere.north ? 0.0 : -80.0;
        final latRange = hemi == Hemisphere.north ? 84.0 : 80.0;
        final adapterGeobase = WGS84.utmZone(UtmZone.from(zone, hemi));
        final def = hemi == Hemisphere.north
            ? '+proj=utm +zone=$zone +datum=WGS84 +units=m +no_defs +type=crs'
            : '+proj=utm +zone=$zone +south +datum=WGS84 +units=m +no_defs'
                ' +type=crs';
        final adapterProj4d = Proj4d.tryInit(
          CoordRefSys.EPSG_4326,
          CoordRefSys.utmWgs84(zone, hemi),
          targetDef: def,
        )!;

        void testZone(Geographic geo) {
          // project using proj4dart
          final utm1 = adapterProj4d.forward.project(geo, to: Projected.create);
          final geo1b =
              adapterProj4d.inverse.project(utm1, to: Geographic.create);
          expect(_format(geo1b, 9), _format(geo, 9));

          // project using geobase
          final utm2 =
              adapterGeobase.forward.project(geo, to: Projected.create);
          final geo2b =
              adapterGeobase.inverse.project(utm2, to: Geographic.create);
          expect(_format(geo2b, 9), _format(geo, 9));

          // cross check
          expect(_format(utm1, 5), _format(utm2, 5)); // 5 decimals ~ 0.01 mm
          expect(_format(geo1b, 9), _format(geo2b, 9));
        }

        test('UTM cross test2 zone $zone ${hemi.symbol}', () {
          final rand = Random(159883 * zone);
          for (var i = 0; i < 20; i++) {
            final geo1 = Geographic(
              lat: latOrigin + rand.nextDouble() * latRange,
              lon: (zone - 1) * 6.0 + rand.nextDouble() * 6.0,
              elev: -5000.0 + rand.nextDouble() * 10000.0,
            );
            testZone(geo1);
          }
        });
      }
    }
  });

  group('Test WebMercator projection (geographic <-> WebMercator)', () {
    // WGS84 to WebMercator projection using geobase
    const adapterGeobase = WGS84.webMercator;

    // WGS84 to WebMercator projection using Proj4dart library
    final adapterProj4d = Proj4d.init(
      CoordRefSys.EPSG_4326,
      CoordRefSys.EPSG_3857,
    );

    void testMercator(Geographic geo) {
      // project using proj4dart
      final merc1 = adapterProj4d.forward.project(geo, to: Projected.create);
      final geo1b = adapterProj4d.inverse.project(merc1, to: Geographic.create);
      expect(_format(geo1b, 10), _format(geo, 10));

      // project using geobase
      final merc2 = adapterGeobase.forward.project(geo, to: Projected.create);
      final geo2b =
          adapterGeobase.inverse.project(merc2, to: Geographic.create);
      expect(_format(geo2b, 11), _format(geo, 11));

      // cross check
      expect(_format(merc1, 6), _format(merc2, 6)); // 6 decimals ~ 0.001 mm
      expect(_format(geo1b, 10), _format(geo2b, 10));
    }

    test('Web Mercator cross test2', () {
      final rand = Random(3056693);
      for (var i = 0; i < 100; i++) {
        final geo1 = Geographic(
          lat: -85.0 + rand.nextDouble() * 170.0,
          lon: -180.0 + rand.nextDouble() * 360.0,
          elev: -5000.0 + rand.nextDouble() * 10000.0,
        );
        testMercator(geo1);
      }
    });
  });

  // EPSG:4978

  group('Test geocentric projection (geographic <-> geocentric)', () {
    // WGS84 to geocentric projection using geobase
    final adapterGeobase = WGS84.geocentric;

    // WGS84 to geocentric projection using Proj4dart library
    final adapterProj4d = Proj4d.tryInit(
      CoordRefSys.EPSG_4326,
      CoordRefSys.EPSG_4978,
      targetDef: '+proj=geocent +datum=WGS84 +units=m +no_defs +type=crs',
    )!;

    void testGeocentric(Geographic geo) {
      // project using proj4dart
      final gc1 = adapterProj4d.forward.project(geo, to: Projected.create);
      final geo1b = adapterProj4d.inverse.project(gc1, to: Geographic.create);
      expect(_format(geo1b, 7), _format(geo, 7));

      // project using geobase
      final gc2 = adapterGeobase.forward.project(geo, to: Projected.create);
      final geo2b = adapterGeobase.inverse.project(gc2, to: Geographic.create);
      expect(_format(geo2b, 7), _format(geo, 7));

      // cross check
      expect(_format(gc1, 6), _format(gc2, 6)); // 6 decimals ~ 0.001 mm
      expect(_format(geo1b, 7), _format(geo2b, 7));
    }

    test('Web Mercator cross test2', () {
      final rand = Random(39435343);
      for (var i = 0; i < 100; i++) {
        final geo1 = Geographic(
          lat: -90.0 + rand.nextDouble() * 90.0,
          lon: -180.0 + rand.nextDouble() * 360.0,
          elev: -5000.0 + rand.nextDouble() * 10000.0,
        );
        testGeocentric(geo1);
      }
    });
  });

  group('Test datum conversions (geographic WGS84 <-> geographic ED50)', () {
    // NOTE: geobase datum conversion is not very accurate at all

    // WGS84 to ED50 (EPSG:4320) projection using geobase
    final adapterGeobase = WGS84.geographicToDatum(
      CoordRefSys.normalized('EPSG:4230'),
      Datum.ED50,
    );

    // WGS84 to ED50 (EPSG:4320) projection using Proj4dart library
    const def = '+proj=longlat +ellps=intl +towgs84=-87,-98,-121,0,0,0,0'
        ' +no_defs +type=crs';
    final adapterProj4d = Proj4d.tryInit(
      CoordRefSys.EPSG_4326,
      CoordRefSys.normalized('EPSG:4230'),
      targetDef: def,
    )!;

    void testDatumConv(Geographic geo) {
      // project using proj4dart
      final ed1 = adapterProj4d.forward.project(geo, to: Geographic.create);
      final geo1b = adapterProj4d.inverse.project(ed1, to: Geographic.create);
      expect(_format(geo1b, 5), _format(geo, 5));

      // project using geobase
      final ed2 = adapterGeobase.forward.project(geo, to: Geographic.create);
      final geo2b = adapterGeobase.inverse.project(ed2, to: Geographic.create);
      expect(_format(geo2b, 3), _format(geo, 3));

      // cross check
      expect(_format(ed1, 1), _format(ed2, 1));
      expect(_format(geo1b, 3), _format(geo2b, 3));
    }

    test('Datum conversions cross test', () {
      final rand = Random(129684);
      for (var i = 0; i < 100; i++) {
        final geo1 = Geographic(
          lat: 34.88 + rand.nextDouble() * 36.36,
          lon: -9.56 + rand.nextDouble() * 41.15,
        );
        testDatumConv(geo1);
      }
    });
  });

  group('Test datum conversions (geographic WGS84 <-> geographic NAD83)', () {
    // NOTE: geobase datum conversion is not very accurate at all

    // WGS84 to NAD83 (EPSG:4269) projection using geobase
    final adapterGeobase = WGS84.geographicToDatum(
      CoordRefSys.normalized('EPSG:4269'),
      Datum.NAD83,
    );

    // WGS84 to NAD83 (EPSG:4269) projection using Proj4dart library
    final adapterProj4d = Proj4d.init(
      CoordRefSys.EPSG_4326,
      CoordRefSys.normalized('EPSG:4269'),
    );

    void testDatumConv(Geographic geo) {
      // project using proj4dart
      final nad1 = adapterProj4d.forward.project(geo, to: Geographic.create);
      final geo1b = adapterProj4d.inverse.project(nad1, to: Geographic.create);
      expect(_format(geo1b, 13), _format(geo, 13));

      // project using geobase
      final nad2 = adapterGeobase.forward.project(geo, to: Geographic.create);
      final geo2b = adapterGeobase.inverse.project(nad2, to: Geographic.create);
      expect(_format(geo2b, 8), _format(geo, 8));

      // cross check
      expect(_format(nad1, 2), _format(nad2, 2));
      expect(_format(geo1b, 8), _format(geo2b, 8));
    }

    test('Datum conversions cross test', () {
      final rand = Random(129684);
      for (var i = 0; i < 100; i++) {
        final geo1 = Geographic(
          lat: 23.81 + rand.nextDouble() * 62.65,
          lon: -172.54 + rand.nextDouble() * 124.8,
        );
        testDatumConv(geo1);
      }
    });
  });
}
