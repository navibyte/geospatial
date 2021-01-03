// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../../base.dart';
import '../../crs.dart';
import '../../geo.dart';

import 'point.dart';

/// A function to create projected and geographic [Bounds] objects.
///
/// [Point] type candidates for bounds to contain: [Point2], [Point3],
/// [GeoPoint2], [GeoPoint3].
Bounds createAnyBounds(Iterable coords,
    {CRS expectedCRS = CRS84, bool expectM = false}) {
  final pointCoordsLen = coords.length ~/ 2;
  return Bounds.of(
      min: createAnyPoint(coords.take(pointCoordsLen),
          expectedCRS: expectedCRS, expectM: expectM),
      max: createAnyPoint(coords.skip(pointCoordsLen),
          expectedCRS: expectedCRS, expectM: expectM));
}

/// A function to create projected and geographic [Bounds] objects.
///
/// [Point] type candidates for bounds to contain: [Point2], [Point2m],
/// [Point3], [Point3m], [GeoPoint2], [GeoPoint2m], [GeoPoint3], [GeoPoint3m].
Bounds createAnyBoundsWithM(Iterable coords,
    {CRS expectedCRS = CRS84, bool expectM = false}) {
  final pointCoordsLen = coords.length ~/ 2;
  return Bounds.of(
      min: createAnyPointWithM(coords.take(pointCoordsLen),
          expectedCRS: expectedCRS, expectM: expectM),
      max: createAnyPointWithM(coords.skip(pointCoordsLen),
          expectedCRS: expectedCRS, expectM: expectM));
}

/// A function to create geographic [Bounds] objects with [GeoPoint] as min/max.
///
/// [Point] type candidates for bounds to contain: [GeoPoint2], [GeoPoint3].
GeoBounds createGeoBounds(Iterable coords,
    {CRS expectedCRS = CRS84, bool expectM = false}) {
  final pointCoordsLen = coords.length ~/ 2;
  return GeoBounds.of(
      min: createGeoPoint(coords.take(pointCoordsLen),
          expectedCRS: expectedCRS, expectM: expectM),
      max: createGeoPoint(coords.skip(pointCoordsLen),
          expectedCRS: expectedCRS, expectM: expectM));
}

/// A function to create geographic [Bounds] objects with [GeoPoint] as min/max.
///
/// [Point] type candidates for bounds to contain: [GeoPoint2], [GeoPoint2m],
/// [GeoPoint3], [GeoPoint3m].
GeoBounds createGeoBoundsWithM(Iterable coords,
    {CRS expectedCRS = CRS84, bool expectM = false}) {
  final pointCoordsLen = coords.length ~/ 2;
  return GeoBounds.of(
      min: createGeoPointWithM(coords.take(pointCoordsLen),
          expectedCRS: expectedCRS, expectM: expectM),
      max: createGeoPointWithM(coords.skip(pointCoordsLen),
          expectedCRS: expectedCRS, expectM: expectM));
}
