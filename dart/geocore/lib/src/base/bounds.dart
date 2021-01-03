// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A function to calculate bounds for some object like a geometry.
typedef CalculateBounds<T extends Point> = Bounds<T> Function();

/// A base interface for bounds (aka a bounding box in 2D).
abstract class Bounds<T extends Point> extends Geometry
    implements _Coordinates {
  const Bounds();

  /// Create bounds with required (and non-empty) [min] and [max] points.
  factory Bounds.of({required T min, required T max}) = BoundsBase;

  /// Return an [empty] bounds that does not intersect with any other bounds.
  static Bounds empty() => _emptyBounds;

  /// Minimum point of bounds.
  T get min;

  /// Maximum point of bounds.
  T get max;

  @override
  Bounds get bounds => this;

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
      Bounds<T>? bounds, final CalculateBounds<T>? calculate) {
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
  bool operator ==(Object other) => _ensureBounds() == other;

  @override
  int get hashCode => _ensureBounds().hashCode;
}

const _emptyBounds = _EmptyBounds();

@immutable
class _EmptyBounds extends Bounds {
  const _EmptyBounds();

  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;

  @override
  Point get min => Point.empty();

  @override
  Point get max => Point.empty();
}

/// A helper class to calculate [bounds] for a set of points and other bounds.
///
/// Use [addPoint] and [addBounds] methods to add geometries to be used on
/// calculation. A value for calculations can be obtained from [bounds].
class _BoundsBuilder {
  /// Creates a new builder to calculate [bounds].
  _BoundsBuilder();

  int _spatialDims = 0;
  bool _hasM = false;
  Point? _firstOfType;

  double _minx = double.nan;
  double _miny = double.nan;
  double _minz = double.nan;
  double _minm = double.nan;
  double _maxx = double.nan;
  double _maxy = double.nan;
  double _maxz = double.nan;
  double _maxm = double.nan;

  /// Adds a [point] to be used on bounds calculation.
  void addPoint(Point point) {
    var sdims = _spatialDims;
    if (point.spatialDimension > sdims) {
      // latest point has more spatial dims than previous ones, so update
      sdims = _spatialDims = point.spatialDimension;
      _firstOfType = point;
      _hasM = point.hasM;
    } else if (point.spatialDimension == sdims && (!_hasM && point.hasM)) {
      // or it has same amount of spatial dims but has also M coordinate
      _hasM = true;
      _firstOfType = point;
    }

    // update min and max values
    _minx = _min(_minx, point.x);
    _miny = _min(_miny, point.y);
    _maxx = _max(_maxx, point.x);
    _maxy = _max(_maxy, point.y);
    if (sdims >= 3) {
      _minz = _min(_minz, point.z);
      _maxz = _max(_maxz, point.z);
    }
    if (_hasM) {
      _minm = _min(_minm, point.m);
      _maxm = _max(_maxm, point.m);
    }
  }

  static double _min(double min, double value) =>
      min.isNaN ? value : math.min(min, value);

  static double _max(double max, double value) =>
      max.isNaN ? value : math.max(max, value);

  /// Adds a [bounds] to be used on bounds calculation.
  void addBounds(Bounds bounds) {
    addPoint(bounds.min);
    addPoint(bounds.max);
  }

  /// The bounds for the current set of added points and bounds.
  Bounds get bounds {
    final p = _firstOfType;
    if (p != null) {
      if (_spatialDims == 2) {
        return !_hasM
            ? Bounds.of(
                min: p.newPoint(x: _minx, y: _miny),
                max: p.newPoint(x: _maxx, y: _maxy))
            : Bounds.of(
                min: p.newPoint(x: _minx, y: _miny, m: _minm),
                max: p.newPoint(x: _maxx, y: _maxy, m: _maxm));
      } else if (_spatialDims >= 3) {
        return !_hasM
            ? Bounds.of(
                min: p.newPoint(x: _minx, y: _miny, z: _minz),
                max: p.newPoint(x: _maxx, y: _maxy, z: _maxz))
            : Bounds.of(
                min: p.newPoint(x: _minx, y: _miny, z: _minz, m: _minm),
                max: p.newPoint(x: _maxx, y: _maxy, z: _maxz, m: _maxm));
      }
    }
    // couldn't calculate, return empty bounds
    return Bounds.empty();
  }
}
