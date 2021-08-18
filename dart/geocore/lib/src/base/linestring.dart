// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// The type for the line string.
enum LineStringType {
  /// Any line string (simple or non-simple, closed or non-closed, empty).
  any,

  /// A linear ring (that is a simple closed line string, or empty one).
  ring
}

/// A line string containing a chain of points.
@immutable
class LineString<T extends Point> extends Geometry with EquatableMixin {
  /// Create [LineString] from [chain] of points conforming by [type].
  LineString(this.chain, {this.type = LineStringType.any}) {
    validate();
  }

  /// Create [LineString] from [chain] of points (0 or >= 2 items).
  factory LineString.any(PointSeries<T> chain) => LineString<T>(chain);

  /// Create a linear ring from a closed and simple [chain] of points.
  ///
  /// There must be zero or at least four points in the chain.
  factory LineString.ring(PointSeries<T> chain) =>
      LineString<T>(chain, type: LineStringType.ring);

  /// Create [LineString] from [values] with a chain of points.
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory LineString.make(
          Iterable<Iterable<num>> values, PointFactory<T> pointFactory,
          {LineStringType type = LineStringType.any, Bounds? bounds}) =>
      LineString<T>(PointSeries<T>.make(values, pointFactory, bounds: bounds),
          type: type);

  /// Create [LineString] parsed from [text] with a chain of points.
  ///
  /// If [parser] is null, then WKT [text] like "25.1 53.1, 25.2 53.2" is
  /// expected.
  ///
  /// Throws FormatException if cannot parse.
  factory LineString.parse(String text, PointFactory<T> pointFactory,
          {LineStringType type = LineStringType.any,
          ParseCoordsList? parser}) =>
      parser != null
          ? LineString<T>.make(parser.call(text), pointFactory, type: type)
          : parseWktLineString<T>(text, pointFactory, type: type);

  /// Throws if [chain] and [type] contains values not valid for a line string.
  /// 
  /// This method is designed to be used only on constructors.
  @protected
  void validate() {
    if (chain.isEmpty) return;
    switch (type) {
      case LineStringType.ring:
        if (chain.length < 4) {
          throw ArgumentError('A linear ring must have 0 or >= 4 points.');
        }
        if (!chain.isClosed) {
          throw ArgumentError('A linear ring must be closed.');
        }
        break;
      default:
        if (chain.length < 2) {
          throw ArgumentError('LineString must have 0 or >= 2 points.');
        }
        break;
    }
  }

  /// The [type] of this line string.
  final LineStringType type;

  /// The [chain] of points forming this line string.
  final PointSeries<T> chain;

  @override
  int get dimension => type == LineStringType.ring ? 2 : 1;

  @override
  bool get isEmpty => chain.isEmpty;

  @override
  Bounds get bounds => chain.bounds;

  @override
  List<Object?> get props => [chain];
}
