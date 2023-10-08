// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/bounded.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_series.dart';

/// Resolves the coordinate type for [item] and/or [collection].
///
/// The returned type is such that it's valid for all items. For example if
/// a collection has items with types `Coords.xy`, `Coords.xyz` and
/// `Coords.xym`, then `Coords.xy` is returned. When all items are `Coords.xyz`,
/// then `Coords.xyz` is returned.
@internal
Coords resolveCoordTypeFrom<E extends Bounded>({
  E? item,
  Iterable<E>? collection,
}) {
  var is3D = true;
  var isMeasured = true;

  if (item != null) {
    final type = item.coordType;
    is3D &= type.is3D;
    isMeasured &= type.isMeasured;
  }

  if (collection != null) {
    for (final elem in collection) {
      final type = elem.coordType;
      is3D &= type.is3D;
      isMeasured &= type.isMeasured;
      if (!is3D && !isMeasured) break;
    }
  }

  return Coords.select(is3D: is3D, isMeasured: isMeasured);
}

/// Coordinate type from the first position in [array].
@internal
Coords positionArrayType(Iterable<Position> array) =>
    array.isNotEmpty ? array.first.type : Coords.xy;

/// Coordinate type from the first series of position in [array].
@internal
Coords positionSeriesArrayType(Iterable<PositionSeries> array) =>
    array.isNotEmpty ? array.first.type : Coords.xy;

/// Coordinate type from the first series of position in [array].
@internal
Coords positionSeriesArrayArrayType(Iterable<Iterable<PositionSeries>> array) =>
    array.isNotEmpty && array.first.isNotEmpty
        ? array.first.first.type
        : Coords.xy;
