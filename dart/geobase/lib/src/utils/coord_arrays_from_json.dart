// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';

import 'format_validation.dart';

/// Utility to convert expect `List<dynamic> data to `List<double>`.
List<double> requirePositionDouble(dynamic data) =>
    // cast to List<num> and map it to List<double>
    (data as List<dynamic>)
        .cast<num>()
        .map<double>((e) => e.toDouble())
        .toList(growable: false);

/// Utility to convert expect `List<dynamic> data to `List<List<double>>`.
List<List<double>> requirePositionArrayDouble(dynamic data) =>
    (data as List<dynamic>)
        .map<List<double>>(requirePositionDouble)
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
List<double> createFlatPositionArrayDouble(
  List<dynamic> source,
  Coords coordType,
) {
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
    array[offset] = (pos[0] as num).toDouble();
    array[offset + 1] = (pos[1] as num).toDouble();
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
List<List<double>> createFlatPositionArrayArrayDouble(
  List<dynamic> source,
  Coords coordType,
) =>
    source.isEmpty
        ? List<List<double>>.empty()
        : source
            .map<List<double>>(
              (e) => createFlatPositionArrayDouble(
                e as List<dynamic>,
                coordType,
              ),
            )
            .toList(growable: false);

/// Utility to create flat `List<List<List<double>>>` (3 dims) from
/// `List<dynamic>`(4 dims).
List<List<List<double>>> createFlatPositionArrayArrayArrayDouble(
  List<dynamic> source,
  Coords coordType,
) =>
    source.isEmpty
        ? List<List<List<double>>>.empty()
        : source
            .map<List<List<double>>>(
              (e) => createFlatPositionArrayArrayDouble(
                e as List<dynamic>,
                coordType,
              ),
            )
            .toList(growable: false);
