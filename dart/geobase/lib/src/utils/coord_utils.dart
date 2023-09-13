// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';

/// A function to create an object of [T] from [coordinates] of [type].
@internal
typedef CreateAt<T> = T Function(
  List<double> coordinates, {
  required Coords type,
});

/// Create an object of [T] from a subset (indicated [start] and [end]) of
/// [coordinates] of [type].
///
/// An object of [T] is created using the factory function [to].
@internal
T doCreateRange<T>(
  Iterable<double> coordinates, {
  required CreateAt<T> to,
  required Coords type,
  required int start,
  required int end,
}) {
  if (coordinates is List<double>) {
    // the source coordinates is a List, get range
    return to.call(
      coordinates.getRange(start, end).toList(growable: false),
      type: type,
    );
  } else {
    // the source is not a List, generate a new
    return to.call(
      coordinates.skip(start).take(end - start).toList(growable: false),
      type: type,
    );
  }
}

/// Coordinate values of all positions represented by [coordinates] with
/// [sourceType]
///
/// Target array is structured according to [targetType].
@internal
Iterable<double> valuesByTypeIter(
  Iterable<double> coordinates, {
  required Coords sourceType,
  required Coords targetType,
}) sync* {
  final iter = coordinates.iterator;
  while (iter.moveNext()) {
    // get source x, y and optional z, m for a position in the source array
    final x = iter.current;
    if (!iter.moveNext()) break;
    final y = iter.current;
    final double? z;
    if (sourceType.is3D) {
      if (!iter.moveNext()) break;
      z = iter.current;
    } else {
      z = null;
    }
    final double? m;
    if (sourceType.isMeasured) {
      if (!iter.moveNext()) break;
      m = iter.current;
    } else {
      m = null;
    }

    // output target position x, y and optional z, m
    yield x;
    yield y;
    if (targetType.is3D) {
      yield z ?? 0.0;
    }
    if (targetType.isMeasured) {
      yield m ?? 0.0;
    }
  }
}
