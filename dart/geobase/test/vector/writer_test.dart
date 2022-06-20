// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector.dart';

import 'package:test/test.dart';

void main() {
  group('Test geometry, coordinate and bounds writers', () {
    test('Position coordinates', () {
      _testAllWriters<CoordinateWriter>(
        (writer) => writer.position(const Projected(x: 10.123, y: 20.25)),
        def: '10.123,20.25',
        geoJson: '10.123,20.25',
        wktLike: '10.123 20.25',
        wkt: '10.123 20.25',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) =>
            writer.position(const Projected(x: 10.123, y: 20.25, z: -30.95)),
        def: '10.123,20.25,-30.95',
        geoJson: '10.123,20.25,-30.95',
        wktLike: '10.123 20.25 -30.95',
        wkt: '10.123 20.25 -30.95',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) =>
            writer.position(const Projected(x: 10.123, y: 20.25, m: -1.999)),
        def: '10.123,20.25,0,-1.999',
        geoJson: '10.123,20.25,0,-1.999',
        geoJsonStrict: '10.123,20.25',
        wktLike: '10.123 20.25 0 -1.999',
        wkt: '10.123 20.25 0 -1.999',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) => writer.position(
          const Projected(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
        ),
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
    test('GeoPosition coordinates', () {
      _testAllWriters<CoordinateWriter>(
        (writer) => writer.position(
          const Geographic(lon: 10.123, lat: 20.25, elev: -30.95, m: -1.999),
        ),
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
      _testAllWriters<CoordinateWriter>(
        (writer) => writer.box(
          const ProjBox(
            minX: 10.123,
            minY: 20.25,
            maxX: 12.485,
            maxY: 25.195,
          ),
        ),
        def: '10.123,20.25,12.485,25.195',
        geoJson: '10.123,20.25,12.485,25.195',
        wktLike: '10.123 20.25,12.485 25.195',
        wkt: 'POLYGON((10.123 20.25,12.485 20.25,12.485 25.195,10.123 '
            '25.195,10.123 20.25))',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) => writer.box(
          const ProjBox(
            minX: 10.123,
            minY: 20.25,
            minZ: -15.09,
            maxX: 12.485,
            maxY: 25.195,
            maxZ: -14.949,
          ),
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
    test('GeoBox coordinates', () {
      _testAllWriters<CoordinateWriter>(
        (writer) => writer.box(
          const GeoBox(
            west: 10.123,
            south: 20.25,
            minElev: -15.09,
            east: 12.485,
            north: 25.195,
            maxElev: -14.949,
          ),
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
        (writer) => writer.positions1D([
          const Projected(x: 10.123, y: 20.25),
          const Projected(x: 10.123, y: 20.25, z: -30.95),
          const Projected(x: 10.123, y: 20.25, m: -1.999),
        ]),
        def: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25,0,-1.999]',
        geoJson: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25,0,-1.999]',
        geoJsonStrict: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25]',
        wktLike: '10.123 20.25,10.123 20.25 -30.95,10.123 20.25 0 -1.999',
        wkt: '10.123 20.25,10.123 20.25 -30.95,10.123 20.25 0 -1.999',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) => writer.positions1D([
          const Projected(x: 10.123, y: 20.25),
          const Projected(x: 10.123, y: 20.25, m: -1.999),
          const Projected(x: 10.123, y: 20.25, z: -30.95),
        ]),
        def: '[10.123,20.25],[10.123,20.25,0,-1.999],[10.123,20.25,-30.95]',
        geoJson: '[10.123,20.25],[10.123,20.25,0,-1.999],[10.123,20.25,-30.95]',
        geoJsonStrict: '[10.123,20.25],[10.123,20.25],[10.123,20.25,-30.95]',
        wktLike: '10.123 20.25,10.123 20.25 0 -1.999,10.123 20.25 -30.95',
        wkt: '10.123 20.25,10.123 20.25 0 -1.999,10.123 20.25 -30.95',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) => writer.positions1D([
          const Projected(x: 10.123, y: 20.25),
          const Projected(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
          const Projected(x: 10.123, y: 20.25),
        ]),
        def: '[10.123,20.25],[10.123,20.25,-30.95,-1.999],[10.123,20.25]',
        geoJson: '[10.123,20.25],[10.123,20.25,-30.95,-1.999],[10.123,20.25]',
        geoJsonStrict: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25]',
        wktLike: '10.123 20.25,10.123 20.25 -30.95 -1.999,10.123 20.25',
        wkt: '10.123 20.25,10.123 20.25 -30.95 -1.999,10.123 20.25',
      );
      _testAllWriters<CoordinateWriter>(
        (writer) => writer.positions1D([
          const Projected(x: 10, y: 20),
          const Projected(x: 11, y: 21, z: -30.95, m: -1.1),
          const Projected(x: 12, y: 22, m: 2.2),
          const Projected(x: 13, y: 23, z: 49.1),
        ]),
        def: '[10,20],[11,21,-30.95,-1.1],[12,22,0,2.2],[13,23,49.1]',
        geoJson: '[10,20],[11,21,-30.95,-1.1],[12,22,0,2.2],[13,23,49.1]',
        geoJsonStrict: '[10,20],[11,21,-30.95],[12,22],[13,23,49.1]',
        wktLike: '10 20,11 21 -30.95 -1.1,12 22 0 2.2,13 23 49.1',
        wkt: '10 20,11 21 -30.95 -1.1,12 22 0 2.2,13 23 49.1',
      );
    });
    test('Point geometry', () {
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryWithPosition(
          type: Geom.point,
          coordinates: const Projected(x: 10.123, y: 20.25),
        ),
        def: '10.123,20.25',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25]}',
        wktLike: '10.123 20.25',
        wkt: 'POINT(10.123 20.25)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryWithPosition(
          type: Geom.point,
          coordinates: const Projected(x: 10.123, y: 20.25, z: -30.95),
        ),
        def: '10.123,20.25,-30.95',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95',
        wkt: 'POINT(10.123 20.25 -30.95)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryWithPosition(
          type: Geom.point,
          coordinates: const Projected(x: 10.123, y: 20.25, m: -1.999),
        ),
        def: '10.123,20.25,0,-1.999',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,0,-1.999]}',
        geoJsonStrict: '{"type":"Point","coordinates":[10.123,20.25]}',
        wktLike: '10.123 20.25 0 -1.999',
        wkt: 'POINT(10.123 20.25 0 -1.999)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryWithPosition(
          type: Geom.point,
          coordinates:
              const Projected(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
        ),
        def: '10.123,20.25,-30.95,-1.999',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95,-1.999]}',
        geoJsonStrict: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95 -1.999',
        wkt: 'POINT(10.123 20.25 -30.95 -1.999)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryWithPosition(
          type: Geom.point,
          coordinates: const Projected(x: 10.123, y: 20.25, z: -30.95),
          coordType: Coords.xyz,
        ),
        def: '10.123,20.25,-30.95',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95',
        wkt: 'POINT Z(10.123 20.25 -30.95)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryWithPosition(
          type: Geom.point,
          coordinates:
              const Projected(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
          coordType: Coords.xyz,
        ),
        def: '10.123,20.25,-30.95',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,-30.95]}',
        wktLike: '10.123 20.25 -30.95',
        wkt: 'POINT Z(10.123 20.25 -30.95)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryWithPosition(
          type: Geom.point,
          coordinates: const Projected(x: 10.123, y: 20.25, z: -30.95),
          coordType: Coords.xy,
        ),
        def: '10.123,20.25',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25]}',
        wktLike: '10.123 20.25',
        wkt: 'POINT(10.123 20.25)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryWithPosition(
          type: Geom.point,
          coordinates: const Projected(x: 10.123, y: 20.25),
          coordType: Coords.xyz,
        ),
        def: '10.123,20.25,0',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,0]}',
        wktLike: '10.123 20.25 0',
        wkt: 'POINT Z(10.123 20.25 0)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryWithPosition(
          type: Geom.point,
          coordinates:
              const Projected(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
          coordType: Coords.xym,
        ),
        def: '10.123,20.25,0,-1.999',
        geoJson: '{"type":"Point","coordinates":[10.123,20.25,0,-1.999]}',
        geoJsonStrict: '{"type":"Point","coordinates":[10.123,20.25]}',
        wktLike: '10.123 20.25 -1.999',
        wkt: 'POINT M(10.123 20.25 -1.999)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryWithPosition(
          type: Geom.point,
          coordinates:
              const Projected(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
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
        (writer) => writer.geometryWithPositions1D(
          type: Geom.multiPoint,
          coordinates: [
            const Projected(x: 10.123, y: 20.25),
            const Projected(x: 5.98, y: -3.47),
          ],
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
        (writer) => writer.geometryWithPositions1D(
          type: Geom.lineString,
          bbox: const ProjBox(minX: -1.1, minY: -3.49, maxX: 3.5, maxY: -1.1),
          coordinates: [
            const Projected(x: -1.1, y: -1.1),
            const Projected(x: 2.1, y: -2.5),
            const Projected(x: 3.5, y: -3.49),
          ],
        ),
        def: '[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]',
        geoJson: '{"type":"LineString",'
            '"bbox":[-1.1,-3.49,3.5,-1.1],'
            '"coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]}',
        wktLike: '-1.1 -1.1,2.1 -2.5,3.5 -3.49',
        wkt: 'LINESTRING(-1.1 -1.1,2.1 -2.5,3.5 -3.49)',
      );
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryWithPositions1D(
          type: Geom.lineString,
          coordType: Coords.xym,
          bbox: const ProjBox(
            minX: -1.1,
            minY: -3.49,
            minM: 0,
            maxX: 3.5,
            maxY: -1.1,
            maxM: 4.99,
          ),
          coordinates: [
            const Projected(x: -1.1, y: -1.1),
            const Projected(x: 2.1, y: -2.5, m: 4.99),
            const Projected(x: 3.5, y: -3.49, z: -0.5),
          ],
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
        (writer) => writer.geometryWithPositions1D(
          type: Geom.lineString,
          coordType: Coords.xyzm,
          bbox: const ProjBox(
            minX: -1.1,
            minY: -3.49,
            minZ: -0.5,
            minM: 0,
            maxX: 3.5,
            maxY: -1.1,
            maxZ: 0,
            maxM: 4.99,
          ),
          coordinates: [
            const Projected(x: -1.1, y: -1.1),
            const Projected(x: 2.1, y: -2.5, m: 4.99),
            const Projected(x: 3.5, y: -3.49, z: -0.5),
          ],
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
        (writer) => writer.geometryWithPositions2D(
          type: Geom.multiLineString,
          coordinates: [
            [
              const Projected(x: -1.1, y: -1.1),
              const Projected(x: 2.1, y: -2.5),
              const Projected(x: 3.5, y: -3.49),
            ],
            [
              const Projected(x: 38.19, y: 57.4),
              const Projected(x: 43.9, y: 84.1),
            ],
          ],
        ),
        def: '[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]],[[38.19,57.4],[43.9,84.1]]',
        geoJson: '{"type":"MultiLineString","coordinates":[[[-1.1,-1.1],'
            '[2.1,-2.5],[3.5,-3.49]],[[38.19,57.4],[43.9,84.1]]]}',
        wktLike: '(-1.1 -1.1,2.1 -2.5,3.5 -3.49),(38.19 57.4,43.9 84.1)',
        wkt: 'MULTILINESTRING((-1.1 -1.1,2.1 -2.5,3.5 -3.49),(38.19 '
            '57.4,43.9 84.1))',
      );
    });
    test('Polygon geometry', () {
      _testAllWriters<GeometryWriter>(
        (writer) => writer.geometryWithPositions2D(
          type: Geom.polygon,
          coordinates: [
            [
              const Projected(x: 10.1, y: 10.1),
              const Projected(x: 5, y: 9),
              const Projected(x: 12, y: 4),
              const Projected(x: 10.1, y: 10.1)
            ],
          ],
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
        (writer) => writer.geometryWithPositions3D(
          type: Geom.multiPolygon,
          coordinates: [
            [
              [
                const Projected(x: 10.1, y: 10.1),
                const Projected(x: 5, y: 9),
                const Projected(x: 12, y: 4),
                const Projected(x: 10.1, y: 10.1)
              ],
            ],
          ],
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
            ..geometryWithPosition(
              type: Geom.point,
              coordinates: const Projected(x: 10.123, y: 20.25, z: -30.95),
              coordType: Coords.xyz,
            )
            ..geometryWithPositions2D(
              type: Geom.polygon,
              coordinates: [
                [
                  const Projected(x: 10.1, y: 10.1),
                  const Projected(x: 5, y: 9),
                  const Projected(x: 12, y: 4),
                  const Projected(x: 10.1, y: 10.1)
                ],
              ],
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
          bbox: const ProjBox(
            minX: -1.1,
            minY: -3.49,
            minZ: -0.5,
            minM: 0,
            maxX: 3.5,
            maxY: -1.1,
            maxZ: 0,
            maxM: 4.99,
          ),
          geometries: (gw) => gw.geometryWithPositions1D(
            type: Geom.lineString,
            coordType: Coords.xyzm,
            coordinates: [
              const Projected(x: -1.1, y: -1.1),
              const Projected(x: 2.1, y: -2.5, m: 4.99),
              const Projected(x: 3.5, y: -3.49, z: -0.5),
            ],
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
          geometries: (gw) => gw.geometryWithPosition(
            type: Geom.point,
            coordinates: const Projected(x: 10.123, y: 20.25),
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
          geometries: (gw) => gw.geometryWithPosition(
            type: Geom.point,
            coordinates: const Projected(x: 10.123, y: 20.25),
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
              ..geometryWithPosition(
                type: Geom.point,
                coordinates: const Projected(x: 10.123, y: 20.25),
              )
              ..geometryWithPosition(
                name: 'geom1',
                type: Geom.point,
                coordinates: const Projected(x: 1, y: 2, z: 3, m: 4),
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
            '"properties":{},"extra":{"foo":{'
            '"bar":"this is property value","baz":[true,false]}}}',
        geoJsonStrict: '{"type":"Feature",'
            '"geometry":{"type":"Point","coordinates":[10.123,20.25]},'
            '"properties":{}}',
      );
    });
    test('FeatureCollection', () {
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.featureCollection(
          bbox: const ProjBox(
            minX: -1.1,
            minY: -3.49,
            maxX: 10.123,
            maxY: 20.25,
          ),
          features: (fw) => fw
            ..feature(
              id: 'fid-1',
              geometries: (gw) => gw.geometryWithPosition(
                type: Geom.point,
                coordinates: const Projected(x: 10.123, y: 20.25),
              ),
              properties: {
                'foo': 100,
                'bar': 'this is property value',
              },
            )
            ..feature(
              geometries: (gw) => gw.geometryWithPositions1D(
                type: Geom.lineString,
                bbox: const ProjBox(
                  minX: -1.1,
                  minY: -3.49,
                  maxX: 3.5,
                  maxY: -1.1,
                ),
                coordinates: [
                  const Projected(x: -1.1, y: -1.1),
                  const Projected(x: 2.1, y: -2.5),
                  const Projected(x: 3.5, y: -3.49),
                ],
              ),
            ),
        ),
        geoJson:
            '{"type":"FeatureCollection","bbox":[-1.1,-3.49,10.123,20.25],"features":[{"type":"Feature","id":"fid-1","geometry":{"type":"Point","coordinates":[10.123,20.25]},"properties":{"foo":100,"bar":"this is property value"}},{"type":"Feature","geometry":{"type":"LineString","bbox":[-1.1,-3.49,3.5,-1.1],"coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]},"properties":{}}]}',
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
            '[{"type":"Feature","properties":{}}]}',
      );
      _testGeoJsonWriters<FeatureWriter>(
        (writer) => writer.featureCollection(
          features: (fw) => fw
            ..feature()
            ..feature(),
        ),
        geoJson: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","properties":{}},'
            '{"type":"Feature","properties":{}}]}',
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
            '[{"type":"Feature","properties":{},"prop1":"value1"},'
            '{"type":"Feature","properties":{},"map1":{"prop1":"value1"}}]}',
        geoJsonStrict: '{"type":"FeatureCollection","features":'
            '[{"type":"Feature","properties":{}},'
            '{"type":"Feature","properties":{}}]}',
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
              geometries: (gw) => gw.geometryWithPosition(
                type: Geom.point,
                coordinates: const Projected(x: 1, y: 2),
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
    GeoJSON(),
    content,
    expected: geoJson,
    decimals: geoJsonDecimals,
  );
  _testWriterOfGeometryFormat<T>(
    GeoJSON(ignoreMeasured: true, ignoreForeignMembers: true),
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
    WKT(),
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
    GeoJSON(),
    content,
    expected: geoJson,
    decimals: decimals,
  );
  _testWriterOfFeatureFormat<T>(
    GeoJSON(ignoreMeasured: true, ignoreForeignMembers: true),
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
  if (T == CoordinateWriter) {
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
