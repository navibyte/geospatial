// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// An private interface with members telling whethen an object is measureable.
///
/// Known (public) sub classes: [Point], [PointFactory], [Bounds],
/// [BoundsFactory].
abstract class _Measured {
  const _Measured();

  /// True for points containing (or expecting) M coordinate.
  bool get hasM;
}

/// An private interface with methods prodiving information about coordinates.
///
/// Known sub classes: [Point], [Bounds].
abstract class _Coordinates extends _Measured {
  const _Coordinates();

  /// The number of coordinate values (2, 3 or 4).
  ///
  /// If value is 2, points have 2D coordinates without m coordinate.
  ///
  /// If value is 3, points have 2D coordinates with m coordinate or
  /// 3D coordinates without m coordinate.
  ///
  /// If value is 4, points have 3D coordinates with m coordinate.
  ///
  /// Must be >= [spatialDimension].
  int get coordinateDimension;

  /// The number of spatial coordinate values (2 for 2D or 3 for 3D).
  int get spatialDimension;

  /// True for 3D points (that is having Z coordinate).
  bool get is3D;

  /// Writes coordinate values to [buffer] delimited by [delimiter].
  void writeValues(StringSink buffer, {String delimiter = ','});

  /// Returns coordinate values as a string delimimited by [delimiter].
  String valuesAsString({String delimiter = ','});
}

/// An interface to create [Geometry] instances of the type [T].
abstract class CoordinateFactory<T extends Geometry> implements _Measured {
  /// Creates a new [Geometry] instance of a type compatible with this object.
  ///
  /// Values for a new geometry are given by [coords] containing `num` values
  /// (that is `double` or `int`). By default 0 is used as an offset and length
  /// of [coords] as length specifying values. If both [offset] and [length]
  /// parameters are given, then those are specifying a segment of values from
  /// [coords] to be used for setting values on a new geometry.
  T newFrom(Iterable<num> coords, {int? offset, int? length});

  static void checkCoords(int atLeastLen, Iterable<num> coords,
      {int? offset, int? length}) {
    if ((offset == null && length != null) ||
        (offset != null && length == null)) {
      throw ArgumentError('Offset and length must be both null or non-null');
    }
    final start = offset ?? 0;
    final len = length ?? coords.length;
    if (start < 0 ||
        start + atLeastLen - 1 >= coords.length ||
        atLeastLen > len) {
      throw RangeError('Coords segment out of range');
    }
  }
}

/// An interface to create [Point] instances of the type [T].
abstract class PointFactory<T extends Point> extends CoordinateFactory<T> {
  /// Creates a new [Point] instance of a type compatible with this object.
  ///
  /// Values for a new point are given by required [x] and [y] values, and
  /// optional [z] and [z] values as applicable or an implementing class.
  ///
  /// When [newWith] is implemented by the [Point] class itself or it's
  /// descentants then a returned instance must be of the type with same
  /// coordinate value members as this.
  T newWith({num x = 0.0, num y = 0.0, num? z, num? m});

  /// Creates a new [Point] instance of a type compatible with this object.
  ///
  /// Values for a new point are given by [coords] containing `num` values
  /// (that is `double` or `int`). By default 0 is used as an offset and length
  /// of [coords] as length specifying values. If both [offset] and [length]
  /// parameters are given, then those are specifying a segment of values from
  /// [coords] to be used for setting values on a new point.
  ///
  /// When [newFrom] is implemented by the [Point] class itself or it's
  /// descentants then a returned instance must be of the type with same
  /// coordinate value members as this.
  @override
  T newFrom(Iterable<num> coords, {int? offset, int? length});
}
