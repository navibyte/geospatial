// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/base/codes.dart';
import '/src/utils/tolerance.dart';

import 'base_position.dart';
import 'position.dart';

/// A geographic position with longitude, latitude and optional elevation and m.
///
/// Longitude is available at [lon], latitude at [lat] and elevation at [elev].
/// [m] represents a measurement.
///
/// Longitude (range `[-180.0, 180.0[`) and latitude (range `[-90.0, 90.0]`) are
/// represented as deegrees. The unit for [elev] is meters.
@immutable
class GeoPosition extends BasePosition {
  /// A geographical position with [lon] and [lat], and optional [elev] and [m].
  ///
  /// Longitude is normalized to the range `[-180.0, 180.0[` using the formula
  /// `(lon + 180.0) % 360.0 - 180.0` (if outside the range) and latitude is
  /// clamped to the range `[-90.0, 90.0]`.
  const GeoPosition({
    required double lon,
    required double lat,
    double? elev,
    double? m,
  })  : _lon =
            lon >= -180.0 && lon < 180.0 ? lon : (lon + 180.0) % 360.0 - 180.0,
        _lat = lat < -90.0 ? -90.0 : (lat > 90.0 ? 90.0 : lat),
        _elev = elev,
        _m = m;

  /// A position from parameters compatible with `CreatePosition` function type.
  ///
  /// Coordinate values from parameters are copied as geographic coordinates:
  /// `x` => `lon`, `y` => `lat`, `z` => `elev`, `m` => `m`
  GeoPosition.create({required num x, required num y, num? z, num? m})
      : this(
          lon: x.toDouble(),
          lat: y.toDouble(),
          elev: z?.toDouble(),
          m: m?.toDouble(),
        );

  final double _lon;
  final double _lat;
  final double? _elev;
  final double? _m;

  /// The longitude coordinate.
  double get lon => _lon;

  /// The latitude coordinate.
  double get lat => _lat;

  /// The elevation (or altitude) coordinate in meters.
  ///
  /// Returns zero if not available.
  ///
  /// You can also use [is3D] to check whether elev coordinate is available, or
  /// [optElev] returns elev coordinate as nullable value.
  double get elev => _elev ?? 0.0;

  /// The elevation (or altitude) coordinate optionally in meters.
  ///
  /// Returns null if not available.
  ///
  /// You can also use [is3D] to check whether elev coordinate is available.
  double? get optElev => _elev;

  @override
  double get m => _m ?? 0.0;

  @override
  double? get optM => _m;

  /// A coordinate value by the coordinate axis index [i].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  @override
  double operator [](int i) => GeoPosition.getValue(this, i);

  /// Coordinate values of this position as an iterable of 2, 3 or 4 items.
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  @override
  Iterable<double> get values => GeoPosition.getValues(this);

  @override
  Position get asPosition => Position(x: _lon, y: _lat, z: _elev, m: _m);

  /// Copies the position with optional [x], [y], [z] and [m] overriding values.
  ///
  /// Coordinate values from parameters are copied as:
  /// `x` => `lon`, `y` => `lat`, `z` => `elev`, `m` => `m
  @override
  GeoPosition copyWith({num? x, num? y, num? z, num? m}) => GeoPosition.create(
        x: x ?? _lon,
        y: y ?? _lat,
        z: z ?? _elev,
        m: m ?? _m,
      );

  @override
  GeoPosition transform(TransformPosition transform) => transform(this);

  @override
  int get spatialDimension => typeCoords.spatialDimension;

  @override
  int get coordinateDimension => typeCoords.coordinateDimension;

  @override
  bool get isGeographic => true;

  @override
  bool get is3D => _elev != null;

  @override
  bool get isMeasured => _m != null;

  @override
  Coords get typeCoords => CoordsExtension.select(
        isGeographic: isGeographic,
        is3D: is3D,
        isMeasured: isMeasured,
      );

  @override
  String toString() {
    switch (typeCoords) {
      case Coords.lonLat:
        return '$_lon,$_lat';
      case Coords.lonLatElev:
        return '$_lon,$_lat,$_elev';
      case Coords.lonLatM:
        return '$_lon,$_lat,$_m';
      case Coords.lonLatElevM:
        return '$_lon,$_lat,$_elev,$_m';
      case Coords.xy:
      case Coords.xyz:
      case Coords.xym:
      case Coords.xyzm:
        return '<not projected>';
    }
  }

  @override
  bool operator ==(Object other) =>
      other is GeoPosition && GeoPosition.testEquals(this, other);

  @override
  int get hashCode => GeoPosition.hash(this);

  @override
  bool equals2D(BasePosition other, {num? toleranceHoriz}) =>
      other is GeoPosition &&
      GeoPosition.testEquals2D(
        this,
        other,
        toleranceHoriz: toleranceHoriz?.toDouble(),
      );

  @override
  bool equals3D(
    BasePosition other, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) =>
      other is GeoPosition &&
      GeoPosition.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz?.toDouble(),
        toleranceVert: toleranceVert?.toDouble(),
      );

  // ---------------------------------------------------------------------------
  // Static methods with default logic, used by GeoPosition itself too.

  /// A coordinate value of [position] by the coordinate axis index [i].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  static double getValue(GeoPosition position, int i) {
    if (position.is3D) {
      switch (i) {
        case 0:
          return position.lon;
        case 1:
          return position.lat;
        case 2:
          return position.elev;
        case 3:
          return position.m; // returns m or 0
        default:
          return 0.0;
      }
    } else {
      switch (i) {
        case 0:
          return position.lon;
        case 1:
          return position.lat;
        case 2:
          return position.m; // returns m or 0
        default:
          return 0.0;
      }
    }
  }

  /// Coordinate values of [position] as an iterable of 2, 3 or 4 items.
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  static Iterable<double> getValues(GeoPosition position) sync* {
    yield position.lon;
    yield position.lat;
    if (position.is3D) {
      yield position.elev;
    }
    if (position.isMeasured) {
      yield position.m;
    }
  }

  /// True if positions [p1] and [p2] equals by testing all coordinate values.
  static bool testEquals(GeoPosition p1, GeoPosition p2) =>
      p1.lon == p2.lon &&
      p1.lat == p2.lat &&
      p1.optElev == p2.optElev &&
      p1.optM == p2.optM;

  /// The hash code for [position].
  static int hash(GeoPosition position) =>
      Object.hash(position.lon, position.lat, position.optElev, position.optM);

  /// True if geo positions [p1] and [p2] equals by testing 2D coordinates only.
  static bool testEquals2D(
    GeoPosition p1,
    GeoPosition p2, {
    double? toleranceHoriz,
  }) {
    assertTolerance(toleranceHoriz);
    return toleranceHoriz != null
        ? (p1.lon - p2.lon).abs() <= toleranceHoriz &&
            (p1.lat - p2.lat).abs() <= toleranceHoriz
        : p1.lon == p2.lon && p1.lat == p2.lat;
  }

  /// True if geo positions [p1] and [p2] equals by testing 3D coordinates only.
  static bool testEquals3D(
    GeoPosition p1,
    GeoPosition p2, {
    double? toleranceHoriz,
    double? toleranceVert,
  }) {
    assertTolerance(toleranceVert);
    if (!GeoPosition.testEquals2D(p1, p2, toleranceHoriz: toleranceHoriz)) {
      return false;
    }
    if (!p1.is3D || !p1.is3D) {
      return false;
    }
    return toleranceVert != null
        ? (p1.elev - p2.elev).abs() <= toleranceVert
        : p1.elev == p2.elev;
  }
}
