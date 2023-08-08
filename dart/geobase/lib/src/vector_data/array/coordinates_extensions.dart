// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';

import 'coordinates.dart';

/// A helper extension on `List<double>` to handle coordinate values.
///
/// See [Coordinates] for more information.
extension ListCoordinateExtension on List<double> {
  /// A bounding box with coordinate values as a view backed by `this`.
  ///
  /// Supported values combinations:
  /// * minX, minY, maxX, maxY
  /// * minX, minY, minZ, maxX, maxY, maxZ
  /// * minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// See [BoxCoords.view] for more information.
  BoxCoords get box =>
      BoxCoords.view(this, type: Coords.fromDimension(length ~/ 2));

  /// A geospatial position with coordinate values as a view backed by `this`.
  ///
  /// Supported values combinations: (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// See [PositionCoords.view] for more information.
  PositionCoords get position =>
      PositionCoords.view(this, type: Coords.fromDimension(length));

  /// Coordinate values of geospatial positions as a view backed by `this`.
  ///
  /// The [type] parameter defines the cooordinate type of coordinate values as
  /// a flat structure.
  ///
  /// See [PositionArray.view] for more information.
  PositionArray positions(Coords type) => PositionArray.view(this, type: type);
}

/// A helper extension on `Iterable<Position>` to convert data as
/// [PositionArray].
extension PositionIterableCoordinatesExtension on Iterable<Position> {
  /// Returns positions of this `Position` iterable as `PositionArray`
  /// structuring coordinates a flat structure of `double` iterable.
  ///
  /// The coordinate type a returned array is set to the coordinate type of the
  /// first position of this iterable.
  ///
  /// If this iterable is empty, then returned array is empty too (with
  /// coordinate type set to `Coords.xy`).
  PositionArray array() {
    final len = length;
    if (len == 0) {
      return PositionArray.view([]);
    }
    final type = first.type;
    final dim = type.coordinateDimension;
    final data = List<double>.filled(len * dim, 0.0);
    var posIndex = 0;
    for (final pos in this) {
      for (var coordIndex = 0; coordIndex < dim; coordIndex++) {
        data[posIndex * dim + coordIndex] = pos[coordIndex].toDouble();
      }
      posIndex++;
    }
    return PositionArray.view(data, type: type);
  }
}

/// A helper extension on [Position] to convert data as [PositionCoords].
extension PositionCoordinatesExtension on Position {
  /// Returns this `Position` as an instance of `PositionCoords` with the same
  /// coordinate type as this has.
  PositionCoords coords() => this is PositionCoords
      ? this as PositionCoords
      : PositionCoords.create(x: x, y: y, z: optZ, m: optM);
}

/// A helper extension on [Box] to convert data as [BoxCoords].
extension BoxCoordinatesExtension on Box {
  /// Returns this `Box` as an instance of `BoxCoords` with the same coordinate
  /// type as this has.
  BoxCoords coords() => this is BoxCoords
      ? this as BoxCoords
      : BoxCoords.create(
          minX: minX,
          minY: minY,
          minZ: minZ,
          minM: minM,
          maxX: maxX,
          maxY: maxY,
          maxZ: maxZ,
          maxM: maxM,
        );
}
