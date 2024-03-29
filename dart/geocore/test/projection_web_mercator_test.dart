// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:equatable/equatable.dart';
import 'package:geobase/projections.dart';
import 'package:geocore/geocore.dart';
import 'package:test/test.dart';

import 'projection_sample.dart';

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  group('Test projections between WGS84 and Web Mercator', () {
    test('webMercatorToWgs84(CartesianPoint to GeoPoint2)', () {
      final toWgs84 = WGS84.webMercator.inverse;
      for (final coords in wgs84ToWebMercatorData) {
        final point2 = Point2(x: coords[2], y: coords[3]);
        final pointWrapper = PointWrapper(point2);
        final geoPoint2 = GeoPoint2(lon: coords[0], lat: coords[1]);
        expectProjected(
          point2.project(toWgs84, to: GeoPoint2.create),
          geoPoint2,
        );
        expectProjected(
          pointWrapper.project(toWgs84, to: GeoPoint2.create),
          geoPoint2,
        );
        expectProjected(
          point2.project(toWgs84, to: GeoPoint2.create),
          GeoPoint3(lon: coords[0], lat: coords[1]),
        );
        expectProjected(
          Point3(x: coords[2], y: coords[3], z: 30.0).project(
            toWgs84,
            to: GeoPoint2.create,
          ),
          GeoPoint2(lon: coords[0], lat: coords[1]),
        );
        expectProjected(
          Point3(x: coords[2], y: coords[3], z: 30.0)
              .project(toWgs84, to: GeoPoint3.create),
          GeoPoint3(lon: coords[0], lat: coords[1], elev: 30.0),
        );
      }
    });

    test('wgs84ToWebMercator(GeoPoint to Point3)', () {
      final toWebMercator = WGS84.webMercator.forward;
      for (final coords in wgs84ToWebMercatorData) {
        final geoPoint3 = GeoPoint3(lon: coords[0], lat: coords[1]);
        final geoPointWrapper = GeoPointWrapper(geoPoint3);
        final point3 = Point3(x: coords[2], y: coords[3]);
        expectProjected(
          geoPoint3.project(toWebMercator, to: Point3.create),
          point3,
          0.01,
        );
        expectProjected(
          geoPointWrapper.project(toWebMercator, to: Point3.create),
          point3,
          0.01,
        );
      }
    });

    test('wgs84ToWebMercator(GeoPoint to PointXX) in different geometries', () {
      _testToWebMercatorWithPoints(Point2.create);
      _testToWebMercatorWithPoints(Point2m.create);
      _testToWebMercatorWithPoints(Point3.create);
      _testToWebMercatorWithPoints(Point3m.create);
    });

    test(
        'webMercatorToWgs84(CartesianPoint to GeoPointXX)'
        ' in different geometries', () {
      _testToWgs84WithPoints(GeoPoint2.create);
      _testToWgs84WithPoints(GeoPoint2m.create);
      _testToWgs84WithPoints(GeoPoint3.create);
      _testToWgs84WithPoints(GeoPoint3m.create);
    });
  });
}

void _testToWgs84WithPoints<R extends GeoPoint>(
  CreatePosition<R> factory,
) {
  final toWgs84 = WGS84.webMercator.inverse;

  // point series and multipoint
  final points = testWebMercatorPoints();
  final pointsProjected = points.project(toWgs84, to: factory);
  final multiPoint = MultiPoint(points);
  final multiPointProjected = multiPoint.project(toWgs84, to: factory);
  for (var i = 0; i < points.length; i++) {
    expectProjected(
      pointsProjected[i],
      points[i].project(toWgs84, to: factory),
    );
    expectProjected(
      multiPointProjected.points[i],
      points[i].project(toWgs84, to: factory),
    );
  }

  // bounds
  final bounds = Bounds.of(min: points[0], max: points[1]);
  final boundsProjected = bounds.project(toWgs84, to: factory);
  final boundsProjectedAsGeoBounds = GeoBounds(boundsProjected);
  expectProjected(boundsProjectedAsGeoBounds.min, pointsProjected[0]);
  expectProjected(boundsProjectedAsGeoBounds.max, pointsProjected[1]);

  // linestring and multilinestring
  final line = LineString.any(points);
  final lineProjected = line.project(toWgs84, to: factory);
  final multiLine = MultiLineString([line]);
  final multiLineProjected = multiLine.project(toWgs84, to: factory);
  for (var i = 0; i < line.chain.length; i++) {
    expectProjected(
      lineProjected.chain[i],
      line.chain[i].project(toWgs84, to: factory),
    );
    expectProjected(
      multiLineProjected.lineStrings.first.chain[i],
      line.chain[i].project(toWgs84, to: factory),
    );
  }

  // polygon and multipolygon
  final rings = testWebMercatorRings();
  final polygon = Polygon.fromPoints(rings);
  final polygonProjected = polygon.project(toWgs84, to: factory);
  final multiPolygon = MultiPolygon([polygon]);
  final multiPolygonProjected = multiPolygon.project(toWgs84, to: factory);
  for (var i = 0; i < rings.length; i++) {
    final projectedRing = polygonProjected.rings[i];
    final projectedMultiRing = multiPolygonProjected.polygons.first.rings[i];
    final originalRing = rings.elementAt(i);
    for (var j = 0; j < originalRing.length; j++) {
      final match = originalRing.elementAt(i).project(toWgs84, to: factory);
      expectProjected(projectedRing.chain[i], match);
      expectProjected(projectedMultiRing.chain[i], match);
    }
  }

  // geometry collection
  final collection = GeometryCollection([polygon]);
  final collectionProjected = collection.project(toWgs84, to: factory);
  expect(collectionProjected.geometries.first, polygonProjected);

  // feature
  final feature = Feature(
    id: '1',
    properties: const {'prop1': 'a', 'prop2': 100},
    geometry: line,
  );
  final featureProjected = feature.project(toWgs84, to: factory);
  expect(featureProjected.geometry, lineProjected);
  expect(featureProjected.id, '1');
  expect(featureProjected.properties, {'prop1': 'a', 'prop2': 100});

  // feature collection
  final fc = FeatureCollection(features: [feature]);
  final fcProjected = fc.project(toWgs84, to: factory);
  final fcProjectedFirst = fcProjected.features.first;
  expect(fcProjectedFirst.geometry, lineProjected);
  expect(fcProjectedFirst.id, '1');
  expect(fcProjectedFirst.properties, {'prop1': 'a', 'prop2': 100});
}

void _testToWebMercatorWithPoints<R extends ProjectedPoint>(
  CreatePosition<R> factory,
) {
  final toWebMercator = WGS84.webMercator.forward;

  // point series and multipoint
  final points = testWgs84Points();
  final pointsProjected = points.project(toWebMercator, to: factory);
  final multiPoint = MultiPoint(points);
  final multiPointProjected = multiPoint.project(toWebMercator, to: factory);
  for (var i = 0; i < points.length; i++) {
    expectProjected(
      pointsProjected[i],
      points[i].project(toWebMercator, to: factory),
    );
    expectProjected(
      multiPointProjected.points[i],
      points[i].project(toWebMercator, to: factory),
    );
  }

  // bounds
  final bounds = Bounds.of(min: points[0], max: points[1]);
  final boundsProjected = bounds.project(toWebMercator, to: factory);
  expectProjected(boundsProjected.min, pointsProjected[0]);
  expectProjected(boundsProjected.max, pointsProjected[1]);

  // geobounds
  final geoBounds = GeoBounds.of(min: points[0], max: points[1]);
  final geoBoundsProjected = geoBounds.project(toWebMercator, to: factory);
  expectProjected(geoBoundsProjected.min, pointsProjected[0]);
  expectProjected(geoBoundsProjected.max, pointsProjected[1]);

  // linestring and multilinestring
  final line = LineString.any(points);
  final lineProjected = line.project(toWebMercator, to: factory);
  final multiLine = MultiLineString([line]);
  final multiLineProjected = multiLine.project(toWebMercator, to: factory);
  for (var i = 0; i < line.chain.length; i++) {
    expectProjected(
      lineProjected.chain[i],
      line.chain[i].project(toWebMercator, to: factory),
    );
    expectProjected(
      multiLineProjected.lineStrings.first.chain[i],
      line.chain[i].project(toWebMercator, to: factory),
    );
  }

  // polygon and multipolygon
  final rings = testWgs84Rings();
  final polygon = Polygon.fromPoints(rings);
  final polygonProjected = polygon.project(toWebMercator, to: factory);
  final multiPolygon = MultiPolygon([polygon]);
  final multiPolygonProjected =
      multiPolygon.project(toWebMercator, to: factory);
  for (var i = 0; i < rings.length; i++) {
    final projectedRing = polygonProjected.rings[i];
    final projectedMultiRing = multiPolygonProjected.polygons.first.rings[i];
    final originalRing = rings.elementAt(i);
    for (var j = 0; j < originalRing.length; j++) {
      final match =
          originalRing.elementAt(i).project(toWebMercator, to: factory);
      expectProjected(projectedRing.chain[i], match);
      expectProjected(projectedMultiRing.chain[i], match);
    }
  }

  // geometry collection
  final collection = GeometryCollection([polygon]);
  final collectionProjected = collection.project(toWebMercator, to: factory);
  expect(collectionProjected.geometries.first, polygonProjected);

  // feature
  final feature = Feature(
    id: '1',
    properties: const {'prop1': 'a', 'prop2': 100},
    geometry: line,
  );
  final featureProjected = feature.project(toWebMercator, to: factory);
  expect(featureProjected.geometry, lineProjected);
  expect(featureProjected.id, '1');
  expect(featureProjected.properties, {'prop1': 'a', 'prop2': 100});

  // feature collection
  final fc = FeatureCollection(features: [feature]);
  final fcProjected = fc.project(toWebMercator, to: factory);
  final fcProjectedFirst = fcProjected.features.first;
  expect(fcProjectedFirst.geometry, lineProjected);
  expect(fcProjectedFirst.id, '1');
  expect(fcProjectedFirst.properties, {'prop1': 'a', 'prop2': 100});
}
