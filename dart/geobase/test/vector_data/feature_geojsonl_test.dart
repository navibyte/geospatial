// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';

import 'package:test/test.dart';

import '../vector/geojson_samples.dart';

void main() {
  group('Features on GeoJSONL', () {
    const lineSeparators = [
      ['', '\n'],
      ['', '\r\n'],
      ['', '\n\r'],
      ['\u{1e}', '\n'],
      ['\u{1e}', '\r\n'],
      [' ', ' \n'],
      ['\t', '\t\n'],
    ];

    test('Decoding from GeoJSONL', () {
      final expectedFeatureCollection = '{"type":"FeatureCollection",'
          '"features":[${geoJsonFeatures.join(',')}]}';
      final expectedFeatureCollectionFrom2 = '{"type":"FeatureCollection",'
          '"features":[${geoJsonFeatures.skip(2).join(',')}]}';
      final expectedFeatureCollectionFrom2Limit2 =
          '{"type":"FeatureCollection",'
          '"features":[${geoJsonFeatures.skip(2).take(2).join(',')}]}';

      for (final sep in lineSeparators) {
        // create test GeoJSONL text with given separators
        final buf = StringBuffer();
        for (final featureJson in geoJsonFeatures) {
          buf
            ..write(sep[0])
            ..write(featureJson)
            ..write(sep[1]);
        }
        final source = buf.toString();

        // parse a feature collection from GeoJSONL text

        final fc = FeatureCollection.parse(
          source,
          format: GeoJSONL.feature,
        );
        expect(fc.toString(), expectedFeatureCollection);

        final fcFrom2 = FeatureCollection.parse(
          source,
          format: GeoJSONL.feature,
          options: {'itemOffset': 2},
        );

        expect(fcFrom2.toString(), expectedFeatureCollectionFrom2);
        final fcFrom2Limit2 = FeatureCollection.parse(
          source,
          format: GeoJSONL.feature,
          options: {'itemOffset': 2, 'itemLimit': 2},
        );
        expect(fcFrom2Limit2.toString(), expectedFeatureCollectionFrom2Limit2);

        // parse a single feature from GeoJSONL text (get a first one)

        final f0 = Feature.parse(
          source,
          format: GeoJSONL.feature,
        );
        expect(f0.toString(), geoJsonFeatures.first);

        final f2 = Feature.parse(
          source,
          format: GeoJSONL.feature,
          options: {'itemOffset': 2},
        );
        expect(f2.toString(), geoJsonFeatures[2]);
      }
    });
  });
}
