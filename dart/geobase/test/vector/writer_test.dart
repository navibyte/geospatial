// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';

import 'package:test/test.dart';

void main() {
  group('Test geometry, coordinate and bounds writers', () {
    test('Projected coordinates', () {
      _testAllWriters<CoordinateContent>(
        [
          (output) => output.position([10.123, 20.25].position),
          (output) => output.position(const Projected(x: 10.123, y: 20.25)),
        ],
        def: '10.123,20.25',
        geoJson: '10.123,20.25',
        wktLike: '10.123 20.25',
        wkt: '10.123 20.25',
      );
      _testAllWriters<CoordinateContent>(
        [
          (output) => output.position([10.123, 20.25, -30.95].position),
          (output) =>
              output.position(const Projected(x: 10.123, y: 20.25, z: -30.95)),
        ],
        def: '10.123,20.25,-30.95',
        geoJson: '10.123,20.25,-30.95',
        wktLike: '10.123 20.25 -30.95',
        wkt: '10.123 20.25 -30.95',
      );
      _testAllWriters<CoordinateContent>(
        [
          (output) => output.position(
                PositionCoords.view(
                  [10.123, 20.25, -1.999],
                  type: Coords.xym,
                ),
              ),
          (output) => output.position(
                const Projected(x: 10.123, y: 20.25, m: -1.999),
              ),
        ],
        def: '10.123,20.25,0,-1.999',
        geoJson: '10.123,20.25,0,-1.999',
        geoJsonStrict: '10.123,20.25',
        wktLike: '10.123 20.25 -1.999',
        wkt: '10.123 20.25 -1.999',
      );
      _testAllWriters<CoordinateContent>(
        [
          (output) => output.position([10.123, 20.25, -30.95, -1.999].position),
          (output) => output.position(
                const Projected(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
              ),
        ],
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
    test('Geographic coordinates', () {
      _testAllWriters<CoordinateContent>(
        [
          (output) => output.position([10.123, 20.25, -30.95, -1.999].position),
          (output) => output.position(
                const Geographic(
                  lon: 10.123,
                  lat: 20.25,
                  elev: -30.95,
                  m: -1.999,
                ),
              ),
        ],
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
    test('Box coordinates', () {
      _testAllWriters<CoordinateContent>(
        [
          (output) => output.bounds([10.123, 20.25, 12.485, 25.195].box),
          (output) => output.bounds(
                const ProjBox(
                  minX: 10.123,
                  minY: 20.25,
                  maxX: 12.485,
                  maxY: 25.195,
                ),
              ),
        ],
        def: '10.123,20.25,12.485,25.195',
        geoJson: '10.123,20.25,12.485,25.195',
        wktLike: '10.123 20.25,12.485 25.195',
        wkt: 'POLYGON((10.123 20.25,12.485 20.25,12.485 25.195,10.123 '
            '25.195,10.123 20.25))',
      );
      _testAllWriters<CoordinateContent>(
        [
          (output) => output.bounds(
                BoxCoords.view(
                  [10.123, 20.25, -2.9, 12.485, 25.195, -0.9],
                  type: Coords.xym,
                ),
              ),
          (output) => output.bounds(
                const ProjBox(
                  minX: 10.123,
                  minY: 20.25,
                  minM: -2.9,
                  maxX: 12.485,
                  maxY: 25.195,
                  maxM: -0.9,
                ),
              ),
        ],
        def: '10.12,20.25,0,-2.90,12.48,25.20,0,-0.90',
        geoJson: '10.12,20.25,0,-2.90,12.48,25.20,0,-0.90',
        geoJsonStrict: '10.12,20.25,12.48,25.20',
        wktLike: '10 20 -3,12 25 -1',
        wkt: 'POLYGON M((10.1 20.3 -2.9,12.5 20.3 -1.9,12.5 25.2'
            ' -0.9,10.1 25.2 -1.9,10.1 20.3 -2.9))',
        defDecimals: 2,
        geoJsonDecimals: 2,
        wktLikeDecimals: 0,
        wktDecimals: 1,
      );
      _testAllWriters<CoordinateContent>(
        [
          (output) => output.bounds(
                [10.123, 20.25, -15.09, -2.9, 12.485, 25.195, -14.949, -0.9]
                    .box,
              ),
          (output) => output.bounds(
                const ProjBox(
                  minX: 10.123,
                  minY: 20.25,
                  minZ: -15.09,
                  minM: -2.9,
                  maxX: 12.485,
                  maxY: 25.195,
                  maxZ: -14.949,
                  maxM: -0.9,
                ),
              ),
        ],
        def: '10.12,20.25,-15.09,-2.90,12.48,25.20,-14.95,-0.90',
        geoJson: '10.12,20.25,-15.09,-2.90,12.48,25.20,-14.95,-0.90',
        geoJsonStrict: '10.12,20.25,-15.09,12.48,25.20,-14.95',
        wktLike: '10 20 -15 -3,12 25 -15 -1',
        wkt: 'POLYGON ZM((10.1 20.3 -15.1 -2.9,12.5 20.3 -15.0 -1.9,12.5 25.2'
            ' -14.9 -0.9,10.1 25.2 -15.0 -1.9,10.1 20.3 -15.1 -2.9))',
        defDecimals: 2,
        geoJsonDecimals: 2,
        wktLikeDecimals: 0,
        wktDecimals: 1,
      );
      _testAllWriters<CoordinateContent>(
        [
          (output) => output
              .bounds([10.123, 20.25, -15.09, 12.485, 25.195, -14.949].box),
          (output) => output.bounds(
                const ProjBox(
                  minX: 10.123,
                  minY: 20.25,
                  minZ: -15.09,
                  maxX: 12.485,
                  maxY: 25.195,
                  maxZ: -14.949,
                ),
              ),
        ],
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
    test('GeoBox coordinates', () {
      _testAllWriters<CoordinateContent>(
        [
          (output) => output
              .bounds([10.123, 20.25, -15.09, 12.485, 25.195, -14.949].box),
          (output) => output.bounds(
                const GeoBox(
                  west: 10.123,
                  south: 20.25,
                  minElev: -15.09,
                  east: 12.485,
                  north: 25.195,
                  maxElev: -14.949,
                ),
              ),
        ],
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
      _testAllWriters<CoordinateContent>(
        [
          (output) => output.positions([
                const Projected(x: 10.123, y: 20.25),
                const Projected(x: 10.123, y: 20.25, z: -30.95),
                const Projected(x: 10.123, y: 20.25, m: -1.999),
              ]),
        ],
        def: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25,0,-1.999]',
        geoJson: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25,0,-1.999]',
        geoJsonStrict: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25]',
        wktLike: '10.123 20.25,10.123 20.25 -30.95,10.123 20.25 0 -1.999',
        wkt: '10.123 20.25,10.123 20.25 -30.95,10.123 20.25 0 -1.999',
      );
      _testAllWriters<CoordinateContent>(
        [
          (output) => output.positions([
                const Projected(x: 10.123, y: 20.25),
                const Projected(x: 10.123, y: 20.25, m: -1.999),
                const Projected(x: 10.123, y: 20.25, z: -30.95),
              ]),
        ],
        def: '[10.123,20.25],[10.123,20.25,0,-1.999],[10.123,20.25,-30.95]',
        geoJson: '[10.123,20.25],[10.123,20.25,0,-1.999],[10.123,20.25,-30.95]',
        geoJsonStrict: '[10.123,20.25],[10.123,20.25],[10.123,20.25,-30.95]',
        wktLike: '10.123 20.25,10.123 20.25 0 -1.999,10.123 20.25 -30.95',
        wkt: '10.123 20.25,10.123 20.25 0 -1.999,10.123 20.25 -30.95',
      );
      _testAllWriters<CoordinateContent>(
        [
          (output) => output.positions([
                [10.123, 20.25].position,
                [10.123, 20.25, -30.95, -1.999].position,
                [10.123, 20.25].position,
              ]),
          (output) => output.positions([
                const Projected(x: 10.123, y: 20.25),
                const Projected(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
                const Projected(x: 10.123, y: 20.25),
              ]),
        ],
        def: '[10.123,20.25],[10.123,20.25,-30.95,-1.999],[10.123,20.25]',
        geoJson: '[10.123,20.25],[10.123,20.25,-30.95,-1.999],[10.123,20.25]',
        geoJsonStrict: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25]',
        wktLike: '10.123 20.25,10.123 20.25 -30.95 -1.999,10.123 20.25',
        wkt: '10.123 20.25,10.123 20.25 -30.95 -1.999,10.123 20.25',
      );
      _testAllWriters<CoordinateContent>(
        [
          (output) => output.positions([
                const Projected(x: 10, y: 20),
                const Projected(x: 11, y: 21, z: -30.95, m: -1.1),
                const Projected(x: 12, y: 22, m: 2.2),
                const Projected(x: 13, y: 23, z: 49.1),
              ])
        ],
        def: '[10,20],[11,21,-30.95,-1.1],[12,22,0,2.2],[13,23,49.1]',
        geoJson: '[10,20],[11,21,-30.95,-1.1],[12,22,0,2.2],[13,23,49.1]',
        geoJsonStrict: '[10,20],[11,21,-30.95],[12,22],[13,23,49.1]',
        wktLike: '10 20,11 21 -30.95 -1.1,12 22 0 2.2,13 23 49.1',
        wkt: '10 20,11 21 -30.95 -1.1,12 22 0 2.2,13 23 49.1',
      );
    });
    test('Point geometry', () {
      _testAllWriters<GeometryContent>(
        [
          (output) => output.point([10.123, 20.25]),
          (output) => output.point(XY(10.123, 20.25)),
        ],
        def: '10.123,20.25',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25]}',
        wktLike: '10.123 20.25',
        wkt: 'POINT(10.123 20.25)',
      );
      _testAllWriters<GeometryContent>(
        [
          (output) => output.point([10.123, 20.25, -30.95]),
          (output) => output.point(XYZ(10.123, 20.25, -30.95)),
        ],
        def: '10.123,20.25,-30.95',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95',
        wkt: 'POINT Z(10.123 20.25 -30.95)',
      );
      _testAllWriters<GeometryContent>(
        [
          (output) => output.point([10.123, 20.25, -1.999], type: Coords.xym),
          (output) => output.point(
                XYM(10.123, 20.25, -1.999),
                type: Coords.xym,
              ),
        ],
        def: '10.123,20.25,0,-1.999',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,0,-1.999]}',
        geoJsonStrict: '{"type":"Point","coordinates":[10.123,20.25]}',
        wktLike: '10.123 20.25 -1.999',
        wkt: 'POINT M(10.123 20.25 -1.999)',
      );
      _testAllWriters<GeometryContent>(
        [
          (output) => output.point([10.123, 20.25, -30.95, -1.999]),
          (output) => output.point(XYZM(10.123, 20.25, -30.95, -1.999)),
        ],
        def: '10.123,20.25,-30.95,-1.999',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95,-1.999]}',
        geoJsonStrict: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95 -1.999',
        wkt: 'POINT ZM(10.123 20.25 -30.95 -1.999)',
      );
      _testAllWriters<GeometryContent>(
        [
          (output) => output.point([10.123, 20.25, -30.95]),
          (output) => output.point(
                [10.123, 20.25, -30.95],
                type: Coords.xyz,
              ),
          (output) => output.point(XYZ(10.123, 20.25, -30.95)),
        ],
        def: '10.123,20.25,-30.95',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95',
        wkt: 'POINT Z(10.123 20.25 -30.95)',
      );
      _testAllWriters<GeometryContent>(
        [
          (output) => output.point(
                [10.123, 20.25, -30.95, -1.999],
                type: Coords.xyz,
              ),
          (output) => output.point(
                XYZM(10.123, 20.25, -30.95, -1.999),
                type: Coords.xyz,
              ),
        ],
        def: '10.123,20.25,-30.95',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95',
        wkt: 'POINT Z(10.123 20.25 -30.95)',
      );
      _testAllWriters<GeometryContent>(
        [
          (output) => output.point(
                [10.123, 20.25, -30.95],
                type: Coords.xy,
              ),
          (output) => output.point(
                XYZ(10.123, 20.25, -30.95),
                type: Coords.xy,
              ),
        ],
        def: '10.123,20.25',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25]}',
        wktLike: '10.123 20.25',
        wkt: 'POINT(10.123 20.25)',
      );
      _testAllWriters<GeometryContent>(
        [
          (output) => output.point(
                [10.123, 20.25],
                type: Coords.xyz,
              ),
          (output) => output.point(
                XY(10.123, 20.25),
                type: Coords.xyz,
              ),
        ],
        def: '10.123,20.25,0.0',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,0.0]}',
        wktLike: '10.123 20.25 0.0',
        wkt: 'POINT Z(10.123 20.25 0.0)',
      );
      _testAllWriters<GeometryContent>(
        [
          (output) => output.point(
                [10.123, 20.25, -1.999],
                type: Coords.xym,
              ),
          (output) => output.point(
                XYM(10.123, 20.25, -1.999),
                type: Coords.xym,
              ),
        ],
        def: '10.123,20.25,0,-1.999',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,0,-1.999]}',
        geoJsonStrict: '{"type":"Point","coordinates":[10.123,20.25]}',
        wktLike: '10.123 20.25 -1.999',
        wkt: 'POINT M(10.123 20.25 -1.999)',
      );
      _testAllWriters<GeometryContent>(
        [
          (output) => output.point(
                [10.123, 20.25, -30.95, -1.999],
                type: Coords.xyzm,
              ),
          (output) => output.point(
                XYZM(10.123, 20.25, -30.95, -1.999),
                type: Coords.xyzm,
              ),
        ],
        def: '10.123,20.25,-30.95,-1.999',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95,-1.999]}',
        geoJsonStrict: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95 -1.999',
        wkt: 'POINT ZM(10.123 20.25 -30.95 -1.999)',
      );
      _testAllWriters<GeometryContent>(
        [
          (output) => output.emptyGeometry(Geom.point),
        ],
        def: '',
        geoJson: '{"type":"Point","coordinates":[]}',
        wktLike: '',
        wkt: 'POINT EMPTY',
      );
    });
    test('MultiPoint geometry', () {
      _testAllWriters<GeometryContent>(
        [
          (output) => output.multiPoint(
                [
                  [10.123, 20.25],
                  [5.98, -3.47],
                ],
                type: Coords.xy,
              ),
          (output) => output.multiPoint(
                [
                  XY(10.123, 20.25),
                  XY(5.98, -3.47),
                ],
                type: Coords.xy,
              ),
        ],
        def: '[10.123,20.25],[5.98,-3.47]',
        geoJson:
            '{"type":"MultiPoint","coordinates":[[10.123,20.25],[5.98,-3.47]]}',
        wktLike: '10.123 20.25,5.98 -3.47',
        wkt: 'MULTIPOINT(10.123 20.25,5.98 -3.47)',
      );
    });
    test('LineString geometry', () {
      _testAllWriters<GeometryContent>(
        [
          (output) => output.lineString(
                [
                  -1.1,
                  -1.1,
                  2.1,
                  -2.5,
                  3.5,
                  -3.49,
                ],
                type: Coords.xy,
                bounds: [-1.1, -3.49, 3.5, -1.1].box,
              ),
        ],
        def: '[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]',
        geoJson: '{"type":"LineString",'
            '"bbox":[-1.1,-3.49,3.5,-1.1],'
            '"coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]}',
        wktLike: '-1.1 -1.1,2.1 -2.5,3.5 -3.49',
        wkt: 'LINESTRING(-1.1 -1.1,2.1 -2.5,3.5 -3.49)',
      );
      _testAllWriters<GeometryContent>(
        [
          (output) => output.lineString(
                [-1.1, -1.1, 0.0, 2.1, -2.5, 4.99, 3.5, -3.49, 0.0],
                type: Coords.xym,
                bounds: BoxCoords.view(
                  [-1.1, -3.49, 0.0, 3.5, -1.1, 4.99],
                  type: Coords.xym,
                ),
              ),
        ],
        def: '[-1.1,-1.1,0,0.0],[2.1,-2.5,0,4.99],[3.5,-3.49,0,0.0]',
        geoJson: '{"type":"LineString",'
            '"bbox":[-1.1,-3.49,0,0.0,3.5,-1.1,0,4.99],'
            '"coordinates":[[-1.1,-1.1,0,0.0],'
            '[2.1,-2.5,0,4.99],[3.5,-3.49,0,0.0]]}',
        geoJsonStrict: '{"type":"LineString",'
            '"bbox":[-1.1,-3.49,3.5,-1.1],'
            '"coordinates":[[-1.1,-1.1],'
            '[2.1,-2.5],[3.5,-3.49]]}',
        wktLike: '-1.1 -1.1 0.0,2.1 -2.5 4.99,3.5 -3.49 0.0',
        wkt: 'LINESTRING M(-1.1 -1.1 0.0,2.1 -2.5 4.99,3.5 -3.49 0.0)',
      );
      _testAllWriters<GeometryContent>(
        [
          (output) => output.lineString(
                [
                  // point 0:
                  -1.1,
                  -1.1,
                  0.0,
                  0.0,
                  // point 1:
                  2.1,
                  -2.5,
                  0.0,
                  4.99,
                  // point 2:
                  3.5,
                  -3.49,
                  -0.5,
                  0.0,
                ],
                type: Coords.xyzm,
                bounds: [-1.1, -3.49, -0.5, 0.0, 3.5, -1.1, 0.0, 4.99].box,
              ),
        ],
        def: '[-1.1,-1.1,0.0,0.0],[2.1,-2.5,0.0,4.99],[3.5,-3.49,-0.5,0.0]',
        geoJson: '{"type":"LineString",'
            '"bbox":[-1.1,-3.49,-0.5,0.0,3.5,-1.1,0.0,4.99],'
            '"coordinates":[[-1.1,-1.1,0.0,0.0],'
            '[2.1,-2.5,0.0,4.99],[3.5,-3.49,-0.5,0.0]]}',
        geoJsonStrict: '{"type":"LineString",'
            '"bbox":[-1.1,-3.49,-0.5,3.5,-1.1,0.0],'
            '"coordinates":[[-1.1,-1.1,0.0],'
            '[2.1,-2.5,0.0],[3.5,-3.49,-0.5]]}',
        wktLike: '-1.1 -1.1 0.0 0.0,2.1 -2.5 0.0 4.99,3.5 -3.49 -0.5 0.0',
        wkt:
            'LINESTRING ZM(-1.1 -1.1 0.0 0.0,2.1 -2.5 0.0 4.99,3.5 -3.49 -0.5 0.0)',
      );
    });
    test('MultiLineString geometry', () {
      _testAllWriters<GeometryContent>(
        [
          (output) => output.multiLineString(
                [
                  [-1.1, -1.1, 2.1, -2.5, 3.5, -3.49],
                  [38.19, 57.4, 43.9, 84.1],
                ],
                type: Coords.xy,
              ),
        ],
        def: '[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]],[[38.19,57.4],[43.9,84.1]]',
        geoJson: '{"type":"MultiLineString","coordinates":[[[-1.1,-1.1],'
            '[2.1,-2.5],[3.5,-3.49]],[[38.19,57.4],[43.9,84.1]]]}',
        wktLike: '(-1.1 -1.1,2.1 -2.5,3.5 -3.49),(38.19 57.4,43.9 84.1)',
        wkt: 'MULTILINESTRING((-1.1 -1.1,2.1 -2.5,3.5 -3.49),(38.19 '
            '57.4,43.9 84.1))',
      );
    });
    test('Polygon geometry', () {
      _testAllWriters<GeometryContent>(
        [
          (output) => output.polygon(
                [
                  [10.1, 10.1, 5, 9, 12, 4, 10.1, 10.1],
                ],
                type: Coords.xy,
              ),
        ],
        def: '[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]]',
        geoJson: '{"type":"Polygon",'
            '"coordinates":[[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]]]}',
        wktLike: '(10.1 10.1,5.0 9.0,12.0 4.0,10.1 10.1)',
        wkt: 'POLYGON((10.1 10.1,5.0 9.0,12.0 4.0,10.1 10.1))',
      );
    });
    test('MultiPolygon geometry', () {
      _testAllWriters<GeometryContent>(
        [
          (output) => output.multiPolygon(
                [
                  [
                    [10.1, 10.1, 5, 9, 12, 4, 10.1, 10.1],
                  ],
                ],
                type: Coords.xy,
              ),
        ],
        def: '[[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]]]',
        geoJson: '{"type":"MultiPolygon",'
            '"coordinates":[[[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]]]]}',
        wktLike: '((10.1 10.1,5.0 9.0,12.0 4.0,10.1 10.1))',
        wkt: 'MULTIPOLYGON(((10.1 10.1,5.0 9.0,12.0 4.0,10.1 10.1)))',
      );
    });
    test('GeometryCollection geometry', () {
      _testAllWriters<GeometryContent>(
        [
          (output) => output.geometryCollection(
                (geom) => geom
                  ..point([10.123, 20.25, -30.95], type: Coords.xyz)
                  ..polygon(
                    [
                      [10.1, 10.1, 5, 9, 12, 4, 10.1, 10.1],
                    ],
                    type: Coords.xy,
                  ),
              ),
        ],
        def:
            '[10.123,20.25,-30.95],[[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]]]',
        geoJson: '{"type":"GeometryCollection","geometries":[{"type":"Point",'
            '"coordinates":[10.123,20.25,-30.95]},{"type":"Polygon",'
            '"coordinates":[[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]]]}]}',
        wktLike:
            '(10.123 20.25 -30.95),((10.1 10.1,5.0 9.0,12.0 4.0,10.1 10.1))',
        wkt: 'GEOMETRYCOLLECTION(POINT Z(10.123 20.25 -30.95),POLYGON((10.1 '
            '10.1,5.0 9.0,12.0 4.0,10.1 10.1)))',
      );
    });
  });

  group('Test feature writers', () {
    test('Feature', () {
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.feature(
          id: 'fid-1',
          bounds: [-1.1, -3.49, -0.5, 0, 3.5, -1.1, 0, 4.99],
          geometry: (geom) => geom.lineString(
            [-1.1, -1.1, 0.0, 0.0, 2.1, -2.5, 0.0, 4.99, 3.5, -3.49, -0.5, 0.0],
            type: Coords.xyzm,
          ),
          properties: {
            'prop': 1,
          },
        ),
        geoJson:
            '{"type":"Feature","id":"fid-1","bbox":[-1.1,-3.49,-0.5,0.0,3.5,-1.1,0.0,4.99],"geometry":{"type":"LineString","coordinates":[[-1.1,-1.1,0.0,0.0],[2.1,-2.5,0.0,4.99],[3.5,-3.49,-0.5,0.0]]},"properties":{"prop":1}}',
        geoJsonStrict:
            '{"type":"Feature","id":"fid-1","bbox":[-1.1,-3.49,-0.5,3.5,-1.1,0.0],"geometry":{"type":"LineString","coordinates":[[-1.1,-1.1,0.0],[2.1,-2.5,0.0],[3.5,-3.49,-0.5]]},"properties":{"prop":1}}',
      );
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.feature(
          id: 'fid-1',
          geometry: (geom) => geom.point(XY(10.123, 20.25)),
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
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.feature(
          geometry: (geom) => geom.point(XY(10.123, 20.25)),
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
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.feature(
          geometry: (geom) => geom
            ..point(XY(10.123, 20.25))
            ..point(XYZM(1, 2, 3, 4), name: 'geom1'),
          custom: (props) => props.properties('extra', {
            'foo': {
              'bar': 'this is property value',
              'baz': [true, false],
            },
          }),
        ),
        geoJson: '{"type":"Feature",'
            '"geometry":{"type":"Point","coordinates":[10.123,20.25]},'
            '"geom1":{"type":"Point","coordinates":[1.0,2.0,3.0,4.0]},'
            '"properties":{},"extra":{"foo":{'
            '"bar":"this is property value","baz":[true,false]}}}',
        geoJsonStrict: '{"type":"Feature",'
            '"geometry":{"type":"Point","coordinates":[10.123,20.25]},'
            '"properties":{}}',
      );
    });
    test('FeatureCollection', () {
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.featureCollection(
          (features) => features
            ..feature(
              id: 'fid-1',
              geometry: (geom) => geom.point(XY(10.123, 20.25)),
              properties: {
                'foo': 100,
                'bar': 'this is property value',
              },
            )
            ..feature(
              geometry: (geom) => geom.lineString(
                [-1.1, -1.1, 2.1, -2.5, 3.5, -3.49],
                type: Coords.xy,
                bounds: [-1.1, -3.49, 3.5, -1.1],
              ),
            ),
          count: 2,
          bounds: [-1.1, -3.49, 10.123, 20.25],
        ),
        geoJson:
            '{"type":"FeatureCollection","bbox":[-1.1,-3.49,10.123,20.25],"features":[{"type":"Feature","id":"fid-1","geometry":{"type":"Point","coordinates":[10.123,20.25]},"properties":{"foo":100,"bar":"this is property value"}},{"type":"Feature","geometry":{"type":"LineString","bbox":[-1.1,-3.49,3.5,-1.1],"coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]},"properties":{}}]}',
      );
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.featureCollection((features) {}),
        geoJson: '{"type":"FeatureCollection","features":[]}',
      );
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.featureCollection(
          (features) {},
          custom: (props) => props.property('prop1', 'value1'),
        ),
        geoJson: '{"type":"FeatureCollection","features":[],"prop1":"value1"}',
        geoJsonStrict: '{"type":"FeatureCollection","features":[]}',
      );
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.featureCollection(
          (features) {},
          custom: (props) => props.properties('map1', {'prop1': 'value1'}),
        ),
        geoJson: '{"type":"FeatureCollection",'
            '"features":[],"map1":{"prop1":"value1"}}',
        geoJsonStrict: '{"type":"FeatureCollection","features":[]}',
      );
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.featureCollection(
          (features) => features.featureCollection((feat) {}),
        ),
        geoJson: '{"type":"FeatureCollection","features":[]}',
      );
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.featureCollection(
          (features) => features.feature(),
        ),
        geoJson: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","geometry":null,"properties":{}}]}',
      );
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.featureCollection(
          (features) => features
            ..feature()
            ..feature(),
        ),
        geoJson: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","geometry":null,"properties":{}},'
            '{"type":"Feature","geometry":null,"properties":{}}]}',
      );
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.featureCollection(
          (features) => features
            ..feature(custom: (props) => props.property('prop1', 'value1'))
            ..feature(
              custom: (props) => props.properties('map1', {'prop1': 'value1'}),
            ),
        ),
        geoJson: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","geometry":null,"properties":{},"prop1":"value1"},'
            '{"type":"Feature","geometry":null,"properties":{},"map1":{"prop1":"value1"}}]}',
        geoJsonStrict: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","geometry":null,"properties":{}},'
            '{"type":"Feature","geometry":null,"properties":{}}]}',
      );
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.featureCollection(
          count: 2,
          (features) => features
            ..feature(
              id: 1,
              properties: {'test1': 3},
              custom: (props) => props.property('p1', BigInt.one),
            )
            ..feature(
              id: '2',
              properties: {},
              custom: (props) => props.properties('map1', {'p2': 2}),
            ),
        ),
        geoJson: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","id":1,"geometry":null,"properties":{"test1":3},"p1":1},'
            '{"type":"Feature","id":"2","geometry":null,"properties":{},"map1":{"p2":2}}]}',
        geoJsonStrict: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","id":1,"geometry":null,"properties":{"test1":3}},'
            '{"type":"Feature","id":"2","geometry":null,"properties":{}}]}',
      );
      _testGeoJsonWriters<FeatureContent>(
        (output) => output.featureCollection(
          count: 2,
          (features) => features
            ..feature(
              geometry: (geom) => geom.point(XY(1, 2)),
              properties: {'test1': null},
            )
            ..feature(
              id: '2',
              geometry: (geom) => geom.emptyGeometry(Geom.point),
              properties: {},
            ),
        ),
        geoJson: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","geometry":{"type":"Point",'
            '"coordinates":[1.0,2.0]},"properties":{"test1":null}},'
            '{"type":"Feature","id":"2","geometry":null,"properties":{}}]}',
      );
    });
  });
}

void _testAllWriters<T>(
  Iterable<void Function(T output)> contents, {
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
  for (final content in contents) {
    _testWriterOfGeometryFormat<T>(
      DefaultFormat.coordinate,
      DefaultFormat.geometry,
      content,
      expected: def,
      decimals: defDecimals,
    );
    _testWriterOfGeometryFormat<T>(
      GeoJSON.coordinate,
      GeoJSON.geometry,
      content,
      expected: geoJson,
      decimals: geoJsonDecimals,
    );
    _testWriterOfGeometryFormat<T>(
      GeoJSON.coordinateFormat(
        conf: const GeoJsonConf(
          ignoreMeasured: true,
          ignoreForeignMembers: true,
        ),
      ),
      GeoJSON.geometryFormat(
        conf: const GeoJsonConf(
          ignoreMeasured: true,
          ignoreForeignMembers: true,
        ),
      ),
      content,
      expected: geoJsonStrict ?? geoJson,
      decimals: geoJsonDecimals,
    );
    _testWriterOfGeometryFormat<T>(
      WktLikeFormat.coordinate,
      WktLikeFormat.geometry,
      content,
      expected: wktLike,
      decimals: wktLikeDecimals,
    );
    _testWriterOfGeometryFormat<T>(
      WKT.coordinate,
      WKT.geometry,
      content,
      expected: wkt,
      decimals: wktDecimals,
    );
  }
}

void _testGeoJsonWriters<T>(
  void Function(T output) content, {
  required String geoJson,
  String? geoJsonStrict,
  int? decimals,
}) {
  _testWriterOfFeatureFormat<T>(
    GeoJSON.feature,
    content,
    expected: geoJson,
    decimals: decimals,
  );
  _testWriterOfFeatureFormat<T>(
    GeoJSON.featureFormat(
      conf: const GeoJsonConf(
        ignoreMeasured: true,
        ignoreForeignMembers: true,
      ),
    ),
    content,
    expected: geoJsonStrict ?? geoJson,
    decimals: decimals,
  );
}

void _testWriterOfGeometryFormat<T>(
  TextWriterFormat<CoordinateContent> coordinateFormat,
  TextWriterFormat<GeometryContent> geometryFormat,
  void Function(T output) content, {
  required String expected,
  int? decimals,
}) {
  if (T == CoordinateContent) {
    final encoder = coordinateFormat.encoder(decimals: decimals);
    content(encoder.writer as T);
    expect(encoder.toText(), expected);
  } else {
    assert(T == GeometryContent, 'expecting geometry writer');
    final encoder = geometryFormat.encoder(decimals: decimals);
    content(encoder.writer as T);
    expect(encoder.toText(), expected);
  }
}

void _testWriterOfFeatureFormat<T>(
  TextWriterFormat<FeatureContent> format,
  void Function(T output) content, {
  required String expected,
  int? decimals,
}) {
  if (T == FeatureContent) {
    final encoder = format.encoder(decimals: decimals);
    content(encoder.writer as T);
    expect(encoder.toText(), expected);
  } else {
    throw UnimplementedError('no geometry format supported here');
  }
}
