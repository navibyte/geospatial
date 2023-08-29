// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/vector/array/coordinates.dart';

/// Builds a bounding box from [coords] if it's non-null.
///
/// If [coords] is already an instance of [BoxCoords] then it's returned.
///
/// Otherwise a new instance is created from [coords] and [type].
@internal
BoxCoords? buildBoxCoordsOpt(Iterable<double>? coords, {Coords? type}) {
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

/// Build a bounding box from [coords].
///
/// If [coords] is already an instance of [BoxCoords] then it's returned.
///
/// Otherwise a new instance is created from [coords] and [type].
@internal
BoxCoords buildBoxCoords(Iterable<double> coords, {Coords? type}) {
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

/// Builds a position from [coords].
///
/// If [coords] is already an instance of [PositionCoords] then it's returned.
///
/// Otherwise a new instance is created from [coords] and [type].
@internal
PositionCoords buildPositionCoords(
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

/// Builds a list of positions from [coords].
///
/// If [coords] is already a list of [PositionCoords] then it's returned.
///
/// Otherwise a new instance is created from [coords] and [type].
@internal
List<PositionCoords> buildListOfPositionsCoords(
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
          (pos) => buildPositionCoords(pos, type: type),
        )
        .toList(growable: false);
  }
}

/// Builds a position array from [coords].
///
/// If [coords] is already an instance of [PositionArray] then it's returned.
///
/// Otherwise a new instance is created from [coords] and [type].
@internal
PositionArray buildPositionArray(
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

/// Builds a list of position arrays from [coords].
///
/// If [coords] is already a list of [PositionArray] then it's returned.
///
/// Otherwise a new instance is created from [coords] and [type].
@internal
List<PositionArray> buildListOfPositionArrays(
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
          (array) => buildPositionArray(array, type: type),
        )
        .toList(growable: false);
  }
}

/// Builds a list of lists of position arrays from [coords].
///
/// If [coords] is already a list of lists of [PositionArray] then it's
/// returned.
///
/// Otherwise a new instance is created from [coords] and [type].
@internal
List<List<PositionArray>> buildListOfListOfPositionArrays(
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
          (array) => buildListOfPositionArrays(array, type: type),
        )
        .toList(growable: false);
  }
}
