// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A function to project the [source] point to a point of [R].
///
/// When [to] is provided, then target points of [R] are created using that
/// as a point factory. Otherwise a projection function uses it's own factory.
///
/// Note that a function could implement for example a map projection from
/// geographical points to projected cartesian points, or an inverse
/// projection (or an "unprojection") from projected cartesian points to
/// geographical points. Both are called here "project point" functions.
///
/// Throws FormatException if cannot project.
typedef ProjectPoint<R extends Point> = R Function(
  Point source, {
  PointFactory<R>? to,
});

/// A projection adapter bundles forward and inverse projections.
///
/// Using [FromPoint] and [ToPoint] it's possible to specify more accurate
/// `Point` class type be used on an adapter implementation.
///
/// The [FromPoint] type specifies a type for source points of `forward` and
/// target points of `inverse` projections.
///
/// The [ToPoint] type specifies a type for target points of `forward` and
/// source points of `inverse` projections.
mixin ProjectionAdapter<FromPoint extends Point, ToPoint extends Point> {
  /// The source coordinate reference system (or projection), ie. "EPSG:4326".
  String get fromCrs;

  /// The target coordinate reference system (or projection), ie. "EPSG:3857".
  String get toCrs;

  /// Returns a projection function projecting from [fromCrs] to [toCrs].
  ///
  /// By default, result points of [R] are created using [factory]. This can be
  /// overridden by giving another factory when calling a projection function.
  ProjectPoint<R> forward<R extends ToPoint>(PointFactory<R> factory);

  /// Returns a projection function unprojecting from [toCrs] to [fromCrs].
  ///
  /// By default, result points of [R] are created using [factory]. This can be
  /// overridden by giving another factory when calling a projection function.
  ProjectPoint<R> inverse<R extends FromPoint>(PointFactory<R> factory);
}
