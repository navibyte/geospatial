// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';
import 'dart:typed_data';

import 'package:geobase/coordinates.dart';
import 'package:geobase/src/utils/byte_writer.dart';
import 'package:geobase/vector.dart';

import 'package:test/test.dart';

void main() {
  group('Test WKB encoding and decoding', () {
    final endians = [Endian.big, Endian.little];

    for (final endian in endians) {
      test('Basic sample for endian: $endian', () {
        // sample from https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary
        _testEncodeToBytes(
          endian,
          (bytes) => bytes
            ..writeUint32(1, endian) // POINT(2D)
            ..writeFloat64(2.0, endian) // x
            ..writeFloat64(4.0, endian), // y
          [
            // three different ways to write POINT(2.0 4.0)
            (writer) => writer.point([2.0, 4.0].xy),
            (writer) => writer.point(const Geographic(lon: 2.0, lat: 4.0)),
            (writer) => writer.point([2.0, 4.0].xy)
          ],
        );

        // empty point as POINT(NaN NaN)
        _testEncodeToBytes(
          endian,
          (bytes) => bytes
            ..writeUint32(1, endian) // POINT(2D)
            ..writeFloat64(-double.nan, endian) // x
            ..writeFloat64(-double.nan, endian), // y
          [
            // four different ways to write empty point
            (writer) => writer.point([double.nan, double.nan].xy),
            (writer) => writer.point(
                  const Geographic(lon: double.nan, lat: double.nan),
                ),
            (writer) => writer.point([double.nan, double.nan].xy),
            (writer) => writer.emptyGeometry(Geom.point),
          ],
        );
      });

      test('Geometry WKB encode/decode + WKT encode for endian: $endian', () {
        _testEncodeAndDecodeToWKT(
          endian,
          'POINT(2.1 -3.4)',
          [
            // three different ways to write POINT(2.1 -3.4)
            (writer) => writer.point([2.1, -3.4].xy),
            (writer) => writer.point(const Geographic(lon: 2.1, lat: -3.4)),
            (writer) => writer.point([2.1, -3.4].xy)
          ],
        );

        _testEncodeAndDecodeToWKT(
          endian,
          'POINT Z(2.1 -3.4 34.2)',
          [
            (writer) => writer.point([2.1, -3.4, 34.2].xyz)
          ],
        );

        _testEncodeAndDecodeToWKT(
          endian,
          'POINT M(2.1 -3.4 0.2)',
          [
            (writer) => writer.point([2.1, -3.4, 0.2].xym)
          ],
        );

        _testEncodeAndDecodeToWKT(
          endian,
          'POINT ZM(2.1 -3.4 34.2 0.2)',
          [
            (writer) => writer.point([2.1, -3.4, 34.2, 0.2].position)
          ],
        );

        _testEncodeAndDecodeToWKT(
          endian,
          'POINT(1.0 1.0),POINT(2.0 2.0)',
          [
            (writer) => writer
              ..point([1.0, 1.0].xy)
              ..point([2.0, 2.0].xy)
          ],
        );

        final points = [
          [1.0, 1.0].xy,
          [2.0, 2.0].xy
        ];
        final pointsFlat = [1.0, 1.0, 2.0, 2.0].positions();
        _testEncodeAndDecodeToWKT(
          endian,
          'LINESTRING(1.0 1.0,2.0 2.0),MULTIPOINT(1.0 1.0,2.0 2.0)',
          [
            (writer) => writer
              ..lineString(pointsFlat)
              ..multiPoint(points)
          ],
        );

        _testEncodeAndDecodeToWKT(
          endian,
          'LINESTRING EMPTY',
          [
            (writer) => writer.lineString(PositionSeries.empty()),
            (writer) => writer.emptyGeometry(Geom.lineString),
          ],
        );

        final linestringsFlat = [
          [10.1, 10.1, 5.0, 9.0, 12.0, 4.0, 10.1, 10.1].positions(),
        ];
        _testEncodeAndDecodeToWKT(
          endian,
          'POLYGON((10.1 10.1,5.0 9.0,12.0 4.0,10.1 10.1))',
          [(writer) => writer.polygon(linestringsFlat)],
        );
        _testEncodeAndDecodeToWKT(
          endian,
          'MULTILINESTRING((10.1 10.1,5.0 9.0,12.0 4.0,10.1 10.1))',
          [(writer) => writer.multiLineString(linestringsFlat)],
        );

        final multiPolygons = [linestringsFlat, linestringsFlat];
        _testEncodeAndDecodeToWKT(
          endian,
          'MULTIPOLYGON(((10.1 10.1,5.0 9.0,12.0 4.0,10.1 '
          '10.1)),((10.1 10.1,5.0 9.0,12.0 4.0,10.1 10.1)))',
          [(writer) => writer.multiPolygon(multiPolygons)],
        );

        _testEncodeAndDecodeToWKT(
          endian,
          'GEOMETRYCOLLECTION(LINESTRING(1.0 1.0,2.0 2.0),MULTIPOINT(1.0 '
          '1.0,2.0 2.0),POINT(2.1 -3.4))',
          [
            (writer) => writer.geometryCollection(
                  (geom) => geom
                    ..lineString(pointsFlat)
                    ..multiPoint(points)
                    ..point([2.1, -3.4].xy),
                )
          ],
        );
      });
    }

    test('Base64 samples in little endian', () {
      expect(double.nan.isNaN, true);
      expect((-double.nan).isNaN, true);

      // https://trac.osgeo.org/geos/ticket/1005
      // https://github.com/OSGeo/gdal/issues/2472
      _testEncodeToBytesBase64(
        Endian.little,
        'AQEAAAAAAAAAAAD4fwAAAAAAAPh/',
        // hex: 0101000000000000000000F87F000000000000F87F
        //   IEEE specifies NaN in float64 as (big endian) 7ff80000 00000000
        //   in Dart it seems that (using ByteData) need to write `-double.nan`
        //   this is handled by wkb encoder / byte writer util....
        'POINT EMPTY',
        [
          (writer) => writer.emptyGeometry(Geom.point),
          (writer) => writer.point([double.nan, double.nan].xy),
          (writer) => writer.point([-double.nan, -double.nan].xy),
        ],
      );

      _testEncodeToBytesBase64(
        Endian.little,
        'AQMAAAACAAAABQAAAAAAAAAAgEFAAAAAAAAAJEAAAAAAAIBGQAAAAAAAgEZAAAAAAAAALkAAAAAAAABEQAAAAAAAACRAAAAAAAAANEAAAAAAAIBBQAAAAAAAACRABAAAAAAAAAAAADRAAAAAAAAAPkAAAAAAAIBBQAAAAAAAgEFAAAAAAAAAPkAAAAAAAAA0QAAAAAAAADRAAAAAAAAAPkA=',
        // hex: 0103000000020000000500000000000000008041400000000000002440000000000080464000000000008046400000000000002E40000000000000444000000000000024400000000000003440000000000080414000000000000024400400000000000000000034400000000000003E40000000000080414000000000008041400000000000003E40000000000000344000000000000034400000000000003E40
        'POLYGON((35 10,45 45,15 40,10 20,35 10),(20 30,35 35,30 20,20 30))',
        [
          (writer) => writer.polygon([
                <double>[35, 10, 45, 45, 15, 40, 10, 20, 35, 10].positions(),
                <double>[20, 30, 35, 35, 30, 20, 20, 30].positions(),
              ]),
        ],
      );

      _testEncodeToBytesBase64(
        Endian.little,
        'AQcAAAADAAAAAQQAAAACAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAADwPwAAAAAAAPA/AQEAAAAAAAAAAAAIQAAAAAAAABBAAQIAAAACAAAAAAAAAAAAAEAAAAAAAAAIQAAAAAAAAAhAAAAAAAAAEEA=',
        // hex: 0107000000030000000104000000020000000101000000000000000000000000000000000000000101000000000000000000f03f000000000000f03f0101000000000000000000084000000000000010400102000000020000000000000000000040000000000000084000000000000008400000000000001040
        'GEOMETRYCOLLECTION(MULTIPOINT(0 0,1 1),POINT(3 4),LINESTRING(2 3,3 4))',
        [
          (writer) => writer
            ..geometryCollection(
              (geom) => geom
                ..multiPoint(
                  [
                    [0.0, 0.0].xy,
                    [1.0, 1.0].xy
                  ],
                )
                ..point([3.0, 4.0].xy)
                ..lineString([2.0, 3.0, 3.0, 4.0].positions()),
            ),
        ],
      );
    });
  });
}

void _testEncodeToBytes(
  Endian endian,
  void Function(ByteWriter) writeBytes,
  Iterable<WriteGeometries> writeGeometriesArray,
) {
  for (final writeGeometries in writeGeometriesArray) {
    // write bytes directly to a byte buffer
    final buffer = ByteWriter.buffered()
      ..writeInt8(endian == Endian.big ? 0 : 1);
    writeBytes.call(buffer);

    // write geometry content using WKB encoder
    final encoder = WKB.geometry.encoder(endian: endian);
    writeGeometries.call(encoder.writer);

    // test
    expect(encoder.toBytes(), buffer.toBytes());
  }
}

void _testEncodeToBytesBase64(
  Endian endian,
  String bytesBase64,
  String wktTextDecimals0,
  Iterable<WriteGeometries> writeGeometriesArray,
) {
  for (final writeGeometries in writeGeometriesArray) {
    // bytes from base64
    final testBytes = base64.decode(bytesBase64);

    // write geometry content using WKB encoder
    final encoder = WKB.geometry.encoder(endian: endian);
    writeGeometries.call(encoder.writer);
    final wkbBytes = encoder.toBytes();

    // test against bytes from base64 string
    expect(wkbBytes, testBytes);

    // decode bytes, and build WKT string that are tested
    final wktEncoder = WKT.geometry.encoder(decimals: 0);
    WKB.geometry.decoder(wktEncoder.writer).decodeBytes(wkbBytes);

    // test
    expect(wktEncoder.toText(), wktTextDecimals0);
  }
}

void _testEncodeAndDecodeToWKT(
  Endian endian,
  String wktText,
  Iterable<WriteGeometries> writeGeometriesArray, {
  Map<String, dynamic>? wkbOptions,
}) {
  for (final writeGeometries in writeGeometriesArray) {
    // wkb format
    const format = WKB.geometry;

    // write geometry content using WKB encoder
    final encoder = format.encoder(endian: endian, options: wkbOptions);
    writeGeometries.call(encoder.writer);
    final wkbBytes = encoder.toBytes();

    // decode bytes, and build WKT string that are tested
    final wktEncoder = WKT.geometry.encoder();
    format
        .decoder(wktEncoder.writer, options: wkbOptions)
        .decodeBytes(wkbBytes);

    // test
    expect(wktEncoder.toText(), wktText);
  }
}
