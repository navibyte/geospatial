// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../../base.dart';
import '../../crs.dart';
import '../../geo.dart';

/// A constant factory for geographic [GeoPoint] objects without M coordinate.
///
/// Result type candidates for objects created by the factory: [GeoPoint2],
/// [GeoPoint3].
const PointFactory<GeoPoint> geoPointFactory = _CreateGeoPoint();

/// Returns a factory for geographic [GeoPoint] objects allowing M coordinate.
///
/// Result type candidates for objects created by a factory: [GeoPoint2],
/// [GeoPoint2m], [GeoPoint3], [GeoPoint3m].
PointFactory<GeoPoint> geoPointFactoryAllowingM({required bool expectM}) =>
    _CreateGeoPointAllowingM(expectM: expectM);

/// A constant factory for projected [Point] objects without M coordinate.
///
/// Result type candidates for objects created by the factory: [Point2],
/// [Point3].
const PointFactory projectedPointFactory = _CreateProjectedPoint();

/// Returns a factory for projected [Point] objects allowing M coordinate.
///
/// Result type candidates for objects created by a factory: [Point2],
/// [Point2m], [Point3], [Point3m].
PointFactory projectedPointFactoryAllowingM({required bool expectM}) =>
    _CreateProjectedPointAllowingM(expectM: expectM);

/// Returns a factory for projected and geographic [Point] objects without M.
///
/// Result type candidates for objects created by a factory: [Point2], [Point3],
/// [GeoPoint2], [GeoPoint3].
PointFactory anyPointFactory({CRS expectedCRS = CRS84}) =>
    _CreateAnyPoint(expectedCRS: expectedCRS);

/// Returns a factory for projected and geographic [Point] objects allowing M.
///
/// Result type candidates for objects created by a factory: [Point2],
/// [Point2m], [Point3], [Point3m], [GeoPoint2], [GeoPoint2m], [GeoPoint3],
/// [GeoPoint3m].
PointFactory<Point> anyPointFactoryAllowingM(
        {CRS expectedCRS = CRS84, required bool expectM}) =>
    _CreateAnyPointAllowingM(expectedCRS: expectedCRS, expectM: expectM);

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

class _CreateGeoPoint implements PointFactory<GeoPoint> {
  const _CreateGeoPoint();

  @override
  bool get hasM => false;

  @override
  GeoPoint newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(2, coords, offset: offset, length: length);
    final len = length ?? coords.length;
    if (len >= 3) {
      return GeoPoint3.from(coords, offset: offset);
    } else if (len == 2) {
      return GeoPoint2.from(coords, offset: offset);
    }
    throw _notValidPoint(coords, offset: offset, length: length);
  }

  @override
  GeoPoint newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => z != null
      ? GeoPoint3.lonLatElev(x.toDouble(), y.toDouble(), z.toDouble())
      : GeoPoint2.lonLat(x.toDouble(), y.toDouble());
}

class _CreateGeoPointAllowingM extends _CreateGeoPoint {
  const _CreateGeoPointAllowingM({required bool expectM}) : hasM = expectM;

  @override
  final bool hasM;

  @override
  GeoPoint newFrom(Iterable<num> coords, {int? offset, int? length}) {
    if (!hasM) {
      return super.newFrom(coords, offset: offset, length: length);
    } else {
      CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
      final len = length ?? coords.length;
      if (len >= 4) {
        return GeoPoint3m.from(coords, offset: offset);
      } else if (len == 3) {
        return GeoPoint2m.from(coords, offset: offset);
      }
      throw _notValidPoint(coords, offset: offset, length: length);
    }
  }

  @override
  GeoPoint newWith({num x = 0.0, num y = 0.0, num? z, num? m}) {
    if (!hasM) {
      return super.newWith(x: x, y: y, z: z, m: m);
    } else {
      return z != null
          ? GeoPoint3m.lonLatElevM(
              x.toDouble(), y.toDouble(), z.toDouble(), m?.toDouble() ?? 0.0)
          : GeoPoint2m.lonLatM(
              x.toDouble(), y.toDouble(), m?.toDouble() ?? 0.0);
    }
  }
}

class _CreateProjectedPoint implements PointFactory {
  const _CreateProjectedPoint();

  @override
  bool get hasM => false;

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(2, coords, offset: offset, length: length);
    final len = length ?? coords.length;
    if (len >= 3) {
      return Point3.from(coords, offset: offset);
    } else if (len == 2) {
      return Point2.from(coords, offset: offset);
    }
    throw _notValidPoint(coords, offset: offset, length: length);
  }

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => z != null
      ? Point3.xyz(x.toDouble(), y.toDouble(), z.toDouble())
      : Point2.xy(x.toDouble(), y.toDouble());
}

class _CreateProjectedPointAllowingM extends _CreateProjectedPoint {
  const _CreateProjectedPointAllowingM({required bool expectM})
      : hasM = expectM;

  @override
  final bool hasM;

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    if (!hasM) {
      return super.newFrom(coords, offset: offset, length: length);
    } else {
      CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
      final len = length ?? coords.length;
      if (len >= 4) {
        return Point3m.from(coords, offset: offset);
      } else if (len == 3) {
        return Point2m.from(coords, offset: offset);
      }
      throw _notValidPoint(coords, offset: offset, length: length);
    }
  }

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) {
    if (!hasM) {
      return super.newWith(x: x, y: y, z: z, m: m);
    } else {
      return z != null
          ? Point3m.xyzm(
              x.toDouble(), y.toDouble(), z.toDouble(), m?.toDouble() ?? 0.0)
          : Point2m.xym(x.toDouble(), y.toDouble(), m?.toDouble() ?? 0.0);
    }
  }
}

class _CreateAnyPoint implements PointFactory {
  const _CreateAnyPoint({this.expectedCRS = CRS84});

  final CRS expectedCRS;

  @override
  bool get hasM => false;

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    if (expectedCRS.type == CRSType.geographic) {
      return const _CreateGeoPoint()
          .newFrom(coords, offset: offset, length: length);
    } else {
      return const _CreateProjectedPoint()
          .newFrom(coords, offset: offset, length: length);
    }
  }

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) {
    if (expectedCRS.type == CRSType.geographic) {
      return const _CreateGeoPoint().newWith(x: x, y: y, z: z, m: m);
    } else {
      return const _CreateProjectedPoint().newWith(x: x, y: y, z: z, m: m);
    }
  }
}

class _CreateAnyPointAllowingM implements PointFactory {
  const _CreateAnyPointAllowingM(
      {this.expectedCRS = CRS84, required bool expectM})
      : hasM = expectM;

  final CRS expectedCRS;

  @override
  final bool hasM;

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    if (expectedCRS.type == CRSType.geographic) {
      return _CreateGeoPointAllowingM(expectM: hasM)
          .newFrom(coords, offset: offset, length: length);
    } else {
      return _CreateProjectedPointAllowingM(expectM: hasM)
          .newFrom(coords, offset: offset, length: length);
    }
  }

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) {
    if (expectedCRS.type == CRSType.geographic) {
      return _CreateGeoPointAllowingM(expectM: hasM)
          .newWith(x: x, y: y, z: z, m: m);
    } else {
      return _CreateProjectedPointAllowingM(expectM: hasM)
          .newWith(x: x, y: y, z: z, m: m);
    }
  }
}

FormatException _notValidPoint(Iterable<num> coords,
        {int? offset, int? length}) =>
    FormatException('Not a valid point with ${coords.length} coordinates.');
