// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: require_trailing_commas

import 'package:geobase/geobase.dart';

import 'package:test/test.dart';

void main() {
  group('Spherical geodesy functions (great circle)', () {
    // with test values derived from:
    //   https://www.movable-type.co.uk/scripts/latlong.html

    const p1 = Geographic(lat: 52.205, lon: 0.119);
    const p2 = Geographic(lat: 48.857, lon: 2.351);

    const p3 = Geographic(lat: 50.066389, lon: -5.714722);
    const p4 = Geographic(lat: 58.643889, lon: -3.07);

    test('Distance haversine', () {
      // ignore: deprecated_member_use_from_same_package
      expect(distanceHaversine(p3, p4), 968853.5441168448);

      expect(p1.spherical.distanceTo(p2), closeTo(404300, 300)); // 404.3×10³ m
      expect(p1.spherical.distanceTo(p2, radius: 3959),
          closeTo(251.2, 0.03)); // 251.2 mi
      expect(p3.spherical.distanceTo(p4), 968853.5441168448);
    });

    test('Initial and final bearing', () {
      expect(p1.spherical.initialBearingTo(p2), closeTo(156.2, 0.1)); // 156.2°
      expect(p3.spherical.initialBearingTo(p4), closeTo(9.1198, 0.0001));

      expect(p1.spherical.finalBearingTo(p2), closeTo(157.9, 0.1)); // 157.9°
      expect(p3.spherical.finalBearingTo(p4), closeTo(11.2752, 0.0001));
    });

    test('Mid and intermediate points', () {
      expect(
          p1.spherical.midPointTo(p2).equals2D(
              const Geographic(lat: 50.5363, lon: 1.2746),
              toleranceHoriz: 0.0001),
          true);
      expect(
          p3.spherical.midPointTo(p4).equals2D(
              const Geographic(lat: 54.362287, lon: -4.530672),
              toleranceHoriz: 0.000001),
          true);
      expect(
          p1.spherical.intermediatePointTo(p2, fraction: 0.25).equals2D(
              const Geographic(lat: 51.3721, lon: 0.7073),
              toleranceHoriz: 0.0001),
          true);
    });

    test('Destination point', () {
      const p = Geographic(lat: 51.47788, lon: -0.00147);
      expect(
          p.spherical
              .destinationPoint(distance: 7794.0, bearing: 300.7)
              .equals2D(const Geographic(lat: 51.5136, lon: -0.0983),
                  toleranceHoriz: 0.0001),
          true);
    });

    test('Intersection point', () {
      const p = Geographic(lat: 51.8853, lon: 0.2545);
      const bearing = 108.547;
      const other = Geographic(lat: 49.0034, lon: 2.5735);
      const otherBearing = 32.435;
      expect(
          p.spherical
              .intersectionWith(
                bearing: bearing,
                other: other,
                otherBearing: otherBearing,
              )!
              .equals2D(const Geographic(lat: 50.9078, lon: 4.5084),
                  toleranceHoriz: 0.0001),
          true);
    });

    test('Cross and along track distance to great circle path', () {
      const current = Geographic(lat: 53.2611, lon: -0.7972);
      const path1 = Geographic(lat: 53.3206, lon: -1.7297);
      const path2 = Geographic(lat: 53.1887, lon: 0.1334);
      expect(current.spherical.crossTrackDistanceTo(start: path1, end: path2),
          closeTo(-307.5, 0.1));
      expect(current.spherical.alongTrackDistanceTo(start: path1, end: path2),
          closeTo(62331.49, 0.1));
    });

    test('Polygon area', () {
      const polygon = [
        Geographic(lat: 0.0, lon: 0.0),
        Geographic(lat: 1.0, lon: 0.0),
        Geographic(lat: 0.0, lon: 1.0),
        Geographic(lat: 0.0, lon: 0.0),
      ];
      expect(polygon.spherical.polygonArea(),
          closeTo(6182469722.7, 0.1)); // 6.18e9 m²
    });

    test('Polygon area from vector data polygon object', () {
      // a closed linear ring of <lon, lat> points as flat coordinate data.
      const linearRing = [0.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0];

      // create a polygon object with an exterior linear ring (and no holes)
      final polygon = Polygon.build(const [linearRing]);

      // an exterior linear ring as an iterable of geographic positions
      final positions = polygon.exterior!.toGeographicPositions;

      // test area
      expect(positions.spherical.polygonArea(),
          closeTo(6182469722.7, 0.1)); // 6.18e9 m²
    });
  });

  group('Spherical geodesy functions (rhumb line)', () {
    // with test values derived from:
    //   https://www.movable-type.co.uk/scripts/latlong.html

    const p1 = Geographic(lat: 51.127, lon: 1.338);
    const p2 = Geographic(lat: 50.964, lon: 1.853);

    test('Rhumb line distance', () {
      expect(p1.rhumb.distanceTo(p2), closeTo(40307.745, 0.001));
    });

    test('Rhumb line bearing', () {
      expect(p1.rhumb.initialBearingTo(p2), closeTo(116.721, 0.001));
      expect(p1.rhumb.finalBearingTo(p2), closeTo(116.721, 0.001));
    });

    test('Rhumb line destination point', () {
      expect(
          p1.rhumb.destinationPoint(distance: 40300.0, bearing: 116.7).equals2D(
              const Geographic(lat: 50.9642, lon: 1.8530),
              toleranceHoriz: 0.0001),
          true);
    });

    test('Rhumb line mid point', () {
      expect(
          p1.rhumb.midPointTo(p2).equals2D(
              const Geographic(lat: 51.0455, lon: 001.5957),
              toleranceHoriz: 0.0001),
          true);
    });
  });

  group('Spherical geodesy functions (great circle) / documentation', () {
    final greenwich =
        Geographic.parseDms(lat: '51°28′40″ N', lon: '0°00′05″ W');
    final sydney = Geographic.parseDms(lat: '33.8688° S', lon: '151.2093° E');

    const dd = Dms(decimals: 0);
    const dm = Dms.narrowSpace(type: DmsType.degMin, decimals: 1);

    test('distanceTo', () {
      expect(
          (greenwich.spherical.distanceTo(sydney) / 1000.0).toStringAsFixed(0),
          '16988');
    });
    test('initialBearingTo / finalBearingTo', () {
      final initialBearing = greenwich.spherical.initialBearingTo(sydney);
      final finalBearing = greenwich.spherical.finalBearingTo(sydney);
      expect('${dd.bearing(initialBearing)} -> ${dd.bearing(finalBearing)}',
          '61° -> 139°');
    });
    test('destinationPoint', () {
      expect(
          greenwich.spherical
              .destinationPoint(distance: 10000, bearing: 61.0)
              .latLonDms(format: dm),
          '51° 31.3′ N, 0° 07.5′ E');
    });
    test('midPointTo', () {
      expect(greenwich.spherical.midPointTo(sydney).latLonDms(format: dm),
          '28° 34.0′ N, 104° 41.6′ E');
    });
    test('intermediatePointTo', () {
      const results = [
        '0.0: 51° 28.7′ N 0° 00.1′ W',
        '0.1: 56° 33.4′ N 24° 42.1′ E',
        '0.2: 55° 50.8′ N 52° 19.4′ E',
        '0.3: 49° 39.2′ N 75° 34.1′ E',
        '0.4: 40° 00.4′ N 92° 22.9′ E',
        '0.5: 28° 34.0′ N 104° 41.6′ E',
        '0.6: 16° 14.5′ N 114° 29.3′ E',
        '0.7: 3° 31.3′ N 123° 05.8′ E',
        '0.8: 9° 16.6′ S 131° 28.2′ E',
        '0.9: 21° 51.8′ S 140° 28.9′ E',
        '1.0: 33° 52.1′ S 151° 12.6′ E',
      ];

      for (var fr = 0.0, i = 0; fr < 1.0; fr += 0.1, i++) {
        final ip =
            greenwich.spherical.intermediatePointTo(sydney, fraction: fr);
        expect(
            '${fr.toStringAsFixed(1)}:'
            ' ${ip.latLonDms(format: dm, separator: ' ')}',
            results[i]);
      }
    });
    test('intersectionWith', () {
      final intersection = greenwich.spherical.intersectionWith(
        bearing: 61.0,
        other: const Geographic(lat: 0.0, lon: 179.0),
        otherBearing: 270.0,
      );
      expect(intersection!.latLonDms(format: dm), '0° 00.0′ N, 125° 19.0′ E');
    });
  });

  group('Spherical geodesy functions (rhumb line) / documentation', () {
    final greenwich =
        Geographic.parseDms(lat: '51°28′40″ N', lon: '0°00′05″ W');
    final sydney = Geographic.parseDms(lat: '33.8688° S', lon: '151.2093° E');

    const dd = Dms(decimals: 0);
    const dm = Dms.narrowSpace(type: DmsType.degMin, decimals: 1);

    test('distanceTo', () {
      expect((greenwich.rhumb.distanceTo(sydney) / 1000.0).toStringAsFixed(0),
          '17670');
    });
    test('initialBearingTo / finalBearingTo', () {
      final initialBearing = greenwich.rhumb.initialBearingTo(sydney);
      final finalBearing = greenwich.rhumb.finalBearingTo(sydney);
      expect('${dd.bearing(initialBearing)} -> ${dd.bearing(finalBearing)}',
          '122° -> 122°');
    });
    test('destinationPoint', () {
      expect(
          greenwich.rhumb
              .destinationPoint(distance: 10000, bearing: 122.0)
              .latLonDms(format: dm),
          '51° 25.8′ N, 0° 07.3′ E');
    });
    test('midPointTo', () {
      expect(greenwich.rhumb.midPointTo(sydney).latLonDms(format: dm),
          '8° 48.3′ N, 80° 44.0′ E');
    });
  });
}
