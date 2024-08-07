// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: unrelated_type_equality_checks, prefer_const_declarations
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:math' as math;

import 'package:geobase/coordinates.dart';
import 'package:geobase/src/utils/coord_calculations_cartesian.dart';

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
        expect(array3.coordType, type);
        expect(array3FromText.coordType, type);
        expect(array3FromPositions.coordType, type);

        expect(array3FromText.equalsCoords(array3), true);
        expect(array3FromPositions.equalsCoords(array3), true);
      });

      test('Access positions as PositionData', () {
        final positions = array3;
        expect(positions.positionCount, 3);
        expect(positions.coordType, type);

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
        expect(array3.coordType, type);

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
      expect(xyArray3.coordType, Coords.xy);
    });

    test('Access as projected positions', () {
      final projected = xyArray3.positionsAs(to: Projected.create).toList();
      expect(projected.length, 3);
      expect(projected.first.coordType, Coords.xy);

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
      expect(xyzmArray3.coordType, Coords.xyzm);
    });

    test('Access projected positions', () {
      final projected = xyzmArray3.positionsAs(to: Projected.create).toList();
      expect(projected.length, 3);
      expect(projected.first.coordType, Coords.xyzm);

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
            2.1, 2.2, 0.0, 0.0, 1.1, 1.2, 0.0, 0.0,
            // ---
          ],
        );
      }
    });

    test('xyz', () {
      final coords = [
        1.1, 1.2, 1.3, 2.1, 2.2, 2.3,
        3.1, 3.2, 3.3, 4.1, 4.2, 4.3,
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
            2.1, 2.2, 2.3, 0.0, 1.1, 1.2, 1.3, 0.0,
            // ---
          ],
        );
      }
    });

    test('xym', () {
      final coords = [
        1.1, 1.2, 1.4, 2.1, 2.2, 2.4,
        3.1, 3.2, 3.4, 4.1, 4.2, 4.4,
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
            2.1, 2.2, 0.0, 2.4, 1.1, 1.2, 0.0, 1.4,
            // ---
          ],
        );
      }
    });

    test('xyzm', () {
      final coords = [
        1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4,
        3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4,
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

  group('PositionSeries manipulations and cartesian calculations', () {
    final series1xy = [
      [1.0, 1.0].xy,
      [1.0, 2.0].xy,
      [2.0, 2.0].xy,
    ].series();
    final series2xy = [
      [1.0, 1.0].xy,
      [2.0, 2.0].xy,
      [3.0, 3.0].xy,
    ].series();
    final series3xyz = [
      [1.0, 1.0, 1.0].xyz,
      [1.0, 2.0, 1.0].xyz,
      [2.0, 2.0, 1.0].xyz,
      [2.0, 2.0, 2.0].xyz,
    ].series();

    test('Range', () {
      expect(series1xy.range(1).values, series1xy.range(1, 3).values);
      expect(series1xy.range(1).values, [1.0, 2.0, 2.0, 2.0]);
      expect(series1xy.reversed().range(1).values, [1.0, 2.0, 1.0, 1.0]);
      final flat1xy = PositionSeries.view(series1xy.values.toList());
      expect(flat1xy.range(1).values, [1.0, 2.0, 2.0, 2.0]);
      expect(flat1xy.reversed().range(1).values, [1.0, 2.0, 1.0, 1.0]);

      expect(series3xyz.range(2).values, series3xyz.range(2, 4).values);
      expect(series3xyz.range(2).values, [2.0, 2.0, 1.0, 2.0, 2.0, 2.0]);
      expect(
        series3xyz.reversed().range(2).values,
        [1.0, 2.0, 1.0, 1.0, 1.0, 1.0],
      );
      final flat3xyz =
          PositionSeries.view(series3xyz.values.toList(), type: Coords.xyz);
      expect(flat3xyz.range(2).values, [2.0, 2.0, 1.0, 2.0, 2.0, 2.0]);
      expect(
        flat3xyz.reversed().range(2).values,
        [1.0, 2.0, 1.0, 1.0, 1.0, 1.0],
      );
    });

    test('RangeRemoved', () {
      expect(
        series1xy.rangeRemoved(1).values,
        series1xy.rangeRemoved(1, 3).values,
      );
      expect(
        series1xy.rangeRemoved(0, 3).values,
        series1xy.range(0, 0).values,
      );
      expect(
        series1xy.rangeRemoved(1, 3).values,
        series1xy.range(0, 1).values,
      );
      expect(
        series1xy.rangeRemoved(0, 1).values,
        series1xy.range(1).values,
      );
      expect(
        series1xy.rangeRemoved(1).values,
        series1xy.range(0, 1).values,
      );
      expect(series1xy.rangeRemoved(1).values, [1.0, 1.0]);
      expect(series1xy.reversed().rangeRemoved(1).values, [2.0, 2.0]);
      final flat1xy = PositionSeries.view(series1xy.values.toList());
      expect(flat1xy.rangeRemoved(1).values, flat1xy.rangeRemoved(1, 3).values);
      expect(flat1xy.rangeRemoved(0, 3).values, flat1xy.range(0, 0).values);
      expect(flat1xy.rangeRemoved(1, 3).values, flat1xy.range(0, 1).values);
      expect(flat1xy.rangeRemoved(0, 1).values, flat1xy.range(1).values);
      expect(flat1xy.rangeRemoved(1).values, flat1xy.range(0, 1).values);
      expect(flat1xy.rangeRemoved(1).values, [1.0, 1.0]);
      expect(flat1xy.reversed().rangeRemoved(1).values, [2.0, 2.0]);

      expect(
        series3xyz.rangeRemoved(2).values,
        series3xyz.range(0, 2).values,
      );
      expect(
        series3xyz.rangeRemoved(1, 3).values,
        [1.0, 1.0, 1.0, 2.0, 2.0, 2.0],
      );
      expect(
        series3xyz.reversed().rangeRemoved(1, 3).values,
        [2.0, 2.0, 2.0, 1.0, 1.0, 1.0],
      );
      final flat3xyz =
          PositionSeries.view(series3xyz.values.toList(), type: Coords.xyz);
      expect(
        flat3xyz.rangeRemoved(2, 3).values,
        [1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 2.0, 2.0, 2.0],
      );
      expect(
        flat3xyz.reversed().rangeRemoved(2, 3).values,
        [2.0, 2.0, 2.0, 2.0, 2.0, 1.0, 1.0, 1.0, 1.0],
      );
    });

    test('RangeReplaced', () {
      for (final s1xy in [
        series1xy,
        PositionSeries.view(series1xy.values.toList()),
      ]) {
        expect(
          s1xy.rangeReplaced(1, 2, [
            [1.1, 2.1].xy,
          ]).values,
          [1.0, 1.0, 1.1, 2.1, 2.0, 2.0],
        );
        expect(
          s1xy.rangeReplaced(1, 3, [
            [1.1, 2.1].xy,
          ]).values,
          [1.0, 1.0, 1.1, 2.1],
        );
        expect(
          s1xy.reversed().rangeReplaced(1, 3, [
            [1.1, 2.1].xy,
            [1.2, 2.2].xy,
          ]).values,
          [2.0, 2.0, 1.1, 2.1, 1.2, 2.2],
        );
        expect(
          s1xy.reversed().rangeReplaced(1, 1, [
            [1.1, 2.1].xy,
            [1.2, 2.2].xy,
          ]).values,
          [2.0, 2.0, 1.1, 2.1, 1.2, 2.2, 1.0, 2.0, 1.0, 1.0],
        );
        expect(
          s1xy.reversed().rangeReplaced(1, 1, const []).values,
          [2.0, 2.0, 1.0, 2.0, 1.0, 1.0],
        );
      }
      for (final s3xyz in [
        series3xyz,
        PositionSeries.view(series3xyz.values.toList(), type: Coords.xyz),
      ]) {
        expect(
          s3xyz.rangeReplaced(1, 2, [
            [1.1, 2.1, 1.1].xyz,
          ]).values,
          [1.0, 1.0, 1.0, 1.1, 2.1, 1.1, 2.0, 2.0, 1.0, 2.0, 2.0, 2.0],
        );
        expect(
          s3xyz.reversed().rangeReplaced(1, 3, [
            [1.1, 2.1].xy,
            [1.2, 2.2, 2.2].xyz,
          ]).values,
          [2.0, 2.0, 2.0, 1.1, 2.1, 0.0, 1.2, 2.2, 2.2, 1.0, 1.0, 1.0],
        );
      }
    });

    test('Inserted', () {
      for (final s1xy in [
        series1xy,
        PositionSeries.view(series1xy.values.toList()),
      ]) {
        expect(
          s1xy.inserted(1, [
            [1.1, 2.1].xy,
          ]).values,
          [1.0, 1.0, 1.1, 2.1, 1.0, 2.0, 2.0, 2.0],
        );
        expect(
          s1xy.reversed().inserted(1, [
            [1.1, 2.1].xy,
            [1.2, 2.2].xy,
          ]).values,
          [2.0, 2.0, 1.1, 2.1, 1.2, 2.2, 1.0, 2.0, 1.0, 1.0],
        );
      }
      for (final s3xyz in [
        series3xyz,
        PositionSeries.view(series3xyz.values.toList(), type: Coords.xyz),
      ]) {
        expect(
          s3xyz.inserted(1, [
            [1.1, 2.1, 1.1].xyz,
          ]).values,
          [
            1.0, 1.0, 1.0, 1.1, 2.1, 1.1, 1.0, 2.0, 1.0,
            2.0, 2.0, 1.0, 2.0, 2.0, 2.0, //
          ],
        );
      }
    });

    test('Added', () {
      for (final s1xy in [
        series1xy,
        PositionSeries.view(series1xy.values.toList()),
      ]) {
        expect(
          s1xy.added([
            [1.1, 2.1].xy,
          ]).values,
          [1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 1.1, 2.1],
        );
        expect(
          s1xy.reversed().added([
            [1.1, 2.1].xy,
            [1.2, 2.2].xy,
          ]).values,
          [2.0, 2.0, 1.0, 2.0, 1.0, 1.0, 1.1, 2.1, 1.2, 2.2],
        );
      }
      for (final s3xyz in [
        series3xyz,
        series3xyz.packed(),
        PositionSeries.view(series3xyz.values.toList(), type: Coords.xyz),
        PositionSeries.view(series3xyz.values.toList(), type: Coords.xyz)
            .packed(singlePrecision: true),
      ]) {
        expect(
          s3xyz.added([
            [1.1, 2.1, 1.1].xyz,
          ]).values,
          [
            1.0, 1.0, 1.0, 1.0, 2.0, 1.0,
            2.0, 2.0, 1.0, 2.0, 2.0, 2.0, 1.1, 2.1, 1.1, //
          ],
        );
      }
    });

    test('Sorted', () {
      for (final s1xy in [
        series1xy,
        series1xy.packed(),
        series1xy.packed(singlePrecision: true),
        PositionSeries.view(series1xy.values.toList()),
      ]) {
        expect(
          s1xy.sorted((a, b) => ((a.x + a.y) - (b.x + b.y)).round()).values,
          [1.0, 1.0, 1.0, 2.0, 2.0, 2.0],
        );
        expect(
          s1xy.sorted((a, b) => -((a.x + a.y) - (b.x + b.y)).round()).values,
          [2.0, 2.0, 1.0, 2.0, 1.0, 1.0],
        );
      }
    });

    test('Filtered', () {
      for (final s1xy in [
        series1xy,
        series1xy.packed(),
        series1xy.packed(singlePrecision: true),
        PositionSeries.view(series1xy.values.toList()),
      ]) {
        expect(
          s1xy.filtered((count, index, pos) => pos.x + pos.y <= 3.5).values,
          [1.0, 1.0, 1.0, 2.0],
        );
        expect(
          s1xy.filtered((count, index, pos) => index < count - 2).values,
          [1.0, 1.0],
        );
        expect(
          s1xy.reversed().filtered((count, index, pos) => true).values,
          [2.0, 2.0, 1.0, 2.0, 1.0, 1.0],
        );
        expect(
          s1xy.reversed().filtered((count, index, pos) => false).values,
          <double>[],
        );
      }
    });

    test('Length2D', () {
      expect(series1xy.length2D(), 2.0);
      expect(series1xy.reversed().length2D(), 2.0);

      expect(series2xy.length2D(), 2.8284271247461903);
      expect(series2xy.range(1).length2D(), 1.4142135623730951);
    });

    test('Length3D', () {
      expect(series3xyz.length3D(), 3.0);
      expect(series3xyz.reversed().length3D(), 3.0);
    });

    test('Area2D and centroid2D (and partially distance2D)', () {
      final rectangle = [
        [1.0, 1.0].xy,
        [2.0, 1.0].xy,
        [2.0, 2.0].xy,
        [1.0, 2.0].xy,
        [1.0, 1.0].xy,
      ].series();
      final rectangleNC = rectangle.range(0, 4);
      expect(rectangle.signedArea2D(), 1.0);
      expect(rectangle.range(0, 4).signedArea2D(), 1.0);
      expect(rectangle.range(0, 3).signedArea2D(), 0.5);
      expect(rectangle.range(1, 5).signedArea2D(), 1.0);
      expect(rectangle.reversed().signedArea2D(), -1.0);
      expect((rectangle * 2.0).signedArea2D(), 4.0);
      expect((rectangle * -3.0).signedArea2D(), 9.0);
      expect(rectangle.length2D(), 4.0);
      expect(rectangle.range(0, 4).length2D(), 3.0);
      expect(rectangle.centroid2D(), [1.5, 1.5].xy);
      expect((rectangle * 2.0).centroid2D(), [3.0, 3.0].xy);
      expect(rectangleNC.centroid2D(), [1.5, 1.5].xy);
      expect(
        rectangleNC.centroid2D(dimensionality: Dimensionality.punctual),
        [1.5, 1.5].xy,
      );
      expect(
        rectangle.centroid2D(dimensionality: Dimensionality.linear),
        [1.5, 1.5].xy,
      );
      expect(
        rectangle.distanceTo2D(
          [1.5, 1.5].xy,
          dimensionality: Dimensionality.areal,
        ),
        0.5,
      );
      expect(
        rectangle.distanceTo2D(
          [1.5, 2.5].xy,
          dimensionality: Dimensionality.linear,
        ),
        0.5,
      );
      expect(
        rectangle.distanceTo2D(
          [1.5, 2.5].xy,
          dimensionality: Dimensionality.punctual,
        ),
        0.7071067811865476,
      );

      final centroidTest1 = [
        [2.0, 4.0].xy,
        [5.0, -1.0].xy,
        [-4.0, 10.0].xy,
      ].series();
      expect(centroidTest1.centroid2D()!.toText(decimals: 2), '1,4.33');
      final centroidTest2 = [
        [4.0, 5.0].xy,
        [30.0, 6.0].xy,
        [20.0, 25.0].xy,
      ].series();
      expect(centroidTest2.centroid2D(), [18.0, 12.0].xy);
      expect(
        centroidTest2.added([
          [4.0, 5.0].xy,
        ]).centroid2D(),
        [18.0, 12.0].xy,
      );
      expect(centroidTest2.range(0, 2).centroid2D(), [17.0, 5.5].xy);
      expect(centroidTest2.range(1, 2).centroid2D(), [30.0, 6.0].xy);

      final straightLine = [
        [1.0, 0.0].xy,
        [2.0, 0.0].xy,
        [6.0, 0.0].xy,
      ].series();
      expect(
        // not actually areal, so calculated as linear
        straightLine.centroid2D(dimensionality: Dimensionality.areal),
        [3.5, 0.0].xy,
      );
      expect(
        straightLine.centroid2D(dimensionality: Dimensionality.linear),
        [3.5, 0.0].xy,
      );
      expect(
        straightLine.centroid2D(dimensionality: Dimensionality.punctual),
        [3.0, 0.0].xy,
      );

      final triangle = [
        [1.0, 1.0].xy,
        [2.0, 1.0].xy,
        [2.0, 2.0].xy,
        [1.0, 1.0].xy,
      ].series();
      expect(triangle.signedArea2D(), 0.5);
      expect(triangle.range(0, 3).signedArea2D(), 0.5);
      expect(triangle.range(0, 2).signedArea2D(), 0.0);
      expect((triangle * 4.0).signedArea2D(), 8.0);
      expect(
        triangle.centroid2D(dimensionality: Dimensionality.punctual),
        [1.5, 1.25].xy,
      );
      expect(
        triangle
            .centroid2D(dimensionality: Dimensionality.linear)!
            .toText(decimals: 3),
        '1.646,1.354',
      );
      expect(
        triangle
            .centroid2D(dimensionality: Dimensionality.areal)!
            .toText(decimals: 3),
        '1.667,1.333',
      );

      final shape = [
        [1.0, 0.0].xy,
        [1.0, 1.0].xy,
        [3.0, 0.0].xy,
        [3.0, 1.0].xy,
        [2.0, 2.0].xy,
        [1.0, 1.0].xy,
        [1.0, 2.0].xy,
        [2.0, 3.0].xy,
        [1.0, 3.0].xy,
        [1.0, 4.0].xy,
        [2.0, 5.0].xy,
        [4.0, 5.0].xy,
        [4.0, 2.0].xy,
        [3.0, 3.0].xy,
        [3.0, 2.0].xy,
        [4.0, 1.0].xy,
        [5.0, 1.0].xy,
        [5.0, 6.0].xy,
        [1.0, 6.0].xy,
        [1.0, 5.0].xy,
        [0.0, 4.0].xy,
        [0.0, 1.0].xy,
        [1.0, 0.0].xy,
      ].series();
      expect(shape.signedArea2D(), 16.0);
      expect((shape * 2.0).signedArea2D(), 64.0);
      expect((shape * -2.0).signedArea2D(), 64.0);
      expect(shape.range(1).signedArea2D(), 16.0);
      expect(shape.range(5).signedArea2D(), 14.0);
      expect(shape.reversed().signedArea2D(), -16.0);
      expect(
        shape
            .centroid2D(dimensionality: Dimensionality.punctual)!
            .toText(decimals: 3),
        '2.130,2.522',
      );
      expect(
        shape
            .centroid2D(dimensionality: Dimensionality.linear)!
            .toText(decimals: 3),
        '2.508,2.996',
      );
      expect(
        shape
            .centroid2D(dimensionality: Dimensionality.areal)!
            .toText(decimals: 3),
        '2.583,3.229',
      );

      final selfTouching = [
        [0.0, 0.0].xy,
        [1.0, 0.0].xy,
        [1.0, 3.0].xy,
        [3.0, 3.0].xy,
        [1.0, 1.0].xy,
        [4.0, 1.0].xy,
        [4.0, 4.0].xy,
        [0.0, 4.0].xy,
        [0.0, 0.0].xy,
      ].series();
      expect(selfTouching.signedArea2D(), 11.0);
      expect(selfTouching.reversed().signedArea2D(), -11.0);
      expect(selfTouching.range(1).reversed().signedArea2D(), -11.0);

      final selfTouchingWithHole = [
        [0.0, 0.0].xy,
        [4.0, 0.0].xy,
        [4.0, 4.0].xy,
        [2.0, 4.0].xy,
        [2.0, 3.0].xy,
        [3.0, 3.0].xy,
        [3.0, 2.0].xy,
        [2.0, 2.0].xy,
        [2.0, 1.0].xy,
        [1.0, 1.0].xy,
        [1.0, 2.0].xy,
        [2.0, 3.0].xy,
        [2.0, 4.0].xy,
        [0.0, 4.0].xy,
        [0.0, 0.0].xy,
      ].series();
      expect(selfTouchingWithHole.signedArea2D(), 13.5);
      expect(selfTouchingWithHole.range(1).signedArea2D(), 13.5);
      expect(selfTouchingWithHole.reversed().signedArea2D(), -13.5);

      final selfIntersectingNotValid = [
        [0.0, 0.0].xy,
        [1.0, 0.0].xy,
        [1.0, 3.0].xy,
        [3.0, 3.0].xy,
        [0.0, 0.0].xy,
        [4.0, 0.0].xy,
        [4.0, 4.0].xy,
        [0.0, 4.0].xy,
        [0.0, 0.0].xy,
      ].series();
      expect(selfIntersectingNotValid.signedArea2D(), 14.5);
      expect(selfIntersectingNotValid.reversed().signedArea2D(), -14.5);
      expect(
        selfIntersectingNotValid.range(1).reversed().signedArea2D(),
        -14.5,
      );

      // http://en.wikipedia.org/wiki/Shoelace_formula
      final shoelaceSample = [
        [1.0, 6.0].xy,
        [3.0, 1.0].xy,
        [7.0, 2.0].xy,
        [4.0, 4.0].xy,
        [8.0, 5.0].xy,
        [1.0, 6.0].xy,
      ].series();
      expect(shoelaceSample.signedArea2D(), 16.5);
      expect(shoelaceSample.range(1).signedArea2D(), 16.5);
      expect(shoelaceSample.reversed().signedArea2D(), -16.5);
      expect(shoelaceSample.range(1).reversed().signedArea2D(), -16.5);
      final p1 = [3.0, 1.0].xy;
      final p2 = [7.0, 2.0].xy;
      final p3 = [4.0, 4.0].xy;
      final p4 = [8.0, 6.0].xy;
      final p5 = [1.0, 7.0].xy;
      final q = [4.0, 3.0].xy;
      final shoelaceBlue = [p1, p2, p3, p4, p5].series();
      final shoelaceGreen = [p2, p3, p4].series();
      final shoelaceRed = [p1, q, p2].series();
      final shoelaceBlueMinusP3 = [p1, p2, p4, p5].series();
      final shoelaceBluePlusQ = [p1, q, p2, p3, p4, p5].series();
      expect(shoelaceBlue.signedArea2D(), 20.5);
      expect(shoelaceBlue.reversed().signedArea2D(), -20.5);
      expect(shoelaceGreen.signedArea2D(), -7.0);
      expect(shoelaceGreen.reversed().signedArea2D(), 7.0);
      expect(shoelaceRed.signedArea2D(), -3.5);
      expect(shoelaceRed.reversed().signedArea2D(), 3.5);
      expect(shoelaceBlueMinusP3.signedArea2D(), 27.5);
      expect(shoelaceBlueMinusP3.reversed().signedArea2D(), -27.5);
      expect(shoelaceBluePlusQ.signedArea2D(), 17.0);
      expect(shoelaceBluePlusQ.reversed().signedArea2D(), -17.0);

      // https://postgis.net/docs/ST_Centroid.html
      final stPoints = PositionSeries.parse(
        '-1,0,-1,2,-1,3,-1,4,-1,7,0,1,0,3,1,1,2,0,6,0,7,8,9,8,10,6',
      );
      expect(
        stPoints
            .centroid2D(dimensionality: Dimensionality.punctual)!
            .toText(decimals: 14),
        '2.30769230769231,3.30769230769231',
      );
      final stPolygon = PositionSeries.parse(
        '0,2,-1,1,0,0,0.5,0,1,0,2,1,1,2,0.5,2,0,2',
      );
      expect(
        stPolygon.centroid2D(dimensionality: Dimensionality.areal),
        [0.5, 1.0].xy,
      );

      // https://postgis.net/docs/ST_Area.html
      // https://postgis.net/docs/ST_Length.html
      final stPolygon2 = PositionSeries.parse(
        '743238,2967416,743238,2967450,743265,2967450,'
        '743265.625,2967416,743238,2967416',
      );
      expect(stPolygon2.reversed().signedArea2D(), closeTo(928.625, 0.001));
      expect(stPolygon2.length2D(), closeTo(122.630744000095, 0.000000001));
    });

    test('distanceTo2D tests', () {
      void testAreal(PositionSeries series, Position pos, double dist) {
        expect(
          series.distanceTo2D(pos, dimensionality: Dimensionality.areal),
          dist,
        );
      }

      void testLinear(PositionSeries series, Position pos, double dist) {
        expect(
          series.distanceTo2D(pos, dimensionality: Dimensionality.linear),
          dist,
        );
      }

      void testPunctual(PositionSeries series, Position pos, double dist) {
        expect(
          series.distanceTo2D(pos, dimensionality: Dimensionality.punctual),
          dist,
        );
      }

      final s1 = [0.0, 0.0, 1.0, 1.0, 3.0, 1.0].positions();
      testAreal(s1, [2.0, 0.0].xy, 0.6324555320336759);
      testAreal(s1, [1.5, 0.0].xy, 0.4743416490252569);
      testLinear(s1, [2.0, 0.0].xy, 1.0);
      testPunctual(s1, [2.0, 0.0].xy, math.sqrt2);

      final s2 = [0.0, 0.0, 0.0, 1.0, 10.0, 1.0, 10.0, 0.0].positions();
      testAreal(s2, [0.5, 0.5].xy, 0.5);
      testLinear(s2, [0.5, 0.5].xy, 0.5);
      testPunctual(s2, [0.5, 0.5].xy, math.sqrt2 / 2);
      testAreal(s2, [9.0, 0.0].xy, 0.0);
      testAreal(s2, [9.0, 0.5].xy, 0.5);
      testLinear(s2, [9.0, 0.0].xy, 1.0);
      testPunctual(s2, [9.0, 0.0].xy, 1.0);
      testAreal(s2, [5.0, 0.0].xy, 0.0);
      testLinear(s2, [5.0, 0.0].xy, 1.0);
      testPunctual(s2, [5.0, 0.0].xy, 5.0);
      testAreal(s2, [5.0, 0.5].xy, 0.5);
      testLinear(s2, [5.0, 0.5].xy, 0.5);
      testPunctual(s2, [5.0, 0.5].xy, 5.024937810560445);
    });

    test('Scale', () {
      expect(
        (series3xyz * 1.5).values,
        [
          [1.5, 1.5, 1.5].xyz,
          [1.5, 3.0, 1.5].xyz,
          [3.0, 3.0, 1.5].xyz,
          [3.0, 3.0, 3.0].xyz,
        ].series().values,
      );
    });

    test('Negate and scale via operators and transform and filter', () {
      final expected3xyz = [
        [-1.5, -1.5, -1.5].xyz,
        [-1.5, -3.0, -1.5].xyz,
        [-3.0, -3.0, -1.5].xyz,
        [-3.0, -3.0, -3.0].xyz,
      ].series();
      expect((-series3xyz * 1.5).values, expected3xyz.values);

      expect(
        series3xyz.transform(_transformPosition(true, 1.5)).values,
        expected3xyz.values,
      );
      expect(
        series3xyz.transform(_transformPosition(false, 1.5)).values,
        (-expected3xyz).values,
      );

      expect(
        expected3xyz[0].expand(_filterPosition([1.0, 1.0, 2.0, 2.0].box)),
        const <Position>[],
      );
      expect(
        expected3xyz[0].expand(_filterPosition([-2.0, -2.0, -1.0, -1.0].box)),
        expected3xyz.range(0, 1).positions,
      );

      expect(
        expected3xyz.expand(_filterPosition([2.0, 2.0, 1.0, 1.0].box)).values,
        PositionSeries.empty().values,
      );
      expect(
        expected3xyz
            .expand(_filterPosition([-2.0, -2.0, -1.0, -1.0].box))
            .values,
        expected3xyz.range(0, 1).values,
      );
      expect(
        expected3xyz
            .expand(_filterPosition([-2.0, -2.0, -1.0, -1.0].box, true))
            .values,
        expected3xyz
            .range(0, 1)
            .values
            .followedBy(expected3xyz.range(0, 1).values),
      );
      expect(
        expected3xyz
            .expand(_filterPosition([-2.0, -3.0, -1.0, -1.0].box))
            .values,
        expected3xyz.range(0, 2).values,
      );
    });

    test('Transform sample', () {
      final series = [
        [10.0, 11.0].xy,
        [20.0, 21.0].xy,
        [30.0, 31.0].xy,
      ].series();

      final transformed = series.transform(_sampleTransform);

      expect(
        transformed.values,
        [
          [15.0, 22.0].xy,
          [25.0, 42.0].xy,
          [35.0, 62.0].xy,
        ].series().values,
      );

      expect(
        [
          [10.0, 11.0, 12.0, 13.0].xyzm,
          [20.0, 21.0, 22.0, 23.0].xyzm,
          [30.0, 31.0, 32.0, 33.0].xyzm,
        ].series().transform(_sampleTransform).values,
        [
          [15.0, 22.0, 12.0].xyz,
          [25.0, 42.0, 22.0].xyz,
          [35.0, 62.0, 32.0].xyz,
        ].series().values,
      );

      expect([10.0, 11.0].xy.transform(_sampleTransform), [15.0, 22.0].xy);
    });
  });
}

/// A sample transform function for positions that translates `x` by 5.0, scales
/// `y` by 2.0, keeps `z` intact (null or a value), and ensures `m` is cleared.
T _sampleTransform<T extends Position>(
  Position source, {
  required CreatePosition<T> to,
}) =>
    // call factory to create a transformed position
    to.call(
      x: source.x + 5.0, // translate x by 5.0
      y: source.y * 2.0, // scale y by 2.0
      z: source.optZ, // copy z value from source (null or a value)
      m: null, // set m null even if source has null
    );

TransformPosition _transformPosition(bool negate, double scale) {
  return <T extends Position>(
    Position source, {
    required CreatePosition<T> to,
  }) {
    if (negate) {
      return cartesianPositionScale(
        cartesianPositionNegate(source, to: to),
        factor: scale,
        to: to,
      );
    } else {
      return cartesianPositionScale(
        source,
        factor: scale,
        to: to,
      );
    }
  };
}

ExpandPosition _filterPosition(Box inside, [bool twice = false]) {
  return <T extends Position>(
    Position source, {
    required CreatePosition<T> to,
  }) {
    if (inside.intersectsPoint2D(source)) {
      final pos = source is T ? source : source.copyTo(to);
      return [
        pos,
        if (twice) pos,
      ];
    } else {
      return const Iterable.empty();
    }
  };
}
