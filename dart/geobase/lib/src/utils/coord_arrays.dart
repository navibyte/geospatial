// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/vector_data/array.dart';

/// A bounding box from [coords] if it's non-null.
///
/// If [coords] is already an instance of [BoxCoords] then it's returned.
///
/// Otherwise a new instance is created from [coords] and [type].
BoxCoords? boxFromCoordsOpt(Iterable<double>? coords, {Coords? type}) {
  if (coords == null) {
    return null;
  } else if (coords is BoxCoords) {
    return coords;
  } else {
    return BoxCoords.view(
      // ensure list structure
      coords is List<double> ? coords : coords.toList(growable: false),
      // resolve type if not known
      type: type ?? Coords.fromDimension(coords.length ~/ 2),
    );
  }
}

/// A bounding box from [coords].
///
/// If [coords] is already an instance of [BoxCoords] then it's returned.
///
/// Otherwise a new instance is created from [coords] and [type].
BoxCoords boxFromCoords(Iterable<double> coords, {Coords? type}) {
  if (coords is BoxCoords) {
    return coords;
  } else {
    return BoxCoords.view(
      // ensure list structure
      coords is List<double> ? coords : coords.toList(growable: false),
      // resolve type if not known
      type: type ?? Coords.fromDimension(coords.length ~/ 2),
    );
  }
}

/// A position from [coords].
///
/// If [coords] is already an instance of [PositionCoords] then it's returned.
///
/// Otherwise a new instance is created from [coords] and [type].
PositionCoords positionFromCoords(
  Iterable<double> coords, {
  Coords? type,
}) {
  if (coords is PositionCoords) {
    return coords;
  } else {
    return PositionCoords.view(
      // ensure list structure
      coords is List<double> ? coords : coords.toList(growable: false),
      // resolve type if not known
      type: type ?? Coords.fromDimension(coords.length),
    );
  }
}

/// A list of positions from [coords].
///
/// If [coords] is already a list of [PositionCoords] then it's returned.
///
/// Otherwise a new instance is created from [coords] and [type].
List<PositionCoords> listOfPositionsFromCoords(
  Iterable<Iterable<double>> coords, {
  Coords? type,
}) {
  if (coords is List<PositionCoords>) {
    return coords;
  } else if (coords is Iterable<PositionCoords>) {
    return coords.toList(growable: false);
  } else {
    return coords
        .map<PositionCoords>(
          (pos) => positionFromCoords(pos, type: type),
        )
        .toList(growable: false);
  }
}

/// A position array from [coords].
///
/// If [coords] is already an instance of [PositionArray] then it's returned.
///
/// Otherwise a new instance is created from [coords] and [type].
PositionArray positionArrayFromCoords(
  Iterable<double> coords, {
  required Coords type,
}) {
  if (coords is PositionArray) {
    return coords;
  } else {
    return PositionArray.view(
      // ensure list structure
      coords is List<double> ? coords : coords.toList(growable: false),
      // type is required
      type: type,
    );
  }
}

/// A list of position arrays from [coords].
///
/// If [coords] is already a list of [PositionArray] then it's returned.
///
/// Otherwise a new instance is created from [coords] and [type].
List<PositionArray> listOfPositionArraysFromCoords(
  Iterable<Iterable<double>> coords, {
  required Coords type,
}) {
  if (coords is List<PositionArray>) {
    return coords;
  } else if (coords is Iterable<PositionArray>) {
    return coords.toList(growable: false);
  } else {
    return coords
        .map<PositionArray>(
          (array) => positionArrayFromCoords(array, type: type),
        )
        .toList(growable: false);
  }
}

/// A list of lists of position arrays from [coords].
///
/// If [coords] is already a list of lists of [PositionArray] then it's
/// returned.
///
/// Otherwise a new instance is created from [coords] and [type].
List<List<PositionArray>> listOfListOfPositionArraysFromCoords(
  Iterable<Iterable<Iterable<double>>> coords, {
  required Coords type,
}) {
  if (coords is List<List<PositionArray>>) {
    return coords;
  } else if (coords is Iterable<List<PositionArray>>) {
    return coords.toList(growable: false);
  } else {
    return coords
        .map<List<PositionArray>>(
          (array) => listOfPositionArraysFromCoords(array, type: type),
        )
        .toList(growable: false);
  }
}
