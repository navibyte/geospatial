// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/projected/projected.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/format_validation.dart';
import '/src/utils/num.dart';
import '/src/vector_data/array/coordinates.dart';

import 'lonlat.dart';

/// A projected position as an iterable collection of x and y values.
///
/// Such position is a valid [Projected] implementation with the type
/// `Coords.xy` and represents coordinate values also as a collection of
/// `Iterable<double>` with exactly 2 items.
///
/// See [Projected] for description about supported coordinate values.
@Deprecated('Use Projected or ListCoordinateExtension instead.')
@immutable
class XY extends PositionCoords implements Projected {
  /// A projected position as an iterable collection of [x] and [y] values.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  factory XY(double x, double y) {
    // create a fixed list of 2 items
    final list = List<double>.filled(2, 0);
    list[0] = x;
    list[1] = y;
    return XY.view(list);
  }

  /// A projected position as an iterable collection of [x] and [y] values.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  factory XY.create({
    required num x,
    required num y,
    // ignore: avoid_unused_constructor_parameters
    num? z,
    // ignore: avoid_unused_constructor_parameters
    num? m,
  }) =>
      XY(
        x.toDouble(),
        y.toDouble(),
      );

  /// A projected position as an iterable collection of x and y values.
  ///
  /// The `source` collection must have exactly 2 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  const XY.view(super.source)
      : assert(source.length == 2, 'XY must have exactly 2 values'),
        super();

  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  const XY._(super.source) : super();

  /// Parses a projected position as an iterable collection from [text].
  ///
  /// Coordinate values (x, y) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  factory XY.parse(
    String text, {
    Pattern? delimiter = ',',
  }) {
    final coords =
        parseDoubleValues(text, delimiter: delimiter).toList(growable: false);
    if (coords.length != 2) {
      throw invalidCoordinates;
    }
    return XY.view(coords);
  }

  @override
  XY copyWith({num? x, num? y, num? z, num? m}) => XY(
        x?.toDouble() ?? this.x,
        y?.toDouble() ?? this.y,
      );

  @override
  LonLat project(Projection projection) =>
      projection.project(this, to: LonLat.create);

  @override
  XY transform(TransformPosition transform) => transform.call(this);

  @override
  Projected get asProjected => this;

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
  double get x => elementAt(0);

  @override
  double get y => elementAt(1);

  @override
  double get z => 0;

  @override
  double? get optZ => null;

  @override
  double get m => 0;

  @override
  double? get optM => null;

  @override
  Iterable<double> get values => this;

  @override
  String toString() => '$x,$y';

  @override
  bool operator ==(Object other) =>
      other is Position && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);
}

/// A projected position as an iterable collection of x, y and z values.
///
/// Such position is a valid [Projected] implementation with the type
/// `Coords.xyz` and represents coordinate values also as a collection of
/// `Iterable<double>` with exactly 3 items.
///
/// See [Projected] for description about supported coordinate values.
@Deprecated('Use Projected or ListCoordinateExtension instead.')
class XYZ extends XY {
  /// A projected position as an iterable collection of [x], [y] and [z] values.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  factory XYZ(double x, double y, double z) {
    // create a fixed list of 3 items
    final list = List<double>.filled(3, 0);
    list[0] = x;
    list[1] = y;
    list[2] = z;
    return XYZ.view(list);
  }

  /// A projected position as an iterable collection of [x], [y] and [z] values.
  ///
  /// The default value for [z] is `0.0`.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  // ignore: avoid_unused_constructor_parameters
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  factory XYZ.create({
    required num x,
    required num y,
    num? z,
    // ignore: avoid_unused_constructor_parameters
    num? m,
  }) =>
      XYZ(
        x.toDouble(),
        y.toDouble(),
        z?.toDouble() ?? 0.0,
      );

  /// A projected position as an iterable collection of x, y and z values.
  ///
  /// The `source` collection must have exactly 3 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  const XYZ.view(super.source)
      : assert(source.length == 3, 'XYZ must have exactly 3 values'),
        super._();

  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  const XYZ._(super.source) : super._();

  /// Parses a projected position as an iterable collection from [text].
  ///
  /// Coordinate values (x, y, z) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  factory XYZ.parse(
    String text, {
    Pattern? delimiter = ',',
  }) {
    final coords =
        parseDoubleValues(text, delimiter: delimiter).toList(growable: false);
    if (coords.length != 3) {
      throw invalidCoordinates;
    }
    return XYZ.view(coords);
  }

  @override
  XYZ copyWith({num? x, num? y, num? z, num? m}) => XYZ(
        x?.toDouble() ?? this.x,
        y?.toDouble() ?? this.y,
        z?.toDouble() ?? this.z,
      );

  @override
  LonLatElev project(Projection projection) =>
      projection.project(this, to: LonLatElev.create);

  @override
  XYZ transform(TransformPosition transform) => transform.call(this);

  @override
  int get spatialDimension => 3;

  @override
  int get coordinateDimension => 3;

  @override
  bool get is3D => true;

  @override
  Coords get type => Coords.xyz;

  @override
  double get z => elementAt(2);

  @override
  double? get optZ => z;

  @override
  String toString() => '$x,$y,$z';
}

/// A projected position as an iterable collection of x, y and m values.
///
/// Such position is a valid [Projected] implementation with the type
/// `Coords.xym` and represents coordinate values also as a collection of
/// `Iterable<double>` with exactly 3 items.
///
/// See [Projected] for description about supported coordinate values.
@Deprecated('Use Projected or ListCoordinateExtension instead.')
class XYM extends XY {
  /// A projected position as an iterable collection of [x], [y] and [m] values.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  factory XYM(double x, double y, double m) {
    // create a fixed list of 3 items
    final list = List<double>.filled(3, 0);
    list[0] = x;
    list[1] = y;
    list[2] = m;
    return XYM.view(list);
  }

  /// A projected position as an iterable collection of [x], [y] and [m] values.
  ///
  /// The default value for [m] is `0.0`.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  // ignore: avoid_unused_constructor_parameters
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  factory XYM.create({
    required num x,
    required num y,
    // ignore: avoid_unused_constructor_parameters
    num? z,
    num? m,
  }) =>
      XYM(
        x.toDouble(),
        y.toDouble(),
        m?.toDouble() ?? 0.0,
      );

  /// A projected position as an iterable collection of x, y and m values.
  ///
  /// The `source` collection must have exactly 3 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  const XYM.view(super.source)
      : assert(source.length == 3, 'XYM must have exactly 3 values'),
        super._();

  /// Parses a projected position as an iterable collection from [text].
  ///
  /// Coordinate values (x, y, m) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  factory XYM.parse(
    String text, {
    Pattern? delimiter = ',',
  }) {
    final coords =
        parseDoubleValues(text, delimiter: delimiter).toList(growable: false);
    if (coords.length != 3) {
      throw invalidCoordinates;
    }
    return XYM.view(coords);
  }

  @override
  XYM copyWith({num? x, num? y, num? z, num? m}) => XYM(
        x?.toDouble() ?? this.x,
        y?.toDouble() ?? this.y,
        m?.toDouble() ?? this.m,
      );

  @override
  LonLatM project(Projection projection) =>
      projection.project(this, to: LonLatM.create);

  @override
  XYM transform(TransformPosition transform) => transform.call(this);

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
  String toString() => '$x,$y,$m';
}

/// A projected position as an iterable collection of x, y, z and m values.
///
/// Such position is a valid [Projected] implementation with the type
/// `Coords.xyzm` and represents coordinate values also as a collection of
/// `Iterable<double>` with exactly 4 items.
///
/// See [Projected] for description about supported coordinate values.
@Deprecated('Use Projected or ListCoordinateExtension instead.')
class XYZM extends XYZ {
  /// A projected position as an iterable collection of [x], [y], [z] and [m]
  /// values.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  factory XYZM(double x, double y, double z, double m) {
    // create a fixed list of 4 items
    final list = List<double>.filled(4, 0);
    list[0] = x;
    list[1] = y;
    list[2] = z;
    list[3] = m;
    return XYZM.view(list);
  }

  /// A projected position as an iterable collection of [x], [y], [z] and [m]
  /// values.
  ///
  /// The default value for [z] and [m] is `0.0`.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  factory XYZM.create({required num x, required num y, num? z, num? m}) => XYZM(
        x.toDouble(),
        y.toDouble(),
        z?.toDouble() ?? 0.0,
        m?.toDouble() ?? 0.0,
      );

  /// A projected position as an iterable collection of x, y, z and m values.
  ///
  /// The `source` collection must have exactly 4 coordinate values and it may
  /// be represented by a [List] or any [Iterable] with efficient `length` and
  /// `elementAt` implementations.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  const XYZM.view(super.source)
      : assert(source.length == 4, 'XYZM must have exactly 4 values'),
        super._();

  /// Parses a projected position as an iterable collection from [text].
  ///
  /// Coordinate values (x, y, z, m) in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  @Deprecated('Use Projected or ListCoordinateExtension instead.')
  factory XYZM.parse(
    String text, {
    Pattern? delimiter = ',',
  }) {
    final coords =
        parseDoubleValues(text, delimiter: delimiter).toList(growable: false);
    if (coords.length != 4) {
      throw invalidCoordinates;
    }
    return XYZM.view(coords);
  }

  @override
  XYZM copyWith({num? x, num? y, num? z, num? m}) => XYZM(
        x?.toDouble() ?? this.x,
        y?.toDouble() ?? this.y,
        z?.toDouble() ?? this.z,
        m?.toDouble() ?? this.m,
      );

  @override
  LonLatElevM project(Projection projection) =>
      projection.project(this, to: LonLatElevM.create);

  @override
  XYZM transform(TransformPosition transform) => transform.call(this);

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
  String toString() => '$x,$y,$z,$m';
}
