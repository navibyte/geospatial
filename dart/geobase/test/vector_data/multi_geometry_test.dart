// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: cascade_invocations, lines_longer_than_80_chars

import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';

import 'package:test/test.dart';

// see also '../vector/geojson_test.dart'

void main() {
  group('MultiPoint', () {
    test('Create from coords', () {
      const points54 = '[1.1,2.1,3.1,4.1,5.1],[1.2,2.2,3.2,4.2]';
      const points45 = '[1.1,2.1,3.1,4.1],[1.2,2.2,3.2,4.2,5.2]';
      const points44 = '[1.1,2.1,3.1,4.1],[1.2,2.2,3.2,4.2]';
      const points33 = '[1.1,2.1,3.1],[1.2,2.2,3.2]';
      const points23 = '[1.1,2.1],[1.2,2.2,3.2]';
      const points32 = '[1.1,2.1,3.1],[1.2,2.2]';
      const points32_0 = '[1.1,2.1,3.1],[1.2,2.2,0]';
      const points22 = '[1.1,2.1],[1.2,2.2]';
      const points12 = '[1.1],[1.2,2.2]';
      const points21 = '[1.1,2.1],[1.2]';
      const points20 = '[1.1,2.1],[]';
      const points02 = '[],[1.2,2.2]';

      const tests = [
        [points54, points44],
        [points45, points44],
        [points44, points44],
        [points33, points33],
        [points23, points22],
        [points32, points32_0],
        [points22, points22],
      ];
      for (final test in tests) {
        expect(
          MultiPoint.parseCoords(_toFlat(test[0]))
              .toText(format: DefaultFormat.geometry),
          test[1],
        );
      }
      expect(
        () => MultiPoint.parseCoords(_toFlat(points12)),
        throwsFormatException,
      );
      expect(
        () => MultiPoint.parseCoords(_toFlat(points21)),
        throwsFormatException,
      );
      expect(
        () => MultiPoint.parseCoords(_toFlat(points20)),
        throwsFormatException,
      );
      expect(
        () => MultiPoint.parseCoords(_toFlat(points02)),
        throwsFormatException,
      );
    });
  });
}

Iterable<String> _toFlat(String test) =>
    test.substring(1, test.length - 1).split('],[');
