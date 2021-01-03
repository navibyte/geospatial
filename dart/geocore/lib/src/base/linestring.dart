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
  int get dimension => type == LineStringType.ring ? 2 : 1;

  @override
  bool get isEmpty => chain.isEmpty;

  @override
  Bounds get bounds => chain.bounds;

  @override
  List<Object?> get props => [chain];
}
