// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:test/test.dart';

import 'package:geocore/geocore.dart';

import 'geojson_sample.dart';

void main() {
  group('GeoJSON tests', () {
    setUp(() {
      // NOP
    });

    test('Basic feature', () {
      final f = geoJSON.feature(geojsonFeature);
      expect(f.geometry, (g) => g == GeoPoint.from([125.6, 10.1]));
      expect(f.properties['name'], (p) => p == 'Dinagat Islands');
    });

    test('Basic feature collection', () {
      final fc = geoJSON.featureCollection(geojsonFeatureCollection);
      expect(fc.features.length, (value) => value == 3);
      expect(fc.features[0].geometry, (g) => g == GeoPoint.from([102.0, 0.5]));
      expect(fc.features[1].geometry,
          (g) => (g as LineString).chain[0] == GeoPoint.from([102.0, 0.0]));
      expect(fc.features[1].properties['prop1'], (p) => p == 0.0);
      expect(fc.features[2].geometry, (g) {
        final exterior = (g as Polygon).exterior;
        return exterior.dimension == 2 &&
            exterior.chain.isClosed &&
            exterior.chain[2] == GeoPoint.from([101.0, 1.0]);
      });
      expect(fc.features[2].properties['prop1']['this'], (p) => p == 'that');
    });
  });
}
