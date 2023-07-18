// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/geographic/dms.dart';
import '/src/coordinates/geographic/geographic.dart';
import '/src/coordinates/geographic/geographic_functions.dart';
import '/src/utils/format_validation.dart';
import '/src/utils/num.dart';
import '/src/vector_data/array/coordinates.dart';

/// A geographic position as an iterable collection of lon and lat values.
///
/// Such position is a valid [Geographic] implementation with the type
/// `Coords.xy` and represents coordinate values also as a collection of
/// `Iterable<double>` with exactly 2 items.
///
/// See [Geographic] for description about supported coordinate values.
@immutable
class LonLat extends PositionCoords implements Geographic {
  /// A geographic position as an iterable collection of [lon] and [lat] values.
  ///
  /// Longitude is normalized using `wrapLongitude` and latitude is clipped
  /// using `clipLatitude` before storing values.
  factory LonLat(double lon, double lat) {
    // create a fixed list of 2 items
    final list = List<double>.filled(2, 0);
    list[0] = lon.wrapLongitude();
    list[1] = lat.clipLatitude();
    return LonLat.view(list);
  }

  /// A geographic position as an iterable collection of lon and lat values.
  ///
  /// Coordinate values from parameters are copied as geographic coordinates:
  /// `x` => `lon`, `y` => `lat`
  ///
  /// Parameters `z` and `m` are ignored.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  // ignore: avoid_unused_constructor_parameters
  factory LonLat.create({required num x, required num y, num? z, num? m}) =>
      LonLat(
        x.toDouble(),
        y.toDouble(),
      );

  /// A geographic position as an iterable collection of lon and lat values.
  ///
  /// The `source` collection must have exactly 2 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  const LonLat.view(super.source)
      : assert(source.length == 2, 'LonLat must have exactly 2 values'),
        super();

  const LonLat._(super.source) : super();

  /// Parses a geographic position as an iterable collection from [text].
  ///
  /// Coordinate values (lon, lat) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory LonLat.parse(
    String text, {
    Pattern? delimiter = ',',
  }) {
    final coords =
        parseDoubleValues(text, delimiter: delimiter).toList(growable: false);
    if (coords.length != 2) {
      throw invalidCoordinates;
    }
    return LonLat.view(coords);
  }

  @override
  LonLat copyWith({num? x, num? y, num? z, num? m}) => LonLat(
        x?.toDouble() ?? lon,
        y?.toDouble() ?? lat,
      );

  @override
  LonLat transform(TransformPosition transform) => transform.call(this);

  @override
  Geographic get asGeographic => this;

  @override
  int get spatialDimension => 2;

  @override
  int get coordinateDimension => 2;

  @override
  bool get is3D => false;

  @override
  bool get isMeasured => false;

  @override
  Coords get type => Coords.xy;

  @override
  double get x => lon;

  @override
  double get y => lat;

  @override
  double get z => elev;

  @override
  double? get optZ => optElev;

  @override
  double get lon => elementAt(0);

  @override
  double get lat => elementAt(1);

  @override
  double get elev => 0.0;

  @override
  double? get optElev => null;

  @override
  double get m => 0.0;

  @override
  double? get optM => null;

  @override
  Iterable<double> get values => this;

  @override
  bool operator ==(Object other) =>
      other is Position && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);

  @override
  String toString() => '$lon,$lat';

  @override
  String toDmsLat([DmsFormat format = const Dms()]) => format.lat(lat);

  @override
  String toDmsLon([DmsFormat format = const Dms()]) => format.lon(lon);

  @override
  String toDmsLatLon({
    DmsFormat format = const Dms(),
    String separator = ' ',
    String elevUnits = 'm',
    int elevDecimals = 2,
    String mUnits = '',
    int mDecimals = 2,
  }) {
    final buf = StringBuffer();
    Geographic.writeDmsLatLon(
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
}

/// A geographic position as an iterable collection of lon, lat and elev values.
///
/// Such position is a valid [Geographic] implementation with the type
/// `Coords.xyz` and represents coordinate values also as a collection of
/// `Iterable<double>` with exactly 3 items.
///
/// See [Geographic] for description about supported coordinate values.
class LonLatElev extends LonLat {
  /// A geographic position as an iterable collection of [lon], [lat] and [elev]
  /// values.
  ///
  /// Longitude is normalized using `wrapLongitude` and latitude is clipped
  /// using `clipLatitude` before storing values.
  factory LonLatElev(double lon, double lat, double elev) {
    // create a fixed list of 3 items
    final list = List<double>.filled(3, 0);
    list[0] = lon.wrapLongitude();
    list[1] = lat.clipLatitude();
    list[2] = elev;
    return LonLatElev.view(list);
  }

  /// A geographic position as an iterable collection of lon, lat and elev
  /// values.
  ///
  /// Coordinate values from parameters are copied as geographic coordinates:
  /// `x` => `lon`, `y` => `lat`, `z` => `elev`
  ///
  /// The default value for `elev` is `0.0`.
  ///
  /// The parameter `m` is ignored.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  // ignore: avoid_unused_constructor_parameters
  factory LonLatElev.create({required num x, required num y, num? z, num? m}) =>
      LonLatElev(
        x.toDouble(),
        y.toDouble(),
        (z ?? 0.0).toDouble(),
      );

  /// A geographic position as an iterable collection of lon, lat and elev
  /// values.
  ///
  /// The `source` collection must have exactly 3 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  const LonLatElev.view(super.source)
      : assert(source.length == 3, 'LonLatElev must have exactly 3 values'),
        super._();

  const LonLatElev._(super.source) : super._();

  /// Parses a geographic position as an iterable collection from [text].
  ///
  /// Coordinate values (lon, lat, elev) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory LonLatElev.parse(
    String text, {
    Pattern? delimiter = ',',
  }) {
    final coords =
        parseDoubleValues(text, delimiter: delimiter).toList(growable: false);
    if (coords.length != 3) {
      throw invalidCoordinates;
    }
    return LonLatElev.view(coords);
  }

  @override
  LonLatElev copyWith({num? x, num? y, num? z, num? m}) => LonLatElev(
        x?.toDouble() ?? lon,
        y?.toDouble() ?? lat,
        z?.toDouble() ?? elev,
      );

  @override
  LonLatElev transform(TransformPosition transform) => transform.call(this);

  @override
  int get spatialDimension => 3;

  @override
  int get coordinateDimension => 3;

  @override
  bool get is3D => true;

  @override
  Coords get type => Coords.xyz;

  @override
  double get elev => elementAt(2);

  @override
  double? get optElev => elev;

  @override
  String toString() => '$lon,$lat,$elev';
}

/// A geographic position as an iterable collection of lon, lat and m values.
///
/// Such position is a valid [Geographic] implementation with the type
/// `Coords.xym` and represents coordinate values also as a collection of
/// `Iterable<double>` with exactly 3 items.
///
/// See [Geographic] for description about supported coordinate values.
class LonLatM extends LonLat {
  /// A geographic position as an iterable collection of [lon], [lat] and [m]
  /// values.
  ///
  /// Longitude is normalized using `wrapLongitude` and latitude is clipped
  /// using `clipLatitude` before storing values.
  factory LonLatM(double lon, double lat, double m) {
    // create a fixed list of 3 items
    final list = List<double>.filled(3, 0);
    list[0] = lon.wrapLongitude();
    list[1] = lat.clipLatitude();
    list[2] = m;
    return LonLatM.view(list);
  }

  /// A geographic position as an iterable collection of lon, lat and m values.
  ///
  /// Coordinate values from parameters are copied as geographic coordinates:
  /// `x` => `lon`, `y` => `lat`, `m` => `m`
  ///
  /// The default value for `m` is `0.0`.
  ///
  /// The parameter `z` is ignored.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  // ignore: avoid_unused_constructor_parameters
  factory LonLatM.create({required num x, required num y, num? z, num? m}) =>
      LonLatM(
        x.toDouble(),
        y.toDouble(),
        (m ?? 0.0).toDouble(),
      );

  /// A geographic position as an iterable collection of lon, lat and m values.
  ///
  /// The `source` collection must have exactly 3 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  const LonLatM.view(super.source)
      : assert(source.length == 3, 'LonLatM must have exactly 3 values'),
        super._();

  /// Parses a geographic position as an iterable collection from [text].
  ///
  /// Coordinate values (lon, lat, m) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory LonLatM.parse(
    String text, {
    Pattern? delimiter = ',',
  }) {
    final coords =
        parseDoubleValues(text, delimiter: delimiter).toList(growable: false);
    if (coords.length != 3) {
      throw invalidCoordinates;
    }
    return LonLatM.view(coords);
  }

  @override
  LonLatM copyWith({num? x, num? y, num? z, num? m}) => LonLatM(
        x?.toDouble() ?? lon,
        y?.toDouble() ?? lat,
        m?.toDouble() ?? this.m,
      );

  @override
  LonLatM transform(TransformPosition transform) => transform.call(this);

  @override
  int get coordinateDimension => 3;

  @override
  bool get isMeasured => true;

  @override
  Coords get type => Coords.xym;

  @override
  double get m => elementAt(2);

  @override
  double? get optM => m;

  @override
  String toString() => '$lon,$lat,$m';
}

/// A geographic position as an iterable collection of lon, lat, elev and m
/// values.
///
/// Such position is a valid [Geographic] implementation with the type
/// `Coords.xyzm` and represents coordinate values also as a collection of
/// `Iterable<double>` with exactly 4 items.
///
/// See [Geographic] for description about supported coordinate values.
class LonLatElevM extends LonLatElev {
  /// A geographic position as an iterable collection of [lon], [lat], [elev]
  /// and [m] values.
  ///
  /// Longitude is normalized using `wrapLongitude` and latitude is clipped
  /// using `clipLatitude` before storing values.
  factory LonLatElevM(double lon, double lat, double elev, double m) {
    // create a fixed list of 4 items
    final list = List<double>.filled(4, 0);
    list[0] = lon.wrapLongitude();
    list[1] = lat.clipLatitude();
    list[2] = elev;
    list[3] = m;
    return LonLatElevM.view(list);
  }

  /// A geographic position as an iterable collection of lon, lat, elev and m
  /// values.
  ///
  /// Coordinate values from parameters are copied as geographic coordinates:
  /// `x` => `lon`, `y` => `lat`, `z` => `elev`, `m` => `m`
  ///
  /// The default value for `elev` and `m` is `0.0`.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  factory LonLatElevM.create({
    required num x,
    required num y,
    num? z,
    num? m,
  }) =>
      LonLatElevM(
        x.toDouble(),
        y.toDouble(),
        (z ?? 0.0).toDouble(),
        (m ?? 0.0).toDouble(),
      );

  /// A geographic position as an iterable collection of lon, lat, elev and m
  /// values.
  ///
  /// The `source` collection must have exactly 4 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  const LonLatElevM.view(super.source)
      : assert(source.length == 4, 'LonLatElevM must have exactly 4 values'),
        super._();

  /// Parses a geographic position as an iterable collection from [text].
  ///
  /// Coordinate values (lon, lat, elev, m) in [text] are separated by
  /// [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory LonLatElevM.parse(
    String text, {
    Pattern? delimiter = ',',
  }) {
    final coords =
        parseDoubleValues(text, delimiter: delimiter).toList(growable: false);
    if (coords.length != 4) {
      throw invalidCoordinates;
    }
    return LonLatElevM.view(coords);
  }

  @override
  LonLatElevM copyWith({num? x, num? y, num? z, num? m}) => LonLatElevM(
        x?.toDouble() ?? lon,
        y?.toDouble() ?? lat,
        z?.toDouble() ?? elev,
        m?.toDouble() ?? this.m,
      );

  @override
  LonLatElevM transform(TransformPosition transform) => transform.call(this);

  @override
  int get coordinateDimension => 4;

  @override
  bool get isMeasured => true;

  @override
  Coords get type => Coords.xyzm;

  @override
  double get m => elementAt(3);

  @override
  double? get optM => m;

  @override
  String toString() => '$lon,$lat,$elev,$m';
}
