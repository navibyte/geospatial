// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base.dart';
import '/src/coordinates/data.dart';
import '/src/coordinates/geographic.dart';
import '/src/coordinates/projected.dart';
import '/src/coordinates/projection.dart';
import '/src/utils/format_validation.dart';
import '/src/utils/num.dart';

part 'box_coords.dart';
part 'coordinates_mixin.dart';
part 'position_array.dart';
part 'position_coords.dart';

/// Geospatial coordinate values as an iterable collection of double values.
///
/// See also sub classes:
/// * [PositionArray]: coordinate values of 0 to N positions in a flat structure
/// * [PositionCoords]: coordinate values of a single position
/// * [BoxCoords]: coordinate values of a single bounding box
abstract class Coordinates extends Iterable<double> implements Positionable {}

typedef _CreateAt<T> = T Function(
  Iterable<double> coordinates, {
  required Coords type,
});

T _doCreateRange<T>(
  Iterable<double> coordinates, {
  required _CreateAt<T> to,
  required Coords type,
  required int start,
  required int end,
}) {
  if (coordinates is List<double>) {
    // the source coordinates is a List, get range
    return to.call(
      coordinates.getRange(start, end),
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
