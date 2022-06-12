// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print

import 'package:geocore/geocore.dart';

import 'package:test/test.dart';

void expectProjected<T1 extends Point, T2 extends Point>(
  T1 actual,
  T2 expected, [
  num? tol,
  num? tolZ,
]) {
  final equals2D = actual.equals2D(expected, toleranceHoriz: tol ?? 0.0000001);
  if (!equals2D) {
    print('$actual $expected');
  }
  expect(equals2D, isTrue);
  if (tolZ != null) {
    final equals3D = actual.equals3D(
      expected,
      toleranceHoriz: tol ?? 0.0000001,
      toleranceVert: tolZ,
    );
    if (!equals3D) {
      print('$actual $expected');
    }
    expect(equals3D, isTrue);
  } else {
    expect(actual.z, expected.z);
  }
  expect(actual.m, expected.m);
}

const wgs84ToWebMercatorData = [
  [0.0, 0.0, 0.0, 0.0],
  [8.8472315, 47.3238447, 984869.31, 5995094.90],
  [-47.592335, -69.493853, -5297954.50, -10905942.09],
  [120.39284, 30.239245, 13402069.64, 3534339.78],
  [-179.9999999, -85.05112878, -20037508.33, -20037508.34],
  [179.9999999, 85.05112878, 20037508.33, 20037508.34],
  [-180.0, -85.05112878, -20037508.34, -20037508.34],
  [180.0, 85.05112878, -20037508.34, 20037508.34],
];


PointSeries<GeoPoint2> testWgs84Points() => PointSeries.from(
      wgs84ToWebMercatorData
          .map((coords) => GeoPoint2(lon: coords[0], lat: coords[1]))
          .toList(growable: false),
    );

PointSeries<Point2> testWebMercatorPoints() => PointSeries.from(
      wgs84ToWebMercatorData
          .map((coords) => Point2(x: coords[2], y: coords[3]))
          .toList(growable: false),
    );

const wgs84ToWebMercatorExterior = [
  [40.0, 15.0, 4452779.63, 1689200.14],
  [50.0, 50.0, 5565974.54, 6446275.84],
  [15.0, 45.0, 1669792.36, 5621521.49],
  [10.0, 15.0, 1113194.91, 1689200.14],
  [40.0, 15.0, 4452779.63, 1689200.14],
];

const wgs84ToWebMercatorInterior = [
  [25.0, 25.0, 2782987.27, 2875744.62],
  [25.0, 40.0, 2782987.27, 4865942.28],
  [35.0, 30.0, 3896182.18, 3503549.84],
  [25.0, 25.0, 2782987.27, 2875744.62],
];

Iterable<Iterable<GeoPoint2>> testWgs84Rings() => [
      wgs84ToWebMercatorExterior
          .map((coords) => GeoPoint2(lon: coords[0], lat: coords[1]))
          .toList(growable: false),
      wgs84ToWebMercatorInterior
          .map((coords) => GeoPoint2(lon: coords[0], lat: coords[1]))
          .toList(growable: false),
    ];

Iterable<Iterable<Point2>> testWebMercatorRings() => [
      wgs84ToWebMercatorExterior
          .map((coords) => Point2(x: coords[2], y: coords[3]))
          .toList(growable: false),
      wgs84ToWebMercatorInterior
          .map((coords) => Point2(x: coords[2], y: coords[3]))
          .toList(growable: false),
    ];
