// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'coord_positions.dart';

/// Utility to convert expected `List<dynamic> data to `List<double>`.
///
/// If [type] is given, then position is returned according to it.
///
/// Swaps x and y for the result if `swapXY` is true.
List<double> _requirePositionDouble(
  dynamic data, {
  Coords? type,
  bool swapXY = false,
  bool singlePrecision = false,
}) {
  // expect source to be list
  final source = data as List<dynamic>;
  final sourceLen = source.length;

  // not valid position if less than 2 coordinate values
  if (sourceLen < 2) throw invalidCoordinates;

  // calculate number of coordinate values for target position
  final targetLen =
      type != null ? type.coordinateDimension : sourceLen.clamp(2, 4);

  // create a list of doubles (cast items to num and then convert to double)
  // (also swap x and y if required)
  final pos = singlePrecision ? Float32List(targetLen) : Float64List(targetLen);
  pos[0] = (source[swapXY ? 1 : 0] as num).toDouble();
  pos[1] = (source[swapXY ? 0 : 1] as num).toDouble();
  if (targetLen >= 3 && sourceLen >= 3) {
    pos[2] = (source[2] as num).toDouble();
  }
  if (targetLen >= 4 && sourceLen >= 4) {
    pos[3] = (source[3] as num).toDouble();
  }
  return pos;
}

/// Utility to parse `List<String> data to `List<double>`.
///
/// If [type] is given, then position is returned according to it.
///
/// Swaps x and y for the result if `swapXY` is true.
List<double> _parsePositionDouble(
  List<String> source, {
  Coords? type,
  bool swapXY = false,
  bool singlePrecision = false,
}) {
  final sourceLen = source.length;

  // not valid position if less than 2 coordinate values
  if (sourceLen < 2) throw invalidCoordinates;

  // calculate number of coordinate values for target position
  final targetLen =
      type != null ? type.coordinateDimension : sourceLen.clamp(2, 4);

  // create a list of doubles (parse items to doubles)
  // (also swap x and y if required)
  final pos = singlePrecision ? Float32List(targetLen) : Float64List(targetLen);
  pos[0] = double.parse(source[swapXY ? 1 : 0]);
  pos[1] = double.parse(source[swapXY ? 0 : 1]);
  if (targetLen >= 3 && sourceLen >= 3) {
    pos[2] = double.parse(source[2]);
  }
  if (targetLen >= 4 && sourceLen >= 4) {
    pos[3] = double.parse(source[3]);
  }
  return pos;
}

/// Utility to convert expected `List<dynamic> data to `List<double>` for Box.
///
/// If [type] is given, then box is returned according to it.
///
/// Swaps x and y for the result if `swapXY` is true.
List<double> _requireBoxDouble(
  dynamic data, {
  Coords? type,
  bool swapXY = false,
  bool singlePrecision = false,
}) {
  // expect source to be list
  final source = data as List<dynamic>;
  final len = source.length;

  // len must be 4, 6 or 8, and match with type if that given
  if ((len != 4 && len != 6 && len != 8) ||
      (type != null && len != 2 * type.coordinateDimension)) {
    throw invalidCoordinates;
  }

  // bbox may have 4, 6 or 8 coordinate values
  final bbox = singlePrecision ? Float32List(len) : Float64List(len);
  switch (len) {
    case 4:
      bbox[0] = (source[swapXY ? 1 : 0] as num).toDouble(); // minX
      bbox[1] = (source[swapXY ? 0 : 1] as num).toDouble(); // minY
      bbox[2] = (source[swapXY ? 3 : 2] as num).toDouble(); // maxX
      bbox[3] = (source[swapXY ? 2 : 3] as num).toDouble(); // maxY
      break;
    case 6:
      bbox[0] = (source[swapXY ? 1 : 0] as num).toDouble(); // minX
      bbox[1] = (source[swapXY ? 0 : 1] as num).toDouble(); // minY
      bbox[2] = (source[2] as num).toDouble(); // minZ or maxM
      bbox[3] = (source[swapXY ? 4 : 3] as num).toDouble(); // maxX
      bbox[4] = (source[swapXY ? 3 : 4] as num).toDouble(); // maxY
      bbox[5] = (source[5] as num).toDouble(); // maxZ or maxM
      break;
    case 8:
      bbox[0] = (source[swapXY ? 1 : 0] as num).toDouble(); // minX
      bbox[1] = (source[swapXY ? 0 : 1] as num).toDouble(); // minY
      bbox[2] = (source[2] as num).toDouble(); // minZ
      bbox[3] = (source[3] as num).toDouble(); // maxM
      bbox[4] = (source[swapXY ? 5 : 4] as num).toDouble(); // maxX
      bbox[5] = (source[swapXY ? 4 : 5] as num).toDouble(); // maxY
      bbox[6] = (source[6] as num).toDouble(); // maxZ
      bbox[7] = (source[7] as num).toDouble(); // maxM
      break;
  }
  return bbox;
}

/// Resolves coordinate type from first coordinate of [array] in
/// [positionLevel].
Coords _resolveCoordType(List<dynamic> array, {required int positionLevel}) {
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
List<double> _createFlatPositionArrayDouble(
  List<dynamic> source,
  Coords coordType, {
  bool swapXY = false,
  bool singlePrecision = false,
}) {
  if (source.isEmpty) {
    return List<double>.empty();
  }

  final dim = coordType.coordinateDimension;
  final positionCount = source.length;
  final valueCount = dim * positionCount;

  final array =
      singlePrecision ? Float32List(valueCount) : Float64List(valueCount);
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
