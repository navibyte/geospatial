// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_declarations

import 'package:geobase/constants.dart';
import 'package:geobase/coordinates.dart';
import 'package:geobase/vector.dart';

import 'package:meta/meta.dart';

import 'package:test/test.dart';

void main() {
  group('Projected class', () {
    test('Coordinate access and factories', () {
      const p1 = Projected(x: 1.0, y: 2.0);
      const p2 = Projected(x: 1.0, y: 2.0, z: 3.0);
      const p3 = Projected(x: 1.0, y: 2.0, m: 4.0);
      const p4 = Projected(x: 1.0, y: 2.0, z: 3.0, m: 4.0);
      expect([p1.x, p1.y], p1.values);
      expect([p2.x, p2.y, p2.z], p2.values);
      expect([p3.x, p3.y, p3.m], p3.values);
      expect([p4.x, p4.y, p4.z, p4.m], p4.values);
      expect([p1.x, p1.y, 0, 0], [p1[0], p1[1], p1[2], p1[3]]);
      expect([p2.x, p2.y, p2.z, 0], [p2[0], p2[1], p2[2], p2[3]]);
      expect([p3.x, p3.y, p3.m, 0], [p3[0], p3[1], p3[2], p3[3]]);
      expect([p4.x, p4.y, p4.z, p4.m], [p4[0], p4[1], p4[2], p4[3]]);
      expect(
        [p1.optZ, p1.optM, p2.optM, p3.optZ],
        [null, null, null, null],
      );

      expect(Projected.build(const [1.0, 2.0]), p1);
      expect(Projected.build(const [1.0, 2.0, 3.0]), p2);
      expect(Projected.build(const [1.0, 2.0, 4.0]), isNot(p3));
      expect(Projected.build(const [1.0, 2.0, 4.0], type: Coords.xym), p3);
      expect(Projected.build(const [1.0, 2.0, 3.0, 4.0]), p4);

      expect(Projected.parse('1.0,2.0'), p1);
      expect(Projected.parse('1.0,2.0,3.0'), p2);
      expect(Projected.parse('1.0,2.0,4.0', type: Coords.xym), p3);
      expect(Projected.parse('1.0,2.0,3.0,4.0'), p4);

      expect(Projected.parse(p1.toString()), p1);
      expect(Projected.parse(p2.toString()), p2);
      expect(Projected.parse(p3.toString(), type: Coords.xym), p3);
      expect(Projected.parse(p4.toString()), p4);
      expect(Projected.parse('1.0 2.0 3.0 4.0', delimiter: ' '), p4);

      expect(() => Projected.build(const [1.0]), throwsFormatException);
      expect(() => Projected.parse('1.0'), throwsFormatException);
      expect(() => Projected.parse('1.0,2.0,x'), throwsFormatException);
    });

    test('Equals and hashCode', () {
      // test Position itself
      final one = 1.0;
      final two = 2.0;
      const p1 = Projected(x: 1.0, y: 2.0, z: 3.0, m: 4.0);
      final p2 = Projected(x: one, y: 2.0, z: 3.0, m: 4.0);
      final p3 = Projected(x: two, y: 2.0, z: 3.0, m: 4.0);
      expect(p1, p2);
      expect(p1, isNot(p3));
      expect(p1.hashCode, p2.hashCode);
      expect(p1.hashCode, isNot(p3.hashCode));
      expect(p1.equals2D(p2), true);
      expect(p1.equals2D(p3), false);
      expect(p1.equals3D(p2), true);
      expect(p1.equals3D(p3), false);

      // test private class that implements Position interface
      const t1 = _TestXYZM(x: 1.0, y: 2.0, z: 3.0, m: 4.0);
      final t2 = _TestXYZM(x: one, y: 2.0, z: 3.0, m: 4.0);
      final t3 = _TestXYZM(x: two, y: 2.0, z: 3.0, m: 4.0);
      expect(t1, t2);
      expect(t1, isNot(t3));
      expect(t1.hashCode, t2.hashCode);
      expect(t1.hashCode, isNot(t3.hashCode));

      // copy to
      expect(p1, p1.copyTo(Projected.create));
      expect(p1, p1.copyTo(Geographic.create));
      expect(p1, p1.copyTo(_TestXYZM.create));
      expect(t1, t1.copyTo(Projected.create));
      expect(t1, t1.copyTo(_TestXYZM.create));

      // test between Position and class implementing it's interface
      expect(p1, t2);
      expect(t1, p2);
      expect(p1, isNot(t3));
      expect(t1, isNot(p3));
      expect(p1.hashCode, t2.hashCode);
      expect(p1.hashCode, isNot(t3.hashCode));

      // with some coordinates missing or other type
      const p5 = Projected(x: 1.0, y: 2.0, z: 3.0);
      const p6 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0);
      const p7 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0, m: 4.0);
      expect(p1, isNot(p5));
      expect(p1, isNot(p6));
      expect(p1, p7);
      expect(p5, p6);
      expect(p6, isNot(p7));

      final p8 = const Projected(x: 1.0, y: 2.0);
      expect(p1.equals2D(p8), true);
      expect(p1.equals3D(p8), false);
    });

    test('Equals with tolerance', () {
      const p1 = Projected(x: 1.0002, y: 2.0002, z: 3.002, m: 4.0);
      const p2 = Projected(x: 1.0003, y: 2.0003, z: 3.003, m: 4.0);
      expect(p1.equals2D(p2), false);
      expect(p1.equals3D(p2), false);
      expect(p1.equals2D(p2, toleranceHoriz: 0.00011), true);
      expect(p1.equals3D(p2, toleranceHoriz: 0.00011), false);
      expect(p1.equals2D(p2, toleranceHoriz: 0.00011), true);
      expect(
        p1.equals3D(p2, toleranceHoriz: 0.00011, toleranceVert: 0.0011),
        true,
      );
      expect(p1.equals2D(p2, toleranceHoriz: 0.00009), false);
      expect(
        p1.equals3D(p2, toleranceHoriz: 0.00011, toleranceVert: 0.0009),
        false,
      );
    });

    test('Copy with', () {
      expect(
        const Projected(x: 1, y: 1).copyWith(),
        const Projected(x: 1, y: 1),
      );
      expect(
        const Projected(x: 1, y: 1).copyWith(y: 2),
        const Projected(x: 1, y: 2),
      );
      expect(
        const Projected(x: 1, y: 1).copyWith(z: 2),
        const Projected(x: 1, y: 1, z: 2),
      );
    });
  });

  group('Geographic class', () {
    test('Longitude normalization/clipping & latitude clipping', () {
      // normal values
      final closeTo174 = closeTo(174.4, 0.0000000000001);
      expect((-185.6).wrapLongitude(), closeTo174);
      expect((-185.6 - 360.0).wrapLongitude(), closeTo174);
      expect((-185.6 + 360.0).wrapLongitude(), closeTo174);
      expect((-185.6 - 5 * 360.0).wrapLongitude(), closeTo174);
      expect((-185.6 + 8 * 360.0).wrapLongitude(), closeTo174);
      expect((-180.0).wrapLongitude(), -180.0);
      expect((-179.534343).wrapLongitude(), -179.534343);
      expect(139.423.wrapLongitude(), 139.423);
      expect(179.99999999.wrapLongitude(), 179.99999999);
      expect(180.0.wrapLongitude(), 180.0);
      expect(185.6.wrapLongitude(), closeTo(-174.4, 0.0000000000001));
      expect((-185.6).clipLongitude(), -180.0);
      expect((-180.0).clipLongitude(), -180.0);
      expect((-179.534343).clipLongitude(), -179.534343);
      expect(139.423.clipLongitude(), 139.423);
      expect(179.99999999.clipLongitude(), 179.99999999);
      expect(180.0.clipLongitude(), 180.0);
      expect(185.6.clipLongitude(), 180.0);
      expect(90.0.clipLatitude(), 90.0);
      expect((-90.0).clipLatitude(), -90.0);
      expect(84.345.clipLatitude(), 84.345);
      expect(90.1.clipLatitude(), 90.0);
      expect(90.0.clipLatitudeWebMercator(), maxLatitudeWebMercator);
      expect((-90.0).clipLatitudeWebMercator(), minLatitudeWebMercator);
      expect(84.345.clipLatitudeWebMercator(), 84.345);
      expect(85.064.clipLatitudeWebMercator(), maxLatitudeWebMercator);

      // NaN values
      expect(double.nan.wrapLongitude(), isNaN);
      expect(double.nan.clipLongitude(), isNaN);
      expect(double.nan.clipLatitude(), isNaN);
      expect(double.nan.clipLatitudeWebMercator(), isNaN);
    });

    test('Latitude normalization', () {
      expect(0.0.wrapLatitude(), 0.0);
      expect(23.0.wrapLatitude(), 23.0);
      expect(-19.0.wrapLatitude(), -19.0);
      expect(-89.0.wrapLatitude(), -89.0);
      expect(-92.0.wrapLatitude(), -88.0);
      expect((-92.0 - 2 * 180.0).wrapLatitude(), -88.0);
      expect((-269.0).wrapLatitude(), 89.0);
      expect(89.0.wrapLatitude(), 89.0);
      expect(269.0.wrapLatitude(), -89.0);
      expect(92.0.wrapLatitude(), 88.0);

      expect(183.62.wrapLatitude(), closeTo(-3.62, 0.000000000001));
      expect(176.38.wrapLatitude(), closeTo(3.62, 0.000000000001));
      expect((-183.62).wrapLatitude(), closeTo(3.62, 0.000000000001));
      expect(-176.38.wrapLatitude(), closeTo(-3.62, 0.000000000001));

      expect(double.nan.wrapLatitude(), isNaN);
    });

    test('Bearing normalization', () {
      expect(0.0.wrap360(), 0.0);
      expect(360.0.wrap360(), 0.0);
      expect((-360.0).wrap360(), 0.0);
      expect(0.001.wrap360(), 0.001);
      expect(360.001.wrap360(), closeTo(0.001, 0.000000001));
      expect((-359.999).wrap360(), closeTo(0.001, 0.000000001));
      expect((-4.34).wrap360(), 355.66);
      expect((-4.34 - 360.0).wrap360(), 355.66);
      expect((-4.34 + 360.0).wrap360(), 355.66);
      expect((-4.34 - 7 * 360.0).wrap360(), closeTo(355.66, 0.00000000001));
      expect((-4.34 + 7 * 360.0).wrap360(), closeTo(355.66, 0.00000000001));
      expect(double.nan.wrap360(), isNaN);
    });

    test('Dms parsing and formatting', () {
      const p1 = Geographic(lon: -0.0014, lat: 51.4778);
      final p1Lat = p1.latDms();
      final p1Lon = p1.lonDms();
      final p1LatLon = p1.latLonDms(separator: ' ');

      expect(p1Lat, '51.4778°N');
      expect(p1Lon, '0.0014°W');
      expect(p1LatLon, '51.4778°N 0.0014°W');

      expect(
        Geographic.parseDms(lat: p1Lat, lon: p1Lon)
            .equals2D(p1, toleranceHoriz: 0.001),
        true,
      );

      const format = Dms(
        type: DmsType.degMinSec,
        decimals: 3,
        zeroPadMinSec: false,
      );
      expect(p1.latLonDms(format: format), '51°28′40.080″N, 0°0′5.040″W');

      const p2 = Geographic(lon: -0.0014, lat: 51.4778, elev: 45.83764);
      expect(
        p2.latLonDms(format: format, separator: ' '),
        '51°28′40.080″N 0°0′5.040″W 45.84m',
      );
      expect(
        p2.latLonDms(format: format),
        '51°28′40.080″N, 0°0′5.040″W, 45.84m',
      );
    });

    test('Dms for documentation examples', () {
      const p1 = Geographic(lon: -0.0014, lat: 51.4778);

      expect(p1.latDms(), '51.4778°N');
      expect(p1.lonDms(), '0.0014°W');

      const dm = Dms(type: DmsType.degMin, decimals: 3);
      expect(p1.latDms(dm), '51°28.668′N');
      expect(p1.lonDms(dm), '0°00.084′W');

      const dms = Dms.narrowSpace(type: DmsType.degMinSec);
      expect(p1.latDms(dms), '51° 28′ 40″ N');
      expect(p1.lonDms(dms), '0° 00′ 05″ W');
    });

    test('Coordinate access and factories', () {
      const p1 = Geographic(lon: 1.0, lat: 2.0);
      const p2 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0);
      const p3 = Geographic(lon: 1.0, lat: 2.0, m: 4.0);
      const p4 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0, m: 4.0);
      expect([p1.lon, p1.lat], p1.values);
      expect([p2.lon, p2.lat, p2.elev], p2.values);
      expect([p3.lon, p3.lat, p3.m], p3.values);
      expect([p4.lon, p4.lat, p4.elev, p4.m], p4.values);
      expect([p1.lon, p1.lat, 0, 0], [p1[0], p1[1], p1[2], p1[3]]);
      expect([p2.lon, p2.lat, p2.elev, 0], [p2[0], p2[1], p2[2], p2[3]]);
      expect([p3.lon, p3.lat, p3.m, 0], [p3[0], p3[1], p3[2], p3[3]]);
      expect([p4.lon, p4.lat, p4.elev, p4.m], [p4[0], p4[1], p4[2], p4[3]]);
      expect(
        [p1.optElev, p1.optM, p2.optM, p3.optElev],
        [null, null, null, null],
      );

      expect(Geographic.build(const [1.0, 2.0]), p1);
      expect(Geographic.build(const [1.0, 2.0, 3.0]), p2);
      expect(Geographic.build(const [1.0, 2.0, 4.0]), isNot(p3));
      expect(Geographic.build(const [1.0, 2.0, 3.0, 4.0]), p4);

      expect(Geographic.parse('1.0,2.0'), p1);
      expect(Geographic.parse('1.0,2.0,3.0'), p2);
      expect(Geographic.parse('1.0,2.0,4.0', type: Coords.xym), p3);
      expect(Geographic.parse('1.0,2.0,3.0,4.0'), p4);
    });

    test('Equals and hashCode', () {
      final one = 1.0;
      final two = 2.0;
      const p1 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0, m: 4.0);
      final p2 = Geographic(lon: one, lat: 2.0, elev: 3.0, m: 4.0);
      final p3 = Geographic(lon: two, lat: 2.0, elev: 3.0, m: 4.0);
      expect(p1, p2);
      expect(p1, isNot(p3));
      expect(p1.hashCode, p2.hashCode);
      expect(p1.hashCode, isNot(p3.hashCode));
      expect(p1.equals2D(p2), true);
      expect(p1.equals2D(p3), false);
      expect(p1.equals3D(p2), true);
      expect(p1.equals3D(p3), false);

      // copy to
      expect(p1, p1.copyTo(Geographic.create));
      expect(p1, p1.copyTo(Projected.create));
    });

    test('Equals with tolerance', () {
      const p1 = Geographic(lon: 1.0002, lat: 2.0002, elev: 3.002, m: 4.0);
      const p2 = Geographic(lon: 1.0003, lat: 2.0003, elev: 3.003, m: 4.0);
      expect(p1.equals2D(p2), false);
      expect(p1.equals3D(p2), false);
      expect(p1.equals2D(p2, toleranceHoriz: 0.00011), true);
      expect(p1.equals3D(p2, toleranceHoriz: 0.00011), false);
      expect(p1.equals2D(p2, toleranceHoriz: 0.00011), true);
      expect(
        p1.equals3D(p2, toleranceHoriz: 0.00011, toleranceVert: 0.0011),
        true,
      );
      expect(p1.equals2D(p2, toleranceHoriz: 0.00009), false);
      expect(
        p1.equals3D(p2, toleranceHoriz: 0.00011, toleranceVert: 0.0009),
        false,
      );

      expect(p1.equals2D(p1), true);
      expect(p1.equals3D(p1), true);
      expect(p1.equals2D(p2), false);
      expect(p1.equals3D(p2), false);

      const p3 = Geographic(
        lon: 1.0002 + 0.99 * defaultEpsilon,
        lat: 2.0002,
        elev: 3.002 + 0.99 * defaultEpsilon,
        m: 4.0,
      );
      const p4 = Geographic(
        lon: 1.0002 + 0.99 * defaultEpsilon,
        lat: 2.0002,
        elev: 3.002 + 1.97 * defaultEpsilon,
        m: 4.0,
      );
      const p5 = Geographic(
        lon: 1.0002 + 1.97 * defaultEpsilon,
        lat: 2.0002,
        elev: 3.002 + 1.97 * defaultEpsilon,
        m: 4.0,
      );
      expect(p1.equals2D(p3), true);
      expect(p1.equals3D(p3), true);
      expect(p1.equals2D(p4), true);
      expect(p1.equals3D(p4), false);
      expect(p1.equals2D(p5), false);
      expect(p1.equals3D(p5), false);
      expect(p3.equals2D(p4), true);
      expect(p3.equals3D(p4), true);
      expect(p4.equals2D(p5), true);
      expect(p4.equals3D(p5), true);
    });

    test('Clamping longitude and latitude in constructor', () {
      expect(const Geographic(lon: 34.0, lat: 18.2).lon, 34.0);
      expect(const Geographic(lon: -326.0, lat: 18.2).lon, 34.0);
      expect(const Geographic(lon: 394.0, lat: 18.2).lon, 34.0);
      expect(const Geographic(lon: -180.0, lat: 18.2).lon, -180.0);
      expect(const Geographic(lon: -181.0, lat: 18.2).lon, 179.0);
      expect(const Geographic(lon: -541.0, lat: 18.2).lon, 179.0);
      expect(const Geographic(lon: 180.0, lat: 18.2).lon, 180.0);
      expect(const Geographic(lon: 181.0, lat: 18.2).lon, -179.0);
      expect(const Geographic(lon: 541.0, lat: 18.2).lon, -179.0);
      expect(const Geographic(lon: 34.2, lat: -90.0).lat, -90.0);
      expect(const Geographic(lon: 34.2, lat: -91.0).lat, -90.0);
      expect(const Geographic(lon: 34.2, lat: 90.0).lat, 90.0);
      expect(const Geographic(lon: 34.2, lat: 91.0).lat, 90.0);
    });

    test('Copy with', () {
      expect(
        const Geographic(lon: 1.0, lat: 1.0).copyWith(),
        const Geographic(lon: 1.0, lat: 1.0),
      );
      expect(
        const Geographic(lon: 1.0, lat: 1.0).copyWith(y: 2.0),
        const Geographic(lon: 1.0, lat: 2.0),
      );
      expect(
        const Geographic(lon: 1.0, lat: 1.0).copyWith(z: 2.0),
        const Geographic(lon: 1.0, lat: 1.0, elev: 2.0),
      );
    });
  });

  group('Other tests', () {
    test('Coordinate order', () {
      // XY
      _testCoordinateOrder('1.0,2.0', [1.0, 2.0]);
      _testCoordinateOrder('1.0,2.0', [1.0, 2.0], Coords.xy);

      // XYZ
      _testCoordinateOrder('1.0,2.0,3.0', [1.0, 2.0, 3.0]);
      _testCoordinateOrder('1.0,2.0,3.0', [1.0, 2.0, 3.0], Coords.xyz);

      // XYM
      _testCoordinateOrder('1.0,2.0,4.0', [1.0, 2.0, 4.0], Coords.xym);

      // XYZM
      _testCoordinateOrder('1.0,2.0,3.0,4.0', [1.0, 2.0, 3.0, 4.0]);
      _testCoordinateOrder(
        '1.0,2.0,3.0,4.0',
        [1.0, 2.0, 3.0, 4.0],
        Coords.xyzm,
      );
    });

    test('createFromObject', () {
      final li4 = [1, 2, 3, 4];
      const p4 = Projected(x: 1, y: 2, z: 3, m: 4);

      expect(
        Position.createFromObject(p4, to: Projected.create),
        p4,
      );
      expect(
        Position.createFromObject(p4, to: Projected.create, type: Coords.xy),
        Projected.build(const [1, 2]),
      );
      expect(
        Position.createFromObject(p4, to: Projected.create, type: Coords.xyz),
        Projected.build(const [1, 2, 3]),
      );
      expect(
        Position.createFromObject(p4, to: Projected.create, type: Coords.xym),
        Projected.build(const [1, 2, 4], type: Coords.xym),
      );
      expect(
        Position.createFromObject(p4, to: Projected.create, type: Coords.xyzm),
        Projected.build(const [1, 2, 3, 4]),
      );

      expect(
        Position.createFromObject(li4, to: Projected.create),
        p4,
      );
      expect(
        Position.createFromObject(li4, to: Projected.create, type: Coords.xy),
        Projected.build(const [1, 2]),
      );
      expect(
        Position.createFromObject(li4, to: Projected.create, type: Coords.xyz),
        Projected.build(const [1, 2, 3]),
      );
      expect(
        Position.createFromObject(
          const [1, 2, 4],
          to: Projected.create,
          type: Coords.xym,
        ),
        Projected.build(const [1, 2, 4], type: Coords.xym),
      );
      expect(
        Position.createFromObject(li4, to: Projected.create, type: Coords.xyzm),
        Projected.build(const [1, 2, 3, 4]),
      );
    });
  });

  group('Position values printed as String', () {
    const p3dec = Projected(x: 10.1, y: 20.217, z: 30.73942);
    const p3 = Projected(x: 10.001, y: 20.000, z: 30);
    const p3i = Projected(x: 10, y: 20, z: 30);

    test('toText with default delimiter', () {
      expect(p3dec.toText(), '10.1,20.217,30.73942');
      expect(p3dec.toText(decimals: 0), '10,20,31');
      expect(p3dec.toText(decimals: 3), '10.100,20.217,30.739');
      expect(p3.toText(decimals: 3), '10.001,20,30');
      expect(p3.toText(decimals: 2), '10.00,20,30');
      expect(p3i.toText(decimals: 2), '10,20,30');
    });

    test('toText swapping X and Y', () {
      expect(p3dec.toText(swapXY: true), '20.217,10.1,30.73942');
      expect(p3dec.toText(decimals: 0, swapXY: true), '20,10,31');
      expect(p3.toText(decimals: 3, swapXY: true), '20,10.001,30');
      expect(p3i.toText(decimals: 2, swapXY: true), '20,10,30');

      expect(
        Geographic.build(const [1.1, 2.2]).toText(swapXY: true),
        '2.2,1.1',
      );
      expect(
        Geographic.build(const [1.1, 2.2, 3.3]).toText(swapXY: true),
        '2.2,1.1,3.3',
      );
      expect(
        Geographic.build(const [1.1, 2.2, 3.3, 4.4]).toText(swapXY: true),
        '2.2,1.1,3.3,4.4',
      );
    });

    test('toText with space delimiter', () {
      expect(p3dec.toText(delimiter: ' '), '10.1 20.217 30.73942');
      expect(p3dec.toText(decimals: 0, delimiter: ' '), '10 20 31');
      expect(p3dec.toText(decimals: 3, delimiter: ' '), '10.100 20.217 30.739');
      expect(p3.toText(decimals: 3, delimiter: ' '), '10.001 20 30');
      expect(p3.toText(decimals: 2, delimiter: ' '), '10.00 20 30');
      expect(p3i.toText(decimals: 2, delimiter: ' '), '10 20 30');
    });

    test('toText with space delimiter (cross test using WKT format)', () {
      final format = WKT.coordinate;
      var wkt = format.encoder()..writer.position(p3dec);
      expect(wkt.toText(), '10.1 20.217 30.73942');
      wkt = format.encoder(decimals: 0)..writer.position(p3dec);
      expect(wkt.toText(), '10 20 31');
      wkt = format.encoder(decimals: 3)..writer.position(p3dec);
      expect(wkt.toText(), '10.100 20.217 30.739');
      wkt = format.encoder(decimals: 3)..writer.position(p3);
      expect(wkt.toText(), '10.001 20 30');
      wkt = format.encoder(decimals: 2)..writer.position(p3);
      expect(wkt.toText(), '10.00 20 30');
      wkt = format.encoder(decimals: 2)..writer.position(p3i);
      expect(wkt.toText(), '10 20 30');
    });
  });
}

void _testCoordinateOrder(String text, Iterable<num> coords, [Coords? type]) {
  final factories = [Projected.create, Geographic.create];

  for (final factory in factories) {
    final fromCoords = Position.buildPosition(coords, to: factory, type: type);
    final fromText = Position.parsePosition(text, to: factory, type: type);
    expect(fromCoords, fromText);
    expect(fromCoords.toString(), text);
    expect(fromText.values, coords);
    for (var i = 0; i < coords.length; i++) {
      expect(fromText[i], coords.elementAt(i));
    }

    expect(
      Position.createFromObject(coords, to: factory, type: type),
      fromCoords,
    );
  }
}

@immutable
class _TestXYZM implements Projected {
  const _TestXYZM({
    required this.x,
    required this.y,
    required this.z,
    required this.m,
  });

  const _TestXYZM.create({
    required double x,
    required double y,
    double? z,
    double? m,
  }) : this(x: x, y: y, z: z ?? 0, m: m ?? 0);

  @override
  bool conformsScheme(PositionScheme scheme) => scheme == Projected.scheme;

  @override
  R copyTo<R extends Position>(CreatePosition<R> factory) =>
      factory.call(x: x, y: y, z: z, m: m);

  @override
  Projected copyWith({double? x, double? y, double? z, double? m}) => _TestXYZM(
        x: x ?? this.x,
        y: y ?? this.y,
        z: z ?? this.z,
        m: m ?? this.m,
      );

  @override
  Projected copyByType(Coords type) => this.type == type
      ? this
      : _TestXYZM.create(
          x: x,
          y: y,
          z: type.is3D ? z : null,
          m: type.isMeasured ? m : null,
        );

  @override
  Projected packed() => this;

  @override
  Geographic project(Projection projection) =>
      projection.project(this, to: Geographic.create);

  @override
  Projected transform(TransformPosition transform) => transform(this);

  @override
  double operator [](int i) => Position.getValue(this, i);

  @override
  // ignore: unnecessary_this
  Iterable<double> get values => Position.getValues(this, type: this.type);

  @override
  Iterable<double> valuesByType(Coords type) =>
      Position.getValues(this, type: type);

  @override
  final double x;
  @override
  final double y;
  @override
  final double z;
  @override
  final double m;

  @override
  double? get optZ => z;

  @override
  double? get optM => m;

  @override
  int get spatialDimension => type.spatialDimension;

  @override
  int get coordinateDimension => type.coordinateDimension;

/*
  @override
  bool get isGeographic => false;
*/

  @override
  bool get is3D => true;

  @override
  bool get isMeasured => true;

  @override
  Coords get type => coordType;

  @override
  Coords get coordType => Coords.select(
        is3D: is3D,
        isMeasured: isMeasured,
      );

  @override
  String toText({
    String delimiter = ',',
    int? decimals,
    bool swapXY = false,
  }) {
    final buf = StringBuffer();
    Position.writeValues(
      this,
      buf,
      delimiter: delimiter,
      decimals: decimals,
      swapXY: swapXY,
    );
    return buf.toString();
  }

  @override
  String toString() => '$x,$y,$z,$m';

  @override
  bool equalsCoords(Position other) => this == other;

  @override
  bool equals2D(
    Position other, {
    double toleranceHoriz = defaultEpsilon,
  }) =>
      Position.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  @override
  bool equals3D(
    Position other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) =>
      Position.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  @override
  bool operator ==(Object other) =>
      other is Position && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);
}
