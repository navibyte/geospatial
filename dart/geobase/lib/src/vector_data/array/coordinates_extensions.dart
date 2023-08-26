// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/geographic/geographic.dart';
import '/src/coordinates/projected/projected.dart';

import 'coordinates.dart';

List<double> _requireLen(List<double> list, int len) {
  if (list.length != len) {
    throw FormatException('double list lenght must be $len');
  }
  return list;
}

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

  /// A position with coordinate values as a view backed by `this`.
  ///
  /// Supported values combinations: (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Or for geographic coordinates (lon, lat), (lon, lat, elev) and
  /// (lon, lat, elev, m).
  ///
  /// See [PositionCoords.view] for more information.
  ///
  /// See also [xy], [xyz], [xym] and [xyzm].
  PositionCoords get position =>
      PositionCoords.view(this, type: Coords.fromDimension(length));

  /// A position with x and y coordinates as a view backed by `this`.
  ///
  /// The double list represented by `this` must contain `x, y` values in
  /// this order (or `lon, lat` for geographic coordinates).
  ///
  /// See [PositionCoords.view] for more information. See also [position].
  ///
  /// Throws FormatException if this does not contain exactly 2 values.
  PositionCoords get xy => PositionCoords.view(_requireLen(this, 2));

  /// A position with x, y and z coordinates as a view backed by `this`.
  ///
  /// The double list represented by `this` must contain `x, y, z` values in
  /// this order (or `lon, lat, elev` for geographic coordinates).
  ///
  /// See [PositionCoords.view] for more information. See also [position].
  ///
  /// Throws FormatException if this does not contain exactly 2 values.
  PositionCoords get xyz =>
      PositionCoords.view(_requireLen(this, 3), type: Coords.xyz);

  /// A position with x, y and m coordinates as a view backed by `this`.
  ///
  /// The double list represented by `this` must contain `x, y, m` values in
  /// this order (or `lon, lat, m` for geographic coordinates).
  ///
  /// See [PositionCoords.view] for more information. See also [position].
  ///
  /// Throws FormatException if this does not contain exactly 2 values.
  PositionCoords get xym =>
      PositionCoords.view(_requireLen(this, 3), type: Coords.xym);

  /// A position with x, y, z and m coordinates as a view backed by `this`.
  ///
  /// The double list represented by `this` must contain `x, y, z, m` values in
  /// this order (or `lon, lat, elev, m` for geographic coordinates).
  ///
  /// See [PositionCoords.view] for more information. See also [position].
  ///
  /// Throws FormatException if this does not contain exactly 2 values.
  PositionCoords get xyzm =>
      PositionCoords.view(_requireLen(this, 4), type: Coords.xyzm);

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
        data[posIndex * dim + coordIndex] = pos[coordIndex];
      }
      posIndex++;
    }
    return PositionArray.view(data, type: type);
  }
}

/// A helper extension on [Position] to convert position objects between
/// subtypes like [Projected], [Geographic] and [PositionCoords].
extension PositionCoordinatesExtension on Position {
  /// Returns this position as an instance of [PositionCoords].
  ///
  /// The coordinate type defined by [type] is preserved.
  ///
  /// If the type of the position is [PositionCoords], then this is returned.
  /// Otherwise a new instance with copied coordinate values is created.
  PositionCoords get coords {
    final pos = this;
    return pos is PositionCoords ? pos : pos.copyTo(PositionCoords.create);
  }

  /// Returns this position as an instance of [Projected].
  ///
  /// The coordinate type defined by [type] is preserved.
  ///
  /// If the type of the position is [Projected], then this is returned.
  /// Otherwise a new instance with copied coordinate values is created.
  Projected get asProjected {
    final pos = this;
    return pos is Projected ? pos : pos.copyTo(Projected.create);
  }

  /// Returns this position as an instance of [Geographic].
  ///
  /// The coordinate type defined by [type] is preserved.
  ///
  /// If the type of the position is [Geographic], then this is returned.
  /// Otherwise a new instance with copied coordinate values is created.
  Geographic get asGeographic {
    final pos = this;
    return pos is Geographic ? pos : pos.copyTo(Geographic.create);
  }
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
