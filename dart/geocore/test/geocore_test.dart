// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_types_on_closure_parameters

import 'package:test/test.dart';

import 'package:equatable/equatable.dart';

import 'package:geocore/geocore.dart';

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
      expect(f.properties.getString('name'), 'Dinagat Islands');
    });

    test('Basic feature collection', () {
      final fc = geoJSON.featureCollection(geojsonFeatureCollection);
      expect(fc.features.length, 3);
      expect(fc.features[0].geometry, GeoPoint2.from([102.0, 0.5]));
      expect(fc.features[1].geometry,
          (LineString g) => g.chain[0] == GeoPoint2.from([102.0, 0.0]));
      expect(fc.features[1].properties.getDouble('prop1'), 0.0);
      expect(fc.features[2].geometry, (Polygon g) {
        final exterior = g.exterior;
        return exterior.dimension == 2 &&
            exterior.chain.isClosed &&
            exterior.chain[2] == GeoPoint2.from([101.0, 1.0]);
      });
      expect(
          fc.features[2].properties.getMap('prop1').getString('this'), 'that');

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
