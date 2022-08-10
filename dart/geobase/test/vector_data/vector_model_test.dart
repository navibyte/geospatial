// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: cascade_invocations

import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';

import 'package:test/test.dart';

import '../vector/geojson_samples.dart';

// see also '../vector/geojson_test.dart'

void main() {
  group('Test GeoJSON decoding to model objects and back to GeoJSON', () {
    test('Test geometry samples', () {
      for (final sample in geoJsonGeometries) {
        //print(sample);
        _testDecodeGeometryAndEncodeToGeoJSON(GeoJSON.geometry, sample);
      }
    });

    test('Test feature samples', () {
      for (final sample in geoJsonFeatures) {
        //print(sample);
        _testDecodeEntityAndEncodeToGeoJSON(GeoJSON.feature, sample);
      }
    });

    test('Test feature collection samples', () {
      for (final sample in geoJsonFeatureCollections) {
        //print(sample);
        _testDecodeEntityAndEncodeToGeoJSON(GeoJSON.feature, sample);
      }
    });
  });
}

void _testDecodeGeometryAndEncodeToGeoJSON(
  TextFormat<GeometryContent> format,
  String geoJsonText,
) {
  // builder geometries from content decoded from GeoJSON text
  final geometries = GeometryBuilder.buildList(
    (builder) {
      // GeoJSON decoder from text to geometry content (writing to builder)
      final decoder = format.decoder(builder);

      // decode
      decoder.decodeText(geoJsonText);
    },
  );

  // get the sample geometry as a model object from list just built
  expect(geometries.length, 1);
  final geometry = geometries.first;

  // GeoJSON encoder from geometry content to text
  final encoder = format.encoder();

  // encode geometry object back to GeoJSON text
  geometry.writeTo(encoder.writer);
  final geoJsonTextEncoded = encoder.toText();

  // test
  expect(geoJsonTextEncoded, geoJsonText);
}

void _testDecodeEntityAndEncodeToGeoJSON(
  TextFormat<FeatureContent> format,
  String geoJsonText,
) {
  // builder entities from content decoded from GeoJSON text
  final entities = EntityBuilder.buildList(
    (builder) {
      // GeoJSON decoder from text to entity content (writing to builder)
      final decoder = format.decoder(builder);

      // decode
      decoder.decodeText(geoJsonText);
    },
  );

  // get the sample entity as a model object from list just built
  expect(entities.length, 1);
  final entity = entities.first;

  // GeoJSON encoder from entity content to text
  final encoder = format.encoder();

  // encode entity object back to GeoJSON text
  entity.writeTo(encoder.writer);
  final geoJsonTextEncoded = encoder.toText();

  // test
  expect(geoJsonTextEncoded, geoJsonText);
}
