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
      final positions = polygon.exterior.toGeographicPositions;

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
}
