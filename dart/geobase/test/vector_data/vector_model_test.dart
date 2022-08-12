// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: cascade_invocations, lines_longer_than_80_chars

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
        _testDecodeFeatureObjectAndEncodeToGeoJSON(GeoJSON.feature, sample);
      }
    });

    test('Test feature collection samples', () {
      for (final sample in geoJsonFeatureCollections) {
        //print(sample);
        _testDecodeFeatureObjectAndEncodeToGeoJSON(GeoJSON.feature, sample);
      }
    });
  });

  group('Typed collections and features', () {
    const props = '"properties":{"foo":1,"bar":"baz"}';
    const point = '{"type":"Point","coordinates":[1.5,2.5]}';
    const lineString =
        '{"type":"LineString","coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]}';

    const geomColl =
        '{"type":"GeometryCollection","geometries":[$point,$lineString]}';
    const geomCollPoints =
        '{"type":"GeometryCollection","geometries":[$point,$point]}';

    const pointFeat = '{"type":"Feature","geometry":$point,$props}';
    const lineStringFeat = '{"type":"Feature","geometry":$lineString,$props}';

    const featColl =
        '{"type":"FeatureCollection","features":[$pointFeat,$lineStringFeat]}';
    const featCollPoints =
        '{"type":"FeatureCollection","features":[$pointFeat,$pointFeat]}';

    test('Basic geometries', () {
      expect(Point.fromText(point).toText(), point);
      expect(LineString.fromText(lineString).toText(), lineString);
    });

    test('Geometry collection with non-typed geometry', () {
      expect(GeometryCollection.fromText(geomColl).toText(), geomColl);
      expect(
        GeometryCollection.fromText(geomCollPoints).toText(),
        geomCollPoints,
      );
    });

    test('Geometry collection with typed geometry', () {
      expect(
        GeometryBuilder.decodeCollection<Point>(geomCollPoints).toText(),
        geomCollPoints,
      );
      expect(
        GeometryCollection.fromText<Point>(geomCollPoints).toText(),
        geomCollPoints,
      );
    });

    test('Feature with non-typed geometry', () {
      expect(Feature.fromText(pointFeat).toText(), pointFeat);
      final feat = Feature.fromText(lineStringFeat);
      expect(feat.toText(), lineStringFeat);
    });

    test('Feature with typed geometry', () {
      expect(Feature.fromText<Point>(pointFeat).toText(), pointFeat);
      final feat = Feature.fromText<LineString>(lineStringFeat);
      expect(feat.toText(), lineStringFeat);
    });

    test('Feature collection with non-typed geometry', () {
      expect(FeatureCollection.fromText(featColl).toText(), featColl);
      final coll = FeatureCollection.fromText(featCollPoints);
      expect(coll.toText(), featCollPoints);
    });

    test('Feature collection with typed geometry', () {
      final coll = FeatureCollection.fromText<Point>(featCollPoints);
      expect(coll.toText(), featCollPoints);
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

  // try to create also using factory method and then write back
  switch (geometry.geomType) {
    case Geom.point:
      expect(Point.fromText(geoJsonText).toText(), geoJsonText);
      break;
    case Geom.lineString:
      expect(LineString.fromText(geoJsonText).toText(), geoJsonText);
      break;
    case Geom.polygon:
      expect(Polygon.fromText(geoJsonText).toText(), geoJsonText);
      break;
    case Geom.multiPoint:
      expect(MultiPoint.fromText(geoJsonText).toText(), geoJsonText);
      break;
    case Geom.multiLineString:
      expect(MultiLineString.fromText(geoJsonText).toText(), geoJsonText);
      break;
    case Geom.multiPolygon:
      expect(MultiPolygon.fromText(geoJsonText).toText(), geoJsonText);
      break;
    case Geom.geometryCollection:
      expect(GeometryCollection.fromText(geoJsonText).toText(), geoJsonText);
      break;
  }
}

void _testDecodeFeatureObjectAndEncodeToGeoJSON(
  TextFormat<FeatureContent> format,
  String geoJsonText,
) {
  // build feature objects from content decoded from GeoJSON text
  final objects = FeatureBuilder.buildList(
    (builder) {
      // GeoJSON decoder from text to feature content (writing to builder)
      final decoder = format.decoder(builder);

      // decode
      decoder.decodeText(geoJsonText);
    },
  );

  // get the sample feature object as a model object from list just built
  expect(objects.length, 1);
  final object = objects.first;

  // GeoJSON encoder from feature content to text
  final encoder = format.encoder();

  // encode feature object back to GeoJSON text
  object.writeTo(encoder.writer);
  final geoJsonTextEncoded = encoder.toText();

  // test
  expect(geoJsonTextEncoded, geoJsonText);

  // try to create also using factory method and then write back
  if (object is Feature) {
    expect(Feature.fromText(geoJsonText).toText(), geoJsonText);
  } else if (object is FeatureCollection) {
    expect(FeatureCollection.fromText(geoJsonText).toText(), geoJsonText);
  }
}
