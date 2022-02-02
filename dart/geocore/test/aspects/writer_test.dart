// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

import 'package:geocore/aspects.dart';

import 'package:test/test.dart';

void main() {
  group('Test geometry, coordinate and bounds writers', () {
    test('Point coordinates', () {
      _testAllWriters<CoordinateWriter>(
        (writer) => writer.coordPoint(x: 10.123, y: 20.25),
        def: '10.123,20.25',
        geoJson: '10.123,20.25',
        wktLike: '10.123 20.25',
        wkt: '10.123 20.25',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) => writer.coordPoint(x: 10.123, y: 20.25, z: -30.95),
        def: '10.123,20.25,-30.95',
        geoJson: '10.123,20.25,-30.95',
        wktLike: '10.123 20.25 -30.95',
        wkt: '10.123 20.25 -30.95',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) => writer.coordPoint(x: 10.123, y: 20.25, m: -1.999),
        def: '10.123,20.25,0,-1.999',
        geoJson: '10.123,20.25,0,-1.999',
        geoJsonStrict: '10.123,20.25',
        wktLike: '10.123 20.25 0 -1.999',
        wkt: '10.123 20.25 0 -1.999',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) =>
            writer.coordPoint(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
        def: '10.1,20.3,-30.9,-2.0',
        geoJson: '10.1,20.3,-30.9,-2.0',
        geoJsonStrict: '10.1,20.3,-30.9',
        wktLike: '10.123 20.250 -30.950 -1.999',
        wkt: '10.12 20.25 -30.95 -2.00',
        defDecimals: 1,
        geoJsonDecimals: 1,
        wktLikeDecimals: 3,
        wktDecimals: 2,
      );
    });
    test('Bounds coordinates', () {
      _testAllWriters<BoundsWriter>(
        (writer) => writer.coordBounds(
          minX: 10.123,
          minY: 20.25,
          maxX: 12.485,
          maxY: 25.195,
        ),
        def: '10.123,20.25,12.485,25.195',
        geoJson: '10.123,20.25,12.485,25.195',
        wktLike: '10.123 20.25,12.485 25.195',
        wkt: 'POLYGON((10.123 20.25,12.485 20.25,12.485 25.195,10.123 '
            '25.195,10.123 20.25))',
      );
      _testAllWriters<BoundsWriter>(
        (writer) => writer.coordBounds(
          minX: 10.123,
          minY: 20.25,
          minZ: -15.09,
          maxX: 12.485,
          maxY: 25.195,
          maxZ: -14.949,
        ),
        def: '10.12,20.25,-15.09,12.48,25.20,-14.95',
        geoJson: '10.12,20.25,-15.09,12.48,25.20,-14.95',
        wktLike: '10 20 -15,12 25 -15',
        wkt: 'POLYGON Z((10.1 20.3 -15.1,12.5 20.3 -15.0,12.5 25.2 -14.9,10.1 '
            '25.2 -15.0,10.1 20.3 -15.1))',
        defDecimals: 2,
        geoJsonDecimals: 2,
        wktLikeDecimals: 0,
        wktDecimals: 1,
      );
    });
    test('PointSeries coordinates', () {
      _testAllWriters<CoordinateWriter>(
        (writer) => writer
          ..coordArray()
          ..coordPoint(x: 10.123, y: 20.25)
          ..coordPoint(x: 10.123, y: 20.25, z: -30.95)
          ..coordPoint(x: 10.123, y: 20.25, m: -1.999)
          ..coordArrayEnd(),
        def: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25,0,-1.999]',
        geoJson: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25,0,-1.999]',
        geoJsonStrict: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25]',
        wktLike: '10.123 20.25,10.123 20.25 -30.95,10.123 20.25 0 -1.999',
        wkt: '10.123 20.25,10.123 20.25 -30.95,10.123 20.25 0 -1.999',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) => writer
          ..coordArray()
          ..coordPoint(x: 10.123, y: 20.25)
          ..coordPoint(x: 10.123, y: 20.25, m: -1.999)
          ..coordPoint(x: 10.123, y: 20.25, z: -30.95)
          ..coordArrayEnd(),
        def: '[10.123,20.25],[10.123,20.25,0,-1.999],[10.123,20.25,-30.95]',
        geoJson: '[10.123,20.25],[10.123,20.25,0,-1.999],[10.123,20.25,-30.95]',
        geoJsonStrict: '[10.123,20.25],[10.123,20.25],[10.123,20.25,-30.95]',
        wktLike: '10.123 20.25,10.123 20.25 0 -1.999,10.123 20.25 -30.95',
        wkt: '10.123 20.25,10.123 20.25 0 -1.999,10.123 20.25 -30.95',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) => writer
          ..coordArray()
          ..coordPoint(x: 10.123, y: 20.25)
          ..coordPoint(x: 10.123, y: 20.25, z: -30.95, m: -1.999)
          ..coordPoint(x: 10.123, y: 20.25)
          ..coordArrayEnd(),
        def: '[10.123,20.25],[10.123,20.25,-30.95,-1.999],[10.123,20.25]',
        geoJson: '[10.123,20.25],[10.123,20.25,-30.95,-1.999],[10.123,20.25]',
        geoJsonStrict: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25]',
        wktLike: '10.123 20.25,10.123 20.25 -30.95 -1.999,10.123 20.25',
        wkt: '10.123 20.25,10.123 20.25 -30.95 -1.999,10.123 20.25',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) => writer
          ..coordArray()
          ..coordPoint(x: 10, y: 20)
          ..coordPoint(x: 11, y: 21, z: -30.95, m: -1.1)
          ..coordPoint(x: 12, y: 22, m: 2.2)
          ..coordPoint(x: 13, y: 23, z: 49.1)
          ..coordArrayEnd(),
        def: '[10,20],[11,21,-30.95,-1.1],[12,22,0,2.2],[13,23,49.1]',
        geoJson: '[10,20],[11,21,-30.95,-1.1],[12,22,0,2.2],[13,23,49.1]',
        geoJsonStrict: '[10,20],[11,21,-30.95],[12,22],[13,23,49.1]',
        wktLike: '10 20,11 21 -30.95 -1.1,12 22 0 2.2,13 23 49.1',
        wkt: '10 20,11 21 -30.95 -1.1,12 22 0 2.2,13 23 49.1',
      );
    });
    test('Point geometry', () {
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.point,
          coordinates: (cw) => cw.coordPoint(x: 10.123, y: 20.25),
        ),
        def: '10.123,20.25',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25]}',
        wktLike: '10.123 20.25',
        wkt: 'POINT(10.123 20.25)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.point,
          coordinates: (cw) => cw.coordPoint(x: 10.123, y: 20.25, z: -30.95),
        ),
        def: '10.123,20.25,-30.95',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95',
        wkt: 'POINT(10.123 20.25 -30.95)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.point,
          coordinates: (cw) => cw.coordPoint(x: 10.123, y: 20.25, m: -1.999),
        ),
        def: '10.123,20.25,0,-1.999',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,0,-1.999]}',
        geoJsonStrict: '{"type":"Point","coordinates":[10.123,20.25]}',
        wktLike: '10.123 20.25 0 -1.999',
        wkt: 'POINT(10.123 20.25 0 -1.999)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.point,
          coordinates: (cw) =>
              cw.coordPoint(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
        ),
        def: '10.123,20.25,-30.95,-1.999',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95,-1.999]}',
        geoJsonStrict: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95 -1.999',
        wkt: 'POINT(10.123 20.25 -30.95 -1.999)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.point,
          coordinates: (cw) => cw.coordPoint(x: 10.123, y: 20.25, z: -30.95),
          coordType: Coords.xyz,
        ),
        def: '10.123,20.25,-30.95',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95',
        wkt: 'POINT Z(10.123 20.25 -30.95)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.point,
          coordinates: (cw) =>
              cw.coordPoint(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
          coordType: Coords.xyz,
        ),
        def: '10.123,20.25,-30.95',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95',
        wkt: 'POINT Z(10.123 20.25 -30.95)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.point,
          coordinates: (cw) => cw.coordPoint(x: 10.123, y: 20.25, z: -30.95),
          coordType: Coords.xy,
        ),
        def: '10.123,20.25',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25]}',
        wktLike: '10.123 20.25',
        wkt: 'POINT(10.123 20.25)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.point,
          coordinates: (cw) => cw.coordPoint(x: 10.123, y: 20.25),
          coordType: Coords.xyz,
        ),
        def: '10.123,20.25,0',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,0]}',
        wktLike: '10.123 20.25 0',
        wkt: 'POINT Z(10.123 20.25 0)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.point,
          coordinates: (cw) =>
              cw.coordPoint(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
          coordType: Coords.xym,
        ),
        def: '10.123,20.25,0,-1.999',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,0,-1.999]}',
        geoJsonStrict: '{"type":"Point","coordinates":[10.123,20.25]}',
        wktLike: '10.123 20.25 -1.999',
        wkt: 'POINT M(10.123 20.25 -1.999)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.point,
          coordinates: (cw) =>
              cw.coordPoint(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
          coordType: Coords.xyzm,
        ),
        def: '10.123,20.25,-30.95,-1.999',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95,-1.999]}',
        geoJsonStrict: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95 -1.999',
        wkt: 'POINT ZM(10.123 20.25 -30.95 -1.999)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.emptyGeometry(Geom.point),
        def: '',
        geoJson: '{"type":"Point","coordinates":[]}',
        wktLike: '',
        wkt: 'POINT EMPTY',
      );
    });
    test('MultiPoint geometry', () {
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.multiPoint,
          coordinates: (cw) => cw
            ..coordArray()
            ..coordPoint(x: 10.123, y: 20.25)
            ..coordPoint(x: 5.98, y: -3.47)
            ..coordArrayEnd(),
        ),
        def: '[10.123,20.25],[5.98,-3.47]',
        geoJson:
            '{"type":"MultiPoint","coordinates":[[10.123,20.25],[5.98,-3.47]]}',
        wktLike: '10.123 20.25,5.98 -3.47',
        wkt: 'MULTIPOINT(10.123 20.25,5.98 -3.47)',
      );
    });
    test('LineString geometry', () {
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.lineString,
          bounds: (bw) =>
              bw.coordBounds(minX: -1.1, minY: -3.49, maxX: 3.5, maxY: -1.1),
          coordinates: (cw) => cw
            ..coordArray()
            ..coordPoint(x: -1.1, y: -1.1)
            ..coordPoint(x: 2.1, y: -2.5)
            ..coordPoint(x: 3.5, y: -3.49)
            ..coordArrayEnd(),
        ),
        def: '[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]',
        geoJson: '{"type":"LineString",'
            '"bbox":[-1.1,-3.49,3.5,-1.1],'
            '"coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]}',
        wktLike: '-1.1 -1.1,2.1 -2.5,3.5 -3.49',
        wkt: 'LINESTRING(-1.1 -1.1,2.1 -2.5,3.5 -3.49)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.lineString,
          coordType: Coords.xym,
          bounds: (bw) => bw.coordBounds(
            minX: -1.1,
            minY: -3.49,
            minM: 0,
            maxX: 3.5,
            maxY: -1.1,
            maxM: 4.99,
          ),
          coordinates: (cw) => cw
            ..coordArray()
            ..coordPoint(x: -1.1, y: -1.1)
            ..coordPoint(x: 2.1, y: -2.5, m: 4.99)
            ..coordPoint(x: 3.5, y: -3.49, z: -0.5)
            ..coordArrayEnd(),
        ),
        def: '[-1.1,-1.1,0,0],[2.1,-2.5,0,4.99],[3.5,-3.49,0,0]',
        geoJson: '{"type":"LineString",'
            '"bbox":[-1.1,-3.49,0,0,3.5,-1.1,0,4.99],'
            '"coordinates":[[-1.1,-1.1,0,0],'
            '[2.1,-2.5,0,4.99],[3.5,-3.49,0,0]]}',
        geoJsonStrict: '{"type":"LineString",'
            '"bbox":[-1.1,-3.49,3.5,-1.1],'
            '"coordinates":[[-1.1,-1.1],'
            '[2.1,-2.5],[3.5,-3.49]]}',
        wktLike: '-1.1 -1.1 0,2.1 -2.5 4.99,3.5 -3.49 0',
        wkt: 'LINESTRING M(-1.1 -1.1 0,2.1 -2.5 4.99,3.5 -3.49 0)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.lineString,
          coordType: Coords.xyzm,
          bounds: (bw) => bw.coordBounds(
            minX: -1.1,
            minY: -3.49,
            minZ: -0.5,
            minM: 0,
            maxX: 3.5,
            maxY: -1.1,
            maxZ: 0,
            maxM: 4.99,
          ),
          coordinates: (cw) => cw
            ..coordArray()
            ..coordPoint(x: -1.1, y: -1.1)
            ..coordPoint(x: 2.1, y: -2.5, m: 4.99)
            ..coordPoint(x: 3.5, y: -3.49, z: -0.5)
            ..coordArrayEnd(),
        ),
        def: '[-1.1,-1.1,0,0],[2.1,-2.5,0,4.99],[3.5,-3.49,-0.5,0]',
        geoJson: '{"type":"LineString",'
            '"bbox":[-1.1,-3.49,-0.5,0,3.5,-1.1,0,4.99],'
            '"coordinates":[[-1.1,-1.1,0,0],'
            '[2.1,-2.5,0,4.99],[3.5,-3.49,-0.5,0]]}',
        geoJsonStrict: '{"type":"LineString",'
            '"bbox":[-1.1,-3.49,-0.5,3.5,-1.1,0],'
            '"coordinates":[[-1.1,-1.1,0],'
            '[2.1,-2.5,0],[3.5,-3.49,-0.5]]}',
        wktLike: '-1.1 -1.1 0 0,2.1 -2.5 0 4.99,3.5 -3.49 -0.5 0',
        wkt: 'LINESTRING ZM(-1.1 -1.1 0 0,2.1 -2.5 0 4.99,3.5 -3.49 -0.5 0)',
      );
    });
    test('MultiLineString geometry', () {
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.multiLineString,
          coordinates: (cw) => cw
            ..coordArray()
            ..coordArray()
            ..coordPoint(x: -1.1, y: -1.1)
            ..coordPoint(x: 2.1, y: -2.5)
            ..coordPoint(x: 3.5, y: -3.49)
            ..coordArrayEnd()
            ..coordArray()
            ..coordPoint(x: 38.19, y: 57.4)
            ..coordArrayEnd()
            ..coordArrayEnd(),
        ),
        def: '[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]],[[38.19,57.4]]',
        geoJson: '{"type":"MultiLineString","coordinates":[[[-1.1,-1.1],'
            '[2.1,-2.5],[3.5,-3.49]],[[38.19,57.4]]]}',
        wktLike: '(-1.1 -1.1,2.1 -2.5,3.5 -3.49),(38.19 57.4)',
        wkt: 'MULTILINESTRING((-1.1 -1.1,2.1 -2.5,3.5 -3.49),(38.19 57.4))',
      );
    });
    test('Polygon geometry', () {
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.polygon,
          coordinates: (cw) => cw
            ..coordArray()
            ..coordArray()
            ..coordPoint(x: 10.1, y: 10.1)
            ..coordPoint(x: 5, y: 9)
            ..coordPoint(x: 12, y: 4)
            ..coordPoint(x: 10.1, y: 10.1)
            ..coordArrayEnd()
            ..coordArrayEnd(),
        ),
        def: '[[10.1,10.1],[5,9],[12,4],[10.1,10.1]]',
        geoJson: '{"type":"Polygon",'
            '"coordinates":[[[10.1,10.1],[5,9],[12,4],[10.1,10.1]]]}',
        wktLike: '(10.1 10.1,5 9,12 4,10.1 10.1)',
        wkt: 'POLYGON((10.1 10.1,5 9,12 4,10.1 10.1))',
      );
    });
    test('MultiPolygon geometry', () {
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometry(
          type: Geom.multiPolygon,
          coordinates: (cw) => cw
            ..coordArray()
            ..coordArray()
            ..coordArray()
            ..coordPoint(x: 10.1, y: 10.1)
            ..coordPoint(x: 5, y: 9)
            ..coordPoint(x: 12, y: 4)
            ..coordPoint(x: 10.1, y: 10.1)
            ..coordArrayEnd()
            ..coordArrayEnd()
            ..coordArrayEnd(),
        ),
        def: '[[[10.1,10.1],[5,9],[12,4],[10.1,10.1]]]',
        geoJson: '{"type":"MultiPolygon",'
            '"coordinates":[[[[10.1,10.1],[5,9],[12,4],[10.1,10.1]]]]}',
        wktLike: '((10.1 10.1,5 9,12 4,10.1 10.1))',
        wkt: 'MULTIPOLYGON(((10.1 10.1,5 9,12 4,10.1 10.1)))',
      );
    });
    test('GeometryCollection geometry', () {
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryCollection(
          geometries: (gw) => gw
            ..geometry(
              type: Geom.point,
              coordinates: (cw) =>
                  cw.coordPoint(x: 10.123, y: 20.25, z: -30.95),
              coordType: Coords.xyz,
            )
            ..geometry(
              type: Geom.polygon,
              coordinates: (cw) => cw
                ..coordArray()
                ..coordArray()
                ..coordPoint(x: 10.1, y: 10.1)
                ..coordPoint(x: 5, y: 9)
                ..coordPoint(x: 12, y: 4)
                ..coordPoint(x: 10.1, y: 10.1)
                ..coordArrayEnd()
                ..coordArrayEnd(),
            ),
        ),
        def: '[10.123,20.25,-30.95],[[[10.1,10.1],[5,9],[12,4],[10.1,10.1]]]',
        geoJson: '{"type":"GeometryCollection","geometries":[{"type":"Point",'
            '"coordinates":[10.123,20.25,-30.95]},{"type":"Polygon",'
            '"coordinates":[[[10.1,10.1],[5,9],[12,4],[10.1,10.1]]]}]}',
        wktLike: '(10.123 20.25 -30.95),((10.1 10.1,5 9,12 4,10.1 10.1))',
        wkt: 'GEOMETRYCOLLECTION(POINT Z(10.123 20.25 -30.95),POLYGON((10.1 '
            '10.1,5 9,12 4,10.1 10.1)))',
      );
    });
  });

  group('Test feature writers', () {
    test('Feature', () {
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.feature(
          id: 'fid-1',
          bounds: (bw) => bw.coordBounds(
            minX: -1.1,
            minY: -3.49,
            minZ: -0.5,
            minM: 0,
            maxX: 3.5,
            maxY: -1.1,
            maxZ: 0,
            maxM: 4.99,
          ),
          geometries: (gw) => gw.geometry(
            type: Geom.lineString,
            coordType: Coords.xyzm,
            coordinates: (cw) => cw
              ..coordArray()
              ..coordPoint(x: -1.1, y: -1.1)
              ..coordPoint(x: 2.1, y: -2.5, m: 4.99)
              ..coordPoint(x: 3.5, y: -3.49, z: -0.5)
              ..coordArrayEnd(),
          ),
          properties: {
            'prop': 1,
          },
        ),
        geoJson:
            '{"type":"Feature","id":"fid-1","bbox":[-1.1,-3.49,-0.5,0,3.5,-1.1,0,4.99],"geometry":{"type":"LineString","coordinates":[[-1.1,-1.1,0,0],[2.1,-2.5,0,4.99],[3.5,-3.49,-0.5,0]]},"properties":{"prop":1}}',
        geoJsonStrict:
            '{"type":"Feature","id":"fid-1","bbox":[-1.1,-3.49,-0.5,3.5,-1.1,0],"geometry":{"type":"LineString","coordinates":[[-1.1,-1.1,0],[2.1,-2.5,0],[3.5,-3.49,-0.5]]},"properties":{"prop":1}}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.feature(
          id: 'fid-1',
          geometries: (gw) => gw.geometry(
            type: Geom.point,
            coordinates: (cw) => cw.coordPoint(x: 10.123, y: 20.25),
          ),
          properties: {
            'foo': 100,
            'bar': 'this is property value',
            'baz': true,
          },
        ),
        geoJson: '{"type":"Feature","id":"fid-1","geometry":{"type":"Point",'
            '"coordinates":[10.123,20.25]},"properties":{"foo":100,"bar":'
            '"this is property value","baz":true}}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.feature(
          geometries: (gw) => gw.geometry(
            type: Geom.point,
            coordinates: (cw) => cw.coordPoint(x: 10.123, y: 20.25),
          ),
          properties: {
            'foo': {
              'bar': 'this is property value',
              'baz': [true, false],
            },
          },
        ),
        geoJson: '{"type":"Feature","geometry":{"type":"Point",'
            '"coordinates":[10.123,20.25]},"properties":{"foo":{'
            '"bar":"this is property value","baz":[true,false]}}}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.feature(
          geometries: (gw) {
            gw
              ..geometry(
                type: Geom.point,
                coordinates: (cw) => cw.coordPoint(x: 10.123, y: 20.25),
              )
              ..geometry(
                name: 'geom1',
                type: Geom.point,
                coordinates: (cw) => cw.coordPoint(x: 1, y: 2, z: 3, m: 4),
              );
          },
          extra: (pw) => pw.properties('extra', {
            'foo': {
              'bar': 'this is property value',
              'baz': [true, false],
            },
          }),
        ),
        geoJson: '{"type":"Feature",'
            '"geometry":{"type":"Point","coordinates":[10.123,20.25]},'
            '"geom1":{"type":"Point","coordinates":[1,2,3,4]},'
            '"properties":null,"extra":{"foo":{'
            '"bar":"this is property value","baz":[true,false]}}}',
        geoJsonStrict: '{"type":"Feature",'
            '"geometry":{"type":"Point","coordinates":[10.123,20.25]},'
            '"properties":null}',
      );
    });
    test('FeatureCollection', () {
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.featureCollection(
          bounds: (bw) => bw.coordBounds(
            minX: -1.1,
            minY: -3.49,
            maxX: 10.123,
            maxY: 20.25,
          ),
          features: (fw) => fw
            ..feature(
              id: 'fid-1',
              geometries: (gw) => gw.geometry(
                type: Geom.point,
                coordinates: (cw) => cw.coordPoint(x: 10.123, y: 20.25),
              ),
              properties: {
                'foo': 100,
                'bar': 'this is property value',
              },
            )
            ..feature(
              geometries: (gw) => gw.geometry(
                type: Geom.lineString,
                bounds: (bw) => bw.coordBounds(
                  minX: -1.1,
                  minY: -3.49,
                  maxX: 3.5,
                  maxY: -1.1,
                ),
                coordinates: (cw) => cw
                  ..coordArray()
                  ..coordPoint(x: -1.1, y: -1.1)
                  ..coordPoint(x: 2.1, y: -2.5)
                  ..coordPoint(x: 3.5, y: -3.49)
                  ..coordArrayEnd(),
              ),
            ),
        ),
        geoJson:
            '{"type":"FeatureCollection","bbox":[-1.1,-3.49,10.123,20.25],"features":[{"type":"Feature","id":"fid-1","geometry":{"type":"Point","coordinates":[10.123,20.25]},"properties":{"foo":100,"bar":"this is property value"}},{"type":"Feature","geometry":{"type":"LineString","bbox":[-1.1,-3.49,3.5,-1.1],"coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]},"properties":null}]}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.featureCollection(features: (fw) {}),
        geoJson: '{"type":"FeatureCollection","features":[]}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.featureCollection(
          features: (fw) {},
          extra: (pw) => pw.property('prop1', 'value1'),
        ),
        geoJson: '{"type":"FeatureCollection","features":[],"prop1":"value1"}',
        geoJsonStrict: '{"type":"FeatureCollection","features":[]}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.featureCollection(
          features: (fw) {},
          extra: (pw) => pw.properties('map1', {'prop1': 'value1'}),
        ),
        geoJson: '{"type":"FeatureCollection",'
            '"features":[],"map1":{"prop1":"value1"}}',
        geoJsonStrict: '{"type":"FeatureCollection","features":[]}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.featureCollection(
          features: (fw) => fw.featureCollection(features: (fw) {}),
        ),
        geoJson: '{"type":"FeatureCollection","features":[]}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.featureCollection(
          features: (fw) => fw.feature(),
        ),
        geoJson: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","properties":null}]}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.featureCollection(
          features: (fw) => fw
            ..feature()
            ..feature(),
        ),
        geoJson: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","properties":null},'
            '{"type":"Feature","properties":null}]}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.featureCollection(
          features: (fw) => fw
            ..feature(extra: (pw) => pw.property('prop1', 'value1'))
            ..feature(
              extra: (pw) => pw.properties('map1', {'prop1': 'value1'}),
            ),
        ),
        geoJson: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","properties":null,"prop1":"value1"},'
            '{"type":"Feature","properties":null,"map1":{"prop1":"value1"}}]}',
        geoJsonStrict: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","properties":null},'
            '{"type":"Feature","properties":null}]}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.featureCollection(
          count: 2,
          features: (fw) => fw
            ..feature(
              id: 1,
              properties: {'test1': 3},
              extra: (pw) => pw.property('p1', BigInt.one),
            )
            ..feature(
              id: '2',
              properties: {},
              extra: (pw) => pw.properties('map1', {'p2': 2}),
            ),
        ),
        geoJson: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","id":1,"properties":{"test1":3},"p1":1},'
            '{"type":"Feature","id":"2","properties":{},"map1":{"p2":2}}]}',
        geoJsonStrict: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","id":1,"properties":{"test1":3}},'
            '{"type":"Feature","id":"2","properties":{}}]}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.featureCollection(
          count: 2,
          features: (fw) => fw
            ..feature(
              geometries: (gw) => gw.geometry(
                type: Geom.point,
                coordinates: (cw) => cw.coordPoint(x: 1, y: 2),
              ),
              properties: {'test1': null},
            )
            ..feature(
              id: '2',
              geometries: (gw) => gw.emptyGeometry(Geom.point),
              properties: {},
            ),
        ),
        geoJson: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","geometry":{"type":"Point",'
            '"coordinates":[1,2]},"properties":{"test1":null}},'
            '{"type":"Feature","id":"2","geometry":null,"properties":{}}]}',
      );
    });
  });
}

void _testAllWriters<T extends BaseWriter>(
  void Function(T writer) content, {
  required String def,
  required String geoJson,
  String? geoJsonStrict,
  required String wktLike,
  required String wkt,
  int? defDecimals,
  int? geoJsonDecimals,
  int? wktLikeDecimals,
  int? wktDecimals,
}) {
  _testWriterOfGeometryFormat<T>(
    defaultFormat,
    content,
    expected: def,
    decimals: defDecimals,
  );
  _testWriterOfGeometryFormat<T>(
    geoJsonFormat(),
    content,
    expected: geoJson,
    decimals: geoJsonDecimals,
  );
  _testWriterOfGeometryFormat<T>(
    geoJsonFormat(ignoreMeasured: true, ignoreForeignMembers: true),
    content,
    expected: geoJsonStrict ?? geoJson,
    decimals: geoJsonDecimals,
  );
  _testWriterOfGeometryFormat<T>(
    wktLikeFormat,
    content,
    expected: wktLike,
    decimals: wktLikeDecimals,
  );
  _testWriterOfGeometryFormat<T>(
    wktFormat(),
    content,
    expected: wkt,
    decimals: wktDecimals,
  );
}

void _testGeoJsonWriters<T extends BaseWriter>(
  void Function(T writer) content, {
  required String geoJson,
  String? geoJsonStrict,
  int? decimals,
}) {
  _testWriterOfFeatureFormat<T>(
    geoJsonFormat(),
    content,
    expected: geoJson,
    decimals: decimals,
  );
  _testWriterOfFeatureFormat<T>(
    geoJsonFormat(ignoreMeasured: true, ignoreForeignMembers: true),
    content,
    expected: geoJsonStrict ?? geoJson,
    decimals: decimals,
  );
}

void _testWriterOfGeometryFormat<T extends BaseWriter>(
  GeometryFormat format,
  void Function(T writer) content, {
  required String expected,
  int? decimals,
}) {
  final T writer;
  if (T == BoundsWriter) {
    writer = format.boundsToText(decimals: decimals) as T;
  } else if (T == CoordinateWriter) {
    writer = format.coordinatesToText(decimals: decimals) as T;
  } else {
    assert(T == GeometryWriter, 'expecting geometry writer');
    writer = format.geometriesToText(decimals: decimals) as T;
  }
  content(writer);
  expect(writer.toString(), expected);
}

void _testWriterOfFeatureFormat<T extends BaseWriter>(
  FeatureFormat format,
  void Function(T writer) content, {
  required String expected,
  int? decimals,
}) {
  if (T == FeatureWriter) {
    final writer = format.featuresToText(decimals: decimals) as T;
    content(writer);
    expect(writer.toString(), expected);
  } else {
    _testWriterOfGeometryFormat(
      format,
      content,
      expected: expected,
      decimals: decimals,
    );
  }
}
