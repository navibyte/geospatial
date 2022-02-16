// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/geobase.dart';

import '/src/base/spatial.dart';

/// A read-only projected (or cartesian) point with [x], [y], [z] and [m].
///
/// Coordinate values of type [C] are either `num` (allowing `double` or `int`),
/// `double` or `int`.
abstract class ProjectedPoint<C extends num> extends Point<C> {
  /// Default `const` constructor to allow extending this abstract class.
  const ProjectedPoint();

  @override
  ProjectedPoint copyWith({num? x, num? y, num? z, num? m});

  @override
  ProjectedPoint newWith({num x = 0.0, num y = 0.0, num? z, num? m});

  @override
  ProjectedPoint newFrom(Iterable<num> coords, {int? offset, int? length});

  @override
  ProjectedPoint transform(TransformPosition transform);

  @override
  bool get isGeographic => false;

  @override
  bool operator ==(Object other) =>
      other is Point &&
      isGeographic == other.isGeographic &&
      Projected.testEquals(this, other);

  @override
  int get hashCode => Projected.hash(this);

  @override
  bool equals2D(Position other, {num? toleranceHoriz}) =>
      other is Projected &&
      Projected.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  @override
  bool equals3D(
    Position other, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) =>
      other is Projected &&
      Projected.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );
}
