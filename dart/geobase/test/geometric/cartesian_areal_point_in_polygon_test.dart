// Adaptations on the derivative work (the Dart port):
//
// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/coordinates.dart';
import 'package:geobase/geometric.dart';

import 'package:test/test.dart';

void main() {
  group('geometric-cartesian-areal-point_in_polygon tests', () {
    final outerOpen1 = [1.0, 1.0, 1.0, 7.0, 7.0, 7.0, 7.0, 1.0].positions();
    final outerClosed1 = outerOpen1.added([
      [1.0, 1.0].xy,
    ]);
    final innerOpen1 = [2.0, 2.0, 2.0, 4.0, 4.0, 4.0, 4.0, 2.0].positions();
    final innerClosed1 = innerOpen1.added([
      [2.0, 2.0].xy,
    ]);
    final polygonOpen1 = [outerOpen1, innerOpen1];
    final polygonClosed1 = [outerClosed1, innerClosed1];
    final insideInner1 = [3.0, 3.0].xy;
    final inside1 = [5.0, 5.0].xy;
    final out1 = [8.0, 8.0].xy;

    test('test outer and inner rings separately', () {
      void testRings(PositionSeries outer, PositionSeries inner) {
        expect(outer.isPointInPolygon2D(insideInner1), true);
        expect(outer.isPointInPolygon2D(inside1), true);
        expect(outer.isPointInPolygon2D(out1), false);
        expect(inner.isPointInPolygon2D(insideInner1), true);
        expect(inner.isPointInPolygon2D(inside1), false);
        expect(inner.isPointInPolygon2D(out1), false);
      }

      testRings(outerOpen1, innerOpen1);
      testRings(outerClosed1, innerClosed1);
    });

    test('test polygon with outer and inner rings', () {
      expect(polygonOpen1.isPointInPolygon2D(insideInner1), false);
      expect(polygonOpen1.isPointInPolygon2D(inside1), true);
      expect(polygonOpen1.isPointInPolygon2D(out1), false);
      expect(polygonClosed1.isPointInPolygon2D(insideInner1), false);
      expect(polygonClosed1.isPointInPolygon2D(inside1), true);
      expect(polygonClosed1.isPointInPolygon2D(out1), false);
    });

    test('test polygon with outer and two inner rings', () {
      final complex = [
        [0.0, 0.0, 10.0, 0.0, 10.0, 10.0, 0.0, 10.0].positions(),
        [2.0, 2.0, 2.0, 8.0, 8.0, 8.0, 8.0, 2.0].positions(),
        [3.0, 3.0, 3.0, 7.0, 7.0, 7.0, 7.0, 3.0].positions(),
      ];

      // Inside both holes
      expect(complex.isPointInPolygon2D([5.0, 5.0].xy), false);

      // Inside outer boundary but outside holes
      expect(complex.isPointInPolygon2D([1.0, 1.0].xy), true);

      // Inside outer boundary but outside holes
      expect(complex.isPointInPolygon2D([9.0, 9.0].xy), true);

      // Outside outer boundary
      expect(complex.isPointInPolygon2D([11.0, 11.0].xy), false);

      // Inside first hole but outside second hole
      expect(complex.isPointInPolygon2D([2.5, 2.5].xy), false);
    });

    test('test polygon from docs', () {
      final outer = [35.0, 10.0, 45.0, 45.0, 15.0, 40.0, 10.0, 20.0, 35.0, 10.0]
          .positions();
      final inner =
          [20.0, 30.0, 35.0, 35.0, 30.0, 20.0, 20.0, 30.0].positions();

      for (final pol in [
        [outer, inner],
        [
          outer.range(0, outer.positionCount),
          inner.range(0, inner.positionCount),
        ],
        [outer.reversed(), inner.reversed()],
      ]) {
        expect(pol.isPointInPolygon2D([10.0, 10.0].xy), false);
        expect(pol.isPointInPolygon2D([20.0, 20.0].xy), true);
        expect(pol.isPointInPolygon2D([35.0, 10.0].xy), true);
        expect(pol.isPointInPolygon2D([40.0, 27.5].xy), true);
        expect(pol.isPointInPolygon2D([30.0, 30.0].xy), false);
        expect(pol.isPointInPolygon2D([20.0, 30.0].xy), false);
        expect(pol.isPointInPolygon2D([20.0, 30.0000001].xy), true);
      }
    });
  });
}
