// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:geobase/geobase.dart';

import 'package:test/test.dart';

void main() {
  final bbox1 = GeoBox(west: -19.2, south: -4.5, east: 12.2, north: 24.5);
  final bbox2 = GeoBox(west: -19.2, south: 31.0, east: 12.2, north: 32.0);
  final spatialSingle = SpatialExtent.single(bbox1);
  final spatialMulti1 = SpatialExtent.multi([bbox1]);
  final spatialMulti2 = SpatialExtent.multi([bbox1, bbox2]);
  final spatialMulti3 = SpatialExtent.multi([bbox2, bbox1]);

  group('Spatial extents', () {
    test('Equals and key properties', () {
      expect(spatialSingle, spatialMulti1);
      expect(spatialSingle, isNot(spatialMulti2));
      expect(spatialMulti3, isNot(spatialMulti2));
      expect(spatialSingle.crs, spatialMulti1.crs);
      expect(spatialSingle.first, spatialMulti1.first);
      expect(spatialSingle.first, spatialMulti2.first);
      expect(spatialSingle.first, isNot(spatialMulti3.first));
      expect(
        spatialSingle.boxes,
        [GeoBox(west: -19.2, south: -4.5, east: 12.2, north: 24.5)],
      );
    });
  });

  final interval1 = Interval.closed(
    DateTime.parse('2020-10-03 20:30:10Z'),
    DateTime.parse('2020-10-05 01:15:50Z'),
  );
  final interval2 =
      Interval.parse('2020-10-03T20:30:10.000Z/2020-10-05T01:15:50.000Z');
  final temporalSingle = TemporalExtent.single(interval2);

  group('Temporal extents', () {
    test('Equals and key properties', () {
      expect(temporalSingle.first, interval1);
      expect(temporalSingle.intervals, [interval1]);
    });
  });

  final extent1 = GeoExtent(spatial: spatialSingle, temporal: temporalSingle);

  group('Geo extents', () {
    test('Equals and key properties', () {
      expect(
        extent1.spatial.first,
        GeoBox(west: -19.2, south: -4.5, east: 12.2, north: 24.5),
      );
      expect(
        extent1.spatial.crs,
        'http://www.opengis.net/def/crs/OGC/1.3/CRS84',
      );
      expect(extent1.temporal!.first, interval1);
      expect(
        extent1.temporal!.trs,
        'http://www.opengis.net/def/uom/ISO-8601/0/Gregorian',
      );
      expect(
        extent1.toString(),
        '[http://www.opengis.net/def/crs/OGC/1.3/CRS84,[-19.2,-4.5,12.2,24.5]],'
        '[http://www.opengis.net/def/uom/ISO-8601/0/Gregorian,'
        '2020-10-03T20:30:10.000Z/2020-10-05T01:15:50.000Z]',
      );
    });
  });
}
