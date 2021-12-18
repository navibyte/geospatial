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

    test(
        'wgs84ToWebMercator(GeoPoint to PointXX) in PointSeries and LineString',
        () {
      _testToWebMercatorWithPoints(Point2.coordinates);
      _testToWebMercatorWithPoints(Point2m.coordinates);
      _testToWebMercatorWithPoints(Point3.coordinates);
      _testToWebMercatorWithPoints(Point3m.coordinates);
    });

    test(
        'webMercatorToWgs84(CartesianPoint to GeoPointXX)'
        ' in PointSeries and LineString', () {
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

  // point serties
  final points = _testWebMercatorPoints();
  final pointsUnprojected = points.project(toWgs84);
  for (var i = 0; i < points.length; i++) {
    _expectProjected(
      pointsUnprojected[i],
      points[i].project(toWgs84),
    );
  }
}

void _testToWebMercatorWithPoints<R extends CartesianPoint>(
  PointFactory<R> factory,
) {
  final toWebMercator = wgs84ToWebMercator(factory);

  // point serties
  final points = _testWgs84Points();
  final pointsProjected = points.project(toWebMercator);
  for (var i = 0; i < points.length; i++) {
    _expectProjected(
      pointsProjected[i],
      points[i].project(toWebMercator),
      0.01,
    );
  }

  // linestring
  final line = LineString.any(points);
  final lineProjected = line.project(toWebMercator);
  for (var i = 0; i < line.chain.length; i++) {
    _expectProjected(
      lineProjected.chain[i],
      line.chain[i].project(toWebMercator),
      0.01,
    );
  }
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
