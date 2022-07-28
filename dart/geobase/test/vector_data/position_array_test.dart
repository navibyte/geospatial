// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: unrelated_type_equality_checks, prefer_const_declarations

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector_data.dart';

import 'package:test/test.dart';

void main() {
  group('Position array (XYZ or XYM positions) as flat coordinate values', () {
    // array of 3 positions with xyz or xym coordinates
    const data3 = [1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3];

    for (final type in [Coords.xyz, Coords.xym]) {
      final array3 = PositionArray.view(data3, type: type);
      final array3FromText = PositionArray.fromText(
        '1.1,1.2,1.3,2.1,2.2,2.3,3.1,3.2,3.3',
        type: type,
      );

      test('Creating position arrays', () {
        expect(array3, data3);
        expect(array3FromText, array3);
        expect(array3.type, type);
      });

      test('Access projected positions', () {
        final projected = array3.projected;
        expect(projected.length, 3);
        expect(projected.type, type);

        final tests = type == Coords.xyz
            ? [
                [
                  XYZ(1.1, 1.2, 1.3),
                  XYZ(2.1, 2.2, 2.3),
                  XYZ(3.1, 3.2, 3.3),
                ],
                [
                  const Projected(x: 1.1, y: 1.2, z: 1.3),
                  const Projected(x: 2.1, y: 2.2, z: 2.3),
                  const Projected(x: 3.1, y: 3.2, z: 3.3),
                ],
              ]
            : [
                [
                  XYM(1.1, 1.2, 1.3),
                  XYM(2.1, 2.2, 2.3),
                  XYM(3.1, 3.2, 3.3),
                ],
                [
                  const Projected(x: 1.1, y: 1.2, m: 1.3),
                  const Projected(x: 2.1, y: 2.2, m: 2.3),
                  const Projected(x: 3.1, y: 3.2, m: 3.3),
                ],
              ];

        for (final test in tests) {
          expect(projected.all, test);
          for (var index = 0; index < 3; index++) {
            expect(projected[index], test[index]);
            expect(projected.get(index, to: Projected.create), tests[1][index]);
            expect(
              projected.get(index, to: Geographic.create),
              isNot(tests[1][index]),
            );
            expect(projected[index].x, test[index].x);
            expect(projected[index].y, test[index].y);
            expect(projected[index].z, test[index].z);
            expect(projected[index].optZ, test[index].optZ);
            expect(projected[index].m, test[index].m);
            expect(projected[index].optM, test[index].optM);
          }
        }
      });

      test('Access geographic positions', () {
        final geographic = array3.geographic;
        expect(geographic.length, 3);
        expect(geographic.type, type);

        final tests = type == Coords.xyz
            ? [
                [
                  LonLatElev(1.1, 1.2, 1.3),
                  LonLatElev(2.1, 2.2, 2.3),
                  LonLatElev(3.1, 3.2, 3.3),
                ],
                [
                  const Geographic(lon: 1.1, lat: 1.2, elev: 1.3),
                  const Geographic(lon: 2.1, lat: 2.2, elev: 2.3),
                  const Geographic(lon: 3.1, lat: 3.2, elev: 3.3),
                ],
              ]
            : [
                [
                  LonLatM(1.1, 1.2, 1.3),
                  LonLatM(2.1, 2.2, 2.3),
                  LonLatM(3.1, 3.2, 3.3),
                ],
                [
                  const Geographic(lon: 1.1, lat: 1.2, m: 1.3),
                  const Geographic(lon: 2.1, lat: 2.2, m: 2.3),
                  const Geographic(lon: 3.1, lat: 3.2, m: 3.3),
                ],
              ];

        for (final test in tests) {
          expect(geographic.all, test);
          for (var index = 0; index < 3; index++) {
            expect(geographic[index], test[index]);
            expect(
              geographic.get(index, to: Geographic.create),
              tests[1][index],
            );
            expect(
              geographic.get(index, to: Projected.create),
              isNot(tests[1][index]),
            );
            expect(geographic[index].lon, test[index].lon);
            expect(geographic[index].lat, test[index].lat);
            expect(geographic[index].elev, test[index].elev);
            expect(geographic[index].optElev, test[index].optElev);
            expect(geographic[index].m, test[index].m);
            expect(geographic[index].optM, test[index].optM);
          }
        }
      });
    }
  });

  group('Position array (XY positions) as flat coordinate values', () {
    // array of 3 positions with xy coordinates
    const xyData3 = [1.1, 1.2, 2.1, 2.2, 3.1, 3.2];
    const xyArray3 = PositionArray.view(xyData3);
    final xyArray3FromText = PositionArray.fromText('1.1,1.2,2.1,2.2,3.1,3.2');

    test('Creating position arrays', () {
      expect(xyArray3, xyData3);
      expect(xyArray3FromText, xyArray3);
      expect(xyArray3.type, Coords.xy);
    });

    test('Access projected positions', () {
      final projected = xyArray3.projected;
      expect(projected.length, 3);
      expect(projected.type, Coords.xy);

      final tests = [
        [
          XY(1.1, 1.2),
          XY(2.1, 2.2),
          XY(3.1, 3.2),
        ],
        [
          const Projected(x: 1.1, y: 1.2),
          const Projected(x: 2.1, y: 2.2),
          const Projected(x: 3.1, y: 3.2),
        ],
      ];

      for (final test in tests) {
        expect(projected.all, test);
        for (var index = 0; index < 3; index++) {
          expect(projected[index], test[index]);
          expect(projected.get(index, to: Projected.create), tests[1][index]);
          expect(
            projected.get(index, to: Geographic.create),
            isNot(tests[1][index]),
          );
          expect(projected[index].x, test[index].x);
          expect(projected[index].y, test[index].y);
          expect(projected[index].z, test[index].z);
          expect(projected[index].optZ, test[index].optZ);
          expect(projected[index].m, test[index].m);
          expect(projected[index].optM, test[index].optM);
        }
      }
    });
  });

  group('Position array (XYZM positions) as flat coordinate values', () {
    // array of 3 positions with xyzm coordinates
    const xyzmData3 = [
      1.1,
      1.2,
      1.3,
      1.4,
      2.1,
      2.2,
      2.3,
      2.4,
      3.1,
      3.2,
      3.3,
      3.4,
    ];
    const xyzmArray3 = PositionArray.view(xyzmData3, type: Coords.xyzm);
    final xyzmArray3FromText = PositionArray.fromText(
      '1.1,1.2,1.3,1.4,2.1,2.2,2.3,2.4,3.1,3.2,3.3,3.4',
      type: Coords.xyzm,
    );

    test('Creating position arrays', () {
      expect(xyzmArray3, xyzmData3);
      expect(xyzmArray3FromText, xyzmArray3);
      expect(xyzmArray3.type, Coords.xyzm);
    });

    test('Access projected positions', () {
      final projected = xyzmArray3.data(Projected.create);
      expect(projected.length, 3);
      expect(projected.type, Coords.xyzm);

      final tests = [
        [
          XYZM(1.1, 1.2, 1.3, 1.4),
          XYZM(2.1, 2.2, 2.3, 2.4),
          XYZM(3.1, 3.2, 3.3, 3.4),
        ],
        [
          const Projected(x: 1.1, y: 1.2, z: 1.3, m: 1.4),
          const Projected(x: 2.1, y: 2.2, z: 2.3, m: 2.4),
          const Projected(x: 3.1, y: 3.2, z: 3.3, m: 3.4),
        ],
      ];

      for (final test in tests) {
        expect(projected.all, test);
        for (var index = 0; index < 3; index++) {
          expect(projected[index], test[index]);
          expect(projected.get(index, to: Projected.create), tests[1][index]);
          expect(
            projected.get(index, to: Geographic.create),
            isNot(tests[1][index]),
          );
          expect(projected[index].x, test[index].x);
          expect(projected[index].y, test[index].y);
          expect(projected[index].z, test[index].z);
          expect(projected[index].optZ, test[index].optZ);
          expect(projected[index].m, test[index].m);
          expect(projected[index].optM, test[index].optM);
        }
      }
    });
  });
}
