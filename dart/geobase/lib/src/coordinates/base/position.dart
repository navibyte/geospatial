// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_redundant_argument_values

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '/src/common/codes/coords.dart';
import '/src/common/constants/epsilon.dart';
import '/src/common/functions/position_functions.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/coord_calculations_cartesian.dart';
import '/src/utils/coord_positions.dart';
import '/src/utils/format_validation.dart';
import '/src/utils/num.dart';
import '/src/utils/tolerance.dart';

import 'box.dart';
import 'position_scheme.dart';
import 'value_positionable.dart';

/*
  NOTE: for the V2 of the geobase following class hiearchy is planned:
  * `Position` (x, y, z, m), the base class and generic positions on geometries
    * `Cartesian` (x, y, z, m), for local and geocentric use cases
      * `Projected` (x=easting, y=northing, z=elev, m), for map projections
    * `Geographic` (x=lon, y=lat, z=elev, m), for geodetic lan/lon
  * currently in V1 of the geobase `Cartesian` is not implemented
  * z (elev) and m are optional
*/

/// Creates a new position of [T] from [x] and [y], and optional [z] and [m].
///
/// For projected or cartesian positions (`Projected`), coordinates axis are
/// applied as is.
///
/// For geographic positions (`Geographic`), coordinates are applied as:
/// `x` => `lon`, `y` => `lat`, `z` => `elev`, `m` => `m`
typedef CreatePosition<T extends Position> = T Function({
  required double x,
  required double y,
  double? z,
  double? m,
});

/// A function to transform the [source] position to a position of [T] using
/// [to] as a factory.
typedef TransformPosition = T Function<T extends Position>(
  Position source, {
  required CreatePosition<T> to,
});

/// A function to expand the [source] position to an iterable of zero or more
/// positions of [T] using [to] as a factory.
///
/// When zero or one position is returned the function implements a *filter*.
typedef ExpandPosition = Iterable<T> Function<T extends Position>(
  Position source, {
  required CreatePosition<T> to,
});

/// A base class for geospatial positions.
///
/// The known two instantiable sub classes are `Projected` (with x, y, z and m
/// coordinates) and `Geographic` (with lon, lat, elev and m coordinates).
///
/// It's also possible to create a position using factory methods
/// [Position.view], [Position.create] and [Position.parse] that create an
/// instance storing coordinate values in a double array.
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
abstract class Position extends ValuePositionable {
  /// Default `const` constructor to allow extending this abstract class.
  const Position();

  /// A position scheme that creates base [Position] and [Box] instances for
  /// positions and bounding boxes.
  ///
  /// These instances can be used to store any positions and boxes (projected,
  /// geographic or some other).
  static const scheme =
      PositionScheme(position: Position.create, box: Box.create);

  /// A position with coordinate values as a view backed by [source].
  ///
  /// The [source] must contain 2, 3 or 4 coordinate values. Supported
  /// coordinate value combinations by coordinate [type] are:
  ///
  /// Type | Expected values
  /// ---- | ---------------
  /// xy   | x, y
  /// xyz  | x, y, z
  /// xym  | x, y, m
  /// xyzm | x, y, z, m
  ///
  /// Or when data is geographic:
  ///
  /// Type | Expected values
  /// ---- | ---------------
  /// xy   | lon, lat
  /// xyz  | lon, lat, elev
  /// xym  | lon, lat, m
  /// xyzm | lon, lat, elev, m
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D position (x: 10.0, y: 20.0)
  /// Position.view([10.0, 20.0]);
  ///
  /// // a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// Position.view([10.0, 20.0, 30.0]);
  ///
  /// // a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
  /// // (need to specify the coordinate type XYM)
  /// Position.view([10.0, 20.0, 40.0], type: Coords.xym);
  ///
  /// // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// Position.view([10.0, 20.0, 30.0, 40.0]);
  /// ```
  factory Position.view(List<double> source, {Coords? type}) {
    final len = source.length;
    final coordType = type ?? Coords.fromDimension(len);
    if (len != coordType.coordinateDimension) {
      throw invalidCoordinates;
    }
    return _PositionCoords.view(source, type: coordType);
  }

  /// A position with coordinate values as a sub view backed by [source],
  /// starting at [start].
  ///
  /// There must be at least 2, 3 or 4 coordinate values (depending on the
  /// [type] how many)
  ///
  /// Examples:
  ///
  /// ```dart
  /// // coordinate data with values: x0, y0, z0, m0, x1, y1, z1, m1
  /// final data = [-10.0, -20.0, -30.0, -40.0, 10.0, 20.0, 30.0, 40.0];
  ///
  /// // a 2D position (x: 10.0, y: 20.0)
  /// // (the coordinate type is XY by default when using subview)
  /// Position.subview(data, start: 4);
  ///
  /// // a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// Position.subview(data, start: 4, type: Coords.xyz);
  ///
  /// // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// Position.subview(data, start: 4, type: Coords.xyzm);
  /// ```
  factory Position.subview(
    List<double> source, {
    required int start,
    Coords type = Coords.xy,
  }) {
    final len = source.length;
    if (start + type.coordinateDimension > len) {
      throw invalidCoordinates;
    }
    return _PositionCoordsSubview.view(source, start: start, type: type);
  }

  /// A position from parameters compatible with `CreatePosition` function type.
  ///
  /// The [Position.view] constructor is used to create a position from a double
  /// array filled by given [x], [y], and optionally [z] and [m].
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D position (x: 10.0, y: 20.0)
  /// Position.create(x: 10.0, y: 20.0);
  ///
  /// // a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// Position.create(x: 10.0, y: 20.0, z: 30.0);
  ///
  /// // a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
  /// Position.create(x: 10.0, y: 20.0, m: 40.0);
  ///
  /// // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// Position.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0);
  /// ```
  factory Position.create({
    required double x,
    required double y,
    double? z,
    double? m,
  }) {
    if (z != null) {
      // 3D coordinates
      if (m != null) {
        // 3D and measured coordinates
        final list = Float64List(4);
        list[0] = x;
        list[1] = y;
        list[2] = z;
        list[3] = m;
        return Position.view(list, type: Coords.xyzm);
      } else {
        // 3D coordinates (not measured)
        final list = Float64List(3);
        list[0] = x;
        list[1] = y;
        list[2] = z;
        return Position.view(list, type: Coords.xyz);
      }
    } else {
      // 2D coordinates
      if (m != null) {
        // 2D and measured coordinates
        final list = Float64List(3);
        list[0] = x;
        list[1] = y;
        list[2] = m;
        return Position.view(list, type: Coords.xym);
      } else {
        // 2D coordinates (not measured)
        final list = Float64List(2);
        list[0] = x;
        list[1] = y;
        return Position.view(list, type: Coords.xy);
      }
    }
  }

  /// Parses a position from [text].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// The [Position.view] constructor is used to create a position from a double
  /// array filled by coordinate values parsed.
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [text] has 3 items, then xyz coordinates are assumed.
  ///
  /// If [swapXY] is true, then swaps x and y for the result.
  ///
  /// If [singlePrecision] is true, then coordinate values of a position are
  /// stored in `Float32List` instead of the `Float64List` (default).
  ///
  /// Throws FormatException if coordinates are invalid.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D position (x: 10.0, y: 20.0)
  /// Position.parse('10.0,20.0');
  ///
  /// // a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// Position.parse('10.0,20.0,30.0');
  ///
  /// // a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
  /// // (need to specify the coordinate type XYM)
  /// Position.parse('10.0,20.0,40.0', type: Coords.xym);
  ///
  /// // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// Position.parse('10.0,20.0,30.0,40.0');
  ///
  /// // a 2D position (x: 10.0, y: 20.0) using an alternative delimiter
  /// Position.parse('10.0;20.0', delimiter: ';');
  ///
  /// // a 2D position (x: 10.0, y: 20.0) from an array with y before x
  /// Position.parse('20.0,10.0', swapXY: true);
  ///
  /// // a 2D position (x: 10.0, y: 20.0) with the internal storage using
  /// // single precision floating point numbers (`Float32List` in this case)
  /// Position.parse('10.0,20.0', singlePrecision: true);
  /// ```
  factory Position.parse(
    String text, {
    Pattern delimiter = ',',
    Coords? type,
    bool swapXY = false,
    bool singlePrecision = false,
  }) =>
      parsePositionFromText(
        text,
        delimiter: delimiter,
        type: type,
        swapXY: swapXY,
        singlePrecision: singlePrecision,
      );

  /// Returns a position scheme this position is conforming to.
  PositionScheme get conforming => Position.scheme;

  /// The x coordinate value.
  ///
  /// For geographic coordinates x represents *longitude*.
  double get x;

  /// The y coordinate value.
  ///
  /// For geographic coordinates y represents *latitude*.
  double get y;

  /// The z coordinate value. Returns zero if not available.
  ///
  /// You can also use [is3D] to check whether z coordinate is available, or
  /// [optZ] returns z coordinate as a nullable value.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  double get z;

  /// The z coordinate value optionally. Returns null if not available.
  ///
  /// You can also use [is3D] to check whether z coordinate is available.
  ///
  /// For geographic coordinates z represents *elevation* or *altitude*.
  double? get optZ;

  /// The m ("measure") coordinate value. Returns zero if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available,
  /// [optM] returns m coordinate as a nullable value.
  ///
  /// [m] represents a measurement or a value on a linear referencing system
  /// (like time).
  double get m;

  /// The m ("measure") coordinate optionally. Returns null if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available.
  ///
  /// [m] represents a measurement or a value on a linear referencing system
  /// (like time).
  double? get optM;

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
  double operator [](int index) => Position.getValue(this, index);

  /// A [Position] object represents a single position, returns always `1`.
  @override
  int get positionCount => 1;

  /// Coordinate values of this position as an iterable of 2, 3 or 4 items.
  ///
  /// The number of values expected is indicated by [valueCount].
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, z), (x, y, m) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, elev), (lon, lat, m) or (lon, lat, elev, m).
  ///
  /// See also [valuesByType] that returns coordinate values according to a
  /// given coordinate type.
  @override
  Iterable<double> get values => Position.getValues(this, type: coordType);

  @override
  Iterable<double> valuesByType(Coords type) =>
      Position.getValues(this, type: type);

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
  Position copyWith({double? x, double? y, double? z, double? m});

  @override
  Position copyByType(Coords type);

  /// Returns a position instance whose coordinate storage contains only
  /// coordinate values represented by this position.
  ///
  /// If this position is already "packed", then this is returned.
  ///
  /// If this position has coordinate values in a subview of a large coordinate
  /// array, then the returned position has coordinate values in an array that
  /// is packed to contain only necessary values.
  Position packed();

  /// Projects this position to another position using [projection].
  ///
  /// Subtypes may specify a more accurate position type for the returned object
  /// (for example a *geographic* position would return a *projected* position
  /// when forward-projecting, and other way when inverse-projecting).
  @override
  Position project(Projection projection);

  /// Returns a position transformed from this using [transform].
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
  /// // create a position X and Y coordinate values
  /// final position1 = [10.0, 11.0].xy;
  ///
  /// // transform it
  /// final transformed = position1.transform(_sampleTransform);
  ///
  /// // in this case the result would contains same coordinate values as this
  /// final position2 = [15.0, 22.0].xy;
  /// ```
  Position transform(TransformPosition transform) =>
      transform.call(this, to: conforming.position);

  /// Expands this position to an iterable of zero or more positions of using
  /// [expand].
  ///
  /// When [expand] returns zero or one position it can be considered
  /// implementing a *filter*.
  Iterable<Position> expand(ExpandPosition expand) =>
      expand.call(this, to: conforming.position);

  /// True if this and the [other] position equals.
  @override
  bool equalsCoords(Position other) => this == other;

  /// True if this position equals with [other] by testing 2D coordinates only.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Tolerance values must be positive (>= 0.0).
  @override
  bool equals2D(
    Position other, {
    double toleranceHoriz = defaultEpsilon,
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
  @override
  bool equals3D(
    Position other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) =>
      Position.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  /// Returns a distance from this to [destination] calculated in a cartesian
  /// 2D plane.
  ///
  /// To calculate distances along the surface of the earth, see `spherical` and
  /// `rhumb` extensions for `Geographic` positions implemented by the
  /// `package:geobase/geodesy.dart` library.
  ///
  /// See also [distanceTo3D].
  double distanceTo2D(Position destination) => this == destination
      ? 0.0
      : math.sqrt(
          (x - destination.x) * (x - destination.x) +
              (y - destination.y) * (y - destination.y),
        );

  /// Returns a distance from this to [destination] calculated in a cartesian
  /// 3D space.
  ///
  /// To calculate distances along the surface of the earth, see `spherical` and
  /// `rhumb` extensions for `Geographic` positions implemented by the
  /// `package:geobase/geodesy.dart` library.
  ///
  /// See also [distanceTo2D].
  double distanceTo3D(Position destination) => this == destination
      ? 0.0
      : math.sqrt(
          (x - destination.x) * (x - destination.x) +
              (y - destination.y) * (y - destination.y) +
              (z - destination.z) * (z - destination.z),
        );

  /// Returns a distance from this to a line segment formed by [start] and [end]
  /// positions calculated in a cartesian 2D plane.
  double distanceToLineSegment2D(Position start, Position end) {
    final deltaX = end.x - start.x;
    final deltyY = end.y - start.y;

    final norm = deltaX * deltaX + deltyY * deltyY;

    final u = (((x - start.x) * deltaX + (y - start.y) * deltyY) / norm)
        .clamp(0.0, 1.0);

    final lineX = start.x + u * deltaX;
    final lineY = start.y + u * deltyY;

    final dx = lineX - x;
    final dy = lineY - y;

    return math.sqrt(dx * dx + dy * dy);
  }

  /// Returns a bearing from this to [destination] calculated in a cartesian
  /// 2D plane.
  ///
  /// The bearing is measured in degrees (0°..360°) with 0° pointing to the
  /// positive Y-axis ("north"), 90° to the positive X-axis ("east"), 180° to
  /// the negative Y-axis ("south"), and 270° to the negative X-axis ("west").
  ///
  /// To calculate initial and final bearings along the surface of the earth,
  /// see `spherical` and `rhumb` extensions for `Geographic` positions
  /// implemented by the `package:geobase/geodesy.dart` library.
  double bearingTo2D(Position destination) => this == destination
      ? 0.0
      : (450.0 - math.atan2(destination.y - y, destination.x - x).toDegrees()) %
          360.0;

  /// Returns a midpoint between this and [destination] positions calculated in
  /// the cartesian coordinate reference system.
  ///
  /// To calculate midpoints along the surface of the earth, see `spherical` and
  /// `rhumb` extensions for `Geographic` positions implemented by the
  /// `package:geobase/geodesy.dart` library.
  Position midPointTo(Position destination) =>
      cartesianMidPointTo(this, destination, to: conforming.position);

  /// Returns an intermediate point at the given [fraction] between this and
  /// [destination] positions calculated in the cartesian coordinate reference
  /// system.
  ///
  /// Parameters:
  /// * [fraction]: 0.0 = this position, 1.0 = destination
  ///
  /// To calculate intermediate points along the surface of the earth, see
  /// the `spherical` extension for `Geographic` positions implemented by the
  /// `package:geobase/geodesy.dart` library.
  ///
  /// Examples:
  /// ```dart
  ///   final p1 = Position.create(x: 0.119, y: 52.205);
  ///   final p2 = Position.create(x: 2.351, y: 48.857);
  ///
  ///   // intermediate point (x: 0.677, y: 51.368)
  ///   final pInt = p1.intermediatePointTo(p2, fraction: 0.25);
  /// ```
  Position intermediatePointTo(
    Position destination, {
    required double fraction,
  }) =>
      cartesianIntermediatePointTo(
        this,
        destination,
        fraction: fraction,
        to: conforming.position,
      );

  /// Returns a destination point located at the given [distance] from this to
  /// the direction of [bearing] calculated in a cartesian 2D plane.
  ///
  /// The bearing is measured in degrees (0°..360°) with 0° pointing to the
  /// positive Y-axis ("north"), 90° to the positive X-axis ("east"), 180° to
  /// the negative Y-axis ("south"), and 270° to the negative X-axis ("west").
  ///
  /// To calculate destination points along the surface of the earth, see
  /// the `spherical` extension for `Geographic` positions implemented by the
  /// `package:geobase/geodesy.dart` library.
  ///
  /// Examples:
  /// ```dart
  ///   final p1 = Position.create(x: 0.119, y: 52.205);
  ///
  ///   // destination point (x: 2.351, y: 48.857)
  ///   final pInt = p1.destinationPoint2D(bearing: 146.31, distance: 4.024);
  /// ```
  Position destinationPoint2D({
    required double distance,
    required double bearing,
  }) =>
      cartesianDestinationPoint2D(
        this,
        distance: distance,
        bearing: bearing,
        to: conforming.position,
      );

  /// Returns a position with coordinate values summed from this and [other].
  Position operator +(Position other) =>
      cartesianPositionSum(this, other, to: conforming.position);

  /// Returns a position with coordinate values of this subtracted with values
  /// of [other].
  Position operator -(Position other) =>
      cartesianPositionSubtract(this, other, to: conforming.position);

  /// Returns a position with coordinate values of this scaled by [factor].
  Position operator *(double factor) =>
      cartesianPositionScale(this, factor: factor, to: conforming.position);

  /// Returns a position with coordinate values of this divided by values of
  /// [divisor].
  ///
  /// Examples:
  ///
  /// ```dart
  /// // This usage of division operator returns a position of `[15.0, 15.0].xy`
  /// [150.0, 300.0].xy / [10.0, 20.0].xy;
  /// ```
  Position operator /(Position divisor) => cartesianPositionDivision(
        this,
        divisor: divisor,
        to: conforming.position,
      );

  /// Returns a position with coordinate values of this applied with modulo
  /// operator `%` by values of [divisor].
  ///
  /// Examples:
  ///
  /// ```dart
  /// // This usage of modulo operator returns a position of `[10.0, 170.0].xy`
  /// [370.0, 170.0].xy % [360.0, 180.0].xy;
  /// ```
  Position operator %(Position divisor) =>
      cartesianPositionModulo(this, divisor: divisor, to: conforming.position);

  /// Returns a position with coordinate values of this negated.
  Position operator -() =>
      cartesianPositionNegate(this, to: conforming.position);

  /// A string representation of coordinate values separated by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// If [compactNums] is true, any ".0" postfixes of numbers without fraction
  /// digits are stripped.
  ///
  /// Set [swapXY] to true to print y (or latitude) before x (or longitude).
  ///
  /// A sample with default parameters (for a 3D position):
  /// `10.1,20.3,30.3`
  ///
  /// To get WKT compatible text, set `delimiter` to ` `:
  /// `10.1 20.2 30.3`
  @override
  String toText({
    String delimiter = ',',
    int? decimals,
    bool compactNums = true,
    bool swapXY = false,
  }) {
    final buf = StringBuffer();
    Position.writeValues(
      this,
      buf,
      delimiter: delimiter,
      decimals: decimals,
      compactNums: compactNums,
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
      if (position is R && (type == null || type == position.coordType)) {
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
  /// If [swapXY] is true, then swaps x and y for the result.
  ///
  /// Throws FormatException if coordinates are invalid.
  static R buildPosition<R extends Position>(
    Iterable<num> coords, {
    required CreatePosition<R> to,
    int offset = 0,
    Coords? type,
    bool swapXY = false,
  }) {
    if (coords is List<num>) {
      final len = coords.length - offset;
      final coordsType = type ?? Coords.fromDimension(math.min(4, len));
      final mIndex = coordsType.indexForM;
      if (len < 2) {
        throw invalidCoordinates;
      }
      return to.call(
        x: coords[swapXY ? offset + 1 : offset].toDouble(),
        y: coords[swapXY ? offset : offset + 1].toDouble(),
        z: coordsType.is3D
            ? (len > 2 ? coords[offset + 2] : 0.0).toDouble()
            : null,
        m: mIndex != null
            ? (len > mIndex ? coords[offset + mIndex] : 0.0).toDouble()
            : null,
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
      final num x;
      final num y;
      if (swapXY) {
        y = iter.moveNext() ? iter.current : throw invalidCoordinates;
        x = iter.moveNext() ? iter.current : throw invalidCoordinates;
      } else {
        x = iter.moveNext() ? iter.current : throw invalidCoordinates;
        y = iter.moveNext() ? iter.current : throw invalidCoordinates;
      }

      // XY was asked
      if (type == Coords.xy) {
        return to.call(x: x.toDouble(), y: y.toDouble());
      }

      // iterate optional z and m
      final num? optZ;
      if (type == null || type.is3D) {
        if (iter.moveNext()) {
          optZ = iter.current;
        } else {
          optZ = type?.is3D ?? false ? 0.0 : null;
        }
      } else {
        optZ = null;
      }
      final num? optM;
      if (type == null || type.isMeasured) {
        if (iter.moveNext()) {
          optM = iter.current;
        } else {
          optM = type?.isMeasured ?? false ? 0.0 : null;
        }
      } else {
        optM = null;
      }

      // finally create a position object
      return to.call(
        x: x.toDouble(),
        y: y.toDouble(),
        z: optZ?.toDouble(),
        m: optM?.toDouble(),
      );
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
  /// If [swapXY] is true, then swaps x and y for the result.
  ///
  /// Throws FormatException if coordinates are invalid.
  static R parsePosition<R extends Position>(
    String text, {
    required CreatePosition<R> to,
    Pattern delimiter = ',',
    Coords? type,
    bool swapXY = false,
  }) {
    final coords = parseDoubleValues(text, delimiter: delimiter);
    return buildPosition(coords, to: to, type: type, swapXY: swapXY);
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
  static double getValue(Position position, int index) {
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
  static Iterable<double> getValues(
    Position position, {
    required Coords type,
  }) sync* {
    yield position.x;
    yield position.y;
    if (type.is3D) {
      yield position.z;
    }
    if (type.isMeasured) {
      yield position.m;
    }
  }

  /// Writes coordinate values of [position] to [buffer] separated by
  /// [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// If [compactNums] is true, any ".0" postfixes of numbers without fraction
  /// digits are stripped.
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
    bool compactNums = true,
    bool swapXY = false,
  }) {
    if (decimals != null) {
      buffer
        ..write(
          toStringAsFixedWhenDecimals(
            swapXY ? position.y : position.x,
            decimals,
            compact: compactNums,
          ),
        )
        ..write(delimiter)
        ..write(
          toStringAsFixedWhenDecimals(
            swapXY ? position.x : position.y,
            decimals,
            compact: compactNums,
          ),
        );
      if (position.is3D) {
        buffer
          ..write(delimiter)
          ..write(
            toStringAsFixedWhenDecimals(
              position.z,
              decimals,
              compact: compactNums,
            ),
          );
      }
      if (position.isMeasured) {
        buffer
          ..write(delimiter)
          ..write(
            toStringAsFixedWhenDecimals(
              position.m,
              decimals,
              compact: compactNums,
            ),
          );
      }
    } else {
      buffer
        ..write(
          toStringCompact(
            swapXY ? position.y : position.x,
            compact: compactNums,
          ),
        )
        ..write(delimiter)
        ..write(
          toStringCompact(
            swapXY ? position.x : position.y,
            compact: compactNums,
          ),
        );
      if (position.is3D) {
        buffer
          ..write(delimiter)
          ..write(toStringCompact(position.z, compact: compactNums));
      }
      if (position.isMeasured) {
        buffer
          ..write(delimiter)
          ..write(toStringCompact(position.m, compact: compactNums));
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
    double toleranceHoriz = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    return (p1.x - p2.x).abs() <= toleranceHoriz &&
        (p1.y - p2.y).abs() <= toleranceHoriz;
  }

  /// True if positions [p1] and [p2] equals by testing 3D coordinates only.
  static bool testEquals3D(
    Position p1,
    Position p2, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
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

// ---------------------------------------------------------------------------
// Position from double array

@immutable
class _PositionCoords extends Position {
  final Iterable<double> _data;
  final Coords _type;

  /// A position with coordinate values of [type] from [source].
  ///
  /// A double iterable of [source] may be represented by a [List] or any
  /// [Iterable] with efficient `length` and `elementAt` implementations.
  const _PositionCoords.view(Iterable<double> source, {required Coords type})
      : _data = source,
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
  double get x => _data.elementAt(0);

  @override
  double get y => _data.elementAt(1);

  @override
  double get z => is3D ? _data.elementAt(2) : 0.0;

  @override
  double? get optZ => is3D ? _data.elementAt(2) : null;

  @override
  double get m {
    final mIndex = _type.indexForM;
    return mIndex != null ? _data.elementAt(mIndex) : 0.0;
  }

  @override
  double? get optM {
    final mIndex = _type.indexForM;
    return mIndex != null ? _data.elementAt(mIndex) : null;
  }

  @override
  double operator [](int index) =>
      index >= 0 && index < coordinateDimension ? _data.elementAt(index) : 0.0;

  @override
  Iterable<double> get values => _data;

  @override
  Iterable<double> valuesByType(Coords type) =>
      type == this.type ? _data : Position.getValues(this, type: type);

  @override
  Position copyWith({double? x, double? y, double? z, double? m}) {
    final newType = Coords.select(
      is3D: is3D || z != null,
      isMeasured: isMeasured || m != null,
    );

    final list = _data is Float32List
        ? Float32List(newType.coordinateDimension)
        : Float64List(newType.coordinateDimension);
    list[0] = x ?? this.x;
    list[1] = y ?? this.y;
    if (newType.is3D) {
      list[2] = z ?? this.z;
    }
    if (newType.isMeasured) {
      list[newType.indexForM!] = m ?? this.m;
    }

    return Position.view(
      list,
      type: newType,
    );
  }

  @override
  Position copyByType(Coords type) => this.type == type
      ? this
      : Position.create(
          x: x,
          y: y,
          z: type.is3D ? z : null,
          m: type.isMeasured ? m : null,
        );

  @override
  Position packed() => this;

  @override
  Position project(Projection projection) =>
      projection.project(this, to: Position.create);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Position && Position.testEquals(this, other));

  @override
  int get hashCode => Position.hash(this);
}

@immutable
class _PositionCoordsSubview extends _PositionCoords {
  final int _start;

  /// A position with coordinate values as a sub view backed by `source`,
  /// starting at [start].
  ///
  /// A double iterable of `source` may be represented by a [List] or any
  /// [Iterable] with efficient `length` and `elementAt` implementations.
  const _PositionCoordsSubview.view(
    super.source, {
    required int start,
    required super.type,
  })  : _start = start,
        super.view();

  @override
  double get x => _data.elementAt(_start + 0);

  @override
  double get y => _data.elementAt(_start + 1);

  @override
  double get z => is3D ? _data.elementAt(_start + 2) : 0.0;

  @override
  double? get optZ => is3D ? _data.elementAt(_start + 2) : null;

  @override
  double get m {
    final mIndex = _type.indexForM;
    return mIndex != null ? _data.elementAt(_start + mIndex) : 0.0;
  }

  @override
  double? get optM {
    final mIndex = _type.indexForM;
    return mIndex != null ? _data.elementAt(_start + mIndex) : null;
  }

  @override
  double operator [](int index) => index >= 0 && index < coordinateDimension
      ? _data.elementAt(_start + index)
      : 0.0;

  @override
  Iterable<double> get values =>
      _start == 0 && _data.length == coordinateDimension
          ? _data
          : _data.skip(_start).take(coordinateDimension);

  @override
  Iterable<double> valuesByType(Coords type) =>
      _start == 0 && _data.length == coordinateDimension && this.type == type
          ? _data
          : Position.getValues(this, type: type);

  @override
  Position packed() => _start == 0 && _data.length == coordinateDimension
      ? this
      : Position.view(
          toFloatNNList(
            values,
            singlePrecision: _data is Float32List,
            valueCount: valueCount,
          ),
          type: type,
        );
}
