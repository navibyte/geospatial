// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_series.dart';

import 'format_validation.dart';

part 'coord_arrays_from_json.dart';

/// Utility to convert expect `List<dynamic>` data to `Position`.
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
Position createPosition(
  dynamic data, {
  Coords? type,
  bool swapXY = false,
  bool singlePrecision = false,
}) {
  final coords = _requirePositionDouble(
    data,
    type: type,
    swapXY: swapXY,
    singlePrecision: singlePrecision,
  );
  final coordType = type ?? Coords.fromDimension(coords.length);
  return Position.view(coords, type: coordType);
}

/// Utility to parse `List<String>` data to `Position`.
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
Position parsePosition(
  List<String> data, {
  Coords? type,
  bool swapXY = false,
  bool singlePrecision = false,
}) {
  final coords = _parsePositionDouble(
    data,
    type: type,
    swapXY: swapXY,
    singlePrecision: singlePrecision,
  );
  final coordType = type ?? Coords.fromDimension(coords.length);
  return Position.view(coords, type: coordType);
}

/// Utility to parse a string with coord values to `Position`.
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
Position parsePositionFromText(
  String text, {
  Pattern delimiter = ',',
  Coords? type,
  bool swapXY = false,
  bool singlePrecision = false,
}) =>
    parsePosition(
      text.trim().split(delimiter),
      type: type,
      swapXY: swapXY,
      singlePrecision: singlePrecision,
    );

/// Utility to convert expect `List<dynamic>` data to `List<Position>`.
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
List<Position> createPositionArray(
  dynamic data, {
  Coords? type,
  bool swapXY = false,
  bool singlePrecision = false,
}) {
  var coordType = type;
  return (data as List<dynamic>).map<Position>(
    (pos) {
      final coords = _requirePositionDouble(
        pos,
        type: coordType,
        swapXY: swapXY,
        singlePrecision: singlePrecision,
      );
      coordType ??= Coords.fromDimension(coords.length);
      return Position.view(coords, type: coordType);
    },
  ).toList(growable: false);
}

/// Utility to convert expect `List<dynamic>` data to `Box`.
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
Box createBox(
  dynamic data, {
  Coords? type,
  bool swapXY = false,
  bool singlePrecision = false,
}) {
  final coords = _requireBoxDouble(
    data,
    type: type,
    swapXY: swapXY,
    singlePrecision: singlePrecision,
  );
  final coordType = type ?? Coords.fromDimension(coords.length ~/ 2);
  return Box.view(coords, type: coordType);
}

/// Utility to parse `List<String>` data to `Box`.
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
Box parseBox(
  List<String> data, {
  Coords? type,
  bool swapXY = false,
  bool singlePrecision = false,
}) {
  final coords = _parseBoxDouble(
    data,
    type: type,
    swapXY: swapXY,
    singlePrecision: singlePrecision,
  );
  final coordType = type ?? Coords.fromDimension(coords.length ~/ 2);
  return Box.view(coords, type: coordType);
}

/// Utility to parse a string with coord values to `Box`.
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
Box parseBoxFromText(
  String text, {
  Pattern delimiter = ',',
  Coords? type,
  bool swapXY = false,
  bool singlePrecision = false,
}) =>
    parseBox(
      text.trim().split(delimiter),
      type: type,
      swapXY: swapXY,
      singlePrecision: singlePrecision,
    );

/// Utility to create `PositionSeries` from `List<dynamic>`(2 dims).
///
/// Swaps x and y for the result if `swapXY` is true.
@internal
PositionSeries createPositionSeries(
  List<dynamic> source, {
  Coords? type,
  bool swapXY = false,
  bool singlePrecision = false,
}) {
  final coordType = type ?? _resolveCoordType(source, positionLevel: 1);

  return PositionSeries.view(
    _createFlatPositionArrayDouble(
      source,
      coordType,
      swapXY: swapXY,
      singlePrecision: singlePrecision,
    ),
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
  bool singlePrecision = false,
}) =>
    source.isEmpty
        ? List<PositionSeries>.empty()
        : source
            .map<PositionSeries>(
              (e) => createPositionSeries(
                e as List<dynamic>,
                type: type ?? _resolveCoordType(source, positionLevel: 2),
                swapXY: swapXY,
                singlePrecision: singlePrecision,
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
  bool singlePrecision = false,
}) =>
    source.isEmpty
        ? List<List<PositionSeries>>.empty()
        : source
            .map<List<PositionSeries>>(
              (e) => createPositionSeriesArray(
                e as List<dynamic>,
                type: type ?? _resolveCoordType(source, positionLevel: 3),
                swapXY: swapXY,
                singlePrecision: singlePrecision,
              ),
            )
            .toList(growable: false);
