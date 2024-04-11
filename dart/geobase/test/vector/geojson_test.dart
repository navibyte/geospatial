// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: cascade_invocations

import 'package:geobase/coordinates.dart';
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
        GeoJSON.featureFormat(),
        coll123456,
        geoJsonExpected: coll12,
        options: {'itemOffset': 0, 'itemLimit': 2},
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(),
        coll123456,
        geoJsonExpected: coll12,
        options: {'itemLimit': 2},
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(),
        coll123456,
        geoJsonExpected: coll34,
        options: {'itemOffset': 2, 'itemLimit': 2},
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(),
        coll123456,
        geoJsonExpected: coll56,
        options: {'itemOffset': 4, 'itemLimit': 2},
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(),
        coll123456,
        geoJsonExpected: coll56,
        options: {'itemOffset': 4, 'itemLimit': 1000},
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(),
        coll123456,
        geoJsonExpected: coll56,
        options: {'itemOffset': 4},
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(),
        coll123456,
        geoJsonExpected: collEmpty,
        options: {'itemOffset': 6, 'itemLimit': 2},
      );
      _testDecodeAndEncodeToGeoJSON(
        GeoJSON.featureFormat(),
        coll123456,
        geoJsonExpected: collEmpty,
        options: {'itemOffset': 1, 'itemLimit': 0},
      );
    });

    test('Test decimals and number compacting', () {
      final geoJSONNotCompact = GeoJSON.geometryFormat(
        conf: const GeoJsonConf(compactNums: false),
      );
      final testCases = [
        [
          (GeometryContent geom) => geom.point([-0.0014, 51.4778, 45.0].xyz),
          (StringBuffer buf) => GeoJSON.geometry.encoder(buffer: buf),
          '{"type":"Point","coordinates":[-0.0014,51.4778,45]}',
        ],
        [
          (GeometryContent geom) => geom.point([-0.0014, 51.4778, 45.0].xyz),
          (StringBuffer buf) => GeoJSON.geometry.encoder(
                buffer: buf,
                decimals: 1,
              ),
          '{"type":"Point","coordinates":[-0.0,51.5,45]}',
        ],
        [
          (GeometryContent geom) => geom.point([-0.0014, 51.4778, 45.0].xyz),
          (StringBuffer buf) => GeoJSON.geometry.encoder(
                buffer: buf,
                decimals: 5,
              ),
          '{"type":"Point","coordinates":[-0.00140,51.47780,45]}',
        ],
        [
          (GeometryContent geom) => geom.point([-0.0014, 51.4778, 45.0].xyz),
          (StringBuffer buf) => geoJSONNotCompact.encoder(
                buffer: buf,
                decimals: 1,
              ),
          '{"type":"Point","coordinates":[-0.0,51.5,45.0]}',
        ],
        [
          (GeometryContent geom) => geom.point([-0.0014, 51.4778, 45.0].xyz),
          (StringBuffer buf) => geoJSONNotCompact.encoder(
                buffer: buf,
                decimals: 5,
              ),
          '{"type":"Point","coordinates":[-0.00140,51.47780,45.00000]}',
        ],
        [
          (GeometryContent geom) => geom.point([-0.0014, 51.4778, 45.0].xyz),
          (StringBuffer buf) => geoJSONNotCompact.encoder(buffer: buf),
          '{"type":"Point","coordinates":[-0.0014,51.4778,45.0]}',
        ],
      ];

      for (final test in testCases) {
        final content = test[0] as WriteGeometries;
        final createEncoder =
            test[1] as ContentEncoder<GeometryContent> Function(StringBuffer);
        final geojson = test[2] as String;
        final buf = StringBuffer();
        final encoder = createEncoder.call(buf);
        content.call(encoder.writer);
        expect(buf.toString(), geojson);
      }
    });
  });
}

void _testDecodeAndEncodeToGeoJSON<Content extends Object>(
  TextFormat<Content> format,
  String geoJsonText, {
  Map<String, dynamic>? options,
  String? geoJsonExpected,
}) {
  // GeoJSON encoder from geometry content to text
  final encoder = format.encoder();

  // GeoJSON decoder from text to geometry content (writing to encoder)
  final decoder = format.decoder(encoder.writer, options: options);

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
    str.write('{"type":"Feature","id":$id,"geometry":null,"properties":{}}');
  }
  str.write(']}');
  return str.toString();
}
