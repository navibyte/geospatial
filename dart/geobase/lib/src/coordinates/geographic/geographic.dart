// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base.dart';

/// A geographic position with longitude, latitude and optional elevation and m.
///
/// Longitude is available at [lon], latitude at [lat] and elevation at [elev].
/// [m] represents a measurement.
///
/// Longitude (range `[-180.0, 180.0[`) and latitude (range `[-90.0, 90.0]`) are
/// represented as deegrees. The unit for [elev] is meters.
///
/// *Geographic* coordinates are based on a spherical or ellipsoidal coordinate
/// system representing positions on the Earth as longitude ([lon]) and latitude
/// ([lat]).
///
/// [m] represents a measurement or a value on a linear referencing system (like
/// time). It could be associated with a 2D position (lon, lat, m) or a 3D
/// position (lon, lat, elev, m).
///
/// For 2D coordinates the coordinate axis indexes are:
///
/// Index | Geographic
/// ----- | ----------
/// 0     | lon
/// 1     | lat
/// 2     | m
///
/// For 3D coordinates the coordinate axis indexes are:
///
/// Index | Geographic
/// ----- | ----------
/// 0     | lon
/// 1     | lat
/// 2     | elev
/// 3     | m
@immutable
class Geographic extends Position {
  final double _lon;
  final double _lat;
  final double? _elev;
  final double? _m;

  /// A geographic position with [lon] and [lat], and optional [elev] and [m].
  ///
  /// Longitude is normalized to the range `[-180.0, 180.0[` using the formula
  /// `(lon + 180.0) % 360.0 - 180.0` (if outside the range) and latitude is
  /// clamped to the range `[-90.0, 90.0]`.
  const Geographic({
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
  Geographic.create({required num x, required num y, num? z, num? m})
      : this(
          lon: x.toDouble(),
          lat: y.toDouble(),
          elev: z?.toDouble(),
          m: m?.toDouble(),
        );

  /// Creates a geographic position from [coords] starting from [offset].
  ///
  /// Supported coordinate value combinations for [coords] are:
  /// (lon, lat), (lon, lat, elev), (lon, lat, m) or (lon, lat, elev, m)
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [coords] has 3 items, then (lon, lat, elev) coordinates are
  /// assumed.
  ///
  /// Throws FormatException if coordinates are invalid.
  factory Geographic.fromCoords(
    Iterable<num> coords, {
    int offset = 0,
    Coords? type,
  }) =>
      Position.createFromCoords(
        coords,
        to: Geographic.create,
        offset: offset,
        type: type,
      );

  /// Creates a geographic position from [text].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// Supported coordinate value combinations for [text] are:
  /// (lon, lat), (lon, lat, elev), (lon, lat, m) or (lon, lat, elev, m)
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [text] has 3 items, then (lon, lat, elev) coordinates are
  /// assumed.
  ///
  /// Throws FormatException if coordinates are invalid.
  factory Geographic.fromText(
    String text, {
    Pattern? delimiter = ',',
    Coords? type,
  }) =>
      Position.createFromText(
        text,
        to: Geographic.create,
        delimiter: delimiter,
        type: type,
      );

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

  @override
  num get x => _lon;

  @override
  num get y => _lat;

  @override
  num get z => _elev ?? 0;

  @override
  num? get optZ => _elev;

  @override
  double operator [](int i) => Geographic.getValue(this, i);

  @override
  Iterable<double> get values => Geographic.getValues(this);

  @override
  R copyTo<R extends Position>(CreatePosition<R> factory) =>
      factory.call(x: _lon, y: _lat, z: _elev, m: _m);

  @override
  Geographic copyWith({num? x, num? y, num? z, num? m}) => Geographic.create(
        x: x ?? _lon,
        y: y ?? _lat,
        z: z ?? _elev,
        m: m ?? _m,
      );

  @override
  Geographic transform(TransformPosition transform) => transform.call(this);

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
  Coords get typeCoords => Coords.select(
        is3D: is3D,
        isMeasured: isMeasured,
      );

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

  @override
  bool operator ==(Object other) =>
      other is Geographic && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);

  // ---------------------------------------------------------------------------
  // Static methods with default logic, used by Geographic itself too.

  /// A coordinate value of [position] by the coordinate axis index [i].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For 2D coordinates the coordinate axis indexes are:
  ///
  /// Index | Geographic
  /// ----- | ----------
  /// 0     | lon
  /// 1     | lat
  /// 2     | m
  ///
  /// For 3D coordinates the coordinate axis indexes are:
  ///
  /// Index | Geographic
  /// ----- | ----------
  /// 0     | lon
  /// 1     | lat
  /// 2     | elev
  /// 3     | m
  static double getValue(Geographic position, int i) {
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
  /// (lon, lat), (lon, lat, elev), (lon, lat, m) or (lon, lat, elev, m).
  static Iterable<double> getValues(Geographic position) sync* {
    yield position.lon;
    yield position.lat;
    if (position.is3D) {
      yield position.elev;
    }
    if (position.isMeasured) {
      yield position.m;
    }
  }
}
