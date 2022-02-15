// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/base/coordinates.dart';

/// A mixin defining an interface for (geospatial) projections.
///
/// A class that implements this mixin may provide for example a map projection
/// from geographical positions to projected cartesian positions, or an inverse
/// projection (or an "unprojection") from projected cartesian positions to
/// geographical positions. Both are called simply "projections" here.
///
/// The mixin specifies only `projectPosition` function, but it can be extended
/// in future to project using other data structures than positions also. If
/// extended, then the mixin provides a default implementation for any new
/// methods.
mixin Projection<R extends BasePosition> {
  /// Projects the [source] position to a position of [R].
  ///
  /// When [to] is provided, then target positions of [R] are created using that
  /// as a factory function. Otherwise a projection uses it's own factory.
  ///
  /// Throws FormatException if cannot project.
  R project(BasePosition source, {CreatePosition<R>? to});
}
