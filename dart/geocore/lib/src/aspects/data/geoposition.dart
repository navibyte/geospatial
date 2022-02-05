// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/codes.dart';

import 'base_position.dart';
import 'position.dart';

/// A geographic position with longitude, latitude and optional elevation and m.
///
/// Longitude is available at [lon], latitude at [lat] and elevation at [elev].
/// [m] represents a measurement.
///
/// Longitude (range `[-180.0, 180.0[`) and latitude (range `[-90.0, 90.0]`) are
/// represented as deegrees. The unit for [elev] is meters.
abstract class GeoPosition extends BasePosition {
  /// A geographical position with [lon] and [lat], and optional [elev] and [m].
  factory GeoPosition({
    required double lon,
    required double lat,
    double? elev,
    double? m,
  }) = _GeoPosition;

  /// The longitude coordinate.
  double get lon;

  /// The latitude coordinate.
  double get lat;

  /// The elevation (or altitude) coordinate in meters.
  ///
  /// Returns zero if not available.
  ///
  /// You can also use [is3D] to check whether elev coordinate is available, or
  /// [optElev] returns elev coordinate as nullable value.
  double get elev;

  /// The elevation (or altitude) coordinate optionally in meters.
  ///
  /// Returns null if not available.
  ///
  /// You can also use [is3D] to check whether elev coordinate is available.
  double? get optElev;
}

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

class _GeoPosition implements GeoPosition, Position {
  const _GeoPosition({
    required double lon,
    required double lat,
    double? elev,
    double? m,
  })  : _lon = lon,
        _lat = lat,
        _elev = elev,
        _m = m;

  final double _lon;
  final double _lat;
  final double? _elev;
  final double? _m;

  @override
  double get lon => _lon;

  @override
  double get lat => _lat;

  @override
  double get elev => _elev ?? 0.0;

  @override
  double? get optElev => _elev;

  @override
  double get x => _lon;

  @override
  double get y => _lat;

  @override
  double get z => _elev ?? 0.0;

  @override
  double? get optZ => _elev;

  @override
  double get m => _m ?? 0.0;

  @override
  double? get optM => _m;

  @override
  Position get asPosition => this;

  @override
  int get spatialDimension => typeCoords.spatialDimension;

  @override
  int get coordinateDimension => typeCoords.coordinateDimension;

  @override
  bool get is3D => _elev != null;

  @override
  bool get isMeasured => _m != null;

  @override
  Coords get typeCoords =>
      CoordsExtension.select(is3D: is3D, isMeasured: isMeasured);

  @override
  String toString() {
    switch (typeCoords) {
      case Coords.xy:
        return '$_lon,$_lat';
      case Coords.xyz:
        return '$_lon,$_lat,$_elev';
      case Coords.xym:
        return '$_lon,$_lat,$_m';
      case Coords.xyzm:
        return '$_lon,$_lat,$_elev,$_m';
    }
  }
}
