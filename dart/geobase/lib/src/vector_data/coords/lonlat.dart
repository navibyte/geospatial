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
import '/src/coordinates/projection/projection.dart';
import '/src/utils/format_validation.dart';
import '/src/utils/num.dart';
import '/src/vector_data/array/coordinates.dart';

import 'xy.dart';

/// A geographic position as an iterable collection of lon and lat values.
///
/// Such position is a valid [Geographic] implementation with the type
/// `Coords.xy` and represents coordinate values also as a collection of
/// `Iterable<double>` with exactly 2 items.
///
/// See [Geographic] for description about supported coordinate values.
@Deprecated('Use Geographic or ListCoordinateExtension instead.')
@immutable
class LonLat extends PositionCoords implements Geographic {
  /// A geographic position as an iterable collection of [lon] and [lat] values.
  ///
  /// Longitude is normalized using `wrapLongitude` and latitude is clipped
  /// using `clipLatitude` before storing values.
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
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
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
  factory LonLat.create({
    required double x,
    required double y,
    // ignore: avoid_unused_constructor_parameters
    double? z,
    // ignore: avoid_unused_constructor_parameters
    double? m,
  }) =>
      LonLat(x, y);

  /// A geographic position as an iterable collection of lon and lat values.
  ///
  /// The `source` collection must have exactly 2 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
  const LonLat.view(super.source)
      : assert(source.length == 2, 'LonLat must have exactly 2 values'),
        super();

  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
  const LonLat._(super.source) : super();

  /// Parses a geographic position as an iterable collection from [text].
  ///
  /// Coordinate values (lon, lat) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
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
  LonLat copyWith({double? x, double? y, double? z, double? m}) => LonLat(
        x ?? lon,
        y ?? lat,
      );

  @override
  XY project(Projection projection) => projection.project(this, to: XY.create);

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
  String latDms([DmsFormat format = const Dms()]) => format.lat(lat);

  @override
  String lonDms([DmsFormat format = const Dms()]) => format.lon(lon);

  @override
  String latLonDms({
    DmsFormat format = const Dms(),
    String separator = ' ',
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
}

/// A geographic position as an iterable collection of lon, lat and elev values.
///
/// Such position is a valid [Geographic] implementation with the type
/// `Coords.xyz` and represents coordinate values also as a collection of
/// `Iterable<double>` with exactly 3 items.
///
/// See [Geographic] for description about supported coordinate values.
@Deprecated('Use Geographic or ListCoordinateExtension instead.')
class LonLatElev extends LonLat {
  /// A geographic position as an iterable collection of [lon], [lat] and [elev]
  /// values.
  ///
  /// Longitude is normalized using `wrapLongitude` and latitude is clipped
  /// using `clipLatitude` before storing values.
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
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
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
  factory LonLatElev.create({
    required double x,
    required double y,
    // ignore: avoid_unused_constructor_parameters
    double? z,
    // ignore: avoid_unused_constructor_parameters
    double? m,
  }) =>
      LonLatElev(
        x,
        y,
        z ?? 0.0,
      );

  /// A geographic position as an iterable collection of lon, lat and elev
  /// values.
  ///
  /// The `source` collection must have exactly 3 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
  const LonLatElev.view(super.source)
      : assert(source.length == 3, 'LonLatElev must have exactly 3 values'),
        super._();

  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
  const LonLatElev._(super.source) : super._();

  /// Parses a geographic position as an iterable collection from [text].
  ///
  /// Coordinate values (lon, lat, elev) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
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
  LonLatElev copyWith({double? x, double? y, double? z, double? m}) =>
      LonLatElev(
        x ?? lon,
        y ?? lat,
        z ?? elev,
      );

  @override
  XYZ project(Projection projection) =>
      projection.project(this, to: XYZ.create);

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
@Deprecated('Use Geographic or ListCoordinateExtension instead.')
class LonLatM extends LonLat {
  /// A geographic position as an iterable collection of [lon], [lat] and [m]
  /// values.
  ///
  /// Longitude is normalized using `wrapLongitude` and latitude is clipped
  /// using `clipLatitude` before storing values.
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
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
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
  factory LonLatM.create({
    required double x,
    required double y,
    // ignore: avoid_unused_constructor_parameters
    double? z,
    double? m,
  }) =>
      LonLatM(
        x,
        y,
        m ?? 0.0,
      );

  /// A geographic position as an iterable collection of lon, lat and m values.
  ///
  /// The `source` collection must have exactly 3 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
  const LonLatM.view(super.source)
      : assert(source.length == 3, 'LonLatM must have exactly 3 values'),
        super._();

  /// Parses a geographic position as an iterable collection from [text].
  ///
  /// Coordinate values (lon, lat, m) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
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
  LonLatM copyWith({double? x, double? y, double? z, double? m}) => LonLatM(
        x ?? lon,
        y ?? lat,
        m ?? this.m,
      );

  @override
  XYM project(Projection projection) =>
      projection.project(this, to: XYM.create);

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
@Deprecated('Use Geographic or ListCoordinateExtension instead.')
class LonLatElevM extends LonLatElev {
  /// A geographic position as an iterable collection of [lon], [lat], [elev]
  /// and [m] values.
  ///
  /// Longitude is normalized using `wrapLongitude` and latitude is clipped
  /// using `clipLatitude` before storing values.
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
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
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
  factory LonLatElevM.create({
    required double x,
    required double y,
    double? z,
    double? m,
  }) =>
      LonLatElevM(
        x,
        y,
        z ?? 0.0,
        m ?? 0.0,
      );

  /// A geographic position as an iterable collection of lon, lat, elev and m
  /// values.
  ///
  /// The `source` collection must have exactly 4 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
  const LonLatElevM.view(super.source)
      : assert(source.length == 4, 'LonLatElevM must have exactly 4 values'),
        super._();

  /// Parses a geographic position as an iterable collection from [text].
  ///
  /// Coordinate values (lon, lat, elev, m) in [text] are separated by
  /// [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  @Deprecated('Use Geographic or ListCoordinateExtension instead.')
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
  LonLatElevM copyWith({double? x, double? y, double? z, double? m}) =>
      LonLatElevM(
        x ?? lon,
        y ?? lat,
        z ?? elev,
        m ?? this.m,
      );

  @override
  XYZM project(Projection projection) =>
      projection.project(this, to: XYZM.create);

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
