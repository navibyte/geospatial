// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_series.dart';

import 'format_validation.dart';

part 'coord_arrays_from_json.dart';

/// Utility to convert expect `List<dynamic> data to `Position`.
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
Position createPosition(
  dynamic data, {
  Coords? type,
  bool swapXY = false,
}) {
  final coords = _requirePositionDouble(data, type: type, swapXY: swapXY);
  final coordType = type ?? Coords.fromDimension(coords.length);
  return Position.view(coords, type: coordType);
}

/// Utility to convert expect `List<dynamic> data to `List<Position>`.
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
List<Position> createPositionArray(
  dynamic data, {
  Coords? type,
  bool swapXY = false,
}) {
  var coordType = type;
  return (data as List<dynamic>).map<Position>(
    (pos) {
      final coords =
          _requirePositionDouble(pos, type: coordType, swapXY: swapXY);
      coordType ??= Coords.fromDimension(coords.length);
      return Position.view(coords, type: coordType);
    },
  ).toList(growable: false);
}

/// Utility to create `PositionSeries` from `List<dynamic>`(2 dims).
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
PositionSeries createPositionSeries(
  List<dynamic> source, {
  Coords? type,
  bool swapXY = false,
}) {
  final coordType = type ?? _resolveCoordType(source, positionLevel: 1);

  return PositionSeries.view(
    _createFlatPositionArrayDouble(source, coordType, swapXY: swapXY),
    type: coordType,
  );
}

/// Utility to create `List<PositionSeries>` from `List<dynamic>`(3 dims).
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
List<PositionSeries> createPositionSeriesArray(
  List<dynamic> source, {
  Coords? type,
  bool swapXY = false,
}) =>
    source.isEmpty
        ? List<PositionSeries>.empty()
        : source
            .map<PositionSeries>(
              (e) => createPositionSeries(
                e as List<dynamic>,
                type: type ?? _resolveCoordType(source, positionLevel: 2),
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
  List<dynamic> source, {
  Coords? type,
  bool swapXY = false,
}) =>
    source.isEmpty
        ? List<List<PositionSeries>>.empty()
        : source
            .map<List<PositionSeries>>(
              (e) => createPositionSeriesArray(
                e as List<dynamic>,
                type: type ?? _resolveCoordType(source, positionLevel: 3),
                swapXY: swapXY,
              ),
            )
            .toList(growable: false);
