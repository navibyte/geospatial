// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print, unused_local_variable

import 'dart:typed_data';

import 'package:geobase/geobase.dart';

/*
To test run this from command line: 

dart test/coordinates/coordinates_bench.dart
*/

void main() {
  _positionSeries();
}

void _positionSeries() {
  print('Test PositionSeries performance');
  print('');

  const n = 10000;
  const valueCount = 500;
  const posCount = 250;

  final tests = <String, PositionSeries Function()>{
    'View on List<double>': () {
      final coords = List<double>.filled(2 * posCount, 0.0);
      for (var j = 0; j < valueCount; j++) {
        coords[j] = j.toDouble();
      }
      return PositionSeries.view(coords);
    },
    'View on Float64List': () {
      final coords = Float64List(2 * posCount);
      for (var j = 0; j < valueCount; j++) {
        coords[j] = j.toDouble();
      }
      return PositionSeries.view(coords);
    },
    'View on Float32List': () {
      final coords = Float32List(2 * posCount);
      for (var j = 0; j < valueCount; j++) {
        coords[j] = j.toDouble();
      }
      return PositionSeries.view(coords);
    },
    'Array of positions': () {
      final positions1 = <Position>[
        for (var index = 0; index < posCount; index++)
          Projected(x: index * 2, y: index * 2 + 1),
      ];
      return PositionSeries.from(positions1, type: Coords.xy);
    },
  };

  var val1 = 0.0;
  var val2 = 0.0;

  for (final test in tests.entries) {
    var sw = Stopwatch()..start();
    print('Case: ${test.key}');

    final factory = test.value;

    // benchmark creating position series
    final arrays = <PositionSeries>[];
    for (var i = 0; i < n; i++) {
      arrays.add(factory.call());
    }
    sw.stop();
    print('Create PositionSeries: ${sw.elapsedMilliseconds} ms');

    // benchmark equalsCoords
    sw = Stopwatch()..start();
    for (var i = 1; i < n; i++) {
      final series1 = arrays[i - 1];
      final series2 = arrays[i];
      if (!series1.equalsCoords(series2)) {
        throw const FormatException('equalsCoords failed');
      }
    }
    sw.stop();
    print('Equals coords: ${sw.elapsedMilliseconds} ms');

    // benchmark equals2D
    sw = Stopwatch()..start();
    for (var i = 1; i < n; i++) {
      final series1 = arrays[i - 1];
      final series2 = arrays[i];
      if (!series1.equals2D(series2)) {
        throw const FormatException('equals2D failed');
      }
    }
    sw.stop();
    print('Equals2D: ${sw.elapsedMilliseconds} ms');

    // benchmark access x and y via positions
    sw = Stopwatch()..start();
    for (var i = 0; i < n; i++) {
      final series = arrays[i];
      for (final pos in series.positions) {
        val1 += pos.x;
        val2 += pos.y;
      }
    }
    sw.stop();
    print('Access x and y via positions: ${sw.elapsedMilliseconds} ms');

    // benchmark access x and y directly
    sw = Stopwatch()..start();
    for (var i = 0; i < n; i++) {
      final series = arrays[i];
      for (var j = 0; j < posCount; j++) {
        val1 += series.x(j);
        val2 += series.y(j);
      }
    }
    sw.stop();
    print('Access x and y directly: ${sw.elapsedMilliseconds} ms');

    // benchmark access values
    sw = Stopwatch()..start();
    for (var i = 0; i < n; i++) {
      final series = arrays[i];
      for (final v in series.values) {
        val1 += v;
      }
    }
    sw.stop();
    print('Access values: ${sw.elapsedMilliseconds} ms');

    // benchmark access reversed values
    sw = Stopwatch()..start();
    for (var i = 0; i < n; i++) {
      final series = arrays[i];
      for (final v in series.reversed().values) {
        val1 += v;
      }
    }
    sw.stop();
    print('Access reversed values: ${sw.elapsedMilliseconds} ms');

    // benchmark access valuesByType
    sw = Stopwatch()..start();
    for (var i = 0; i < n; i++) {
      final series = arrays[i];
      for (final v in series.valuesByType(Coords.xyzm)) {
        val1 += v;
      }
    }
    sw.stop();
    print('Access valuesByType: ${sw.elapsedMilliseconds} ms');

    print('');
  }
}
