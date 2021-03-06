// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A base interface for a series of points with getters to access point items.
///
/// A series of points could represents a geometry path, a line string,
/// an outer or inner linear ring of a polygon, a multi point, a vertex array or
/// any other collection for points.
abstract class PointSeries<T extends Point>
    extends _BatchedSeries<PointSeries<T>, T> {
  const PointSeries();

  /// Create a [PointSeries] instance backed by [source].
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory PointSeries.view(Iterable<T> source, {Bounds? bounds}) =
      _PointSeriesView<T>;

  /// Create an immutable [PointSeries] with points copied from [source].
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory PointSeries.from(Iterable<T> source, {Bounds? bounds}) =>
      PointSeries<T>.view(List<T>.unmodifiable(source), bounds: bounds);

  /// Create [PointSeries] from [values] with a list of points.
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory PointSeries.make(
          Iterable<Iterable<num>> values, PointFactory<T> pointFactory,
          {Bounds? bounds}) =>
      PointSeries<T>.from(
          values.map<T>((coords) => pointFactory.newFrom(coords)),
          bounds: bounds);

  /// Create [PointSeries] parsed from [text] with a list of points.
  ///
  /// If [parser] is null, then WKT [text] like "25.1 53.1, 25.2 53.2" or
  /// "(25.1 53.1), (25.2 53.2)" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory PointSeries.parse(String text, PointFactory<T> pointFactory,
          {ParseCoordsList? parser}) =>
      parser != null
          ? PointSeries<T>.make(parser.call(text), pointFactory)
          : parseWktPointSeries<T>(text, pointFactory);

  /// X coordinate as num at [index].
  ///
  /// Throws RangeError if [index] is out of bounds.
  num x(int index);

  /// Y coordinate as num at [index].
  ///
  /// Throws RangeError if [index] is out of bounds.
  num y(int index);

  /// Z coordinate as num at [index].
  ///
  /// Returns zero if Z is not available when an [index] >= 0 and < [length].
  ///
  /// Throws RangeError if [index] is out of bounds.
  num z(int index) => 0.0;

  /// M coordinate as num at [index].
  ///
  /// Returns zero if M is not available when an [index] >= 0 and < [length].
  ///
  /// [m] represents a value on a linear referencing system (like time).
  /// Could be associated with a 2D point (x, y, m) or a 3D point (x, y, z, m).
  ///
  /// Throws RangeError if [index] is out of bounds.
  num m(int index) => 0.0;

  /// True if the first and last point equals in 2D.
  bool get isClosed;
}

/// A partial implementation of [PointSeries] as a mixin.
mixin PointSeriesMixin<T extends Point> implements PointSeries<T> {
  @override
  bool get isClosed => length >= 2 && first.equals2D(last);

  @override
  num x(int index) => this[index].x;

  @override
  num y(int index) => this[index].y;

  @override
  num z(int index) => this[index].z;

  @override
  num m(int index) => this[index].m;

  /// Initializes a [Bounds] object for [source] points.
  ///
  /// If [bounds] is non-null, then it's returned as is.
  ///
  /// In other cases the current implementation returns a [_LazyBounds]
  /// instance with bounds lazy calculated when first needed. However this
  /// implementation can internally be optimized in future (ie. bounds for
  /// small series of points is initialized right a way, and for large
  /// series with lazy calculations).
  @protected
  static Bounds initBounds<T extends Point>(Iterable<T> source,
          {Bounds? bounds}) =>
      bounds ??
      _LazyBounds.calculate(() {
        final builder = BoundsBuilder();
        source.forEach(builder.addPoint);
        return builder.bounds;
      });
}

/// Private implementation of [PointSeries].
/// The implementation may change in future.
class _PointSeriesView<T extends Point>
    extends _BatchedSeriesView<PointSeries<T>, T> with PointSeriesMixin<T> {
  _PointSeriesView(Iterable<T> source, {Bounds? bounds})
      : super(source,
            bounds: PointSeriesMixin.initBounds<T>(source, bounds: bounds));

  @override
  PointSeries<T> intersectByBounds(Bounds bounds) =>
      _PointSeriesView(where((point) => bounds.intersectsPoint(point)));

  @override
  PointSeries<T> intersectByBounds2D(Bounds bounds) =>
      _PointSeriesView(where((point) => bounds.intersectsPoint2D(point)));
}
