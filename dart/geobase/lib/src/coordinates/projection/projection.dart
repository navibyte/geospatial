// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_series.dart';

/// A mixin defining an interface for (geospatial) projections.
///
/// A class that implements this mixin may provide for example a map projection
/// from geographic positions to projected positions, or an inverse projection
/// (or an "unprojection") from projected positions to geographic positions.
/// Both are called simply "projections" here.
mixin Projection {
  /// Projects the [source] position to a position of [T] using [to] as a
  /// factory.
  ///
  /// Throws FormatException if cannot project.
  T project<T extends Position>(
    Position source, {
    required CreatePosition<T> to,
  });

  /// Projects positions from [source] and returns a list of projected values.
  ///
  /// Use the required [type] to explicitely specify the type of coordinates.
  ///
  /// The [source] array contains coordinate values of positions as a flat
  /// structure. For example for `Coords.xyz` the first three coordinate values
  /// are x, y and z of the first position, the next three coordinate values are
  /// x, y and z of the second position, and so on.
  ///
  /// The length of the [target] array, when given, must be exactly same as the
  /// length of the [source] array, and [target] must be a mutable list. If
  /// [target] is null, then a new list instance is created.
  ///
  /// Throws FormatException if cannot project.
  List<double> projectCoords(
    Iterable<double> source, {
    List<double>? target,
    required Coords type,
  });

  /// Projects the [source] position to a position of [Position].
  ///
  /// Throws FormatException if cannot project.
  Position projectPosition(Position source) =>
      project(source, to: Position.create);

  /// Projects positions from [source] and returns a series of projected
  /// positions.
  ///
  /// Throws FormatException if cannot project.
  PositionSeries projectSeries(PositionSeries source) => PositionSeries.view(
        projectCoords(source.values, type: source.type),
        type: source.type,
      );
}
