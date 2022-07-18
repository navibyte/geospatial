// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base.dart';
import '/src/coordinates/geographic.dart';

import 'position_coords.dart';

/// A geographic position as an iterable collection of coordinate values.
///
/// Such position is a valid [Geographic] implementation and represents
/// coordinate values also as a collection of `Iterable<double>` (containing 2,
/// 3, or 4 items).
/// 
/// This abstract class has four sub classes with different sets of coordinate
/// values available:
///
/// Class         | 2D/3D | Coords | Type     | lon (x) | lat (y) | elev (z) | m 
/// ------------- | ----- | ------ | -------- | ------- | ------- | -------- | -
/// [LonLat]      | 2D    | 2      | `double` |    +    |    +    |          |  
/// [LonLatElev]  | 3D    | 3      | `double` |    +    |    +    |    +     |  
/// [LonLatM]     | 2D    | 3      | `double` |    +    |    +    |          | +
/// [LonLatElevM] | 3D    | 4      | `double` |    +    |    +    |    +     | +
///
/// See [Geographic] for description about supported coordinate values.
@immutable
abstract class GeographicCoords extends PositionCoords<double>
    implements Geographic {
  const GeographicCoords._(Iterable<double> source) : _data = source;

  /// A geographic position as an iterable collection of [lon], [lat], and
  /// optional [elev] and [m] values.
  ///
  /// Returns an instance of [LonLat], [LonLatElev], [LonLatM] or
  /// [LonLatElevM].
  ///
  /// This factory is compatible with `CreatePosition` function type.
  factory GeographicCoords.create({
    required num x,
    required num y,
    num? z,
    num? m,
  }) {
    // x => lon, y => lat, z => elev, m => m
    if (z != null) {
      // 3D coordinates
      if (m != null) {
        // 3D and measured coordinates
        return LonLatElevM.create(x: x, y: y, z: z, m: m);
      } else {
        return LonLatElev.create(x: x, y: y, z: z);
      }
    } else {
      // 2D coordinates
      if (m != null) {
        // 2D and measured coordinates
        return LonLatM.create(x: x, y: y, m: m);
      } else {
        return LonLat.create(x: x, y: y);
      }
    }
  }

  /// A geographic position with coordinate values as a view backed by [source].
  ///
  /// Returns an instance of [LonLat], [LonLatElev], [LonLatM] or [LonLatElevM].
  /// When [type] is given, then it's used to select the appropriate class.
  /// Otherwise the coordinate dimension of [source] values resolves the class
  /// (2 => LonLat, 3 => LonLatElev, 4 => LonLatElevM).
  ///
  /// An iterable collection of [source] may be represented by a [List] or any
  /// [Iterable] with efficient `length` and `elementAt` implementations.
  ///
  /// Throws FormatException is the coordinate dimension of [source] is not 2,
  /// 3 or 4.
  factory GeographicCoords.view(Iterable<double> source, {Coords? type}) {
    switch (type ?? Coords.fromDimension(source.length)) {
      case Coords.xy:
        return LonLat.view(source);
      case Coords.xyz:
        return LonLatElev.view(source);
      case Coords.xym:
        return LonLatM.view(source);
      case Coords.xyzm:
        return LonLatElevM.view(source);
    }
  }

  /// A geographic position with coordinate values copied from [source].
  ///
  /// Returns an instance of [LonLat], [LonLatElev], [LonLatM] or [LonLatElevM].
  /// When [type] is given, then it's used to select the appropriate class.
  /// Otherwise the coordinate dimension of [source] values resolves the class
  /// (2 => LonLat, 3 => LonLatElev, 4 => LonLatElevM).
  ///
  /// Throws FormatException is the coordinate dimension of [source] is not 2,
  /// 3 or 4.
  factory GeographicCoords.fromCoords(Iterable<num> source, {Coords? type}) {
    // copy from Iterable<num> to fixed size List<double> that is used as data
    final data = source is Iterable<double>
        ? source.toList(growable: false)
        : source.map<double>((e) => e.toDouble()).toList(growable: false);

    // create a geographic position with copied list as data
    return GeographicCoords.view(data, type: type);
  }

  /// A geographic position as an iterable collection parsed from [text].
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
  /// Returns an instance of [LonLat], [LonLatElev], [LonLatM] or [LonLatElevM].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory GeographicCoords.fromText(
    String text, {
    Pattern? delimiter = ',',
    Coords? type,
  }) =>
      Position.createFromText(
        text,
        to: GeographicCoords.create,
        delimiter: delimiter,
        type: type,
      );

  final Iterable<double> _data;

  @override
  Iterable<double> get values => _data;

  @override
  double operator [](int index) => elementAt(index);

  @override
  bool get isGeographic => true;

  @override
  num get x => lon;

  @override
  num get y => lat;

  @override
  num get z => elev;

  @override
  num? get optZ => optElev;

  @override
  bool operator ==(Object other) =>
      other is Geographic && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);

  // .......... Iterable<double> implementation below

  @override
  double elementAt(int index) =>
      index >= 0 && index < coordinateDimension ? _data.elementAt(index) : 0.0;

  @override
  int get length => coordinateDimension;

  @override
  bool get isEmpty => false;

  @override
  bool get isNotEmpty => true;

  @override
  double get single => throw StateError('Position has at least 2 items');

  @override
  Iterator<double> get iterator => _data.iterator;

  @override
  bool any(bool Function(double element) test) => _data.any(test);

  @override
  Iterable<R> cast<R>() => _data.cast<R>();

  @override
  bool contains(Object? element) => _data.contains(element);

  @override
  bool every(bool Function(double element) test) => _data.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(double element) toElements) =>
      _data.expand<T>(toElements);

  @override
  double get first => _data.first;

  @override
  double firstWhere(
    bool Function(double element) test, {
    double Function()? orElse,
  }) =>
      _data.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(
    T initialValue,
    T Function(T previousValue, double element) combine,
  ) =>
      _data.fold<T>(initialValue, combine);

  @override
  Iterable<double> followedBy(Iterable<double> other) =>
      _data.followedBy(other);

  @override
  void forEach(void Function(double element) action) => _data.forEach(action);

  @override
  String join([String separator = '']) => _data.join(separator);

  @override
  double get last => _data.last;

  @override
  double lastWhere(
    bool Function(double element) test, {
    double Function()? orElse,
  }) =>
      _data.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(double e) toElement) => _data.map<T>(toElement);

  @override
  double reduce(double Function(double value, double element) combine) =>
      _data.reduce(combine);

  @override
  double singleWhere(
    bool Function(double element) test, {
    double Function()? orElse,
  }) =>
      _data.singleWhere(test, orElse: orElse);

  @override
  Iterable<double> skip(int count) => _data.skip(count);

  @override
  Iterable<double> skipWhile(bool Function(double value) test) =>
      _data.skipWhile(test);

  @override
  Iterable<double> take(int count) => _data.take(count);

  @override
  Iterable<double> takeWhile(bool Function(double value) test) =>
      _data.takeWhile(test);

  @override
  List<double> toList({bool growable = true}) =>
      _data.toList(growable: growable);

  @override
  Set<double> toSet() => _data.toSet();

  @override
  Iterable<double> where(bool Function(double element) test) =>
      _data.where(test);

  @override
  Iterable<T> whereType<T>() => _data.whereType();
}

/// A geographic position as an iterable collection of lon and lat values.
///
/// Such position is a valid [Geographic] implementation with the type
/// `Coords.xy` and represents coordinate values also as a collection of
/// `Iterable<double>` with exactly 2 items.
///
/// See [Geographic] for description about supported coordinate values.
class LonLat extends GeographicCoords {
  /// A geographic position as an iterable collection of [lon] and [lat] values.
  factory LonLat(double lon, double lat) {
    // create a fixed list of 2 items
    final list = List<double>.filled(2, 0);
    list[0] = lon;
    list[1] = lat;
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
        super._();

  const LonLat._(super.source) : super._();

  /// A geographic position as an iterable collection parsed from [text].
  ///
  /// Coordinate values (lon, lat) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory LonLat.fromText(
    String text, {
    Pattern? delimiter = ',',
  }) =>
      Position.createFromText(
        text,
        to: LonLat.create,
        delimiter: delimiter,
        type: Coords.xy,
      );

  @override
  LonLat copyWith({num? x, num? y, num? z, num? m}) => LonLat(
        x?.toDouble() ?? lon,
        y?.toDouble() ?? lat,
      );

  @override
  LonLat transform(TransformPosition transform) => transform.call(this);

  @override
  int get spatialDimension => 2;

  @override
  int get coordinateDimension => 2;

  @override
  bool get is3D => false;

  @override
  bool get isMeasured => false;

  @override
  Coords get typeCoords => Coords.xy;

  @override
  double get lon => _data.elementAt(0);

  @override
  double get lat => _data.elementAt(1);

  @override
  double get elev => 0;

  @override
  double? get optElev => null;

  @override
  double get m => 0;

  @override
  double? get optM => null;

  @override
  String toString() => '$lon,$lat';
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
  factory LonLatElev(double lon, double lat, double elev) {
    // create a fixed list of 3 items
    final list = List<double>.filled(3, 0);
    list[0] = lon;
    list[1] = lat;
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

  /// A geographic position as an iterable collection parsed from [text].
  ///
  /// Coordinate values (lon, lat, elev) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory LonLatElev.fromText(
    String text, {
    Pattern? delimiter = ',',
  }) =>
      Position.createFromText(
        text,
        to: LonLatElev.create,
        delimiter: delimiter,
        type: Coords.xyz,
      );

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
  Coords get typeCoords => Coords.xyz;

  @override
  double get elev => _data.elementAt(2);

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
  factory LonLatM(double lon, double lat, double m) {
    // create a fixed list of 3 items
    final list = List<double>.filled(3, 0);
    list[0] = lon;
    list[1] = lat;
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

  /// A geographic position as an iterable collection parsed from [text].
  ///
  /// Coordinate values (lon, lat, m) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory LonLatM.fromText(
    String text, {
    Pattern? delimiter = ',',
  }) =>
      Position.createFromText(
        text,
        to: LonLatM.create,
        delimiter: delimiter,
        type: Coords.xym,
      );

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
  Coords get typeCoords => Coords.xym;

  @override
  double get m => _data.elementAt(2);

  @override
  double? get optM => elev;

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
  factory LonLatElevM(double lon, double lat, double elev, double m) {
    // create a fixed list of 4 items
    final list = List<double>.filled(4, 0);
    list[0] = lon;
    list[1] = lat;
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

  /// A geographic position as an iterable collection parsed from [text].
  ///
  /// Coordinate values (lon, lat, elev, m) in [text] are separated by
  /// [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory LonLatElevM.fromText(
    String text, {
    Pattern? delimiter = ',',
  }) =>
      Position.createFromText(
        text,
        to: LonLatElevM.create,
        delimiter: delimiter,
        type: Coords.xyzm,
      );

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
  Coords get typeCoords => Coords.xyzm;

  @override
  double get m => _data.elementAt(3);

  @override
  double? get optM => m;

  @override
  String toString() => '$lon,$lat,$elev,$m';
}
