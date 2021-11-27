// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
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

    test('Basic feature', () {
      final f = geoJSON.feature(geojsonFeature);
      expect(f.geometry, GeoPoint2.from([125.6, 10.1]));
      expect(f.properties['name'], 'Dinagat Islands');
    });

    test('Basic feature collection', () {
      final fc = geoJSON.featureCollection(geojsonFeatureCollection);
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
      expect(intersect1.bounds.min, GeoPoint2.lonLat(102.0, 0.0));
      expect(intersect1.bounds.max, GeoPoint2.lonLat(105.0, 1.0));

      final intersect2 = fc.features
          .intersectByBounds(GeoBounds.bboxLonLat(100.0, 0.4, 100.0, 0.5));
      expect(intersect2.length, 1);
      expect(intersect2.bounds.min, GeoPoint2.lonLat(100.0, 0.0));
      expect(intersect2.bounds.max, GeoPoint2.lonLat(101.0, 1.0));

      final intersect3 = fc.features
          .intersectByBounds(GeoBounds.bboxLonLat(100.0, 1.1, 105.0, 1.2));
      expect(intersect3.length, 0);
    });

    test('Basic feature with bbox', () {
      final f = geoJSON.feature(geojsonBboxFeature);
      expect((f.geometry as Polygon?)?.exterior.chain[3],
          GeoPoint2.from([-10.0, -10.0]));
      expect(f.bounds, GeoBounds.bboxLonLat(-10.0, -10.0, 10.0, 10.0));
    });

    test('Basic feature collection with bbox', () {
      final f = geoJSON.featureCollection(geojsonBboxFeatureCollection);
      expect(f.bounds,
          GeoBounds.bboxLonLatElev(100.0, 0.0, -100.0, 105.0, 1.0, 0.0));
    });

    test('Basic extended feature', () {
      final f = geoJSON.feature(geojsonExtendedFeature);
      expect(f.id?.toString(), 'f2');
    });
  });

  group('Geometry tests using GeoPoint2', () {
    setUp(() {
      // NOP
    });

    final a2 = GeoPoint2.lonLat(25.1, 53.1);
    final b2 = GeoPoint2.lonLat(25.2, 53.2);

    test('GeoPoint2', () {
      expect(GeoPoint2.latLon(53.1, 25.1), a2);
      expect(GeoPoint2.from([25.1, 53.1]), a2);
      expect(GeoPoint2.parse('25.1 53.1'), a2);
      expect(GeoPoint2.parse('25.1, 53.1', parser: _parseCoordsTest), a2);
    });

    test('PointSeries<GeoPoint2>', () {
      final expected = PointSeries.from([a2, b2]);
      expect(
          PointSeries.make([
            [25.1, 53.1],
            [25.2, 53.2]
          ], GeoPoint2.geometry),
          expected);
      expect(PointSeries.parse('25.1 53.1, 25.2 53.2', GeoPoint2.geometry),
          expected);
      expect(
          PointSeries.parse('25.1, 53.1, 25.2, 53.2', GeoPoint2.geometry,
              parser: _parseCoordsListTest(2)),
          expected);
    });

    test('MultiPoint<GeoPoint2>', () {
      final expected = MultiPoint(PointSeries.from([a2, b2]));
      expect(
          MultiPoint.make([
            [25.1, 53.1],
            [25.2, 53.2]
          ], GeoPoint2.geometry),
          expected);
      expect(MultiPoint.parse('25.1 53.1, 25.2 53.2', GeoPoint2.geometry),
          expected);
      expect(MultiPoint.parse('(25.1 53.1), (25.2 53.2)', GeoPoint2.geometry),
          expected);
      expect(
          MultiPoint.parse('25.1, 53.1, 25.2, 53.2', GeoPoint2.geometry,
              parser: _parseCoordsListTest(2)),
          expected);
    });
  });

  group('Point values printed as String', () {
    const p3dec = Point3.xyz(10.1, 20.217, 30.73942);
    const p3 = Point3.xyz(10.001, 20.000, 30);
    const p3i = Point3i.xyz(10, 20, 30);

    test('toText with Point3 and Point3i', () {
      expect(p3dec.toText(), '10.1 20.217 30.73942');
      expect(p3dec.toText(fractionDigits: 0), '10 20 31');
      expect(p3dec.toText(fractionDigits: 3), '10.100 20.217 30.739');
      expect(p3.toText(fractionDigits: 3), '10.001 20 30');
      expect(p3.toText(fractionDigits: 2), '10.00 20 30');
      expect(p3i.toText(fractionDigits: 2), '10 20 30');
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
