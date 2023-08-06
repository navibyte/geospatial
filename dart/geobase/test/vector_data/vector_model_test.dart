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
import '../vector/wkt_samples.dart';

// see also '../vector/geojson_test.dart'

void main() {
  group('Test GeoJSON decoding to model objects and back to GeoJSON', () {
    test('Test geometry samples (GeoJSON)', () {
      for (final sample in geoJsonGeometries) {
        //print(sample);
        _testDecodeGeometryAndEncodeToText(GeoJSON.geometry, sample);
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

  group('Test WKT decoding to model objects and back to WKT', () {
    test('Test geometry samples (WKT', () {
      for (final sample in wktGeometries) {
        //print(sample);
        _testDecodeGeometryAndEncodeToText(WKT.geometry, sample);
      }
    });

    test('Test geometry samples (WKT -> WKB)', () {
      for (final sample in wktGeometries) {
        // filter out samples with bbox as WKB does not support
        if (!sample.contains('bbox')) {
          //print(sample);
          _testDecodeGeometryAndEncodeToWKB(
            WKT.geometry,
            WKB.geometry,
            sample,
          );
        }
      }
    });

    test('WKT multipoint special cases', () {
      const mp1 = 'MULTIPOINT(10.1 10.1,20.2 20.2,30.3 30.3)';
      const mp2 = 'MULTIPOINT((10.1 10.1),(20.2 20.2),(30.3 30.3))';

      expect(
        MultiPoint.parse(mp1, format: WKT.geometry)
            .toText(format: WKT.geometry),
        mp1,
      );
      expect(
        MultiPoint.parse(mp2, format: WKT.geometry)
            .toText(format: WKT.geometry),
        mp1,
      );
    });

    test('WKT example use cases', () {
      expect(
        Point.parse(
          'POINT ZM(10.123 20.25 -30.95 -1.999)',
          format: WKT.geometry,
        ).toText(format: WKT.geometry),
        'POINT ZM(10.123 20.25 -30.95 -1.999)',
      );
    });
  });

  group('Empty geometries', () {
    test('WKT empty geometry special cases', () {
      const wkt = WKT.geometry;
      const def = DefaultFormat.geometry;

      final emptyPoint = Point.parse('POINT EMPTY', format: wkt);
      expect(emptyPoint.isEmpty, true);
      expect(emptyPoint.toText(format: wkt), 'POINT EMPTY');
      expect(emptyPoint.toText(), '{"type":"Point","coordinates":[]}');
      expect(
        Point.parseCoords('').toText(format: def),
        emptyPoint.toText(format: def),
      );
      expect(
        Point.parse('{"type":"Point","coordinates":[]}').toText(format: wkt),
        emptyPoint.toText(format: wkt),
      );
      expect(Point.decode(emptyPoint.toBytes()).toText(), emptyPoint.toText());

      final emptyLineString = LineString.parse('LINESTRING EMPTY', format: wkt);
      expect(emptyLineString.isEmpty, true);
      expect(emptyLineString.toText(format: wkt), 'LINESTRING EMPTY');
      expect(
        LineString.parseCoords('').toText(format: def),
        emptyLineString.toText(format: def),
      );
      expect(
        emptyLineString.toText(),
        '{"type":"LineString","coordinates":[]}',
      );
      expect(
        LineString.parse('{"type":"LineString","coordinates":[]}')
            .toText(format: wkt),
        emptyLineString.toText(format: wkt),
      );
      expect(
        LineString.decode(emptyLineString.toBytes()).toText(),
        emptyLineString.toText(),
      );

      final emptyPolygon = Polygon.parse('POLYGON EMPTY', format: wkt);
      expect(emptyPolygon.isEmpty, true);
      expect(emptyPolygon.toText(format: wkt), 'POLYGON EMPTY');
      expect(emptyPolygon.toText(), '{"type":"Polygon","coordinates":[]}');
      expect(
        Polygon.parseCoords('').toText(format: def),
        emptyPolygon.toText(format: def),
      );
      expect(
        Polygon.parse('{"type":"Polygon","coordinates":[]}')
            .toText(format: wkt),
        emptyPolygon.toText(format: wkt),
      );
      expect(
        Polygon.decode(emptyPolygon.toBytes()).toText(),
        emptyPolygon.toText(),
      );

      final emptyMultiPoint = MultiPoint.parse('MULTIPOINT EMPTY', format: wkt);
      expect(emptyMultiPoint.isEmpty, true);
      expect(emptyMultiPoint.toText(format: wkt), 'MULTIPOINT EMPTY');
      expect(
        emptyMultiPoint.toText(),
        '{"type":"MultiPoint","coordinates":[]}',
      );
      expect(
        MultiPoint.parseCoords('').toText(format: def),
        emptyMultiPoint.toText(format: def),
      );
      expect(
        MultiPoint.parse('{"type":"MultiPoint","coordinates":[]}')
            .toText(format: wkt),
        emptyMultiPoint.toText(format: wkt),
      );
      expect(
        MultiPoint.decode(emptyMultiPoint.toBytes()).toText(),
        emptyMultiPoint.toText(),
      );

      final emptyMultiLineString =
          MultiLineString.parse('MULTILINESTRING EMPTY', format: wkt);
      expect(emptyMultiLineString.isEmpty, true);
      expect(emptyMultiLineString.toText(format: wkt), 'MULTILINESTRING EMPTY');
      expect(
        MultiLineString.parseCoords('').toText(format: def),
        emptyMultiLineString.toText(format: def),
      );
      expect(
        emptyMultiLineString.toText(),
        '{"type":"MultiLineString","coordinates":[]}',
      );
      expect(
        MultiLineString.parse('{"type":"MultiLineString","coordinates":[]}')
            .toText(format: wkt),
        emptyMultiLineString.toText(format: wkt),
      );
      expect(
        MultiLineString.decode(emptyMultiLineString.toBytes()).toText(),
        emptyMultiLineString.toText(),
      );

      final emptyMultiPolygon =
          MultiPolygon.parse('MULTIPOLYGON EMPTY', format: wkt);
      expect(emptyMultiPolygon.isEmpty, true);
      expect(emptyMultiPolygon.toText(format: wkt), 'MULTIPOLYGON EMPTY');
      expect(
        MultiPolygon.parseCoords('').toText(format: def),
        emptyMultiPolygon.toText(format: def),
      );
      expect(
        emptyMultiPolygon.toText(),
        '{"type":"MultiPolygon","coordinates":[]}',
      );
      expect(
        MultiPolygon.parse('{"type":"MultiPolygon","coordinates":[]}')
            .toText(format: wkt),
        emptyMultiPolygon.toText(format: wkt),
      );
      expect(
        MultiPolygon.decode(emptyMultiPolygon.toBytes()).toText(),
        emptyMultiPolygon.toText(),
      );

      final emptyGeomColl =
          GeometryCollection.parse('GEOMETRYCOLLECTION EMPTY', format: wkt);
      expect(emptyGeomColl.isEmpty, true);
      expect(emptyGeomColl.toText(format: wkt), 'GEOMETRYCOLLECTION EMPTY');
      expect(
        emptyGeomColl.toText(),
        '{"type":"GeometryCollection","geometries":[]}',
      );
      expect(
        GeometryCollection.parse(
          '{"type":"GeometryCollection","geometries":[]}',
        ).toText(format: wkt),
        emptyGeomColl.toText(format: wkt),
      );
      expect(
        GeometryCollection.decode(emptyGeomColl.toBytes()).toText(),
        emptyGeomColl.toText(),
      );
    });
  });

  group('Testing equals2D and equals3D in geometries', () {
    const e = 0.1 + 10 * doublePrecisionEpsilon;
    const t3d = Coords.xyz;

    test('Point', () {
      final xy = Point.build([23.1, 34.2]);
      final xyz = Point.build([23.1, 34.2, 45.3]);
      expect(xy.equals2D(xyz), true);
      expect(xy.equals3D(xyz), false);
      expect(xyz.equals2D(xyz), true);
      expect(xyz.equals3D(xyz), true);

      final xy1 = Point.build([23.1, 34.3]);
      final xy2 = Point.build([23.1, 34.4]);
      expect(xy.equals2D(xy1, toleranceHoriz: e), true);
      expect(xy.equals2D(xy2, toleranceHoriz: e), false);
      expect(xy.equals3D(xy1, toleranceHoriz: e, toleranceVert: e), false);
      expect(xy.equals3D(xy2, toleranceHoriz: e, toleranceVert: e), false);

      final xyz1 = Point.build([23.1, 34.3, 45.4]);
      final xyz2 = Point.build([23.1, 34.4, 45.5]);
      expect(xyz.equals2D(xyz1, toleranceHoriz: e), true);
      expect(xyz.equals2D(xyz2, toleranceHoriz: e), false);
      expect(xyz.equals3D(xyz1, toleranceHoriz: e, toleranceVert: e), true);
      expect(xyz.equals3D(xyz2, toleranceHoriz: e, toleranceVert: e), false);
    });

    test('LineString', () {
      final xy = LineString.build(const [23.1, 34.2, 1, 2]);
      final xyz =
          LineString.build(const [23.1, 34.2, 45.3, 1, 2, 3], type: t3d);
      expect(xy.equals2D(xyz), true);
      expect(xy.equals3D(xyz), false);
      expect(xyz.equals2D(xyz), true);
      expect(xyz.equals3D(xyz), true);

      final xy1 = LineString.build(const [23.1, 34.3, 1, 2]);
      final xy2 = LineString.build(const [23.1, 34.4, 1, 2]);
      expect(xy.equals2D(xy1, toleranceHoriz: e), true);
      expect(xy.equals2D(xy2, toleranceHoriz: e), false);
      expect(xy.equals3D(xy1, toleranceHoriz: e, toleranceVert: e), false);
      expect(xy.equals3D(xy2, toleranceHoriz: e, toleranceVert: e), false);

      final xyz1 =
          LineString.build(const [23.1, 34.3, 45.4, 1, 2, 3], type: t3d);
      final xyz2 =
          LineString.build(const [23.1, 34.4, 45.5, 1, 2, 3], type: t3d);
      expect(xyz.equals2D(xyz1, toleranceHoriz: e), true);
      expect(xyz.equals2D(xyz2, toleranceHoriz: e), false);
      expect(xyz.equals3D(xyz1, toleranceHoriz: e, toleranceVert: e), true);
      expect(xyz.equals3D(xyz2, toleranceHoriz: e, toleranceVert: e), false);
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

void _testDecodeGeometryAndEncodeToText(
  TextFormat<GeometryContent> format,
  String geometryAsText,
) {
  // builder geometries from content decoded from text [format]
  final geometries = GeometryBuilder.buildList(
    (builder) {
      // GeoJSON decoder from text to geometry content (writing to builder)
      final decoder = format.decoder(builder);

      // decode
      decoder.decodeText(geometryAsText);
    },
  );

  // get the sample geometry as a model object from list just built
  expect(geometries.length, 1);
  final geometry = geometries.first;

  // text [format] encoder from geometry content to text
  final encoder = format.encoder();

  // encode geometry object back to text [format]
  geometry.writeTo(encoder.writer);
  final geoJsonTextEncoded = encoder.toText();

  // test
  expect(geoJsonTextEncoded, geometryAsText);

  // try to create also using factory method and then write back
  const eps = 5 * doublePrecisionEpsilon;
  switch (geometry.geomType) {
    case Geom.point:
      final parsed = Point.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmpty,
      );
      break;
    case Geom.lineString:
      final parsed = LineString.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmpty,
      );
      break;
    case Geom.polygon:
      final parsed = Polygon.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmpty,
      );
      break;
    case Geom.multiPoint:
      final parsed = MultiPoint.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmpty,
      );
      break;
    case Geom.multiLineString:
      final parsed = MultiLineString.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmpty,
      );
      break;
    case Geom.multiPolygon:
      final parsed = MultiPolygon.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmpty,
      );
      break;
    case Geom.geometryCollection:
      final parsed = GeometryCollection.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      break;
  }
}

void _testDecodeGeometryAndEncodeToWKB(
  TextFormat<GeometryContent> textFormat,
  BinaryFormat<GeometryContent> binaryFormat,
  String geometryAsText,
) {
  // builder geometries from content decoded from [textFormat]
  final geometries = GeometryBuilder.buildList(
    (builder) {
      // [textFormat] decoder from text to geometry content
      // (writing to builder)
      final decoder = textFormat.decoder(builder);

      // decode
      decoder.decodeText(geometryAsText);
    },
  );

  // get the sample geometry as a model object from list just built
  expect(geometries.length, 1);
  final geometry = geometries.first;

  // now not testing actually [textFormat] here, but [binaryFormat]...

  // get encoded bytes from geometry
  final bytes = geometry.toBytes(format: binaryFormat);

  // then decode those bytes back to geometry, get text, that is compared
  const eps = 5 * doublePrecisionEpsilon;
  switch (geometry.geomType) {
    case Geom.point:
      final parsed = Point.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmpty,
      );
      break;
    case Geom.lineString:
      final parsed = LineString.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmpty,
      );
      break;
    case Geom.polygon:
      final parsed = Polygon.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmpty,
      );
      break;
    case Geom.multiPoint:
      final parsed = MultiPoint.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmpty,
      );
      break;
    case Geom.multiLineString:
      final parsed = MultiLineString.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmpty,
      );
      break;
    case Geom.multiPolygon:
      final parsed = MultiPolygon.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmpty,
      );
      break;
    case Geom.geometryCollection:
      final parsed = GeometryCollection.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(geometry.equals2D(parsed, toleranceHoriz: eps), !parsed.isEmpty);
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
