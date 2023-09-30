// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: unrelated_type_equality_checks, prefer_const_declarations

import 'package:geobase/coordinates.dart';

import 'package:test/test.dart';

void main() {
  group('Position array (XYZ or XYM positions) as flat coordinate values', () {
    // array of 3 positions with xyz or xym coordinates
    const data3 = [1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3];

    for (final type in [Coords.xyz, Coords.xym]) {
      final array3 = PositionSeries.view(data3, type: type);
      final array3FromText = PositionSeries.parse(
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
      final array3FromPositions = positions3.series();

      test('Creating position arrays', () {
        expect(array3.values, data3);
        expect(array3FromText.values, array3.values);
        expect(array3FromPositions.values, array3.values);
        expect(array3.type, type);
        expect(array3FromText.type, type);
        expect(array3FromPositions.type, type);

        expect(array3FromText.equalsCoords(array3), true);
        expect(array3FromPositions.equalsCoords(array3), true);
      });

      test('Access positions as PositionData', () {
        final positions = array3;
        expect(positions.positionCount, 3);
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
          expect(positions.positions, test);
          for (var index = 0; index < 3; index++) {
            expect(positions[index], test[index]);
            expect(Projected.from(positions[index]), test[index]);
            expect(Geographic.from(positions[index]), test[index]);
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
        final geographic = array3.positionsAs(to: Geographic.create).toList();
        expect(geographic.length, 3);
        expect(array3.type, type);

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
          expect(geographic, test);
          for (var index = 0; index < 3; index++) {
            expect(geographic[index], test[index]);
            expect(
              array3.get(index, to: Geographic.create),
              tests[1][index],
            );
            expect(
              array3.get(index, to: Projected.create),
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
    final xy1 = PositionSeries.parse('1.1,1.2,2.1,2.2,3.1,3.2');
    final arr = [1.1, 1.2, 2.1, 2.2, 3.1, 3.2];
    final xy2 = PositionSeries.view(arr);
    final xy3 = PositionSeries.view(arr);

    test('Testing equality', () {
      expect(xy1.values, xy2.values);
      expect(xy1 == xy2, false);
      expect(xy1.equalsCoords(xy2), true);

      expect(xy2, xy3);
      expect(xy2 == xy3, true);
      expect(xy2.equalsCoords(xy3), true);
    });

    test('Test equalsCoords', () {
      final iter = arr.map((e) => e * 10.0);
      final xyIter2 = PositionSeries.view(iter.toList(growable: false));
      final xyIter3 = PositionSeries.view(iter.toList(growable: false));

      expect(xy1.equalsCoords(xyIter2), false);
      expect(xyIter3.equalsCoords(xyIter2), true);

      expect(
        PositionSeries.empty().equalsCoords(PositionSeries.empty()),
        true,
      );
      expect(
        PositionSeries.view([1, 2, 3, 4]).equalsCoords(PositionSeries.empty()),
        false,
      );
      expect(
        PositionSeries.view([1, 2, 3, 4])
            .equalsCoords(PositionSeries.view([1, 2, 3, 4])),
        true,
      );
      expect(
        PositionSeries.view([1, 2, 3.000000000001, 4])
            .equalsCoords(PositionSeries.view([1, 2, 3, 4])),
        false,
      );
      expect(
        PositionSeries.parse('1,2,3', type: Coords.xyz)
            .equalsCoords(PositionSeries.view([1, 2, 3], type: Coords.xyz)),
        true,
      );
      expect(
        PositionSeries.parse('1,2,3', type: Coords.xym)
            .equalsCoords(PositionSeries.view([1, 2, 3], type: Coords.xyz)),
        false,
      );
    });
  });

  group('Position array (XY positions) as flat coordinate values', () {
    // array of 3 positions with xy coordinates
    const xyData3 = [1.1, 1.2, 2.1, 2.2, 3.1, 3.2];
    final xyArray3 = PositionSeries.view(xyData3);
    final xyArray3FromText = PositionSeries.parse('1.1,1.2,2.1,2.2,3.1,3.2');

    test('Creating position arrays', () {
      expect(xyArray3.values, xyData3);
      expect(xyArray3FromText.values, xyArray3.values);
      expect(xyArray3.type, Coords.xy);
    });

    test('Access as projected positions', () {
      final projected = xyArray3.positionsAs(to: Projected.create).toList();
      expect(projected.length, 3);
      expect(projected.first.type, Coords.xy);

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
        expect(projected, test);
        for (var index = 0; index < 3; index++) {
          expect(projected[index], test[index]);
          expect(xyArray3.get(index, to: Projected.create), tests[1][index]);
          expect(
            xyArray3.get(index, to: Geographic.create),
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
    final xyzmArray3 = PositionSeries.view(xyzmData3, type: Coords.xyzm);
    final xyzmArray3FromText = PositionSeries.parse(
      '1.1,1.2,1.3,1.4,2.1,2.2,2.3,2.4,3.1,3.2,3.3,3.4',
      type: Coords.xyzm,
    );

    test('Creating position arrays', () {
      expect(xyzmArray3.values, xyzmData3);
      expect(xyzmArray3FromText.values, xyzmArray3.values);
      expect(xyzmArray3.type, Coords.xyzm);
    });

    test('Access projected positions', () {
      final projected = xyzmArray3.positionsAs(to: Projected.create).toList();
      expect(projected.length, 3);
      expect(projected.first.type, Coords.xyzm);

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
        expect(projected, test);
        for (var index = 0; index < 3; index++) {
          expect(projected[index], test[index]);
          expect(projected[index].copyTo(Projected.create), tests[1][index]);
          expect(
            projected[index].copyTo(Geographic.create),
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

  group('Position series reversed and toText', () {
    test('xy', () {
      final coords = [1.1, 1.2, 2.1, 2.2, 3.1, 3.2, 4.1, 4.2];
      final xyCoords = PositionSeries.view(coords);
      final xyPos = PositionSeries.from([
        [1.1, 1.2].xy,
        [2.1, 2.2].xy,
        [3.1, 3.2].xy,
        [4.1, 4.2].xy,
      ]);
      for (final xy in [xyCoords, xyPos]) {
        expect(xy.toText(), '1.1,1.2,2.1,2.2,3.1,3.2,4.1,4.2');
        expect(
          xy.toText(positionDelimiter: ' ', decimals: 2),
          '1.10,1.20 2.10,2.20 3.10,3.20 4.10,4.20',
        );
        final xyRev = xy.reversed();
        expect(xy[1], [2.1, 2.2].xy);
        expect(xyRev[2], [2.1, 2.2].xy);
        expect(xyRev.values, [4.1, 4.2, 3.1, 3.2, 2.1, 2.2, 1.1, 1.2]);
        expect(xyRev.toText(), '4.1,4.2,3.1,3.2,2.1,2.2,1.1,1.2');
        expect(xyRev.toText(swapXY: true), '4.2,4.1,3.2,3.1,2.2,2.1,1.2,1.1');
        expect(
          xyRev.valuesByType(Coords.xy),
          [4.1, 4.2, 3.1, 3.2, 2.1, 2.2, 1.1, 1.2],
        );
        expect(
          xyRev.valuesByType(Coords.xyz),
          [4.1, 4.2, 0.0, 3.1, 3.2, 0.0, 2.1, 2.2, 0.0, 1.1, 1.2, 0.0],
        );
        expect(
          xyRev.valuesByType(Coords.xym),
          [4.1, 4.2, 0.0, 3.1, 3.2, 0.0, 2.1, 2.2, 0.0, 1.1, 1.2, 0.0],
        );
        expect(
          xyRev.valuesByType(Coords.xyzm),
          [
            4.1, 4.2, 0.0, 0.0, 3.1, 3.2, 0.0, 0.0,
            2.1, 2.2, 0.0, 0.0, 1.1, 1.2, 0.0, 0.0
            // ---
          ],
        );
      }
    });

    test('xyz', () {
      final coords = [
        1.1, 1.2, 1.3, 2.1, 2.2, 2.3,
        3.1, 3.2, 3.3, 4.1, 4.2, 4.3
        // ---
      ];
      final xyzCoords = PositionSeries.view(coords, type: Coords.xyz);
      final xyzPos = PositionSeries.from([
        [1.1, 1.2, 1.3].xyz,
        [2.1, 2.2, 2.3].xyz,
        [3.1, 3.2, 3.3].xyz,
        [4.1, 4.2, 4.3].xyz,
      ]);
      for (final xyz in [xyzCoords, xyzPos]) {
        final xyzRev = xyz.reversed();
        expect(xyz[1], [2.1, 2.2, 2.3].xyz);
        expect(xyzRev[2], [2.1, 2.2, 2.3].xyz);
        expect(
          xyzRev.values,
          [4.1, 4.2, 4.3, 3.1, 3.2, 3.3, 2.1, 2.2, 2.3, 1.1, 1.2, 1.3],
        );
        expect(
          xyzRev.valuesByType(Coords.xy),
          [4.1, 4.2, 3.1, 3.2, 2.1, 2.2, 1.1, 1.2],
        );
        expect(
          xyzRev.valuesByType(Coords.xyz),
          [4.1, 4.2, 4.3, 3.1, 3.2, 3.3, 2.1, 2.2, 2.3, 1.1, 1.2, 1.3],
        );
        expect(
          xyzRev.valuesByType(Coords.xym),
          [4.1, 4.2, 0.0, 3.1, 3.2, 0.0, 2.1, 2.2, 0.0, 1.1, 1.2, 0.0],
        );
        expect(
          xyzRev.valuesByType(Coords.xyzm),
          [
            4.1, 4.2, 4.3, 0.0, 3.1, 3.2, 3.3, 0.0,
            2.1, 2.2, 2.3, 0.0, 1.1, 1.2, 1.3, 0.0
            // ---
          ],
        );
      }
    });

    test('xym', () {
      final coords = [
        1.1, 1.2, 1.4, 2.1, 2.2, 2.4,
        3.1, 3.2, 3.4, 4.1, 4.2, 4.4
        // ---
      ];
      final xymCoords = PositionSeries.view(coords, type: Coords.xym);
      final xymPos = PositionSeries.from([
        [1.1, 1.2, 1.4].xym,
        [2.1, 2.2, 2.4].xym,
        [3.1, 3.2, 3.4].xym,
        [4.1, 4.2, 4.4].xym,
      ]);
      for (final xym in [xymCoords, xymPos]) {
        final xymRev = xym.reversed();
        expect(xym[1], [2.1, 2.2, 2.4].xym);
        expect(xymRev[2], [2.1, 2.2, 2.4].xym);
        expect(
          xymRev.values,
          [4.1, 4.2, 4.4, 3.1, 3.2, 3.4, 2.1, 2.2, 2.4, 1.1, 1.2, 1.4],
        );
        expect(
          xymRev.valuesByType(Coords.xy),
          [4.1, 4.2, 3.1, 3.2, 2.1, 2.2, 1.1, 1.2],
        );
        expect(
          xymRev.valuesByType(Coords.xyz),
          [4.1, 4.2, 0.0, 3.1, 3.2, 0.0, 2.1, 2.2, 0.0, 1.1, 1.2, 0.0],
        );
        expect(
          xymRev.valuesByType(Coords.xym),
          [4.1, 4.2, 4.4, 3.1, 3.2, 3.4, 2.1, 2.2, 2.4, 1.1, 1.2, 1.4],
        );
        expect(
          xymRev.valuesByType(Coords.xyzm),
          [
            4.1, 4.2, 0.0, 4.4, 3.1, 3.2, 0.0, 3.4,
            2.1, 2.2, 0.0, 2.4, 1.1, 1.2, 0.0, 1.4
            // ---
          ],
        );
      }
    });

    test('xyzm', () {
      final coords = [
        1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4,
        3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4
        // ---
      ];
      final xyzmCoords = PositionSeries.view(coords, type: Coords.xyzm);
      final xyzmPos = PositionSeries.from([
        [1.1, 1.2, 1.3, 1.4].xyzm,
        [2.1, 2.2, 2.3, 2.4].xyzm,
        [3.1, 3.2, 3.3, 3.4].xyzm,
        [4.1, 4.2, 4.3, 4.4].xyzm,
      ]);
      for (final xyzm in [xyzmCoords, xyzmPos]) {
        final xyzmRev = xyzm.reversed();
        expect(xyzm[1], [2.1, 2.2, 2.3, 2.4].xyzm);
        expect(xyzmRev[2], [2.1, 2.2, 2.3, 2.4].xyzm);
        expect(
          xyzmRev.values,
          [
            4.1, 4.2, 4.3, 4.4, 3.1, 3.2, 3.3, 3.4,
            2.1, 2.2, 2.3, 2.4, 1.1, 1.2, 1.3, 1.4,
            // ---
          ],
        );
        expect(
          xyzmRev.valuesByType(Coords.xy),
          [4.1, 4.2, 3.1, 3.2, 2.1, 2.2, 1.1, 1.2],
        );
        expect(
          xyzmRev.valuesByType(Coords.xyz),
          [4.1, 4.2, 4.3, 3.1, 3.2, 3.3, 2.1, 2.2, 2.3, 1.1, 1.2, 1.3],
        );
        expect(
          xyzmRev.valuesByType(Coords.xym),
          [4.1, 4.2, 4.4, 3.1, 3.2, 3.4, 2.1, 2.2, 2.4, 1.1, 1.2, 1.4],
        );
        expect(
          xyzmRev.valuesByType(Coords.xyzm),
          [
            4.1, 4.2, 4.3, 4.4, 3.1, 3.2, 3.3, 3.4,
            2.1, 2.2, 2.3, 2.4, 1.1, 1.2, 1.3, 1.4,
            // ---
          ],
        );
      }
    });
  });
}
