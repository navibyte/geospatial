// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geodata/src/utils/object_utils.dart';

import 'package:test/test.dart';

void main() {
  const List<int>? listNull = null;
  final list = <int>[];
  final list12 = [1, 2];
  final list123 = [1, 2, 3];
  final list123b = [1, 2, 3];

  const Map<String, int>? mapNull = null;
  final map = <String, int>{};
  final map12 = <String, int>{'1': 1, '2': 2};
  final map123 = <String, int>{'1': 1, '2': 2, '3': 3};
  final map123b = <String, int>{'1': 1, '2': 2, '3': 3};

  group('List', () {
    test('testListEquality', () {
      expect(testListEquality(listNull, listNull), true);
      expect(testListEquality(listNull, list), false);
      expect(testListEquality(list, list12), false);
      expect(testListEquality(list12, list), false);
      expect(testListEquality(list12, list123), false);
      expect(testListEquality(list123, list12), false);
      expect(testListEquality(list123, list123), true);
      expect(testListEquality(list123, list123b), true);
    });

    test('listToString', () {
      expect(listToString(listNull), '');
      expect(listToString(list), '');
      expect(listToString(list12), '1,2');
      expect(listToString(list123), '1,2,3');
    });
  });

  group('Iterable', () {
    test('testIterableEquality', () {
      expect(testIterableEquality(listNull, listNull), true);
      expect(testIterableEquality(listNull, list), false);
      expect(testIterableEquality(list, list12), false);
      expect(testIterableEquality(list12, list), false);
      expect(testIterableEquality(list12, list123), false);
      expect(testIterableEquality(list123, list12), false);
      expect(testIterableEquality(list123, list123), true);
      expect(testIterableEquality(list123, list123b), true);
    });
  });

  group('Map', () {
    test('testMapEquality', () {
      expect(testMapEquality(mapNull, mapNull), true);
      expect(testMapEquality(mapNull, map), false);
      expect(testMapEquality(map, map12), false);
      expect(testMapEquality(map12, map), false);
      expect(testMapEquality(map12, map123), false);
      expect(testMapEquality(map123, map12), false);
      expect(testMapEquality(map123, map123), true);
      expect(testMapEquality(map123, map123b), true);
    });

    test('mapHashCode', () {
      expect(mapHashCode(mapNull) == mapHashCode(mapNull), true);
      expect(mapHashCode(mapNull) == mapHashCode(map), false);
      expect(mapHashCode(map) == mapHashCode(map12), false);
      expect(mapHashCode(map12) == mapHashCode(map), false);
      expect(mapHashCode(map12) == mapHashCode(map123), false);
      expect(mapHashCode(map123) == mapHashCode(map12), false);
      expect(mapHashCode(map123) == mapHashCode(map123), true);
      expect(mapHashCode(map123) == mapHashCode(map123b), true);
    });

    test('mapToString', () {
      expect(mapToString(mapNull), '');
      expect(mapToString(map), '');
      expect(mapToString(map12), '1:1,2:2');
      expect(mapToString(map123), '1:1,2:2,3:3');
    });
  });
}
