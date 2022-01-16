// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:equatable/equatable.dart';

import 'package:geocore/geocore.dart';

import 'package:test/test.dart';

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  group('Compare temporal events (instants and intervals)', () {
    final t1 = DateTime.parse('2020-10-01 15:45:30Z');
    final t2 = DateTime.parse('2020-10-03 20:30:10Z');
    final t3 = DateTime.parse('2020-10-03 21:30:10Z');
    final t4 = DateTime.parse('2020-10-05 01:15:50Z');
    final t5 = DateTime.parse('2020-10-05 01:15:51Z');

    test('Instant', () {
      final instant = Instant(t1);
      expect(instant.toString(), '2020-10-01T15:45:30.000Z');
      expect(instant.isAfterTime(t2), false);
      expect(instant.isBeforeTime(t2), true);
      expect(instant.isAfterTime(t1), false);
      expect(instant.isBeforeTime(t1), false);
    });

    test('Interval closed', () {
      final interval = Interval.closed(t2, t4);
      expect(
        interval.toString(),
        '2020-10-03T20:30:10.000Z/2020-10-05T01:15:50.000Z',
      );
      expect(interval.isAfterTime(t1), true);
      expect(interval.isBeforeTime(t1), false);
      expect(interval.isAfterTime(t2), false);
      expect(interval.isBeforeTime(t2), false);
      expect(interval.isAfterTime(t3), false);
      expect(interval.isBeforeTime(t3), false);
      expect(interval.isAfterTime(t4), false);
      expect(interval.isBeforeTime(t4), true);
      expect(interval.isAfterTime(t5), false);
      expect(interval.isBeforeTime(t5), true);
    });

    test('Interval open ended', () {
      final interval = Interval.openEnd(t2);
      expect(interval.toString(), '2020-10-03T20:30:10.000Z/..');
      expect(interval.isAfterTime(t1), true);
      expect(interval.isBeforeTime(t1), false);
      expect(interval.isAfterTime(t2), false);
      expect(interval.isBeforeTime(t2), false);
      expect(interval.isAfterTime(t3), false);
      expect(interval.isBeforeTime(t3), false);
      expect(interval.isAfterTime(t4), false);
      expect(interval.isBeforeTime(t4), false);
      expect(interval.isAfterTime(t5), false);
      expect(interval.isBeforeTime(t5), false);
    });

    test('Interval open started', () {
      final interval = Interval.openStart(t4);
      expect(interval.toString(), '../2020-10-05T01:15:50.000Z');
      expect(interval.isAfterTime(t1), false);
      expect(interval.isBeforeTime(t1), false);
      expect(interval.isAfterTime(t2), false);
      expect(interval.isBeforeTime(t2), false);
      expect(interval.isAfterTime(t3), false);
      expect(interval.isBeforeTime(t3), false);
      expect(interval.isAfterTime(t4), false);
      expect(interval.isBeforeTime(t4), true);
      expect(interval.isAfterTime(t5), false);
      expect(interval.isBeforeTime(t5), true);
    });

    test('Interval open', () {
      final interval = Interval.open();
      expect(interval.toString(), '../..');
      expect(interval.isAfterTime(t1), false);
      expect(interval.isBeforeTime(t1), false);
      expect(interval.isAfterTime(t2), false);
      expect(interval.isBeforeTime(t2), false);
      expect(interval.isAfterTime(t3), false);
      expect(interval.isBeforeTime(t3), false);
      expect(interval.isAfterTime(t4), false);
      expect(interval.isBeforeTime(t4), false);
      expect(interval.isAfterTime(t5), false);
      expect(interval.isBeforeTime(t5), false);
    });
  });
}
