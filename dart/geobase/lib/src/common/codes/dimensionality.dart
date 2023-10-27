// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enum for *dimensionality* or *topological dimension* in the context of
/// geospatial applications.
enum Dimensionality {
  /// A dimensionality representing a *punctual* geometry (or position, point,
  /// vertex, node, marker etc.) with the topological dimension of `0`.
  punctual(0),

  /// A dimensionality representing a *linear* geometry (or chain, line string,
  /// polyline, path, curve etc.) with the topological dimension of `1`.
  linear(1),

  /// A dimensionality representing an *areal* geometry (or polygon, area,
  /// surface, box etc.) with the topological dimension of `2`.
  areal(2),

  /// A dimensionality representing a *volymetric* geometry (or tetrahedron,
  /// polyhedron, volyme, cube etc.) with the topological dimension of `3`.
  volymetric(3);

  const Dimensionality(this.topologicalDimension);

  /// The topological dimension (`0`: punctual, `1`: linear, `2`: areal,
  /// `3`: volymetric).
  final int topologicalDimension;
}
