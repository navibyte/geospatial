// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/codes/dimensionality.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/coord_calculations_cartesian.dart';
import '/src/utils/coord_positions.dart';
import '/src/utils/format_validation.dart';
import '/src/utils/tolerance.dart';

import 'bounded.dart';
import 'box.dart';
import 'position.dart';
import 'position_extensions.dart';
import 'position_scheme.dart';
import 'value_positionable.dart';

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
abstract class PositionSeries extends Bounded implements ValuePositionable {
  /// A position series object with an optional [bounds].
  const PositionSeries._({super.bounds});

  static final _empty = PositionSeries.view(const []);

  /// An empty series of positions without any positions.
  ///
  /// An optional [type] specifies the coordinate type.
  factory PositionSeries.empty([Coords type = Coords.xy]) =>
      type == Coords.xy ? _empty : PositionSeries.view(const [], type: type);

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
  /// for all positions). For an empty [source] the `Coords.xy` type is used if
  /// [type] is missing.
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
    } else if (data.isEmpty) {
      return _PositionArray.view(data, type: Coords.xy);
    } else {
      var is3D = true;
      var isMeasured = true;

      for (final elem in data) {
        final type = elem.coordType;
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
  @override
  int get positionCount;

  /// The number of coordinate values for all positions in this series.
  @override
  int get valueCount => positionCount * coordinateDimension;

  /// Returns true if this series has no positions.
  @override
  bool get isEmptyByGeometry => positionCount == 0;

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
  /// The number of all values expected is indicated by [valueCount].
  ///
  /// Each position contains 2, 3 or 4 coordinate values indicated by
  /// [coordinateDimension].
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
  @override
  Iterable<double> get values;

  /// Coordinate values of all positions in this series as an iterable.
  ///
  /// Each position contains 2, 3 or 4 coordinate values indicated by given
  /// [type].
  ///
  /// See [values] (that returns coordinate values according to the coordinate
  /// type of this bounding box) for description of possible return values.
  @override
  Iterable<double> valuesByType(Coords type);

  /// Copies this series of positions as another series with positions mapped by
  /// the given coordinate [type].
  @override
  PositionSeries copyByType(Coords type);

  /// Returns a position series with coordinate values packed in a flat
  /// structure.
  ///
  /// If this series is already "packed", then this is returned.
  ///
  /// If [singlePrecision] is true, then coordinate values of positions are
  /// stored in `Float32List` instead of the `Float64List` (default).
  ///
  /// The coordinate type of returned series is [type] when given, and othewise
  /// [coordType] of this series.
  PositionSeries packed({bool singlePrecision = false, Coords? type});

  /// Returns a position series with all positions in reversed order compared to
  /// this.
  PositionSeries reversed();

  /// Returns a subseries with positions from [start] (inclusive) to [end]
  /// (exclusive).
  ///
  /// If [end] is not provided, then all positions from [start] to end are
  /// returned.
  ///
  /// A returned series may point to the same position data as this (however
  /// implementations are allowed to make a copy of positions in the range).
  ///
  /// Valid queries are such that 0 ≤ start ≤ end ≤ [positionCount].
  PositionSeries range(int start, [int? end]);

  /// Returns a position series with positions from [start] (inclusive) to [end]
  /// (exclusive) removed.
  ///
  /// If [end] is not provided, then all positions from [start] to end are
  /// removed.
  ///
  /// A returned series may point to the same position data as this (however
  /// implementations are allowed to make a copy of positions in the range).
  ///
  /// Valid queries are such that 0 ≤ start ≤ end ≤ [positionCount].
  PositionSeries rangeRemoved(int start, [int? end]);

  /// Returns a position series with positions from [start] (inclusive) to [end]
  /// (exclusive) replaced with [replacements].
  ///
  /// A returned series may point to the same position data as this (however
  /// implementations are allowed to make a copy of positions in the range).
  ///
  /// Valid queries are such that 0 ≤ start ≤ end ≤ [positionCount].
  PositionSeries rangeReplaced(
    int start,
    int end,
    Iterable<Position> replacements,
  ) {
    final source = positions;
    Iterable<Position>? target;
    if (start == end && replacements.isEmpty) {
      // ignore: avoid_returning_this
      return this;
    } else if (start == 0 && end == positionCount) {
      target = replacements;
    } else {
      if (start > 0) {
        target = source.take(start);
      }
      target = target != null ? target.followedBy(replacements) : replacements;
      if (end < positionCount) {
        target = target.followedBy(source.skip(end));
      }
    }
    return PositionSeries.from(target, type: coordType);
  }

  /// Returns a position series with [iterable] of positions inserted at [index]
  /// of this series.
  ///
  /// A returned series may point to the same position data as this (however
  /// implementations are allowed to make a copy of positions in the range).
  ///
  /// Valid queries are such that 0 ≤ index < [positionCount].
  PositionSeries inserted(
    int index,
    Iterable<Position> iterable,
  ) =>
      rangeReplaced(index, index, iterable);

  /// Returns a position series with [iterable] of positions added to positions
  /// of this series.
  ///
  /// A returned series may point to the same position data as this (however
  /// implementations are allowed to make a copy of positions in the range).
  PositionSeries added(Iterable<Position> iterable) => PositionSeries.from(
        positions.followedBy(iterable),
        type: coordType,
      );

  /// Returns a position series with all positions of this series sorted to the
  /// order specified by [compare].
  PositionSeries sorted(int Function(Position a, Position b) compare) =>
      PositionSeries.from(
        positions.toList(growable: false)..sort(compare),
        type: coordType,
      );

  /// Returns a position series with all positions of this series that satisfy
  /// the predicate [test].
  ///
  /// The test predicate defined by
  /// `bool Function(int count, int index, Position element)` has arguments
  /// `count` (the count of all positions in this series), `index` (the current
  /// index of element tested) and `element` (the current element tested).
  PositionSeries filtered(
    bool Function(int count, int index, Position element) test,
  ) {
    final posCount = positionCount;
    var i = 0;
    return PositionSeries.from(
      positions.where((pos) => test(posCount, i++, pos)),
      type: coordType,
    );
  }

  /// Projects this series of positions to another series using [projection].
  @override
  PositionSeries project(Projection projection);

  /// Returns a position series with all positions transformed using
  /// [transform].
  ///
  /// As an example a transform function could be:
  ///
  /// ```dart
  /// /// A sample transform function for positions that translates `x` by 5.0,
  /// /// scales `y` by 2.0, keeps `z` intact (null or a value), and ensures
  /// /// `m` is cleared.
  /// T _sampleTransform<T extends Position>(
  ///   Position source, {
  ///   required CreatePosition<T> to,
  /// }) =>
  ///     // call factory to create a transformed position
  ///     to.call(
  ///       x: source.x + 5.0, // translate x by 5.0
  ///       y: source.y * 2.0, // scale y by 2.0
  ///       z: source.optZ, // copy z value from source (null or a value)
  ///       m: null, // set m null even if source has null
  ///     );
  /// ```
  ///
  /// Then this transform function could be applied like this:
  ///
  /// ```dart
  /// // create a position series object with three XY positions
  /// final series1 = [
  ///   [10.0, 11.0].xy,
  ///   [20.0, 21.0].xy,
  ///   [30.0, 31.0].xy,
  /// ].series();
  ///
  /// // transform it
  /// final transformed = series1.transform(_sampleTransform);
  ///
  /// // in this case the result would contains same coordinate values as this
  /// final series2 = [
  ///   [15.0, 22.0].xy,
  ///   [25.0, 42.0].xy,
  ///   [35.0, 62.0].xy,
  /// ].series()
  /// ```
  PositionSeries transform(TransformPosition transform) {
    final source = positions;
    // ignore: avoid_returning_this
    if (source.isEmpty) return this;

    return PositionSeries.from(
      source.map((pos) => pos.transform(transform)).toList(growable: false),
    );
  }

  /// Expands this position to an iterable of zero or more positions of using
  /// [expand].
  ///
  /// When [expand] returns zero or one position it can be considered
  /// implementing a *filter*.
  PositionSeries expand(ExpandPosition expand) {
    final source = positions;
    // ignore: avoid_returning_this
    if (source.isEmpty) return this;

    final target = <Position>[];
    for (final pos in source) {
      target.addAll(pos.expand(expand));
    }

    return PositionSeries.from(target);
  }

  @override
  Box? calculateBounds({PositionScheme scheme = Position.scheme}) {
    final posCount = positionCount;
    if (posCount >= 1) {
      final hasZ = is3D;
      final hasM = isMeasured;
      var minx = x(0);
      var miny = y(0);
      var minz = hasZ ? z(0) : 0.0;
      var minm = hasM ? m(0) : 0.0;
      var maxx = minx;
      var maxy = miny;
      var maxz = minz;
      var maxm = minm;

      if (posCount >= 2) {
        for (var i = 1; i < posCount; i++) {
          final xi = x(i);
          final yi = y(i);
          minx = math.min(minx, xi);
          miny = math.min(miny, yi);
          maxx = math.max(maxx, xi);
          maxy = math.max(maxy, yi);
          if (hasZ) {
            final zi = z(i);
            minz = math.min(minz, zi);
            maxz = math.max(maxz, zi);
          }
          if (hasM) {
            final mi = m(i);
            minm = math.min(minm, mi);
            maxm = math.max(maxm, mi);
          }
        }
      }

      return scheme.box.call(
        minX: minx,
        minY: miny,
        minZ: hasZ ? minz : null,
        minM: hasM ? minm : null,
        maxX: maxx,
        maxY: maxy,
        maxZ: hasZ ? maxz : null,
        maxM: hasM ? maxm : null,
      );
    }

    return null;
  }

  @override
  PositionSeries populated({
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  });

  @override
  PositionSeries unpopulated({
    bool onBounds = true,
  });

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
  @override
  bool equalsCoords(PositionSeries other) {
    if (identical(this, other)) return true;
    if (positionCount != other.positionCount) return false;
    if (coordType != other.coordType) return false;

    // test bounding boxes if both position series objects have it
    final bb1 = bounds;
    final bb2 = other.bounds;
    if (bb1 != null && bb2 != null && bb1 != bb2) {
      // both position series objects have bounding boxes and boxes do not equal
      return false;
    }

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
  /// Returns false if this or [other] is empty ([isEmptyByGeometry] is true).
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Tolerance values must be positive (>= 0.0).
  @override
  bool equals2D(
    PositionSeries other, {
    double toleranceHoriz = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    if (isEmptyByGeometry || other.isEmptyByGeometry) return false;
    if (identical(this, other)) return true;
    if (positionCount != other.positionCount) return false;

    // test bounding boxes if both position series objects have it
    final bb1 = bounds;
    final bb2 = other.bounds;
    if (bb1 != null &&
        bb2 != null &&
        !bb1.equals2D(
          bb2,
          toleranceHoriz: toleranceHoriz,
        )) {
      // both position series objects have boxes and boxes do not equal in 2D
      return false;
    }

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
  /// Returns false if this or [other] is empty ([isEmptyByGeometry] is true).
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
  @override
  bool equals3D(
    PositionSeries other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    assertTolerance(toleranceVert);
    if (!is3D || !other.is3D) return false;
    if (isEmptyByGeometry || other.isEmptyByGeometry) return false;
    if (identical(this, other)) return true;
    if (positionCount != other.positionCount) return false;

    // test bounding boxes if both position series objects have it
    final bb1 = bounds;
    final bb2 = other.bounds;
    if (bb1 != null &&
        bb2 != null &&
        !bb1.equals3D(
          bb2,
          toleranceHoriz: toleranceHoriz,
          toleranceVert: toleranceVert,
        )) {
      // both position series objects have boxes and boxes do not equal in 3D
      return false;
    }

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

  /// Returns the length of a line string represented by this position series
  /// calculated in a cartesian 2D plane.
  ///
  /// If this series is closed and it represents a linear ring of a polygon then
  /// the result is a perimeter of an area.
  ///
  /// To calculate lengths along the surface of the earth, see `spherical`
  /// extensions for `Iterable<Geographic>` and `PositionSeries` implemented by
  /// the `package:geobase/geodesy.dart` library.
  ///
  /// See also [length3D].
  double length2D() {
    var length = 0.0;
    final posCount = positionCount;
    if (posCount >= 2) {
      var px = x(0);
      var py = y(0);
      for (var i = 1; i < posCount; i++) {
        final cx = x(i);
        final cy = y(i);
        final dx = px - cx;
        final dy = py - cy;
        length += math.sqrt(dx * dx + dy * dy);
        px = cx;
        py = cy;
      }
    }
    return length;
  }

  /// Returns the length of a line string represented by this position series
  /// calculated in a cartesian 3D space.
  ///
  /// If this series is closed and it represents a linear ring of a polygon then
  /// the result is a perimeter of an area.
  ///
  /// To calculate (2D) lengths along the surface of the earth, see `spherical`
  /// extensions for `Iterable<Geographic>` and `PositionSeries` implemented by
  /// the `package:geobase/geodesy.dart` library.
  ///
  /// See also [length2D].
  double length3D() {
    var length = 0.0;
    final posCount = positionCount;
    if (posCount >= 2) {
      var px = x(0);
      var py = y(0);
      var pz = z(0);
      for (var i = 1; i < posCount; i++) {
        final cx = x(i);
        final cy = y(i);
        final cz = z(i);
        final dx = px - cx;
        final dy = py - cy;
        final dz = pz - cz;
        length += math.sqrt(dx * dx + dy * dy + dz * dz);
        px = cx;
        py = cy;
        pz = cz;
      }
    }
    return length;
  }

  /// Returns the signed area of a linear ring (polygon) represented by this
  /// position series calculated in a cartesian 2D plane.
  ///
  /// The area is positive for linear rings in counterclockwise (CCW) order, and
  /// negative for linear rings in clockwise (CW) order.
  ///
  /// To calculate (2D) area on the surface of the earth, see `spherical`
  /// extensions for `Iterable<Geographic>` and `PositionSeries` implemented by
  /// the `package:geobase/geodesy.dart` library.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // A sample closed polygon in the counterclockwise (CCW) order.
  /// // (source for the sample: http://en.wikipedia.org/wiki/Shoelace_formula).
  /// final shoelaceSample = [
  ///   [1.0, 6.0].xy,
  ///   [3.0, 1.0].xy,
  ///   [7.0, 2.0].xy,
  ///   [4.0, 4.0].xy,
  ///   [8.0, 5.0].xy,
  ///   [1.0, 6.0].xy,
  /// ].series();
  ///
  /// // The area is `16.5` for a closed counterclockwise (CCW) polygon.
  /// shoelaceSample.signedArea2D();
  ///
  /// // The area is `16.5` also for non-closed counterclockwise (CCW) polygon.
  /// shoelaceSample.subseries(1).signedArea2D();
  ///
  /// // The area is `-16.5` for a closed clockwise (CW) polygon.
  /// shoelaceSample.reversed().signedArea2D();
  ///
  /// // The area is `-16.5` also for non-closed clockwise (CW) polygon.
  /// shoelaceSample.subseries(1).reversed().signedArea2D();
  /// ```
  double signedArea2D() {
    // Based on Computational Geometry in C, 2nd edition (2005) by O'Rourke,
    // the section 1.4.3 (Code for Area).
    //
    // See also: https://en.wikipedia.org/wiki/Shoelace_formula

    var area = 0.0;
    final posCount = positionCount;
    if (posCount >= 3) {
      final px = x(0);
      final py = y(0);
      var aDeltaX = x(1) - px;
      var aDeltaY = y(1) - py;
      for (var i = 2; i < posCount; i++) {
        final nextDeltaX = x(i) - px;
        final nextDeltaY = y(i) - py;
        area += aDeltaX * nextDeltaY - nextDeltaX * aDeltaY;
        aDeltaX = nextDeltaX;
        aDeltaY = nextDeltaY;
      }
    }
    return area / 2.0;
  }

  /// Returns the centroid of a geometry represented by this position series
  /// calculated in a cartesian 2D plane.
  ///
  /// The *centroid* is - as by definition - *a geometric center of mass of a
  /// geometry*.
  ///
  /// The centroid is computed according to [dimensionality]:
  /// * `Dimensionality.volymetric`: not supported, works as `areal`
  /// * `Dimensionality.areal`: weighted by the area with this position series
  ///    representing a polygon with positions in the counterclockwise (CCW)
  ///    order.
  /// * `Dimensionality.linear`: computed from midpoints of line segments that
  ///    are weighted by the length of each line segment.
  /// * `Dimensionality.punctual`: the arithmetic mean of all separate
  ///    positions in this series.
  ///
  /// Returns null if a centroid position could not be calculated.
  ///
  /// See also [Centroid](https://en.wikipedia.org/wiki/Centroid) in Wikipedia.
  Position? centroid2D({
    Dimensionality dimensionality = Dimensionality.areal,
  }) {
    final topoDim = dimensionality.topologicalDimension;
    final posCount = positionCount;

    // Areal geometry (weighted by area triangles).
    if (topoDim >= 2 && posCount >= 3) {
      // See "Of a polygon" in https://en.wikipedia.org/wiki/Centroid
      var area = 0.0;
      var cx = 0.0;
      var cy = 0.0;
      var x1 = x(0);
      var y1 = y(0);
      for (var i = 1; i <= posCount; i++) {
        final isLast = i == posCount;
        final x2 = x(isLast ? 0 : i);
        final y2 = y(isLast ? 0 : i);
        final shoelace = x1 * y2 - x2 * y1;
        area += shoelace;
        cx += (x1 + x2) * shoelace;
        cy += (y1 + y2) * shoelace;
        x1 = x2;
        y1 = y2;
      }
      if (area.abs() > 0.0) {
        final area6 = 6.0 * (area / 2.0);
        return Position.create(
          x: cx / area6,
          y: cy / area6,
        );
      }
    }

    // Linear geometry (weighted by line segments).
    if (topoDim >= 1 && posCount >= 2) {
      var length = 0.0;
      var cx = 0.0;
      var cy = 0.0;
      var x1 = x(0);
      var y1 = y(0);
      for (var i = 1; i < posCount; i++) {
        final x2 = x(i);
        final y2 = y(i);
        final dx = x2 - x1;
        final dy = y2 - y1;
        final segmentLength = math.sqrt(dx * dx + dy * dy);
        if (segmentLength > 0.0) {
          length += segmentLength;
          cx += segmentLength * (x1 + x2) / 2.0;
          cy += segmentLength * (y1 + y2) / 2.0;
        }
        x1 = x2;
        y1 = y2;
      }
      if (length > 0.0) {
        return Position.create(
          x: cx / length,
          y: cy / length,
        );
      }
    }

    // Punctual geometry (arithmethic mean of all points).
    if (posCount >= 1) {
      var cx = 0.0;
      var cy = 0.0;
      for (var i = 0; i < posCount; i++) {
        cx += x(i);
        cy += y(i);
      }
      return Position.create(
        x: cx / posCount,
        y: cy / posCount,
      );
    }

    // could not calculate
    return null;
  }

  /// Returns a position series with coordinate values of all positions scaled
  /// by [factor].
  PositionSeries operator *(double factor) => PositionSeries.from(
        positions.map(
          (pos) => cartesianPositionScale(
            pos,
            factor: factor,
            to: pos.conforming.position,
          ),
        ),
      );

  /// Returns a position series with coordinate values of all positions negated.
  PositionSeries operator -() => PositionSeries.from(
        positions.map(
          (pos) => cartesianPositionNegate(pos, to: pos.conforming.position),
        ),
      );

  /// A string representation of coordinate values of all positions (in this
  /// series) separated by [delimiter].
  ///
  /// If [positionDelimiter] is given, then positions are separated by
  /// [positionDelimiter] and coordinate values inside positions by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// Set [swapXY] to true to print y (or latitude) before x (or longitude).
  @override
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
    super.bounds,
  })  : _data = source,
        _type = type,
        _reversed = reversed,
        super._();

  @override
  int get spatialDimension => _type.spatialDimension;

  @override
  int get coordinateDimension => _type.coordinateDimension;

  @override
  bool get is3D => _type.is3D;

  @override
  bool get isMeasured => _type.isMeasured;

  @override
  @Deprecated('Use coordType instead.')
  Coords get type => _type;

  @override
  Coords get coordType => _type;

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
  Iterable<double> get values => _valuesByType(coordType);

  @override
  Iterable<double> valuesByType(Coords type) => _valuesByType(type);

  @override
  PositionSeries copyByType(Coords type) => coordType == type
      ? this
      : PositionSeries.from(
          positions.map((pos) => pos.copyByType(type)).toList(growable: false),
          type: type,
        );

  @override
  PositionSeries packed({bool singlePrecision = false, Coords? type}) {
    final targetType = type ?? coordType;
    return PositionSeries.view(
      toFloatNNList(
        valuesByType(targetType),
        singlePrecision: singlePrecision,
        valueCount: positionCount * targetType.coordinateDimension,
      ),
      type: targetType,
    );
  }

  @override
  PositionSeries reversed() => positionCount <= 1
      ? this
      : _PositionArray.view(
          _data,
          type: _type,
          reversed: !_reversed,
          bounds: bounds,
        );

  @override
  PositionSeries range(int start, [int? end]) {
    final rangeEnd = math.min(end ?? positionCount, positionCount);
    if (start >= rangeEnd) {
      return PositionSeries.empty(coordType);
    } else if (start == 0 && rangeEnd == positionCount) {
      return this;
    } else {
      return PositionSeries.from(
        _reversed
            ? _data.reversed
                .skip(start)
                .take(rangeEnd - start)
                .toList(growable: false)
            : _data.sublist(start, rangeEnd),
        type: coordType,
      );
    }
  }

  @override
  PositionSeries rangeRemoved(int start, [int? end]) {
    final rangeEnd = math.min(end ?? positionCount, positionCount);
    if (start >= rangeEnd) {
      return this;
    } else if (start == 0 && rangeEnd == positionCount) {
      return PositionSeries.empty(coordType);
    } else if (rangeEnd == positionCount) {
      return range(0, start);
    } else if (start == 0) {
      return range(rangeEnd);
    } else {
      final removedCount = rangeEnd - start;
      final target = List<Position>.generate(
        positionCount - removedCount,
        (index) {
          if (index < start) {
            return this[index];
          } else {
            return this[removedCount + index];
          }
        },
      );
      return PositionSeries.from(target, type: coordType);
    }
  }

  @override
  PositionSeries project(Projection projection) => PositionSeries.from(
        positions.map((pos) => pos.project(projection)).toList(growable: false),
        type: coordType,
      );

  @override
  PositionSeries populated({
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  }) {
    if (onBounds) {
      // create a new series if bounds was unpopulated or of other scheme
      final b = bounds;
      final empty = isEmptyByGeometry;
      if ((b == null && !empty) ||
          (b != null && !b.conforming.conformsWith(scheme))) {
        return _PositionArray.view(
          _data,
          type: _type,
          reversed: _reversed,
          bounds: calculateBounds(scheme: scheme),
        );
      }
    }
    return this;
  }

  @override
  PositionSeries unpopulated({
    bool onBounds = true,
  }) =>
      onBounds && bounds != null
          ? _PositionArray.view(_data, type: _type, reversed: _reversed)
          : this;

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
      other is _PositionArray &&
      _type == other._type &&
      bounds == other.bounds &&
      _reversed == other._reversed &&
      _data == other._data;

  @override
  int get hashCode => Object.hash(_type, bounds, _reversed, _data);
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
    super.bounds,
  })  : _data = source,
        _type = type,
        _positionCount = source.length ~/ type.coordinateDimension,
        _reversed = reversed,
        super._();

  /// Internal helper to create a flat coordinate array for [count] positions.
  List<double> _createValueList(int count) => _data is Float32List
      ? Float32List(count * coordinateDimension)
      : Float64List(count * coordinateDimension);

  /// Internal helper to copy coordinate values from this to flat [target].
  ///
  /// Indexes [sourceStart], [sourceEnd] and [targetStart] specify indexes of
  /// positions not coordinate values.
  void _copyValues(
    List<double> target, {
    required int sourceStart,
    required int sourceEnd,
    required int targetStart,
  }) {
    final dim = coordinateDimension;
    for (var index = sourceStart; index < sourceEnd; index++) {
      // index in coordinate value array of this for a position by `index`
      // (need to use _resolveIndex to ensure any reversing is handled)
      final sourceArrayIndex = _resolveIndex(index) * dim;

      // index in coordinate value array of target
      final targetArrayIndex = (targetStart + index - sourceStart) * dim;

      // copy `dim` coordinate values for a position by `index`
      for (var i = 0; i < dim; i++) {
        target[targetArrayIndex + i] = _data[sourceArrayIndex + i];
      }
    }
  }

  @override
  int get spatialDimension => _type.spatialDimension;

  @override
  int get coordinateDimension => _type.coordinateDimension;

  @override
  bool get is3D => _type.is3D;

  @override
  bool get isMeasured => _type.isMeasured;

  @override
  @Deprecated('Use coordType instead.')
  Coords get type => _type;

  @override
  Coords get coordType => _type;

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
        type: coordType,
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
      is3D ? _data[_resolveIndex(index) * coordinateDimension + 2] : 0.0;

  @override
  double? optZ(int index) =>
      is3D ? _data[_resolveIndex(index) * coordinateDimension + 2] : null;

  @override
  double m(int index) {
    final mIndex = coordType.indexForM;
    return mIndex != null
        ? _data[_resolveIndex(index) * coordinateDimension + mIndex]
        : 0.0;
  }

  @override
  double? optM(int index) {
    final mIndex = coordType.indexForM;
    return mIndex != null
        ? _data[_resolveIndex(index) * coordinateDimension + mIndex]
        : null;
  }

  @override
  Iterable<double> get values =>
      _reversed && positionCount > 1 ? _valuesByType(coordType) : _data;

  @override
  Iterable<double> valuesByType(Coords type) =>
      coordType == type ? values : _valuesByType(type);

  @override
  PositionSeries copyByType(Coords type) => coordType == type
      ? this
      : PositionSeries.view(
          toFloatNNList(
            valuesByType(type),
            singlePrecision: _data is Float32List,
            valueCount: positionCount * type.coordinateDimension,
          ),
          type: type,
        );

  @override
  PositionSeries packed({bool singlePrecision = false, Coords? type}) {
    final isSingleCurrently = _data is Float32List;
    final targetType = type ?? coordType;

    if (coordType != targetType ||
        isSingleCurrently != singlePrecision ||
        _reversed) {
      return PositionSeries.view(
        toFloatNNList(
          valuesByType(targetType),
          singlePrecision: singlePrecision,
          valueCount: positionCount * targetType.coordinateDimension,
        ),
        type: targetType,
      );
    } else {
      // already packed (without reversed state and with correct precision)
      return this;
    }
  }

  @override
  PositionSeries reversed() => positionCount <= 1
      ? this
      : _PositionDataCoords.view(
          _data,
          type: _type,
          reversed: !_reversed,
          bounds: bounds,
        );

  @override
  PositionSeries range(int start, [int? end]) {
    final rangeEnd = math.min(end ?? positionCount, positionCount);
    if (start >= rangeEnd) {
      return PositionSeries.empty(coordType);
    } else if (start == 0 && rangeEnd == positionCount) {
      return this;
    } else {
      if (_reversed) {
        final target = _createValueList(rangeEnd - start);
        _copyValues(
          target,
          sourceStart: start,
          sourceEnd: rangeEnd,
          targetStart: 0,
        );
        return PositionSeries.view(target, type: coordType);
      } else {
        final arrayStart = start * coordinateDimension;
        final arrayEnd = rangeEnd * coordinateDimension;
        return PositionSeries.view(
          _data.sublist(arrayStart, arrayEnd),
          type: coordType,
        );
      }
    }
  }

  @override
  PositionSeries rangeRemoved(int start, [int? end]) {
    final rangeEnd = math.min(end ?? positionCount, positionCount);
    if (start >= rangeEnd) {
      return this;
    } else if (start == 0 && rangeEnd == positionCount) {
      return PositionSeries.empty(coordType);
    } else if (rangeEnd == positionCount) {
      return range(0, start);
    } else if (start == 0) {
      return range(rangeEnd);
    } else {
      final removedCount = rangeEnd - start;
      final target = _createValueList(positionCount - removedCount);
      _copyValues(
        target,
        sourceStart: 0,
        sourceEnd: start,
        targetStart: 0,
      );
      _copyValues(
        target,
        sourceStart: rangeEnd,
        sourceEnd: positionCount,
        targetStart: start,
      );
      return PositionSeries.view(target, type: coordType);
    }
  }

  @override
  PositionSeries project(Projection projection) => PositionSeries.view(
        projection.projectCoords(
          values,
          type: coordType,
          target: _createValueList(positionCount),
        ),
        type: coordType,
      );

  @override
  PositionSeries populated({
    int traverse = 0,
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  }) {
    if (onBounds) {
      // create a new series if bounds was unpopulated or of other scheme
      final b = bounds;
      final empty = isEmptyByGeometry;
      if ((b == null && !empty) ||
          (b != null && !b.conforming.conformsWith(scheme))) {
        return _PositionDataCoords.view(
          _data,
          type: _type,
          reversed: _reversed,
          bounds: calculateBounds(scheme: scheme),
        );
      }
    }
    return this;
  }

  @override
  PositionSeries unpopulated({
    int traverse = 0,
    bool onBounds = true,
  }) =>
      onBounds && bounds != null
          ? _PositionDataCoords.view(_data, type: _type, reversed: _reversed)
          : this;

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
      bounds == other.bounds &&
      _reversed == other._reversed &&
      _data == other._data;

  @override
  int get hashCode => Object.hash(_type, bounds, _reversed, _data);
}
