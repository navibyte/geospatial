// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'spatial.dart';

/// A function to parse coordinate values from [text].
///
/// Such values can be used to create for example point geometries.
///
/// Throws FormatException if cannot parse.
typedef ParseCoords = Iterable<num> Function(String text);

/// A function to parse coordinate values as integers from [text].
///
/// Such values can be used to create for example point geometries.
///
/// Throws FormatException if cannot parse.
typedef ParseCoordsInt = Iterable<int> Function(String text);

/// A function to parse a list of coordinate values from [text].
///
/// Such values can be used to create for example point series or linear
/// strings.
///
/// Throws FormatException if cannot parse.
typedef ParseCoordsList = Iterable<Iterable<num>> Function(String text);

/// A function to parse a list of a list of coordinate values from [text].
///
/// Such values can be used to create for example a list of rings (or closed
/// liner strings) for a polygon.
///
/// Throws FormatException if cannot parse.
typedef ParseCoordsListList = Iterable<Iterable<Iterable<num>>> Function(
  String text,
);

/// A function to parse a list of a list of a list of coordinates from [text].
///
/// Such values can be used to create for example a multi polygon with each
/// polygon containg a list of rings (or closed liner strings).
///
/// Throws FormatException if cannot parse.
typedef ParseCoordsListListList = Iterable<Iterable<Iterable<Iterable<num>>>>
    Function(String text);

/// An private interface with methods prodiving information about coordinates.
///
/// Known sub classes: [Point], [Bounds].
abstract class _Coordinates extends Positionable {
  const _Coordinates();

  /// Writes coordinate values to [buffer] separated by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  void writeValues(
    StringSink buffer, {
    String delimiter = ',',
    int? decimals,
  });

  /// A string representation of coordinate values separated by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  String valuesAsString({
    String delimiter = ',',
    int? decimals,
  });
}

/// An interface to create [Bounded] instances of the type [T].
abstract class CoordinateFactory<T extends Bounded> implements Measurable {
  /// Creates a new [Geometry] instance of a type compatible with this object.
  ///
  /// Values for a new geometry are given by [coords] containing `num` values
  /// (that is `double` or `int`). By default 0 is used as an offset and length
  /// of [coords] as length specifying values. If both [offset] and [length]
  /// parameters are given, then those are specifying a segment of values from
  /// [coords] to be used for setting values on a new geometry.
  T newFrom(Iterable<num> coords, {int? offset, int? length});

  /// Throw if [coords] do not have [atLeastLen] values.
  ///
  /// Use optional [offset] and [length] params to define a segment on [coords].
  static void checkCoords(
    int atLeastLen,
    Iterable<num> coords, {
    int? offset,
    int? length,
  }) {
    if ((offset == null && length != null) ||
        (offset != null && length == null)) {
      throw const FormatException(
        'Offset and length must be both null or non-null',
      );
    }
    final start = offset ?? 0;
    final len = length ?? coords.length;
    if (start < 0 ||
        start + atLeastLen - 1 >= coords.length ||
        atLeastLen > len) {
      throw const FormatException('Coords segment out of range');
    }
  }
}

/// An interface to create [Point] instances of the type [T].
abstract class PointFactory<T extends Point> extends CoordinateFactory<T> {
  /// Creates a new point instance of a type compatible with this object.
  ///
  /// Values for a new point are given by required [x] and [y] values, and
  /// optional [z] and [z] values as applicable or an implementing class.
  ///
  /// When [newWith] is implemented by the [Point] class itself or it's
  /// descentants then a returned instance must be of the type with same
  /// coordinate value members as this object has.
  T newWith({num x = 0.0, num y = 0.0, num? z, num? m});

  /// Creates a new point instance of a type compatible with this object.
  ///
  /// Values for a new point are given by [coords] containing `num` values
  /// (that is `double` or `int`). By default 0 is used as an offset and length
  /// of [coords] as length specifying values. If both [offset] and [length]
  /// parameters are given, then those are specifying a segment of values from
  /// [coords] to be used for setting values on a new point.
  ///
  /// When [newFrom] is implemented by the [Point] class itself or it's
  /// descentants then a returned instance must be of the type with same
  /// coordinate value members as this object has.
  @override
  T newFrom(Iterable<num> coords, {int? offset, int? length});
}

/// A [PointFactory] that casts points created by [_wrapped] to the type [T].
///
/// The [_wrapped] point factory MUST return instance castable to [T].
class CastingPointFactory<T extends Point> implements PointFactory<T> {
  /// Create a point factory wrapping a [_wrapped] point factory.
  const CastingPointFactory(this._wrapped);

  final PointFactory _wrapped;

  @override
  bool get isMeasured => _wrapped.isMeasured;

  @override
  T newFrom(Iterable<num> coords, {int? offset, int? length}) =>
      _wrapped.newFrom(coords, offset: offset, length: length) as T;

  @override
  T newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      _wrapped.newWith(x: x, y: y, z: z, m: m) as T;
}
