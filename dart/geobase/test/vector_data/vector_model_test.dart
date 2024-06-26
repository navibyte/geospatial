// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: cascade_invocations, lines_longer_than_80_chars

import 'package:geobase/common.dart';
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
      expect(emptyPoint.isEmptyByGeometry, true);
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
      expect(emptyLineString.isEmptyByGeometry, true);
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
      expect(emptyPolygon.isEmptyByGeometry, true);
      expect(emptyPolygon.toText(format: wkt), 'POLYGON EMPTY');
      expect(emptyPolygon.toText(), '{"type":"Polygon","coordinates":[]}');
      expect(
        Polygon.parseCoords(const []).toText(format: def),
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
      expect(emptyMultiPoint.isEmptyByGeometry, true);
      expect(emptyMultiPoint.toText(format: wkt), 'MULTIPOINT EMPTY');
      expect(
        emptyMultiPoint.toText(),
        '{"type":"MultiPoint","coordinates":[]}',
      );
      expect(
        MultiPoint.parseCoords(const []).toText(format: def),
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
      expect(emptyMultiLineString.isEmptyByGeometry, true);
      expect(emptyMultiLineString.toText(format: wkt), 'MULTILINESTRING EMPTY');
      expect(
        MultiLineString.parseCoords(const []).toText(format: def),
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
      expect(emptyMultiPolygon.isEmptyByGeometry, true);
      expect(emptyMultiPolygon.toText(format: wkt), 'MULTIPOLYGON EMPTY');
      expect(
        MultiPolygon.parseCoords(const []).toText(format: def),
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
      expect(emptyGeomColl.isEmptyByGeometry, true);
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

  group('Testing equalsCoords in geometries', () {
    test('Point', () {
      expect(
        Point.parseCoords('23.1,34.2')
            .equalsCoords(Point.parseCoords('23.1,34.2')),
        true,
      );
      expect(
        Point.parseCoords('23.1, 34.2, 45.3')
            .equalsCoords(Point.parseCoords('23.1, 34.2')),
        false,
      );
      expect(
        Point.parseCoords('23.1, 34.2, 45.3')
            .equalsCoords(Point.build([23.1, 34.2, 45.3])),
        true,
      );
    });

    test('LineString', () {
      const coords1 = '23.1, 34.2, 45.3, 1.0, 2.0, 3.0';
      const coords2 = '23.1, 34.2, 45.3, 1.0, 2.0, 3.0000003';
      expect(
        LineString(PositionSeries.parse(coords1))
            .equalsCoords(LineString(PositionSeries.parse(coords1))),
        true,
      );
      expect(
        LineString(PositionSeries.parse(coords1))
            .equalsCoords(LineString(PositionSeries.parse(coords2))),
        false,
      );
      expect(
        LineString(PositionSeries.parse(coords2, type: Coords.xyz))
            .equalsCoords(
          LineString(PositionSeries.parse(coords2, type: Coords.xyz)),
        ),
        true,
      );
      expect(
        LineString(PositionSeries.parse(coords2, type: Coords.xyz))
            .equalsCoords(
          LineString(PositionSeries.parse(coords2, type: Coords.xym)),
        ),
        false,
      );
    });
  });

  group('Testing equals2D and equals3D in geometries', () {
    const e = 0.1 + 10 * defaultEpsilon;
    const t3d = Coords.xyz;

    test('Point', () {
      final xy = Point.build([23.1, 34.2]);
      final xyz = Point.build([23.1, 34.2, 45.3]);
      expect(xy.equals2D(xyz), true);
      expect(xy.equals3D(xyz), false);
      expect(xyz.equals2D(xyz), true);
      expect(xyz.equals3D(xyz), true);

      final xy1 = Point.build(const Projected(x: 23.1, y: 34.3).values);
      const xy2 = Point(Projected(x: 23.1, y: 34.4));
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

      final xy1 = LineString(
        [
          const Projected(x: 23.1, y: 34.3),
          const Projected(x: 1, y: 2),
        ].series(),
      );
      final xy2 = LineString.from(const [
        Projected(x: 23.1, y: 34.4),
        Projected(x: 1, y: 2),
      ]);
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

  group('Testing equals2D and equals3D in features', () {
    const e = 0.1 + 10 * defaultEpsilon;
    const wkt = WKT.geometry;

    test('Feature', () {
      final xy = Feature(
        geometry: Polygon.parse(
          format: wkt,
          'POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10), '
          '(20 30, 35 35, 30 20, 20 30))',
        ),
      );
      final xyz = Feature(
        geometry: Polygon.parse(
          format: wkt,
          'POLYGON Z ((35 10 1, 45 45 2, 15 40 3, 10 20 4, 35 10 5), '
          '(20 30 6, 35 35 7, 30 20 8, 20 30 9))',
        ),
      );
      final fc = FeatureCollection([xy, xyz]);
      final fcz = FeatureCollection([xyz]);
      expect(xy.equals2D(xyz), true);
      expect(xy.equals3D(xyz), false);
      expect(xyz.equals2D(xyz), true);
      expect(xyz.equals3D(xyz), true);
      expect(fc.equalsCoords(fcz), false);
      expect(fc.equalsCoords(FeatureCollection([xy, xyz])), true);
      expect(fc.equals2D(fc), true);
      expect(fc.equals3D(fc), false);
      expect(fc.equals2D(fcz), false);
      expect(fc.equals3D(fcz), false);
      expect(fcz.equals2D(fcz), true);
      expect(fcz.equals3D(fcz), true);

      final xy1 = Feature(
        geometry: Polygon.parse(
          format: wkt,
          'POLYGON ((35.1 10, 45 45, 15 40, 10 20, 35 10), '
          '(20 30.1, 35 35, 30 20, 20 30))',
        ),
      );
      final xy2 = Feature(
        geometry: Polygon.parse(
          format: wkt,
          'POLYGON ((35.2 10, 45 45, 15 40, 10 20, 35 10), '
          '(20 30.2, 35 35, 30 20, 20 30))',
        ),
      );
      expect(xy.equals2D(xy1, toleranceHoriz: e), true);
      expect(xy.equals2D(xy2, toleranceHoriz: e), false);
      expect(xy.equals3D(xy1, toleranceHoriz: e, toleranceVert: e), false);
      expect(xy.equals3D(xy2, toleranceHoriz: e, toleranceVert: e), false);

      final xyz1 = Feature(
        geometry: Polygon.parse(
          format: wkt,
          'POLYGON Z ((35.1 10 1, 45 45 2, 15 40 3, 10 20 4, 35 10 5.1), '
          '(20 30.1 6, 35 35 7, 30 20 8, 20 30 9))',
        ),
      );
      final xyz2 = Feature(
        geometry: Polygon.parse(
          format: wkt,
          'POLYGON Z ((35.2 10 1, 45 45 2, 15 40 3, 10 20 4, 35 10 5.2), '
          '(20 30.2 6, 35 35 7, 30 20 8, 20 30 9))',
        ),
      );
      expect(xyz.equals2D(xyz1, toleranceHoriz: e), true);
      expect(xyz.equals2D(xyz2, toleranceHoriz: e), false);
      expect(xyz.equals3D(xyz1, toleranceHoriz: e, toleranceVert: e), true);
      expect(xyz.equals3D(xyz2, toleranceHoriz: e, toleranceVert: e), false);

      final fc1 = FeatureCollection([xy1, xyz1]);
      final fcz1 = FeatureCollection([xyz1]);
      final fc2 = FeatureCollection([xy2, xyz2]);
      final fcz2 = FeatureCollection([xyz2]);
      expect(fc.equals2D(fc1, toleranceHoriz: e), true);
      expect(fc.equals3D(fc1, toleranceHoriz: e, toleranceVert: e), false);
      expect(fcz.equals2D(fcz1, toleranceHoriz: e), true);
      expect(fcz.equals3D(fcz1, toleranceHoriz: e, toleranceVert: e), true);
      expect(fc.equals2D(fc2, toleranceHoriz: e), false);
      expect(fc.equals3D(fc2, toleranceHoriz: e, toleranceVert: e), false);
      expect(fcz.equals2D(fcz2, toleranceHoriz: e), false);
      expect(fcz.equals3D(fcz2, toleranceHoriz: e, toleranceVert: e), false);
    });
  });

  group('Parsing geometries', () {
    const pointCoords = '1.5,2.5';
    const pointCoordsYX = '2.5,1.5';
    const point = '{"type":"Point","coordinates":[$pointCoords]}';
    const pointYX = '{"type":"Point","coordinates":[$pointCoordsYX]}';
    const lineStringCoords = '[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]';
    const lineStringCoordsYX = '[-1.1,-1.1],[-2.5,2.1],[-3.49,3.5]';
    const lineStringCoordsFlat = '-1.1,-1.1,2.1,-2.5,3.5,-3.49';
    const lineStringCoordsYXFlat = '-1.1,-1.1,-2.5,2.1,-3.49,3.5';
    const lineString =
        '{"type":"LineString","coordinates":[$lineStringCoords]}';
    const lineStringYX =
        '{"type":"LineString","coordinates":[$lineStringCoordsYX]}';
    const polygonCoords =
        '[[10.1,10.1],[5,9],[12,4],[10.1,10.1]],[[11.1,11.1],[6,9.9],[13,4.9],[11.1,11.1]]';
    const polygonCoordsYX =
        '[[10.1,10.1],[9,5],[4,12],[10.1,10.1]],[[11.1,11.1],[9.9,6],[4.9,13],[11.1,11.1]]';
    const polygonCoordsFlat = [
      '10.1,10.1,5,9,12,4,10.1,10.1',
      '11.1,11.1,6,9.9,13,4.9,11.1,11.1',
    ];
    const polygonCoordsYXFlat = [
      '10.1,10.1,9,5,4,12,10.1,10.1',
      '11.1,11.1,9.9,6,4.9,13.0,11.1,11.1',
    ];
    const polygon = '{"type":"Polygon","coordinates":[$polygonCoords]}';
    const polygonYX = '{"type":"Polygon","coordinates":[$polygonCoordsYX]}';
    const multiPointCoords =
        '[-1.1,-1.1,-1.1,-1.1],[2.1,-2.5,2.3,0.1],[3.5,-3.49,11.3,0.23]';
    const multiPointCoordsYX =
        '[-1.1,-1.1,-1.1,-1.1],[-2.5,2.1,2.3,0.1],[-3.49,3.5,11.3,0.23]';
    const multiPointCoordsFlat = [
      '-1.1,-1.1,-1.1,-1.1',
      '2.1,-2.5,2.3,0.1',
      '3.5,-3.49,11.3,0.23',
    ];
    const multiPointCoordsYXFlat = [
      '-1.1,-1.1,-1.1,-1.1',
      '-2.5,2.1,2.3,0.1',
      '-3.49,3.5,11.3,0.23',
    ];
    const multiPoint =
        '{"type":"MultiPoint","coordinates":[$multiPointCoords]}';
    const multiPointYX =
        '{"type":"MultiPoint","coordinates":[$multiPointCoordsYX]}';
    const multiLineStringCoords =
        '[[10.1,10.1],[5,9],[12,4],[10.1,10.1]],[[11.1,11.1],[6,9.9],[13,4.9],[11.1,11.1]]';
    const multiLineStringCoordsYX =
        '[[10.1,10.1],[9,5],[4,12],[10.1,10.1]],[[11.1,11.1],[9.9,6],[4.9,13],[11.1,11.1]]';
    const multiLineStringCoordsFlat = [
      '10.1,10.1,5,9,12,4,10.1,10.1',
      '11.1,11.1,6,9.9,13,4.9,11.1,11.1',
    ];
    const multiLineStringCoordsYXFlat = [
      '10.1,10.1,9,5,4,12,10.1,10.1',
      '11.1,11.1,9.9,6,4.9,13,11.1,11.1',
    ];
    const multiLineString =
        '{"type":"MultiLineString","coordinates":[$multiLineStringCoords]}';
    const multiLineStringYX =
        '{"type":"MultiLineString","coordinates":[$multiLineStringCoordsYX]}';
    const multiPolygonCoords =
        '[[[10.1,10.1],[5,9],[12,4],[10.1,10.1]],[[11.1,11.1],[6,9.9],[13,4.9],[11.1,11.1]]]';
    const multiPolygonCoordsYX =
        '[[[10.1,10.1],[9,5],[4,12],[10.1,10.1]],[[11.1,11.1],[9.9,6],[4.9,13],[11.1,11.1]]]';
    const multiPolygonCoordsFlat = [
      [
        '10.1,10.1,5,9,12,4,10.1,10.1',
        '11.1,11.1,6,9.9,13,4.9,11.1,11.1',
      ]
    ];
    const multiPolygonCoordsYXFlat = [
      [
        '10.1,10.1,9,5,4,12,10.1,10.1',
        '11.1,11.1,9.9,6,4.9,13,11.1,11.1',
      ]
    ];
    const multiPolygon =
        '{"type":"MultiPolygon","coordinates":[$multiPolygonCoords]}';
    const multiPolygonYX =
        '{"type":"MultiPolygon","coordinates":[$multiPolygonCoordsYX]}';

    test('Simple geometries', () {
      expect(Point.parse(point).toText(), point);
      expect(Point.parseCoords(pointCoords).toText(), point);
      expect(LineString.parse(lineString).toText(), lineString);
      expect(LineString.parseCoords(lineStringCoordsFlat).toText(), lineString);
      expect(Polygon.parse(polygon).toText(), polygon);
      expect(Polygon.parseCoords(polygonCoordsFlat).toText(), polygon);

      final mpo1 = MultiPoint.parse(multiPoint);
      expect(mpo1.toText(), multiPoint);
      expect(
        MultiPoint.parseCoords(
          multiPointCoordsFlat,
          type: Coords.xyzm,
        ).toText(),
        multiPoint,
      );
      final mpo2 = MultiPoint.from([
        Projected.parse('-1.1,-1.1,-1.1,-1.1'),
        Projected.parse('2.1,-2.5,2.3,0.1'),
        Projected.parse('3.5,-3.49,11.3,0.23'),
      ]);
      expect(mpo1.toText(), mpo2.toText());

      expect(MultiLineString.parse(multiLineString).toText(), multiLineString);
      expect(
        MultiLineString.parseCoords(multiLineStringCoordsFlat).toText(),
        multiLineString,
      );
      expect(MultiPolygon.parse(multiPolygon).toText(), multiPolygon);
      expect(
        MultiPolygon.parseCoords(multiPolygonCoordsFlat).toText(),
        multiPolygon,
      );
    });

    test('Simple geometries as populated', () {
      final po = Point.parse(point);
      final pob = po.populated();
      expect(pob.toText(), point);
      expect(pob.bounds.toText(), '1.5,2.5,1.5,2.5');
      expect(po.calculateBounds().toText(), '1.5,2.5,1.5,2.5');

      final ls = LineString.parse(lineString);
      final lsb = ls.populated();
      expect(lsb.bounds?.toText(), '-1.1,-3.49,3.5,-1.1');
      expect(ls.calculateBounds()?.toText(), '-1.1,-3.49,3.5,-1.1');

      final pg = Polygon.parse(polygon);
      final pgb = pg.populated();
      expect(pgb.bounds?.toText(), '5,4,12,10.1');
      expect(pg.calculateBounds()?.toText(), '5,4,12,10.1');

      final mpo = MultiPoint.parse(multiPoint);
      final mpob = mpo.populated();
      expect(mpob.bounds?.toText(), '-1.1,-3.49,-1.1,-1.1,3.5,-1.1,11.3,0.23');
      expect(
        mpo.calculateBounds()?.toText(),
        '-1.1,-3.49,-1.1,-1.1,3.5,-1.1,11.3,0.23',
      );
      final mpo2 = MultiPoint.fromGeometries([po, pob], bounds: pob.bounds);
      final mpob2 = mpo2.populated();
      expect(mpo2.bounds?.toText(), '1.5,2.5,1.5,2.5');
      expect(mpob2.bounds?.toText(), '1.5,2.5,1.5,2.5');

      final mls = MultiLineString.parse(multiLineString);
      final mlsb = mls.populated();
      expect(mlsb.bounds?.toText(), '5,4,13,11.1');
      expect(mls.calculateBounds()?.toText(), '5,4,13,11.1');
      final mls2 =
          MultiLineString.fromGeometries([ls, lsb], bounds: lsb.bounds);
      final mlsb2 = mls2.unpopulated().populated();
      expect(mls2.bounds?.toText(), '-1.1,-3.49,3.5,-1.1');
      expect(mlsb2.bounds?.toText(), '-1.1,-3.49,3.5,-1.1');

      final mpg = MultiPolygon.parse(multiPolygon);
      final mpgb = mpg.populated();
      expect(mpgb.bounds?.toText(), '5,4,12,10.1');
      expect(mpg.calculateBounds()?.toText(), '5,4,12,10.1');
      final mpg2 = MultiPolygon.fromGeometries([pg, pgb], bounds: pgb.bounds);
      final mpgb2 = mpg.unpopulated().populated();
      expect(mpg2.bounds?.toText(), '5,4,12,10.1');
      expect(mpgb2.bounds?.toText(), '5,4,12,10.1');
    });

    test('Simple geometries from positions', () {
      expect(const Point(Projected(x: 1.5, y: 2.5)).toText(), point);
      expect(
        LineString.from(const [
          Projected(x: -1.1, y: -1.1),
          Projected(x: 2.1, y: -2.5),
          Projected(x: 3.5, y: -3.49),
        ]).toText(),
        lineString,
      );
      expect(
        Polygon.from(const [
          [
            Projected(x: 10.1, y: 10.1),
            Projected(x: 5.0, y: 9.0),
            Projected(x: 12.0, y: 4.0),
            Projected(x: 10.1, y: 10.1),
          ],
          [
            Projected(x: 11.1, y: 11.1),
            Projected(x: 6.0, y: 9.9),
            Projected(x: 13.0, y: 4.9),
            Projected(x: 11.1, y: 11.1),
          ],
        ]).toText(),
        polygon,
      );
      expect(
        MultiPoint.from(const [
          Projected(x: -1.1, y: -1.1, z: -1.1, m: -1.1),
          Projected(x: 2.1, y: -2.5, z: 2.3, m: 0.1),
          Projected(x: 3.5, y: -3.49, z: 11.3, m: 0.23),
        ]).toText(),
        multiPoint,
      );
      expect(
        MultiLineString.from(const [
          [
            Projected(x: 10.1, y: 10.1),
            Projected(x: 5.0, y: 9.0),
            Projected(x: 12.0, y: 4.0),
            Projected(x: 10.1, y: 10.1),
          ],
          [
            Projected(x: 11.1, y: 11.1),
            Projected(x: 6.0, y: 9.9),
            Projected(x: 13.0, y: 4.9),
            Projected(x: 11.1, y: 11.1),
          ],
        ]).toText(),
        multiLineString,
      );
      expect(
        MultiPolygon.from(const [
          [
            [
              Projected(x: 10.1, y: 10.1),
              Projected(x: 5.0, y: 9.0),
              Projected(x: 12.0, y: 4.0),
              Projected(x: 10.1, y: 10.1),
            ],
            [
              Projected(x: 11.1, y: 11.1),
              Projected(x: 6.0, y: 9.9),
              Projected(x: 13.0, y: 4.9),
              Projected(x: 11.1, y: 11.1),
            ],
          ]
        ]).toText(),
        multiPolygon,
      );
    });

    test('Simple geometries with crs geo representation logic', () {
      final geoJsonAuth = GeoJSON.geometryFormat();
      final geoJsonLonLatAlways = GeoJSON.geometryFormat(
        conf: const GeoJsonConf(crsLogic: GeoRepresentation.geoJsonStrict),
      );
      const crsLonLatOrder = CoordRefSys.CRS84;
      const crsLatLonOrder = CoordRefSys.EPSG_4326;

      expect(
        Point.parse(point, format: geoJsonAuth, crs: crsLonLatOrder)
            .toText(format: geoJsonAuth, crs: crsLonLatOrder),
        point,
      );
      expect(
        Point.parse(pointYX, format: geoJsonAuth, crs: crsLatLonOrder)
            .toText(format: geoJsonAuth, crs: crsLatLonOrder),
        pointYX,
      );

      expect(
        Point.parse(point, format: geoJsonLonLatAlways, crs: crsLonLatOrder)
            .toText(format: geoJsonLonLatAlways, crs: crsLonLatOrder),
        point,
      );
      expect(
        Point.parse(point, format: geoJsonLonLatAlways, crs: crsLatLonOrder)
            .toText(format: geoJsonLonLatAlways, crs: crsLatLonOrder),
        point,
      );
      expect(
        Point.parse(pointYX, format: geoJsonAuth, crs: crsLatLonOrder)
            .toText(format: geoJsonLonLatAlways, crs: crsLatLonOrder),
        point,
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
        final swapXY = crs.swapXY();
        final order = crsData[1] as AxisOrder;
        if (order == AxisOrder.xy) {
          expect(Point.parse(point, crs: crs).toText(), point);
          expect(
            Point.parseCoords(pointCoords, swapXY: swapXY).toText(),
            point,
          );
          expect(LineString.parse(lineString, crs: crs).toText(), lineString);
          expect(
            LineString.parseCoords(lineStringCoordsFlat, swapXY: swapXY)
                .toText(),
            lineString,
          );
          expect(Polygon.parse(polygon, crs: crs).toText(), polygon);
          expect(
            Polygon.parseCoords(polygonCoordsFlat, swapXY: swapXY).toText(),
            polygon,
          );
          expect(MultiPoint.parse(multiPoint, crs: crs).toText(), multiPoint);
          expect(
            MultiPoint.parseCoords(
              multiPointCoordsFlat,
              type: Coords.xyzm,
              swapXY: swapXY,
            ).toText(),
            multiPoint,
          );
          expect(
            MultiLineString.parse(multiLineString, crs: crs).toText(),
            multiLineString,
          );
          expect(
            MultiLineString.parseCoords(
              multiLineStringCoordsFlat,
              swapXY: swapXY,
            ).toText(),
            multiLineString,
          );
          expect(
            MultiPolygon.parse(multiPolygon, crs: crs).toText(),
            multiPolygon,
          );
          expect(
            MultiPolygon.parseCoords(
              multiPolygonCoordsFlat,
              swapXY: swapXY,
            ).toText(),
            multiPolygon,
          );
        } else if (order == AxisOrder.yx) {
          // toText without CRS (so default xy order)
          expect(Point.parse(pointYX, crs: crs).toText(), point);
          expect(
            Point.parseCoords(pointCoordsYX, swapXY: swapXY).toText(),
            point,
          );
          expect(LineString.parse(lineStringYX, crs: crs).toText(), lineString);
          expect(
            LineString.parseCoords(lineStringCoordsYXFlat, swapXY: swapXY)
                .toText(),
            lineString,
          );
          expect(Polygon.parse(polygonYX, crs: crs).toText(), polygon);
          expect(
            Polygon.parseCoords(polygonCoordsYXFlat, swapXY: swapXY).toText(),
            polygon,
          );
          expect(MultiPoint.parse(multiPointYX, crs: crs).toText(), multiPoint);
          expect(
            MultiPoint.parseCoords(
              multiPointCoordsYXFlat,
              swapXY: swapXY,
              type: Coords.xyzm,
            ).toText(),
            multiPoint,
          );
          expect(
            MultiLineString.parse(multiLineStringYX, crs: crs).toText(),
            multiLineString,
          );
          expect(
            MultiLineString.parseCoords(
              multiLineStringCoordsYXFlat,
              swapXY: swapXY,
            ).toText(),
            multiLineString,
          );
          expect(
            MultiPolygon.parse(multiPolygonYX, crs: crs).toText(),
            multiPolygon,
          );
          expect(
            MultiPolygon.parseCoords(
              multiPolygonCoordsYXFlat,
              swapXY: swapXY,
            ).toText(),
            multiPolygon,
          );

          // toText with CRS (so yx order and swapping should occur)
          expect(Point.parse(pointYX, crs: crs).toText(crs: crs), pointYX);
          expect(
            Point.parseCoords(pointCoordsYX, swapXY: swapXY).toText(crs: crs),
            pointYX,
          );
          expect(
            LineString.parse(lineStringYX, crs: crs).toText(crs: crs),
            lineStringYX,
          );
          expect(
            LineString.parseCoords(lineStringCoordsYXFlat, swapXY: swapXY)
                .toText(crs: crs),
            lineStringYX,
          );
          expect(
            Polygon.parse(polygonYX, crs: crs).toText(crs: crs),
            polygonYX,
          );
          expect(
            Polygon.parseCoords(polygonCoordsYXFlat, swapXY: swapXY)
                .toText(crs: crs),
            polygonYX,
          );
          expect(
            MultiPoint.parse(multiPointYX, crs: crs).toText(crs: crs),
            multiPointYX,
          );
          expect(
            MultiPoint.parseCoords(
              multiPointCoordsYXFlat,
              swapXY: swapXY,
              type: Coords.xyzm,
            ).toText(crs: crs),
            multiPointYX,
          );
          expect(
            MultiLineString.parse(multiLineStringYX, crs: crs).toText(crs: crs),
            multiLineStringYX,
          );
          expect(
            MultiLineString.parseCoords(
              multiLineStringCoordsYXFlat,
              swapXY: swapXY,
            ).toText(crs: crs),
            multiLineStringYX,
          );
          expect(
            MultiPolygon.parse(multiPolygonYX, crs: crs).toText(crs: crs),
            multiPolygonYX,
          );
          expect(
            MultiPolygon.parseCoords(
              multiPolygonCoordsYXFlat,
              swapXY: swapXY,
            ).toText(crs: crs),
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

    test('Geometry collection with non-typed geometry (mapped)', () {
      expect(
        GeometryCollection.parse(geomCollPoints).map((g) => g).toText(),
        geomCollPoints,
      );
      expect(
        GeometryCollection.parse<Point>(geomCollPoints)
            .map((g) => Point(g.position.copyWith(x: 0.0)))
            .toText(),
        '{"type":"GeometryCollection","geometries":[{"type":"Point","coordinates":[0,2.5]},{"type":"Point","coordinates":[0,2.5]}]}',
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

    test('Feature with non-typed geometry (copyWith)', () {
      final po = Feature.parse(pointFeat);
      expect(
        po.copyWith(id: 'foo').toText(),
        '{"type":"Feature","id":"foo","geometry":{"type":"Point","coordinates":[1.5,2.5]},"properties":{"foo":1,"bar":"baz"}}',
      );
      expect(
        po.copyWith(
          properties: {
            'a': 1,
            'b': [1, 2],
          },
        ).toText(),
        '{"type":"Feature","geometry":{"type":"Point","coordinates":[1.5,2.5]},"properties":{"a":1,"b":[1,2]}}',
      );
      expect(
        po
            .copyWith(
              geometry: const Point(Geographic(lat: 10.0, lon: 20.0)),
            )
            .toText(),
        '{"type":"Feature","geometry":{"type":"Point","coordinates":[20,10]},"properties":{"foo":1,"bar":"baz"}}',
      );
      expect(
        po.copyWith(custom: {'a': 1}).toText(),
        '{"type":"Feature","geometry":{"type":"Point","coordinates":[1.5,2.5]},"properties":{"foo":1,"bar":"baz"},"a":1}',
      );
    });

    test('Feature with non-typed geometry (populated)', () {
      final pof = Feature.parse(pointFeat);
      final pofb = pof.populated();
      expect(pofb.bounds?.toText(), '1.5,2.5,1.5,2.5');
      expect(pof.calculateBounds()?.toText(), '1.5,2.5,1.5,2.5');

      final lsf = Feature.parse(lineStringFeat);
      final lsfb = lsf.populated();
      expect(lsfb.bounds?.toText(), '-1.1,-3.49,3.5,-1.1');
      expect(lsf.calculateBounds()?.toText(), '-1.1,-3.49,3.5,-1.1');
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

    test('Feature collection with non-typed geometry (copyWith and map)', () {
      final fc = FeatureCollection.parse(featColl);
      expect(
        fc.copyWith(
          custom: {
            'a': 1,
            'b': [2, 3],
          },
        ).toText(),
        '${featColl.substring(0, featColl.length - 1)},"a":1,"b":[2,3]}',
      );
      expect(fc.map((f) => f).toText(), featColl);
      expect(
        fc.map((f) => f.copyWith(properties: {'m': true})).toText(),
        '{"type":"FeatureCollection","features":[{"type":"Feature","geometry":$point,"properties":{"m":true}},{"type":"Feature","geometry":$lineString,"properties":{"m":true}}]}',
      );
    });

    test('Feature collection with non-typed geometry (populated)', () {
      final fc = FeatureCollection.parse(featColl);
      final fcb = fc.populated();
      expect(fcb.bounds?.toText(), '-1.1,-3.49,3.5,2.5');
      expect(fcb.features[0].bounds, isNull);
      expect(fcb.features[1].bounds, isNull);
      expect(fcb.features[0].geometry?.bounds?.toText(), '1.5,2.5,1.5,2.5');
      expect(fcb.features[1].geometry?.bounds, isNull);
      expect(fcb.calculateBounds()?.toText(), '-1.1,-3.49,3.5,2.5');
      final fcb1 = fc.populated(traverse: 1);
      expect(fcb1.bounds?.toText(), '-1.1,-3.49,3.5,2.5');
      expect(fcb1.features[0].bounds?.toText(), '1.5,2.5,1.5,2.5');
      expect(fcb1.features[1].bounds?.toText(), '-1.1,-3.49,3.5,-1.1');
      expect(fcb1.features[0].geometry?.bounds?.toText(), '1.5,2.5,1.5,2.5');
      expect(fcb1.features[1].geometry?.bounds, isNull);
      final fcb2 = fc.populated(traverse: 2);
      expect(fcb2.bounds?.toText(), '-1.1,-3.49,3.5,2.5');
      expect(fcb2.features[0].bounds?.toText(), '1.5,2.5,1.5,2.5');
      expect(fcb2.features[1].bounds?.toText(), '-1.1,-3.49,3.5,-1.1');
      expect(fcb2.features[0].geometry?.bounds?.toText(), '1.5,2.5,1.5,2.5');
      expect(
        fcb2.features[1].geometry?.bounds?.toText(),
        '-1.1,-3.49,3.5,-1.1',
      );

      final fcpo = FeatureCollection.parse(featCollPoints);
      final fcpob = fcpo.populated();
      expect(fcpob.bounds?.toText(), '1.5,2.5,1.5,2.5');
      expect(fcpo.calculateBounds()?.toText(), '1.5,2.5,1.5,2.5');
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

  group('Calculations', () {
    final rectanglePositions = [
      [1.0, 1.0, 0.0].xyz,
      [2.0, 1.0, 0.0].xyz,
      [2.0, 2.0, 0.0].xyz,
      [2.0, 2.0, 1.0].xyz,
      [1.0, 2.0, 1.0].xyz,
      [1.0, 2.0, 0.0].xyz,
      [1.0, 1.0, 0.0].xyz,
    ];
    final rectangle = rectanglePositions.series();

    test('Length2D', () {
      expect(Point(rectangle[0]).length2D(), 0.0);
      expect(LineString(rectangle).length2D(), 4.0);
      expect(Polygon([rectangle]).length2D(), 4.0);
      expect(MultiPoint(rectanglePositions).length2D(), 0.0);
      expect(MultiLineString([rectangle, rectangle]).length2D(), 8.0);
      expect(
        MultiPolygon([
          [rectangle],
          [rectangle],
        ]).length2D(),
        8.0,
      );
      expect(
        GeometryCollection([
          LineString(rectangle),
          MultiLineString([rectangle, rectangle]),
        ]).length2D(),
        12.0,
      );
    });

    test('Length3D', () {
      expect(Point(rectangle[0]).length3D(), 0.0);
      expect(LineString(rectangle).length3D(), 6.0);
      expect(Polygon([rectangle]).length3D(), 6.0);
      expect(MultiPoint(rectanglePositions).length3D(), 0.0);
      expect(MultiLineString([rectangle, rectangle]).length3D(), 12.0);
      expect(
        MultiPolygon([
          [rectangle],
          [rectangle],
        ]).length3D(),
        12.0,
      );
      expect(
        GeometryCollection([
          LineString(rectangle),
          MultiLineString([rectangle, rectangle]),
        ]).length3D(),
        18.0,
      );
    });

    test('Area2D', () {
      final holePositions = [
        [1.25, 1.25].xy,
        [1.75, 1.25].xy,
        [1.75, 1.75].xy,
        [1.25, 1.75].xy,
        [1.25, 1.25].xy,
      ];
      final hole = holePositions.reversed.series();

      expect(Point(rectangle[0]).area2D(), 0.0);
      expect(LineString(rectangle).area2D(), 0.0);
      expect(Polygon([rectangle]).area2D(), 1.0);
      expect(Polygon([rectangle, hole]).area2D(), 0.75);
      expect(MultiPoint(rectanglePositions).area2D(), 0.0);
      expect(MultiLineString([rectangle, rectangle]).area2D(), 0.0);
      expect(
        MultiPolygon([
          [rectangle],
          [rectangle, hole],
        ]).area2D(),
        1.75,
      );
      expect(
        GeometryCollection([
          Polygon([rectangle]),
          Polygon([rectangle, hole]),
          LineString(rectangle),
          MultiLineString([rectangle, rectangle]),
        ]).area2D(),
        1.75,
      );
    });

    test('Centroid2D for shape', () {
      final positions = [
        [1.0, 0.0].xy,
        [1.0, 1.0].xy,
        [3.0, 0.0].xy,
        [3.0, 1.0].xy,
        [2.0, 2.0].xy,
        [1.0, 1.0].xy,
        [1.0, 2.0].xy,
        [2.0, 3.0].xy,
        [1.0, 3.0].xy,
        [1.0, 4.0].xy,
        [2.0, 5.0].xy,
        [4.0, 5.0].xy,
        [4.0, 2.0].xy,
        [3.0, 3.0].xy,
        [3.0, 2.0].xy,
        [4.0, 1.0].xy,
        [5.0, 1.0].xy,
        [5.0, 6.0].xy,
        [1.0, 6.0].xy,
        [1.0, 5.0].xy,
        [0.0, 4.0].xy,
        [0.0, 1.0].xy,
        [1.0, 0.0].xy,
      ];
      final shape = positions.series();

      final point = Point(positions[3]);
      expect(point.centroid2D()!.toText(decimals: 3), '3,1');
      expect(point.boundsAligned2D()!.toText(decimals: 3), '3,1');
      expect(point.dimensionality2D(), Dimensionality.punctual);

      final multiPoint = MultiPoint(positions);
      expect(multiPoint.centroid2D()!.toText(decimals: 3), '2.130,2.522');
      expect(multiPoint.boundsAligned2D()!.toText(decimals: 3), '2.500,3');
      expect(
        multiPoint
            .boundsAligned2D(align: Aligned.northCenter)!
            .toText(decimals: 3),
        '2.500,6',
      );
      expect(
        multiPoint
            .boundsAligned2D(align: Aligned.southWest)!
            .toText(decimals: 3),
        '0,0',
      );
      expect(multiPoint.dimensionality2D(), Dimensionality.punctual);

      final lineString = LineString(shape);
      expect(lineString.centroid2D()!.toText(decimals: 3), '2.508,2.996');
      expect(lineString.boundsAligned2D()!.toText(decimals: 3), '2.500,3');
      expect(lineString.dimensionality2D(), Dimensionality.linear);
      final lineString2 = LineString.build(const [2.0, 5.0, 2.0, 5.0]);
      expect(lineString2.centroid2D()!.toText(decimals: 3), '2,5');
      expect(lineString2.boundsAligned2D()!.toText(decimals: 3), '2,5');
      expect(lineString2.dimensionality2D(), Dimensionality.punctual);

      final multiLineString1 = MultiLineString([shape]);
      expect(multiLineString1.centroid2D()!.toText(decimals: 3), '2.508,2.996');
      expect(
        multiLineString1.boundsAligned2D()!.toText(decimals: 3),
        '2.500,3',
      );
      expect(multiLineString1.dimensionality2D(), Dimensionality.linear);

      final polygon = Polygon([shape]);
      final polygonResults = [
        polygon.centroid2D(),
        polygon.centroid2D(scheme: Projected.scheme),
        polygon.centroid2D(scheme: Geographic.scheme),
      ];
      expect(polygonResults[0] is Position, true);
      expect(polygonResults[1] is Projected, true);
      expect(polygonResults[2] is Geographic, true);
      for (final res in polygonResults) {
        expect(res!.toText(decimals: 3), '2.583,3.229');
      }
      expect(polygon.boundsAligned2D()!.toText(decimals: 3), '2.500,3');
      expect(polygon.dimensionality2D(), Dimensionality.areal);

      final multiPolygon1 = MultiPolygon([
        [shape],
      ]);
      expect(multiPolygon1.centroid2D()!.toText(decimals: 3), '2.583,3.229');
      expect(multiPolygon1.boundsAligned2D()!.toText(decimals: 3), '2.500,3');
      expect(multiPolygon1.dimensionality2D(), Dimensionality.areal);

      final geomColl1 = GeometryCollection([
        Polygon([shape]),
      ]);
      expect(geomColl1.centroid2D()!.toText(decimals: 3), '2.583,3.229');
      expect(geomColl1.boundsAligned2D()!.toText(decimals: 3), '2.500,3');
      expect(geomColl1.dimensionality2D(), Dimensionality.areal);
      final geomColl2 = GeometryCollection([
        Polygon([shape]),
        LineString(shape),
        MultiPoint(positions),
      ]);
      expect(geomColl2.centroid2D()!.toText(decimals: 3), '2.583,3.229');
      expect(geomColl2.dimensionality2D(), Dimensionality.areal);
      final geomColl3 = GeometryCollection([
        LineString(shape),
        MultiPoint(positions),
      ]);
      expect(geomColl3.centroid2D()!.toText(decimals: 3), '2.508,2.996');
      expect(geomColl3.dimensionality2D(), Dimensionality.linear);
      final geomColl4 = GeometryCollection([
        MultiPoint(positions),
      ]);
      expect(geomColl4.centroid2D()!.toText(decimals: 3), '2.130,2.522');
      expect(geomColl4.dimensionality2D(), Dimensionality.punctual);
    });

    test('Centroid2D for polygon with hole case 1', () {
      final exteriorCCW = [
        [0.0, 0.0].xy,
        [3.0, 0.0].xy,
        [3.0, 6.0].xy,
        [0.0, 6.0].xy,
        [0.0, 0.0].xy,
      ];
      final holeCW = [
        [1.0, 4.0].xy,
        [1.0, 5.0].xy,
        [2.0, 5.0].xy,
        [2.0, 4.0].xy,
        [1.0, 4.0].xy,
      ];
      final exterior = exteriorCCW.series();
      final hole = holeCW.series();

      // basic cases
      final pol = Polygon([exterior]);
      expect(
        pol.centroid2D()!.toText(decimals: 3, compactNums: false),
        '1.500,3.000',
      );
      final hol = Polygon([hole]);
      expect(
        hol.centroid2D()!.toText(decimals: 3, compactNums: false),
        '1.500,4.500',
      );
      final polHol = Polygon([exterior, hole]);
      expect(
        polHol.centroid2D()!.toText(decimals: 3, compactNums: false),
        '1.500,2.912',
      );

      // special cases

      // polygon with hole same size as exterior (not actually an area, but
      // algorithm gets then centroid for exterior)
      final polHolSP1 = Polygon([exterior, exterior]);
      expect(
        polHolSP1.centroid2D()!.toText(decimals: 3, compactNums: false),
        '1.500,3.000',
      );

      // polygon with hole slightly smaller than exterior
      const delta = 0.000000001;
      final polHolSP2 = Polygon([
        exterior,
        [
          [0.0 + delta, 0.0 + delta].xy,
          [3.0 - delta, 0.0 + delta].xy,
          [3.0 - delta, 6.0 - delta].xy,
          [0.0 + delta, 6.0 - delta].xy,
          [0.0 + delta, 0.0 + delta].xy,
        ].series(),
      ]);
      expect(
        polHolSP2.centroid2D()!.toText(decimals: 3, compactNums: false),
        '1.500,3.000',
      );

      // polygon with hole slightly larger than exterior (even if not actually
      // valid geometry)
      final polHolSP3 = Polygon([
        exterior,
        [
          [0.0 - delta, 0.0 - delta].xy,
          [3.0 + delta, 0.0 - delta].xy,
          [3.0 + delta, 6.0 + delta].xy,
          [0.0 - delta, 6.0 + delta].xy,
          [0.0 - delta, 0.0 - delta].xy,
        ].series(),
      ]);
      expect(
        polHolSP3.centroid2D()!.toText(decimals: 3, compactNums: false),
        '1.500,3.000',
      );

      // polygon with hole taking half of exterior out
      final polHolSP4 = Polygon([
        exterior,
        [
          [0.0, 0.0].xy,
          [3.0, 0.0].xy,
          [3.0, 3.0].xy,
          [0.0, 3.0].xy,
          [0.0, 0.0].xy,
        ].series(),
      ]);
      expect(
        polHolSP4.centroid2D()!.toText(decimals: 3, compactNums: false),
        '1.500,4.500',
      );
    });

    test('Centroid2D for geometry collection and multi polygon', () {
      const polygons = [
        [
          'POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))',
          'POINT(1.5 1.5)',
        ],
        [
          'POLYGON((11 11, 12 11, 12 12, 11 12, 11 11))',
          'POINT(11.5 11.5)',
        ],
        [
          'POLYGON((11 11, 12 11, 12 11, 11 11, 11 11))', // linear, no area
          'POINT(11.5 11.0)',
        ],
        [
          'POLYGON((11 11, 11 11, 11 11, 11 11, 11 11))', // punctual, no area
          'POINT(11.0 11.0)',
        ],
      ];

      final geoms = <Polygon>[];
      for (final testCase in polygons) {
        final pol = Polygon.parse(testCase[0], format: WKT.geometry);
        final centroid = Point.parse(testCase[1], format: WKT.geometry);

        expect(pol.centroid2D()?.toText(), centroid.position.toText());

        geoms.add(pol);
      }

      final coll = GeometryCollection(geoms.sublist(0, 2));
      expect(coll.centroid2D()?.toText(), '6.5,6.5');
      final coll2 = GeometryCollection(geoms.sublist(1, 2));
      expect(coll2.centroid2D()?.toText(), '11.5,11.5');
      final coll3 = GeometryCollection(const <Polygon>[]);
      expect(coll3.centroid2D()?.toText(), isNull);
      final col4 = GeometryCollection(geoms.sublist(0, 4));
      expect(col4.centroid2D()?.toText(), '6.5,6.5');
      final col5 = GeometryCollection(geoms.sublist(1, 4));
      expect(col5.centroid2D()?.toText(), '11.5,11.5');
      expect(col5.dimensionality2D(), Dimensionality.areal);
      final col6 = GeometryCollection(geoms.sublist(2, 4));
      expect(col6.centroid2D()?.toText(), '11.5,11');
      expect(col6.dimensionality2D(), Dimensionality.linear);
      final col7 = GeometryCollection(geoms.sublist(3, 4));
      expect(col7.centroid2D()?.toText(), '11,11');
      expect(col7.dimensionality2D(), Dimensionality.punctual);

      final mpl = MultiPolygon.fromGeometries(geoms.sublist(0, 2));
      expect(mpl.centroid2D()?.toText(), '6.5,6.5');
      final mp2 = MultiPolygon.fromGeometries(geoms.sublist(1, 2));
      expect(mp2.centroid2D()?.toText(), '11.5,11.5');
      final mp3 = MultiPolygon.fromGeometries(const <Polygon>[]);
      expect(mp3.centroid2D()?.toText(), isNull);
      final mp4 = MultiPolygon.fromGeometries(geoms.sublist(0, 4));
      expect(mp4.centroid2D()?.toText(), '6.5,6.5');
      final mp5 = MultiPolygon.fromGeometries(geoms.sublist(1, 4));
      expect(mp5.centroid2D()?.toText(), '11.5,11.5');
      final mp6 = MultiPolygon.fromGeometries(geoms.sublist(2, 4));
      expect(mp6.centroid2D()?.toText(), '11.5,11');
      final mp7 = MultiPolygon.fromGeometries(geoms.sublist(3, 4));
      expect(mp7.centroid2D()?.toText(), '11,11');
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
  const eps = 5 * defaultEpsilon;
  switch (geometry.geomType) {
    case Geom.point:
      final parsed = Point.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmptyByGeometry,
      );
      break;
    case Geom.lineString:
      final parsed = LineString.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmptyByGeometry,
      );
      break;
    case Geom.polygon:
      final parsed = Polygon.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmptyByGeometry,
      );
      break;
    case Geom.multiPoint:
      final parsed = MultiPoint.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmptyByGeometry,
      );
      break;
    case Geom.multiLineString:
      final parsed = MultiLineString.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmptyByGeometry,
      );
      break;
    case Geom.multiPolygon:
      final parsed = MultiPolygon.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmptyByGeometry,
      );
      break;
    case Geom.geometryCollection:
      final parsed = GeometryCollection.parse(geometryAsText, format: format);
      expect(parsed.toText(format: format), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
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
  const eps = 5 * defaultEpsilon;
  switch (geometry.geomType) {
    case Geom.point:
      final parsed = Point.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmptyByGeometry,
      );
      break;
    case Geom.lineString:
      final parsed = LineString.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmptyByGeometry,
      );
      break;
    case Geom.polygon:
      final parsed = Polygon.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmptyByGeometry,
      );
      break;
    case Geom.multiPoint:
      final parsed = MultiPoint.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmptyByGeometry,
      );
      break;
    case Geom.multiLineString:
      final parsed = MultiLineString.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmptyByGeometry,
      );
      break;
    case Geom.multiPolygon:
      final parsed = MultiPolygon.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
      expect(
        geometry.equals3D(parsed, toleranceHoriz: eps, toleranceVert: eps),
        parsed.coordType.is3D && !parsed.isEmptyByGeometry,
      );
      break;
    case Geom.geometryCollection:
      final parsed = GeometryCollection.decode(bytes);
      expect(parsed.toText(format: textFormat), geometryAsText);
      expect(
        geometry.equals2D(parsed, toleranceHoriz: eps),
        !parsed.isEmptyByGeometry,
      );
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
  const eps = 5 * defaultEpsilon;
  if (object is Feature) {
    final parsed = Feature.parse(geoJsonText);
    expect(parsed.toText(), geoJsonText);
    expect(
      object.equals2D(parsed, toleranceHoriz: eps),
      !parsed.isEmptyByGeometry,
    );
  } else if (object is FeatureCollection) {
    final parsed = FeatureCollection.parse(geoJsonText);
    expect(parsed.toText(), geoJsonText);
    expect(
      object.equals2D(parsed, toleranceHoriz: eps),
      !parsed.isEmptyByGeometry,
    );
  }
}
