// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_constructors,require_trailing_commas
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:equatable/equatable.dart';

import 'package:geobase/vector.dart';
import 'package:geocore/geocore.dart';

import 'package:test/test.dart';

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  group('WKT tests', () {
    setUp(() {
      // NOP
    });

    test('WKT empty geoms', () {
      expect(wktGeographic.parse('POINT EMPTY'), Geometry.empty(Geom.point));
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

    test('WKT points using specific point factory', () {
      final wktParser2Dm = wkt(Point2.coordinates, Point2m.coordinates);
      expect(wktParser2Dm.parse('POINT (25.1 53.1)'), Point2.xy(25.1, 53.1));
      expect(wktParser2Dm.parse('POINT M (25.1 53.1 89.0)'),
          Point2m.xym(25.1, 53.1, 89.0));

      final wktParser3Dm = wkt(Point3.coordinates, Point3m.coordinates);
      expect(wktParser3Dm.parse('POINT (25.1 53.1 123.4)'),
          Point3.xyz(25.1, 53.1, 123.4));
      expect(wktParser3Dm.parse('POINT Z (25.1 53.1 123.4)'),
          Point3.xyz(25.1, 53.1, 123.4));
      expect(wktParser3Dm.parse('POINT ZM (25.1 53.1 123.4 89.0)'),
          Point3m.xyzm(25.1, 53.1, 123.4, 89.0));

      final wktParser3D = wkt(Point3.coordinates);
      expect(wktParser3D.parse('POINT (25.1 53.1 123.4)'),
          Point3.xyz(25.1, 53.1, 123.4));
      expect(wktParser3D.parse('POINT Z (25.1 53.1 123.4)'),
          Point3.xyz(25.1, 53.1, 123.4));
      expect(wktParser3D.parse('POINT ZM (25.1 53.1 123.4 89.0)'),
          Point3.xyz(25.1, 53.1, 123.4));
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
      expect(wktGeographic.parse('POINT EMPTY'), Geometry.empty(Geom.point));
      expect(wktProjected.parse('POINT M EMPTY'), Geometry.empty(Geom.point));
      expect(wktGeographic.parse('POINT Z EMPTY'), Geometry.empty(Geom.point));

      // MULTIPOLYGON EMPTY
      // (todo: implement geometry specific empty instances?)
      expect(wktGeographic.parse('MULTIPOLYGON EMPTY'),
          Geometry.empty(Geom.multiPolygon));

      // LINESTRING (30 10, 10 30, 40 40)
      // LineString contains Point abstract types and Point2 are concrete types.
      final lineString = LineString<Point>.make(
        [
          [30.0, 10.0],
          [10.0, 30.0],
          [40.0, 40.0]
        ],
        Point2.coordinates,
      );
      expect(
          wktProjected.parse('LINESTRING (30 10, 10 30, 40 40)'), lineString);
      expect(
          LineString<Point>.parse(
              '(30 10), (10 30), (40 40)', Point2.coordinates),
          lineString);
      expect(LineString<Point>.parse('30 10, 10 30, 40 40', Point2.coordinates),
          lineString);

      // Same as previous but container point type more specific.
      // LineString contains GeoPoint2 types and GeoPoint2 are concrete types.
      final lineString2 = LineString.make(
        [
          [30.0, 10.0],
          [10.0, 30.0],
          [40.0, 40.0]
        ],
        GeoPoint2.coordinates,
      );
      expect(wktGeographic.parse<GeoPoint2>('LINESTRING (30 10, 10 30, 40 40)'),
          lineString2);
      expect(
          LineString.parse('(30 10), (10 30), (40 40)', GeoPoint2.coordinates),
          lineString2);
      expect(LineString.parse('30 10, 10 30, 40 40', GeoPoint2.coordinates),
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
        Point3.coordinates,
      );
      expect(
          wktProjected.parse<Point3>('POLYGON ((30 10 100, 40 40 110,'
              ' 20 40 120, 10 20 130, 30 10 100))'),
          polygon1);
      expect(
          Polygon.parse(
              '(30 10 100, 40 40 110,'
              ' 20 40 120, 10 20 130, 30 10 100)',
              Point3.coordinates),
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
        Point2m.coordinates,
      );
      expect(
          wktProjected.parse<Point2>('POLYGON M ((30 10 5, 40 40 6,'
              ' 20 40 7, 10 20 8, 30 10 5))'),
          polygon2);
      expect(
          Polygon<Point2>.parse(
              '(30 10 5, 40 40 6,'
              ' 20 40 7, 10 20 8, 30 10 5)',
              Point2m.coordinates),
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
        GeoPoint3m.coordinates,
      );
      expect(
          wktGeographic.parse('POLYGON ZM ((30 10 100 5, 40 40 110 6,'
              ' 20 40 120 7, 10 20 130 8, 30 10 100 5))'),
          polygon3);
      expect(
          Polygon<GeoPoint>.parse(
              '(30 10 100 5, 40 40 110 6,'
              ' 20 40 120 7, 10 20 130 8, 30 10 100 5)',
              GeoPoint3m.coordinates),
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
        GeoPoint2.coordinates,
      );
      expect(
          wktGeographic.parse<GeoPoint2>('POLYGON ((35 10, 45 45, 15 40, '
              '10 20, 35 10) (20 30, 35 35, 30 20, 20 30))'),
          polygon4);
      expect(
          Polygon.parse(
              '(35 10, 45 45, 15 40, '
              '10 20, 35 10) (20 30, 35 35, 30 20, 20 30)',
              GeoPoint2.coordinates),
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
        GeoPoint2.coordinates,
      );
      expect(
          wktGeographic.parse('MULTIPOINT ((10 40), (40 30), '
              '(20 20), (30 10))'),
          multiPoint1);
      expect(
          MultiPoint<GeoPoint>.parse(
              '(10 40), (40 30), (20 20), (30 10)', GeoPoint2.coordinates),
          multiPoint1);
      expect(wktGeographic.parse('MULTIPOINT (10 40, 40 30, 20 20, 30 10)'),
          multiPoint1);
      expect(
          MultiPoint<GeoPoint>.parse(
              '10 40, 40 30, 20 20, 30 10', GeoPoint2.coordinates),
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
        Point2.coordinates,
      );
      expect(
          wktProjected.parse('MULTILINESTRING ((10 10, 20 20, 10 40), '
              '(40 40, 30 30, 40 20, 30 10))'),
          multiLineString1);
      expect(
          MultiLineString<Point>.parse(
              '(10 10, 20 20, 10 40), '
              '(40 40, 30 30, 40 20, 30 10)',
              Point2.coordinates),
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
        GeoPoint2.coordinates,
      );
      expect(
          wktGeographic.parse('MULTIPOLYGON (((30 20, 45 40, 10 40, 30 20)), '
              '((15 5, 40 10, 10 20, 5 10, 15 5)))'),
          multiPolygon1);
      expect(
          MultiPolygon<GeoPoint>.parse(
              '((30 20, 45 40, 10 40, 30 20)), '
              '((15 5, 40 10, 10 20, 5 10, 15 5))',
              GeoPoint2.coordinates),
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
        GeoPoint2.coordinates,
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
              GeoPoint2.coordinates),
          multiPolygon2);

      // GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))
      // GeometryCollection contains Point types and Point2 are concrete types.
      final geometryCollection1 = GeometryCollection([
        Point2.from([4.0, 6.0]),
        LineString.make(
          [
            [4.0, 6.0],
            [7.0, 10.0]
          ],
          Point2.coordinates,
        )
      ]);
      expect(
          wktProjected.parse<Point2>('GEOMETRYCOLLECTION(POINT(4 6), '
              'LINESTRING(4 6,7 10))'),
          geometryCollection1);
      // also some geometry series tests with different separators
      // (each wkt token each separated with blanks/linefeeds/commas)
      expect(wktProjected.parseAll<Point2>('POINT(4 6), LINESTRING(4 6,7 10)'),
          geometryCollection1.geometries);
      expect(wktProjected.parseAll<Point2>('''
      POINT(4 6)  
      LINESTRING(4 6,7 10)
      '''), geometryCollection1.geometries);
      expect(wktProjected.parseAll<Point2>('''
      ,

      POINT(4 6)  
      
      ,

      LINESTRING(4 6,7 10)
      '''), geometryCollection1.geometries);

      /// Geometries with empty ones on WKT text.
      expect(wktProjected.parseAll<Point>('''
      POINT ZM (1 1 5 60)
      POINT EMPTY
      POINT M (1 1 80)
      MULTIPOLYGON EMPTY
      '''), <Geometry>[
        Point3m.from([1.0, 1.0, 5.0, 60.0]),
        Geometry.empty(Geom.point),
        Point2m.from([1.0, 1.0, 80.0]),
        Geometry.empty(Geom.multiPolygon)
      ]);

      // Other geometry collection sample from wikipedia.
      expect(
          wktProjected.parse<Point2>('''
      GEOMETRYCOLLECTION (
            POINT (40 10),
            LINESTRING 
              (10 10, 20 20, 10 40),
            POLYGON ((40 40, 
                    20 45, 
                    45 30, 
                    40 40))
      )
      '''),
          GeometryCollection([
            Point2.parse('40 10'),
            LineString<Point2>.parse('10 10, 20 20, 10 40', Point2.coordinates),
            Polygon<Point2>.parse(
                '(40 40, 20 45, 45 30, 40 40)', Point2.coordinates)
          ]));
    });

    test('WKT range limits', () {
      const wktTest = '''
      POINT (1 1)
      POINT (2 2)
      POINT (3 3)
      POINT (4 4)
      POINT (5 5)
      ''';

      expect(wktGeographic.parseAll<GeoPoint2>(wktTest), <Geometry>[
        GeoPoint2.from([1, 1]),
        GeoPoint2.from([2, 2]),
        GeoPoint2.from([3, 3]),
        GeoPoint2.from([4, 4]),
        GeoPoint2.from([5, 5]),
      ]);

      expect(
          wktGeographic.parseAll<GeoPoint2>(wktTest,
              range: Range(start: 1, limit: 2)),
          <Geometry>[
            GeoPoint2.from([2, 2]),
            GeoPoint2.from([3, 3]),
          ]);

      expect(
          wktGeographic.parseAll<GeoPoint2>(wktTest, range: Range(start: 2)),
          <Geometry>[
            GeoPoint2.from([3, 3]),
            GeoPoint2.from([4, 4]),
            GeoPoint2.from([5, 5]),
          ]);

      expect(
          wktGeographic.parseAll<GeoPoint2>(wktTest,
              range: Range(start: 0, limit: 2)),
          <Geometry>[
            GeoPoint2.from([1, 1]),
            GeoPoint2.from([2, 2]),
          ]);
    });
  });
}
