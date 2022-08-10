// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: cascade_invocations

import 'package:geobase/vector.dart';

import 'package:test/test.dart';

import 'geojson_samples.dart';

void main() {
  group('Test GeoJSON encoding and decoding', () {
    test('Test geometry samples', () {
      for (final sample in geoJsonGeometries) {
        //print(sample);
        _testDecodeAndEncodeToGeoJSON(GeoJSON.geometry, sample);
      }
    });

    test('Test feature samples', () {
      for (final sample in geoJsonFeatures) {
        //print(sample);
        _testDecodeAndEncodeToGeoJSON(GeoJSON.feature, sample);
      }
    });

    test('Test feature collection samples', () {
      for (final sample in geoJsonFeatureCollections) {
        //print(sample);
        _testDecodeAndEncodeToGeoJSON(GeoJSON.feature, sample);
      }
    });
  });
}

void _testDecodeAndEncodeToGeoJSON<Content extends Object>(
  TextFormat<Content> format,
  String geoJsonText,
) {
  // GeoJSON encoder from geometry content to text
  final encoder = format.encoder();

  // GeoJSON decoder from text to geometry content (writing to encoder)
  final decoder = format.decoder(encoder.writer);

  // now decode the original sample...
  decoder.decodeText(geoJsonText);

  // ... and result encoded back to text should be here
  final geoJsonTextEncoded = encoder.toText();

  // test
  expect(geoJsonTextEncoded, geoJsonText);
}
