// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';

import 'package:test/test.dart';

import '../vector/wkt_samples.dart';

void main() {
  group('WKT special cases', () {
    test('EWKT - samples', () {
      for (final test in wktGeometries2) {
        final input = test[0] as List<String>;
        final geom = test[1] as Geometry;
        final srid = test[2] as int?;
        final dim = test[3] as Coords;

        for (final wkt in input) {
          const spaces = [' (', '( ', '   (  ', '(  '];

          for (final sp in spaces) {
            const formats = [
              WKT.geometry,
              GeoJSON.geometry,
              DefaultFormat.geometry,
            ];
            for (final format in formats) {
              final source = wkt.replaceAll('(', sp);
              expect(
                GeometryBuilder.parse(
                  source,
                  format: WKT.geometry,
                ).toText(format: format),
                geom.toText(format: format),
              );
              if (srid != null && source.contains('SRID')) {
                expect(WKT.decodeSRID(source), srid);
              }
              expect(WKT.decodeCoordType(source), dim);
            }
          }
        }
      }
    });
  });
}
