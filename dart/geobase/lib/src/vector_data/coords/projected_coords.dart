// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base.dart';
import '/src/coordinates/projected.dart';

import 'position_coords.dart';

/// A projected position as an iterable collection of coordinate values.
///
/// Such position is a valid [Projected] implementation and represents
/// coordinate values also as a collection of `Iterable<num>` (containing 2, 3,
/// or 4 items).
/// 
/// This abstract class has four sub classes with different sets of coordinate
/// values available:
///
/// Class  | 2D/3D | Coords | Type  | x | y | z | m 
/// ------ | ----- | ------ | ----- | - | - | - | -
/// [XY]   | 2D    | 2      | `num` | + | + |   |  
/// [XYZ]  | 3D    | 3      | `num` | + | + | + |  
/// [XYM]  | 2D    | 3      | `num` | + | + |   | +
/// [XYZM] | 3D    | 4      | `num` | + | + | + | +
///
/// See [Projected] for description about supported coordinate values.
@immutable
abstract class ProjectedCoords extends PositionCoords<num>
    implements Projected {
  const ProjectedCoords._(Iterable<num> source) : _data = source;

  /// A projected position as an iterable collection of [x], [y], and optional
  /// [z] and [m] values.
  ///
  /// Returns an instance of [XY], [XYZ], [XYM] or [XYZM].
  ///
  /// This factory is compatible with `CreatePosition` function type.
  factory ProjectedCoords.create({
    required num x,
    required num y,
    num? z,
    num? m,
  }) {
    if (z != null) {
      // 3D coordinates
      if (m != null) {
        // 3D and measured coordinates
        return XYZM.create(x: x, y: y, z: z, m: m);
      } else {
        return XYZ.create(x: x, y: y, z: z);
      }
    } else {
      // 2D coordinates
      if (m != null) {
        // 2D and measured coordinates
        return XYM.create(x: x, y: y, m: m);
      } else {
        return XY.create(x: x, y: y);
      }
    }
  }

  /// A projected position with coordinate values as a view backed by [source].
  ///
  /// Returns an instance of [XY], [XYZ], [XYM] or [XYZM]. When [type] is given,
  /// then it's used to select the appropriate class. Otherwise the coordinate
  /// dimension of [source] values resolves the class (2 => XY, 3 => XYZ,
  /// 4 => XYZM).
  ///
  /// An iterable collection of [source] may be represented by a [List] or any
  /// [Iterable] with efficient `length` and `elementAt` implementations.
  ///
  /// Throws FormatException is the coordinate dimension of [source] is not 2,
  /// 3 or 4.
  factory ProjectedCoords.view(Iterable<num> source, {Coords? type}) {
    switch (type ?? Coords.fromDimension(source.length)) {
      case Coords.xy:
        return XY.view(source);
      case Coords.xyz:
        return XYZ.view(source);
      case Coords.xym:
        return XYM.view(source);
      case Coords.xyzm:
        return XYZM.view(source);
    }
  }

  /// A projected position with coordinate values copied from [source].
  ///
  /// Returns an instance of [XY], [XYZ], [XYM] or [XYZM]. When [type] is given,
  /// then it's used to select the appropriate class. Otherwise the coordinate
  /// dimension of [source] values resolves the class (2 => XY, 3 => XYZ,
  /// 4 => XYZM).
  ///
  /// Throws FormatException is the coordinate dimension of [source] is not 2,
  /// 3 or 4.
  factory ProjectedCoords.fromCoords(Iterable<num> source, {Coords? type}) {
    // create a projected position with copied list as data
    return ProjectedCoords.view(source.toList(growable: false), type: type);
  }

  /// A projected position as an iterable collection parsed from [text].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// Supported coordinate value combinations for [text] are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [text] has 3 items, then xyz coordinates are assumed.
  ///
  /// Returns an instance of [XY], [XYZ], [XYM] or [XYZM].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory ProjectedCoords.fromText(
    String text, {
    Pattern? delimiter = ',',
    Coords? type,
  }) =>
      Position.createFromText(
        text,
        to: ProjectedCoords.create,
        delimiter: delimiter,
        type: type,
      );

  final Iterable<num> _data;

  /// Coordinate values of this position as an iterable of 2, 3 or 4 items.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  @override
  Iterable<num> get values => _data;

  @override
  num operator [](int index) => elementAt(index);

  @override
  bool get isGeographic => false;

  @override
  bool operator ==(Object other) =>
      other is Projected && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);

  // .......... Iterable<num> implementation below

  @override
  num elementAt(int index) =>
      index >= 0 && index < coordinateDimension ? _data.elementAt(index) : 0.0;

  @override
  int get length => coordinateDimension;

  @override
  bool get isEmpty => false;

  @override
  bool get isNotEmpty => true;

  @override
  num get single => throw StateError('Position has at least 2 items');

  @override
  Iterator<num> get iterator => _data.iterator;

  @override
  bool any(bool Function(num element) test) => _data.any(test);

  @override
  Iterable<R> cast<R>() => _data.cast<R>();

  @override
  bool contains(Object? element) => _data.contains(element);

  @override
  bool every(bool Function(num element) test) => _data.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(num element) toElements) =>
      _data.expand<T>(toElements);

  @override
  num get first => _data.first;

  @override
  num firstWhere(bool Function(num element) test, {num Function()? orElse}) =>
      _data.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, num element) combine) =>
      _data.fold<T>(initialValue, combine);

  @override
  Iterable<num> followedBy(Iterable<num> other) => _data.followedBy(other);

  @override
  void forEach(void Function(num element) action) => _data.forEach(action);

  @override
  String join([String separator = '']) => _data.join(separator);

  @override
  num get last => _data.last;

  @override
  num lastWhere(bool Function(num element) test, {num Function()? orElse}) =>
      _data.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(num e) toElement) => _data.map<T>(toElement);

  @override
  num reduce(num Function(num value, num element) combine) =>
      _data.reduce(combine);

  @override
  num singleWhere(bool Function(num element) test, {num Function()? orElse}) =>
      _data.singleWhere(test, orElse: orElse);

  @override
  Iterable<num> skip(int count) => _data.skip(count);

  @override
  Iterable<num> skipWhile(bool Function(num value) test) =>
      _data.skipWhile(test);

  @override
  Iterable<num> take(int count) => _data.take(count);

  @override
  Iterable<num> takeWhile(bool Function(num value) test) =>
      _data.takeWhile(test);

  @override
  List<num> toList({bool growable = true}) => _data.toList(growable: growable);

  @override
  Set<num> toSet() => _data.toSet();

  @override
  Iterable<num> where(bool Function(num element) test) => _data.where(test);

  @override
  Iterable<T> whereType<T>() => _data.whereType();
}

/// A projected position as an iterable collection of x and y values.
///
/// Such position is a valid [Projected] implementation with the type
/// `Coords.xy` and represents coordinate values also as a collection of
/// `Iterable<num>` with exactly 2 items.
///
/// See [Projected] for description about supported coordinate values.
class XY extends ProjectedCoords {
  /// A projected position as an iterable collection of [x] and [y] values.
  factory XY(num x, num y) {
    // create a fixed list of 2 items
    final list = List<num>.filled(2, 0);
    list[0] = x;
    list[1] = y;
    return XY.view(list);
  }

  /// A projected position as an iterable collection of [x] and [y] values.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  // ignore: avoid_unused_constructor_parameters
  factory XY.create({required num x, required num y, num? z, num? m}) =>
      XY(x, y);

  /// A projected position as an iterable collection of x and y values.
  ///
  /// The `source` collection must have exactly 2 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  const XY.view(super.source)
      : assert(source.length == 2, 'XY must have exactly 2 values'),
        super._();

  const XY._(super.source) : super._();

  /// A projected position as an iterable collection parsed from [text].
  ///
  /// Coordinate values (x, y) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory XY.fromText(
    String text, {
    Pattern? delimiter = ',',
  }) =>
      Position.createFromText(
        text,
        to: XY.create,
        delimiter: delimiter,
        type: Coords.xy,
      );

  @override
  XY copyWith({num? x, num? y, num? z, num? m}) => XY(
        x ?? this.x,
        y ?? this.y,
      );

  @override
  XY transform(TransformPosition transform) => transform.call(this);

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
  num get x => _data.elementAt(0);

  @override
  num get y => _data.elementAt(1);

  @override
  num get z => 0;

  @override
  num? get optZ => null;

  @override
  num get m => 0;

  @override
  num? get optM => null;

  @override
  String toString() => '$x,$y';
}

/// A projected position as an iterable collection of x, y and z values.
///
/// Such position is a valid [Projected] implementation with the type
/// `Coords.xyz` and represents coordinate values also as a collection of
/// `Iterable<num>` with exactly 3 items.
///
/// See [Projected] for description about supported coordinate values.
class XYZ extends XY {
  /// A projected position as an iterable collection of [x], [y] and [z] values.
  factory XYZ(num x, num y, num z) {
    // create a fixed list of 3 items
    final list = List<num>.filled(3, 0);
    list[0] = x;
    list[1] = y;
    list[2] = z;
    return XYZ.view(list);
  }

  /// A projected position as an iterable collection of [x], [y] and [z] values.
  ///
  /// The default value for [z] is `0`.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  // ignore: avoid_unused_constructor_parameters
  factory XYZ.create({required num x, required num y, num? z, num? m}) =>
      XYZ(x, y, z ?? 0);

  /// A projected position as an iterable collection of x, y and z values.
  ///
  /// The `source` collection must have exactly 3 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  const XYZ.view(super.source)
      : assert(source.length == 3, 'XYZ must have exactly 3 values'),
        super._();

  const XYZ._(super.source) : super._();

  /// A projected position as an iterable collection parsed from [text].
  ///
  /// Coordinate values (x, y, z) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory XYZ.fromText(
    String text, {
    Pattern? delimiter = ',',
  }) =>
      Position.createFromText(
        text,
        to: XYZ.create,
        delimiter: delimiter,
        type: Coords.xyz,
      );

  @override
  XYZ copyWith({num? x, num? y, num? z, num? m}) => XYZ(
        x ?? this.x,
        y ?? this.y,
        z ?? this.z,
      );

  @override
  XYZ transform(TransformPosition transform) => transform.call(this);

  @override
  int get spatialDimension => 3;

  @override
  int get coordinateDimension => 3;

  @override
  bool get is3D => true;

  @override
  Coords get typeCoords => Coords.xyz;

  @override
  num get z => _data.elementAt(2);

  @override
  num? get optZ => z;

  @override
  String toString() => '$x,$y,$z';
}

/// A projected position as an iterable collection of x, y and m values.
///
/// Such position is a valid [Projected] implementation with the type
/// `Coords.xym` and represents coordinate values also as a collection of
/// `Iterable<num>` with exactly 3 items.
///
/// See [Projected] for description about supported coordinate values.
class XYM extends XY {
  /// A projected position as an iterable collection of [x], [y] and [m] values.
  factory XYM(num x, num y, num m) {
    // create a fixed list of 3 items
    final list = List<num>.filled(3, 0);
    list[0] = x;
    list[1] = y;
    list[2] = m;
    return XYM.view(list);
  }

  /// A projected position as an iterable collection of [x], [y] and [m] values.
  ///
  /// The default value for [m] is `0`.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  // ignore: avoid_unused_constructor_parameters
  factory XYM.create({required num x, required num y, num? z, num? m}) =>
      XYM(x, y, m ?? 0);

  /// A projected position as an iterable collection of x, y and m values.
  ///
  /// The `source` collection must have exactly 3 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  const XYM.view(super.source)
      : assert(source.length == 3, 'XYM must have exactly 3 values'),
        super._();

  /// A projected position as an iterable collection parsed from [text].
  ///
  /// Coordinate values (x, y, m) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory XYM.fromText(
    String text, {
    Pattern? delimiter = ',',
  }) =>
      Position.createFromText(
        text,
        to: XYM.create,
        delimiter: delimiter,
        type: Coords.xym,
      );

  @override
  XYM copyWith({num? x, num? y, num? z, num? m}) => XYM(
        x ?? this.x,
        y ?? this.y,
        m ?? this.m,
      );

  @override
  XYM transform(TransformPosition transform) => transform.call(this);

  @override
  int get coordinateDimension => 3;

  @override
  bool get isMeasured => true;

  @override
  Coords get typeCoords => Coords.xym;

  @override
  num get m => _data.elementAt(2);

  @override
  num? get optM => m;

  @override
  String toString() => '$x,$y,$m';
}

/// A projected position as an iterable collection of x, y, z and m values.
///
/// Such position is a valid [Projected] implementation with the type
/// `Coords.xyzm` and represents coordinate values also as a collection of
/// `Iterable<num>` with exactly 4 items.
///
/// See [Projected] for description about supported coordinate values.
class XYZM extends XYZ {
  /// A projected position as an iterable collection of [x], [y], [z] and [m]
  /// values.
  factory XYZM(num x, num y, num z, num m) {
    // create a fixed list of 4 items
    final list = List<num>.filled(4, 0);
    list[0] = x;
    list[1] = y;
    list[2] = z;
    list[3] = m;
    return XYZM.view(list);
  }

  /// A projected position as an iterable collection of [x], [y], [z] and [m]
  /// values.
  ///
  /// The default value for [z] and [m] is `0`.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  factory XYZM.create({required num x, required num y, num? z, num? m}) =>
      XYZM(x, y, z ?? 0, m ?? 0);

  /// A projected position as an iterable collection of x, y, z and m values.
  ///
  /// The `source` collection must have exactly 4 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  const XYZM.view(super.source)
      : assert(source.length == 4, 'XYZM must have exactly 4 values'),
        super._();

  /// A projected position as an iterable collection parsed from [text].
  ///
  /// Coordinate values (x, y, z, m) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory XYZM.fromText(
    String text, {
    Pattern? delimiter = ',',
  }) =>
      Position.createFromText(
        text,
        to: XYZM.create,
        delimiter: delimiter,
        type: Coords.xyzm,
      );

  @override
  XYZM copyWith({num? x, num? y, num? z, num? m}) => XYZM(
        x ?? this.x,
        y ?? this.y,
        z ?? this.z,
        m ?? this.m,
      );

  @override
  XYZM transform(TransformPosition transform) => transform.call(this);

  @override
  int get coordinateDimension => 4;

  @override
  bool get isMeasured => true;

  @override
  Coords get typeCoords => Coords.xyzm;

  @override
  num get m => _data.elementAt(3);

  @override
  num? get optM => m;

  @override
  String toString() => '$x,$y,$z,$m';
}
