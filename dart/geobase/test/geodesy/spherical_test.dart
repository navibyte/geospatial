// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: require_trailing_commas

import 'package:geobase/geobase.dart';

import 'package:test/test.dart';

void main() {
  group('Geography functions', () {
    // with test values derived from:
    //   https://www.movable-type.co.uk/scripts/latlong.html

    const p1 = Geographic(lat: 50.066389, lon: -5.714722);
    const p2 = Geographic(lat: 58.643889, lon: -3.07);

    test('Distance haversine', () {
      expect(distanceHaversine(p1, p2), 968853.5441168448);
    });
  });
}
