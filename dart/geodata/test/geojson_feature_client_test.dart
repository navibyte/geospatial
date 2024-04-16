// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_redundant_argument_values

// importing `dart:io` not supported on the Flutter web platform
import 'dart:io' show File;

import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';
import 'package:geodata/geojson_client.dart';

import 'package:test/test.dart';

void main() {
  group('GeoJSON feature client', () {
    test('Test accessing a local GeoJSON file (London)', () async {
      final source = GeoJSONFeatures.any(
        () async => File('test/data/london.geojson').readAsString(),
        format: GeoJSON.feature,
      );

      final items = await source.itemsAll();
      _testLondonFeatureCollection(items.collection);
    });

    test('Test accessing a local GeoJSONL file (London)', () async {
      final source = GeoJSONFeatures.any(
        () async => File('test/data/london.geojsonl').readAsString(),
        format: GeoJSONL.feature,
      );

      final items = await source.itemsAll();
      _testLondonFeatureCollection(items.collection);
    });

    test('Test accessing a local GeoJSON file (USGS)', () async {
      final source = GeoJSONFeatures.any(
        () async => File('test/usgs/summary/2.5_day.geojson').readAsString(),
        format: GeoJSON.feature,
      );

      await _testUSGSFeatureCollection(source);
    });

    test('Test accessing a local GeoJSONL file (USGS)', () async {
      final source = GeoJSONFeatures.any(
        () async => File('test/usgs/summary/2.5_day.geojsonl').readAsString(),
        format: GeoJSONL.feature,
      );

      await _testUSGSFeatureCollection(source);
    });
  });
}

Future<void> _testUSGSFeatureCollection(
  BasicFeatureSource<FeatureItem, FeatureItems> source,
) async {
  final itemsAll = await source.itemsAll();
  final all = itemsAll.collection.features;
  expect(all.length, 37);
  expect(all[17].properties['place'], '12km SW of Searles Valley, CA');

  final itemsById14 = await source.itemById('nn00801358');
  expect(itemsById14.feature.id, 'nn00801358');
  expect(itemsById14.feature.properties['place'], '28 km SSE of Mina, Nevada');

  final itemsPaged0 = await source.itemsAllPaged(limit: 20);
  final paged0 = itemsPaged0.current.collection.features;
  expect(paged0.length, 20);
  expect(paged0[17].properties['place'], '12km SW of Searles Valley, CA');

  expect(itemsPaged0.hasNext, true);
  final itemsPaged1 = await itemsPaged0.next();
  if (itemsPaged1 != null) {
    final paged1 = itemsPaged1.current.collection.features;
    expect(paged1.length, 17);
    expect(paged1[1].properties['place'], '116 km ENE of Luwuk, Indonesia');

    expect(itemsPaged1.hasNext, false);
  }
}

void _testLondonFeatureCollection(FeatureCollection collection) {
  expect(collection.features.length, 2);

  final greenwich = collection.features.first;
  expect(greenwich.id, 'ROG');
  expect(greenwich.geometry, Point.build([-0.0014, 51.4778, 45]));
}
