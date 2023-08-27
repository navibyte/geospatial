// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/projected/projected.dart';
import '/src/coordinates/projection/projection.dart';

import 'dms.dart';

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
  /// clipped to the range `[-90.0, 90.0]`.
  ///
  /// As a special case if [lon] or [lat] is `double.nan` then that value is
  /// preserved (not normalized or clipped).
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
  const Geographic.create({
    required double x,
    required double y,
    double? z,
    double? m,
  }) : this(lon: x, lat: y, elev: z, m: m);

  /// Builds a geographic position from [coords] starting from [offset].
  ///
  /// Supported coordinate value combinations for [coords] are:
  /// (lon, lat), (lon, lat, elev), (lon, lat, m) or (lon, lat, elev, m)
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [coords] has 3 items, then (lon, lat, elev) coordinates are
  /// assumed.
  ///
  /// Throws FormatException if coordinates are invalid.
  factory Geographic.build(
    Iterable<num> coords, {
    int offset = 0,
    Coords? type,
  }) =>
      Position.buildPosition(
        coords,
        to: Geographic.create,
        offset: offset,
        type: type,
      );

  /// Parses a geographic position from [text].
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
  factory Geographic.parse(
    String text, {
    Pattern? delimiter = ',',
    Coords? type,
  }) =>
      Position.parsePosition(
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
  double get x => _lon;

  @override
  double get y => _lat;

  @override
  double get z => _elev ?? 0;

  @override
  double? get optZ => _elev;

  /// Copies the position with optional [x], [y], [z] and [m] overriding values.
  ///
  /// When copying `Geographic` then coordinates has correspondence:
  /// `x` => `lon`, `y` => `lat`, `z` => `elev`, `m` => `m`
  ///
  /// For example `Geographic(lon: 1.0, lat: 2.0)` equals to
  /// `Geographic(lon: 1.0, lat: 1.0).copyWith(y: 2.0)`
  ///
  /// Some sub classes may ignore a non-null z parameter value if a position is
  /// not a 3D position, and a non-null m parameter if a position is not a
  /// measured position. However [Geographic] itself supports changing the
  /// coordinate type.
  @override
  Geographic copyWith({double? x, double? y, double? z, double? m}) =>
      Geographic(
        lon: x ?? _lon,
        lat: y ?? _lat,
        elev: z ?? _elev,
        m: m ?? _m,
      );

  /// Projects this geographic position to a projected position using
  /// the forward [projection].
  @override
  Projected project(Projection projection) =>
      projection.project(this, to: Projected.create);

  @override
  Geographic transform(TransformPosition transform) => transform.call(this);

  @override
  bool get is3D => _elev != null;

  @override
  bool get isMeasured => _m != null;

  @override
  String toString() {
    switch (type) {
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
      other is Position && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);

  // ---------------------------------------------------------------------------
  // Special coordinate formats etc.

  /// Parses a geographic position from [lon] and [lat] text values that are
  /// formatted as specified (and parsed) by [format].
  ///
  /// By default the [Dms] class is used as the format.
  ///
  /// Optionally [elev] and/or [m] are parsed using the standard
  /// `double.tryParse` method.
  factory Geographic.parseDms({
    DmsFormat format = const Dms(),
    required String lon,
    required String lat,
    String? elev,
    String? m,
  }) =>
      Geographic(
        lon: format.parse(lon),
        lat: format.parse(lat),
        elev: elev != null ? double.tryParse(elev) : null,
        m: m != null ? double.tryParse(m) : null,
      );

  /// Formats [lat] according to [format].
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 51.4778, lon: -0.0014);
  ///
  ///   // Decimal degrees on latitude: 51.4778°N
  ///   final p1Deg = p1.latDms();
  ///
  ///   // DM representation with three decimals on latitude: 51°28.668′N
  ///   const dm = Dms(type: DmsType.degMin, decimals: 3);
  ///   final p1DegMin = p1.latDms(dm);
  ///
  ///   // DMS representation with narrow spaces on latitude: 51° 28′ 40″ N
  ///   const dms = Dms.narrowSpace(type: DmsType.degMinSec);
  ///   final p1DegMinSec = p1.latDms(dms);
  /// ```
  String latDms([DmsFormat format = const Dms()]) => format.lat(lat);

  /// Formats [lon] according to [format].
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 51.4778, lon: -0.0014);
  ///
  ///   // Decimal degrees on longitude: 0.0014°W
  ///   final p1Deg = p1.lonDms();
  ///
  ///   // DM representation with three decimals on longitude: 0°00.084′W
  ///   const dm = Dms(type: DmsType.degMin, decimals: 3);
  ///   final p1DegMin = p1.lonDms(dm);
  ///
  ///   // DMS representation with narrow spaces on longitude: 0° 00′ 05″ W
  ///   const dms = Dms.narrowSpace(type: DmsType.degMinSec);
  ///   final p1DegMinSec = p1.lonDms(dms);
  /// ```
  String lonDms([DmsFormat format = const Dms()]) => format.lon(lon);

  /// Formats [lat] and [lon] according to [format], with [lat] formatted first
  /// and separated from [lon] by [separator].
  ///
  /// If this position contains an elevation in [optElev], then it's formatted
  /// after longitude according to [elevUnits] and [elevDecimals].
  ///
  /// If this position contains a measure in [optM], then it's formatted after
  /// elevation according to [mUnits] and [mDecimals].
  ///
  /// Examples:
  /// ```dart
  ///   const p1 = Geographic(lat: 51.4778, lon: -0.0014);
  ///
  ///   // Decimal degrees on lat-lon: 51.4778°N 0.0014°W
  ///   final p1Deg = p1.latLonDms(separator: ' ');
  ///
  ///   // DM with three decimals on lat-lon: 51°28.668′N, 0°00.084′W
  ///   const dm = Dms(type: DmsType.degMin, decimals: 3);
  ///   final p1DegMin = p1.latLonDms(format: dm);
  ///
  ///   // DMS with narrow spaces on lat-lon: 51° 28′ 40″ N, 0° 00′ 05″ W
  ///   const dms = Dms.narrowSpace(type: DmsType.degMinSec);
  ///   final p1DegMinSec = p1.latLonDms(format: dms);
  ///
  ///   // geographic position with elevation
  ///   const p2 = Geographic(lon: -0.0014, lat: 51.4778, elev: 45.83764);
  ///
  ///   // DMS lat-lon with elevation: 51°28′40.080″N, 0°0′5.040″W
  ///   const format = Dms(
  ///     type: DmsType.degMinSec,
  ///     decimals: 3,
  ///     zeroPadMinSec: false,
  ///   );
  ///   final p2DegMinSecWithElev = p2.latLonDms(format: format);
  /// ```
  String latLonDms({
    DmsFormat format = const Dms(),
    String separator = ', ',
    String elevUnits = 'm',
    int elevDecimals = 2,
    String mUnits = '',
    int mDecimals = 2,
  }) {
    final buf = StringBuffer();
    Geographic.writeLatLonDms(
      buf,
      this,
      format: format,
      separator: separator,
      elevUnits: elevUnits,
      elevDecimals: elevDecimals,
      mUnits: mUnits,
      mDecimals: mDecimals,
    );
    return buf.toString();
  }

  /// Formats geographic [position] according to [format] and writes it to
  /// [buf].
  ///
  /// See also [latLonDms] for documentation.
  static void writeLatLonDms(
    StringSink buf,
    Geographic position, {
    DmsFormat format = const Dms(),
    String separator = ' ',
    String elevUnits = 'm',
    int elevDecimals = 2,
    String mUnits = '',
    int mDecimals = 2,
  }) {
    buf
      ..write(format.lat(position.lat))
      ..write(separator)
      ..write(format.lon(position.lon));

    final elev = position.optElev;
    if (elev != null) {
      buf
        ..write(separator)
        ..write(elev.toStringAsFixed(elevDecimals))
        ..write(elevUnits);
    }

    final m = position.optM;
    if (m != null) {
      buf
        ..write(separator)
        ..write(m.toStringAsFixed(mDecimals))
        ..write(mUnits);
    }
  }
}
