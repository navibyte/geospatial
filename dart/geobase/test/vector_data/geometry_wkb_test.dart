// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values

import 'dart:convert';

import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';

import 'package:test/test.dart';

void main() {
  group('WKB special cases', () {
    test('Geobase issue #224 (EWKB sample data)', () {
      // test case for https://github.com/navibyte/geospatial/issues/224
      // see also: https://rodic.fr/wp-content/uploads/2015/11/geom_converter.html
      //
      // hex: 0101000020E6100000AFCF9CF529765440920F30A9906F3940
      // base64: AQEAACDmEAAAr8+c9Sl2VECSDzCpkG85QA==
      // expected: POINT(81.846311 25.4358011)

      // decode bytes from base64 encoded string
      final bytes = base64.decode('AQEAACDmEAAAr8+c9Sl2VECSDzCpkG85QA==');

      // decode WKB
      // (should throw when trying to decode according to WKB standard)
      expect(() => Point.decode(bytes, format: WKB.geometry), throwsException);

      // NOTE the sample data above is not a valid WKB byte sequence
      // * https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry
      //    * See section: "Well-known binary"
      // * The first byte indicates the byte order for the data
      //    * here "01" means "little endian" - this is interpreted correctly
      // * The next 4 bytes are a 32-bit unsigned integer for the geometry type
      //    * here "01000020" in little endian is integer 536870913
      //    * that is not a WKB geometry type, so exception should be thrown
      //
      // Seems that such data is PostGIS specific EKWB format
      // * https://postgis.net/docs/ST_AsEWKB.html
      // * https://postgis.net/docs/using_postgis_dbmanagement.html#EWKB_EWKT
      // * https://libgeos.org/specifications/wkb/
    });

    test('MariaDB samples (standard WKB)', () {
      // https://mariadb.com/kb/en/well-known-binary-wkb-format/
      //
      // hex: 000000000140000000000000004010000000000000
      // base64: AAAAAAFAAAAAAAAAAEAQAAAAAAAA
      // expected: POINT(2.0 4.0)

      // decode bytes from base64 encoded string
      final bytes = base64.decode('AAAAAAFAAAAAAAAAAEAQAAAAAAAA');

      // decode WKB
      final point = Point.decode(bytes, format: WKB.geometry);
      expect(point.toText(format: WKT.geometry), 'POINT(2.0 4.0)');
    });

    test('MySQL samples (standard WKB)', () {
      // https://docs.oracle.com/cd/E17952_01/mysql-8.0-en/gis-data-formats.html
      //
      // hex: 0101000000000000000000F03F000000000000F0BF
      // base64: AAAAAAFAAAAAAAAAAEAQAAAAAAAA
      // expected: POINT(1.0 -1.0)

      // decode bytes from base64 encoded string
      final bytes = base64.decode('AQEAAAAAAAAAAADwPwAAAAAAAPC/');

      // decode WKB
      final point = Point.decode(bytes, format: WKB.geometry);
      expect(point.toText(format: WKT.geometry), 'POINT(1.0 -1.0)');
    });

    test('GEOS samples (standard WKB)', () {
      // https://libgeos.org/specifications/wkb/
      //
      // hex: 01020000000300000000000000000000000000000000000000000000000000F03F000000000000F03F0000000000000040000000000000F03F
      // base64: AQIAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPA/AAAAAAAA8D8AAAAAAAAAQAAAAAAAAPA/
      // expected: LINESTRING(0.0 0.0,1.0 1.0,2.0 1.0)

      // decode bytes from base64 encoded string
      final bytes = base64.decode(
        'AQIAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPA/AAAAAAAA8D8AAAAAAAAAQAAAAAAAAPA/',
      );

      // decode WKB
      final line = LineString.decode(bytes, format: WKB.geometry);
      expect(
        line.toText(format: WKT.geometry),
        'LINESTRING(0.0 0.0,1.0 1.0,2.0 1.0)',
      );
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
    });
  });
}
