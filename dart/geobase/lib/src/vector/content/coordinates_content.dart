// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/base.dart';
import '/src/coordinates/geographic.dart';
import '/src/coordinates/projected.dart';

/// An interface to write coordinate data to a geospatial content receiver.
///
/// A receiver could be a geospatial data format writer or an object factory.
/// 
/// Coordinate positions are represented either as [Position] or 
/// `Iterable<num>`. Bounding boxes are represented either as [Box] or
/// `Iterable<num>`.
mixin CoordinateContent {
  /// Writes a bounding box represented by [bbox] of [Box] or `Iterable<num>`.
  ///
  /// Known [Box] sub classes are [ProjBox] (projected or cartesian coordinates)
  /// and [GeoBox] (geographic coordinates). Other sub classes are supported
  /// too.
  ///
  /// Allowed [bbox] coordinate value combinations for `Iterable<num>` are:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  void box(Object bbox);

  /// Writes a position represented by [coordinates] of [Position] or
  /// `Iterable<num>`.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Other sub classes
  /// are supported too.
  ///
  /// Allowed coordinate value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  void position(Object coordinates);

  /// Writes a position array represented by [coordinates].
  ///
  /// The [coordinates] iterable is an array containing `Object` items. 
  /// Supported sub classes for items are [Position] and `Iterable<num>`.
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Other sub classes
  /// are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  void positions1D(Iterable<Object> coordinates);

  /// Writes a position array represented by [coordinates].
  ///
  /// The [coordinates] iterable is an array of arrays containing `Object`
  /// items. Supported sub classes for items are [Position] and `Iterable<num>`
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Other sub classes
  /// are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  void positions2D(Iterable<Iterable<Object>> coordinates);

  /// Writes a position array represented by [coordinates].
  ///
  /// The [coordinates] iterable is an array of arrays of arrays containing
  /// `Object` items. Supported sub classes for items are [Position] and 
  /// `Iterable<num>`
  ///
  /// Known [Position] sub classes are [Projected] (projected or cartesian
  /// coordinates) and [Geographic] (geographic coordinates). Other sub classes
  /// are supported too.
  ///
  /// Allowed [coordinates] value combinations for `Iterable<num>` are:
  /// (x, y), (x, y, z) and (x, y, z, m).
  void positions3D(Iterable<Iterable<Iterable<Object>>> coordinates);
}
