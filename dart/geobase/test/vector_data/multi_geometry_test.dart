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
      const points33 = '[1.0,2.0,3.0],[1.2,2.2,3.2]';
      const points23 = '[1.0,2.0],[1.2,2.2,3.2]';
      expect(
        MultiPoint.parseCoords(points33).toText(format: DefaultFormat.geometry),
        points33,
      );
      expect(
        () => MultiPoint.parseCoords(points23),
        throwsFormatException,
      );
    });
  });
}
