// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/base.dart';

/// A geospatial position as an iterable collection of coordinate values.
///
/// Such position is a valid [Position] implementation and represents
/// coordinate values also as a collection of `Iterable<num>` (containing 2, 3,
/// or 4 items).
///
/// See [Position] for description about supported coordinate values.
abstract class PositionCoords<E extends num> extends Position
    implements Iterable<E> {
  /// Default `const` constructor to allow extending this abstract class.
  const PositionCoords();

  /// Returns a new iterator that allows iterating coordinate values of this
  /// position.
  ///
  /// There are 2, 3 or 4 coordinate values to iterate.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, z), (x, y, m) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, elev), (lon, lat, m) or (lon, lat, elev, m).
  @override
  Iterator<E> get iterator;

  /// A coordinate value by the coordinate axis [index].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For 2D coordinates the coordinate axis indexes are:
  ///
  /// Index | Projected | Geographic
  /// ----- | --------- | ----------
  /// 0     | x         | lon
  /// 1     | y         | lat
  /// 2     | m         | m
  ///
  /// For 3D coordinates the coordinate axis indexes are:
  ///
  /// Index | Projected | Geographic
  /// ----- | --------- | ----------
  /// 0     | x         | lon
  /// 1     | y         | lat
  /// 2     | z         | elev
  /// 3     | m         | m
  @override
  E elementAt(int index);

  /// The number of coordinate values (2, 3 or 4) for this position.
  ///
  /// Equals to [coordinateDimension].
  @override
  int get length;
}
