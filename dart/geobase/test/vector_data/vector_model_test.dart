// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: cascade_invocations, lines_longer_than_80_chars

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';

import 'package:test/test.dart';

import '../vector/geojson_samples.dart';

// see also '../vector/geojson_test.dart'

void main() {
  group('Test GeoJSON decoding to model objects and back to GeoJSON', () {
    test('Test geometry samples (GeoJSON)', () {
      for (final sample in geoJsonGeometries) {
        //print(sample);
        _testDecodeGeometryAndEncodeToGeoJSON(GeoJSON.geometry, sample);
      }
    });

    test('Test geometry samples (GeoJSON -> WKB)', () {
      for (final sample in geoJsonGeometries) {
        // filter out samples with bbox as WKB does not support
        if (!sample.contains('bbox')) {
          //print(sample);
          _testDecodeGeometryAndEncodeToWKB(
            GeoJSON.geometry,
            WKB.geometry,
            sample,
          );
        }
      }
    });

    test('Test feature samples (GeoJSON)', () {
      for (final sample in geoJsonFeatures) {
        //print(sample);
        _testDecodeFeatureObjectAndEncodeToGeoJSON(GeoJSON.feature, sample);
      }
    });

    test('Test feature collection samples (GeoJSON)', () {
      for (final sample in geoJsonFeatureCollections) {
        //print(sample);
        _testDecodeFeatureObjectAndEncodeToGeoJSON(GeoJSON.feature, sample);
      }
    });
  });

  group('Parsing geometries', () {
    const pointCoords = '1.5,2.5';
    const pointCoordsYX = '2.5,1.5';
    const point = '{"type":"Point","coordinates":[$pointCoords]}';
    const pointYX = '{"type":"Point","coordinates":[$pointCoordsYX]}';
    const lineStringCoords = '[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]';
    const lineStringCoordsYX = '[-1.1,-1.1],[-2.5,2.1],[-3.49,3.5]';
    const lineString =
        '{"type":"LineString","coordinates":[$lineStringCoords]}';
    const lineStringYX =
        '{"type":"LineString","coordinates":[$lineStringCoordsYX]}';
    const polygonCoords =
        '[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]],[[11.1,11.1],[6.0,9.9],[13.0,4.9],[11.1,11.1]]';
    const polygonCoordsYX =
        '[[10.1,10.1],[9.0,5.0],[4.0,12.0],[10.1,10.1]],[[11.1,11.1],[9.9,6.0],[4.9,13.0],[11.1,11.1]]';
    const polygon = '{"type":"Polygon","coordinates":[$polygonCoords]}';
    const polygonYX = '{"type":"Polygon","coordinates":[$polygonCoordsYX]}';
    const multiPointCoords =
        '[-1.1,-1.1,-1.1,-1.1],[2.1,-2.5,2.3,0.1],[3.5,-3.49,11.3,0.23]';
    const multiPointCoordsYX =
        '[-1.1,-1.1,-1.1,-1.1],[-2.5,2.1,2.3,0.1],[-3.49,3.5,11.3,0.23]';
    const multiPoint =
        '{"type":"MultiPoint","coordinates":[$multiPointCoords]}';
    const multiPointYX =
        '{"type":"MultiPoint","coordinates":[$multiPointCoordsYX]}';
    const multiLineStringCoords =
        '[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]],[[11.1,11.1],[6.0,9.9],[13.0,4.9],[11.1,11.1]]';
    const multiLineStringCoordsYX =
        '[[10.1,10.1],[9.0,5.0],[4.0,12.0],[10.1,10.1]],[[11.1,11.1],[9.9,6.0],[4.9,13.0],[11.1,11.1]]';
    const multiLineString =
        '{"type":"MultiLineString","coordinates":[$multiLineStringCoords]}';
    const multiLineStringYX =
        '{"type":"MultiLineString","coordinates":[$multiLineStringCoordsYX]}';
    const multiPolygonCoords =
        '[[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]],[[11.1,11.1],[6.0,9.9],[13.0,4.9],[11.1,11.1]]]';
    const multiPolygonCoordsYX =
        '[[[10.1,10.1],[9.0,5.0],[4.0,12.0],[10.1,10.1]],[[11.1,11.1],[9.9,6.0],[4.9,13.0],[11.1,11.1]]]';
    const multiPolygon =
        '{"type":"MultiPolygon","coordinates":[$multiPolygonCoords]}';
    const multiPolygonYX =
        '{"type":"MultiPolygon","coordinates":[$multiPolygonCoordsYX]}';

    test('Simple geometries', () {
      expect(Point.parse(point).toText(), point);
      expect(Point.parseCoords(pointCoords).toText(), point);
      expect(LineString.parse(lineString).toText(), lineString);
      expect(LineString.parseCoords(lineStringCoords).toText(), lineString);
      expect(Polygon.parse(polygon).toText(), polygon);
      expect(Polygon.parseCoords(polygonCoords).toText(), polygon);
      expect(MultiPoint.parse(multiPoint).toText(), multiPoint);
      expect(MultiPoint.parseCoords(multiPointCoords).toText(), multiPoint);
      expect(MultiLineString.parse(multiLineString).toText(), multiLineString);
      expect(
        MultiLineString.parseCoords(multiLineStringCoords).toText(),
        multiLineString,
      );
      expect(MultiPolygon.parse(multiPolygon).toText(), multiPolygon);
      expect(
        MultiPolygon.parseCoords(multiPolygonCoords).toText(),
        multiPolygon,
      );
    });

    test('Simple geometries with crs with AxisOrder.yx input', () {
      const crsDataList = [
        [CoordRefSys.CRS84, AxisOrder.xy],
        [CoordRefSys.EPSG_4326, AxisOrder.yx],
        [CoordRefSys.EPSG_3857, AxisOrder.xy],
      ];
      for (final crsData in crsDataList) {
        final crs = crsData[0] as CoordRefSys;
        final order = crsData[1] as AxisOrder;
        if (order == AxisOrder.xy) {
          expect(Point.parse(point, crs: crs).toText(), point);
          expect(Point.parseCoords(pointCoords, crs: crs).toText(), point);
          expect(LineString.parse(lineString, crs: crs).toText(), lineString);
          expect(
            LineString.parseCoords(lineStringCoords, crs: crs).toText(),
            lineString,
          );
          expect(Polygon.parse(polygon, crs: crs).toText(), polygon);
          expect(
            Polygon.parseCoords(polygonCoords, crs: crs).toText(),
            polygon,
          );
          expect(MultiPoint.parse(multiPoint, crs: crs).toText(), multiPoint);
          expect(
            MultiPoint.parseCoords(multiPointCoords, crs: crs).toText(),
            multiPoint,
          );
          expect(
            MultiLineString.parse(multiLineString, crs: crs).toText(),
            multiLineString,
          );
          expect(
            MultiLineString.parseCoords(multiLineStringCoords, crs: crs)
                .toText(),
            multiLineString,
          );
          expect(
            MultiPolygon.parse(multiPolygon, crs: crs).toText(),
            multiPolygon,
          );
          expect(
            MultiPolygon.parseCoords(multiPolygonCoords, crs: crs).toText(),
            multiPolygon,
          );
        } else if (order == AxisOrder.yx) {
          // toText without CRS (so default xy order)
          expect(Point.parse(pointYX, crs: crs).toText(), point);
          expect(Point.parseCoords(pointCoordsYX, crs: crs).toText(), point);
          expect(LineString.parse(lineStringYX, crs: crs).toText(), lineString);
          expect(
            LineString.parseCoords(lineStringCoordsYX, crs: crs).toText(),
            lineString,
          );
          expect(Polygon.parse(polygonYX, crs: crs).toText(), polygon);
          expect(
            Polygon.parseCoords(polygonCoordsYX, crs: crs).toText(),
            polygon,
          );
          expect(MultiPoint.parse(multiPointYX, crs: crs).toText(), multiPoint);
          expect(
            MultiPoint.parseCoords(multiPointCoordsYX, crs: crs).toText(),
            multiPoint,
          );
          expect(
            MultiLineString.parse(multiLineStringYX, crs: crs).toText(),
            multiLineString,
          );
          expect(
            MultiLineString.parseCoords(multiLineStringCoordsYX, crs: crs)
                .toText(),
            multiLineString,
          );
          expect(
            MultiPolygon.parse(multiPolygonYX, crs: crs).toText(),
            multiPolygon,
          );
          expect(
            MultiPolygon.parseCoords(multiPolygonCoordsYX, crs: crs).toText(),
            multiPolygon,
          );

          // toText with CRS (so yx order and swapping should occur)
          expect(Point.parse(pointYX, crs: crs).toText(crs: crs), pointYX);
          expect(
            Point.parseCoords(pointCoordsYX, crs: crs).toText(crs: crs),
            pointYX,
          );
          expect(
            LineString.parse(lineStringYX, crs: crs).toText(crs: crs),
            lineStringYX,
          );
          expect(
            LineString.parseCoords(lineStringCoordsYX, crs: crs)
                .toText(crs: crs),
            lineStringYX,
          );
          expect(
            Polygon.parse(polygonYX, crs: crs).toText(crs: crs),
            polygonYX,
          );
          expect(
            Polygon.parseCoords(polygonCoordsYX, crs: crs).toText(crs: crs),
            polygonYX,
          );
          expect(
            MultiPoint.parse(multiPointYX, crs: crs).toText(crs: crs),
            multiPointYX,
          );
          expect(
            MultiPoint.parseCoords(multiPointCoordsYX, crs: crs)
                .toText(crs: crs),
            multiPointYX,
          );
          expect(
            MultiLineString.parse(multiLineStringYX, crs: crs).toText(crs: crs),
            multiLineStringYX,
          );
          expect(
            MultiLineString.parseCoords(multiLineStringCoordsYX, crs: crs)
                .toText(crs: crs),
            multiLineStringYX,
          );
          expect(
            MultiPolygon.parse(multiPolygonYX, crs: crs).toText(crs: crs),
            multiPolygonYX,
          );
          expect(
            MultiPolygon.parseCoords(multiPolygonCoordsYX, crs: crs)
                .toText(crs: crs),
            multiPolygonYX,
          );
        }
      }
    });
  });

  group('Typed collections and features', () {
    const props = '"properties":{"foo":1,"bar":"baz"}';
    const point = '{"type":"Point","coordinates":[1.5,2.5]}';
    const pointYX = '{"type":"Point","coordinates":[2.5,1.5]}';
    const lineString =
        '{"type":"LineString","coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]}';
    const lineStringYX =
        '{"type":"LineString","coordinates":[[-1.1,-1.1],[-2.5,2.1],[-3.49,3.5]]}';

    const geomColl =
        '{"type":"GeometryCollection","geometries":[$point,$lineString]}';
    const geomCollYX =
        '{"type":"GeometryCollection","geometries":[$pointYX,$lineStringYX]}';
    const geomCollPoints =
        '{"type":"GeometryCollection","geometries":[$point,$point]}';
    const geomCollPointsYX =
        '{"type":"GeometryCollection","geometries":[$pointYX,$pointYX]}';

    const pointFeat = '{"type":"Feature","geometry":$point,$props}';
    const pointFeatYX = '{"type":"Feature","geometry":$pointYX,$props}';
    const lineStringFeat = '{"type":"Feature","geometry":$lineString,$props}';
    const lineStringFeatYX =
        '{"type":"Feature","geometry":$lineStringYX,$props}';

    const featColl =
        '{"type":"FeatureCollection","features":[$pointFeat,$lineStringFeat]}';
    const featCollYX =
        '{"type":"FeatureCollection","features":[$pointFeatYX,$lineStringFeatYX]}';
    const featCollYXEpsg4326 =
        '{"type":"FeatureCollection","crs":"http://www.opengis.net/def/crs/EPSG/0/4326","features":[$pointFeatYX,$lineStringFeatYX]}';

    const featCollPoints =
        '{"type":"FeatureCollection","features":[$pointFeat,$pointFeat]}';
    const featCollPointsYX =
        '{"type":"FeatureCollection","features":[$pointFeatYX,$pointFeatYX]}';
    const featCollPointsYXEpsg4326 =
        '{"type":"FeatureCollection","crs":"http://www.opengis.net/def/crs/EPSG/0/4326","features":[$pointFeatYX,$pointFeatYX]}';

    const epsg4326 = CoordRefSys.EPSG_4326;

    test('Simple geometries', () {
      expect(Point.parse(point).toText(), point);
      expect(LineString.parse(lineString).toText(), lineString);
    });

    test('Simple geometries (swapped)', () {
      expect(Point.parse(pointYX, crs: epsg4326).toText(), point);
      expect(
        LineString.parse(lineStringYX, crs: epsg4326).toText(),
        lineString,
      );

      expect(Point.parse(point).toText(crs: epsg4326), pointYX);
      expect(LineString.parse(lineString).toText(crs: epsg4326), lineStringYX);

      expect(
        Point.parse(pointYX, crs: epsg4326).toText(crs: epsg4326),
        pointYX,
      );
      expect(
        LineString.parse(lineStringYX, crs: epsg4326).toText(crs: epsg4326),
        lineStringYX,
      );
    });

    test('Geometry collection with non-typed geometry', () {
      expect(GeometryCollection.parse(geomColl).toText(), geomColl);
      expect(
        GeometryCollection.parse(geomCollPoints).toText(),
        geomCollPoints,
      );
    });

    test('Geometry collection with non-typed geometry (swapped)', () {
      expect(
        GeometryCollection.parse(geomCollYX, crs: epsg4326).toText(),
        geomColl,
      );
      expect(
        GeometryCollection.parse(geomCollPointsYX, crs: epsg4326).toText(),
        geomCollPoints,
      );

      expect(
        GeometryCollection.parse(geomColl).toText(crs: epsg4326),
        geomCollYX,
      );
      expect(
        GeometryCollection.parse(geomCollPoints).toText(crs: epsg4326),
        geomCollPointsYX,
      );

      expect(
        GeometryCollection.parse(geomCollYX, crs: epsg4326)
            .toText(crs: epsg4326),
        geomCollYX,
      );
      expect(
        GeometryCollection.parse(geomCollPointsYX, crs: epsg4326)
            .toText(crs: epsg4326),
        geomCollPointsYX,
      );
    });

    test('Geometry collection with typed geometry', () {
      expect(
        GeometryBuilder.parseCollection<Point>(geomCollPoints).toText(),
        geomCollPoints,
      );
      expect(
        GeometryCollection.parse<Point>(geomCollPoints).toText(),
        geomCollPoints,
      );
    });

    test('Feature with non-typed geometry', () {
      expect(Feature.parse(pointFeat).toText(), pointFeat);
      final feat = Feature.parse(lineStringFeat);
      expect(feat.toText(), lineStringFeat);
    });

    test('Feature with non-typed geometry (swapped)', () {
      expect(Feature.parse(pointFeatYX, crs: epsg4326).toText(), pointFeat);
      expect(
        Feature.parse(lineStringFeatYX, crs: epsg4326).toText(),
        lineStringFeat,
      );

      expect(Feature.parse(pointFeat).toText(crs: epsg4326), pointFeatYX);
      expect(
        Feature.parse(lineStringFeat).toText(crs: epsg4326),
        lineStringFeatYX,
      );

      expect(
        Feature.parse(pointFeatYX, crs: epsg4326).toText(crs: epsg4326),
        pointFeatYX,
      );
      expect(
        Feature.parse(lineStringFeatYX, crs: epsg4326).toText(crs: epsg4326),
        lineStringFeatYX,
      );
    });

    test('Feature with typed geometry', () {
      expect(Feature.parse<Point>(pointFeat).toText(), pointFeat);
      final feat = Feature.parse<LineString>(lineStringFeat);
      expect(feat.toText(), lineStringFeat);
    });

    test('Feature collection with non-typed geometry', () {
      expect(FeatureCollection.parse(featColl).toText(), featColl);
      final coll = FeatureCollection.parse(featCollPoints);
      expect(coll.toText(), featCollPoints);
    });

    test('Feature collection with non-typed geometry (swapped)', () {
      expect(
        FeatureCollection.parse(featCollYX, crs: epsg4326).toText(),
        featColl,
      );
      expect(
        FeatureCollection.parse(featCollPointsYX, crs: epsg4326).toText(),
        featCollPoints,
      );

      expect(
        FeatureCollection.parse(featColl).toText(crs: epsg4326),
        featCollYX,
      );
      expect(
        FeatureCollection.parse(featCollPoints).toText(crs: epsg4326),
        featCollPointsYX,
      );

      expect(
        FeatureCollection.parse(featCollYX, crs: epsg4326)
            .toText(crs: epsg4326),
        featCollYX,
      );
      expect(
        FeatureCollection.parse(featCollPointsYX, crs: epsg4326)
            .toText(crs: epsg4326),
        featCollPointsYX,
      );
    });

    test('Feature collection with non-typed geometry (swapped) with CRS', () {
      final f = GeoJSON.featureFormat(
        conf: const GeoJsonConf(printNonDefaultCrs: true),
      );

      expect(
        FeatureCollection.parse(featCollYX, crs: epsg4326).toText(format: f),
        featColl,
      );
      expect(
        FeatureCollection.parse(featCollPointsYX, crs: epsg4326)
            .toText(format: f),
        featCollPoints,
      );

      expect(
        FeatureCollection.parse(featColl).toText(format: f, crs: epsg4326),
        featCollYXEpsg4326,
      );
      expect(
        FeatureCollection.parse(featCollPoints)
            .toText(format: f, crs: epsg4326),
        featCollPointsYXEpsg4326,
      );

      expect(
        FeatureCollection.parse(featCollYX, crs: epsg4326)
            .toText(format: f, crs: epsg4326),
        featCollYXEpsg4326,
      );
      expect(
        FeatureCollection.parse(featCollPointsYX, crs: epsg4326)
            .toText(format: f, crs: epsg4326),
        featCollPointsYXEpsg4326,
      );
    });

    test('Feature collection with typed geometry', () {
      final coll = FeatureCollection.parse<Point>(featCollPoints);
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
      expect(Point.parse(geoJsonText).toText(), geoJsonText);
      break;
    case Geom.lineString:
      expect(LineString.parse(geoJsonText).toText(), geoJsonText);
      break;
    case Geom.polygon:
      expect(Polygon.parse(geoJsonText).toText(), geoJsonText);
      break;
    case Geom.multiPoint:
      expect(MultiPoint.parse(geoJsonText).toText(), geoJsonText);
      break;
    case Geom.multiLineString:
      expect(MultiLineString.parse(geoJsonText).toText(), geoJsonText);
      break;
    case Geom.multiPolygon:
      expect(MultiPolygon.parse(geoJsonText).toText(), geoJsonText);
      break;
    case Geom.geometryCollection:
      expect(GeometryCollection.parse(geoJsonText).toText(), geoJsonText);
      break;
  }
}

void _testDecodeGeometryAndEncodeToWKB(
  TextFormat<GeometryContent> textFormat,
  BinaryFormat<GeometryContent> binaryFormat,
  String geoJsonText,
) {
  // builder geometries from content decoded from GeoJSON text
  final geometries = GeometryBuilder.buildList(
    (builder) {
      // GeoJSON decoder from text to geometry content (writing to builder)
      final decoder = textFormat.decoder(builder);

      // decode
      decoder.decodeText(geoJsonText);
    },
  );

  // get the sample geometry as a model object from list just built
  expect(geometries.length, 1);
  final geometry = geometries.first;

  // now not testing actually GeoJSON here, but WKB...

  // get encoded bytes from geometry
  final bytes = geometry.toBytes(format: binaryFormat);

  // then decode those bytes back to geometry, get json text, that is compared
  switch (geometry.geomType) {
    case Geom.point:
      expect(Point.decode(bytes).toText(), geoJsonText);
      break;
    case Geom.lineString:
      expect(LineString.decode(bytes).toText(), geoJsonText);
      break;
    case Geom.polygon:
      expect(Polygon.decode(bytes).toText(), geoJsonText);
      break;
    case Geom.multiPoint:
      expect(MultiPoint.decode(bytes).toText(), geoJsonText);
      break;
    case Geom.multiLineString:
      expect(MultiLineString.decode(bytes).toText(), geoJsonText);
      break;
    case Geom.multiPolygon:
      expect(MultiPolygon.decode(bytes).toText(), geoJsonText);
      break;
    case Geom.geometryCollection:
      expect(GeometryCollection.decode(bytes).toText(), geoJsonText);
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
    expect(Feature.parse(geoJsonText).toText(), geoJsonText);
  } else if (object is FeatureCollection) {
    expect(FeatureCollection.parse(geoJsonText).toText(), geoJsonText);
  }
}
