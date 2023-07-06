// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: require_trailing_commas

import 'package:geobase/geobase.dart';

import 'package:test/test.dart';

void main() {
  group('Spherical geodesy functions', () {
    // with test values derived from:
    //   https://www.movable-type.co.uk/scripts/latlong.html

    const p1 = Geographic(lat: 52.205, lon: 0.119);
    const p2 = Geographic(lat: 48.857, lon: 2.351);

    const p3 = Geographic(lat: 50.066389, lon: -5.714722);
    const p4 = Geographic(lat: 58.643889, lon: -3.07);

    test('Distance haversine', () {
      // ignore: deprecated_member_use_from_same_package
      expect(distanceHaversine(p3, p4), 968853.5441168448);

      expect(p1.distanceTo(p2), closeTo(404300, 300)); // 404.3×10³ m
      expect(p1.distanceTo(p2, radius: 3959), closeTo(251.2, 0.03)); // 251.2 mi
      expect(p3.distanceTo(p4), 968853.5441168448);
    });

    test('Initial bearing', () {
      expect(p1.initialBearingTo(p2), closeTo(156.2, 0.1)); // 156.2°
      expect(p3.initialBearingTo(p4), closeTo(9.1198, 0.0001));
    });
  });
}
