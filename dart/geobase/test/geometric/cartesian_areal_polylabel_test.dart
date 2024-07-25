// Ported from: https://github.com/mapbox/polylabel/blob/master/test/test.js
//              https://github.com/mapbox/polylabel/blob/master/LICENSE

/*
ISC License
Copyright (c) 2016 Mapbox

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND ISC DISCLAIMS ALL WARRANTIES WITH REGARD TO
THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS.
IN NO EVENT SHALL ISC BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.
*/

// Adaptations on the derivative work (the Dart port):
//
// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_redundant_argument_values, avoid_dynamic_calls

import 'dart:convert';

// importing `dart:io` not supported on the Flutter web platform
import 'dart:io' show File;

import 'package:geobase/coordinates.dart';
import 'package:geobase/geometric.dart';

import 'package:test/test.dart';

void main() {
  group(
      'geometric-cartesian-areal-polylabel tests from mapbox/polylabel package',
      () {
    final water1 = _readPolygon('water1');
    final water2 = _readPolygon('water2');

    test('finds pole of inaccessibility for water1 and precision 1', () {
      final p = water1.polylabel2D(precision: 1.0);
      expect(
        p,
        DistancedPosition(
          Position.create(x: 3865.85009765625, y: 2124.87841796875),
          288.8493574779127,
        ),
      );
    });

    test('finds pole of inaccessibility for water1 and precision 50', () {
      final p = water1.polylabel2D(precision: 50.0);
      expect(
        p,
        DistancedPosition(
          Position.create(x: 3854.296875, y: 2123.828125),
          278.5795872381558,
        ),
      );
    });

    test('finds pole of inaccessibility for water2 and precision 1', () {
      final p = water2.polylabel2D(precision: 1.0);
      expect(
        p,
        DistancedPosition(
          Position.create(x: 3263.5, y: 3263.5),
          960.5,
        ),
      );
    });

    test('works on degenerate polygons', () {
      final p1 = [
        [0.0, 0.0, 1.0, 0.0, 2.0, 0.0, 0.0, 0.0].positions(),
      ].polylabel2D();
      expect(
        p1,
        DistancedPosition(
          Position.create(x: 0.0, y: 0.0),
          0.0,
        ),
      );

      final p2 = [
        [0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0].positions(),
      ].polylabel2D();
      expect(
        p2,
        DistancedPosition(
          Position.create(x: 0.0, y: 0.0),
          0.0,
        ),
      );
    });
  });
}

Iterable<PositionSeries> _readPolygon(String name) {
  final str = File('test/geometric/data/$name.json').readAsStringSync();
  final coordinates = json.decode(str) as List;

  return coordinates.map((ring) {
    return PositionSeries.from(
      (ring as List).map((pos) {
        return Position.create(
          x: (pos[0] as num).toDouble(),
          y: (pos[1] as num).toDouble(),
        );
      }).toList(growable: false),
      type: Coords.xy,
    );
  }).toList(growable: false);
}
