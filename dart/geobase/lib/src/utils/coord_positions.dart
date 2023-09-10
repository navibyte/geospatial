// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_series.dart';

import 'coord_arrays_from_json.dart';

/// Utility to convert expect `List<dynamic> data to `List<List<double>>`.
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
List<Position> requirePositionArray(
  dynamic data, {
  bool swapXY = false,
}) {
  Coords? type;
  return (data as List<dynamic>).map<Position>(
    (pos) {
      final coords = requirePositionDouble(pos, swapXY: swapXY);
      type ??= Coords.fromDimension(coords.length);
      return Position.view(
        coords,
        type: type ?? Coords.fromDimension(coords.length),
      );
    },
  ).toList(growable: false);
}

/// Utility to create `PositionSeries` from `List<dynamic>`(2 dims).
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
PositionSeries createPositionSeries(
  List<dynamic> source,
  Coords coordType, {
  bool swapXY = false,
}) =>
    PositionSeries.view(
      createFlatPositionArrayDouble(source, coordType, swapXY: swapXY),
      type: coordType,
    );

/// Utility to create `List<PositionSeries>` from `List<dynamic>`(3 dims).
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
List<PositionSeries> createPositionSeriesArray(
  List<dynamic> source,
  Coords coordType, {
  bool swapXY = false,
}) =>
    source.isEmpty
        ? List<PositionSeries>.empty()
        : source
            .map<PositionSeries>(
              (e) => createPositionSeries(
                e as List<dynamic>,
                coordType,
                swapXY: swapXY,
              ),
            )
            .toList(growable: false);

/// Utility to create flat `List<List<PositionSeries>>` from
/// `List<dynamic>`(4 dims).
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
List<List<PositionSeries>> createPositionSeriesArrayArray(
  List<dynamic> source,
  Coords coordType, {
  bool swapXY = false,
}) =>
    source.isEmpty
        ? List<List<PositionSeries>>.empty()
        : source
            .map<List<PositionSeries>>(
              (e) => createPositionSeriesArray(
                e as List<dynamic>,
                coordType,
                swapXY: swapXY,
              ),
            )
            .toList(growable: false);
