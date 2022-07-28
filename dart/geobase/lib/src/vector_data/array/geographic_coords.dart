// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'coordinates.dart';

/// A geographic position as an iterable collection of coordinate values.
///
/// Such position is a valid [Geographic] implementation and represents
/// coordinate values also as a collection of `Iterable<double>` (containing 2,
/// 3, or 4 items).
///
/// See [Geographic] for description about supported coordinate values.
///
/// See also specialized sub classes:
///
/// Class         | 2D/3D | Coords | Values   | lon (x) | lat (y) | elev (z) | m
/// ------------- | ----- | ------ | -------- | ------- | ------- | -------- | -
/// `LonLat`      | 2D    | 2      | `double` |    +    |    +    |          |
/// `LonLatElev`  | 3D    | 3      | `double` |    +    |    +    |    +     |
/// `LonLatM`     | 2D    | 3      | `double` |    +    |    +    |          | +
/// `LonLatElevM` | 3D    | 4      | `double` |    +    |    +    |    +     | +
class GeographicCoords extends PositionCoords implements Geographic {
  /// A geographic position with coordinate values as a view backed by `source`.
  ///
  /// An iterable collection of `source` may be represented by a [List] or any
  /// [Iterable] with efficient `length` and `elementAt` implementations.
  const GeographicCoords.view(super.source, {super.type = Coords.xy})
      : super._();

  /// A geographic position as an iterable collection of [x], [y], and optional
  /// [z] and [m] values.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  factory GeographicCoords.create({
    required num x,
    required num y,
    num? z,
    num? m,
  }) =>
      _doCreate(
        to: GeographicCoords.view,
        x: x,
        y: y,
        z: z,
        m: m,
      );

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
  /// Throws FormatException if coordinates are invalid.
  factory GeographicCoords.fromText(
    String text, {
    Pattern? delimiter = ',',
    Coords? type,
  }) =>
      _doCreateFromText(
        text,
        to: GeographicCoords.view,
        delimiter: delimiter,
        type: type,
      );

  @override
  double get x => lon;

  @override
  double get y => lat;

  @override
  double get z => elev;

  @override
  double? get optZ => optElev;

  @override
  double get lon => _data.elementAt(0);

  @override
  double get lat => _data.elementAt(1);

  @override
  double get elev => is3D ? _data.elementAt(2) : 0.0;

  @override
  double? get optElev => is3D ? _data.elementAt(2) : null;

  @override
  Iterable<double> get values => _data;

  @override
  GeographicCoords copyWith({num? x, num? y, num? z, num? m}) => _doCopyWith(
        from: this,
        to: GeographicCoords.view,
        x: x,
        y: y,
        z: z,
        m: m,
      );

  @override
  GeographicCoords transform(TransformPosition transform) =>
      transform.call(this);

  @override
  bool operator ==(Object other) =>
      other is Geographic && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);
}
