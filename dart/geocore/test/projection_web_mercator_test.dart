// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:equatable/equatable.dart';

import 'package:geocore/geocore.dart';

import 'package:test/test.dart';

import 'projection_sample.dart';

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  group('Test projections between WGS84 and Web Mercator', () {
    test('webMercatorToWgs84(CartesianPoint to GeoPoint2)', () {
      final toWgs84 = wgs84ToWebMercator.inverse(GeoPoint2.coordinates);
      for (final coords in wgs84ToWebMercatorData) {
        final point2 = Point2(x: coords[2], y: coords[3]);
        final pointWrapper = PointWrapper(point2);
        final geoPoint2 = GeoPoint2(lon: coords[0], lat: coords[1]);
        expectProjected(point2.project(toWgs84), geoPoint2);
        expectProjected(pointWrapper.project(toWgs84), geoPoint2);
        expectProjected(
          point2.project(toWgs84),
          GeoPoint3(lon: coords[0], lat: coords[1]),
        );
        expectProjected(
          Point3(x: coords[2], y: coords[3], z: 30.0).project(toWgs84),
          GeoPoint2(lon: coords[0], lat: coords[1]),
        );
        expectProjected(
          Point3(x: coords[2], y: coords[3], z: 30.0)
              .project(toWgs84, to: GeoPoint3.coordinates),
          GeoPoint3(lon: coords[0], lat: coords[1], elev: 30.0),
        );
      }
    });

    test('wgs84ToWebMercator(GeoPoint to Point3)', () {
      final toWebMercator = wgs84ToWebMercator.forward(Point3.coordinates);
      for (final coords in wgs84ToWebMercatorData) {
        final geoPoint3 = GeoPoint3(lon: coords[0], lat: coords[1]);
        final geoPointWrapper = GeoPointWrapper(geoPoint3);
        final point3 = Point3(x: coords[2], y: coords[3]);
        expectProjected(geoPoint3.project(toWebMercator), point3, 0.01);
        expectProjected(geoPointWrapper.project(toWebMercator), point3, 0.01);
      }
    });

    test('wgs84ToWebMercator(GeoPoint to PointXX) in different geometries', () {
      _testToWebMercatorWithPoints(Point2.coordinates);
      _testToWebMercatorWithPoints(Point2m.coordinates);
      _testToWebMercatorWithPoints(Point3.coordinates);
      _testToWebMercatorWithPoints(Point3m.coordinates);
    });

    test(
        'webMercatorToWgs84(CartesianPoint to GeoPointXX)'
        ' in different geometries', () {
      _testToWgs84WithPoints(GeoPoint2.coordinates);
      _testToWgs84WithPoints(GeoPoint2m.coordinates);
      _testToWgs84WithPoints(GeoPoint3.coordinates);
      _testToWgs84WithPoints(GeoPoint3m.coordinates);
    });
  });
}

void _testToWgs84WithPoints<R extends GeoPoint>(
  PointFactory<R> factory,
) {
  final toWgs84 = wgs84ToWebMercator.inverse(factory);

  // point series and multipoint
  final points = testWebMercatorPoints();
  final pointsProjected = points.project(toWgs84);
  final multiPoint = MultiPoint(points);
  final multiPointProjected = multiPoint.project(toWgs84);
  for (var i = 0; i < points.length; i++) {
    expectProjected(
      pointsProjected[i],
      points[i].project(toWgs84),
    );
    expectProjected(
      multiPointProjected.points[i],
      points[i].project(toWgs84),
    );
  }

  // bounds
  final bounds = Bounds.of(min: points[0], max: points[1]);
  final boundsProjected = bounds.project(toWgs84);
  final boundsProjectedAsGeoBounds = GeoBounds(boundsProjected);
  expectProjected(boundsProjectedAsGeoBounds.min, pointsProjected[0]);
  expectProjected(boundsProjectedAsGeoBounds.max, pointsProjected[1]);

  // linestring and multilinestring
  final line = LineString.any(points);
  final lineProjected = line.project(toWgs84);
  final multiLine = MultiLineString([line]);
  final multiLineProjected = multiLine.project(toWgs84);
  for (var i = 0; i < line.chain.length; i++) {
    expectProjected(
      lineProjected.chain[i],
      line.chain[i].project(toWgs84),
    );
    expectProjected(
      multiLineProjected.lineStrings.first.chain[i],
      line.chain[i].project(toWgs84),
    );
  }

  // polygon and multipolygon
  final rings = testWebMercatorRings();
  final polygon = Polygon.fromPoints(rings);
  final polygonProjected = polygon.project(toWgs84);
  final multiPolygon = MultiPolygon([polygon]);
  final multiPolygonProjected = multiPolygon.project(toWgs84);
  for (var i = 0; i < rings.length; i++) {
    final projectedRing = polygonProjected.rings[i];
    final projectedMultiRing = multiPolygonProjected.polygons.first.rings[i];
    final originalRing = rings.elementAt(i);
    for (var j = 0; j < originalRing.length; j++) {
      final match = originalRing.elementAt(i).project(toWgs84);
      expectProjected(projectedRing.chain[i], match);
      expectProjected(projectedMultiRing.chain[i], match);
    }
  }

  // geometry collection
  final collection = GeometryCollection([polygon]);
  final collectionProjected = collection.project(toWgs84);
  expect(collectionProjected.geometries.first, polygonProjected);

  // feature
  final feature = Feature.of(
    id: '1',
    properties: {'prop1': 'a', 'prop2': 100},
    geometry: line,
  );
  final featureProjected = feature.project(toWgs84);
  expect(featureProjected.geometry, lineProjected);
  expect(featureProjected.id, '1');
  expect(featureProjected.properties, {'prop1': 'a', 'prop2': 100});

  // feature collection
  final fc = FeatureCollection.of(features: [feature]);
  final fcProjected = fc.project(toWgs84);
  final fcProjectedFirst = fcProjected.features.first;
  expect(fcProjectedFirst.geometry, lineProjected);
  expect(fcProjectedFirst.id, '1');
  expect(fcProjectedFirst.properties, {'prop1': 'a', 'prop2': 100});
}

void _testToWebMercatorWithPoints<R extends CartesianPoint>(
  PointFactory<R> factory,
) {
  final toWebMercator = wgs84ToWebMercator.forward(factory);

  // point series and multipoint
  final points = testWgs84Points();
  final pointsProjected = points.project(toWebMercator);
  final multiPoint = MultiPoint(points);
  final multiPointProjected = multiPoint.project(toWebMercator);
  for (var i = 0; i < points.length; i++) {
    expectProjected(
      pointsProjected[i],
      points[i].project(toWebMercator),
    );
    expectProjected(
      multiPointProjected.points[i],
      points[i].project(toWebMercator),
    );
  }

  // bounds
  final bounds = Bounds.of(min: points[0], max: points[1]);
  final boundsProjected = bounds.project(toWebMercator);
  expectProjected(boundsProjected.min, pointsProjected[0]);
  expectProjected(boundsProjected.max, pointsProjected[1]);

  // geobounds
  final geoBounds = GeoBounds.of(min: points[0], max: points[1]);
  final geoBoundsProjected = geoBounds.project(toWebMercator);
  expectProjected(geoBoundsProjected.min, pointsProjected[0]);
  expectProjected(geoBoundsProjected.max, pointsProjected[1]);

  // linestring and multilinestring
  final line = LineString.any(points);
  final lineProjected = line.project(toWebMercator);
  final multiLine = MultiLineString([line]);
  final multiLineProjected = multiLine.project(toWebMercator);
  for (var i = 0; i < line.chain.length; i++) {
    expectProjected(
      lineProjected.chain[i],
      line.chain[i].project(toWebMercator),
    );
    expectProjected(
      multiLineProjected.lineStrings.first.chain[i],
      line.chain[i].project(toWebMercator),
    );
  }

  // polygon and multipolygon
  final rings = testWgs84Rings();
  final polygon = Polygon.fromPoints(rings);
  final polygonProjected = polygon.project(toWebMercator);
  final multiPolygon = MultiPolygon([polygon]);
  final multiPolygonProjected = multiPolygon.project(toWebMercator);
  for (var i = 0; i < rings.length; i++) {
    final projectedRing = polygonProjected.rings[i];
    final projectedMultiRing = multiPolygonProjected.polygons.first.rings[i];
    final originalRing = rings.elementAt(i);
    for (var j = 0; j < originalRing.length; j++) {
      final match = originalRing.elementAt(i).project(toWebMercator);
      expectProjected(projectedRing.chain[i], match);
      expectProjected(projectedMultiRing.chain[i], match);
    }
  }

  // geometry collection
  final collection = GeometryCollection([polygon]);
  final collectionProjected = collection.project(toWebMercator);
  expect(collectionProjected.geometries.first, polygonProjected);

  // feature
  final feature = Feature.of(
    id: '1',
    properties: {'prop1': 'a', 'prop2': 100},
    geometry: line,
  );
  final featureProjected = feature.project(toWebMercator);
  expect(featureProjected.geometry, lineProjected);
  expect(featureProjected.id, '1');
  expect(featureProjected.properties, {'prop1': 'a', 'prop2': 100});

  // feature collection
  final fc = FeatureCollection.of(features: [feature]);
  final fcProjected = fc.project(toWebMercator);
  final fcProjectedFirst = fcProjected.features.first;
  expect(fcProjectedFirst.geometry, lineProjected);
  expect(fcProjectedFirst.id, '1');
  expect(fcProjectedFirst.properties, {'prop1': 'a', 'prop2': 100});
}
