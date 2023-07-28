// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:geobase/meta.dart';

import 'package:test/test.dart';

void main() {
  group('coordRefSys', () {
    final epsg4326 =
        CoordRefSys.normalized('http://www.opengis.net/def/crs/EPSG/0/4326');

    test('instantiation', () {
      expect(epsg4326, CoordRefSys.from(coordRefSys: CoordRefSys.EPSG_4326));
      expect(epsg4326, CoordRefSys.from(crs: 'EPSG:4326'));
      expect(epsg4326, isNot(CoordRefSys.id('EPSG:4326')));
      expect(
        epsg4326,
        CoordRefSys.id('http://www.opengis.net/def/crs/EPSG/0/4326'),
      );
      expect(
        epsg4326,
        CoordRefSys.from(coordRefSys: CoordRefSys.EPSG_4326, crs: 'what ever'),
      );
      expect(CoordRefSys.CRS84, CoordRefSys.from());
    });

    test('id normalization', () {
      expect(epsg4326, CoordRefSys.normalized('EPSG:4326'));
      expect(epsg4326.id, 'http://www.opengis.net/def/crs/EPSG/0/4326');
    });
    test('id normalization (not normalized)', () {
      expect(epsg4326, isNot(CoordRefSys.normalized('4326')));
    });
    test('axis order', () {
      expect(CoordRefSys.CRS84.axisOrder, AxisOrder.xy);
      expect(CoordRefSys.CRS84h.axisOrder, AxisOrder.xy);
      expect(CoordRefSys.EPSG_4326.axisOrder, AxisOrder.yx);
      expect(CoordRefSys.EPSG_3857.axisOrder, AxisOrder.xy);
      expect(CoordRefSys.EPSG_3395.axisOrder, AxisOrder.xy);
      expect(CoordRefSys.id('EPSG:27700').axisOrder, isNull);
    });
  });
}
