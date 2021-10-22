// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../../base.dart';
import '../../geo.dart';

/// A function to create geographic bounds from [coords] with [pointFactory].
GeoBounds geoBoundsFactory(
  Iterable<num> coords, {
  required PointFactory<GeoPoint> pointFactory,
}) {
  final pointCoordsLen = coords.length ~/ 2;
  return GeoBounds.of(
    min: pointFactory.newFrom(
      coords,
      offset: 0,
      length: pointCoordsLen,
    ),
    max: pointFactory.newFrom(
      coords,
      offset: pointCoordsLen,
      length: pointCoordsLen,
    ),
  );
}

/// A function to create any [Bounds] object from [coords] with [pointFactory].
Bounds anyBoundsFactory(
  Iterable<num> coords, {
  required PointFactory pointFactory,
}) {
  final pointCoordsLen = coords.length ~/ 2;
  return Bounds.of(
    min: pointFactory.newFrom(
      coords,
      offset: 0,
      length: pointCoordsLen,
    ),
    max: pointFactory.newFrom(
      coords,
      offset: pointCoordsLen,
      length: pointCoordsLen,
    ),
  );
}
