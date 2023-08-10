// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
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
      final array3FromText = PositionArray.parse(
        '1.1,1.2,1.3,2.1,2.2,2.3,3.1,3.2,3.3',
        type: type,
      );
      final positions3 = type == Coords.xyz
          ? [
              const Projected(x: 1.1, y: 1.2, z: 1.3),
              const Projected(x: 2.1, y: 2.2, z: 2.3),
              const Projected(x: 3.1, y: 3.2, z: 3.3),
            ]
          : [
              const Projected(x: 1.1, y: 1.2, m: 1.3),
              const Projected(x: 2.1, y: 2.2, m: 2.3),
              const Projected(x: 3.1, y: 3.2, m: 3.3),
            ];
      final array3FromPositions = positions3.array();

      test('Creating position arrays', () {
        expect(array3, data3);
        expect(array3FromText, array3);
        expect(array3FromPositions, array3);
        expect(array3.type, type);
        expect(array3FromText.type, type);
        expect(array3FromPositions.type, type);
      });

      test('Access positions as PositionData', () {
        final positions = array3.data;
        expect(positions.length, 3);
        expect(positions.type, type);

        final tests = type == Coords.xyz
            ? [
                [
                  [1.1, 1.2, 1.3].xyz,
                  [2.1, 2.2, 2.3].xyz,
                  [3.1, 3.2, 3.3].xyz,
                ],
                [
                  const Projected(x: 1.1, y: 1.2, z: 1.3),
                  const Projected(x: 2.1, y: 2.2, z: 2.3),
                  const Projected(x: 3.1, y: 3.2, z: 3.3),
                ],
              ]
            : [
                [
                  [1.1, 1.2, 1.3].xym,
                  [2.1, 2.2, 2.3].xym,
                  [3.1, 3.2, 3.3].xym,
                ],
                [
                  const Projected(x: 1.1, y: 1.2, m: 1.3),
                  const Projected(x: 2.1, y: 2.2, m: 2.3),
                  const Projected(x: 3.1, y: 3.2, m: 3.3),
                ],
              ];

        for (final test in tests) {
          expect(positions.all, test);
          for (var index = 0; index < 3; index++) {
            expect(positions[index], test[index]);
            expect(positions[index].asProjected, test[index]);
            expect(positions[index].asGeographic, test[index]);
            expect(positions.get(index, to: Projected.create), tests[1][index]);
            expect(
              positions.get(index, to: Geographic.create),
              tests[1][index],
            );
            expect(positions[index].x, test[index].x);
            expect(positions[index].y, test[index].y);
            expect(positions[index].z, test[index].z);
            expect(positions[index].optZ, test[index].optZ);
            expect(positions[index].m, test[index].m);
            expect(positions[index].optM, test[index].optM);
          }
        }
      });

      test('Access as geographic positions', () {
        final geographic = array3.toGeographic;
        expect(geographic.length, 3);
        expect(geographic.type, type);

        final tests = type == Coords.xyz
            ? [
                [
                  [1.1, 1.2, 1.3].xyz,
                  [2.1, 2.2, 2.3].xyz,
                  [3.1, 3.2, 3.3].xyz,
                ],
                [
                  const Geographic(lon: 1.1, lat: 1.2, elev: 1.3),
                  const Geographic(lon: 2.1, lat: 2.2, elev: 2.3),
                  const Geographic(lon: 3.1, lat: 3.2, elev: 3.3),
                ],
              ]
            : [
                [
                  [1.1, 1.2, 1.3].xym,
                  [2.1, 2.2, 2.3].xym,
                  [3.1, 3.2, 3.3].xym,
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
              tests[1][index],
            );
            expect(geographic[index].lon, test[index].x);
            expect(geographic[index].lat, test[index].y);
            expect(geographic[index].elev, test[index].z);
            expect(geographic[index].optElev, test[index].optZ);
            expect(geographic[index].m, test[index].m);
            expect(geographic[index].optM, test[index].optM);
          }
        }
      });
    }
  });

  group('Position array equality', () {
    final xy1 = PositionArray.parse('1.1,1.2,2.1,2.2,3.1,3.2');
    final arr = [1.1, 1.2, 2.1, 2.2, 3.1, 3.2];
    final xy2 = PositionArray.view(arr);
    final xy3 = PositionArray.view(arr);

    test('Testing equality', () {
      expect(xy1, xy2);
      expect(xy1 == xy2, false);
     
      expect(xy2, xy3);
      expect(xy2 == xy3, true);
    });
  });

  group('Position array (XY positions) as flat coordinate values', () {
    // array of 3 positions with xy coordinates
    const xyData3 = [1.1, 1.2, 2.1, 2.2, 3.1, 3.2];
    final xyArray3 = PositionArray.view(xyData3);
    final xyArray3FromText = PositionArray.parse('1.1,1.2,2.1,2.2,3.1,3.2');

    test('Creating position arrays', () {
      expect(xyArray3, xyData3);
      expect(xyArray3FromText, xyArray3);
      expect(xyArray3.type, Coords.xy);
    });

    test('Access as projected positions', () {
      final projected = xyArray3.toProjected;
      expect(projected.length, 3);
      expect(projected.type, Coords.xy);

      final tests = [
        [
          [1.1, 1.2].xy,
          [2.1, 2.2].xy,
          [3.1, 3.2].xy,
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
            tests[1][index],
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
    final xyzmArray3 = PositionArray.view(xyzmData3, type: Coords.xyzm);
    final xyzmArray3FromText = PositionArray.parse(
      '1.1,1.2,1.3,1.4,2.1,2.2,2.3,2.4,3.1,3.2,3.3,3.4',
      type: Coords.xyzm,
    );

    test('Creating position arrays', () {
      expect(xyzmArray3, xyzmData3);
      expect(xyzmArray3FromText, xyzmArray3);
      expect(xyzmArray3.type, Coords.xyzm);
    });

    test('Access projected positions', () {
      final projected = xyzmArray3.dataTo(Projected.create);
      expect(projected.length, 3);
      expect(projected.type, Coords.xyzm);

      final tests = [
        [
          [1.1, 1.2, 1.3, 1.4].xyzm,
          [2.1, 2.2, 2.3, 2.4].xyzm,
          [3.1, 3.2, 3.3, 3.4].xyzm,
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
            tests[1][index],
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
