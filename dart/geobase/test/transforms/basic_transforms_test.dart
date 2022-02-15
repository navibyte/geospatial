// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/geobase.dart';

import 'package:test/test.dart';

void main() {
  group('Test transformations with simple translate', () {
    final translate1 = translatePoint(dx: 1.0, dy: 2.0, dz: 3.0, dm: 4.0);
    test('Immutable point classes (cartesian points)', () {
      expect(
        const Position(x: 10.0, y: 20.0).transform(translate1),
        const Position(x: 11.0, y: 22.0),
      );
      expect(
        const Position(x: 10.0, y: 20.0, m: 40.0).transform(translate1),
        const Position(x: 11.0, y: 22.0, m: 44.0),
      );
      expect(
        const Position(x: 10.0, y: 20.0, z: 30.0).transform(translate1),
        const Position(x: 11.0, y: 22.0, z: 33.0),
      );
      expect(
        const Position(x: 10.0, y: 20.0, z: 30.0, m: 40.0)
            .transform(translate1),
        const Position(x: 11.0, y: 22.0, z: 33.0, m: 44.0),
      );
    });
  });
}
