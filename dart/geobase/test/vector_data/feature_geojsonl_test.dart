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
      [null, '\n'],
      [null, '\r\n'],
      [null, '\n\r'],
      ['\u{1e}', '\n'],
      ['\u{1e}', '\r\n'],
      [' ', ' \n'],
      ['\t', '\t\n'],
      ['\n', '\r\n \t \n'],
    ];

    test('Decoding and encoding from GeoJSONL', () {
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
          if (sep[0] != null) {
            buf.write(sep[0]);
          }
          buf.write(featureJson);
          if (sep[1] != null) {
            buf.write(sep[1]);
          }
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

        // encode a feature collection to GeoJSONL text

        final encodeOptions = !(sep[0] == null && sep[1] == '\n')
            ? {
                'GeoJSONL.delimiterBefore': sep[0],
                'GeoJSONL.delimiterAfter': sep[1],
              }
            : null;
        final fcOutput = fc.toText(
          format: GeoJSONL.feature,
          options: encodeOptions,
        );
        expect(fcOutput, source);

        // encode a single feature to GeoJSONL text

        final f2Output = f2.toText(
          format: GeoJSONL.feature,
          options: encodeOptions,
        );
        expect(f2Output, '${sep[0] ?? ''}${geoJsonFeatures[2]}${sep[1] ?? ''}');
      }
    });
  });
}
