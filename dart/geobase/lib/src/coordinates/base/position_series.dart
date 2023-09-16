// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/coord_utils.dart';
import '/src/utils/num.dart';
import '/src/utils/tolerance.dart';

import 'position.dart';
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
  factory PositionSeries.view(
    List<double> source, {
    Coords type = Coords.xy,
  }) =>
      _PositionDataCoords.view(source, type: type);

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
  /// See [Position] for description about supported coordinate values.
  ///
  /// Throws FormatException if coordinates are invalid.
  factory PositionSeries.parse(
    String text, {
    Pattern? delimiter = ',',
    Coords type = Coords.xy,
  }) =>
      PositionSeries.view(
        parseDoubleValues(text, delimiter: delimiter).toList(growable: false),
        type: type,
      );

  /// The number of positions in this series.
  int get length;

  /// Returns true if this series has no positions.
  bool get isEmpty => length == 0;

  /// Returns true if this series has at least one position.
  bool get isNotEmpty => length > 0;

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
  Position? get firstOrNull => length > 0 ? this[0] : null;

  /// The last position or null (if empty collection).
  Position? get lastOrNull {
    final len = length;
    return len > 0 ? this[len - 1] : null;
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

  /// Projects this series of positions to another series using [projection].
  PositionSeries project(Projection projection);

  /// Returns a position series with all points transformed using [transform].
  ///
  /// The returned object should be of the same type as this object has.
  PositionSeries transform(TransformPosition transform);

  /// True if the first and last position equals in 2D.
  bool get isClosed {
    final len = length;
    if (len >= 2) {
      return this[0].equals2D(this[len - 1]);
    }
    return false;
  }

  /// True if the first and last position equals in 2D within [toleranceHoriz].
  bool isClosedBy([double toleranceHoriz = defaultEpsilon]) {
    final len = length;
    if (len >= 2) {
      return this[0].equals2D(this[len - 1], toleranceHoriz: toleranceHoriz);
    }
    return false;
  }

  /// Returns true if this and [other] contain exactly same coordinate values
  /// (or both are empty) in the same order and with the same coordinate type.
  bool equalsCoords(PositionSeries other) {
    if (identical(this, other)) return true;
    if (length != other.length) return false;
    if (type != other.type) return false;

    for (var i = 0; i < length; i++) {
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
    if (length != other.length) return false;

    for (var i = 0; i < length; i++) {
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
    if (length != other.length) return false;

    for (var i = 0; i < length; i++) {
      if ((x(i) - other.x(i)).abs() > toleranceHoriz ||
          (y(i) - other.y(i)).abs() > toleranceHoriz ||
          (z(i) - other.z(i)).abs() > toleranceVert) {
        return false;
      }
    }
    return true;
  }
}

// ---------------------------------------------------------------------------
// PositionSeries from Position array

@immutable
class _PositionArray extends PositionSeries {
  final Iterable<Position> _data;
  final Coords _type;

  /// A series of positions with positions stored in [source].
  ///
  /// An iterable collection of [source] may be represented by a [List] or any
  /// [Iterable] with efficient `length` and `elementAt` implementations. A lazy
  /// iterable with a lot of position objects may produce very poor performance.
  const _PositionArray.view(
    Iterable<Position> source, {
    required Coords type,
  })  : _data = source,
        _type = type;

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
  int get length => _data.length;

  @override
  Iterable<Position> get positions => _data;

  @override
  Iterable<R> positionsAs<R extends Position>({
    required CreatePosition<R> to,
  }) =>
      _data.map((pos) => pos.copyTo(to));

  @override
  Position operator [](int index) => _data.elementAt(index);

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
  Iterable<double> get values sync* {
    final yieldZ = is3D;
    final yieldM = isMeasured;
    for (final pos in _data) {
      yield pos.x;
      yield pos.y;
      if (yieldZ) yield pos.z;
      if (yieldM) yield pos.m;
    }
  }

  @override
  Iterable<double> valuesByType(Coords type) sync* {
    final yieldZ = type.is3D;
    final yieldM = type.isMeasured;
    for (final pos in _data) {
      yield pos.x;
      yield pos.y;
      if (yieldZ) yield pos.z;
      if (yieldM) yield pos.m;
    }
  }

  @override
  PositionSeries copyByType(Coords type) => this.type == type
      ? this
      : PositionSeries.from(
          positions.map((pos) => pos.copyByType(type)).toList(growable: false),
          type: type,
        );

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

  /// A series of positions with coordinate values of [type] from [source].
  const _PositionDataCoords.view(
    List<double> source, {
    Coords type = Coords.xy,
  })  : _data = source,
        _type = type;

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
  int get length => _data.length ~/ coordinateDimension;

  @override
  Iterable<Position> get positions =>
      Iterable.generate(length, (index) => this[index]);

  @override
  Iterable<R> positionsAs<R extends Position>({
    required CreatePosition<R> to,
  }) =>
      Iterable.generate(length, (index) => this[index].copyTo(to));

  @override
  Position operator [](int index) => Position.subview(
        _data,
        start: index * coordinateDimension,
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
  double x(int index) => _data[index * coordinateDimension];

  @override
  double y(int index) => _data[index * coordinateDimension + 1];

  @override
  double z(int index) =>
      type.is3D ? _data[index * coordinateDimension + 2] : 0.0;

  @override
  double? optZ(int index) =>
      type.is3D ? _data[index * coordinateDimension + 2] : null;

  @override
  double m(int index) {
    final mIndex = type.indexForM;
    return mIndex != null ? _data[index * coordinateDimension + mIndex] : 0.0;
  }

  @override
  double? optM(int index) {
    final mIndex = type.indexForM;
    return mIndex != null ? _data[index * coordinateDimension + mIndex] : null;
  }

  @override
  Iterable<double> get values => _data;

  @override
  Iterable<double> valuesByType(Coords type) => this.type == type
      ? values
      : valuesByTypeIter(
          _data,
          sourceType: this.type,
          targetType: type,
        );

  @override
  PositionSeries copyByType(Coords type) => this.type == type
      ? this
      : PositionSeries.view(
          valuesByType(type).toList(growable: false),
          type: type,
        );

  @override
  PositionSeries project(Projection projection) => PositionSeries.view(
        projection.projectCoords(values, type: type),
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
  bool equalsCoords(PositionSeries other) {
    if (_type != other.type) return false;

    final coords1 = _data;
    final coords2 = other is _PositionDataCoords ? other._data : other.values;
    final len = coords1.length;
    if (len != coords2.length) return false;

    if (identical(coords1, coords2)) return true;

    if (coords2 is List<double>) {
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
