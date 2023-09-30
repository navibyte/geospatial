// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/coord_positions.dart';
import '/src/utils/format_validation.dart';
import '/src/utils/tolerance.dart';

import 'position.dart';
import 'position_extensions.dart';
import 'positionable.dart';

/// A fixed-length (and random-access) view to a series of positions.
///
/// Implementations of this abstract class can use at least two different
/// structures to store coordinate values of positions contained in a series:
/// * A list of [Position] objects (each object contain x and y coordinates, and
///   optionally z and m too).
/// * A list of [double] values as a flat structure. For example a double list
///   could contain coordinates like `[x0, y0, z0, x1, y1, z1, x2, y2, z2]`
///   that represents three positions each with x, y and z coordinates.
///
/// It's also possible to create a position data instance using factory methods
/// [PositionSeries.view] and [PositionSeries.parse] that create an instance
/// storing coordinate values of positions in a double array. The factory
/// [PositionSeries.from] creates an instance storing positions objects in an
/// array. The factory [PositionSeries.empty] returns an empty series.
///
/// See [Position] for description about supported coordinate values.
///
/// For [PositionSeries] and sub classes equality by `operator ==` and
/// `hashCode` is not testing coordinate values for contained positions. Methods
/// [equalsCoords], [equals2D] and [equals3D] should be used to test coordinate
/// values between two [PositionSeries] instances.
abstract class PositionSeries implements Positionable {
  /// Default `const` constructor to allow extending this abstract class.
  const PositionSeries();

  static final _empty = PositionSeries.view(const []);

  /// An empty series of positions without any positions.
  factory PositionSeries.empty() => _empty;

  /// A series of positions as a view backed by [source] containing coordinate
  /// values of positions.
  ///
  /// The [source] collection contains coordinate values of positions as a flat
  /// structure. For example for `Coords.xyz` the first three coordinate values
  /// are x, y and z of the first position, the next three coordinate values are
  /// x, y and z of the second position, and so on.
  ///
  /// The `type.coordinateDimension` (either 2, 3 or 4) property defines the
  /// number of coordinate values for each position. The number of positions
  /// contained by the view is calculated as
  /// `source.length ~/ type.coordinateDimension`. If there are zero values or
  /// less coordinate values than `type.coordinateDimension`, then the view is
  /// considered empty.
  ///
  /// See [Position] for description about supported coordinate values.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a series of 2D positions (with values of the `Coords.xy` type)
  /// PositionSeries.view(
  ///   [
  ///     10.0, 20.0, // (x, y) for position 0
  ///     12.5, 22.5, // (x, y) for position 1
  ///     15.0, 25.0, // (x, y) for position 2
  ///   ],
  ///   type: Coords.xy,
  /// );
  ///
  /// // a series of 3D positions (with values of the `Coords.xyz` type)
  /// PositionSeries.view(
  ///   [
  ///     10.0, 20.0, 30.0, // (x, y, z) for position 0
  ///     12.5, 22.5, 32.5, // (x, y, z) for position 1
  ///     15.0, 25.0, 35.0, // (x, y, z) for position 2
  ///   ],
  ///   type: Coords.xyz,
  /// );
  ///
  /// // a series of measured 2D positions (values of the `Coords.xym` type)
  /// PositionSeries.view(
  ///   [
  ///     10.0, 20.0, 40.0, // (x, y, m) for position 0
  ///     12.5, 22.5, 42.5, // (x, y, m) for position 1
  ///     15.0, 25.0, 45.0, // (x, y, m) for position 2
  ///   ],
  ///   type: Coords.xym,
  /// );
  ///
  /// // a series of measured 3D positions (values of the `Coords.xyzm` type)
  /// PositionSeries.view(
  ///   [
  ///     10.0, 20.0, 30.0, 40.0, // (x, y, z, m) for position 0
  ///     12.5, 22.5, 32.5, 42.5, // (x, y, z, m) for position 1
  ///     15.0, 25.0, 35.0, 45.0, // (x, y, z, m) for position 2
  ///   ],
  ///   type: Coords.xyzm,
  /// );
  /// ```
  factory PositionSeries.view(
    List<double> source, {
    Coords type = Coords.xy,
  }) {
    // ensure source array size is correct according to coordinate type
    final valueCount = source.length;
    final positionCount = valueCount ~/ type.coordinateDimension;
    if (valueCount != positionCount * type.coordinateDimension) {
      throw invalidCoordinates;
    }

    return _PositionDataCoords.view(source, type: type);
  }

  /// A series of positions as a view backed by [source] containing [Position]
  /// objects.
  ///
  /// If given [type] is null then the coordinate type of [source] positions is
  /// resolved from those positions (a type returned is such that it's valid
  /// for all positions).
  ///
  /// If [source] is `List<Position>` then it's used directly as a source for a
  /// new `PositionSeries` object. If [source] is `Iterable<Position>` then
  /// items are iterated and copied to a list that is used as a source.
  ///
  /// See [Position] for description about supported coordinate values.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a series of 2D positions
  /// PositionSeries.from(
  ///   [
  ///     Position.create(x: 10.0, y: 20.0),
  ///     Position.create(x: 12.5, y: 22.5),
  ///     Position.create(x: 15.0, y: 25.0),
  ///   ],
  ///   type: Coords.xy,
  /// );
  ///
  /// // a series of 3D positions
  /// PositionSeries.from(
  ///   [
  ///     Position.create(x: 10.0, y: 20.0, z: 30.0),
  ///     Position.create(x: 12.5, y: 22.5, z: 32.5),
  ///     Position.create(x: 15.0, y: 25.0, z: 35.0),
  ///   ],
  ///   type: Coords.xyz,
  /// );
  ///
  /// // a series of measured 2D positions
  /// PositionSeries.from(
  ///   [
  ///     Position.create(x: 10.0, y: 20.0, m: 40.0),
  ///     Position.create(x: 12.5, y: 22.5, m: 42.5),
  ///     Position.create(x: 15.0, y: 25.0, m: 45.0),
  ///   ],
  ///   type: Coords.xym,
  /// ),
  ///
  /// // a series of measured 3D positions
  /// PositionSeries.from(
  ///   [
  ///     Position.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
  ///     Position.create(x: 12.5, y: 22.5, z: 32.5, m: 42.5),
  ///     Position.create(x: 15.0, y: 25.0, z: 35.0, m: 45.0),
  ///   ],
  ///   type: Coords.xyzm,
  /// );
  /// ```
  factory PositionSeries.from(Iterable<Position> source, {Coords? type}) {
    // ensure a list data structure
    final data =
        source is List<Position> ? source : source.toList(growable: false);

    if (type != null) {
      return _PositionArray.view(data, type: type);
    } else {
      var is3D = true;
      var isMeasured = true;

      for (final elem in data) {
        final type = elem.type;
        is3D &= type.is3D;
        isMeasured &= type.isMeasured;
        if (!is3D && !isMeasured) break;
      }

      return _PositionArray.view(
        data,
        type: Coords.select(is3D: is3D, isMeasured: isMeasured),
      );
    }
  }

  /// Parses a series of positions from [text] containing coordinate values of
  /// positions.
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// Use the required optional [type] to explicitely set the coordinate type.
  ///
  /// If [swapXY] is true, then swaps x and y for all positions in the result.
  ///
  /// If [singlePrecision] is true, then coordinate values of positions are
  /// stored in `Float32List` instead of the `Float64List` (default).
  ///
  /// See [Position] for description about supported coordinate values.
  ///
  /// Throws FormatException if coordinates are invalid.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a series of 2D positions (with values of the `Coords.xy` type)
  /// PositionSeries.parse(
  ///   // values for three (x, y) positions
  ///   '10.0,20.0,12.5,22.5,15.0,25.0',
  ///   type: Coords.xy,
  /// );
  ///
  /// // a series of 3D positions (with values of the `Coords.xyz` type)
  /// PositionSeries.parse(
  ///   // values for three (x, y, z) positions
  ///   '10.0,20.0,30.0,12.5,22.5,32.5,15.0,25.0,35.0',
  ///   type: Coords.xyz,
  /// );
  ///
  /// // a series of measured 2D positions (values of the `Coords.xym` type)
  /// PositionSeries.parse(
  ///   // values for three (x, y, m) positions
  ///   '10.0,20.0,40.0,12.5,22.5,42.5,15.0,25.0,45.0',
  ///   type: Coords.xym,
  /// ):
  ///
  /// // a series of measured 3D positions (values of the `Coords.xyzm` type)
  /// PositionSeries.parse(
  ///   // values for three (x, y, z, m) positions
  ///   '10.0,20.0,30.0,40.0,12.5,22.5,32.5,42.5,15.0,25.0,35.0,45.0',
  ///   type: Coords.xyzm,
  /// );
  ///
  /// // a series of 2D positions (with values of the `Coords.xy` type) using
  /// // an alternative delimiter
  /// PositionSeries.parse(
  ///   // values for three (x, y) positions
  ///   '10.0;20.0;12.5;22.5;15.0;25.0',
  ///   type: Coords.xy,
  ///   delimiter: ';',
  /// );
  ///
  /// // a series of 2D positions (with values of the `Coords.xy` type) with x
  /// // before y
  /// PositionSeries.parse(
  ///   // values for three (x, y) positions
  ///   '20.0,10.0,22.5,12.5,25.0,15.0',
  ///   type: Coords.xy,
  ///   swapXY: true,
  /// );
  ///
  /// // a series of 2D positions (with values of the `Coords.xy` type) with the
  /// // internal storage using single precision floating point numbers
  /// // (`Float32List` in this case)
  /// PositionSeries.parse(
  ///   // values for three (x, y) positions
  ///   '10.0,20.0,12.5,22.5,15.0,25.0',
  ///   type: Coords.xy,
  ///   singlePrecision: true,
  /// );
  /// ```
  factory PositionSeries.parse(
    String text, {
    Pattern delimiter = ',',
    Coords type = Coords.xy,
    bool swapXY = false,
    bool singlePrecision = false,
  }) =>
      parsePositionSeriesFromTextDim1(
        text,
        delimiter: delimiter,
        type: type,
        swapXY: swapXY,
        singlePrecision: singlePrecision,
      );

  /// The number of positions in this series.
  int get positionCount;

  /// Returns true if this series has no positions.
  bool get isEmpty => positionCount == 0;

  /// Returns true if this series has at least one position.
  bool get isNotEmpty => positionCount > 0;

  /// All positions in this series as an iterable.
  ///
  /// See also [positionsAs] that allow typing position object as subtypes of
  /// [Position].
  Iterable<Position> get positions;

  /// All positions in this series as an iterable of positions typed as [R]
  /// using [to] factory.
  ///
  /// See also [positions] that always returns position objects as [Position].
  Iterable<R> positionsAs<R extends Position>({
    required CreatePosition<R> to,
  });

  /// The position at the given index.
  ///
  /// The index must be a valid index in this series; `0 <= index < length`.
  ///
  /// See also [get] that allow typing the position object as subtypes of
  /// [Position].
  Position operator [](int index);

  /// The position at the given index as an object of [R] using [to] factory.
  ///
  /// The index must be a valid index in this series; `0 <= index < length`.
  ///
  /// Examples when `series` is an instance of [PositionSeries]:
  ///
  /// ```dart
  /// // get a position at index 3 as a `Projected` position
  /// series.get(3, to: Projected.create);
  ///
  /// // get a position at index 3 as a `Geographic` position
  /// series.get(3, to: Geographic.create);
  /// ```
  R get<R extends Position>(
    int index, {
    required CreatePosition<R> to,
  });

  /// The first position or null (if empty collection).
  Position? get firstOrNull => positionCount > 0 ? this[0] : null;

  /// The last position or null (if empty collection).
  Position? get lastOrNull {
    final posCount = positionCount;
    return posCount > 0 ? this[posCount - 1] : null;
  }

  /// The `x` coordinate of the position at the given index.
  ///
  /// For geographic coordinates x represents *longitude*.
  ///
  /// The index must be a valid index in this series; `0 <= index < length`.
  double x(int index);

  /// The `y` coordinate of the position at the given index.
  ///
  /// For geographic coordinates y represents *latitude*.
  ///
  /// The index must be a valid index in this series; `0 <= index < length`.
  double y(int index);

  /// The `z` coordinate of the position at the given index.
  ///
  /// Returns zero if z is not available for a valid index. You can also use
  /// [optZ] that returns z coordinate as a nullable value.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  ///
  /// The index must be a valid index in this series; `0 <= index < length`.
  double z(int index);

  /// The `z` coordinate of the position at the given index.
  ///
  /// Returns null if z is not available for a valid index.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  ///
  /// The index must be a valid index in this series; `0 <= index < length`.
  double? optZ(int index);

  /// The `m` coordinate of the position at the given index.
  ///
  /// Returns zero if m is not available for a valid index. You can also use
  /// [optM] that returns m coordinate as a nullable value.
  ///
  /// `m` represents a measurement or a value on a linear referencing system
  /// (like time).
  ///
  /// The index must be a valid index in this series; `0 <= index < length`.
  double m(int index);

  /// The `m` coordinate of the position at the given index.
  ///
  /// Returns null if m is not available for a valid index.
  ///
  /// `m` represents a measurement or a value on a linear referencing system
  /// (like time).
  ///
  /// The index must be a valid index in this series; `0 <= index < length`.
  double? optM(int index);

  /// Coordinate values of all positions in this series as an iterable.
  ///
  /// Each position contains 2, 3 or 4 coordinate values indicated by [type] of
  /// this series.
  ///
  /// For example if data contains positions (x: 1.0, y: 1.1), (x: 2.0, y: 2.1),
  /// and (x: 3.0, y: 3.1), then a returned iterable would be
  /// `[1.0, 1.1, 2.0, 2.1, 3.0, 3.1]`.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, z), (x, y, m) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, elev), (lon, lat, m) or (lon, lat, elev, m).
  ///
  /// See also [valuesByType] that returns coordinate values of all positions
  /// according to a given coordinate type.
  Iterable<double> get values;

  /// Coordinate values of all positions in this series as an iterable.
  ///
  /// Each position contains 2, 3 or 4 coordinate values indicated by given
  /// [type].
  ///
  /// See [values] (that returns coordinate values according to the coordinate
  /// type of this bounding box) for description of possible return values.
  Iterable<double> valuesByType(Coords type);

  /// Copies this series of positions as another series with positions mapped by
  /// the given coordinate [type].
  PositionSeries copyByType(Coords type);

  /// Returns a position series with all positions in reversed order compared to
  /// this.
  PositionSeries reversed();

  /// Returns a sub series with positions from [start] (inclusive) to [end]
  /// (exclusive).
  ///
  /// If [end] is not provided, then all positions from [start] to end are
  /// returned.
  ///
  /// A returned series may point to the same position data as this (however
  /// implementations are allowed to make a copy of positions in the range).
  ///
  /// Valid queries are such that 0 ≤ start ≤ end ≤ [positionCount].
  PositionSeries subseries(int start, [int? end]) {
    final subEnd = end ?? positionCount;
    return start == 0 && subEnd == positionCount
        ? this
        : PositionSeries.from(
            positions.skip(start).take(subEnd - start).toList(growable: false),
          );
  }

  /// Projects this series of positions to another series using [projection].
  PositionSeries project(Projection projection);

  /// Returns a position series with all points transformed using [transform].
  ///
  /// The returned object should be of the same type as this object has.
  PositionSeries transform(TransformPosition transform);

  /// True if the first and last position equals in 2D.
  bool get isClosed {
    final posCount = positionCount;
    if (posCount >= 2) {
      return this[0].equals2D(this[posCount - 1]);
    }
    return false;
  }

  /// True if the first and last position equals in 2D within [toleranceHoriz].
  bool isClosedBy([double toleranceHoriz = defaultEpsilon]) {
    final posCount = positionCount;
    if (posCount >= 2) {
      return this[0].equals2D(
        this[posCount - 1],
        toleranceHoriz: toleranceHoriz,
      );
    }
    return false;
  }

  /// Returns true if this and [other] contain exactly same coordinate values
  /// (or both are empty) in the same order and with the same coordinate type.
  bool equalsCoords(PositionSeries other) {
    if (identical(this, other)) return true;
    if (positionCount != other.positionCount) return false;
    if (type != other.type) return false;

    return _testEqualsCoords(other);
  }

  /// Private implementation used by [equalsCoords] (overridden by sub classes).
  bool _testEqualsCoords(PositionSeries other) {
    final posCount = positionCount;
    for (var i = 0; i < posCount; i++) {
      if (x(i) != x(i)) return false;
      if (y(i) != y(i)) return false;
      if (is3D && z(i) != z(i)) return false;
      if (isMeasured && m(i) != m(i)) return false;
    }
    return true;
  }

  /// True if this series of positions equals with [other] by testing 2D
  /// coordinates of all positions (that must be in same order in both series).
  ///
  /// Returns false if this or [other] is empty ([isEmpty] is true).
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals2D(
    PositionSeries other, {
    double toleranceHoriz = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    if (isEmpty || other.isEmpty) return false;
    if (identical(this, other)) return true;
    if (positionCount != other.positionCount) return false;

    return _testEquals2D(other, toleranceHoriz: toleranceHoriz);
  }

  /// Private implementation used by [equals2D] (overridden by sub classes).
  bool _testEquals2D(
    PositionSeries other, {
    required double toleranceHoriz,
  }) {
    final posCount = positionCount;
    for (var i = 0; i < posCount; i++) {
      if ((x(i) - other.x(i)).abs() > toleranceHoriz ||
          (y(i) - other.y(i)).abs() > toleranceHoriz) {
        return false;
      }
    }
    return true;
  }

  /// True if this series of positions equals with [other] by testing 3D
  /// coordinates of all positions (that must be in same order in both views).
  ///
  /// Returns false if this or [other] is empty ([isEmpty] is true).
  ///
  /// Returns false if this or [other] do not contain 3D coordinates.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Differences on vertical coordinate values (ie. z or elev) between
  /// this and [other] must be within [toleranceVert].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals3D(
    PositionSeries other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    assertTolerance(toleranceVert);
    if (!is3D || !other.is3D) return false;
    if (isEmpty || other.isEmpty) return false;
    if (identical(this, other)) return true;
    if (positionCount != other.positionCount) return false;

    return _testEquals3D(
      other,
      toleranceHoriz: toleranceHoriz,
      toleranceVert: toleranceVert,
    );
  }

  /// Private implementation used by [equals3D] (overridden by sub classes).
  bool _testEquals3D(
    PositionSeries other, {
    required double toleranceHoriz,
    required double toleranceVert,
  }) {
    final posCount = positionCount;
    for (var i = 0; i < posCount; i++) {
      if ((x(i) - other.x(i)).abs() > toleranceHoriz ||
          (y(i) - other.y(i)).abs() > toleranceHoriz ||
          (z(i) - other.z(i)).abs() > toleranceVert) {
        return false;
      }
    }
    return true;
  }

  /// A string representation of coordinate values of all positions (in this
  /// series) separated by [delimiter].
  ///
  /// If [positionDelimiter] is given, then positions are separated by
  /// [positionDelimiter] and coordinate values inside positions by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// Set [swapXY] to true to print y (or latitude) before x (or longitude).
  String toText({
    String delimiter = ',',
    String? positionDelimiter,
    int? decimals,
    bool swapXY = false,
  }) =>
      positions.toText(
        delimiter: delimiter,
        positionDelimiter: positionDelimiter,
        decimals: decimals,
        swapXY: swapXY,
      );

  @override
  String toString() => toText();

  Iterable<double> _valuesByType(Coords type) {
    final posCount = positionCount;
    if (posCount > 0) {
      final yieldZ = type.is3D;
      final yieldM = type.isMeasured;
      final dim = type.coordinateDimension;
      final valCount = posCount * dim;

      return Iterable.generate(valCount, (index) {
        switch (index % dim) {
          case 0:
            return x(index ~/ dim);
          case 1:
            return y(index ~/ dim);
          case 2:
            if (yieldZ) {
              return z(index ~/ dim);
            } else if (yieldM) {
              return m(index ~/ dim);
            }
            return 0.0;
          case 3:
            if (yieldM) {
              return m(index ~/ dim);
            }
            return 0.0;
        }
        return 0.0;
      });
    }

    return const Iterable.empty();
  }
}

// ---------------------------------------------------------------------------
// PositionSeries from Position array

@immutable
class _PositionArray extends PositionSeries {
  final List<Position> _data;
  final Coords _type;
  final bool _reversed;

  /// A series of positions with positions stored in [source].
  const _PositionArray.view(
    List<Position> source, {
    required Coords type,
    bool reversed = false,
  })  : _data = source,
        _type = type,
        _reversed = reversed;

  @override
  int get spatialDimension => _type.spatialDimension;

  @override
  int get coordinateDimension => _type.coordinateDimension;

  @override
  bool get is3D => _type.is3D;

  @override
  bool get isMeasured => _type.isMeasured;

  @override
  Coords get type => _type;

  @override
  int get positionCount => _data.length;

  @override
  Iterable<Position> get positions => _reversed ? _data.reversed : _data;

  @override
  Iterable<R> positionsAs<R extends Position>({
    required CreatePosition<R> to,
  }) =>
      positions.map((pos) => pos.copyTo(to));

  @override
  Position operator [](int index) =>
      _data[_reversed ? positionCount - 1 - index : index];

  @override
  R get<R extends Position>(
    int index, {
    required CreatePosition<R> to,
  }) =>
      this[index].copyTo(to);

  @override
  double x(int index) => this[index].x;

  @override
  double y(int index) => this[index].y;

  @override
  double z(int index) => is3D ? this[index].z : 0.0;

  @override
  double? optZ(int index) => is3D ? this[index].optZ : null;

  @override
  double m(int index) => isMeasured ? this[index].m : 0.0;

  @override
  double? optM(int index) => isMeasured ? this[index].m : null;

  @override
  // ignore: unnecessary_this
  Iterable<double> get values => _valuesByType(this.type);

  @override
  Iterable<double> valuesByType(Coords type) => _valuesByType(type);

  @override
  PositionSeries copyByType(Coords type) => this.type == type
      ? this
      : PositionSeries.from(
          positions.map((pos) => pos.copyByType(type)).toList(growable: false),
          type: type,
        );

  @override
  PositionSeries reversed() => positionCount <= 1
      ? this
      : _PositionArray.view(_data, type: _type, reversed: !_reversed);

  @override
  PositionSeries project(Projection projection) => PositionSeries.from(
        positions.map((pos) => pos.project(projection)).toList(growable: false),
        type: type,
      );

  @override
  PositionSeries transform(TransformPosition transform) => PositionSeries.from(
        positions
            .map((pos) => pos.transform(transform))
            .toList(growable: false),
        type: type,
      );

  @override
  bool _testEqualsCoords(PositionSeries other) {
    final iter1 = positions.iterator;
    final iter2 = other.positions.iterator;
    while (iter1.moveNext()) {
      if (!iter2.moveNext()) return false;
      if (iter1.current != iter2.current) return false;
    }
    return true;
  }

  @override
  bool _testEquals2D(
    PositionSeries other, {
    required double toleranceHoriz,
  }) {
    final iter1 = positions.iterator;
    final iter2 = other.positions.iterator;
    while (iter1.moveNext()) {
      if (!iter2.moveNext()) return false;
      if (!iter1.current.equals2D(
        iter2.current,
        toleranceHoriz: toleranceHoriz,
      )) {
        return false;
      }
    }
    return true;
  }

  @override
  bool _testEquals3D(
    PositionSeries other, {
    required double toleranceHoriz,
    required double toleranceVert,
  }) {
    final iter1 = positions.iterator;
    final iter2 = other.positions.iterator;
    while (iter1.moveNext()) {
      if (!iter2.moveNext()) return false;
      if (!iter1.current.equals3D(
        iter2.current,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      )) {
        return false;
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is _PositionArray && _type == other._type && _data == other._data;

  @override
  int get hashCode => Object.hash(_type, _data);
}

// ---------------------------------------------------------------------------
// A series of positions from double array

@immutable
class _PositionDataCoords extends PositionSeries {
  final List<double> _data;
  final Coords _type;
  final int _positionCount;
  final bool _reversed;

  /// A series of positions with coordinate values of [type] from [source].
  _PositionDataCoords.view(
    List<double> source, {
    Coords type = Coords.xy,
    bool reversed = false,
  })  : _data = source,
        _type = type,
        _positionCount = source.length ~/ type.coordinateDimension,
        _reversed = reversed;

  @override
  int get spatialDimension => _type.spatialDimension;

  @override
  int get coordinateDimension => _type.coordinateDimension;

  @override
  bool get is3D => _type.is3D;

  @override
  bool get isMeasured => _type.isMeasured;

  @override
  Coords get type => _type;

  @override
  int get positionCount => _positionCount;

  @override
  Iterable<Position> get positions =>
      Iterable.generate(positionCount, (index) => this[index]);

  @override
  Iterable<R> positionsAs<R extends Position>({
    required CreatePosition<R> to,
  }) =>
      Iterable.generate(positionCount, (index) => this[index].copyTo(to));

  int _resolveIndex(int index) => _reversed ? positionCount - 1 - index : index;

  @override
  Position operator [](int index) => Position.subview(
        _data,
        start: _resolveIndex(index) * coordinateDimension,
        type: type,
      );

  @override
  R get<R extends Position>(
    int index, {
    required CreatePosition<R> to,
  }) =>
      to.call(
        x: x(index),
        y: y(index),
        z: optZ(index),
        m: optM(index),
      );

  @override
  double x(int index) => _data[_resolveIndex(index) * coordinateDimension];

  @override
  double y(int index) => _data[_resolveIndex(index) * coordinateDimension + 1];

  @override
  double z(int index) =>
      type.is3D ? _data[_resolveIndex(index) * coordinateDimension + 2] : 0.0;

  @override
  double? optZ(int index) =>
      type.is3D ? _data[_resolveIndex(index) * coordinateDimension + 2] : null;

  @override
  double m(int index) {
    final mIndex = type.indexForM;
    return mIndex != null
        ? _data[_resolveIndex(index) * coordinateDimension + mIndex]
        : 0.0;
  }

  @override
  double? optM(int index) {
    final mIndex = type.indexForM;
    return mIndex != null
        ? _data[_resolveIndex(index) * coordinateDimension + mIndex]
        : null;
  }

  @override
  Iterable<double> get values =>
      _reversed && positionCount > 1 ? _valuesByType(type) : _data;

  @override
  Iterable<double> valuesByType(Coords type) =>
      this.type == type ? values : _valuesByType(type);

  @override
  PositionSeries copyByType(Coords type) => this.type == type
      ? this
      : PositionSeries.view(
          toFloatNNList(
            valuesByType(type),
            singlePrecision: _data is Float32List,
          ),
          type: type,
        );

  @override
  PositionSeries reversed() => positionCount <= 1
      ? this
      : _PositionDataCoords.view(_data, type: _type, reversed: !_reversed);

  @override
  PositionSeries project(Projection projection) => PositionSeries.view(
        projection.projectCoords(
          values,
          type: type,
          target: _data is Float32List
              ? Float32List(positionCount * type.coordinateDimension)
              : Float64List(positionCount * type.coordinateDimension),
        ),
        type: type,
      );

  @override
  PositionSeries transform(TransformPosition transform) => PositionSeries.from(
        positions
            .map((pos) => pos.transform(transform))
            .toList(growable: false),
        type: type,
      );

  @override
  bool _testEqualsCoords(PositionSeries other) {
    final coords1 = values;
    final coords2 = other.values;
    final len = coords1.length;

    if (coords1 is List<double> && coords2 is List<double>) {
      for (var i = 0; i < len; i++) {
        if (coords1[i] != coords2[i]) return false;
      }
    } else {
      final iter1 = coords1.iterator;
      final iter2 = coords2.iterator;
      while (iter1.moveNext()) {
        if (!iter2.moveNext()) return false;
        if (iter1.current != iter2.current) return false;
      }
    }
    return true;
  }

  // Note: calculating equality and hashCode of Iterable<double> arrays is
  // delegated to viewed source iterable (most often lists).
  //
  // The default List: "Lists are, by default, only equal to themselves. Even if
  // other is also a list, the equality comparison does not compare the elements
  // of the two lists."
  //
  // So when two position arrays view on two different List<double> lists with
  // exactly same value in same order, this implementation returns false on
  // equality.
  //
  // Some other Iterable<double> or List<double> implementations might use
  // something like IterableEquality.equals / hash from "collection" package.
  //
  // Anyway, a position array might be really large, so calculating equality and
  // hash might then have performance issues too.

  @override
  bool operator ==(Object other) =>
      other is _PositionDataCoords &&
      _type == other._type &&
      _data == other._data;

  @override
  int get hashCode => Object.hash(_type, _data);
}
