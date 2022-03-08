// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:equatable/equatable.dart';

import 'package:geobase/geobase.dart';
import 'package:geocore/geocore.dart';

import 'package:test/test.dart';

import 'geojson_sample.dart';

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  group('Test transformations with simple translate', () {
    final translate1 = translatePosition(dx: 1.0, dy: 2.0, dz: 3.0, dm: 4.0);
    test('Immutable point classes (cartesian points)', () {
      expect(
        Point2.xy(10.0, 20.0).transform(translate1),
        Point2.xy(11.0, 22.0),
      );
      expect(
        Point2m.xym(10.0, 20.0, 40.0).transform(translate1),
        Point2m.xym(11.0, 22.0, 44.0),
      );
      expect(
        Point3.xyz(10.0, 20.0, 30.0).transform(translate1),
        Point3.xyz(11.0, 22.0, 33.0),
      );
      expect(
        Point3m.xyzm(10.0, 20.0, 30.0, 40.0).transform(translate1),
        Point3m.xyzm(11.0, 22.0, 33.0, 44.0),
      );
      expect(
        Point2i.xy(10, 20).transform(translate1),
        Point2i.xy(11, 22),
      );
      expect(
        Point3i.xyz(10, 20, 30).transform(translate1),
        Point3i.xyz(11, 22, 33),
      );
    });

    test('Immutable geo point classes (geographical points)', () {
      expect(
        GeoPoint2.lonLat(10.0, 20.0).transform(translate1),
        GeoPoint2.lonLat(11.0, 22.0),
      );
      expect(
        GeoPoint2m.lonLatM(10.0, 20.0, 40.0).transform(translate1),
        GeoPoint2m.lonLatM(11.0, 22.0, 44.0),
      );
      expect(
        GeoPoint3.lonLatElev(10.0, 20.0, 30.0).transform(translate1),
        GeoPoint3.lonLatElev(11.0, 22.0, 33.0),
      );
      expect(
        GeoPoint3m.lonLatElevM(10.0, 20.0, 30.0, 40.0).transform(translate1),
        GeoPoint3m.lonLatElevM(11.0, 22.0, 33.0, 44.0),
      );
    });

    test('Point wrappers (cartesian or geographical points)', () {
      expect(
        PointWrapper(Point3m.xyzm(10.0, 20.0, 30.0, 40.0))
            .transform(translate1),
        Point3m.xyzm(11.0, 22.0, 33.0, 44.0),
      );
      expect(
        PointWrapper(GeoPoint3m.lonLatElevM(10.0, 20.0, 30.0, 40.0))
            .transform(translate1),
        GeoPoint3m.lonLatElevM(11.0, 22.0, 33.0, 44.0),
      );
    });

    test('Immutable bounds classes (with cartesian points)', () {
      expect(
        Bounds.of(
          min: Point2.xy(10.0, 20.0),
          max: Point2.xy(110.0, 120.0),
        ).transform(translate1),
        Bounds.of(
          min: Point2.xy(11.0, 22.0),
          max: Point2.xy(111.0, 122.0),
        ),
      );
      expect(
        Bounds.of(
          min: Point3.xyz(10.0, 20.0, 30.0),
          max: Point3.xyz(110.0, 120.0, 130.0),
        ).transform(translate1),
        Bounds.of(
          min: Point3.xyz(11.0, 22.0, 33.0),
          max: Point3.xyz(111.0, 122.0, 133.0),
        ),
      );
      expect(
        Bounds.of(
          min: Point3i.xyz(10, 20, 30),
          max: Point3i.xyz(110, 120, 130),
        ).transform(translate1),
        Bounds.of(
          min: Point3i.xyz(11, 22, 33),
          max: Point3i.xyz(111, 122, 133),
        ),
      );
    });

    test('Immutable bounds classes (with geographical points)', () {
      expect(
        GeoBounds.bboxLonLat(10.0, 20.0, 110.0, 120.0).transform(translate1),
        GeoBounds.bboxLonLat(11.0, 22.0, 111.0, 122.0),
      );
      expect(
        GeoBounds.bboxLonLatElev(10.0, 20.0, 30.0, 110.0, 120.0, 130.0)
            .transform(translate1),
        GeoBounds.bboxLonLatElev(11.0, 22.0, 33.0, 111.0, 122.0, 133.0),
      );
    });

    test('LineString classes (with cartesian points)', () {
      expect(
        LineString.parse('30 10, 10 30, 40 40', Point2.coordinates)
            .transform(translate1),
        LineString.parse('31 12, 11 32, 41 42', Point2.coordinates),
      );
    });

    test('Polygon classes (with cartesian points)', () {
      expect(
        Polygon.parse(
          '(30 10 100, 40 40 110,'
          ' 20 40 120, 10 20 130, 30 10 100)',
          Point3.coordinates,
        ).transform(translate1),
        Polygon.parse(
          '(31 12 103, 41 42 113,'
          ' 21 42 123, 11 22 133, 31 12 103)',
          Point3.coordinates,
        ),
      );
    });

    test('MultiPoint classes (with geographical points)', () {
      expect(
        MultiPoint<GeoPoint>.parse(
          '10 40, 40 30, 20 20, 30 10',
          GeoPoint2.coordinates,
        ).transform(translate1),
        MultiPoint<GeoPoint>.parse(
          '11 42, 41 32, 21 22, 31 12',
          GeoPoint2.coordinates,
        ),
      );
    });

    test('MultiLineString classes (with cartesian points)', () {
      expect(
        MultiLineString<Point>.parse(
          '(10 10 100 5, 20 20 100 5, 10 40 100 5), '
          '(40 40 100 5, 30 30 100 5, 40 20 100 5, 30 10 100 5)',
          GeoPoint3m.coordinates,
        ).transform(translate1),
        MultiLineString<Point>.parse(
          '(11 12 103 9, 21 22 103 9, 11 42 103 9), '
          '(41 42 103 9, 31 32 103 9, 41 22 103 9, 31 12 103 9)',
          GeoPoint3m.coordinates,
        ),
      );
    });

    test('MultiPolygon classes (with geographical points)', () {
      expect(
        MultiPolygon<GeoPoint>.parse(
          '((30 20 10, 45 40 20, 10 40 30, 30 20 40)), '
          '((15 5 50, 40 10 60, 10 20 70, 5 10 80, 15 5 90))',
          GeoPoint2m.coordinates,
        ).transform(translate1),
        MultiPolygon<GeoPoint>.parse(
          '((31 22 14, 46 42 24, 11 42 34, 31 22 44)), '
          '((16 7 54, 41 12 64, 11 22 74, 6 12 84, 16 7 94))',
          GeoPoint2m.coordinates,
        ),
      );
    });

    test('GeometryCollection classes (with cartesian points)', () {
      expect(
        GeometryCollection(
          BoundedSeries<Geometry>.from([
            Point2.parse('40 10'),
            LineString<Point3>.parse(
              '10 10 50, 20 20 60, 10 40 50',
              Point3.coordinates,
            ),
            Polygon<Point3m>.parse(
              '(40 40 -10 110, 20 45 -20 120, 45 30 -30 130, 40 40 -40 140)',
              Point3m.coordinates,
            )
          ]),
        ).transform(translate1),
        GeometryCollection([
          Point2.parse('41 12'),
          LineString<Point3>.parse(
            '11 12 53, 21 22 63, 11 42 53',
            Point3.coordinates,
          ),
          Polygon<Point3m>.parse(
            '(41 42 -7 114, 21 47 -17 124, 46 32 -27 134, 41 42 -37 144)',
            Point3m.coordinates,
          )
        ]),
      );
    });

    final parser2D = geoJsonGeographic(geographicPoints);

    test('Feature', () {
      final f = parser2D.feature(geojsonFeature).transform(translate1);
      expect(f.geometry, GeoPoint2.lonLat(126.6, 12.1));
      expect(f.properties['name'], 'Dinagat Islands');
    });

    test('FeatureCollection', () {
      final fc = parser2D
          .featureCollection(geojsonFeatureCollection)
          .transform(translate1);
      expect(fc.features.length, 3);
      expect(fc.features[0].geometry, GeoPoint2.lonLat(103.0, 2.5));
      expect(
        fc.features[1].geometry,
        (LineString g) => g.chain[0] == GeoPoint2.lonLat(103.0, 2.0),
      );
    });
  });

  group('Test projections with simple scale (each scale own factor)', () {
    final scale1 = scalePosition(sx: 2.6, sy: 3.0, sz: 4.0, sm: 5.0);

    test('Point classes', () {
      expect(
        Point3m.xyzm(10.0, 20.0, 30.0, 40.0).transform(scale1),
        Point3m.xyzm(26.0, 60.0, 120.0, 200.0),
      );
      expect(
        Point3i.xyz(10, 20, 30).transform(scale1),
        Point3i.xyz(26, 60, 120),
      );
    });
  });

  group('Test projections with simple scale (one factor for all axes)', () {
    final scale1 = scalePositionBy(1.5);

    test('Point classes', () {
      expect(
        Point3m.xyzm(10.0, 20.0, 30.0, 40.0).transform(scale1),
        Point3m.xyzm(15.0, 30.0, 45.0, 60.0),
      );
      expect(
        Point3i.xyz(10, 20, 30).transform(scale1),
        Point3i.xyz(15, 30, 45),
      );
    });
  });

  group('Test projections with simple 2D rotation', () {
    test('Point classes', () {
      final tests = [
        // angle (deg), pivot-x, pivot-y, source-x, source-y, target-x, target-y
        [90, 0.0, 0.0, 10.0, 0.0, 0.0, 10.0],
        [90, 1.0, 0.0, 10.0, 0.0, 1.0, 9.0],
        [270, 0.0, 0.0, 10.0, 20.0, 20.0, -10.0],
        [630, 0.0, 0.0, 10.0, 20.0, 20.0, -10.0]
      ];

      for (final t in tests) {
        final rot = rotatePosition2D(
          _angleToRad(t[0].toDouble()),
          cx: t[1],
          cy: t[2],
        );
        expect(
          Point3.xyz(t[3], t[4], 30.0).transform(rot),
          (Point3 val) => val.equals2D(
            Point3.xyz(t[5], t[6], 30.0),
            toleranceHoriz: 1e-8,
          ),
        );
      }
    });
  });
}

double _angleToRad(double angle) => angle * pi / 180.0;
