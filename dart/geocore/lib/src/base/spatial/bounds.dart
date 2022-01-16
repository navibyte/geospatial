// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'spatial.dart';

/// A function to calculate bounds for some object like a geometry.
typedef CalculateBounds<T extends Point> = Bounds<T> Function();

/// A base interface for bounds (aka a bounding box in 2D).
abstract class Bounds<T extends Point> extends Geometry
    implements _Coordinates, CoordinateFactory<Bounds<T>> {
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

  /// Return an [empty] bounds that does not intersect with any other bounds.
  static Bounds empty() => _emptyBounds;

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

  /// Minimum point of bounds.
  T get min;

  /// Maximum point of bounds.
  T get max;

  @override
  Bounds<T> get bounds => this;

  @override
  int get dimension => 1;

  @override
  int get coordinateDimension =>
      math.min(min.coordinateDimension, max.coordinateDimension);

  @override
  int get spatialDimension =>
      math.min(min.spatialDimension, max.spatialDimension);

  @override
  bool get is3D => min.is3D && max.is3D;

  @override
  bool get hasM => min.hasM && max.hasM;

  @override
  void writeValues(
    StringSink buf, {
    String delimiter = ',',
    int? fractionDigits,
  }) {
    min.writeValues(buf, delimiter: delimiter, fractionDigits: fractionDigits);
    buf.write(delimiter);
    max.writeValues(buf, delimiter: delimiter, fractionDigits: fractionDigits);
  }

  @override
  String valuesAsString({String delimiter = ',', int? fractionDigits}) {
    final buf = StringBuffer();
    writeValues(buf, delimiter: delimiter, fractionDigits: fractionDigits);
    return buf.toString();
  }

  /// Returns new bounds transformed from this bounds using [transform].
  @override
  Bounds<T> transform(TransformPoint transform);

  @override
  Bounds<R> project<R extends Point>(
    Projection<R> projection, {
    PointFactory<R>? to,
  });

  /// Returns true if this bounds intesects with [other] bounds in 2D.
  ///
  /// Only X ja Y are compared on intersection calculation.
  ///
  /// If this bounds or [other] bounds is empty, then always return false.
  bool intersects2D(Bounds other) {
    if (isEmpty || other.isEmpty) return false;
    return !(min.x > other.max.x ||
        max.x < other.min.x ||
        min.y > other.max.y ||
        max.y < other.min.y);
  }

  /// Returns true if this bounds intesects with [other] bounds.
  ///
  /// X ja Y are always compared on intersection calculation. Z is compared only
  /// if this and [other] bounds has 3D coordinates. M is compared only if this
  /// and [other] bounds has M coordinate values.
  ///
  /// If this bounds or [other] bounds is empty, then always return false.
  bool intersects(Bounds other) {
    if (isEmpty || other.isEmpty) return false;
    if (min.x > other.max.x ||
        max.x < other.min.x ||
        min.y > other.max.y ||
        max.y < other.min.y) {
      return false;
    }
    if (is3D && other.is3D && min.z > other.max.z || max.z < other.min.z) {
      return false;
    }
    if (hasM && other.hasM && min.m > other.max.m || max.m < other.min.m) {
      return false;
    }
    return true;
  }

  /// Returns true if this bounds intesects with [point] in 2D.
  ///
  /// Only X ja Y are compared on intersection calculation.
  ///
  /// If this bounds or [point] is empty, then always return false.
  bool intersectsPoint2D(Point point) {
    if (isEmpty || point.isEmpty) return false;
    return !(min.x > point.x ||
        max.x < point.x ||
        min.y > point.y ||
        max.y < point.y);
  }

  /// Returns true if this bounds intesects with [point].
  ///
  /// X ja Y are always compared on intersection calculation. Z is compared only
  /// if this bounds and [point] has 3D coordinates. M is compared only if this
  /// bounds and [point] has M coordinate values.
  ///
  /// If this bounds or [point] is empty, then always return false.
  bool intersectsPoint(Point point) {
    if (isEmpty || point.isEmpty) return false;
    if (min.x > point.x ||
        max.x < point.x ||
        min.y > point.y ||
        max.y < point.y) {
      return false;
    }
    if (is3D && point.is3D && min.z > point.z || max.z < point.z) {
      return false;
    }
    if (hasM && point.hasM && min.m > point.m || max.m < point.m) {
      return false;
    }
    return true;
  }
}

/// An immutable bounds with min and max points for limits.
@immutable
class BoundsBase<T extends Point> extends Bounds<T> with EquatableMixin {
  /// Create bounds with required (and non-empty) [min] and [max] points.
  const BoundsBase({required T min, required T max})
      : _min = min,
        _max = max;

  final T _min, _max;

  @override
  List<Object?> get props => [_min, _max];

  @override
  bool get isEmpty => false;

  @override
  T get min => _min;

  @override
  T get max => _max;

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
  Bounds<T> transform(TransformPoint transform) => BoundsBase(
        min: min.transform(transform) as T,
        max: max.transform(transform) as T,
      );

  @override
  Bounds<R> project<R extends Point>(
    Projection<R> projection, {
    PointFactory<R>? to,
  }) =>
      BoundsBase(
        min: min.project(projection, to: to),
        max: max.project(projection, to: to),
      );

  @override
  String toString() => valuesAsString();
}

/// [Bounds] with values calculated when first needed if not initialized.
class _LazyBounds<T extends Point> extends Bounds<T> {
  /// Bounds with nullable [bounds] and a mechanism to [calculate] as needed.
  ///
  /// You must provide either [bounds] or [calculate], both of them cannot be
  /// null.
  _LazyBounds(Bounds<T>? bounds, CalculateBounds<T>? calculate)
      : _bounds = _validate<T>(bounds, calculate),
        _calculate = calculate;

  /// Initially unset bounds, but with a mechanism to [calculate] it as needed.
  factory _LazyBounds.calculate(CalculateBounds<T> calculate) =>
      _LazyBounds(null, calculate);

  static Bounds<T>? _validate<T extends Point>(
    Bounds<T>? bounds,
    final CalculateBounds<T>? calculate,
  ) {
    if (bounds == null && calculate == null) {
      throw ArgumentError('You must provide either bounds or calculate!');
    }
    return bounds;
  }

  Bounds<T>? _bounds;

  final CalculateBounds<T>? _calculate;

  Bounds<T> _ensureBounds() => _bounds ??= _calculate!.call();

  @override
  bool get isEmpty => false;

  @override
  T get min => _ensureBounds().min;

  @override
  T get max => _ensureBounds().max;

  @override
  Bounds<T> newFrom(Iterable<num> coords, {int? offset, int? length}) =>
      _ensureBounds().newFrom(coords, offset: offset, length: length);

  @override
  Bounds<T> transform(TransformPoint transform) =>
      _ensureBounds().transform(transform);

  @override
  Bounds<R> project<R extends Point>(
    Projection<R> projection, {
    PointFactory<R>? to,
  }) =>
      _ensureBounds().project(projection, to: to);

/*
  // See lint => avoid_equals_and_hash_code_on_mutable_classes

  @override
  bool operator ==(Object other) => _ensureBounds() == other;

  @override
  int get hashCode => _ensureBounds().hashCode;
*/

  @override
  String toString() => valuesAsString();
}

const _emptyBounds = _EmptyBounds();

@immutable
class _EmptyBounds extends Bounds with EquatableMixin {
  const _EmptyBounds();

  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;

  @override
  Point get min => Point.empty();

  @override
  Point get max => Point.empty();

  @override
  Bounds newFrom(Iterable<num> coords, {int? offset, int? length}) => this;

  @override
  Bounds transform(TransformPoint transform) => this;

  @override
  Bounds<R> project<R extends Point>(
    Projection<R> projection, {
    PointFactory<R>? to,
  }) =>
      throw const FormatException('Cannot project empty bounds.');

  @override
  String toString() => valuesAsString();

  @override
  List<Object?> get props => [];
}
