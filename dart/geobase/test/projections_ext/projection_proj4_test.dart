// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/common.dart';
import 'package:geobase/coordinates.dart';
import 'package:geobase/projections_proj4d.dart';

import 'package:test/test.dart';

import '../projections/projection_sample.dart';

void main() {
  group('Test proj4dart with built in projections', () {
    // here WGS84 geographic coordinates specified by CRS84

    final adapterWgs84ToWM =
        Proj4d.init(CoordRefSys.CRS84, CoordRefSys.EPSG_3857);
    final adapterWMToWgs84 = Proj4d.init(
      CoordRefSys.EPSG_3857,
      CoordRefSys.CRS84,
    );

    test('Create projection adapters', () {
      expect(
        adapterWgs84ToWM.sourceCrs.toString(),
        'http://www.opengis.net/def/crs/OGC/1.3/CRS84',
      );
      expect(
        adapterWgs84ToWM.targetCrs.toString(),
        'http://www.opengis.net/def/crs/EPSG/0/3857',
      );
      expect(adapterWgs84ToWM.tuple.fromProj.projName, 'longlat');
      expect(adapterWgs84ToWM.tuple.toProj.projName, 'merc');
      expect(
        adapterWMToWgs84.sourceCrs.toString(),
        'http://www.opengis.net/def/crs/EPSG/0/3857',
      );
      expect(
        adapterWMToWgs84.targetCrs.toString(),
        'http://www.opengis.net/def/crs/OGC/1.3/CRS84',
      );
      expect(adapterWMToWgs84.tuple.fromProj.projName, 'merc');
      expect(adapterWMToWgs84.tuple.toProj.projName, 'longlat');
    });

    test('wgs84ToWebMercator.forward', () {
      final toWebMercatorProj4a = adapterWgs84ToWM.forward;
      final toWebMercatorProj4b = adapterWMToWgs84.inverse;
      for (final coords in wgs84ToWebMercatorData) {
        final geo =
            Geographic(lon: coords[0], lat: coords[1], elev: 5.1, m: 6.2);
        final proj = Projected(x: coords[2], y: coords[3], z: 5.1, m: 6.2);
        expectPosition(
          toWebMercatorProj4a.project(geo, to: Projected.create),
          proj,
          0.01,
        );
        expectPosition(
          toWebMercatorProj4b.project(geo, to: Projected.create),
          proj,
          0.01,
        );
      }
    });

    test('wgs84ToWebMercator.inverse', () {
      final toWgs84Proj4a = adapterWgs84ToWM.inverse;
      final toWgs84Proj4b = adapterWMToWgs84.forward;
      for (final coords in wgs84ToWebMercatorData) {
        final geo =
            Geographic(lon: coords[0], lat: coords[1], elev: 5.1, m: 6.2);
        final proj = Projected(x: coords[2], y: coords[3], z: 5.1, m: 6.2);
        expectPosition(toWgs84Proj4a.project(proj, to: Geographic.create), geo);
        expectPosition(toWgs84Proj4b.project(proj, to: Geographic.create), geo);
      }
    });
  });

  group('Test proj4dart flat coordinate arrays', () {
    test('Wgs84 <-> WebMercator', () {
      // here WGS84 geographic coordinates specified by EPSG:4326

      final adapter = Proj4d.init(CoordRefSys.EPSG_4326, CoordRefSys.EPSG_3857);
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
    const defsAccuracyProj = [null, 0.1, 100.0];
    const defsAccuracyWgs84 = [null, 0.000002, 0.01];

    for (var i = 0; i < defs.length; i++) {
      final def = defs[i];
      final adapter = Proj4d.tryInit(
        CoordRefSys.EPSG_4326,
        CoordRefSys.normalized('EPSG:23700'),
        targetDef: def,
      );
      test('Test between EPSG:4326 and EPSG:23700', () {
        // here WGS84 geographic coordinates specified by EPSG:4326

        expect(adapter, isNotNull);

        if (adapter != null) {
          expect(adapter.sourceCrs.epsg, 'EPSG:4326');
          expect(adapter.targetCrs.epsg, 'EPSG:23700');

          const proj = Projected(x: 561651.8408065987, y: 172658.61998377228);
          const geo =
              Geographic(lon: 17.888058560281515, lat: 46.89226406700879);
          expectPosition(
            adapter.forward.project(geo, to: Projected.create),
            proj,
            defsAccuracyProj[i],
          );
          expectPosition(
            adapter.inverse.project(proj, to: Geographic.create),
            geo,
            defsAccuracyWgs84[i],
          );
        }
      });
    }
  });

  group('Test proj4dart with defined projections (geocentric)', () {
    // here WGS84 geographic coordinates specified by CRS84

    final adapter = Proj4d.init(
      CoordRefSys.CRS84,
      CoordRefSys.normalized('WGS84 geocentric'),
      targetDef: '+proj=geocent +datum=WGS84',
    );
    test('Test between WGS84 lon-lat-elev(h) to WGS84 geocentric (XYZ)', () {
      // this is NOT very geodetically accurate test (values are NOT reference
      // checked), but tests that lat-lon-elev coordinates are converted
      // to geocentric XYZ and vice versa
      const geocentric = Projected(
        x: -3356242.3698167196,
        y: 5168160.035350793,
        z: 1640136.37486220,
      );
      const geodetic = Geographic(
        lon: 123.0,
        lat: 15.0,
        elev: 140.0,
      );
      expectPosition(
        adapter.forward.project(geodetic, to: Projected.create),
        geocentric,
        0.0000001,
        0.0000001,
      );
      expectPosition(
        adapter.inverse.project(geocentric, to: Geographic.create),
        geodetic,
        0.0000001,
        0.0000001,
      );
    });
  });
}
