// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';

import 'positionable.dart';

/// A positionable object that has (geospatial) coordinate values directly
/// available.
///
/// This interface is extended at least by `Position` (representing a single
/// position), `PositionSeries` (representing a series of positions) and `Box`
/// (representing a single bounding box with minimum and maximum coordinates).
abstract class ValuePositionable extends Positionable {
  /// Default `const` constructor to allow extending this abstract class.
  const ValuePositionable();

  /// The number of coordinate values (2, 3 or 4) on a position.
  ///
  /// If value is 2, a position has 2D coordinates without m coordinate.
  ///
  /// If value is 3, a position has 2D coordinates with m coordinate or
  /// 3D coordinates without m coordinate.
  ///
  /// If value is 4, a position has 3D coordinates with m coordinate.
  ///
  /// Must be >= [spatialDimension].
  int get coordinateDimension {
    if (is3D) {
      return isMeasured ? 4 : 3;
    } else {
      return isMeasured ? 3 : 2;
    }
  }

  /// The number of spatial coordinate values (2 for 2D or 3 for 3D) on a
  /// position.
  int get spatialDimension => is3D ? 3 : 2;

  /// True for 3D positions (with z or elevation coordinate).
  bool get is3D;

  /// True if a measure value is available (or the m coordinate for a position).
  bool get isMeasured;

  /// The coordinate type.
  @Deprecated('Use coordType instead.')
  Coords get type => coordType;

  @override
  Coords get coordType => Coords.select(
        is3D: is3D,
        isMeasured: isMeasured,
      );

  /// The number of positions contained.
  int get positionCount;

  /// The number of coordinate values contained.
  ///
  /// The result should equal to `positionCount * coordinateDimension`.
  int get valueCount => positionCount * coordinateDimension;

  /// Coordinate values as a double iterable.
  /// 
  /// The number of values expected is indicated by [valueCount].
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, z), (x, y, m) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, elev), (lon, lat, m) or (lon, lat, elev, m).
  ///
  /// See also [valuesByType] that returns coordinate values according to a
  /// given coordinate type.
  Iterable<double> get values;

  /// Coordinate values  as a double iterable according to the given [type].
  ///
  /// See [values] (that returns coordinate values according to the coordinate
  /// type of `this`) for description of possible return values.
  Iterable<double> valuesByType(Coords type);

  /// Copies `this` as another object according to the given [type].
  ValuePositionable copyByType(Coords type);

  /// A string representation of coordinate values separated by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// Set [swapXY] to true to print y (or latitude) before x (or longitude).
  String toText({
    String delimiter = ',',
    int? decimals,
    bool swapXY = false,
  });
}
