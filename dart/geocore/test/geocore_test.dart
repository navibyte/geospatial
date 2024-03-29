// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_types_on_closure_parameters
// ignore_for_file: prefer_const_constructors,require_trailing_commas
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:equatable/equatable.dart';

import 'package:geocore/geocore.dart';

import 'package:test/test.dart';

import 'geojson_sample.dart';

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  group('GeoJSON tests', () {
    setUp(() {
      // NOP
    });

    final parser2D = GeoJSON().parserGeographic(GeoPoint2.coordinates);
    final parser3D = GeoJSON().parserGeographic(GeoPoint3.coordinates);
    test('Basic feature', () {
      final f = parser2D.feature(geojsonFeature);
      expect(f.geometry, GeoPoint2.from([125.6, 10.1]));
      expect(f.properties['name'], 'Dinagat Islands');
    });

    test('Basic feature collection', () {
      final fc = parser2D.featureCollection(geojsonFeatureCollection);
      expect(fc.features.length, 3);
      expect(fc.features[0].geometry, GeoPoint2.from([102.0, 0.5]));
      expect(fc.features[1].geometry,
          (LineString g) => g.chain[0] == GeoPoint2.from([102.0, 0.0]));
      expect(fc.features[1].properties['prop1'], 0.0);
      expect(fc.features[2].geometry, (Polygon g) {
        final exterior = g.exterior;
        return exterior.dimension == 2 &&
            exterior.chain.isClosed &&
            exterior.chain[2] == GeoPoint2.from([101.0, 1.0]);
      });
      final prop1 = fc.features[2].properties['prop1']! as Map<String, Object?>;
      expect(prop1['this'], 'that');

      final intersect1 = fc.features
          .intersectByBounds(GeoBounds.bboxLonLat(101.05, 0.4, 102.05, 0.5));
      expect(intersect1.length, 2);
      expect(intersect1.bounds!.min, GeoPoint2.lonLat(102.0, 0.0));
      expect(intersect1.bounds!.max, GeoPoint2.lonLat(105.0, 1.0));

      final intersect2 = fc.features
          .intersectByBounds(GeoBounds.bboxLonLat(100.0, 0.4, 100.0, 0.5));
      expect(intersect2.length, 1);
      expect(intersect2.bounds!.min, GeoPoint2.lonLat(100.0, 0.0));
      expect(intersect2.bounds!.max, GeoPoint2.lonLat(101.0, 1.0));

      final intersect3 = fc.features
          .intersectByBounds(GeoBounds.bboxLonLat(100.0, 1.1, 105.0, 1.2));
      expect(intersect3.length, 0);
    });

    test('Basic feature with bbox', () {
      final f = parser2D.feature(geojsonBboxFeature);
      expect((f.geometry as Polygon?)?.exterior.chain[3],
          GeoPoint2.from([-10.0, -10.0]));
      expect(f.bounds, GeoBounds.bboxLonLat(-10.0, -10.0, 10.0, 10.0));
    });

    test('Basic feature collection with bbox', () {
      final f = parser3D.featureCollection(geojsonBboxFeatureCollection);
      expect(f.bounds,
          GeoBounds.bboxLonLatElev(100.0, 0.0, -100.0, 105.0, 1.0, 0.0));
    });

    test('Basic extended feature', () {
      final f = parser2D.feature(geojsonExtendedFeature);
      expect(f.id?.toString(), 'f2');
    });
  });

  group('Geometry tests using GeoPoint2', () {
    setUp(() {
      // NOP
    });

    final a2 = GeoPoint2.lonLat(25.1, 53.1);
    final b2 = GeoPoint2.lonLat(25.2, 53.2);
    final c2 = GeoPoint2(lon: -180.0, lat: -90.0);

    test('GeoPoint2', () {
      expect(GeoPoint2.latLon(53.1, 25.1), a2);
      expect(GeoPoint2.from([25.1, 53.1]), a2);
      expect(GeoPoint2.parse('25.1 53.1'), a2);
      expect(GeoPoint2.parse('25.1, 53.1', parser: _parseCoordsTest), a2);

      expect(c2, GeoPoint2(lon: 180.0, lat: -90.0));
      expect(c2.lon, -180.0);
    });

    test('PointSeries<GeoPoint2>', () {
      final expected = PointSeries.from([a2, b2]);
      expect(
          PointSeries.make([
            [25.1, 53.1],
            [25.2, 53.2]
          ], GeoPoint2.coordinates),
          expected);
      expect(PointSeries.parse('25.1 53.1, 25.2 53.2', GeoPoint2.coordinates),
          expected);
      expect(
          PointSeries.parse('25.1, 53.1, 25.2, 53.2', GeoPoint2.coordinates,
              parser: _parseCoordsListTest(2)),
          expected);
    });

    test('MultiPoint<GeoPoint2>', () {
      final expected = MultiPoint(PointSeries.from([a2, b2]));
      expect(
          MultiPoint.make([
            [25.1, 53.1],
            [25.2, 53.2]
          ], GeoPoint2.coordinates),
          expected);
      expect(MultiPoint.parse('25.1 53.1, 25.2 53.2', GeoPoint2.coordinates),
          expected);
      expect(
          MultiPoint.parse('(25.1 53.1), (25.2 53.2)', GeoPoint2.coordinates),
          expected);
      expect(
          MultiPoint.parse('25.1, 53.1, 25.2, 53.2', GeoPoint2.coordinates,
              parser: _parseCoordsListTest(2)),
          expected);
    });
  });

  group('Point toString', () {
    test('Cartesian points', () {
      expect(Point2.xy(1.1, 2.2).toString(), '1.1,2.2');
      expect(Point2m.xym(1.1, 2.2, 3.3).toString(), '1.1,2.2,3.3');
      expect(Point3.xyz(1.1, 2.2, 3.3).toString(), '1.1,2.2,3.3');
      expect(Point3m.xyzm(1.1, 2.2, 3.3, 4.4).toString(), '1.1,2.2,3.3,4.4');
      expect(Point2i.xy(1, 2).toString(), '1,2');
      expect(Point3i.xyz(1, 2, 3).toString(), '1,2,3');
    });
    test('Geographical points', () {
      expect(GeoPoint2.lonLat(1.1, 2.2).toString(), '1.1,2.2');
      expect(GeoPoint2m.lonLatM(1.1, 2.2, 3.3).toString(), '1.1,2.2,3.3');
      expect(GeoPoint3.lonLatElev(1.1, 2.2, 3.3).toString(), '1.1,2.2,3.3');
      expect(GeoPoint3m.lonLatElevM(1.1, 2.2, 3.3, 4.4).toString(),
          '1.1,2.2,3.3,4.4');
    });
  });

  group('Bounds toString and toStringAs', () {
    test('Bounds', () {
      final b1 = Bounds.of(min: Point2.xy(1.1, 2.1), max: Point2.xy(1.5, 2.5));
      final b2 = Bounds.of(
          min: Point2m.xym(1.1, 2.1, 3.1), max: Point2m.xym(1.5, 2.5, 3.5));
      final b3 = Bounds.of(
          min: Point3.xyz(1.1, 2.1, 3.1), max: Point3.xyz(1.5, 2.5, 3.5));
      final b4 =
          Bounds.of(min: Point3i.xyz(1, 2, 3), max: Point3i.xyz(2, 3, 4));
      final b5 = GeoBounds.bboxLonLat(1.1, 2.1, 1.5, 2.5);
      final b6 = GeoBounds.bboxLonLatElev(1.1, 2.1, 3.1, 1.5, 2.5, 3.5);
      expect(b1.toString(), '1.1,2.1,1.5,2.5');
      /*
      expect(b1.toStringAs(), '1.1,2.1,1.5,2.5');
      expect(b1.toStringAs(format: wktLikeFormat), '1.1 2.1,1.5 2.5');
      expect(b1.toStringAs(format: wktLikeFormat, decimals: 0), '1 2,2 3');
      expect(b1.toStringAs(format: wktLikeFormat, decimals: 2),
          '1.10 2.10,1.50 2.50');
      */
      expect(b2.toString(), '1.1,2.1,3.1,1.5,2.5,3.5');
      /*
      expect(b2.toStringAs(format: wktLikeFormat), '1.1 2.1 3.1,1.5 2.5 3.5');
      */
      expect(b3.toString(), '1.1,2.1,3.1,1.5,2.5,3.5');
      expect(b4.toString(), '1,2,3,2,3,4');
      expect(b5.toString(), '1.1,2.1,1.5,2.5');
      expect(b6.toString(), '1.1,2.1,3.1,1.5,2.5,3.5');
    });
  });
  group('Point values printed as String', () {
    const p3dec = Point3.xyz(10.1, 20.217, 30.73942);
    const p3 = Point3.xyz(10.001, 20.000, 30);
    const p3i = Point3i.xyz(10, 20, 30);

    test('toStringAs (defaultFormat) with Point3 and Point3i', () {
      expect(p3dec.toStringAs(), '10.1,20.217,30.73942');
      expect(p3dec.toStringAs(decimals: 0), '10,20,31');
      expect(p3dec.toStringAs(decimals: 3), '10.100,20.217,30.739');
      expect(p3.toStringAs(decimals: 3), '10.001,20,30');
      expect(p3.toStringAs(decimals: 2), '10.00,20,30');
      expect(p3i.toStringAs(decimals: 2), '10,20,30');
    });

    test('toStringAs (wktFormat) with Point3 and Point3i', () {
      expect(p3dec.toStringAs(format: WktLikeFormat.geometry),
          '10.1 20.217 30.73942');
      expect(p3dec.toStringAs(format: WktLikeFormat.geometry, decimals: 0),
          '10 20 31');
      expect(p3dec.toStringAs(format: WktLikeFormat.geometry, decimals: 3),
          '10.100 20.217 30.739');
      expect(p3.toStringAs(format: WktLikeFormat.geometry, decimals: 3),
          '10.001 20 30');
      expect(p3.toStringAs(format: WktLikeFormat.geometry, decimals: 2),
          '10.00 20 30');
      expect(p3i.toStringAs(format: WktLikeFormat.geometry, decimals: 2),
          '10 20 30');
    });
  });

  group('PointSeries and simple geometry - toString and toStringAs', () {
    final points1 = PointSeries.make([
      [-1.1, -1.1],
      [2.1, -2.5],
      [3.5, -3.49]
    ], Point2.coordinates);

    test('PointSeries', () {
      expect(points1.toString(), '[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]');
      /*
      expect(points1.toStringAs(), '[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]');
      expect(points1.toStringAs(decimals: 0), '[-1,-1],[2,-3],[4,-3]');
      expect(points1.toStringAs(format: wktLikeFormat),
          '-1.1 -1.1,2.1 -2.5,3.5 -3.49');
      expect(points1.toStringAs(format: wktLikeFormat, decimals: 2),
          '-1.10 -1.10,2.10 -2.50,3.50 -3.49');
      */
    });

    final multiPoint1 = MultiPoint(points1);
    test('MultiPoint', () {
      expect(multiPoint1.toStringAs(), '[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]');
      expect(
          multiPoint1.toStringAs(format: WktLikeFormat.geometry, decimals: 0),
          '-1 -1,2 -3,4 -3');
    });

    final line1 = LineString(points1);
    final ring1 = LineString.make([
      [10.1, 10.1],
      [5, 9],
      [12, 4],
      [10.1, 10.1]
    ], Point2.coordinates, type: LineStringType.ring);

    test('LineString', () {
      expect(line1.toString(), '[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]');
      expect(line1.toStringAs(format: WktLikeFormat.geometry),
          '-1.1 -1.1,2.1 -2.5,3.5 -3.49');
    });

    final multiLine1 = MultiLineString([
      line1,
      ring1,
    ]);
    test('MultiLineString', () {
      expect(
          multiLine1.toStringAs(format: WktLikeFormat.geometry),
          '(-1.1 -1.1,2.1 -2.5,3.5 -3.49),(10.1 10.1,5.0 9.0,12.0'
          ' 4.0,10.1 10.1)');
    });

    final polygon1 = Polygon([ring1]);
    test('Polygon', () {
      expect(polygon1.toString(),
          '[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]]');
      expect(polygon1.toStringAs(format: WktLikeFormat.geometry),
          '(10.1 10.1,5.0 9.0,12.0 4.0,10.1 10.1)');
    });

    final multiPolygon1 = MultiPolygon([
      polygon1,
    ]);
    test('MultiPolygon', () {
      expect(multiPolygon1.toStringAs(decimals: 2),
          '[[[10.10,10.10],[5,9],[12,4],[10.10,10.10]]]');
    });
  });

  group('Parsing point objects from text', () {
    test('Point.fromText tests', () {
      expect(
          Point2.fromText('10.1;20.2', delimiter: ';'), Point2.xy(10.1, 20.2));
      expect(Point2m.fromText('10.1;20.2;5.0', delimiter: ';'),
          Point2m.xym(10.1, 20.2, 5.0));
      expect(Point3.fromText('10.1;20.2;30.3', delimiter: ';'),
          Point3.xyz(10.1, 20.2, 30.3));
      expect(Point3m.fromText('10.1;20.2;30.3;5.0', delimiter: ';'),
          Point3m.xyzm(10.1, 20.2, 30.3, 5.0));
      expect(Point2i.fromText('10.1;20.2', delimiter: ';'), Point2i.xy(10, 20));
      expect(Point3i.fromText('10.1;20.2;30.3', delimiter: ';'),
          Point3i.xyz(10, 20, 30));
    });

    test('GeoPoint.fromText tests', () {
      expect(GeoPoint2.fromText('10.1;20.2', delimiter: ';'),
          GeoPoint2.lonLat(10.1, 20.2));
      expect(GeoPoint2m.fromText('10.1;20.2;5.0', delimiter: ';'),
          GeoPoint2m.lonLatM(10.1, 20.2, 5.0));
      expect(GeoPoint3.fromText('10.1;20.2;30.3', delimiter: ';'),
          GeoPoint3.lonLatElev(10.1, 20.2, 30.3));
      expect(GeoPoint3m.fromText('10.1;20.2;30.3;5.0', delimiter: ';'),
          GeoPoint3m.lonLatElevM(10.1, 20.2, 30.3, 5.0));
    });

    test('GeoPoint2.fromText tests with different delimiters and space', () {
      expect(
        () => GeoPoint2.fromText('10.1;20.2', delimiter: ''),
        throwsFormatException,
      );
      expect(
        GeoPoint2.fromText(' 10.1 ; 20.2 ', delimiter: ';'),
        GeoPoint2.lonLat(10.1, 20.2),
      );
      expect(
        GeoPoint2.fromText('     10.1    20.2 ', delimiter: RegExp(r'\s+')),
        GeoPoint2.lonLat(10.1, 20.2),
      );
      expect(
        GeoPoint2.fromText('     10.1    20.2 '),
        GeoPoint2.lonLat(10.1, 20.2),
      );
      expect(
        GeoPoint2.fromText('     10.1 20.2 ', delimiter: ' '),
        GeoPoint2.lonLat(10.1, 20.2),
      );
      expect(
        () => GeoPoint2.fromText('     10.1    20.2 ', delimiter: ' '),
        throwsFormatException,
      );
    });
  });

  group('Geometry tests with iterables, point series, and bounded series', () {
    final points = [
      Point2.xy(10.0, 11.0),
      Point2.xy(20.0, 21.0),
    ];
    final series = PointSeries.view(points);
    test('PointSeries', () {
      expect(PointSeries.from(points), series);
      expect(
          PointSeries.make([
            [10.0, 11.0],
            [20.0, 21.0]
          ], Point2.coordinates),
          series);
      expect(
        PointSeries.parse('10 11, 20 21', Point2.coordinates),
        series,
      );
    });

    test('MultiPoint', () {
      final multiPoint = MultiPoint(points);
      expect(multiPoint.points, series);
      expect(MultiPoint(series), multiPoint);
      expect(
          MultiPoint.make([
            [10.0, 11.0],
            [20.0, 21.0]
          ], Point2.coordinates),
          multiPoint);
      expect(
        MultiPoint.parse('10 11, 20 21', Point2.coordinates),
        multiPoint,
      );
    });
    test('LineString', () {
      final lineString = LineString.any(points);
      expect(lineString.chain, series);
      expect(LineString.any(series), lineString);
      expect(
          LineString.make([
            [10.0, 11.0],
            [20.0, 21.0]
          ], Point2.coordinates),
          lineString);
      expect(
        LineString.parse('10 11, 20 21', Point2.coordinates),
        lineString,
      );
    });
  });

  group('Geometry tests with multi line string, polygons, multi polygon', () {
    final points = [
      Point2.xy(10.0, 10.0),
      Point2.xy(5.0, 9.0),
      Point2.xy(12.0, 4.0),
      Point2.xy(10.0, 10.0),
    ];
    final series = PointSeries.view(points);
    final lineString = LineString.any(series);
    final ring = LineString.ring(series);

    test('MultiLineString', () {
      final multiLineString = MultiLineString(BoundedSeries.from([lineString]));
      expect(multiLineString.lineStrings.first.chain, series);
      expect(MultiLineString([lineString]), multiLineString);
      expect(
          MultiLineString.make([
            [
              [10.0, 10.0],
              [5.0, 9.0],
              [12.0, 4.0],
              [10.0, 10.0]
            ],
          ], Point2.coordinates),
          multiLineString);
      expect(
        MultiLineString.parse('(10 10, 5 9, 12 4, 10 10)', Point2.coordinates),
        multiLineString,
      );
    });

    test('Polygon and MultiPolygon and MultiGeometry', () {
      final polygon = Polygon(BoundedSeries.from([ring]));
      expect(polygon.exterior.chain, series);
      expect(Polygon([ring]), polygon);
      expect(Polygon.fromPoints([points]), polygon);
      expect(Polygon.fromPoints([series]), polygon);
      expect(
          Polygon.make([
            [
              [10.0, 10.0],
              [5.0, 9.0],
              [12.0, 4.0],
              [10.0, 10.0]
            ],
          ], Point2.coordinates),
          polygon);
      expect(
        Polygon.parse('(10 10, 5 9, 12 4, 10 10)', Point2.coordinates),
        polygon,
      );

      final multiPolygon = MultiPolygon(BoundedSeries.from([polygon]));
      expect(multiPolygon.polygons.first.exterior.chain, series);
      expect(MultiPolygon([polygon]), multiPolygon);
      expect(
          MultiPolygon.make([
            [
              [
                [10.0, 10.0],
                [5.0, 9.0],
                [12.0, 4.0],
                [10.0, 10.0]
              ],
            ]
          ], Point2.coordinates),
          multiPolygon);
      expect(
        MultiPolygon.parse('((10 10, 5 9, 12 4, 10 10))', Point2.coordinates),
        multiPolygon,
      );

      final multiGeometry1 =
          GeometryCollection(BoundedSeries.from([lineString]));
      expect(multiGeometry1.geometries.first.chain, series);
      expect(GeometryCollection([lineString]), multiGeometry1);

      final multiGeometry2 =
          GeometryCollection(BoundedSeries.from([lineString, polygon]));
      expect((multiGeometry2.geometries.first as LineString).chain, series);
      expect(GeometryCollection([lineString, polygon]), multiGeometry2);
    });
  });
}

Iterable<num> _parseCoordsTest(String text) =>
    text.trim().split(',').map<num>((c) => double.parse(c.trim()));

ParseCoordsList _parseCoordsListTest(int coordDim) => (String text) {
      final splitted = text.trim().split(',');
      final result = <Iterable<num>>[];
      for (var i = 0; i + (coordDim - 1) < splitted.length; i += coordDim) {
        final coord = <num>[];
        for (var j = 0; j < coordDim; j++) {
          coord.add(double.parse(splitted[i + j]));
        }
        result.add(coord);
      }
      return result;
    };
