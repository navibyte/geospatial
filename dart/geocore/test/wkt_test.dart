// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:test/test.dart';

import 'package:equatable/equatable.dart';

import 'package:geocore/geocore.dart';

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  group('WKT tests', () {
    setUp(() {
      // NOP
    });

    test('WKT empty geoms', () {
      expect(wktGeographic.parse('POINT EMPTY'), Point.empty());
    });

    test('WKT points using GeoPoint', () {
      expect(wktGeographic.parse('POINT (25.1 53.1)'),
          GeoPoint2.lonLat(25.1, 53.1));
      expect(wktGeographic.parse('POINT M (25.1 53.1 89.0)'),
          GeoPoint2m.lonLatM(25.1, 53.1, 89.0));
      expect(wktGeographic.parse('POINT (25.1 53.1 123.4)'),
          GeoPoint3.lonLatElev(25.1, 53.1, 123.4));
      expect(wktGeographic.parse('POINT Z (25.1 53.1 123.4)'),
          GeoPoint3.lonLatElev(25.1, 53.1, 123.4));
      expect(wktGeographic.parse('POINT ZM (25.1 53.1 123.4 89.0)'),
          GeoPoint3m.lonLatElevM(25.1, 53.1, 123.4, 89.0));
    });

    test('WKT points using projected points', () {
      expect(wktProjected.parse('POINT (25.1 53.1)'), Point2.xy(25.1, 53.1));
      expect(wktProjected.parse('POINT M (25.1 53.1 89.0)'),
          Point2m.xym(25.1, 53.1, 89.0));
      expect(wktProjected.parse('POINT (25.1 53.1 123.4)'),
          Point3.xyz(25.1, 53.1, 123.4));
      expect(wktProjected.parse('POINT Z (25.1 53.1 123.4)'),
          Point3.xyz(25.1, 53.1, 123.4));
      expect(wktProjected.parse('POINT ZM (25.1 53.1 123.4 89.0)'),
          Point3m.xyzm(25.1, 53.1, 123.4, 89.0));
    });

    test('WKT line strings', () {
      final parsed = wktGeographic.parse('LINESTRING (25.1 53.1, 25.2 53.2)');
      final expected = LineString.any(PointSeries.from(<GeoPoint>[
        GeoPoint2.lonLat(25.1, 53.1),
        GeoPoint2.lonLat(25.2, 53.2)
      ]));
      expect(parsed, expected);
    });

    test('WKT polygon', () {
      final parsed = wktGeographic.parse('POLYGON ((1 1, 1 2, 2 1, 1 1), '
          '(1.1 1.1, 1.1 1.2, 1.2 1.1, 1.1 1.1))');
      final expected = Polygon(
        BoundedSeries.from([
          LineString.ring(PointSeries.from(<GeoPoint>[
            GeoPoint2.lonLat(1, 1),
            GeoPoint2.lonLat(1, 2),
            GeoPoint2.lonLat(2, 1),
            GeoPoint2.lonLat(1, 1),
          ])),
          LineString.ring(PointSeries.from(<GeoPoint>[
            GeoPoint2.lonLat(1.1, 1.1),
            GeoPoint2.lonLat(1.1, 1.2),
            GeoPoint2.lonLat(1.2, 1.1),
            GeoPoint2.lonLat(1.1, 1.1),
          ])),
        ]),
      );
      expect(parsed, expected);
    });

    test('WKT multi polygon', () {
      final parsed = wktGeographic.parse(
          'MULTIPOLYGON (((1 1, 1 2, 2 1, 1 1)), ((3 3, 3 4, 4 3, 3 3)))');
      final expected = MultiPolygon(BoundedSeries.from([
        Polygon(
          BoundedSeries.from([
            LineString.ring(PointSeries.from(<GeoPoint>[
              GeoPoint2.lonLat(1, 1),
              GeoPoint2.lonLat(1, 2),
              GeoPoint2.lonLat(2, 1),
              GeoPoint2.lonLat(1, 1),
            ])),
          ]),
        ),
        Polygon(
          BoundedSeries.from([
            LineString.ring(PointSeries.from(<GeoPoint>[
              GeoPoint2.lonLat(3, 3),
              GeoPoint2.lonLat(3, 4),
              GeoPoint2.lonLat(4, 3),
              GeoPoint2.lonLat(3, 3),
            ])),
          ]),
        ),
      ]));
      expect(parsed, expected);
    });

    test('WKT wikipedia samples', () {
      // https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry

      // POINT (30 10)
      final point1 = Point2.from([30.0, 10.0]);
      expect(wktProjected.parse('POINT (30 10)'), point1);
      expect(Point2.parse('(30 10)'), point1);
      expect(Point2.parse('30 10'), point1);

      // POINT ZM (1 1 5 60)
      final point2 = Point3m.from([1.0, 1.0, 5.0, 60.0]);
      expect(wktProjected.parse('POINT ZM (1 1 5 60)'), point2);
      expect(Point3m.parse('1 1 5 60'), point2);

      // POINT M (1 1 80)
      final point3 = GeoPoint2m.from([1, 1, 80]);
      expect(wktGeographic.parse('POINT M (1 1 80)'), point3);
      expect(GeoPoint2m.parse('1 1 80'), point3);

      // POINT EMPTY
      expect(wktGeographic.parse('POINT EMPTY'), Point.empty());
      expect(wktProjected.parse('POINT M EMPTY'), Point.empty(hasM: true));
      expect(wktGeographic.parse('POINT Z EMPTY'), Point.empty(is3D: true));

      // MULTIPOLYGON EMPTY
      // (todo: implement geometry specific empty instances?)
      expect(wktGeographic.parse('MULTIPOLYGON EMPTY'), Geometry.empty());

      // LINESTRING (30 10, 10 30, 40 40)
      // LineString contains Point abstract types and Point2 are concrete types.
      final lineString = LineString<Point>.make(
        [
          [30.0, 10.0],
          [10.0, 30.0],
          [40.0, 40.0]
        ],
        Point2.geometry,
      );
      expect(
          wktProjected.parse('LINESTRING (30 10, 10 30, 40 40)'), lineString);
      expect(
          LineString<Point>.parse('(30 10), (10 30), (40 40)', Point2.geometry),
          lineString);
      expect(LineString<Point>.parse('30 10, 10 30, 40 40', Point2.geometry),
          lineString);

      // Same as previous but container point type more specific.
      // LineString contains GeoPoint2 types and GeoPoint2 are concrete types.
      final lineString2 = LineString.make(
        [
          [30.0, 10.0],
          [10.0, 30.0],
          [40.0, 40.0]
        ],
        GeoPoint2.geometry,
      );
      expect(wktGeographic.parse<GeoPoint2>('LINESTRING (30 10, 10 30, 40 40)'),
          lineString2);
      expect(LineString.parse('(30 10), (10 30), (40 40)', GeoPoint2.geometry),
          lineString2);
      expect(LineString.parse('30 10, 10 30, 40 40', GeoPoint2.geometry),
          lineString2);

      // POLYGON ((30 10 100, 40 40 110, 20 40 120, 10 20 130, 30 10 100))
      //    "elev" added to wikipedia sample
      // Polygon contains Point3 types and Point3 are concrete types.
      final polygon1 = Polygon.make(
        [
          [
            [30.0, 10.0, 100.0],
            [40.0, 40.0, 110.0],
            [20.0, 40.0, 120.0],
            [10.0, 20.0, 130.0],
            [30.0, 10.0, 100.0]
          ],
        ],
        Point3.geometry,
      );
      expect(
          wktProjected.parse<Point3>('POLYGON ((30 10 100, 40 40 110,'
              ' 20 40 120, 10 20 130, 30 10 100))'),
          polygon1);
      expect(
          Polygon.parse(
              '(30 10 100, 40 40 110,'
              ' 20 40 120, 10 20 130, 30 10 100)',
              Point3.geometry),
          polygon1);

      // POLYGON ((30 10 5, 40 40 6, 20 40 7, 10 20 8, 30 10 5))
      //    "m" added to wikipedia sample
      // Polygon contains Point2 types and Point2m are concrete types.
      final polygon2 = Polygon<Point2>.make(
        [
          [
            [30.0, 10.0, 5.0],
            [40.0, 40.0, 6.0],
            [20.0, 40.0, 7.0],
            [10.0, 20.0, 8.0],
            [30.0, 10.0, 5.0]
          ],
        ],
        Point2m.geometry,
      );
      expect(
          wktProjected.parse<Point2>('POLYGON M ((30 10 5, 40 40 6,'
              ' 20 40 7, 10 20 8, 30 10 5))'),
          polygon2);
      expect(
          Polygon<Point2>.parse(
              '(30 10 5, 40 40 6,'
              ' 20 40 7, 10 20 8, 30 10 5)',
              Point2m.geometry),
          polygon2);

      // POLYGON ((30 10 100 5, 40 40 110 6, 20 40 120 7,
      //           10 20 130 8, 30 10 100 5))
      //    "elev" and "m" added to wikipedia sample
      // Polygon contains GeoPoint types and GeoPoint3m are concrete types.
      final polygon3 = Polygon<GeoPoint>.make(
        [
          [
            [30.0, 10.0, 100.0, 5.0],
            [40.0, 40.0, 110.0, 6.0],
            [20.0, 40.0, 120.0, 7.0],
            [10.0, 20.0, 130.0, 8.0],
            [30.0, 10.0, 100.0, 5.0]
          ],
        ],
        GeoPoint3m.geometry,
      );
      expect(
          wktGeographic.parse('POLYGON ZM ((30 10 100 5, 40 40 110 6,'
              ' 20 40 120 7, 10 20 130 8, 30 10 100 5))'),
          polygon3);
      expect(
          Polygon<GeoPoint>.parse(
              '(30 10 100 5, 40 40 110 6,'
              ' 20 40 120 7, 10 20 130 8, 30 10 100 5)',
              GeoPoint3m.geometry),
          polygon3);

      // POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10),
      //      (20 30, 35 35, 30 20, 20 30))
      // Polygon contains GeoPoint2 types and GeoPoint2 are concrete types.
      final polygon4 = Polygon.make(
        [
          [
            [35, 10],
            [45, 45],
            [15, 40],
            [10, 20],
            [35, 10]
          ],
          [
            [20, 30],
            [35, 35],
            [30, 20],
            [20, 30]
          ],
        ],
        GeoPoint2.geometry,
      );
      expect(
          wktGeographic.parse<GeoPoint2>('POLYGON ((35 10, 45 45, 15 40, '
              '10 20, 35 10) (20 30, 35 35, 30 20, 20 30))'),
          polygon4);
      expect(
          Polygon.parse(
              '(35 10, 45 45, 15 40, '
              '10 20, 35 10) (20 30, 35 35, 30 20, 20 30)',
              GeoPoint2.geometry),
          polygon4);

      // MULTIPOINT ((10 40), (40 30), (20 20), (30 10))
      // MULTIPOINT (10 40, 40 30, 20 20, 30 10)
      // MultiPoint contains GeoPoint types and GeoPoint2 are concrete types.
      final multiPoint1 = MultiPoint<GeoPoint>.make(
        [
          [10, 40],
          [40, 30],
          [20, 20],
          [30, 10]
        ],
        GeoPoint2.geometry,
      );
      expect(
          wktGeographic.parse('MULTIPOINT ((10 40), (40 30), '
              '(20 20), (30 10))'),
          multiPoint1);
      expect(
          MultiPoint<GeoPoint>.parse(
              '(10 40), (40 30), (20 20), (30 10)', GeoPoint2.geometry),
          multiPoint1);
      expect(wktGeographic.parse('MULTIPOINT (10 40, 40 30, 20 20, 30 10)'),
          multiPoint1);
      expect(
          MultiPoint<GeoPoint>.parse(
              '10 40, 40 30, 20 20, 30 10', GeoPoint2.geometry),
          multiPoint1);

      // MULTILINESTRING ((10 10, 20 20, 10 40),
      //      (40 40, 30 30, 40 20, 30 10))
      // MultiLineString contains Point types and Point2 are concrete types.
      final multiLineString1 = MultiLineString<Point>.make(
        [
          [
            [10.0, 10.0],
            [20.0, 20.0],
            [10.0, 40.0]
          ],
          [
            [40.0, 40.0],
            [30.0, 30.0],
            [40.0, 20.0],
            [30.0, 10.0]
          ],
        ],
        Point2.geometry,
      );
      expect(
          wktProjected.parse('MULTILINESTRING ((10 10, 20 20, 10 40), '
              '(40 40, 30 30, 40 20, 30 10))'),
          multiLineString1);
      expect(
          MultiLineString<Point>.parse(
              '(10 10, 20 20, 10 40), '
              '(40 40, 30 30, 40 20, 30 10)',
              Point2.geometry),
          multiLineString1);

      // MULTIPOLYGON (((30 20, 45 40, 10 40, 30 20)),
      //     ((15 5, 40 10, 10 20, 5 10, 15 5)))
      // MultiPolygon contains GeoPoint types and GeoPoint2 are concrete types.
      final multiPolygon1 = MultiPolygon<GeoPoint>.make(
        [
          [
            [
              [30, 20],
              [45, 40],
              [10, 40],
              [30, 20]
            ],
          ],
          [
            [
              [15, 5],
              [40, 10],
              [10, 20],
              [5, 10],
              [15, 5]
            ],
          ],
        ],
        GeoPoint2.geometry,
      );
      expect(
          wktGeographic.parse('MULTIPOLYGON (((30 20, 45 40, 10 40, 30 20)), '
              '((15 5, 40 10, 10 20, 5 10, 15 5)))'),
          multiPolygon1);
      expect(
          MultiPolygon<GeoPoint>.parse(
              '((30 20, 45 40, 10 40, 30 20)), '
              '((15 5, 40 10, 10 20, 5 10, 15 5))',
              GeoPoint2.geometry),
          multiPolygon1);

      // MULTIPOLYGON (((40 40, 20 45, 45 30, 40 40)),
      //            ((20 35, 10 30, 10 10, 30 5, 45 20, 20 35),
      //            (30 20, 20 15, 20 25, 30 20)))
      // MultiPolygon contains GeoPoint2 types and GeoPoint2 are concrete types.
      final multiPolygon2 = MultiPolygon.make(
        [
          [
            [
              [40, 40],
              [20, 45],
              [45, 30],
              [40, 40]
            ],
          ],
          [
            [
              [20, 35],
              [10, 30],
              [10, 10],
              [30, 5],
              [45, 20],
              [20, 35]
            ],
            [
              [30, 20],
              [20, 15],
              [20, 25],
              [30, 20]
            ],
          ],
        ],
        GeoPoint2.geometry,
      );
      expect(
          wktGeographic
              .parse<GeoPoint2>('MULTIPOLYGON (((40 40, 20 45, 45 30, 40 40)), '
                  '((20 35, 10 30, 10 10, 30 5, 45 20, 20 35), '
                  '(30 20, 20 15, 20 25, 30 20)))'),
          multiPolygon2);
      expect(
          MultiPolygon.parse(
              '((40 40, 20 45, 45 30, 40 40)), '
              '((20 35, 10 30, 10 10, 30 5, 45 20, 20 35), '
              '(30 20, 20 15, 20 25, 30 20))',
              GeoPoint2.geometry),
          multiPolygon2);
    });
  });
}
