// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'spatial.dart';

/// A base interface for bounds (aka a bounding box in 2D).
abstract class Bounds<T extends Point> extends Bounded
    implements _Coordinates, CoordinateFactory<Bounds<T>>, ProjBox {
  /// Default `const` constructor to allow extending this abstract class.
  const Bounds();

  /// Create bounds with required (and non-empty) [min] and [max] points.
  factory Bounds.of({required T min, required T max}) = BoundsBase;

  /// Create [Bounds] from [values] with two points (both a list of nums).
  factory Bounds.make(
    Iterable<Iterable<num>> values,
    PointFactory<T> pointFactory,
  ) =>
      Bounds<T>.of(
        min: pointFactory.newFrom(values.elementAt(0)),
        max: pointFactory.newFrom(values.elementAt(1)),
      );

  /// Create [Bounds] parsed from [text] with two points.
  ///
  /// If [parser] is null, then WKT [text] like "25.1 53.1, 25.2 53.2" is
  /// expected.
  factory Bounds.parse(
    String text,
    PointFactory<T> pointFactory, {
    ParseCoordsList? parser,
  }) {
    if (parser != null) {
      final coordsList = parser.call(text);
      return Bounds<T>.make(coordsList, pointFactory);
    } else {
      final points = parseWktPointSeries(text, pointFactory);
      return Bounds<T>.of(min: points[0], max: points[1]);
    }
  }

  /// Creates [Bounds] from [coords] using [pointFactory].
  static Bounds<T> fromCoords<T extends Point>(
    Iterable<num> coords, {
    required PointFactory<T> pointFactory,
    int? offset,
    int? length,
  }) {
    CoordinateFactory.checkCoords(4, coords, offset: offset, length: length);
    final start = offset ?? 0;
    final len = length ?? coords.length;
    final pointLen = len ~/ 2;
    return Bounds<T>.of(
      min: pointFactory.newFrom(
        coords,
        offset: start,
        length: pointLen,
      ),
      max: pointFactory.newFrom(
        coords,
        offset: start + pointLen,
        length: pointLen,
      ),
    );
  }

  @override
  T get min;

  @override
  T get max;

  @override
  Iterable<T> get corners2D => Box.createCorners2D(
        this,
        ({required num x, required num y, num? z, num? m}) =>
            min.newWith(x: x, y: y, z: z, m: m) as T,
      );

  @override
  num get minX => min.x;

  @override
  num get minY => min.y;

  @override
  num? get minZ => min.optZ;

  @override
  num? get minM => min.optM;

  @override
  num get maxX => max.x;

  @override
  num get maxY => max.y;

  @override
  num? get maxZ => max.optZ;

  @override
  num? get maxM => max.optM;

  @override
  int get coordinateDimension => min.coordinateDimension;

  @override
  int get spatialDimension => min.spatialDimension;

  /// True for geographic coordinates (with longitude and latitude).
  ///
  /// If false is returned, then coordinates are projected or cartesian (with
  /// x and y).
  bool get isGeographic => min.isGeographic;

  @override
  bool get is3D => min.is3D;

  @override
  bool get isMeasured => min.isMeasured;

  @override
  Coords get type => min.type;

  /// Writes coordinate values to [buffer] separated by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// A sample with default parameters (for a 2D bounding box):
  /// `10.1,10.1,20.2,20.2`
  @override
  void writeValues(
    StringSink buffer, {
    String delimiter = ',',
    int? decimals,
  }) {
    min.writeValues(
      buffer,
      delimiter: delimiter,
      decimals: decimals,
    );
    buffer.write(delimiter);
    max.writeValues(
      buffer,
      delimiter: delimiter,
      decimals: decimals,
    );
  }

  /// Returns coordinate values as a string separated by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// A sample with default parameters (for a 2D bounding box):
  /// `10.1,10.1,20.2,20.2`
  @override
  String valuesAsString({String delimiter = ',', int? decimals}) {
    final buf = StringBuffer();
    writeValues(buf, delimiter: delimiter, decimals: decimals);
    return buf.toString();
  }

  /// Writes this bounds object to [output].
  void writeTo(CoordinateContent output) => output.bounds(this);

  /// Returns new bounds transformed from this bounds using [transform].
  @override
  Bounds<T> transform(TransformPosition transform);

  @override
  Bounds<R> project<R extends Point>(
    Projection projection, {
    required CreatePosition<R> to,
  });

  @override
  bool intersects2D(Box other) => Box.testIntersects2D(this, other);

  @override
  bool intersects(Box other) => Box.testIntersects(this, other);

  @override
  bool intersectsPoint2D(Position point) =>
      Box.testIntersectsPoint2D(this, point);

  @override
  bool intersectsPoint(Position point) => Box.testIntersectsPoint(this, point);
}

/// An immutable bounds with min and max points for limits.
@immutable
class BoundsBase<T extends Point> extends Bounds<T> {
  /// Create bounds with required (and non-empty) [min] and [max] points.
  const BoundsBase({required T min, required T max})
      : _min = min,
        _max = max;

  final T _min, _max;

  @override
  T get min => _min;

  @override
  T get max => _max;

  @override
  Bounds<T> get bounds => this;

  @override
  Bounds<T>? get boundsExplicit => this;

  @override
  Bounds<T> newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(4, coords, offset: offset, length: length);
    final start = offset ?? 0;
    final len = length ?? coords.length;
    final pointLen = len ~/ 2;
    return BoundsBase(
      min: min.newFrom(coords, offset: start, length: pointLen) as T,
      max: max.newFrom(coords, offset: start + pointLen, length: pointLen) as T,
    );
  }

  @override
  R copyTo<R extends Box>(CreateBox<R> factory) => factory.call(
        minX: minX,
        minY: minY,
        minZ: minZ,
        minM: minM,
        maxX: maxX,
        maxY: maxY,
        maxZ: maxZ,
        maxM: maxM,
      );

  @override
  Bounds<T> transform(TransformPosition transform) => BoundsBase(
        min: min.transform(transform) as T,
        max: max.transform(transform) as T,
      );

  @override
  Bounds<R> project<R extends Point>(
    Projection projection, {
    required CreatePosition<R> to,
  }) =>
      BoundsBase(
        min: min.project(projection, to: to),
        max: max.project(projection, to: to),
      );

  @override
  String toString() => valuesAsString();

  @override
  bool operator ==(Object other) =>
      other is Bounds && Box.testEquals(this, other);

  @override
  int get hashCode => Box.hash(this);

  @override
  bool equals2D(Box other, {num? toleranceHoriz}) =>
      Box.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  @override
  bool equals3D(
    Box other, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) =>
      Box.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );
}
