// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'position.dart';
import 'positionable.dart';

/// A base interface for geospatial positions.
//
/// This interface defines coordinate value only for the m axis. Sub classes
/// define coordinate values for other axes (x, y and z for projected or
/// cartesian positions, and longitude, latitude and elevation for geographic
/// positions).
///
/// The known sub classes are `Position` (with x, y, z and m coordinates) and
/// `GeoPosition` (with lon, lat, elev and m coordinates).
abstract class BasePosition extends Positionable {
  /// Default `const` constructor to allow extending this abstract class.
  const BasePosition();

  /// The m ("measure") coordinate value. Returns zero if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available,
  /// [optM] returns m coordinate as nullable value.
  ///
  /// [m] represents a measurement or a value on a linear referencing system
  /// (like time).
  num get m;

  /// The m ("measure") coordinate optionally. Returns null if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available.
  ///
  /// [m] represents a measurement or a value on a linear referencing system
  /// (like time).
  num? get optM;

  /// Returns this position as [Position] (with x, y, z and m coordinates).
  ///
  /// When returning `GeoPosition` as [Position] then coordinates are copied as:
  /// `lon` => `x`, `lat` => `y`, `elev` => `z`, `m` => `m`
  Position get asPosition;
}
