// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/common/codes/coords.dart';

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
