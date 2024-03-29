// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
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
    implements Projected, _Coordinates, PointFactory {
  /// Default `const` constructor to allow extending this abstract class.
  const Point();

  @override
  Geom get typeGeom => Geom.point;

  @override
  int get dimension => 0;

  @override
  @nonVirtual
  bool get isEmpty => false;

  @override
  @nonVirtual
  bool get isNotEmpty => true;

  @override
  Bounds? get bounds => Bounds.of(min: this, max: this);

  @override
  Bounds? get boundsExplicit => null;

  @override
  Point? get onePoint => this;

  /// A coordinate value by the coordinate axis index [i].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  @override
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
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, m), (x, y, z) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, m), (lon, lat, elev) or (lon, lat, elev, m).
  @override
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

  @override
  C? get optZ => null;

  @override
  C? get optM => null;

  /// Returns zero value of the type [C] that can be `num`, `double` or `int`.
  C _zero() {
    if (C == int) {
      return 0 as C;
    } else {
      return 0.0 as C;
    }
  }

  /// True for geographic coordinates (with longitude and latitude).
  ///
  /// If false is returned, then coordinates are projected or cartesian (with
  /// x and y).
  bool get isGeographic;

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

  @override
  void writeTo(SimpleGeometryContent writer) =>
      writer.point(Position.getDoubleList(this), type: type);

  @override
  R copyTo<R extends Position>(CreatePosition<R> factory) =>
      factory.call(x: x, y: y, z: optZ, m: optM);

  /// Copies this point with optional [x], [y], [z] and [m] overriding values.
  ///
  /// The copied point is compatible by coordinate type with this point.
  ///
  /// Optional [x], [y], [z] and [m] values, when given, override values of
  /// this point object. If the type of this point does not have a certain
  /// value, then it's ignored.
  @override
  Point copyWith({num? x, num? y, num? z, num? m});

  /// Returns a new point transformed from this point using [transform].
  ///
  /// The transformed point object must be of the type with same coordinate
  /// value members as this object has.
  @override
  Point transform(TransformPosition transform);

  /// Returns a new point projected from this point using [projection].
  ///
  /// Target points of [R] are created using [to] as a point factory.
  @override
  R project<R extends Point>(
    Projection projection, {
    required CreatePosition<R> to,
  }) =>
      projection.project(this, to: to);

  @override
  bool equals2D(Position other, {num? toleranceHoriz}) =>
      Position.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  @override
  bool equals3D(
    Position other, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) =>
      Position.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );
}
