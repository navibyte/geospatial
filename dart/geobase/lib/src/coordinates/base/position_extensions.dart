// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/utils/coord_type.dart';

import 'box.dart';
import 'position.dart';
import 'position_series.dart';

List<double> _requireLen(List<double> list, int len) {
  if (list.length != len) {
    throw FormatException('double list lenght must be $len');
  }
  return list;
}

/// A helper extension on `List<double>` to handle coordinate values.
extension CoordinateArrayExtension on List<double> {
  /// A bounding box with coordinate values as a view backed by `this`.
  ///
  /// Supported values combinations:
  /// * minX, minY, maxX, maxY
  /// * minX, minY, minZ, maxX, maxY, maxZ
  /// * minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// Or for geographic coordinates:
  /// * west, south, east, north
  /// * west, south, minElev, east, north, maxElev
  /// * west, south, minElev, minM, east, north, maxElev, maxM
  ///
  /// See [Box.view] for more information.
  Box get box => Box.view(this, type: Coords.fromDimension(length ~/ 2));

  /// A position with coordinate values as a view backed by `this`.
  ///
  /// Supported values combinations: (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Or for geographic coordinates (lon, lat), (lon, lat, elev) and
  /// (lon, lat, elev, m).
  ///
  /// See [Position.view] for more information.
  ///
  /// See also [xy], [xyz], [xym] and [xyzm].
  Position get position =>
      Position.view(this, type: Coords.fromDimension(length));

  /// Coordinate values of geospatial positions as a view backed by `this`.
  ///
  /// The [type] parameter defines the cooordinate type of coordinate values as
  /// a flat structure.
  ///
  /// See [PositionSeries.view] for more information.
  PositionSeries positions([Coords type = Coords.xy]) =>
      PositionSeries.view(this, type: type);

  /// A position with x and y coordinates as a view backed by `this`.
  ///
  /// The double list represented by `this` must contain `x, y` values in
  /// this order (or `lon, lat` for geographic coordinates).
  ///
  /// See [Position.view] for more information. See also [position].
  ///
  /// Throws FormatException if this does not contain exactly 2 values.
  Position get xy => Position.view(_requireLen(this, 2));

  /// A position with x, y and z coordinates as a view backed by `this`.
  ///
  /// The double list represented by `this` must contain `x, y, z` values in
  /// this order (or `lon, lat, elev` for geographic coordinates).
  ///
  /// See [Position.view] for more information. See also [position].
  ///
  /// Throws FormatException if this does not contain exactly 3 values.
  Position get xyz => Position.view(_requireLen(this, 3), type: Coords.xyz);

  /// A position with x, y and m coordinates as a view backed by `this`.
  ///
  /// The double list represented by `this` must contain `x, y, m` values in
  /// this order (or `lon, lat, m` for geographic coordinates).
  ///
  /// See [Position.view] for more information. See also [position].
  ///
  /// Throws FormatException if this does not contain exactly 3 values.
  Position get xym => Position.view(_requireLen(this, 3), type: Coords.xym);

  /// A position with x, y, z and m coordinates as a view backed by `this`.
  ///
  /// The double list represented by `this` must contain `x, y, z, m` values in
  /// this order (or `lon, lat, elev, m` for geographic coordinates).
  ///
  /// See [Position.view] for more information. See also [position].
  ///
  /// Throws FormatException if this does not contain exactly 4 values.
  Position get xyzm => Position.view(_requireLen(this, 4), type: Coords.xyzm);
}

/// A helper extension on `Iterable<Position>` to convert data as
/// [PositionSeries].
extension PositionArrayExtension on Iterable<Position> {
  /// Returns positions of this `Position` iterable as `PositionSeries`.
  ///
  /// The coordinate type a returned array is set to the coordinate type of the
  /// first position of this iterable.
  ///
  /// If this iterable is empty, then returned array is empty too (with
  /// coordinate type set to `Coords.xy`).
  PositionSeries series() => isEmpty
      ? PositionSeries.empty()
      : PositionSeries.from(
          this,
          type: positionArrayType(this),
        );
}
