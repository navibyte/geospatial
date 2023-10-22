// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_declarations

import 'dart:typed_data';

import 'package:geobase/coordinates.dart';

import 'package:geobase/src/utils/format_validation.dart';

// A dummy projection that just adds 1.0 to x and y coordinates (for testing).
class AddOneOnXYProjection with Projection {
  @override
  T project<T extends Position>(
    Position source, {
    required CreatePosition<T> to,
  }) =>
      to.call(
        x: source.x + 1.0,
        y: source.y + 1.0,
        z: source.optZ,
        m: source.optM,
      );

  @override
  List<double> projectCoords(
    Iterable<double> source, {
    List<double>? target,
    required Coords type,
  }) {
    final dim = type.coordinateDimension;
    final result = target ?? Float64List(source.length);

    var offset = 0;
    final iter = source.iterator;
    while (iter.moveNext()) {
      result[offset] = iter.current + 1.0;
      result[offset + 1] =
          iter.moveNext() ? iter.current + 1.0 : throw invalidCoordinates;
      // optional z and m coords unchanged
      if (dim >= 3) {
        result[offset + 2] =
            iter.moveNext() ? iter.current : throw invalidCoordinates;
      }
      if (dim >= 4) {
        result[offset + 3] =
            iter.moveNext() ? iter.current : throw invalidCoordinates;
      }
      offset += dim;
    }

    return result;
  }
}

T addOneOnXYTransform<T extends Position>(
  Position source, {
  required CreatePosition<T> to,
}) =>
    to.call(x: source.x + 1.0, y: source.y + 1);
