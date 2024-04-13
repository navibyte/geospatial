// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values

import 'dart:convert';
import 'dart:typed_data';

import 'package:geobase/geobase.dart';
import 'package:geobase/src/utils/byte_utils.dart';

import 'package:test/test.dart';

import '../vector/wkb_samples.dart';

void main() {
  group('WKB special cases', () {
    test('Geobase issue #224 (EWKB sample data) 1', () {
      // test case for https://github.com/navibyte/geospatial/issues/224
      // see also: https://rodic.fr/wp-content/uploads/2015/11/geom_converter.html
      //
      // hex: 0101000020E6100000AFCF9CF529765440920F30A9906F3940
      // base64: AQEAACDmEAAAr8+c9Sl2VECSDzCpkG85QA==
      // expected: POINT(81.846311 25.4358011)

      // decode bytes from base64 encoded string
      final bytes = base64.decode('AQEAACDmEAAAr8+c9Sl2VECSDzCpkG85QA==');

      // decode EWKB data using standard WKB format (should ignore SRID data)
      final point = Point.decode(bytes, format: WKB.geometry);
      expect(point.toText(format: WKT.geometry), 'POINT(81.846311 25.4358011)');
      expect(WKB.decodeEndian(bytes), Endian.little);
      expect(WKB.decodeFlavor(bytes), WkbFlavor.extended);
      expect(WKB.decodeSRID(bytes), 4326);
    });

    test('Geobase issue #224 (EWKB sample data) 2', () {
      // test case for https://github.com/navibyte/geospatial/issues/224
      // original sample code from the issue (with some modifications)

      const bin = '0101000020E6100000AFCF9CF529765440920F30A9906F3940';

      final ibytes = <int>[];
      for (var i = 0; i + 1 < bin.length; i += 2) {
        final hexDigit = bin.substring(i, i + 2);
        ibytes.add(int.parse(hexDigit, radix: 16));
      }
      final bytes = Uint8List.fromList(ibytes);
      final point = Point.decode(bytes, format: WKB.geometry);

      expect(point.toText(format: WKT.geometry), 'POINT(81.846311 25.4358011)');
      expect(WKB.decodeEndian(bytes), Endian.little);
      expect(WKB.decodeFlavor(bytes), WkbFlavor.extended);
      expect(WKB.decodeSRID(bytes), 4326);
    });

    test('MariaDB samples (standard WKB)', () {
      // https://mariadb.com/kb/en/well-known-binary-wkb-format/
      //
      // hex: 000000000140000000000000004010000000000000
      // base64: AAAAAAFAAAAAAAAAAEAQAAAAAAAA
      // expected: POINT(2 4)

      // decode bytes from base64 encoded string
      final bytes = base64.decode('AAAAAAFAAAAAAAAAAEAQAAAAAAAA');

      // decode WKB
      final point = Point.decode(bytes, format: WKB.geometry);
      expect(point.toText(format: WKT.geometry), 'POINT(2 4)');
      expect(WKB.decodeEndian(bytes), Endian.big);
      expect(WKB.decodeFlavor(bytes), WkbFlavor.standard);
      expect(WKB.decodeSRID(bytes), isNull);
    });

    test('MySQL samples (standard WKB)', () {
      // https://docs.oracle.com/cd/E17952_01/mysql-8.0-en/gis-data-formats.html
      //
      // hex: 0101000000000000000000F03F000000000000F0BF
      // base64: AAAAAAFAAAAAAAAAAEAQAAAAAAAA
      // expected: POINT(1 -1)

      // decode bytes from base64 encoded string
      final bytes = base64.decode('AQEAAAAAAAAAAADwPwAAAAAAAPC/');

      // decode WKB
      final point = Point.decode(bytes, format: WKB.geometry);
      expect(point.toText(format: WKT.geometry), 'POINT(1 -1)');
      expect(WKB.decodeEndian(bytes), Endian.little);
      expect(WKB.decodeFlavor(bytes), WkbFlavor.standard);
      expect(WKB.decodeSRID(bytes), isNull);
    });

    test('GEOS samples (standard WKB)', () {
      // https://libgeos.org/specifications/wkb/
      //
      // hex: 01020000000300000000000000000000000000000000000000000000000000F03F000000000000F03F0000000000000040000000000000F03F
      // base64: AQIAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPA/AAAAAAAA8D8AAAAAAAAAQAAAAAAAAPA/
      // expected: LINESTRING(0 0,1 1,2 1)

      // decode bytes from base64 encoded string
      final bytes = base64.decode(
        'AQIAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPA/AAAAAAAA8D8AAAAAAAAAQAAAAAAAAPA/',
      );

      // decode WKB
      final line = LineString.decode(bytes, format: WKB.geometry);
      expect(
        line.toText(format: WKT.geometry),
        'LINESTRING(0 0,1 1,2 1)',
      );
      expect(WKB.decodeEndian(bytes), Endian.little);
      expect(WKB.decodeFlavor(bytes), WkbFlavor.standard);
      expect(WKB.decodeSRID(bytes), isNull);
    });

    test('OpenLayers samples (standard WKB)', () {
      // https://openlayers.org/en/latest/examples/wkb.html
      //
      // hex: 0103000000010000000500000054E3A59BC4602540643BDF4F8D1739C05C8FC2F5284C4140EC51B81E852B34C0D578E926316843406F1283C0CAD141C01B2FDD2406012B40A4703D0AD79343C054E3A59BC4602540643BDF4F8D1739C0
      // base64: AQMAAAABAAAABQAAAFTjpZvEYCVAZDvfT40XOcBcj8L1KExBQOxRuB6FKzTA1XjpJjFoQ0BvEoPAytFBwBsv3SQGAStApHA9CteTQ8BU46WbxGAlQGQ730+NFznA
      // expected: POLYGON((10.689 -25.092,34.595 -20.17,38.814 -35.639,13.502 -39.155,10.689 -25.092))

      // decode bytes from base64 encoded string
      final bytes = base64.decode(
        'AQMAAAABAAAABQAAAFTjpZvEYCVAZDvfT40XOcBcj8L1KExBQOxRuB6FKzTA1XjpJjFoQ0BvEoPAytFBwBsv3SQGAStApHA9CteTQ8BU46WbxGAlQGQ730+NFznA',
      );

      // decode WKB
      final polygon = Polygon.decode(bytes, format: WKB.geometry);
      expect(
        polygon.toText(format: WKT.geometry),
        'POLYGON((10.689 -25.092,34.595 -20.17,38.814 -35.639,13.502 -39.155,10.689 -25.092))',
      );
      expect(WKB.decodeEndian(bytes), Endian.little);
      expect(WKB.decodeFlavor(bytes), WkbFlavor.standard);
      expect(WKB.decodeSRID(bytes), isNull);
    });

    test('HEXWKB/HEXEWKB samples', () {
      for (final testCase in wkbGeometries) {
        // test case with WKB or EWKB representation as hex and WKT representation
        final hex = (testCase[0] as String).toLowerCase();
        final wkt = testCase[1] as String;
        final srid = testCase[2] as int;
        final expectEWKB = testCase[3] as bool;

        // decode a geometry using geometry builder directly
        final geom = GeometryBuilder.decodeHex(hex, format: WKB.geometry);
        expect(geom.toText(format: WKT.geometry), wkt);

        // check for flavor
        final flavorFromWkb = WKB.decodeFlavorHex(hex);
        expect(
          flavorFromWkb,
          expectEWKB ? WkbFlavor.extended : WkbFlavor.standard,
        );

        // check also an optional SRID
        final sridFromWkb = WKB.decodeSRIDHex(hex);
        expect(sridFromWkb ?? 0, srid);
        final crs =
            sridFromWkb != null ? CoordRefSys.id('EPSG:$sridFromWkb') : null;

        // decode a geometry using geometry specific factories
        if (wkt.startsWith('POINT')) {
          expect(Point.decodeHex(hex).toText(format: WKT.geometry), wkt);
          if (!expectEWKB) {
            expect(
              Point.parse(wkt, format: WKT.geometry)
                  .toBytesHex(endian: WKB.decodeEndianHex(hex)),
              hex,
            );
          } else {
            expect(
              Point.parse(wkt, format: WKT.geometry).toBytesHex(
                format: WKB.geometryExtended,
                endian: WKB.decodeEndianHex(hex),
                crs: crs,
              ),
              hex,
            );
          }
        } else if (wkt.startsWith('LINESTRING')) {
          expect(LineString.decodeHex(hex).toText(format: WKT.geometry), wkt);
          if (!expectEWKB) {
            expect(
              LineString.parse(wkt, format: WKT.geometry)
                  .toBytesHex(endian: WKB.decodeEndianHex(hex)),
              hex,
            );
          } else {
            expect(
              LineString.parse(wkt, format: WKT.geometry).toBytesHex(
                format: WKB.geometryExtended,
                endian: WKB.decodeEndianHex(hex),
                crs: crs,
              ),
              hex,
            );
          }
        } else if (wkt.startsWith('POLYGON')) {
          expect(Polygon.decodeHex(hex).toText(format: WKT.geometry), wkt);
          if (!expectEWKB) {
            expect(
              Polygon.parse(wkt, format: WKT.geometry)
                  .toBytesHex(endian: WKB.decodeEndianHex(hex)),
              hex,
            );
          } else {
            expect(
              Polygon.parse(wkt, format: WKT.geometry).toBytesHex(
                format: WKB.geometryExtended,
                endian: WKB.decodeEndianHex(hex),
                crs: crs,
              ),
              hex,
            );
          }
        } else if (wkt.startsWith('MULTIPOINT')) {
          expect(MultiPoint.decodeHex(hex).toText(format: WKT.geometry), wkt);
          if (!expectEWKB) {
            expect(
              MultiPoint.parse(wkt, format: WKT.geometry)
                  .toBytesHex(endian: WKB.decodeEndianHex(hex)),
              hex,
            );
          } else {
            expect(
              MultiPoint.parse(wkt, format: WKT.geometry).toBytesHex(
                format: WKB.geometryExtended,
                endian: WKB.decodeEndianHex(hex),
                crs: crs,
              ),
              hex,
            );
          }
        } else if (wkt.startsWith('MULTILINESTRING')) {
          expect(
            MultiLineString.decodeHex(hex).toText(format: WKT.geometry),
            wkt,
          );
          if (!expectEWKB) {
            expect(
              MultiLineString.parse(wkt, format: WKT.geometry)
                  .toBytesHex(endian: WKB.decodeEndianHex(hex)),
              hex,
            );
          } else {
            expect(
              MultiLineString.parse(wkt, format: WKT.geometry).toBytesHex(
                format: WKB.geometryExtended,
                endian: WKB.decodeEndianHex(hex),
                crs: crs,
              ),
              hex,
            );
          }
        } else if (wkt.startsWith('MULTIPOLYGON')) {
          expect(MultiPolygon.decodeHex(hex).toText(format: WKT.geometry), wkt);
          if (!expectEWKB) {
            expect(
              MultiPolygon.parse(wkt, format: WKT.geometry)
                  .toBytesHex(endian: WKB.decodeEndianHex(hex)),
              hex,
            );
          } else {
            expect(
              MultiPolygon.parse(wkt, format: WKT.geometry).toBytesHex(
                format: WKB.geometryExtended,
                endian: WKB.decodeEndianHex(hex),
                crs: crs,
              ),
              hex,
            );
          }
        } else if (wkt.startsWith('GEOMETRYCOLLECTION')) {
          expect(
            GeometryCollection.decodeHex(hex).toText(format: WKT.geometry),
            wkt,
          );
          if (!expectEWKB) {
            expect(
              GeometryCollection.parse(wkt, format: WKT.geometry)
                  .toBytesHex(endian: WKB.decodeEndianHex(hex)),
              hex,
            );
          } else {
            expect(
              GeometryCollection.parse(wkt, format: WKT.geometry).toBytesHex(
                format: WKB.geometryExtended,
                endian: WKB.decodeEndianHex(hex),
                crs: crs,
              ),
              hex,
            );
          }
        }
      }
    });

    test('Test hex utility functions', () {
      for (final testCase in wkbGeometries) {
        final hex = testCase[0] as String;
        final bytes = Uint8ListUtils.fromHex(hex);
        final bytesToHex = bytes.toHex();
        expect(hex.toLowerCase(), bytesToHex);
      }
    });
  });
}
