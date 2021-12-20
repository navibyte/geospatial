// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:equatable/equatable.dart';

import 'package:geocore/geocore.dart';

import 'package:test/test.dart';

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  group('Test projections between WGS84 and Web Mercator', () {
    test('webMercatorToWgs84(CartesianPoint to GeoPoint2)', () {
      final toWgs84 = webMercatorToWgs84(GeoPoint2.coordinates);
      for (final coords in _wgs84ToWebMercator) {
        final point2 = Point2(x: coords[2], y: coords[3]);
        final pointWrapper = PointWrapper(point2);
        final geoPoint2 = GeoPoint2(lon: coords[0], lat: coords[1]);
        _expectProjected(point2.project(toWgs84), geoPoint2);
        _expectProjected(pointWrapper.project(toWgs84), geoPoint2);
        _expectProjected(
          point2.project(toWgs84),
          GeoPoint3(lon: coords[0], lat: coords[1]),
        );
        _expectProjected(
          Point3(x: coords[2], y: coords[3], z: 30.0).project(toWgs84),
          GeoPoint2(lon: coords[0], lat: coords[1]),
        );
        _expectProjected(
          Point3(x: coords[2], y: coords[3], z: 30.0)
              .project(toWgs84, to: GeoPoint3.coordinates),
          GeoPoint3(lon: coords[0], lat: coords[1], elev: 30.0),
        );
      }
    });

    test('wgs84ToWebMercator(GeoPoint to Point3)', () {
      final toWebMercator = wgs84ToWebMercator(Point3.coordinates);
      for (final coords in _wgs84ToWebMercator) {
        final geoPoint3 = GeoPoint3(lon: coords[0], lat: coords[1]);
        final geoPointWrapper = GeoPointWrapper(geoPoint3);
        final point3 = Point3(x: coords[2], y: coords[3]);
        _expectProjected(geoPoint3.project(toWebMercator), point3, 0.01);
        _expectProjected(geoPointWrapper.project(toWebMercator), point3, 0.01);
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

void _expectProjected<T1 extends Point, T2 extends Point>(
  T1 actual,
  T2 expected, [
  num? tol,
]) {
  final equals2D = actual.equals2D(expected, toleranceHoriz: tol ?? 0.0000001);
  if (!equals2D) {
    print('$actual $expected');
  }
  expect(equals2D, isTrue);
  expect(actual.z, expected.z);
  expect(actual.m, expected.m);
}

void _testToWgs84WithPoints<R extends GeoPoint>(
  PointFactory<R> factory,
) {
  final toWgs84 = webMercatorToWgs84(factory);

  // point series and multipoint
  final points = _testWebMercatorPoints();
  final pointsProjected = points.project(toWgs84);
  final multiPoint = MultiPoint(points);
  final multiPointProjected = multiPoint.project(toWgs84);
  for (var i = 0; i < points.length; i++) {
    _expectProjected(
      pointsProjected[i],
      points[i].project(toWgs84),
    );
    _expectProjected(
      multiPointProjected.points[i],
      points[i].project(toWgs84),
    );
  }

  // bounds
  final bounds = Bounds.of(min: points[0], max: points[1]);
  final boundsProjected = bounds.project(toWgs84);
  final boundsProjectedAsGeoBounds = GeoBounds(boundsProjected);
  _expectProjected(boundsProjectedAsGeoBounds.min, pointsProjected[0]);
  _expectProjected(boundsProjectedAsGeoBounds.max, pointsProjected[1]);

  // linestring and multilinestring
  final line = LineString.any(points);
  final lineProjected = line.project(toWgs84);
  final multiLine = MultiLineString([line]);
  final multiLineProjected = multiLine.project(toWgs84);
  for (var i = 0; i < line.chain.length; i++) {
    _expectProjected(
      lineProjected.chain[i],
      line.chain[i].project(toWgs84),
    );
    _expectProjected(
      multiLineProjected.lineStrings.first.chain[i],
      line.chain[i].project(toWgs84),
    );
  }

  // polygon and multipolygon
  final rings = _testWebMercatorRings();
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
      _expectProjected(projectedRing.chain[i], match);
      _expectProjected(projectedMultiRing.chain[i], match);
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
  final toWebMercator = wgs84ToWebMercator(factory);

  // point series and multipoint
  final points = _testWgs84Points();
  final pointsProjected = points.project(toWebMercator);
  final multiPoint = MultiPoint(points);
  final multiPointProjected = multiPoint.project(toWebMercator);
  for (var i = 0; i < points.length; i++) {
    _expectProjected(
      pointsProjected[i],
      points[i].project(toWebMercator),
    );
    _expectProjected(
      multiPointProjected.points[i],
      points[i].project(toWebMercator),
    );
  }

  // bounds
  final bounds = Bounds.of(min: points[0], max: points[1]);
  final boundsProjected = bounds.project(toWebMercator);
  _expectProjected(boundsProjected.min, pointsProjected[0]);
  _expectProjected(boundsProjected.max, pointsProjected[1]);

  // geobounds
  final geoBounds = GeoBounds.of(min: points[0], max: points[1]);
  final geoBoundsProjected = geoBounds.project(toWebMercator);
  _expectProjected(geoBoundsProjected.min, pointsProjected[0]);
  _expectProjected(geoBoundsProjected.max, pointsProjected[1]);

  // linestring and multilinestring
  final line = LineString.any(points);
  final lineProjected = line.project(toWebMercator);
  final multiLine = MultiLineString([line]);
  final multiLineProjected = multiLine.project(toWebMercator);
  for (var i = 0; i < line.chain.length; i++) {
    _expectProjected(
      lineProjected.chain[i],
      line.chain[i].project(toWebMercator),
    );
    _expectProjected(
      multiLineProjected.lineStrings.first.chain[i],
      line.chain[i].project(toWebMercator),
    );
  }

  // polygon and multipolygon
  final rings = _testWgs84Rings();
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
      _expectProjected(projectedRing.chain[i], match);
      _expectProjected(projectedMultiRing.chain[i], match);
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

const _wgs84ToWebMercator = [
  [0.0, 0.0, 0.0, 0.0],
  [8.8472315, 47.3238447, 984869.31, 5995094.90],
  [-47.592335, -69.493853, -5297954.50, -10905942.09],
  [120.39284, 30.239245, 13402069.64, 3534339.78],
  [-179.9999999, -85.051129, -20037508.33, -20037508.63],
  [179.9999999, 85.051129, 20037508.33, 20037508.63],
  [-180.0, -85.051129, -20037508.34, -20037508.63],
  [180.0, 85.051129, -20037508.34, 20037508.63],
];

PointSeries<GeoPoint2> _testWgs84Points() => PointSeries.from(
      _wgs84ToWebMercator
          .map((coords) => GeoPoint2(lon: coords[0], lat: coords[1]))
          .toList(growable: false),
    );

PointSeries<Point2> _testWebMercatorPoints() => PointSeries.from(
      _wgs84ToWebMercator
          .map((coords) => Point2(x: coords[2], y: coords[3]))
          .toList(growable: false),
    );

const _wgs84ToWebMercatorExterior = [
  [40.0, 15.0, 4452779.63, 1689200.14],
  [50.0, 50.0, 5565974.54, 6446275.84],
  [15.0, 45.0, 1669792.36, 5621521.49],
  [10.0, 15.0, 1113194.91, 1689200.14],
  [40.0, 15.0, 4452779.63, 1689200.14],
];

const _wgs84ToWebMercatorInterior = [
  [25.0, 25.0, 2782987.27, 2875744.62],
  [25.0, 40.0, 2782987.27, 4865942.28],
  [35.0, 30.0, 3896182.18, 3503549.84],
  [25.0, 25.0, 2782987.27, 2875744.62],
];

Iterable<Iterable<GeoPoint2>> _testWgs84Rings() => [
      _wgs84ToWebMercatorExterior
          .map((coords) => GeoPoint2(lon: coords[0], lat: coords[1]))
          .toList(growable: false),
      _wgs84ToWebMercatorInterior
          .map((coords) => GeoPoint2(lon: coords[0], lat: coords[1]))
          .toList(growable: false),
    ];

Iterable<Iterable<Point2>> _testWebMercatorRings() => [
      _wgs84ToWebMercatorExterior
          .map((coords) => Point2(x: coords[2], y: coords[3]))
          .toList(growable: false),
      _wgs84ToWebMercatorInterior
          .map((coords) => Point2(x: coords[2], y: coords[3]))
          .toList(growable: false),
    ];
