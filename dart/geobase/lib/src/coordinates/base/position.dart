// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import '/src/codes/coords.dart';
import '/src/constants/epsilon.dart';
import '/src/utils/format_validation.dart';
import '/src/utils/num.dart';
import '/src/utils/tolerance.dart';

import 'positionable.dart';

/// Creates a new position of [T] from [x] and [y], and optional [z] and [m].
///
/// For projected or cartesian positions (`Projected`), coordinates axis are
/// applied as is.
///
/// For geographic positions (`Geographic`), coordinates are applied as:
/// `x` => `lon`, `y` => `lat`, `z` => `elev`, `m` => `m`
typedef CreatePosition<T extends Position> = T Function({
  required num x,
  required num y,
  num? z,
  num? m,
});

/// A function to transform the [source] position of `T` to a position of `T`.
///
/// Target positions of `T` are created using [source] itself as a factory.
///
/// Throws FormatException if cannot transform.
typedef TransformPosition = T Function<T extends Position>(T source);

/// A base interface for geospatial positions.
///
/// The known sub classes are `Projected` (with x, y, z and m coordinates) and
/// `Geographic` (with lon, lat, elev and m coordinates).
///
/// All implementations must contain at least [x] and [y] coordinate values, but
/// [z] and [m] coordinates are optional (getters should return zero value when
/// such a coordinate axis is not available).
///
/// When a position contains geographic coordinates, then by default [x]
/// represents *longitude*, [y] represents *latitude*, and [z] represents
/// *elevation* (or *height* or *altitude*).
///
/// A projected map position might be defined as *easting* (E) and *northing*
/// (N) coordinates. It's suggested that then E == [x] and N == [y], but a
/// coordinate reference system might specify something else too.
///
/// [m] represents a measurement or a value on a linear referencing system (like
/// time). It could be associated with a 2D position (x, y, m) or a 3D position
/// (x, y, z, m).
///
/// For 2D coordinates the coordinate axis indexes are:
///
/// Index | Projected | Geographic
/// ----- | --------- | ----------
/// 0     | x         | lon
/// 1     | y         | lat
/// 2     | m         | m
///
/// For 3D coordinates the coordinate axis indexes are:
///
/// Index | Projected | Geographic
/// ----- | --------- | ----------
/// 0     | x         | lon
/// 1     | y         | lat
/// 2     | z         | elev
/// 3     | m         | m
///
/// Sub classes containing coordinate values mentioned above, should implement
/// equality and hashCode methods as:
///
/// ```dart
/// @override
/// bool operator ==(Object other) =>
///      other is Position && Position.testEquals(this, other);
///
/// @override
/// int get hashCode => Position.hash(this);
/// ```
abstract class Position extends Positionable {
  /// Default `const` constructor to allow extending this abstract class.
  const Position();

  /// The x coordinate value.
  ///
  /// For geographic coordinates x represents *longitude*.
  num get x;

  /// The y coordinate value.
  ///
  /// For geographic coordinates y represents *latitude*.
  num get y;

  /// The z coordinate value. Returns zero if not available.
  ///
  /// You can also use [is3D] to check whether z coordinate is available, or
  /// [optZ] returns z coordinate as a nullable value.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  num get z;

  /// The z coordinate value optionally. Returns null if not available.
  ///
  /// You can also use [is3D] to check whether z coordinate is available.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  num? get optZ;

  /// The m ("measure") coordinate value. Returns zero if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available,
  /// [optM] returns m coordinate as a nullable value.
  ///
  /// [m] represents a measurement or a value on a linear referencing system
  /// (like time).
  num get m;

  /// The m ("measure") coordinate optionally. Returns null if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available.
  ///
  /// [m] represents a measurement or a value on a linear referencing system
  /// (like time).
  num? get optM;

  /// A coordinate value by the coordinate axis [index].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For 2D coordinates the coordinate axis indexes are:
  ///
  /// Index | Projected | Geographic
  /// ----- | --------- | ----------
  /// 0     | x         | lon
  /// 1     | y         | lat
  /// 2     | m         | m
  ///
  /// For 3D coordinates the coordinate axis indexes are:
  ///
  /// Index | Projected | Geographic
  /// ----- | --------- | ----------
  /// 0     | x         | lon
  /// 1     | y         | lat
  /// 2     | z         | elev
  /// 3     | m         | m
  num operator [](int index);

  /// Coordinate values of this position as an iterable of 2, 3 or 4 items.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, z), (x, y, m) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, elev), (lon, lat, m) or (lon, lat, elev, m).
  Iterable<num> get values;

  /// Copies this position to a new position created by the [factory].
  R copyTo<R extends Position>(CreatePosition<R> factory) =>
      factory.call(x: x, y: y, z: optZ, m: optM);

  /// Copies the position with optional [x], [y], [z] and [m] overriding values.
  ///
  /// When copying `Geographic` then coordinates has correspondence:
  /// `x` => `lon`, `y` => `lat`, `z` => `elev`, `m` => `m`
  ///
  /// Some sub classes may ignore a non-null z parameter value if a position is
  /// not a 3D position, and a non-null m parameter if a position is not a
  /// measured position.
  Position copyWith({num? x, num? y, num? z, num? m});

  /// Returns a position with all points transformed using [transform].
  Position transform(TransformPosition transform);

  /// True if this position equals with [other] by testing 2D coordinates only.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals2D(
    Position other, {
    double toleranceHoriz = doublePrecisionEpsilon,
  }) =>
      Position.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  /// True if this position equals with [other] by testing 3D coordinates only.
  ///
  /// Returns false if this or [other] is not a 3D position.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Differences on vertical coordinate values (ie. z or elev) between
  /// this and [other] must be within [toleranceVert].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals3D(
    Position other, {
    double toleranceHoriz = doublePrecisionEpsilon,
    double toleranceVert = doublePrecisionEpsilon,
  }) =>
      Position.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  /// A string representation of coordinate values separated by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// Set [swapXY] to true to print y (or latitude) before x (or longitude).
  ///
  /// A sample with default parameters (for a 3D position):
  /// `10.1,20.3,30.3`
  ///
  /// To get WKT compatible text, set `delimiter` to ` `:
  /// `10.1 20.2 30.3`
  String toText({
    String delimiter = ',',
    int? decimals,
    bool swapXY = false,
  }) {
    final buf = StringBuffer();
    Position.writeValues(
      this,
      buf,
      delimiter: delimiter,
      decimals: decimals,
      swapXY: swapXY,
    );
    return buf.toString();
  }

  @override
  String toString() {
    final buf = StringBuffer()
      ..write(x)
      ..write(',')
      ..write(y);
    if (is3D) {
      buf
        ..write(',')
        ..write(z);
    }
    if (isMeasured) {
      buf
        ..write(',')
        ..write(m);
    }
    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Static methods with default logic, used by Position, Projected and
  // Geographic.

  /// Creates a position of [R] from [position] (of [R] or `Iterable<num>`).
  ///
  /// If [position] is [R] and with compatible coordinate type already, then
  /// it's returned.  Other `Position` instances are copied as [R].
  ///
  /// If [position] is `Iterable<num>`, then a position instance is created
  /// using the factory function [to]. Supported coordinate value combinations:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and an iterable has 3 items, then xyz coordinates are assumed.
  ///
  /// Otherwise throws `FormatException`.
  static R createFromObject<R extends Position>(
    Object position, {
    required CreatePosition<R> to,
    Coords? type,
  }) {
    if (position is Position) {
      if (position is R && (type == null || type == position.type)) {
        // position is of R and with compatiable coord type
        return position;
      } else {
        if (type == null) {
          // create a copy with same coordinate values
          return position.copyTo(to);
        } else {
          // create a copy with z and m selected if coord type suggests so
          return to.call(
            x: position.x,
            y: position.y,
            z: type.is3D ? position.z : null,
            m: type.isMeasured ? position.m : null,
          );
        }
      }
    } else if (position is Iterable<num>) {
      // create position from iterable of num values
      return buildPosition(position, to: to, type: type);
    }
    throw invalidCoordinates;
  }

  /// Builds a position of [R] from [coords] starting from [offset].
  ///
  /// A position instance is created using the factory function [to].
  ///
  /// Supported coordinate value combinations for [coords] are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [coords] has 3 items, then xyz coordinates are assumed.
  ///
  /// Throws FormatException if coordinates are invalid.
  static R buildPosition<R extends Position>(
    Iterable<num> coords, {
    required CreatePosition<R> to,
    int offset = 0,
    Coords? type,
  }) {
    if (coords is List<num>) {
      final len = coords.length - offset;
      final coordsType = type ?? Coords.fromDimension(math.min(4, len));
      final mIndex = coordsType.indexForM;
      if (len < 2) {
        throw invalidCoordinates;
      }
      return to.call(
        x: coords[offset],
        y: coords[offset + 1],
        z: coordsType.is3D ? (len > 2 ? coords[offset + 2] : 0) : null,
        m: mIndex != null ? (len > mIndex ? coords[offset + mIndex] : 0) : null,
      );
    } else {
      // resolve iterator for source coordinates
      final Iterator<num> iter;
      if (offset == 0) {
        iter = coords.iterator;
      } else if (coords.length >= offset + 2) {
        iter = coords.skip(offset).iterator;
      } else {
        throw invalidCoordinates;
      }

      // iterate at least to x and y
      final x = iter.moveNext() ? iter.current : throw invalidCoordinates;
      final y = iter.moveNext() ? iter.current : throw invalidCoordinates;

      // XY was asked
      if (type == Coords.xy) {
        return to.call(x: x, y: y);
      }

      // iterate optional z and m
      final num? optZ;
      if (type == null || type.is3D) {
        if (iter.moveNext()) {
          optZ = iter.current;
        } else {
          optZ = type?.is3D ?? false ? 0 : null;
        }
      } else {
        optZ = null;
      }
      final num? optM;
      if (type == null || type.isMeasured) {
        if (iter.moveNext()) {
          optM = iter.current;
        } else {
          optM = type?.isMeasured ?? false ? 0 : null;
        }
      } else {
        optM = null;
      }

      // finally create a position object
      return to.call(x: x, y: y, z: optZ, m: optM);
    }
  }

  /// Parses a position of [R] from [text].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// A position instance is created using the factory function [to].
  ///
  /// Supported coordinate value combinations for [text] are:
  /// (x, y), (x, y, z), (x, y, m) and (x, y, z, m).
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [text] has 3 items, then xyz coordinates are assumed.
  ///
  /// Throws FormatException if coordinates are invalid.
  static R parsePosition<R extends Position>(
    String text, {
    required CreatePosition<R> to,
    Pattern? delimiter = ',',
    Coords? type,
  }) {
    final coords = parseNumValues(text, delimiter: delimiter);
    return buildPosition(coords, to: to, type: type);
  }

  /// A coordinate value of [position] by the coordinate axis [index].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For 2D coordinates the supported indexes are:
  ///
  /// Index | Projected | Geographic
  /// ----- | --------- | ----------
  /// 0     | x         | lon
  /// 1     | y         | lat
  /// 2     | m         | m
  ///
  /// For 3D coordinates the supported indexes are:
  ///
  /// Index | Projected | Geographic
  /// ----- | --------- | ----------
  /// 0     | x         | lon
  /// 1     | y         | lat
  /// 2     | z         | elev
  /// 3     | m         | m
  static num getValue(Position position, int index) {
    if (position.is3D) {
      switch (index) {
        case 0:
          return position.x;
        case 1:
          return position.y;
        case 2:
          return position.z;
        case 3:
          return position.m; // returns m or 0
        default:
          return 0;
      }
    } else {
      switch (index) {
        case 0:
          return position.x;
        case 1:
          return position.y;
        case 2:
          return position.m; // returns m or 0
        default:
          return 0;
      }
    }
  }

  /// Coordinate values of [position] as an iterable of 2, 3 or 4 items.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, z), (x, y, m) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, elev), (lon, lat, m) or (lon, lat, elev, m).
  static Iterable<num> getValues(Position position) sync* {
    yield position.x;
    yield position.y;
    if (position.is3D) {
      yield position.z;
    }
    if (position.isMeasured) {
      yield position.m;
    }
  }

  /// Coordinate values of [position] as a double list of 2, 3 or 4 items.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, z), (x, y, m) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, elev), (lon, lat, m) or (lon, lat, elev, m).
  static List<double> getDoubleList(Position position) {
    final type = position.type;
    final list = List<double>.filled(type.coordinateDimension, 0);
    list[0] = position.x.toDouble();
    list[1] = position.y.toDouble();
    if (type.is3D) {
      list[2] = position.z.toDouble();
      if (type.isMeasured) {
        list[3] = position.m.toDouble();
      }
    } else {
      if (type.isMeasured) {
        list[2] = position.m.toDouble();
      }
    }
    return list;
  }

  /// Writes coordinate values of [position] to [buffer] separated by
  /// [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// Set [swapXY] to true to print y (or latitude) before x (or longitude).
  ///
  /// A sample with default parameters (for a 3D point):
  /// `10.1,20.3,30.3`
  ///
  /// To get WKT compatible text, set `delimiter` to ` `:
  /// `10.1 20.2 30.3`
  static void writeValues(
    Position position,
    StringSink buffer, {
    String delimiter = ',',
    int? decimals,
    bool swapXY = false,
  }) {
    if (decimals != null) {
      buffer
        ..write(
          toStringAsFixedWhenDecimals(
            swapXY ? position.y : position.x,
            decimals,
          ),
        )
        ..write(delimiter)
        ..write(
          toStringAsFixedWhenDecimals(
            swapXY ? position.x : position.y,
            decimals,
          ),
        );
      if (position.is3D) {
        buffer
          ..write(delimiter)
          ..write(toStringAsFixedWhenDecimals(position.z, decimals));
      }
      if (position.isMeasured) {
        buffer
          ..write(delimiter)
          ..write(toStringAsFixedWhenDecimals(position.m, decimals));
      }
    } else {
      buffer
        ..write(swapXY ? position.y : position.x)
        ..write(delimiter)
        ..write(swapXY ? position.x : position.y);
      if (position.is3D) {
        buffer
          ..write(delimiter)
          ..write(position.z);
      }
      if (position.isMeasured) {
        buffer
          ..write(delimiter)
          ..write(position.m);
      }
    }
  }

  /// True if positions [p1] and [p2] equals by testing all coordinate values.
  static bool testEquals(Position p1, Position p2) =>
      p1.x == p2.x && p1.y == p2.y && p1.optZ == p2.optZ && p1.optM == p2.optM;

  /// The hash code for [position].
  static int hash(Position position) =>
      Object.hash(position.x, position.y, position.optZ, position.optM);

  /// True if positions [p1] and [p2] equals by testing 2D coordinates only.
  static bool testEquals2D(
    Position p1,
    Position p2, {
    double toleranceHoriz = doublePrecisionEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    return (p1.x - p2.x).abs() <= toleranceHoriz &&
        (p1.y - p2.y).abs() <= toleranceHoriz;
  }

  /// True if positions [p1] and [p2] equals by testing 3D coordinates only.
  static bool testEquals3D(
    Position p1,
    Position p2, {
    double toleranceHoriz = doublePrecisionEpsilon,
    double toleranceVert = doublePrecisionEpsilon,
  }) {
    assertTolerance(toleranceVert);
    if (!Position.testEquals2D(p1, p2, toleranceHoriz: toleranceHoriz)) {
      return false;
    }
    if (!p1.is3D || !p1.is3D) {
      return false;
    }
    return (p1.z - p2.z).abs() <= toleranceVert;
  }
}
