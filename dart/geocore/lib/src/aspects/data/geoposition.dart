// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/codes.dart';

import 'position.dart';

/// A geographic position with longitude, latitude and optional elevation and m.
///
/// Longitude is available at [lon], latitude at [lat] and elevation at [elev].
/// [m] represents a measurement.
///
/// Longitude (range `[-180.0, 180.0[`) and latitude (range `[-90.0, 90.0]`) are
/// represented as deegrees. The unit for [elev] is meters.
///
/// Extends the [Position] interface. Properties have equality (in the context
/// of this library): [lon] == [x], [lat] == [y], [elev] == [z]
class GeoPosition implements Position {
  /// A geographical position with [lon], [lat], and optional [elev] and [m].
  const GeoPosition({
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

  /// The longitude coordinate. Equals to [x].
  double get lon => _lon;

  /// The latitude coordinate. Equals to [y].
  double get lat => _lat;

  /// The elevation (or height or altitude) coordinate in meters. Equals to [z].
  ///
  /// Returns zero if not available.
  ///
  /// Use [is3D] to check whether elev coordinate is available.
  double get elev => _elev ?? 0.0;

  /// The elevation (or height or altitude) coordinate in meters.
  ///
  /// Equals to [optZ]. Returns null if not available.
  ///
  /// Use [is3D] to check whether elev coordinate is available.
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
  int get spatialDimension => typeCoords.spatialDimension;

  @override
  int get coordinateDimension => typeCoords.coordinateDimension;

  @override
  bool get is3D => optZ != null;

  @override
  bool get isMeasured => optM != null;

  @override
  Coords get typeCoords =>
      CoordsExtension.select(is3D: is3D, isMeasured: isMeasured);

  @override
  String toString() {
    switch (typeCoords) {
      case Coords.xy:
        return '$x,$y';
      case Coords.xyz:
        return '$x,$y,$z';
      case Coords.xym:
        return '$x,$y,$m';
      case Coords.xyzm:
        return '$x,$y,$z,$m';
    }
  }
}
