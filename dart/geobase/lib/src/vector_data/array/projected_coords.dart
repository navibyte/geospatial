// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'coordinates.dart';

/// A projected position as an iterable collection of coordinate values.
///
/// Such position is a valid [Projected] implementation and represents
/// coordinate values also as a collection of `Iterable<double>` (containing 2,
/// 3, or 4 items).
///
/// See [Projected] for description about supported coordinate values.
///
/// See also specialized sub classes:
///
/// Class  | 2D/3D | Coords | Values   | x | y | z | m
/// ------ | ----- | ------ | -------- | - | - | - | -
/// `XY`   | 2D    | 2      | `double` | + | + |   |
/// `XYZ`  | 3D    | 3      | `double` | + | + | + |
/// `XYM`  | 2D    | 3      | `double` | + | + |   | +
/// `XYZM` | 3D    | 4      | `double` | + | + | + | +
class ProjectedCoords extends PositionCoords implements Projected {
  /// A projected position with coordinate values as a view backed by `source`.
  ///
  /// An iterable collection of `source` may be represented by a [List] or any
  /// [Iterable] with efficient `length` and `elementAt` implementations.
  const ProjectedCoords.view(super.source, {super.type = Coords.xy})
      : super._();

  /// A projected position as an iterable collection of [x], [y], and optional
  /// [z] and [m] values.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  factory ProjectedCoords.create({
    required num x,
    required num y,
    num? z,
    num? m,
  }) =>
      _doCreate(
        to: ProjectedCoords.view,
        x: x,
        y: y,
        z: z,
        m: m,
      );

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
  /// Throws FormatException if coordinates are invalid.
  factory ProjectedCoords.fromText(
    String text, {
    Pattern? delimiter = ',',
    Coords? type,
  }) =>
      _doCreateFromText(
        text,
        to: ProjectedCoords.view,
        delimiter: delimiter,
        type: type,
      );

  @override
  Iterable<double> get values => _data;

  @override
  ProjectedCoords copyWith({num? x, num? y, num? z, num? m}) => _doCopyWith(
        from: this,
        to: ProjectedCoords.view,
        x: x,
        y: y,
        z: z,
        m: m,
      );

  @override
  ProjectedCoords transform(TransformPosition transform) =>
      transform.call(this);

  @override
  bool operator ==(Object other) =>
      other is Projected && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);
}
