// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'spatial.dart';

/// `Point` is a read-only position with [x], [y], [z] and [m] coordinates.
///
/// The type [C] of coordinate values is either `num` (allowing `double` or
/// `int`), `double` or `int`.
///
/// All concrete implementations must contain at least [x] and [y] coordinate 
/// values, but [z] and [m] coordinates are optional (getters should return `0`
/// value when such a coordinate axis is not available).
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
abstract class Point<C extends num> extends Geometry
    with GeometryWritableMixin
    implements Position, _Coordinates, PointFactory, CoordinateWritable {
  /// Default `const` constructor to allow extending this abstract class.
  const Point();

  /// Create an empty point.
  factory Point.empty([Coords typeCoords]) = _PointEmpty<C>;

  @override
  Geom get typeGeom => Geom.point;

  @override
  int get dimension => 0;

  @override
  Bounds? get bounds => Bounds.of(min: this, max: this);

  @override
  Bounds? get boundsExplicit => Bounds.of(min: this, max: this);

  @override
  Point? get onePoint => this;

  /// A coordinate value by the index [i].
  ///
  /// The coordinate ordering is: (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  ///
  /// If a point represents geographic coordinates, then the ordering is:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  ///
  /// For easting (E) and northing (N) projected coordinates the ordering is
  /// (unless otherwise specified by a coordinate reference system):
  /// (E, N), (E, N, m), (E, N, z) or (E, N, z, m).
  C operator [](int i);

  /// Returns coordinate values of this point as a fixed length list.
  ///
  /// The default implementation creates a fixed length `List<C>` with
  /// length equaling to [coordinateDimension]. Then [] operator is used to
  /// populate coordinate values (see it's documentation for the coordinate
  /// ordering).
  ///
  /// Sub classes may override the default implementation to provide more
  /// efficient approach. It's also allowed to return internal data storage
  /// for coordinate values.
  List<C> get values =>
      // create fixed length list and set coordinate values on it
      List<C>.generate(coordinateDimension, (i) => this[i], growable: false);

  @override
  C get x;

  @override
  C get y;

  @override
  C get z => _zero();

  @override
  C get m => _zero();

  /// True if this point equals with [other] point in 2D by testing x and y.
  ///
  /// If [toleranceHoriz] is given, then differences on x and y coordinate
  /// values between this and [other] must be <= tolerance. Otherwise value
  /// must be exactly same.
  ///
  /// Tolerance values must be null or positive (>= 0).
  bool equals2D(Point other, {num? toleranceHoriz}) {
    assert(
      toleranceHoriz == null || toleranceHoriz >= 0.0,
      'Tolerance must be null or positive (>= 0)',
    );
    if (isEmpty || other.isEmpty) {
      return false;
    }
    return toleranceHoriz != null
        ? (x - other.x).abs() <= toleranceHoriz &&
            (y - other.y).abs() <= toleranceHoriz
        : x == other.x && y == other.y;
  }

  /// True if this point equals with [other] point in 3D by testing x, y and z.
  ///
  /// If [toleranceHoriz] is given, then differences on x and y coordinate
  /// values between this and [other] must be <= tolerance. Otherwise value
  /// must be exactly same.
  ///
  /// The tolerance for z coordinate values is given by an optional
  /// [toleranceVert] value.
  ///
  /// Tolerance values must be null or positive (>= 0).
  bool equals3D(Point other, {num? toleranceHoriz, num? toleranceVert}) {
    assert(
      toleranceVert == null || toleranceVert >= 0.0,
      'Tolerance must be null or positive (>= 0)',
    );
    if (!equals2D(other, toleranceHoriz: toleranceHoriz)) {
      return false;
    }
    return toleranceVert != null
        ? (z - other.z).abs() <= toleranceVert
        : z == other.z;
  }

  /// Returns zero value of the type [C] that can be `num`, `double` or `int`.
  C _zero() {
    if (C == int) {
      return 0 as C;
    } else {
      return 0.0 as C;
    }
  }

  /// Writes coordinate values to [buffer] separated by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// A sample with default parameters (for a 3D point):
  /// `10.1,20.3,30.3`
  ///
  /// To get WKT compatible text, set `delimiter` to ` `:
  /// `10.1 20.2 30.3`
  @override
  void writeValues(
    StringSink buffer, {
    String delimiter = ',',
    int? decimals,
  }) {
    for (var i = 0; i < coordinateDimension; i++) {
      if (i > 0) {
        buffer.write(delimiter);
      }
      if (decimals != null) {
        buffer.write(toStringAsFixedWhenDecimals(this[i], decimals));
      } else {
        buffer.write(this[i]);
      }
    }
  }

  /// A string representation of coordinate values separated by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// A sample with default parameters (for a 3D point):
  /// `10.1,20.3,30.3`
  ///
  /// To get WKT compatible text, set `delimiter` to ` `:
  /// `10.1 20.2 30.3`
  @override
  String valuesAsString({
    String delimiter = ',',
    int? decimals,
  }) {
    final buf = StringBuffer();
    writeValues(buf, delimiter: delimiter, decimals: decimals);
    return buf.toString();
  }

  /// A string representation of coordinate values separated by [delimiter].
  ///
  /// If [delimiter] is not provided, values are separated by whitespace. For
  /// example "10.1 20.2" is returned for a point with x=10.1 and y=20.2.
  ///
  /// Use [fractionDigits] to set a number of decimals to nums with decimals.
  @Deprecated('Use toStringAs() instead')
  String toText({
    String delimiter = ' ',
    int? fractionDigits,
  }) {
    final buf = StringBuffer();
    writeValues(buf, delimiter: delimiter, decimals: fractionDigits);
    return buf.toString();
  }

  @override
  void writeGeometries(GeometryWriter writer) => writer.geometry(
        type: Geom.point,
        coordinates: writeCoordinates,
        coordType: typeCoords,
      );

  @override
  void writeCoordinates(CoordinateWriter writer) => writer.coordPoint(
        x: x,
        y: y,
        z: is3D ? z : null,
        m: isMeasured ? m : null,
      );

  /// Copies this point with the compatible type and sets given coordinates.
  ///
  /// Optional [x], [y], [z] and [m] values, when given, override values of
  /// this point object. If the type of this point does not have a certain
  /// value, then it's ignored.
  Point copyWith({num? x, num? y, num? z, num? m});

  /// Returns a new point transformed from this point using [transform].
  ///
  /// The transformed point object must be of the type with same coordinate
  /// value members as this object has.
  @override
  Point transform(TransformPoint transform);

  /// Returns a new point projected from this point using [projection].
  ///
  /// When [to] is provided, then target points of [R] are created using
  /// that as a point factory. Otherwise [projection] uses it's own factory.
  @override
  R project<R extends Point>(
    Projection<R> projection, {
    PointFactory<R>? to,
  }) =>
      projection.projectPoint(this, to: to);
}

/// A private implementation for an empty point with coordinate zero values.
/// The implementation may change in future.
@immutable
class _PointEmpty<C extends num> extends Point<C> with EquatableMixin {
  const _PointEmpty([this.typeCoords = Coords.xy]);

  @override
  bool get is3D => typeCoords.is3D;

  @override
  bool get isMeasured => typeCoords.isMeasured;

  @override
  final Coords typeCoords;

  @override
  Bounds? get bounds => null;

  @override
  Bounds? get boundsExplicit => null;

  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;

  @override
  int get coordinateDimension => spatialDimension + (isMeasured ? 1 : 0);

  @override
  int get spatialDimension => is3D ? 3 : 2;

  @override
  C operator [](int i) => _zero();

  @override
  C get x => _zero();

  @override
  C get y => _zero();

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => this;

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) => this;

  @override
  Point copyWith({num? x, num? y, num? z, num? m}) => this;

  @override
  Point transform(TransformPoint transform) => this;

  @override
  R project<R extends Point>(
    Projection<R> projection, {
    PointFactory<R>? to,
  }) =>
      throw const FormatException('Cannot project empty point.');

  @override
  String toString() => valuesAsString();

  @override
  List<Object?> get props => [is3D, isMeasured];
}
