// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geocore/aspects.dart';

import 'package:test/test.dart';

void main() {
  group('Test aspects/writer', () {
    test('Point coordinates', () {
      _testAllWriters(
        (writer) => writer.coordPoint(x: 10.123, y: 20.25),
        def: '10.123,20.25',
        wktLike: '10.123 20.25',
      );
      _testAllWriters(
        (writer) =>
            writer.coordPoint(x: 10.123, y: 20.25, z: -30.95, m: -1.999),
        def: '10.1,20.3,-30.9,-2.0',
        wktLike: '10.123 20.250 -30.950 -1.999',
        defDecimals: 1,
        wktLikeDecimals: 3,
      );
    });
    test('Bounds coordinates', () {
      _testAllWriters(
        (writer) => writer.coordBounds(
          minX: 10.123,
          minY: 20.25,
          maxX: 12.485,
          maxY: 25.195,
        ),
        def: '10.123,20.25,12.485,25.195',
        wktLike: '10.123 20.25,12.485 25.195',
      );
      _testAllWriters(
        (writer) => writer.coordBounds(
          minX: 10.123,
          minY: 20.25,
          minZ: -15.09,
          maxX: 12.485,
          maxY: 25.195,
          maxZ: -14.949,
        ),
        def: '10.12,20.25,-15.09,12.48,25.20,-14.95',
        wktLike: '10 20 -15,12 25 -15',
        defDecimals: 2,
        wktLikeDecimals: 0,
      );
    });
    test('PointSeries coordinates', () {
      _testAllWriters(
        (writer) => writer
          ..coordArray()
          ..coordPoint(x: 10.123, y: 20.25)
          ..coordPoint(x: 10.123, y: 20.25, z: -30.95)
          ..coordPoint(x: 10.123, y: 20.25, m: -1.999)
          ..coordArrayEnd(),
        def: '[10.123,20.25],[10.123,20.25,-30.95],[10.123,20.25,-1.999]',
        wktLike: '10.123 20.25,10.123 20.25 -30.95,10.123 20.25 -1.999',
      );
    });
    test('Point geometry', () {
      _testAllWriters(
        (writer) => writer
          ..geometry(Geom.point)
          ..coordPoint(x: 10.123, y: 20.25)
          ..geometryEnd(),
        def: '10.123,20.25',
        wktLike: '10.123 20.25',
      );
    });
    test('MultiPoint geometry', () {
      _testAllWriters(
        (writer) => writer
          ..geometry(Geom.multiPoint)
          ..coordArray()
          ..coordPoint(x: 10.123, y: 20.25)
          ..coordPoint(x: 5.98, y: -3.47)
          ..coordArrayEnd()
          ..geometryEnd(),
        def: '[10.123,20.25],[5.98,-3.47]',
        wktLike: '10.123 20.25,5.98 -3.47',
      );
    });
    test('LineString geometry', () {
      _testAllWriters(
        (writer) => writer
          ..geometry(Geom.lineString)
          ..coordArray()
          ..coordPoint(x: -1.1, y: -1.1)
          ..coordPoint(x: 2.1, y: -2.5)
          ..coordPoint(x: 3.5, y: -3.49)
          ..coordArrayEnd()
          ..geometryEnd(),
        def: '[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]',
        wktLike: '-1.1 -1.1,2.1 -2.5,3.5 -3.49',
      );
    });
    test('MultiLineString geometry', () {
      _testAllWriters(
        (writer) => writer
          ..geometry(Geom.multiLineString)
          ..coordArray()
          ..coordArray()
          ..coordPoint(x: -1.1, y: -1.1)
          ..coordPoint(x: 2.1, y: -2.5)
          ..coordPoint(x: 3.5, y: -3.49)
          ..coordArrayEnd()
          ..coordArray()
          ..coordPoint(x: 38.19, y: 57.4)
          ..coordArrayEnd()
          ..coordArrayEnd()
          ..geometryEnd(),
        def: '[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]],[[38.19,57.4]]',
        wktLike: '(-1.1 -1.1,2.1 -2.5,3.5 -3.49),(38.19 57.4)',
      );
    });
    test('Polygon geometry', () {
      _testAllWriters(
        (writer) => writer
          ..geometry(Geom.polygon)
          ..coordArray()
          ..coordArray()
          ..coordPoint(x: 10.1, y: 10.1)
          ..coordPoint(x: 5, y: 9)
          ..coordPoint(x: 12, y: 4)
          ..coordPoint(x: 10.1, y: 10.1)
          ..coordArrayEnd()
          ..coordArrayEnd()
          ..geometryEnd(),
        def: '[[10.1,10.1],[5,9],[12,4],[10.1,10.1]]',
        wktLike: '(10.1 10.1,5 9,12 4,10.1 10.1)',
      );
    });
    test('MultiPolygon geometry', () {
      _testAllWriters(
        (writer) => writer
          ..geometry(Geom.multiPolygon)
          ..coordArray()
          ..coordArray()
          ..coordArray()
          ..coordPoint(x: 10.1, y: 10.1)
          ..coordPoint(x: 5, y: 9)
          ..coordPoint(x: 12, y: 4)
          ..coordPoint(x: 10.1, y: 10.1)
          ..coordArrayEnd()
          ..coordArrayEnd()
          ..coordArrayEnd()
          ..geometryEnd(),
        def: '[[[10.1,10.1],[5,9],[12,4],[10.1,10.1]]]',
        wktLike: '((10.1 10.1,5 9,12 4,10.1 10.1))',
      );
    });
    test('GeometryCollection geometry', () {
      _testAllWriters(
        (writer) => writer
          ..geometry(Geom.geometryCollection)
          ..boundedArray()
          ..geometry(Geom.point)
          ..coordPoint(x: 10.123, y: 20.25)
          ..geometryEnd()
          ..geometry(Geom.polygon)
          ..coordArray() 
          ..coordArray()
          ..coordPoint(x: 10.1, y: 10.1)
          ..coordPoint(x: 5, y: 9)
          ..coordPoint(x: 12, y: 4)
          ..coordPoint(x: 10.1, y: 10.1)
          ..coordArrayEnd()
          ..coordArrayEnd()
          ..geometryEnd()
          ..boundedArrayEnd()
          ..geometryEnd(),
        def: '[10.123,20.25],[[[10.1,10.1],[5,9],[12,4],[10.1,10.1]]]',
        wktLike: '(10.123 20.25),((10.1 10.1,5 9,12 4,10.1 10.1))',
//        def: '[[[10.1,10.1],[5,9],[12,4],[10.1,10.1]]]',
//        wktLike: '((10.1 10.1,5 9,12 4,10.1 10.1))',
 //       def: '[10.123,20.25],[[[10.1,10.1],[5,9],[12,4],[10.1,10.1]]]',
 //       wktLike: '(10.123 20.25),((10.1 10.1,5 9,12 4,10.1 10.1))',
      );
    });
  });
}

void _testAllWriters(
  void Function(CoordinateWriter writer) content, {
  required String def,
  required String wktLike,
  int? defDecimals,
  int? wktLikeDecimals,
}) {
  _testWriter(defaultFormat, content, expected: def, decimals: defDecimals);
  _testWriter(
    wktLikeFormat,
    content,
    expected: wktLike,
    decimals: wktLikeDecimals,
  );
}

void _testWriter(
  CoordinateFormat format,
  void Function(CoordinateWriter writer) content, {
  required String expected,
  int? decimals,
}) {
  final writer = format.text(decimals: decimals);
  content(writer);
  expect(writer.toString(), expected);
}
