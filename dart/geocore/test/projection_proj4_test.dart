// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import 'package:geocore/geocore.dart';

import 'package:test/test.dart';

import 'projection_sample.dart';

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  group('Test proj4dart with built in projections', () {
    final adapterWgs84ToWM = proj4dart('EPSG:4326', 'EPSG:3857');
    final adapterWMToWgs84 = Proj4Adapter.resolve('EPSG:3857', 'EPSG:4326');

    test('Create projection adapters', () {
      expect(adapterWgs84ToWM.fromCrs, 'EPSG:4326');
      expect(adapterWgs84ToWM.toCrs, 'EPSG:3857');
      expect(adapterWgs84ToWM.tuple.fromProj.projName, 'longlat');
      expect(adapterWgs84ToWM.tuple.toProj.projName, 'merc');
      expect(adapterWMToWgs84.fromCrs, 'EPSG:3857');
      expect(adapterWMToWgs84.toCrs, 'EPSG:4326');
      expect(adapterWMToWgs84.tuple.fromProj.projName, 'merc');
      expect(adapterWMToWgs84.tuple.toProj.projName, 'longlat');
    });

    test('wgs84ToWebMercator.forward', () {
      final toWebMercatorProj4a = adapterWgs84ToWM.forward(Point3m.coordinates);
      final toWebMercatorProj4b = adapterWMToWgs84.inverse(Point3m.coordinates);
      final toWebMercatorGeocore =
          wgs84ToWebMercator.forward(Point3m.coordinates);
      for (final coords in wgs84ToWebMercatorData) {
        final geoPoint3 =
            GeoPoint3m(lon: coords[0], lat: coords[1], elev: 5.1, m: 6.2);
        final point3 = Point3m(x: coords[2], y: coords[3], z: 5.1, m: 6.2);
        expectProjected(geoPoint3.project(toWebMercatorProj4a), point3, 0.01);
        expectProjected(geoPoint3.project(toWebMercatorProj4b), point3, 0.01);
        expectProjected(
          geoPoint3.project(toWebMercatorProj4a),
          geoPoint3.project(toWebMercatorGeocore),
          0.01,
        );
      }
    });

    test('wgs84ToWebMercator.inverse', () {
      final toWgs84Proj4a = adapterWgs84ToWM.inverse(GeoPoint3m.coordinates);
      final toWgs84Proj4b = adapterWMToWgs84.forward(GeoPoint3m.coordinates);
      final toWgs84Geocore = wgs84ToWebMercator.inverse(GeoPoint3m.coordinates);
      for (final coords in wgs84ToWebMercatorData) {
        final geoPoint3 =
            GeoPoint3m(lon: coords[0], lat: coords[1], elev: 5.1, m: 6.2);
        final point3 = Point3m(x: coords[2], y: coords[3], z: 5.1, m: 6.2);
        expectProjected(point3.project(toWgs84Proj4a), geoPoint3);
        expectProjected(point3.project(toWgs84Proj4b), geoPoint3);
        expectProjected(
          point3.project(toWgs84Proj4a),
          point3.project(toWgs84Geocore),
        );
      }
    });
  });

  group('Test proj4dart with defined projections', () {
    // testing a sample introduced at https://pub.dev/packages/proj4dart
    const proj4def =
        '+proj=somerc +lat_0=47.14439372222222 +lon_0=19.04857177777778 '
        '+k_0=0.99993 +x_0=650000 +y_0=200000 +ellps=GRS67 '
        '+towgs84=52.17,-71.82,-14.9,0,0,0,0 +units=m +no_defs';
    const wktDef =
        'PROJCS["HD72 / EOV",GEOGCS["HD72",DATUM["Hungarian_Datum_1972", '
        'SPHEROID["GRS 1967",6378160,298.247167427,AUTHORITY["EPSG","7036"]], '
        'TOWGS84[52.17,-71.82,-14.9,0,0,0,0],AUTHORITY["EPSG","6237"]],'
        'PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",'
        '0.0174532925199433,AUTHORITY["EPSG","9122"]],'
        'AUTHORITY["EPSG","4237"]],'
        'PROJECTION["Hotine_Oblique_Mercator_Azimuth_Center"],'
        'PARAMETER["latitude_of_center",47.14439372222222],'
        'PARAMETER["longitude_of_center",19.04857177777778],'
        'PARAMETER["azimuth",90],PARAMETER["rectified_grid_angle",90],'
        'PARAMETER["scale_factor",0.99993],PARAMETER["false_easting",650000],'
        'PARAMETER["false_northing",200000],UNIT["metre",1,'
        'AUTHORITY["EPSG","9001"]],AXIS["Y",EAST],AXIS["X",NORTH],'
        'AUTHORITY["EPSG","23700"]]';
    const esriDef =
        'PROJCS["HD72_EOV",GEOGCS["GCS_HD72",DATUM["D_Hungarian_1972",SPHEROID'
        '["GRS_1967",6378160,298.247167427]],PRIMEM["Greenwich",0],'
        'UNIT["Degree",0.017453292519943295]],PROJECTION'
        '["Hotine_Oblique_Mercator_Azimuth_Center"],'
        'PARAMETER["latitude_of_center",47.14439372222222],'
        'PARAMETER["longitude_of_center",19.04857177777778],'
        'PARAMETER["azimuth",90],PARAMETER["scale_factor",0.99993],'
        'PARAMETER["false_easting",650000],PARAMETER["false_northing",200000],'
        'UNIT["Meter",1]]';
    const defs = [proj4def, wktDef, esriDef];
    const defsAccuracyProj = [null, 0.1, 100];
    const defsAccuracyWgs84 = [null, 0.000001, 0.01];

    for (var i = 0; i < defs.length; i++) {
      final def = defs[i];
      final adapter = Proj4Adapter.tryResolve(
        'EPSG:4326',
        'EPSG:23700',
        toDef: def,
      );
      test('Test between EPSG:4326 and EPSG:23700', () {
        expect(adapter, isNotNull);

        if (adapter != null) {
          expect(adapter.fromCrs, 'EPSG:4326');
          expect(adapter.toCrs, 'EPSG:23700');

          const p = Point2(x: 561651.8408065987, y: 172658.61998377228);
          const geo =
              GeoPoint2(lon: 17.888058560281515, lat: 46.89226406700879);
          expectProjected(
            geo.project(adapter.forward(Point2.coordinates)),
            p,
            defsAccuracyProj[i],
          );
          expectProjected(
            p.project(adapter.inverse(GeoPoint2.coordinates)),
            geo,
            defsAccuracyWgs84[i],
          );
        }
      });
    }
  });

  group('Test proj4dart with defined projections (geocentric)', () {
    final adapter = proj4dart(
      'EPSG:4326',
      'WGS84 geocentric',
      toDef: '+proj=geocent +datum=WGS84',
    );
    test('Test between WGS84 lon-lat-elev(h) to WGS84 geocentric (XYZ)', () {
      // this is NOT very geodetically accurate test (values are NOT reference
      // checked), but tests that lat-lon-elev coordinates are converted
      // to geocentric XYZ and vice versa
      const geocentric = Point3(
        x: -3356242.3698167196,
        y: 5168160.035350793,
        z: 1640136.37486220,
      );
      const geodetic = GeoPoint3(
        lon: 123.0,
        lat: 15.0,
        elev: 140.0,
      );
      expectProjected(
        geodetic.project(adapter.forward(Point3.coordinates)),
        geocentric,
        0.0000001,
        0.0000001,
      );
      expectProjected(
        geocentric.project(adapter.inverse(GeoPoint3.coordinates)),
        geodetic,
        0.0000001,
        0.0000001,
      );
    });
  });
}
