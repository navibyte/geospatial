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

    test('Test decoding ranges on feature collection', () {
      final coll123456 = _makeTestCollection([1, 2, 3, 4, 5, 6]);
      final coll12 = _makeTestCollection([1, 2]);
      final coll34 = _makeTestCollection([3, 4]);
      final coll56 = _makeTestCollection([5, 6]);
      final collEmpty = _makeTestCollection([]);

      // all feature items
      _testDecodeAndEncodeToGeoJSON(GeoJSON.feature, coll123456);

      // feature items by range
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(itemOffset: 0, itemLimit: 2),
        coll123456,
        geoJsonExpected: coll12,
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(itemLimit: 2),
        coll123456,
        geoJsonExpected: coll12,
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(itemOffset: 2, itemLimit: 2),
        coll123456,
        geoJsonExpected: coll34,
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(itemOffset: 4, itemLimit: 2),
        coll123456,
        geoJsonExpected: coll56,
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(itemOffset: 4, itemLimit: 1000),
        coll123456,
        geoJsonExpected: coll56,
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(itemOffset: 4),
        coll123456,
        geoJsonExpected: coll56,
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(itemOffset: 6, itemLimit: 2),
        coll123456,
        geoJsonExpected: collEmpty,
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(itemOffset: 1, itemLimit: 0),
        coll123456,
        geoJsonExpected: collEmpty,
      );
    });
  });
}

void _testDecodeAndEncodeToGeoJSON<Content extends Object>(
  TextFormat<Content> format,
  String geoJsonText, {
  String? geoJsonExpected,
}) {
  // GeoJSON encoder from geometry content to text
  final encoder = format.encoder();

  // GeoJSON decoder from text to geometry content (writing to encoder)
  final decoder = format.decoder(encoder.writer);

  // now decode the original sample...
  decoder.decodeText(geoJsonText);

  // ... and result encoded back to text should be here
  final geoJsonTextEncoded = encoder.toText();

  // test
  expect(geoJsonTextEncoded, geoJsonExpected ?? geoJsonText);
}

String _makeTestCollection(List<int> ids) {
  final str = StringBuffer('{"type":"FeatureCollection","features":[');
  var first = true;
  for (final id in ids) {
    if (first) {
      first = false;
    } else {
      str.write(',');
    }
    str.write('{"type":"Feature","id":$id,"properties":{}}');
  }
  str.write(']}');
  return str.toString();
}
