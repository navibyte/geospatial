// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';

import 'format_validation.dart';

/// Utility to convert expected `List<dynamic> data to `List<double>`.
///
/// Swaps x and y for the result if `swapXY` is true.
List<double> requirePositionDouble(dynamic data, {bool swapXY = false}) {
  // expect source to be list
  final source = data as List<dynamic>;

  // create a list of doubles (cast items to num and then convert to double)
  // (also swap x and y if required)
  return List<double>.generate(
    source.length,
    (index) {
      final sourceIndex = swapXY && index <= 1 ? (1 - index) : index;
      return (source[sourceIndex] as num).toDouble();
    },
    growable: false,
  );
}

/// Utility to convert expect `List<dynamic> data to `List<List<double>>`.
///
/// Swaps x and y for the result if `swapXY` is true.
List<List<double>> requirePositionArrayDouble(
  dynamic data, {
  bool swapXY = false,
}) =>
    (data as List<dynamic>)
        .map<List<double>>(
          (pos) => requirePositionDouble(pos, swapXY: swapXY),
        )
        .toList(growable: false);

/// Resolves coordinate type from first coordinate of [array] in
/// [positionLevel].
Coords resolveCoordType(List<dynamic> array, {required int positionLevel}) {
  if (positionLevel == 0) {
    return Coords.fromDimension(array.length);
  } else {
    var arr = array;
    var index = 0;
    while (index < positionLevel && array.isNotEmpty) {
      arr = arr.first as List<dynamic>;
      index++;
      if (index == positionLevel) {
        return Coords.fromDimension(arr.length);
      }
    }
  }
  return Coords.xy;
}

/// Utility to create flat `List<double>` (1 dim) from `List<dynamic>`(2 dims).
///
/// Swaps x and y for the result if `swapXY` is true.
List<double> createFlatPositionArrayDouble(
  List<dynamic> source,
  Coords coordType, {
  bool swapXY = false,
}) {
  if (source.isEmpty) {
    return List<double>.empty();
  }

  final dim = coordType.coordinateDimension;
  final positionCount = source.length;
  final valueCount = dim * positionCount;

  final array = List<double>.filled(valueCount, 0.0);
  for (var i = 0; i < positionCount; i++) {
    final pos = source[i] as List<dynamic>;
    if (pos.length < 2) {
      throw invalidCoordinates;
    }
    final offset = i * dim;
    if (swapXY) {
      // coordinate reference system has y-x (lat-lon) order => swap x and y
      array[offset] = (pos[1] as num).toDouble();
      array[offset + 1] = (pos[0] as num).toDouble();
    } else {
      // coordinate reference system has x-y (lon-lat) order => no swapping
      array[offset] = (pos[0] as num).toDouble();
      array[offset + 1] = (pos[1] as num).toDouble();
    }
    if (dim >= 3 && pos.length >= 3) {
      array[offset + 2] = (pos[2] as num).toDouble();
    }
    if (dim >= 4 && pos.length >= 4) {
      array[offset + 3] = (pos[3] as num).toDouble();
    }
  }

  return array;
}

/// Utility to create flat `List<List<double>>` (2 dims) from
/// `List<dynamic>`(3 dims).
///
/// Swaps x and y for the result if `swapXY` is true.
List<List<double>> createFlatPositionArrayArrayDouble(
  List<dynamic> source,
  Coords coordType, {
  bool swapXY = false,
}) =>
    source.isEmpty
        ? List<List<double>>.empty()
        : source
            .map<List<double>>(
              (e) => createFlatPositionArrayDouble(
                e as List<dynamic>,
                coordType,
                swapXY: swapXY,
              ),
            )
            .toList(growable: false);

/// Utility to create flat `List<List<List<double>>>` (3 dims) from
/// `List<dynamic>`(4 dims).
///
/// Swaps x and y for the result if `swapXY` is true.
List<List<List<double>>> createFlatPositionArrayArrayArrayDouble(
  List<dynamic> source,
  Coords coordType, {
  bool swapXY = false,
}) =>
    source.isEmpty
        ? List<List<List<double>>>.empty()
        : source
            .map<List<List<double>>>(
              (e) => createFlatPositionArrayArrayDouble(
                e as List<dynamic>,
                coordType,
                swapXY: swapXY,
              ),
            )
            .toList(growable: false);
