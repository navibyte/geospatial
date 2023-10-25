// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: unrelated_type_equality_checks, prefer_const_declarations

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

  group('PositionSeries cartesian calculations', () {
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

    test('Length2D', () {
      expect(series1xy.length2D(), 2.0);
      expect(series1xy.reversed().length2D(), 2.0);

      expect(series2xy.length2D(), 2.8284271247461903);
      expect(series2xy.subseries(1).length2D(), 1.4142135623730951);
    });

    test('Length3D', () {
      expect(series3xyz.length3D(), 3.0);
      expect(series3xyz.reversed().length3D(), 3.0);
    });

    test('Area3D', () {
      final rectangle = [
        [1.0, 1.0].xy,
        [2.0, 1.0].xy,
        [2.0, 2.0].xy,
        [1.0, 2.0].xy,
        [1.0, 1.0].xy,
      ].series();
      expect(rectangle.signedArea2D(), 1.0);
      expect(rectangle.subseries(0, 4).signedArea2D(), 1.0);
      expect(rectangle.subseries(0, 3).signedArea2D(), 0.5);
      expect(rectangle.subseries(1, 5).signedArea2D(), 1.0);
      expect(rectangle.reversed().signedArea2D(), -1.0);
      expect((rectangle * 2.0).signedArea2D(), 4.0);
      expect((rectangle * -3.0).signedArea2D(), 9.0);
      expect(rectangle.length2D(), 4.0);
      expect(rectangle.subseries(0, 4).length2D(), 3.0);

      final triangle = [
        [1.0, 1.0].xy,
        [2.0, 1.0].xy,
        [2.0, 2.0].xy,
        [1.0, 1.0].xy,
      ].series();
      expect(triangle.signedArea2D(), 0.5);
      expect(triangle.subseries(0, 3).signedArea2D(), 0.5);
      expect(triangle.subseries(0, 2).signedArea2D(), 0.0);
      expect((triangle * 4.0).signedArea2D(), 8.0);

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
      expect(shape.subseries(1).signedArea2D(), 16.0);
      expect(shape.subseries(5).signedArea2D(), 14.0);
      expect(shape.reversed().signedArea2D(), -16.0);

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
      expect(selfTouching.subseries(1).reversed().signedArea2D(), -11.0);

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
      expect(selfTouchingWithHole.subseries(1).signedArea2D(), 13.5);
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
        selfIntersectingNotValid.subseries(1).reversed().signedArea2D(),
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
      expect(shoelaceSample.subseries(1).signedArea2D(), 16.5);
      expect(shoelaceSample.reversed().signedArea2D(), -16.5);
      expect(shoelaceSample.subseries(1).reversed().signedArea2D(), -16.5);
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
        expected3xyz.subseries(0, 1).positions,
      );

      expect(
        expected3xyz.expand(_filterPosition([2.0, 2.0, 1.0, 1.0].box)).values,
        PositionSeries.empty().values,
      );
      expect(
        expected3xyz
            .expand(_filterPosition([-2.0, -2.0, -1.0, -1.0].box))
            .values,
        expected3xyz.subseries(0, 1).values,
      );
      expect(
        expected3xyz
            .expand(_filterPosition([-2.0, -2.0, -1.0, -1.0].box, true))
            .values,
        expected3xyz
            .subseries(0, 1)
            .values
            .followedBy(expected3xyz.subseries(0, 1).values),
      );
      expect(
        expected3xyz
            .expand(_filterPosition([-2.0, -3.0, -1.0, -1.0].box))
            .values,
        expected3xyz.subseries(0, 2).values,
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
