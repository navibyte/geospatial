// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_declarations

import 'package:geobase/coordinates.dart';

import 'package:test/test.dart';

void main() {
  group('Basic tiling scheme tests', () {
    const ref0 = Scalable2i(zoom: 0, x: 1, y: 0);
    const ref9 = Scalable2i(zoom: 9, x: 23, y: 10);
    const ref9neg = Scalable2i(zoom: 9, x: -23, y: -10);
    test('Test Scalable2i coordinates', () {
      expect(Scalable2i.build(const [9, 23, 10]), ref9);
      expect(Scalable2i.parse('9;23;10', delimiter: ';'), ref9);
      expect(Scalable2i.factory(zoom: 9).call(x: 23, y: 10), ref9);
    });

    test('Test Scalable2i coordinates (output)', () {
      expect(Scalable2i.build(const [9, 23, 10]).toText(), '9,23,10');
      expect(Scalable2i.parse('9;23;10', delimiter: ';').values, [9, 23, 10]);

      final s2i = Scalable2i.factory(zoom: 9).call(x: 23, y: 10);
      expect(s2i[0], 9);
      expect(s2i[1], 23);
      expect(s2i[2], 10);
    });

    test('Test Scalable2i zoomIn and zoomOut', () {
      expect(ref0.zoomIn(), const Scalable2i(zoom: 1, x: 2, y: 0));
      expect(ref0.zoomOut(), const Scalable2i(zoom: 0, x: 1, y: 0));
      expect(ref9.zoomIn(), const Scalable2i(zoom: 10, x: 46, y: 20));
      expect(ref9.zoomOut(), const Scalable2i(zoom: 8, x: 11, y: 5));
      expect(ref9neg.zoomIn(), const Scalable2i(zoom: 10, x: -46, y: -20));
      expect(ref9neg.zoomOut(), const Scalable2i(zoom: 8, x: -12, y: -5));
    });

    test('Test Scalable2i zoomTo', () {
      expect(ref0.zoomTo(2), const Scalable2i(zoom: 2, x: 4, y: 0));
      expect(ref0.zoomTo(0), const Scalable2i(zoom: 0, x: 1, y: 0));
      expect(ref9.zoomTo(13), const Scalable2i(zoom: 13, x: 368, y: 160));
      expect(ref9.zoomTo(6), const Scalable2i(zoom: 6, x: 2, y: 1));
      expect(ref9neg.zoomTo(13), const Scalable2i(zoom: 13, x: -368, y: -160));
      expect(ref9neg.zoomTo(6), const Scalable2i(zoom: 6, x: -3, y: -2));
    });
  });
}
