// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';

import 'coordinates.dart';

/// Some helper extension on `List<double>` to handle coordinate values.
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
