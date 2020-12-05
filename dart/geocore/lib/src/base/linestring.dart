// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

import 'geometry.dart';
import 'point.dart';
import 'point_series.dart';

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
  /// Creates a line string from [chain] of points conforming by [type].
  LineString(this.chain, {this.type = LineStringType.any}) {
    validate();
  }

  /// Creates a line string from [chain] of points (0 or >= 2 items).
  factory LineString.any(PointSeries<T> chain) =>
      LineString(chain, type: LineStringType.any);

  /// Creates a linear ring from a closed and simple [chain] of points.
  ///
  /// There must be zero or at least four points in the chain.
  factory LineString.ring(PointSeries<T> chain) =>
      LineString(chain, type: LineStringType.ring);

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
  int get dimension => 1;

  @override
  bool get isEmpty => chain.isEmpty;

  @override
  List<Object?> get props => [chain];
}

/// A series of line strings.
abstract class LineStringSeries<T extends Point> extends GeomSeries<LineString<T>> {
  const LineStringSeries();

  /// Create an unmodifiable [LineStringSeries] backed by [source].
  factory LineStringSeries.view(Iterable<LineString<T>> source) =
      LineStringSeriesView<T>;

  /// Create an immutable [LineStringSeries] copied from [elements].
  factory LineStringSeries.from(Iterable<LineString<T>> elements) =>
      LineStringSeries<T>.view(List<LineString<T>>.unmodifiable(elements));
}

/// A partial implementation of [LineStringSeries] as a mixin.
mixin LineStringSeriesMixin<T extends Point> implements LineStringSeries<T> {
  @override
  int get dimension => 1;
}

/// An unmodifiable [LineStringSeries] backed by another list.
@immutable
class LineStringSeriesView<T extends Point> extends GeomSeriesView<LineString<T>>
    with LineStringSeriesMixin<T>
    implements LineStringSeries<T> {
  /// Create an unmodifiable [LineStringSeries] backed by [source].
  LineStringSeriesView(Iterable<LineString<T>> source) : super(source);
}
