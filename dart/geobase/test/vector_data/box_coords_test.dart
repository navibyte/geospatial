// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: unrelated_type_equality_checks, prefer_const_declarations

import 'package:geobase/codes.dart';
import 'package:geobase/vector_data.dart';

import 'package:test/test.dart';

void main() {
  group('BoxCoords with XYZM coordinates', () {
    const data = [11.0, 12.0, 13.0, 14.0, 21.0, 22.0, 23.0, 24.0];

    test('Coordinate values as iterable', () {
      final box = BoxCoords.view(data, type: Coords.xyzm);

      for (final bb in [box, box.asProjected, box.asGeographic]) {
        expect(bb.minX, 11.0);
        expect(bb.minY, 12.0);
        expect(bb.minZ, 13.0);
        expect(bb.minM, 14.0);
        expect(bb.maxX, 21.0);
        expect(bb.maxY, 22.0);
        expect(bb.maxZ, 23.0);
        expect(bb.maxM, 24.0);

        final min = bb.min;
        expect(min.x, 11.0);
        expect(min.y, 12.0);
        expect(min.z, 13.0);
        expect(min.m, 14.0);

        final max = bb.max;
        expect(max.x, 21.0);
        expect(max.y, 22.0);
        expect(max.z, 23.0);
        expect(max.m, 24.0);
      }

      expect(
        BoxCoords.create(
          minX: 11.0,
          minY: 12.0,
          minZ: 13.0,
          minM: 14.0,
          maxX: 21.0,
          maxY: 22.0,
          maxZ: 23.0,
          maxM: 24.0,
        ),
        box,
      );
      expect(
        BoxCoords.parse(
          '11.0, 12.0, 13.0, 14.0, 21.0, 22.0, 23.0, 24.0',
          type: Coords.xyzm,
        ),
        box,
      );
      expect(BoxCoords.parse(box.toString(), type: Coords.xyzm), box);
    });
  });

  group('BoxCoords with XYZ coordinates', () {
    const data = [11.0, 12.0, 13.0, 21.0, 22.0, 23.0];

    test('Coordinate values as iterable', () {
      final box = BoxCoords.view(data, type: Coords.xyz);

      for (final bb in [box, box.asProjected, box.asGeographic]) {
        expect(bb.minX, 11.0);
        expect(bb.minY, 12.0);
        expect(bb.minZ, 13.0);
        expect(bb.minM, null);
        expect(bb.maxX, 21.0);
        expect(bb.maxY, 22.0);
        expect(bb.maxZ, 23.0);
        expect(bb.maxM, null);

        final min = bb.min;
        expect(min.x, 11.0);
        expect(min.y, 12.0);
        expect(min.z, 13.0);
        expect(min.optM, null);

        final max = bb.max;
        expect(max.x, 21.0);
        expect(max.y, 22.0);
        expect(max.z, 23.0);
        expect(max.optM, null);
      }

      expect(
        BoxCoords.create(
          minX: 11.0,
          minY: 12.0,
          minZ: 13.0,
          maxX: 21.0,
          maxY: 22.0,
          maxZ: 23.0,
        ),
        box,
      );
      expect(
        BoxCoords.parse(
          '11.0, 12.0, 13.0, 21.0, 22.0, 23.0',
          type: Coords.xyz,
        ),
        box,
      );
      expect(BoxCoords.parse(box.toString(), type: Coords.xyz), box);
    });
  });

  group('BoxCoords with XYM coordinates', () {
    const data = [11.0, 12.0, 14.0, 21.0, 22.0, 24.0];

    test('Coordinate values as iterable', () {
      final box = BoxCoords.view(data, type: Coords.xym);

      for (final bb in [box, box.asProjected, box.asGeographic]) {
        expect(bb.minX, 11.0);
        expect(bb.minY, 12.0);
        expect(bb.minZ, null);
        expect(bb.minM, 14.0);
        expect(bb.maxX, 21.0);
        expect(bb.maxY, 22.0);
        expect(bb.maxZ, null);
        expect(bb.maxM, 24.0);

        final min = bb.min;
        expect(min.x, 11.0);
        expect(min.y, 12.0);
        expect(min.optZ, null);
        expect(min.m, 14.0);

        final max = bb.max;
        expect(max.x, 21.0);
        expect(max.y, 22.0);
        expect(max.optZ, null);
        expect(max.m, 24.0);
      }

      expect(
        BoxCoords.create(
          minX: 11.0,
          minY: 12.0,
          minM: 14.0,
          maxX: 21.0,
          maxY: 22.0,
          maxM: 24.0,
        ),
        box,
      );
      expect(
        BoxCoords.parse(
          '11.0, 12.0, 14.0, 21.0, 22.0, 24.0',
          type: Coords.xym,
        ),
        box,
      );
      expect(BoxCoords.parse(box.toString(), type: Coords.xym), box);
    });
  });

  group('BoxCoords with XY coordinates', () {
    const data = [11.0, 12.0, 21.0, 22.0];

    test('Coordinate values as iterable', () {
      final box = BoxCoords.view(data);

      for (final bb in [box, box.asProjected, box.asGeographic]) {
        expect(bb.minX, 11.0);
        expect(bb.minY, 12.0);
        expect(bb.minZ, null);
        expect(bb.minM, null);
        expect(bb.maxX, 21.0);
        expect(bb.maxY, 22.0);
        expect(bb.maxZ, null);
        expect(bb.maxM, null);

        final min = bb.min;
        expect(min.x, 11.0);
        expect(min.y, 12.0);
        expect(min.optZ, null);
        expect(min.optZ, null);

        final max = bb.max;
        expect(max.x, 21.0);
        expect(max.y, 22.0);
        expect(max.optZ, null);
        expect(max.optM, null);
      }

      expect(
        BoxCoords.create(minX: 11.0, minY: 12.0, maxX: 21.0, maxY: 22.0),
        box,
      );
      expect(BoxCoords.parse('11.0, 12.0, 21.0, 22.0'), box);
      expect(BoxCoords.parse(box.toString()), box);
    });
  });
}
